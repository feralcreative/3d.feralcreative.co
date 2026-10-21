#!/usr/bin/env python3
"""Check the four fence-pumpkin meshes, optionally cleaning binary body export.

The curved imported shell can export collapsed float32 triangles despite a
clean OpenSCAD status. Re-importing and intersecting an enclosing cube removes
those artifacts without changing the part. Only replace outputs after topology
and volume checks pass; keep the numbered body and plain copy identical.
"""
import argparse
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import numpy as np
from scipy.sparse import coo_matrix
from scipy.sparse.csgraph import connected_components

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('section', ROOT / 'utils/section-outline.py')
section = importlib.util.module_from_spec(spec)
spec.loader.exec_module(section)
STL = ROOT / 'library/holiday/halloween/fence-pumpkins/_work/stl'
PREFIX = 'fence-pumpkin-traditional-'


def volume(tris):
    return np.einsum('ij,ij->i', tris[:, 0], np.cross(tris[:, 1], tris[:, 2])).sum() / 6


def check(path, euler, expected_shells=1):
    tris = section.load(path)
    vertices, faces = np.unique(tris.reshape(-1, 3), axis=0, return_inverse=True)
    faces = faces.reshape(-1, 3)
    edges, counts = np.unique(np.sort(np.concatenate([faces[:, [0, 1]], faces[:, [1, 2]], faces[:, [2, 0]]]), axis=1), axis=0, return_counts=True)
    area = np.linalg.norm(np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0]), axis=1)
    adjacency = coo_matrix((np.ones(len(edges)), (edges[:, 0], edges[:, 1])), shape=(len(vertices), len(vertices)))
    shells, _ = connected_components(adjacency, directed=False)
    actual_euler = len(vertices) - len(edges) + len(tris)
    collapsed, bad = int((area < 1e-12).sum()), int((counts != 2).sum())
    if collapsed or bad or shells != expected_shells or actual_euler != euler:
        raise ValueError(f'{path.name}: collapsed={collapsed}, bad edges={bad}, shells={shells}, Euler={actual_euler}; expected Euler={euler}, shells={expected_shells}')
    print(f'{path.name}: {shells} closed surface(s), no collapsed triangles or bad edges, Euler {euler}, {volume(tris):.3f} mm3')
    return tris


def clean_body():
    plain = STL / (PREFIX + 'body.stl')
    ledger = dict(line.split() for line in (ROOT / 'docs/stl-versions.txt').read_text().splitlines() if line.strip())
    version = STL / f'{PREFIX}body-v{int(ledger[PREFIX + "body"]):02d}.stl'
    before = plain.read_bytes()
    if version.read_bytes() != before:
        raise ValueError('Body plain copy differs from its current numbered version; rebuild before cleaning')
    binary = os.environ.get('OPENSCAD') or shutil.which('openscad') or '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
    with tempfile.TemporaryDirectory(prefix='pumpkin-mesh-') as work:
        source, output = Path(work) / 'clean.scad', Path(work) / 'clean.stl'
        source.write_text(f'intersection() {{ import("{plain.as_posix()}"); translate([-100,-100,-100]) cube([200,200,200]); }}\n')
        subprocess.run([binary, '-o', str(output), '--export-format', 'binstl', str(source)], check=True)
        cleaned = check(output, 2)
        delta = volume(cleaned) - volume(section.load(plain))
        if abs(delta) > .001:
            raise ValueError(f'Cleanup changed volume by {delta} mm3')
        if plain.read_bytes() != before or version.read_bytes() != before:
            raise ValueError('Body changed during cleanup; refusing to overwrite another build')
        data = output.read_bytes()
        version.write_bytes(data)
        plain.write_bytes(data)
        print(f'Body cleanup volume change: {delta:.9g} mm3')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--clean-body', action='store_true', help='Re-import/cube cleanup, then check all four exports')
    args = parser.parse_args()
    if args.clean_body:
        clean_body()
    for piece in ('body', 'door', 'cap', 'stem'):
        check(STL / (PREFIX + piece + '.stl'), 0 if piece == 'door' else 2)
