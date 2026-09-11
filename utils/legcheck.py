#!/usr/bin/env python3
"""legcheck.py — how far the twin clip's legs can bend, and what stops them.

This exists because the clip is meant to be snapped in and squeezed out
repeatedly, and "does it fit" says nothing about that. Fit is a boolean the
OpenSCAD checks already answer; how much travel is left before the leg cracks
is a number, it moves with every section change, and nobody can eyeball it off
a render.

It reads the parameters out of the .scad rather than duplicating them, so it
cannot drift from the part. Two limits are reported and the binding one is
whichever is smaller:

  STRAIN     the leg is a tapered cantilever loaded at the fin tab. Peak
             bending strain is integrated along the real section, not taken
             from the prismatic formula, because the taper moves the peak
             about 10 mm off the root and the formula would put it at the root
             and overstate it.

  GEOMETRY   the two legs bend toward each other. Long before the strain
             limit on a thin leg, their inboard faces meet. Checked along the
             whole length with the true deflected shape, not by translating
             the leg, because a translated leg closes the gap at the root
             where a real one does not move at all.

Allowables, and they are judgement rather than data: PETG yields around 2.5-3 %
strain. A snap-fit assembled ONCE is normally worked to about 70 % of yield;
one assembled repeatedly to about 30 %, which is where the 1.0 % column comes
from. There is no fatigue data here for printed PETG in this orientation, so
treat 1.0 % as a considered default and not as a measurement.

Usage:
    utils/legcheck.py                       # the part as it stands
    utils/legcheck.py --hook 3.8            # a specific engagement
    utils/legcheck.py --sweep               # compare section options
"""

import argparse
import math
import pathlib
import re
import sys

E_PETG = 2000.0  # MPa
PART = pathlib.Path(__file__).resolve().parent.parent / "parts" / "screen-fence-rail.scad"


def read_params(path):
    """Pull `name = <arithmetic>;` assignments out of the .scad.

    Numbers alone are not enough: the track's reaches are derived in the part
    (`trk_ledge_x = (trk_clear_w - trk_fin_gap) / 2`) and re-deriving them here
    would be exactly the duplicated constant this script exists to avoid. So
    plain arithmetic over names already known is evaluated, in repeated passes
    until nothing new resolves. Anything more complicated is skipped.
    """
    text = path.read_text(encoding="utf-8")
    pending = {}
    for m in re.finditer(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([0-9A-Za-z_+\-*/(). ]+?)\s*;", text, re.M):
        pending[m.group(1)] = m.group(2)
    out = {}
    for _ in range(len(pending) + 1):
        progress = False
        for name, expr in list(pending.items()):
            try:
                out[name] = float(eval(expr, {"__builtins__": {}}, dict(out)))
            except Exception:
                continue
            del pending[name]
            progress = True
        if not progress:
            break
    m = re.search(r'^twin_catch\s*=\s*"([a-z]+)"', text, re.M)
    out["twin_catch"] = m.group(1) if m else "fin"
    m = re.search(r"^clip_coupon_hook\s*=\s*\[([^\]]*)\]", text, re.M)
    out["ladder"] = [float(v) for v in m.group(1).split(",")] if m else []
    return out


class Leg:
    """A tapered cantilever, root at the crossbar, loaded at the fin tab."""

    def __init__(self, p, n=2000):
        fin = p["twin_catch"] == "fin"
        self.reach = p["trk_ledge_x"] if fin else p["trk_hook_x"]
        under = p["trk_ledge_z0"] if fin else p["trk_lip_z0"]
        self.zbar = p["trk_depth"] + p["clip_fence_h"] - p["clip_bridge_t"]
        self.tz1 = under - p["clip_tab_clr"]
        self.a = self.zbar - self.tz1
        self.t_root = p["clip_leg_root_t"]
        self.t_tip = p["clip_leg_tip_t"]
        self.xo = self.reach + p["clip_clr"]
        self.bore = p["trk_clear_w"]
        self.fillet_in = p.get("clip_leg_fillet_in", 0.0)
        # The key's near edge, from the same wall the leg is referenced to. It
        # is set by the root, because that is where the key has to squeeze past.
        self.key_edge = self.xo + self.t_root + self.fillet_in + p.get("key_clr", 0.20)
        self.has_key = bool(p.get("twin_key_on", 1))
        self.n = n

    def t(self, s):
        """Thickness at s, the distance from the loaded end."""
        return max(self.t_tip, self.t_root * math.sqrt(max(s, 0.0) / self.a))

    def _integral(self):
        ds = self.a / self.n
        return sum(((i + 0.5) * ds) ** 2 / (self.t((i + 0.5) * ds) ** 3 / 12.0) * ds
                   for i in range(self.n))

    def peak_strain(self, delta):
        load = delta * E_PETG / self._integral()
        worst, at = 0.0, 0.0
        ds = self.a / self.n
        for i in range(self.n):
            s = (i + 0.5) * ds
            t = self.t(s)
            e = load * s * t / (2 * (t ** 3 / 12.0) * E_PETG)
            if e > worst:
                worst, at = e, s
        return worst, at, load

    def travel_at(self, target):
        lo, hi = 0.0, 40.0
        for _ in range(60):
            mid = (lo + hi) / 2
            if self.peak_strain(mid)[0] > target:
                hi = mid
            else:
                lo = mid
        return lo

    def shape(self, delta, s):
        """Deflection at s (distance from the loaded end) for tip travel delta.

        Prismatic cantilever shape. The taper changes it a little; it is used
        only for the leg-to-leg clearance, where being a few percent out at
        mid-span does not change which limit binds.
        """
        x = self.a - s                      # distance from the root
        if x <= self.a:
            return delta * (3 * self.a * x * x - x ** 3) / (2 * self.a ** 3)
        return delta

    def clearance(self, delta, margin=0.40):
        """Smallest gap between the two legs' inboard faces, and where."""
        worst, at = 1e9, 0.0
        for i in range(self.n + 1):
            s = i * self.a / self.n
            gap = self.bore - 2 * (self.xo + self.t(s) + self.shape(delta, s))
            if gap < worst:
                worst, at = gap, s
        return worst, at

    def fillet(self, s):
        """How far the inboard root fillet stands proud of the leg face at s."""
        r = self.fillet_in
        if r <= 0:
            return 0.0
        u = r - (self.a - s)            # distance up into the fillet
        return r - math.sqrt(max(r * r - u * u, 0.0)) if 0 <= u <= r else 0.0

    def key_gap(self, delta):
        """Smallest gap between ONE leg's inboard face and the key, and where.

        Against the key the leg is alone, so this uses the true deflected shape
        for the leg and a fixed edge for the key — unlike the leg-to-leg case
        there is nothing moving on the other side.
        """
        worst, at = 1e9, 0.0
        for i in range(self.n + 1):
            s = i * self.a / self.n
            gap = self.key_edge - (self.xo + self.t(s) + self.fillet(s)
                                   + self.shape(delta, s))
            if gap < worst:
                worst, at = gap, s
        return worst, at

    def travel_to_key(self):
        lo, hi = 0.0, 40.0
        for _ in range(60):
            mid = (lo + hi) / 2
            if self.key_gap(mid)[0] < 0:
                hi = mid
            else:
                lo = mid
        return lo

    def travel_to_touch(self, margin=0.40):
        lo, hi = 0.0, 40.0
        for _ in range(60):
            mid = (lo + hi) / 2
            if self.clearance(mid)[0] < margin:
                hi = mid
            else:
                lo = mid
        return lo


def report(p, hooks, slack):
    leg = Leg(p)
    print("leg      root %.2f -> tip %.2f mm, free length %.2f mm, catching the %s"
          % (leg.t_root, leg.t_tip, leg.a, p["twin_catch"]))
    print("travel   = hook + %.2f, and both legs move it, so the pair closes by twice\n" % slack)

    kt = leg.travel_to_key()
    print("key      %.3f mm wide, near edge at %.3f; it stops the leg after %.2f mm\n"
          % (leg.bore - 2 * leg.key_edge, leg.key_edge, kt))

    print("  hook   move   strain   peak at   force      leg gap   verdict")
    for h in hooks:
        d = h + slack
        e, at, f = leg.peak_strain(d)
        gap, _ = leg.clearance(d)
        flag = "ok" if e <= 0.010 and gap >= 0.40 else (
            "STRAIN" if e > 0.010 else "TOUCHING")
        print("  %5.2f  %5.2f   %5.2f%%   %4.1f mm   %4.2f N/mm  %6.2f    %s"
              % (h, d, e * 100, at, f, gap, flag))
    th = p.get("twin_hook", hooks[0])
    print("\n  with the key home a leg reaches %.2f mm of the %.2f it needs to release,"
          % (kt, th + slack))
    print("  so the barb stays %.2f mm of its %.2f under the fin." % (th - kt, th))

    print("\n  limits")
    for tgt, note in ((0.010, "repeated use, ~30% of yield"),
                      (0.015, ""),
                      (0.020, "one-time assembly, ~70% of yield")):
        t = leg.travel_at(tgt)
        print("    %.1f%% strain   travel %5.2f   hook %5.2f   %s"
              % (tgt * 100, t, t - slack, note))
    touch = leg.travel_to_touch()
    print("    legs touch     travel %5.2f   hook %5.2f   (0.40 mm margin)"
          % (touch, touch - slack))
    bind = min(leg.travel_at(0.010), touch)
    print("\n  binding limit for repeated use: hook %.2f mm, %s"
          % (bind - slack, "strain" if leg.travel_at(0.010) < touch else "legs touching"))


def sweep(p, slack):
    print("  root   tip    travel @1.0%   force at 3.45   peak sits")
    for root, tip in ((1.74, 1.74), (1.35, 1.35), (1.05, 1.05),
                      (1.74, 1.35), (1.74, 1.05), (2.19, 1.05), (2.19, 0.87)):
        q = dict(p, clip_leg_root_t=root, clip_leg_tip_t=tip)
        leg = Leg(q)
        t = leg.travel_at(0.010)
        _, at, f = leg.peak_strain(3.45)
        print("  %.2f   %.2f   %6.2f mm      %5.2f N/mm     %4.1f mm off the tab"
              % (root, tip, t, f, at))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--hook", type=float, action="append",
                    help="engagement to report; repeatable. Default is the coupon ladder.")
    ap.add_argument("--slack", type=float, default=0.05,
                    help="extra squeeze past the engagement (default 0.05)")
    ap.add_argument("--sweep", action="store_true", help="compare section options")
    ap.add_argument("--part", type=pathlib.Path, default=PART)
    args = ap.parse_args()

    if not args.part.exists():
        sys.exit("no such part: %s" % args.part)
    p = read_params(args.part)
    for need in ("clip_leg_root_t", "clip_leg_tip_t", "clip_fence_h", "trk_clear_w"):
        if need not in p:
            sys.exit("%s does not define %s — has the section been renamed?"
                     % (args.part, need))

    if args.sweep:
        sweep(p, args.slack)
        return
    report(p, args.hook or p["ladder"] or [p["clip_hook"]], args.slack)


if __name__ == "__main__":
    main()
