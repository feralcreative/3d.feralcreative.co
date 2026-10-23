#!/usr/bin/env python3
"""Prepare a closed pumpkin door upright on its flat underside.

Preserve the provided project's flattened machine/filament settings and ordinary
infill;
disable removable supports. This writes an editable project only and sends
nothing to the printer.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import zipfile


def load_helper(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mesh', type=Path, required=True)
    parser.add_argument('--settings', type=Path, required=True)
    parser.add_argument('--process', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    util = load_helper('project_helpers', 'magnet-project.py')
    profiles = load_helper('profile_helpers', 'ffprofile.py')
    process, _ = profiles.resolve(str(args.process), 'process', profiles.BUNDLE)
    settings = json.loads(args.settings.read_text())
    if process['enable_support'] != '0':
        raise ValueError('Closed door project must disable removable supports')
    settings.update(enable_support='0', print_settings_id=process['name'])
    process['from'] = 'project'
    model = ET.Element('model', unit='millimeter', xmlns='http://schemas.microsoft.com/3dmanufacturing/core/2015/02')
    ET.SubElement(model, 'metadata', name='Application').text = 'BambuStudio-2.4.2'
    ET.SubElement(model, 'metadata', name='BambuStudio:3mfVersion').text = '1'
    resources, build, config = ET.SubElement(model, 'resources'), ET.SubElement(model, 'build'), ET.Element('config')
    combined_vertices, combined_faces = [], []
    for number, (path, centre_x) in enumerate([(args.mesh, 0)], 1):
        vertices, faces = util.read_stl(path)
        lo = [min(v[d] for v in vertices) for d in range(3)]
        hi = [max(v[d] for v in vertices) for d in range(3)]
        if abs(lo[2]) > .001:
            raise ValueError(f'{path.name} does not have its flat face on Z=0')
        shift = [centre_x - (lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2]]
        vertices = [tuple(v[d] + shift[d] for d in range(3)) for v in vertices]
        if any(abs(v[d]) > 105 for v in vertices for d in (0, 1)):
            raise ValueError('Part exceeds the centered 210 mm safe plate area')
        obj = ET.SubElement(resources, 'object', id=str(number), type='model')
        mesh = ET.SubElement(obj, 'mesh')
        vs, fs = ET.SubElement(mesh, 'vertices'), ET.SubElement(mesh, 'triangles')
        for v in vertices:
            ET.SubElement(vs, 'vertex', **dict(zip(('x', 'y', 'z'), map(str, v))))
        for f in faces:
            ET.SubElement(fs, 'triangle', **dict(zip(('v1', 'v2', 'v3'), map(str, f))))
        ET.SubElement(build, 'item', objectid=str(number))
        obj = ET.SubElement(config, 'object', id=str(number))
        for key, value in [('name', path.stem), ('extruder', '1'), ('enable_support', '0')]:
            ET.SubElement(obj, 'metadata', key=key, value=value)
        part = ET.SubElement(obj, 'part', id=str(number), subtype='normal_part')
        ET.SubElement(part, 'metadata', key='name', value=path.stem)
        offset = len(combined_vertices)
        combined_vertices.extend(vertices)
        combined_faces.extend(tuple(i + offset for i in face) for face in faces)
    plate = ET.SubElement(config, 'plate')
    images = {'thumbnail_file': 'Metadata/plate_1.png', 'thumbnail_no_light_file': 'Metadata/plate_no_light_1.png',
              'top_file': 'Metadata/top_1.png', 'pick_file': 'Metadata/pick_1.png'}
    for key, value in {'plater_id': '1', 'plater_name': args.output.stem, 'locked': 'false', **images}.items():
        ET.SubElement(plate, 'metadata', key=key, value=value)
    for number in [1]:
        instance = ET.SubElement(plate, 'model_instance')
        for key, value in [('object_id', str(number)), ('instance_id', '0'), ('identify_id', str(number))]:
            ET.SubElement(instance, 'metadata', key=key, value=value)
    iso, top = util.thumbnail(combined_vertices, combined_faces), util.thumbnail(combined_vertices, combined_faces, True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(args.output, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml', '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/><Default Extension="png" ContentType="image/png"/></Types>')
        z.writestr('_rels/.rels', '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        for name, tree in [('3D/3dmodel.model', model), ('Metadata/model_settings.config', config)]:
            z.writestr(name, ET.tostring(tree, encoding='utf-8', xml_declaration=True))
        z.writestr('Metadata/project_settings.config', json.dumps(settings, indent=2))
        z.writestr('Metadata/process_settings_1.config', json.dumps(process, indent=2))
        for key, name in images.items():
            z.writestr(name, top if key in ('top_file', 'pick_file') else iso)
    print(f'Closed upright door: one piece, support disabled, {settings["sparse_infill_density"]} {settings["sparse_infill_pattern"]} infill -> {args.output}')


if __name__ == '__main__':
    main()
