#!/usr/bin/env python3
"""Keep fence-pumpkin print plates reproducible after a rebuild.

Write an editable Flash Studio project using the existing CPU-thumbnail/STL
helpers. Paint only the flat inside lid underside as a support enforcer and
attach a blocker protecting the internal steel-disc pocket. --door adds the
door in its support-free print orientation. No print geometry or shared printer
presets are changed by this project writer. Use a Python with Pillow.
With --cap, arrange the open body, face-down door and flat-bottomed cap with
supports disabled unless --rim-supports paints the sculpted rim. Current jobs
use --rim-supports with the Pumpkin Rim Supports process and PETG Pro filament.
The green stem remains a separate print.
--plate-only retains the fused roof and tests trees routed through the rear
door from the build plate. It does not establish that those trees can be removed.
"""

import argparse
import importlib.util
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET
import zipfile


def helpers():
    spec = importlib.util.spec_from_file_location(
        'project_helpers', Path(__file__).with_name('magnet-project.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def cylinder(radius, bottom, height, centre, facets=96):
    vertices = [(centre[0] + radius * math.cos(2 * math.pi * i / facets),
                 centre[1] + radius * math.sin(2 * math.pi * i / facets), z)
                for z in (bottom, bottom + height) for i in range(facets)]
    faces = []
    for i in range(facets):
        j = (i + 1) % facets
        faces += [(i, j, i + facets), (j, j + facets, i + facets)]
    for i in range(1, facets - 1):
        faces += [(0, i + 1, i), (facets, facets + i, facets + i + 1)]
    return vertices, faces


def roof_face(vertices, face):
    points = [vertices[i] for i in face]
    if any(abs(p[2] - 29.04747) > 0.001 for p in points):
        return False
    a, b, c = points
    return ((b[0] - a[0]) * (c[1] - a[1]) -
            (b[1] - a[1]) * (c[0] - a[0])) < 0


def rim_face(vertices, face):
    points = [vertices[i] for i in face]
    if min(p[2] for p in points) < 29 or max(p[2] for p in points) > 32.2:
        return False
    # Three inward rim tips start as isolated slices. Paint only their local
    # undersides, rather than generating a tree beneath the whole rim.
    x, y = (sum(p[d] for p in points) / 3 for d in (0, 1))
    windows = [(-5, 4, -20, -14), (13.5, 18, 19.2, 20.2), (-9, -5, 18.5, 20.2)]
    if not any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in windows):
        return False
    a, b, c = points
    return ((b[0] - a[0]) * (c[1] - a[1]) -
            (b[1] - a[1]) * (c[0] - a[0])) < -1e-8


def write_project(source, settings, output, door=None, cap=None, profiles=None, rim_supports=False, plate_only=False, disc_pause=False):
    util = helpers()
    vertices, faces = util.read_stl(source)
    painted = [(rim_face if rim_supports else roof_face)(vertices, f) for f in faces]
    if plate_only:
        if cap or rim_supports:
            raise ValueError('--plate-only is a fused-roof trial; omit --cap and --rim-supports')
        painted = [roof_face(vertices, f) or rim_face(vertices, f) for f in faces]
    if not cap and not any(painted):
        raise ValueError('No flat interior lid underside; use --cap for the open-body design')
    profile = json.loads(settings.read_text())
    embedded = {}
    if cap or plate_only:
        if profile.get('filament_settings_id') != ['Flashforge PETG Pro']:
            raise ValueError('The current pumpkin plate requires Flashforge PETG Pro resolved settings')
        if profiles is None:
            raise ValueError('Use --profiles with the resolved machine/process/filament JSON directory so GUI import retains the presets')
    if profiles:
        for kind, prefix in [('machine', 'machine'), ('process', 'process'), ('filament', 'filament')]:
            preset = json.loads((profiles / f'{kind}.json').read_text())
            preset['from'] = 'project'
            if kind == 'machine':
                preset['printer_settings_id'] = preset['name']
            if kind == 'process' and cap and not rim_supports:
                preset['enable_support'] = '0'
            embedded[f'Metadata/{prefix}_settings_1.config'] = preset
        filament = embedded['Metadata/filament_settings_1.config']
        if profile.get('filament_settings_id') != [filament['name']]:
            raise ValueError('Embedded filament preset does not match the resolved print settings')
    if profile['printable_area'] != ['-110x-110', '110x-110', '110x110', '-110x110']:
        raise ValueError('Expected the centered AD5M Pro 220 mm bed')
    if cap:
        if rim_supports:
            if not any(painted):
                raise ValueError('No downward rim faces were found to enforce support')
            if str(profile['enable_support']) != '1' or profile['support_type'] != 'tree(manual)':
                raise ValueError('Rim supports require the resolved Pumpkin Rim Supports process preset')
        elif any(painted):
            raise ValueError('Body still has its roof; rebuild the open body before adding --cap')
        else:
            profile.update(enable_support='0')
    else:
        if plate_only:
            if str(profile['support_on_build_plate_only']) != '1':
                raise ValueError('Plate-only trial requires a plate-only process preset')
        else:
            profile.update(enable_support='1', support_type='tree(manual)',
                           support_style='tree_slim', support_on_build_plate_only='0')
    # Block the pocket and a little space above it so tree bases cannot fill it.
    blocker_vertices, blocker_faces = cylinder(13.3, -26.94, 8.0, (0, 2))
    lo = [min(v[d] for v in vertices) for d in range(3)]
    hi = [max(v[d] for v in vertices) for d in range(3)]
    body_x = -32.5 if door or cap else 0
    shift = [body_x - (lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2]]
    disc_info = disc_marker = None
    if disc_pause:
        if not plate_only:
            raise ValueError('Disc-pause trial requires --plate-only')
        spec = importlib.util.spec_from_file_location('disc_pause', Path(__file__).with_name('pumpkin-disc-pause.py'))
        disc = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(disc)
        disc_info = disc.measure(vertices, faces, profile, shift)
        disc_marker = disc.marker(disc_info)
    move = lambda vs: [tuple(v[d] + shift[d] for d in range(3)) for v in vs]
    vertices, blocker_vertices = move(vertices), move(blocker_vertices)
    model = ET.Element('model', unit='millimeter',
                       xmlns='http://schemas.microsoft.com/3dmanufacturing/core/2015/02')
    ET.SubElement(model, 'metadata', name='Application').text = 'BambuStudio-2.3.2'
    ET.SubElement(model, 'metadata', name='BambuStudio:3mfVersion').text = '1'
    resources = ET.SubElement(model, 'resources')
    pieces = [(1, vertices, faces)]
    if not cap or rim_supports:
        pieces.append((2, blocker_vertices, blocker_faces))
    if door:
        door_vertices, door_faces = util.read_stl(door)
        # Same orientation as show="print-door": rotate +90 degrees about X,
        # inner face on the bed. Place it to the right, clear of the support tree.
        door_vertices = [(x, -z, y - 20.2) for x, y, z in door_vertices]
        door_y = (min(v[1] for v in door_vertices) + max(v[1] for v in door_vertices)) / 2
        door_vertices = [(x + 55, y - door_y - (32 if cap else 0), z) for x, y, z in door_vertices]
        if abs(min(v[2] for v in door_vertices)) > 0.001:
            raise ValueError('Door inner face is not Y=20.2; review its print orientation')
        pieces.append((4, door_vertices, door_faces))
    if cap:
        cap_vertices, cap_faces = util.read_stl(cap)
        cap_vertices = [(x + 55, y + 38, z - 29.04747) for x, y, z in cap_vertices]
        if abs(min(v[2] for v in cap_vertices)) > 0.001:
            raise ValueError('Cap underside is not Z=29.04747; review its print orientation')
        pieces.append((5, cap_vertices, cap_faces))
    for number, vs, _ in pieces:
        if number == 2:
            continue
        if any(abs(v[d]) > 105 for v in vs for d in (0, 1)):
            raise ValueError('Printed piece exceeds the centered 210 mm safe bed area')
    for number, vs, fs in pieces:
        obj = ET.SubElement(resources, 'object', id=str(number), type='model')
        geometry = ET.SubElement(obj, 'mesh')
        verts = ET.SubElement(geometry, 'vertices')
        for v in vs:
            ET.SubElement(verts, 'vertex', **dict(zip(('x', 'y', 'z'), map(str, v))))
        triangles = ET.SubElement(geometry, 'triangles')
        for i, f in enumerate(fs):
            attrs = dict(zip(('v1', 'v2', 'v3'), map(str, f)))
            if number == 1 and painted[i]:
                # Orca/Bambu's unsplit triangle: two zero split bits followed
                # by state 1 (enforcer), serialized as one hexadecimal nibble.
                attrs['paint_supports'] = '4'
            ET.SubElement(triangles, 'triangle', **attrs)
    assembly = ET.SubElement(resources, 'object', id='3', type='model')
    components = ET.SubElement(assembly, 'components')
    for number in ([1] if cap and not rim_supports else [1, 2]):
        ET.SubElement(components, 'component', objectid=str(number))
    build = ET.SubElement(model, 'build')
    ET.SubElement(build, 'item', objectid='3')
    if door:
        ET.SubElement(build, 'item', objectid='4')
    if cap:
        ET.SubElement(build, 'item', objectid='5')
    config = ET.Element('config')
    obj = ET.SubElement(config, 'object', id='3')
    for key, value in [('name', source.stem), ('extruder', '1')]:
        ET.SubElement(obj, 'metadata', key=key, value=value)
    body_parts = [(1, 'normal_part', source.stem)]
    if not cap or rim_supports:
        body_parts.append((2, 'support_blocker', 'Protect internal steel-disc pocket'))
    for number, subtype, name in body_parts:
        part = ET.SubElement(obj, 'part', id=str(number), subtype=subtype)
        ET.SubElement(part, 'metadata', key='name', value=name)
    if door:
        obj = ET.SubElement(config, 'object', id='4')
        for key, value in [('name', door.stem), ('extruder', '1'), ('enable_support', '0')]:
            ET.SubElement(obj, 'metadata', key=key, value=value)
        part = ET.SubElement(obj, 'part', id='4', subtype='normal_part')
        ET.SubElement(part, 'metadata', key='name', value=door.stem)
    if cap:
        obj = ET.SubElement(config, 'object', id='5')
        for key, value in [('name', cap.stem), ('extruder', '1'), ('enable_support', '0')]:
            ET.SubElement(obj, 'metadata', key=key, value=value)
        part = ET.SubElement(obj, 'part', id='5', subtype='normal_part')
        ET.SubElement(part, 'metadata', key='name', value=cap.stem)
        ET.SubElement(config.find('object'), 'metadata', key='enable_support', value='1' if rim_supports else '0')
    images = {'thumbnail_file': 'Metadata/plate_1.png',
              'thumbnail_no_light_file': 'Metadata/plate_no_light_1.png',
              'top_file': 'Metadata/top_1.png', 'pick_file': 'Metadata/pick_1.png'}
    plate = ET.SubElement(config, 'plate')
    for key, value in dict(plater_id='1', plater_name=output.stem,
                           locked='false', **images).items():
        ET.SubElement(plate, 'metadata', key=key, value=value)
    object_ids = [3] + ([4] if door else []) + ([5] if cap else [])
    for i, object_id in enumerate(object_ids, 1):
        instance = ET.SubElement(plate, 'model_instance')
        for key, value in [('object_id', str(object_id)), ('instance_id', '0'), ('identify_id', str(i))]:
            ET.SubElement(instance, 'metadata', key=key, value=value)
    shown_vertices, shown_faces = list(vertices), list(faces)
    if door:
        shown_faces += [tuple(i + len(vertices) for i in f) for f in door_faces]
        shown_vertices += door_vertices
    if cap:
        shown_faces += [tuple(i + len(shown_vertices) for i in f) for f in cap_faces]
        shown_vertices += cap_vertices
    iso = util.thumbnail(shown_vertices, shown_faces)
    top = util.thumbnail(shown_vertices, shown_faces, True)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.writestr('Metadata/project_settings.config', json.dumps(profile))
        if disc_pause:
            archive.writestr('Metadata/custom_gcode_per_layer.xml', disc_marker)
            archive.writestr('Metadata/pumpkin_disc.json', json.dumps(disc_info))
        for path, preset in embedded.items():
            archive.writestr(path, json.dumps(preset))
        archive.writestr('[Content_Types].xml', '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/><Default Extension="png" ContentType="image/png"/></Types>')
        archive.writestr('_rels/.rels', '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        for name, tree in [('3D/3dmodel.model', model), ('Metadata/model_settings.config', config)]:
            archive.writestr(name, ET.tostring(tree, encoding='utf-8', xml_declaration=True))
        for key, path in images.items():
            archive.writestr(path, top if key in ('top_file', 'pick_file') else iso)
    print(f'{str(sum(painted)) + " rim triangles painted; separate cap" if rim_supports else "Supports disabled; separate cap" if cap else str(sum(painted)) + " roof triangles painted; pocket blocker"}; upright'
          f'{" + door face down" if door else ""}; {output}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stl', type=Path)
    parser.add_argument('settings', type=Path, help='Fully resolved Flash Studio settings JSON')
    parser.add_argument('output', type=Path)
    parser.add_argument('--door', type=Path, help='Door STL in its assembled/source coordinates')
    parser.add_argument('--cap', type=Path, help='Separate cap STL; disable all supports')
    parser.add_argument('--profiles', type=Path, help='Resolved machine.json/process.json/filament.json directory to embed for GUI import')
    parser.add_argument('--rim-supports', action='store_true', help='Paint only downward upper-rim faces; use the Pumpkin Rim Supports process')
    parser.add_argument('--plate-only', action='store_true', help='Fused-roof trial: paint roof and rim; require plate-only supports in the process preset')
    parser.add_argument('--disc-pause', action='store_true', help='Measure the sealed steel pocket and add its native insert pause')
    args = parser.parse_args()
    write_project(args.stl, args.settings, args.output, args.door, args.cap, args.profiles, args.rim_supports, args.plate_only, args.disc_pause)
