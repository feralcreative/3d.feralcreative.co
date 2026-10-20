#!/usr/bin/env python3
"""Split a binary STL into one file per connected shell, so a part can union them.

Exists because a scanned mesh often arrives as several overlapping closed
shells in one file — a head with the eyes and a lure dropped onto it as
separate spheres — and OpenSCAD's import() keeps them that way. Any boolean
done on that import leaves every overlap in place, so the built STL reports
a negative genus, carries internal faces for the slicer to guess about, and
counts the overlapped volume twice. Unioning the same file with itself does
not fix it either: coincident faces are degenerate for an exact boolean and
the result is worse than the input (tried on fish_koozie.stl: genus 980).

Written as separate files, the shells go back in as separate operands —
`union() for (i = ...) import(...)` — and Manifold resolves the overlaps
properly: one shell out, correct genus, correct volume. Shells are numbered
by size, biggest first, so shell-00 is always the body.

Reports the shell count and each shell's bounding box, plus the edge tally,
which is the manifold check: every edge on a clean closed mesh is shared by
exactly two triangles.

    utils/stl-shells.py "_incoming/<thing>/mesh.stl"
    utils/stl-shells.py "_incoming/<thing>/mesh.stl" --outdir some/dir

Output lands in <mesh dir>/<mesh basename>-shells/shell-NN.stl by default —
beside the original, and therefore under _incoming/, which is not committed.
"""

import argparse
import os
import struct
import sys

import numpy as np


def read_binary_stl(path):
    raw = open(path, "rb").read()
    if raw[:5] == b"solid" and b"facet" in raw[:300]:
        sys.exit(f"{path}: ASCII STL; export it binary first")
    n = struct.unpack("<I", raw[80:84])[0]
    if len(raw) != 84 + n * 50:
        sys.exit(f"{path}: header says {n} triangles, file size disagrees")
    dt = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    return np.frombuffer(raw[84:], dtype=dt)


def shells(rec):
    """Label each triangle with its connected component, via shared vertices."""
    V = rec["v"].reshape(-1, 3)
    uniq, inv = np.unique(np.round(V, 5), axis=0, return_inverse=True)
    F = inv.reshape(-1, 3)
    parent = np.arange(len(uniq))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for a, b, c in F:
        ra = find(a)
        parent[find(b)] = ra
        parent[find(c)] = ra
    roots = np.array([find(i) for i in range(len(uniq))])
    labels = roots[F[:, 0]]
    edges = np.sort(np.vstack([F[:, [0, 1]], F[:, [1, 2]], F[:, [2, 0]]]), axis=1)
    _, count = np.unique(edges, axis=0, return_counts=True)
    tally = dict(zip(*np.unique(count, return_counts=True)))
    return labels, tally


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("stl")
    ap.add_argument("--outdir", help="default: <stl dir>/<stl basename>-shells")
    args = ap.parse_args()

    rec = read_binary_stl(args.stl)
    labels, tally = shells(rec)
    ids, sizes = np.unique(labels, return_counts=True)
    order = np.argsort(-sizes)

    base = os.path.splitext(os.path.basename(args.stl))[0]
    outdir = args.outdir or os.path.join(os.path.dirname(args.stl), f"{base}-shells")
    os.makedirs(outdir, exist_ok=True)

    print(f"{args.stl}: {len(rec)} triangles, {len(ids)} shells")
    for k, idx in enumerate(order):
        sub = rec[labels == ids[idx]]
        pts = sub["v"].reshape(-1, 3)
        lo, hi = pts.min(0), pts.max(0)
        out = os.path.join(outdir, f"shell-{k:02d}.stl")
        with open(out, "wb") as f:
            f.write(f"shell {k} of {base}".encode().ljust(80, b"\0"))
            f.write(struct.pack("<I", len(sub)))
            f.write(sub.tobytes())
        print(f"  {out}  {len(sub):7d} tris  "
              f"x {lo[0]:7.2f}..{hi[0]:7.2f}  y {lo[1]:7.2f}..{hi[1]:7.2f}  "
              f"z {lo[2]:7.2f}..{hi[2]:7.2f}")
    bad = {int(k): int(v) for k, v in tally.items() if k != 2}
    if bad:
        print(f"  edges not shared by exactly two triangles: {bad}  (faces per edge: count)")
    else:
        print("  every edge shared by exactly two triangles")


if __name__ == "__main__":
    main()
