from pathlib import Path
import json
import runpy
import struct
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[2]
load = runpy.run_path(str(REPO / 'utils/section-outline.py'))['load']
WORK = ROOT / '_work'
STL = WORK / 'stl'

def audit(t):
    vertices, ix = np.unique(t.reshape(-1, 3), axis=0, return_inverse=True)
    faces = ix.reshape(-1, 3)
    directed = np.concatenate([faces[:, [0, 1]], faces[:, [1, 2]], faces[:, [2, 0]]])
    edges, labels, counts = np.unique(np.sort(directed, axis=1), axis=0, return_inverse=True, return_counts=True)
    winding = np.bincount(labels, weights=np.where(directed[:, 0] < directed[:, 1], 1, -1))
    areas = np.linalg.norm(np.cross(t[:, 1] - t[:, 0], t[:, 2] - t[:, 0]), axis=1)
    report = {'triangles': len(t), 'bad_edges': int((counts != 2).sum()), 'collapsed_triangles': int((areas == 0).sum()), 'winding_errors': int((winding != 0).sum()), 'bounds_mm': [t.min((0, 1)).tolist(), t.max((0, 1)).tolist()]}
    assert not any(report[k] for k in ['bad_edges', 'collapsed_triangles', 'winding_errors']), report
    parent = np.arange(len(vertices))
    def root(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    for a, b in edges:
        parent[root(b)] = root(a)
    groups = np.array([root(int(i)) for i in faces[:, 0]])
    report['components'] = len(np.unique(groups))
    assert t[:, :, 2].min() >= -1e-5, report
    return groups, report

def write(path, t):
    t = t.astype('<f4')
    _, report = audit(t.astype(float))
    normal = np.cross(t[:, 1].astype(float)-t[:, 0], t[:, 2].astype(float)-t[:, 0])
    normal /= np.linalg.norm(normal, axis=1)[:, None]
    assert np.isfinite(normal).all()
    records = np.zeros(len(t), dtype=np.dtype([('n', '<f4', 3), ('v', '<f4', (3, 3)), ('a', '<u2')]))
    records['n'] = normal
    records['v'] = t
    path.write_bytes(b'Bookshelf printer lid clip'.ljust(80, b'\0') + struct.pack('<I', len(t)) + records.tobytes())
    return report

if __name__ == '__main__':
    path = STL / 'bookshelf-lid-clip-print-set.stl'
    t = load(path)
    groups, report = audit(t)
    assert report['components'] == 2, report
    reports = {'print-set': report}
    for group in np.unique(groups):
        piece = t[groups == group].copy()
        positioned = piece.copy()
        centre_x = (piece[:, :, 0].min()+piece[:, :, 0].max())/2
        name = 'mount' if centre_x < 0 else 'platform'
        bounds = np.array([piece.min((0, 1)), piece.max((0, 1))])
        piece[:, :, :2] -= bounds.mean(axis=0)[:2]
        piece[:, :, 2] -= piece[:, :, 2].min()
        try:
            reports[name] = write(STL / f'bookshelf-lid-clip-{name}.stl', piece)
        except AssertionError:
            # Preserve fine artwork when float32 recentering collapses an edge.
            reports[name] = write(STL / f'bookshelf-lid-clip-{name}.stl', positioned)
            reports[name]['kept_placement'] = True
        assert reports[name]['components'] == 1
    assert set(reports) == {'print-set', 'mount', 'platform'}
    (WORK / 'mesh-validation.json').write_text(json.dumps(reports, indent=2) + '\n')
    print(json.dumps(reports, indent=2))
