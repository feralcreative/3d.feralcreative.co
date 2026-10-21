#!/usr/bin/env python3
"""Measure the pumpkin's sealed disc pocket and verify its native insert pause.

The pause is stored in the editable 3MF and emitted by Flash Studio. Verification
reads the sliced archive; no G-code is patched or sent to a printer.
"""
import argparse
import json
import math
from pathlib import Path
import re
import xml.etree.ElementTree as ET
import zipfile


def measure(vertices, faces, profile, shift):
    adjacent = [set() for _ in vertices]
    for a, b, c in faces:
        for u, v in ((a, b), (b, c), (c, a)):
            adjacent[u].add(v)
            adjacent[v].add(u)
    labels, groups = {}, []
    for start in range(len(vertices)):
        if start in labels:
            continue
        group, todo = [], [start]
        labels[start] = len(groups)
        while todo:
            u = todo.pop()
            group.append(u)
            for v in adjacent[u]:
                if v not in labels:
                    labels[v] = len(groups)
                    todo.append(v)
        groups.append(group)
    volumes = [0.0] * len(groups)
    for face in faces:
        a, b, c = [vertices[i] for i in face]
        volumes[labels[face[0]]] += (
            a[0]*(b[1]*c[2]-b[2]*c[1]) +
            a[1]*(b[2]*c[0]-b[0]*c[2]) +
            a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
    if len(groups) != 2 or sum(v < 0 for v in volumes) != 1:
        raise ValueError('Disc pause requires one solid with one enclosed disc cavity')
    cavity = [vertices[i] for i in groups[next(i for i, v in enumerate(volumes) if v < 0)]]
    lo = [min(v[d] for v in cavity) for d in range(3)]
    hi = [max(v[d] for v in cavity) for d in range(3)]
    dims = [hi[d]-lo[d] for d in range(3)]
    if max(abs(dims[d]-25.4) for d in (0, 1)) > .001 or abs(dims[2]-2.2) > .001:
        raise ValueError(f'Unexpected disc cavity dimensions: {dims}')
    center = [(lo[d]+hi[d])/2+shift[d] for d in (0, 1)]
    span = [lo[2]+shift[2], hi[2]+shift[2]]
    first, layer = map(float, (profile['initial_layer_print_height'], profile['layer_height']))
    if profile['machine_pause_gcode'].strip() != 'PAUSE' or int(profile['raft_layers']) != 0:
        raise ValueError('Requires native PAUSE and no raft')
    if str(profile['independent_support_layer_height']) != '0':
        raise ValueError('Disable independent support layer heights for a stable pause boundary')
    index = next(i for i in range(400) if first+layer*i-layer/2 > span[1])
    pause_z = round(first+layer*index, 3)
    if span[0]+2 > pause_z-layer+.001:
        raise ValueError('Steel disc would protrude above the completed layer at pause')
    # Measure the cover's upward planar face immediately above the cavity.
    tops = []
    cx, cy = ((lo[d]+hi[d])/2 for d in (0, 1))
    for face in faces:
        a, b, c = [vertices[i] for i in face]
        if max(a[2], b[2], c[2])-min(a[2], b[2], c[2]) > 1e-5:
            continue
        if a[2] <= hi[2]+.001 or a[2] > hi[2]+1:
            continue
        if math.hypot((a[0]+b[0]+c[0])/3-cx, (a[1]+b[1]+c[1])/3-cy) > 14.8:
            continue
        if (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0]) > 0:
            tops.append(a[2]+shift[2])
    if not tops:
        raise ValueError('No planar disc cover found')
    cover_top = min(tops)
    cover_layers = [round(first+layer*i, 3) for i in range(index, 400)
                    if first+layer*i-layer/2 < cover_top]
    if len(cover_layers) != 2:
        raise ValueError(f'Expected exactly two cover layers: {cover_layers}')
    return dict(center=center, cavity_z=span, pause_z=pause_z,
                layer_index=index, cover_z=cover_layers, disc_d=25, disc_t=2,
                cover_thickness=cover_top-span[1])


def marker(info):
    root = ET.Element('custom_gcodes_per_layer')
    plate = ET.SubElement(root, 'plate')
    ET.SubElement(plate, 'plate_info', id='1')
    ET.SubElement(plate, 'layer', top_z=str(info['pause_z']), type='1', extruder='1',
                  color='', extra='Insert one 25 x 2 mm steel disc flat in the open pocket', gcode='PAUSE')
    ET.SubElement(plate, 'mode', value='SingleExtruder')
    return ET.tostring(root, encoding='utf-8', xml_declaration=True)


def verify(job, project):
    # Flash Studio retains native pause XML but drops unknown metadata files
    # when exporting a sliced archive. Read measured pocket data from its
    # editable companion, then check the actual sliced settings and G-code.
    with zipfile.ZipFile(project) as z:
        info = json.loads(z.read('Metadata/pumpkin_disc.json'))
    with zipfile.ZipFile(job) as z:
        if z.testzip() is not None:
            raise ValueError('Corrupt sliced archive')
        settings = json.loads(z.read('Metadata/project_settings.config'))
        text = z.read('Metadata/plate_1.gcode').decode()
        xml = ET.fromstring(z.read('Metadata/custom_gcode_per_layer.xml'))
    assert settings['filament_settings_id'] == ['Flashforge PETG Pro']
    assert str(settings['support_on_build_plate_only']) == '1'
    assert str(settings['independent_support_layer_height']) == '0'
    markers = xml.findall('./plate/layer')
    assert len(markers) == 1 and markers[0].get('gcode') == 'PAUSE'
    assert abs(float(markers[0].get('top_z'))-info['pause_z']) < .001
    assert re.findall(r'^(?:PAUSE|M25|M600|M601)(?:[ \t].*)?$', text, re.M) == ['PAUSE']
    blocks = text.split(';LAYER_CHANGE')[1:]
    pause_index = next(i for i, b in enumerate(blocks) if '\nPAUSE\n' in b)
    assert pause_index == info['layer_index']
    z_of = lambda b: float(re.search(r'^;Z:([\d.]+)', b, re.M)[1])
    assert abs(z_of(blocks[pause_index])-info['pause_z']) < .001
    previous_z = z_of(blocks[pause_index-1])
    assert info['cavity_z'][0]+info['disc_t'] < previous_z
    x = y = e = layer_z = 0.0
    relative = paused = False
    role = ''
    roof_moves = {z: [] for z in info['cover_z']}
    radius = info['disc_d']/2-.3
    for line in text.splitlines():
        if line.startswith((';TYPE:', '; FEATURE:')):
            role = line.split(':', 1)[1].strip()
        if line.startswith(';Z:'):
            layer_z = float(line[3:])
        if line == 'PAUSE':
            paused = True
        command = line.split(';')[0].strip()
        if command == 'M83': relative = True
        if command == 'M82': relative = False
        if command.startswith('G92 E'): e = float(command[5:])
        if not re.match(r'^G[01] ', command): continue
        values = {k: float(v) for k, v in re.findall(r'([XYE])(-?[\d.]+)', command)}
        nx, ny = values.get('X', x), values.get('Y', y)
        extrusion = values.get('E', 0) if relative else values.get('E', e)-e
        if 'E' in values: e = values['E'] if not relative else e+values['E']
        if extrusion > 0 and (nx, ny) != (x, y):
            dx, dy = nx-x, ny-y
            cx, cy = info['center']
            fraction = max(0, min(1, ((cx-x)*dx+(cy-y)*dy)/(dx*dx+dy*dy)))
            distance = math.hypot(x+fraction*dx-cx, y+fraction*dy-cy)
            if distance < radius and layer_z > info['cavity_z'][0]+.01:
                if not paused:
                    raise ValueError(f'Pocket filled before pause at Z {layer_z}')
                if 'support' in role.lower() and layer_z < info['cavity_z'][1]+.2:
                    raise ValueError('Support inside steel pocket')
                if layer_z in roof_moves:
                    roof_moves[layer_z].append(((x, y), (nx, ny)))
        x, y = nx, ny
    # Verify coverage of both layers, rather than accepting one crossing line.
    from shapely.geometry import LineString, Point
    from shapely.ops import unary_union
    disc = Point(*info['center']).buffer(radius, quad_segs=96)
    for z, lines in roof_moves.items():
        paths = unary_union([LineString(line).buffer(.25) for line in lines])
        uncovered = disc.difference(paths).area
        if uncovered > 1:
            raise ValueError(f'Disc cover incomplete at Z {z}: {uncovered:.3f} mm2')
        print(f'Cover Z {z:.2f}: {len(lines)} extrusion moves, uncovered area {uncovered:.3f} mm2')
    print(f'VERIFIED: exactly one native PAUSE before model layer {pause_index+1}, '
          f'Z {info["pause_z"]:.2f}; previous layer {previous_z:.2f}; '
          f'disc top {info["cavity_z"][0]+info["disc_t"]:.2f}; two complete cover layers; pocket open until pause')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('job', type=Path, help='Sliced 3MF')
    parser.add_argument('--project', required=True, type=Path, help='Editable companion with measured disc metadata')
    args = parser.parse_args()
    verify(args.job, args.project)
