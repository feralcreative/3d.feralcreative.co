#!/usr/bin/env python3
"""Turn a one-path SVG outline into a BOSL2 cubic bezpath, ready to paste into a part.

Exists because a traced outline (a heater's end cap, a shelf's edge) should
live in the .scad as numbers rather than be import()ed at render time: an
import that fails exits 0 and hands build.sh a clean STL with the shape
missing, and the imported polygon can't be offset, measured, or extended
along its tangents the way a bezpath can. logos/marks.scad explains the rest.

Output is in millimetres with y up — SVG y runs down — and the outline's
own bounding box (the curves, not their control points) sat on x = 0 and
y = 0. The scale is that box against --height or --width; give one of them. Straight runs come out as degenerate cubics so
the whole outline is one bezpath for bezpath_curve(). Only M/m, L/l, H/h,
V/v, C/c and Z are handled; anything else is an error rather than a guess.

    utils/svg2bez.py "_incoming/Asset 1.svg" --height 80
"""

import argparse
import re
import sys

NUM = r"-?(?:\d+\.?\d*|\.\d+)(?:[eE]-?\d+)?"


def parse(d):
    toks = re.findall(rf"[A-Za-z]|{NUM}", d)
    pts = []  # bezpath: P, c1, c2, P, c1, c2, P ...
    cur = start = None
    i = 0

    def num():
        nonlocal i
        v = float(toks[i])
        i += 1
        return v

    def line_to(p):
        nonlocal cur
        a, b = cur, p
        pts.extend([
            (a[0] + (b[0] - a[0]) / 3, a[1] + (b[1] - a[1]) / 3),
            (a[0] + 2 * (b[0] - a[0]) / 3, a[1] + 2 * (b[1] - a[1]) / 3),
            b,
        ])
        cur = b

    def more_numbers():
        return i < len(toks) and re.fullmatch(NUM, toks[i])

    while i < len(toks):
        cmd = toks[i]
        i += 1
        rel = cmd.islower()
        c = cmd.upper()
        ox, oy = (cur if cur and rel else (0.0, 0.0))
        if c == "M":
            cur = (ox + num(), oy + num())
            start = cur
            pts.append(cur)
            while more_numbers():  # implicit lineto after moveto
                ox, oy = cur if rel else (0.0, 0.0)
                line_to((ox + num(), oy + num()))
        elif c == "L":
            while more_numbers():
                ox, oy = cur if rel else (0.0, 0.0)
                line_to((ox + num(), oy + num()))
        elif c == "H":
            while more_numbers():
                line_to(((cur[0] if rel else 0.0) + num(), cur[1]))
        elif c == "V":
            while more_numbers():
                line_to((cur[0], (cur[1] if rel else 0.0) + num()))
        elif c == "C":
            while more_numbers():
                ox, oy = cur if rel else (0.0, 0.0)
                c1 = (ox + num(), oy + num())
                c2 = (ox + num(), oy + num())
                p = (ox + num(), oy + num())
                pts.extend([c1, c2, p])
                cur = p
        elif c == "Z":
            if abs(cur[0] - start[0]) > 1e-3 or abs(cur[1] - start[1]) > 1e-3:
                line_to(start)  # a real gap; a rounding-error one is already closed
        else:
            sys.exit(f"unhandled path command {cmd!r}; flatten it in the editor first")
    return pts


def bbox(pts, steps=64):
    """Bounding box of the curves themselves; a control point can sit well outside it."""
    xs, ys = [], []
    for k in range(0, len(pts) - 1, 3):
        p0, p1, p2, p3 = pts[k:k + 4]
        for j in range(steps + 1):
            t = j / steps
            u = 1 - t
            xs.append(u**3 * p0[0] + 3 * u**2 * t * p1[0] + 3 * u * t**2 * p2[0] + t**3 * p3[0])
            ys.append(u**3 * p0[1] + 3 * u**2 * t * p1[1] + 3 * u * t**2 * p2[1] + t**3 * p3[1])
    return min(xs), min(ys), max(xs), max(ys)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("svg")
    size = ap.add_mutually_exclusive_group(required=True)
    size.add_argument("--height", type=float, help="real height of the shape, mm")
    size.add_argument("--width", type=float, help="real width of the shape, mm")
    ap.add_argument("--steps", type=int, default=24, help="splinesteps to suggest in the comment")
    a = ap.parse_args()

    svg = open(a.svg).read()
    paths = re.findall(r'<path[^>]*\sd="([^"]+)"', svg)
    if len(paths) != 1:
        sys.exit(f"expected exactly one <path>, found {len(paths)}")
    pts = parse(paths[0])

    x0, y0, x1, y1 = bbox(pts)
    w, h = x1 - x0, y1 - y0
    s = a.height / h if a.height else a.width / w
    out = [((x - x0) * s, (y1 - y) * s) for x, y in pts]

    print(f"// {a.svg}: {len(out)} points, {(len(out) - 1) // 3} cubics, "
          f"{w * s:.3f} x {h * s:.3f} mm, y up. bezpath_curve(BEZ, splinesteps = {a.steps})")
    print("BEZ = [")
    print(f"    [{out[0][0]:7.3f}, {out[0][1]:7.3f}],")
    for k in range(1, len(out), 3):
        print("    " + ", ".join(f"[{x:7.3f}, {y:7.3f}]" for x, y in out[k:k + 3]) + ",")
    print("];")


if __name__ == "__main__":
    main()
