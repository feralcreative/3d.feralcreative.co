#!/usr/bin/env python3
"""Inset the pumpkin backing so its round-over stays inside the original outline.

An outward Minkowski round-over leaves a visible flange beside the printed
body. Offset the convex core's supporting planes inward first, then let the
authoring SCAD add the same radius back. Requires NumPy and local OpenSCAD.
"""
import argparse
import importlib.util
from pathlib import Path
import subprocess
import tempfile

import numpy as np


def clip(faces, normal, distance):
    """Clip a convex polyhedron, retaining the inward side of a plane."""
    result, cut = [], []
    for face in faces:
        values = np.einsum('ij,j->i', face, normal) - distance
        values[abs(values) < 1e-8] = 0
        if np.max(values) <= 0:
            result.append(face)
            continue
        if np.min(values) > 0:
            continue
        points = []
        for i, point in enumerate(face):
            previous = face[i - 1]
            a, b = values[i - 1], values[i]
            if (a > 0) != (b > 0):
                crossing = previous + a / (a - b) * (point - previous)
                points.append(crossing)
                cut.append(crossing)
            if b <= 0:
                points.append(point)
        if len(points) >= 3:
            polygon = np.array(points)
            keep = np.linalg.norm(polygon - np.roll(polygon, 1, axis=0), axis=1) > 1e-8
            if keep.sum() >= 3:
                result.append(polygon[keep])
    if not result:
        raise ValueError('Inset radius consumes the backing')
    if len(cut) >= 3:
        cap = np.unique(np.round(cut, 10), axis=0)
        if len(cap) >= 3:
            centre = cap.mean(axis=0)
            axis = np.eye(3)[np.argmin(abs(normal))]
            u = np.cross(normal, axis)
            u /= np.linalg.norm(u)
            v = np.cross(normal, u)
            angles = np.arctan2((cap - centre) @ v, (cap - centre) @ u)
            result.append(cap[np.argsort(angles)])
    return result


def inset(triangles, radius):
    normals = np.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
    length = np.linalg.norm(normals, axis=1)
    triangles, normals, length = triangles[length > 1e-10], normals[length > 1e-10], length[length > 1e-10]
    normals /= length[:, None]
    centre = triangles.reshape(-1, 3).mean(axis=0)
    flip = np.einsum('ij,ij->i', normals, triangles[:, 0] - centre) < 0
    normals[flip] *= -1
    distances = np.einsum('ij,ij->i', normals, triangles[:, 0])
    _, indices = np.unique(np.round(np.c_[normals, distances], 6), axis=0, return_index=True)
    normals, distances = normals[indices], distances[indices] - radius
    lo, hi = triangles.min(axis=(0, 1)), triangles.max(axis=(0, 1))
    box = np.array([[x, y, z] for x in [lo[0], hi[0]] for y in [lo[1], hi[1]] for z in [lo[2], hi[2]]])
    faces = [box[q] for q in [[0, 1, 3, 2], [4, 6, 7, 5], [0, 4, 5, 1], [2, 3, 7, 6], [0, 2, 6, 4], [1, 5, 7, 3]]]
    # Apply the planar seam and root constraints before the curved hull.
    order = np.argsort(-np.max(abs(normals), axis=1))
    for i in order:
        faces = clip(faces, normals[i], distances[i])
    vertices, inverse = np.unique(np.round(np.concatenate(faces), 6), axis=0, return_inverse=True)
    polygons, start = [], 0
    for face in faces:
        ids = inverse[start:start + len(face)].tolist()
        start += len(face)
        normal = np.cross(face[1] - face[0], face[2] - face[0])
        # OpenSCAD polyhedron faces use clockwise winding from outside.
        if normal @ (face.mean(axis=0) - vertices.mean(axis=0)) > 0:
            ids.reverse()
        polygons.append(ids)
    if len(vertices) < 4 or not np.isfinite(vertices).all():
        raise ValueError('Inset has no finite three-dimensional core')
    violation = np.max(np.einsum('ij,kj->ik', vertices, normals) - distances)
    if violation > 0.0001:
        raise ValueError(f'Inset exceeds a supporting plane by {violation} mm')
    return vertices, polygons


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--radius', type=float, default=2.1)
    parser.add_argument('--seam', type=float, default=0.3)
    parser.add_argument('--inner-x', type=float, default=-22.2)
    parser.add_argument('--openscad', default='/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD')
    args = parser.parse_args()
    if args.radius <= 0 or args.seam < 0 or not -100 < args.inner_x < 0:
        parser.error('radius must be positive, seam nonnegative and inner-x between -100 and 0')
    root = Path(__file__).resolve().parents[1]
    source = root / 'library/holiday/halloween/fence-pumpkins/led-tea-light-jack-o-lantern-pumpkins-model_files/blank-shell.stl'
    spec = importlib.util.spec_from_file_location('section', Path(__file__).with_name('section-outline.py'))
    section = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(section)
    with tempfile.TemporaryDirectory(prefix='pumpkin-backing-') as folder:
        folder = Path(folder)
        scad, mesh = folder / 'core.scad', folder / 'core.stl'
        scad.write_text(f'intersection() {{ hull() import("{source.as_posix()}"); translate([-100,{25 + args.seam},-100]) cube([{100 + args.inner_x},100,200]); }}\n')
        result = subprocess.run([args.openscad, '--export-format=binstl', '-o', str(mesh), str(scad)], capture_output=True, text=True, check=True)
        if 'ERROR:' in result.stderr or not mesh.exists():
            raise ValueError(result.stderr)
        vertices, faces = inset(section.load(mesh), args.radius)
    header = '// Generated by utils/pumpkin-backing.py from the original blank shell.\n'
    header += '// Inset supporting planes before the authoring SCAD applies its inward round-over.\n'
    header += f'backing_inset_radius = {args.radius};\nbacking_inset_seam = {args.seam};\nbacking_inset_inner_x = {args.inner_x};\n'
    # Re-hull the clipped vertices to remove redundant coplanar edges and
    # numerical T-junctions before OpenSCAD's Minkowski operation.
    body = 'module rear_backing_inset() hull() polyhedron(points=[\n'
    body += ',\n'.join('[' + ','.join(f'{v:.6f}' for v in point) + ']' for point in vertices)
    body += '\n], faces=[\n' + ',\n'.join(str(face) for face in faces) + '\n], convexity=10);\n'
    args.output.write_text(header + body)
    print(f'{len(vertices)} vertices, {len(faces)} faces; inward radius {args.radius} mm; {args.output}')


if __name__ == '__main__':
    main()
