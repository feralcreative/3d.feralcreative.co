#!/usr/bin/env python3
"""Prepare a Gridfinity STL as a positioned 3MF with a native magnet pause.

Reject old/open-pocket meshes. Pre-render thumbnails on the CPU because Flash
Studio's CLI requests an invalid OpenGL 3.4 context when creating its own.
The resulting project still needs utils/slice.sh; no G-code is patched here.
Usage: python3 utils/magnet-project.py part.stl /tmp/part.3mf --settings resolved.json
"""

import argparse
import io
import json
import math
import re
import struct
import zipfile
from collections import Counter, defaultdict
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw


def mesh(path):
    data = path.read_bytes()
    count = struct.unpack_from('<I', data, 80)[0]
    if len(data) != 84 + count * 50:
        raise ValueError('Expected binary STL')
    vertices, indices, faces = [], {}, []
    for i in range(count):
        face = []
        for j in range(3):
            point = struct.unpack_from('<3f', data, 84 + i * 50 + 12 + j * 12)
            if point not in indices:
                indices[point] = len(vertices)
                vertices.append(point)
            face.append(indices[point])
        if len(set(face)) != 3:
            raise ValueError('Collapsed triangle')
        faces.append(face)
    edges, adjacent = Counter(), defaultdict(set)
    for a, b, c in faces:
        for u, v in ((a, b), (b, c), (c, a)):
            edges[tuple(sorted((u, v)))] += 1
            adjacent[u].add(v)
            adjacent[v].add(u)
    if any(n != 2 for n in edges.values()):
        raise ValueError('Non-manifold mesh')
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
    lo = [min(v[d] for v in vertices) for d in range(3)]
    hi = [max(v[d] for v in vertices) for d in range(3)]
    cavities = []
    for group, volume in zip(groups, volumes):
        if volume >= 0:
            continue
        g = [vertices[i] for i in group]
        low = [min(v[d] for v in g) for d in range(3)]
        high = [max(v[d] for v in g) for d in range(3)]
        dims = [high[d]-low[d] for d in range(3)]
        if not (abs(low[2]-lo[2]-.4) < .001 and
                abs(high[2]-lo[2]-2.6) < .001 and
                all(abs(d-10.5) < .03 for d in dims[:2])):
            raise ValueError(f'Unexpected enclosed void: {low}, {high}')
        cavities.append([(low[d]+high[d])/2 for d in range(3)])
    if not cavities or sum(v > 0 for v in volumes) != 1:
        raise ValueError('Expected one solid with enclosed magnet cavities')
    shift = [-(lo[0]+hi[0])/2, -(lo[1]+hi[1])/2, -lo[2]]
    vertices = [tuple(v[d]+shift[d] for d in range(3)) for v in vertices]
    cavities = [tuple(v[d]+shift[d] for d in range(3)) for v in cavities]
    return vertices, faces, cavities


def thumbnail(vertices, faces, top=False):
    # Orthographic painter's projection; uses the actual mesh, no GPU context.
    center = [(min(v[d] for v in vertices)+max(v[d] for v in vertices))/2
              for d in range(3)]
    def project(v):
        x, y, z = [v[d]-center[d] for d in range(3)]
        return (x, -y, z) if top else ((x-y)/math.sqrt(2),
            (x+y)/math.sqrt(6)-z*math.sqrt(2/3), (x+y+z)/math.sqrt(3))
    points = [project(v) for v in vertices]
    extent = max(max(p[d] for p in points)-min(p[d] for p in points)
                 for d in range(2))
    scale = 440/extent
    image = Image.new('RGBA', (512, 512), (245, 245, 245, 255))
    draw = ImageDraw.Draw(image)
    for face in sorted(faces, key=lambda f: sum(points[i][2] for i in f)):
        a, b, c = [vertices[i] for i in face]
        u, v = [b[d]-a[d] for d in range(3)], [c[d]-a[d] for d in range(3)]
        normal = [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]
        norm = math.sqrt(sum(x*x for x in normal)) or 1
        shade = .55 + .45*abs(sum(normal[d]*[.3,-.4,.866][d] for d in range(3))/norm)
        color = tuple(int(x*shade) for x in (218, 35, 136)) + (255,)
        draw.polygon([(256+points[i][0]*scale,256+points[i][1]*scale)
                      for i in face], fill=color)
    out = io.BytesIO()
    image.save(out, format='PNG')
    return out.getvalue()


def write_project(source, output, settings):
    profile = json.loads(settings.read_text())
    if profile['printable_area'] != ['-110x-110','110x-110','110x110','-110x110']:
        raise ValueError('Expected the AD5M Pro centered 220 mm bed')
    if profile.get('machine_pause_gcode', '').strip() != 'PAUSE':
        raise ValueError('Expected the AD5M Pro native PAUSE command')
    if (float(profile['initial_layer_print_height']) != .3 or
            float(profile['layer_height']) != .12 or
            str(profile['enable_support']) != '0' or
            int(profile['raft_layers']) != 0):
        raise ValueError('Pause validated only for 0.30 first / 0.12 mm layers, no support or raft')
    vertices, faces, cavities = mesh(source)
    ns = 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'
    model = ET.Element('model', unit='millimeter', xmlns=ns)
    ET.SubElement(model, 'metadata', name='Application').text = 'BambuStudio-2.3.2'
    ET.SubElement(model, 'metadata', name='BambuStudio:3mfVersion').text = '1'
    obj = ET.SubElement(ET.SubElement(model, 'resources'), 'object', id='1', type='model')
    geometry = ET.SubElement(obj, 'mesh')
    verts = ET.SubElement(geometry, 'vertices')
    for v in vertices:
        ET.SubElement(verts, 'vertex', **dict(zip(('x','y','z'),map(str,v))))
    tris = ET.SubElement(geometry, 'triangles')
    for f in faces:
        ET.SubElement(tris, 'triangle', **dict(zip(('v1','v2','v3'),map(str,f))))
    ET.SubElement(ET.SubElement(model, 'build'), 'item', objectid='1')
    config = ET.Element('config')
    obj = ET.SubElement(config, 'object', id='1')
    ET.SubElement(obj, 'metadata', key='name', value=source.stem)
    ET.SubElement(obj, 'metadata', key='extruder', value='1')
    part = ET.SubElement(obj, 'part', id='1', subtype='normal_part')
    ET.SubElement(part, 'metadata', key='name', value=source.stem)
    plate = ET.SubElement(config, 'plate')
    images = {'thumbnail_file':'Metadata/plate_1.png',
              'thumbnail_no_light_file':'Metadata/plate_no_light_1.png',
              'top_file':'Metadata/top_1.png', 'pick_file':'Metadata/pick_1.png'}
    for k,v in {'plater_id':'1', 'plater_name':source.stem, 'locked':'false', **images}.items():
        ET.SubElement(plate, 'metadata', key=k, value=v)
    instance = ET.SubElement(plate, 'model_instance')
    for k,v in {'object_id':'1','instance_id':'0','identify_id':'1'}.items():
        ET.SubElement(instance, 'metadata', key=k, value=v)
    pauses = ET.Element('custom_gcodes_per_layer')
    plate = ET.SubElement(pauses, 'plate')
    ET.SubElement(plate, 'plate_info', id='1')
    ET.SubElement(plate, 'layer', top_z='2.7', type='1', extruder='1', color='',
                  extra=f'Insert {len(cavities)} 10x2 mm magnets; check polarity', gcode='PAUSE')
    ET.SubElement(plate, 'mode', value='SingleExtruder')
    iso, top = thumbnail(vertices,faces), thumbnail(vertices,faces,True)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('Metadata/project_settings.config', json.dumps(profile))
        z.writestr('[Content_Types].xml', '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/><Default Extension="png" ContentType="image/png"/></Types>')
        z.writestr('_rels/.rels','<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        for name, tree in [('3D/3dmodel.model',model), ('Metadata/model_settings.config',config),
                           ('Metadata/custom_gcode_per_layer.xml',pauses)]:
            z.writestr(name,ET.tostring(tree,encoding='utf-8',xml_declaration=True))
        for key,path in images.items():
            z.writestr(path, top if key in ('top_file','pick_file') else iso)
    print(f'{source.stem}: {len(cavities)} cavities, Z 0.40–2.60; pause before layer Z 2.70 -> {output}')


def verify_job(source, job):
    """Read the shipped archive and check open cavities before the actual pause."""
    _, _, cavities = mesh(source)
    with zipfile.ZipFile(job) as archive:
        if archive.testzip() is not None:
            raise ValueError('Corrupt 3MF')
        text = archive.read('Metadata/plate_1.gcode').decode()
        xml = ET.fromstring(archive.read('Metadata/custom_gcode_per_layer.xml'))
        markers = xml.findall('./plate/layer')
        if len(markers) != 1 or markers[0].get('type') != '1' or abs(float(markers[0].get('top_z'))-2.7) > .001:
            raise ValueError('Missing or wrong native pause marker')
    pause_lines = re.findall(r'^(?:PAUSE|M25|M600|M601)(?:[ \t].*)?$', text, re.M)
    if pause_lines != ['PAUSE']:
        raise ValueError(f'Expected exactly one PAUSE: {pause_lines}')
    blocks = text.split(';LAYER_CHANGE')[1:]
    pause_block = next(i for i,b in enumerate(blocks) if '\nPAUSE\n' in b)
    z_of = lambda b: float(re.search(r'^;Z:([\d.]+)', b, re.M)[1])
    if pause_block != 20 or abs(z_of(blocks[19])-2.58) > .001 or abs(z_of(blocks[20])-2.7) > .001:
        raise ValueError('Pause moved away from the validated layer boundary')
    x = y = e = 0.0
    relative_e = False
    layer_z = 0.0
    paused = False
    bridged = set()
    bounds = [math.inf, math.inf, -math.inf, -math.inf]
    for line in text.splitlines():
        if line.startswith(';Z:'):
            layer_z = float(line[3:])
        if line == 'PAUSE':
            paused = True
        command = line.split(';')[0].strip()
        if command == 'M83': relative_e = True
        if command == 'M82': relative_e = False
        if command.startswith('G92 E'): e = float(command[5:])
        if not re.match(r'^G[01] ', command):
            continue
        values = {k:float(v) for k,v in re.findall(r'([XYE])(-?[\d.]+)',command)}
        nx, ny = values.get('X',x), values.get('Y',y)
        extrusion = values.get('E',0) if relative_e else values.get('E',e)-e
        if 'E' in values:
            e = e+values['E'] if relative_e else values['E']
        if extrusion > 0 and (nx,ny) != (x,y):
            bounds = [min(bounds[0],x,nx),min(bounds[1],y,ny),max(bounds[2],x,nx),max(bounds[3],y,ny)]
            if .53 < layer_z < 2.71:
                for i,(cx,cy,_) in enumerate(cavities):
                    dx,dy = nx-x,ny-y
                    t = max(0,min(1,((cx-x)*dx+(cy-y)*dy)/(dx*dx+dy*dy)))
                    distance = math.hypot(x+t*dx-cx,y+t*dy-cy)
                    if distance < 4.95 and not paused:
                        raise ValueError(f'Extrusion in magnet opening {i+1} before pause at Z {layer_z}')
                    if distance < 2.5 and abs(layer_z-2.7)<.001 and paused:
                        bridged.add(i)
        x,y = nx,ny
    if len(bridged) != len(cavities):
        raise ValueError(f'Expected roofs after pause over {len(cavities)} magnets, found {len(bridged)}')
    if min(bounds[:2]) < -110 or max(bounds[2:]) > 110:
        raise ValueError(f'Extrusion outside bed: {bounds}')
    print(f'VERIFIED {job.name}: {len(cavities)} open cavities; one pause before layer 21; all roofs after pause; extrusion bounds {bounds}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stl',type=Path)
    parser.add_argument('output',type=Path)
    parser.add_argument('--settings',type=Path)
    parser.add_argument('--verify',action='store_true',help='verify output as a sliced job instead of creating a project')
    args = parser.parse_args()
    if args.verify:
        verify_job(args.stl,args.output)
    elif args.settings:
        write_project(args.stl,args.output,args.settings)
    else:
        parser.error('--settings is required when creating a project')
