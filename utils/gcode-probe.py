#!/usr/bin/env python3
"""
gcode-probe.py — read a sliced job and report what it will actually do.

The design loop already has render.sh to see geometry and build.sh to mesh it
and report manifoldness and genus. This is the same idea one stage later: a
handful of facts read out of the G-code, so a claim about a print is checked
before the printer runs rather than measured off the plastic afterwards.

Every figure here exists because it was needed once:

- **Height and layer count.** A coupon printed 6.41 mm short of its mesh and the
  first question was whether the slicer had emitted the part at all. Reading max
  Z takes a second and settles it.
- **Temperatures.** A nozzle temperature fix was applied, appeared to be
  selected, and did not reach the printer. The G-code is the last place the
  number can hide — if M104 says 265 the print will run at 265.
- **Retraction distances.** Same reason. `filament_retraction_length` overriding
  the machine's value is worth trusting only once it shows up as real E moves.
- **Extrusion-role mix at a height.** Whether a thin wall resolves into clean
  perimeters or degenerates into gap fill, which is the open question about the
  chalk holder's 1.26 mm collet fingers given inner walls are 0.45.

Usage:
  utils/gcode-probe.py /tmp/slice/plate_1.gcode
  utils/gcode-probe.py out.gcode.3mf --at-z 38.0
"""

import argparse
import collections
import os
import re
import sys
import zipfile

RE_Z = re.compile(r"^;Z:([0-9.]+)")
RE_TEMP = re.compile(r"^M10[49]\s+S([0-9.]+)")
RE_E = re.compile(r"^G[01]\b.*?\bE(-?[0-9.]+)")
RE_TYPE = re.compile(r"^;TYPE:(.+)")
RE_HEADER = re.compile(r"^;\s*(total layer number|max_z_height|total filament"
                       r"|filament used|estimated printing time)[^:]*:\s*(.+)", re.I)


def load(path):
    """Return G-code text, from a .gcode file or from inside a .gcode.3mf."""
    if path.endswith(".3mf") or zipfile.is_zipfile(path):
        with zipfile.ZipFile(path) as z:
            names = [n for n in z.namelist() if n.endswith(".gcode")]
            if not names:
                sys.exit("error: no .gcode inside %s — was it sliced, or only saved?"
                         % path)
            return z.read(names[0]).decode("utf-8", "replace"), names[0]
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read(), os.path.basename(path)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("gcode", help=".gcode file or .gcode.3mf archive")
    ap.add_argument("--at-z", type=float, default=None,
                    help="also break down extrusion roles for the layer at this Z")
    ap.add_argument("--expect-z", type=float, default=None,
                    help="fail if max Z differs from this by more than 0.2 mm")
    args = ap.parse_args()

    if not os.path.exists(args.gcode):
        sys.exit("error: no such file: %s" % args.gcode)

    text, which = load(args.gcode)
    lines = text.splitlines()

    header, temps, retracts = {}, [], collections.Counter()
    zs = []
    # role counts per layer index, plus the Z each layer starts at
    layer_roles = collections.defaultdict(collections.Counter)
    layer_z, cur_layer, cur_role = [], -1, None
    pending = 0.0  # negative E accumulated in the retraction currently open
    layer_work = collections.Counter()  # filament extruded per layer, in mm

    for line in lines:
        m = RE_HEADER.match(line)
        if m:
            header.setdefault(m.group(1).lower(), m.group(2).strip())
            continue
        m = RE_Z.match(line)
        if m:
            z = float(m.group(1))
            zs.append(z)
            cur_layer += 1
            layer_z.append(z)
            continue
        m = RE_TEMP.match(line)
        if m:
            # Order matters more than frequency: the first setpoint is the
            # first-layer temperature and the next one is the body. Reporting
            # only the highest would call a 245/240 job a 245 C print.
            t = float(m.group(1))
            if not temps or temps[-1] != t:
                temps.append(t)
            continue
        m = RE_E.match(line)
        if m:
            # A retraction is not one G-code move. With retract_before_wipe
            # below 100% the slicer splits it: a pure `G1 E-n` for the part
            # taken before the wipe, then the remainder spread over the wipe's
            # own `G1 X.. Y.. E-..` moves. Measuring only the pure move reports
            # a 1.6 mm retraction as 1.15. So accumulate every negative E until
            # extrusion resumes, and treat that whole run as one event.
            e = float(m.group(1))
            if e < 0:
                pending -= e
            else:
                if pending:
                    retracts[round(pending, 2)] += 1
                    pending = 0.0
                # Positive E with no X or Y is a deretraction, not extrusion.
                # Counting it inflates the per-layer figure by the whole
                # retraction budget, which makes two runs of the SAME geometry
                # disagree whenever their retraction length differs.
                if cur_layer >= 0 and ("X" in line or "Y" in line):
                    layer_work[cur_layer] += e
            continue
        m = RE_TYPE.match(line)
        if m:
            cur_role = m.group(1).strip()
            if cur_layer >= 0:
                layer_roles[cur_layer][cur_role] += 1

    print("file            %s" % which)
    for key in ("total layer number", "max_z_height", "estimated printing time",
                "total filament", "filament used"):
        if key in header:
            print("%-15s %s" % (key.replace("total layer number", "layers")
                                   .replace("max_z_height", "max z"), header[key]))

    max_z = max(zs) if zs else None
    print("layers seen     %d" % len(zs))
    print("max z seen      %s" % ("%.3f" % max_z if max_z is not None else "n/a"))

    print("temp setpoints  %s" % (" -> ".join("%g" % t for t in temps) or "none"))
    live = [t for t in temps if t > 0]
    if len(live) >= 2:
        print("  first layer   %g C" % live[0])
        print("  body          %g C" % live[1])
    elif live:
        print("  throughout    %g C" % live[0])

    if retracts:
        total = sum(retracts.values())
        print("retractions     %d total" % total)
        # Distances scatter across neighbouring thousandths because wipe eats
        # part of the move, so the interesting figures are what dominates and
        # what the longest is — not a histogram of near-identical values.
        for dist, n in retracts.most_common(4):
            print("  %-7s mm     x%-5d %4.1f%%" % (dist, n, 100.0 * n / total))
        print("  longest       %s mm" % max(retracts))
    else:
        print("retractions     none found (firmware retraction?)")

    # Where the amount of work per layer falls off a cliff, some geometry
    # finished and everything above it is printing alone. That matters for thin
    # tall features: while a bulkier neighbour was still printing, each layer
    # took long enough for the thin part to cool between visits, and the moment
    # the neighbour ends, the same feature gets revisited every few seconds with
    # no cooling interval. It is a common reason a tall thin feature prints fine
    # up to one height and turns to mush above it.
    if len(layer_work) > 4:
        drops = []
        for i in range(1, len(layer_z)):
            before, after = layer_work.get(i - 1, 0.0), layer_work.get(i, 0.0)
            if before > 1.0 and after / before < 0.5:
                drops.append((after / before, i, before, after))
        # Every cliff, not just the steepest: a part usually has several as
        # successive features top out, and the interesting one is rarely the
        # biggest. Ordered by height so it reads as a profile of the print.
        drops.sort()
        for ratio, i, before, after in sorted(drops[:3], key=lambda d: d[1]):
            print("work cliff      layer %d at z %.2f: %.0f -> %.0f mm "
                  "extruded (%.0f%% drop)"
                  % (i + 1, layer_z[i], before, after, 100 * (1 - ratio)))

    if args.at_z is not None and layer_z:
        idx = min(range(len(layer_z)), key=lambda i: abs(layer_z[i] - args.at_z))
        print("roles at z %.2f (layer %d, nearest to %.2f)"
              % (layer_z[idx], idx + 1, args.at_z))
        roles = layer_roles.get(idx)
        if not roles:
            print("  no extrusion on this layer")
        for role, n in roles.most_common():
            print("  %-24s %d segments" % (role, n))
        if roles and any("Gap" in r for r in roles):
            print("  NOTE gap fill present — a wall here did not resolve into "
                  "clean perimeters")

    if args.expect_z is not None and max_z is not None:
        if abs(max_z - args.expect_z) > 0.2:
            sys.exit("\nFAIL max z %.3f differs from expected %.3f"
                     % (max_z, args.expect_z))
        print("\nOK   max z %.3f matches expected %.3f" % (max_z, args.expect_z))


if __name__ == "__main__":
    main()
