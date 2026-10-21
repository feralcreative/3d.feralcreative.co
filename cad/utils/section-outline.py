#!/usr/bin/env python3
"""Write the filled outer outline of a mesh's section as an OpenSCAD polygon.

Exists because OpenSCAD can section a mesh (projection(cut = true)) but cannot
fill it: a hollow part's section is a thin ring, and there is no operation that
turns the ring into the solid shape it encloses. hull() overshoots any lobe or
notch in the outline. A flat wall or door cut into a hollow imported shell needs
that solid shape, so it is computed here and included as data.

The section is taken on a plane normal to --axis at --at. Every region larger
than --min-area is written, with its holes filled: a lobe can cross the plane
as an island of its own. NAME is a list of polygons, in the other two axes in
order (x z for --axis y), ready for
translate(...) rotate(...) linear_extrude() for (p = NAME) polygon(p).

    utils/section-outline.py pumpkin.stl --axis y --at 25 --name back_outline -o back-outline.scad
"""

import argparse
import struct
import sys

import numpy as np


def load(path):
    data = open(path, "rb").read()
    count = struct.unpack("<I", data[80:84])[0]
    if 84 + 50 * count == len(data):
        rows = np.frombuffer(data[84:], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]), count=count)
        return rows["v"].reshape(-1, 3, 3).astype(float)
    words = data.decode(errors="replace").split()
    vertices = [words[i + 1:i + 4] for i, w in enumerate(words) if w == "vertex"]
    return np.array(vertices, dtype=float).reshape(-1, 3, 3)


def section(tris, axis, at, keep):
    d = tris[:, :, axis] - at
    t, d = tris[(d.max(1) > 0) & (d.min(1) < 0)], d[(d.max(1) > 0) & (d.min(1) < 0)]
    segs = []
    for i, j in ((0, 1), (1, 2), (2, 0)):
        cross = (d[:, i] > 0) != (d[:, j] > 0)
        k = d[cross, i] / (d[cross, i] - d[cross, j])
        p = t[cross, i] + k[:, None] * (t[cross, j] - t[cross, i])
        segs.append((np.where(cross)[0], p[:, keep]))
    ends = np.zeros((len(t), 2, 2))
    filled = np.zeros(len(t), dtype=int)
    for rows, pts in segs:
        ends[rows, filled[rows]] = pts
        filled[rows] += 1
    return ends[filled == 2]


def numpy_outline(segs, simplify=0.02, min_area=1.0):
    """Fill closed manifold section loops when Shapely is unavailable."""
    vertices, ids = np.unique(np.round(segs.reshape(-1, 2), 5), axis=0, return_inverse=True)
    edges = np.unique(np.sort(ids.reshape(-1, 2), axis=1), axis=0)
    edges = edges[edges[:, 0] != edges[:, 1]]
    neighbours = {}
    for a, b in edges:
        neighbours.setdefault(int(a), []).append(int(b))
        neighbours.setdefault(int(b), []).append(int(a))
    if any(len(points) != 2 for points in neighbours.values()):
        raise ValueError('Section has open or branching contours; cannot fill it safely without Shapely')

    def reduce(points):
        if len(points) <= 2 or simplify <= 0:
            return points
        direction = points[-1] - points[0]
        delta = points - points[0]
        distance = np.abs(direction[0] * delta[:, 1] - direction[1] * delta[:, 0]) / max(np.linalg.norm(direction), 1e-12)
        at = int(np.argmax(distance))
        if distance[at] <= simplify:
            return points[[0, -1]]
        return np.concatenate([reduce(points[:at + 1])[:-1], reduce(points[at:])])

    loops, visited = [], set()
    for start in neighbours:
        if start in visited:
            continue
        loop, previous, current = [], None, start
        while current not in visited:
            visited.add(current)
            loop.append(current)
            choices = neighbours[current]
            following = choices[0] if choices[0] != previous else choices[1]
            previous, current = current, following
        if current != start:
            raise ValueError('Section loop did not close at its start')
        points = vertices[loop]
        middle = len(points) // 2
        points = np.concatenate([reduce(points[:middle + 1])[:-1], reduce(np.concatenate([points[middle:], points[:1]]))[:-1]])
        following = np.roll(points, -1, axis=0)
        area = abs((points[:, 0] * following[:, 1] - points[:, 1] * following[:, 0]).sum()) / 2
        if len(points) >= 3 and area >= min_area:
            loops.append((area, points))

    def contains(polygon, point):
        a, b = polygon, np.roll(polygon, -1, axis=0)
        cross = (a[:, 1] > point[1]) != (b[:, 1] > point[1])
        a, b = a[cross], b[cross]
        return bool(np.count_nonzero(point[0] < a[:, 0] + (point[1] - a[:, 1]) * (b[:, 0] - a[:, 0]) / (b[:, 1] - a[:, 1])) % 2)

    result = []
    for _, polygon in sorted(loops, key=lambda item: -item[0]):
        if not any(contains(outer, polygon[0]) for outer in result):
            result.append(polygon)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("mesh")
    p.add_argument("--axis", choices="xyz", required=True)
    p.add_argument("--at", type=float, required=True, help="plane position along --axis, mm")
    p.add_argument("--name", default="outline", help="OpenSCAD variable name")
    p.add_argument("--simplify", type=float, default=0.02, help="mm")
    p.add_argument("--min-area", type=float, default=1.0, help="mm2; smaller regions are dropped")
    p.add_argument("-o", "--output", required=True)
    args = p.parse_args()

    axis = "xyz".index(args.axis)
    keep = [i for i in range(3) if i != axis]
    segs = section(load(args.mesh), axis, args.at, keep)
    try:
        from shapely.geometry import LineString, Polygon
        from shapely.ops import polygonize, unary_union
    except ImportError:
        regions = numpy_outline(segs, args.simplify, args.min_area)
    else:
        faces = list(polygonize(unary_union([LineString(np.round(s, 5)) for s in segs if np.linalg.norm(s[1] - s[0]) > 1e-9])))
        shape = unary_union([Polygon(f.exterior) for f in faces])
        polygons = [Polygon(g.exterior).simplify(args.simplify) for g in getattr(shape, "geoms", [shape]) if g.area >= args.min_area]
        polygons.sort(key=lambda g: -g.area)
        regions = [np.array(g.exterior.coords[:-1]) for g in polygons]
    if not regions:
        sys.exit(f"no closed section at {args.axis}={args.at}")
    with open(args.output, "w") as f:
        f.write(f"// Generated by utils/section-outline.py from {args.mesh} at {args.axis}={args.at}; do not edit.\n")
        f.write(f"// Filled section regions, coordinates {'xyz'[keep[0]]} {'xyz'[keep[1]]}.\n")
        f.write(f"{args.name} = [\n")
        f.write(",\n".join("    [" + ", ".join(f"[{x:.3f}, {y:.3f}]" for x, y in g) + "]" for g in regions))
        f.write("\n];\n")
    for g in regions:
        b = [*g.min(0), *g.max(0)]
        following = np.roll(g, -1, axis=0)
        area = abs((g[:, 0] * following[:, 1] - g[:, 1] * following[:, 0]).sum()) / 2
        print(f"region {area:7.0f} mm2, {len(g)} points, "
              f"{'xyz'[keep[0]]} {b[0]:.2f}..{b[2]:.2f}, {'xyz'[keep[1]]} {b[1]:.2f}..{b[3]:.2f}")
    print(f"wrote {args.output}: {len(regions)} regions")


if __name__ == "__main__":
    main()
