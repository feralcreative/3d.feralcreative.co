#!/usr/bin/env python3
"""Prepare a Gridfinity STL as a positioned 3MF with a native magnet pause.

Reject old/open-pocket meshes. Pre-render thumbnails on the CPU because Flash
Studio's CLI requests an invalid OpenGL 3.4 context when creating its own.
The cavity height is read from the mesh, so a part printed upside down, with
its cavities well off the bed, pauses at its own height; every cavity must
share one Z range, and neither end may sit on a layer middle. Layer heights
come from the process profile (the job's own settings when verifying).
The resulting project still needs utils/slice.sh; no G-code is patched here.

--with adds further pieces to the same plate as separate objects, and
--enforcer (repeatable) attaches a support-enforcer volume to whichever piece
its footprint centre falls on. All STLs must
share one coordinate frame (export them from the same layout); they are moved
together. Supports are allowed only with an enforcer and a "(manual)" support
type, so the slicer puts them inside the enforcer and never in a magnet cavity,
and the verification fails if any support extrusion reaches a cavity.
Usage: python3 utils/magnet-project.py part.stl /tmp/part.3mf --settings resolved.json
       [--with other.stl ...] [--enforcer groove.stl ...]
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


def read_stl(path):
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
    return vertices, faces


def mesh(path, cavities_required=True):
    """Vertices, faces, cavity centres, and cavity Z span, in the file's frame."""
    vertices, faces = read_stl(path)
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
    cavities, spans = [], set()
    for group, volume in zip(groups, volumes):
        if volume >= 0:
            continue
        g = [vertices[i] for i in group]
        low = [min(v[d] for v in g) for d in range(3)]
        high = [max(v[d] for v in g) for d in range(3)]
        dims = [high[d]-low[d] for d in range(3)]
        if not (all(abs(d-10.5) < .03 for d in dims[:2]) and 2.1 < dims[2] < 2.3):
            raise ValueError(f'Unexpected enclosed void: {low}, {high}')
        spans.add((round(low[2]-lo[2], 3), round(high[2]-lo[2], 3)))
        cavities.append([(low[d]+high[d])/2 for d in range(3)])
    if sum(v > 0 for v in volumes) != 1:
        raise ValueError(f'Expected one solid in {path.name}')
    if not cavities_required:
        if cavities:
            raise ValueError(f'{path.name} has magnet cavities; only the first STL may')
        return vertices, faces, [], None
    if not cavities:
        raise ValueError('Expected one solid with enclosed magnet cavities')
    if len(spans) != 1:
        raise ValueError(f'Cavities at different heights: {sorted(spans)}')
    return vertices, faces, cavities, spans.pop()


def layout(source, extras=(), enforcers=()):
    """Load every piece and centre them together on the bed, floor at Z=0."""
    vertices, faces, cavities, span = mesh(source)
    pieces = [(source, vertices, faces)] + [(p, *mesh(p, False)[:2]) for p in extras]
    for enforcer in enforcers:
        pieces.append((enforcer, *read_stl(enforcer)))
    every = [v for _, vs, _ in pieces[:1 + len(extras)] for v in vs]
    lo = [min(v[d] for v in every) for d in range(3)]
    hi = [max(v[d] for v in every) for d in range(3)]
    for p, vs, _ in pieces[1:1 + len(extras)]:
        if abs(min(v[2] for v in vs) - lo[2]) > .001:
            raise ValueError(f'{p.name} does not stand on the bed')
    shift = [-(lo[0]+hi[0])/2, -(lo[1]+hi[1])/2, -lo[2]]
    move = lambda vs: [tuple(v[d]+shift[d] for d in range(3)) for v in vs]
    pieces = [(p, move(vs), fs) for p, vs, fs in pieces]
    # The magnet cavities' span is measured from the magnet part's own floor.
    if abs(min(v[2] for v in pieces[0][1])) > .001:
        raise ValueError(f'{source.name} does not stand on the bed')
    return pieces, move(cavities), span


FIRST, LAYER = .3, .12


def use_layers(profile):
    global FIRST, LAYER
    FIRST = float(profile['initial_layer_print_height'])
    LAYER = float(profile['layer_height'])


def layer_top(i):
    return FIRST + LAYER * i


def layer_mid(i):
    return layer_top(i) - (LAYER if i else FIRST) / 2


def pause_layer(span):
    """Index of the first layer whose middle is above the cavity top."""
    for z in span:
        # A cavity face at a layer's middle is a coin toss for the slicer.
        if min(abs(z - layer_mid(i)) for i in range(400)) < .03:
            raise ValueError(f'Cavity face Z {z} sits on a layer middle')
    return next(i for i in range(400) if layer_mid(i) > span[1])


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


def write_project(source, output, settings, extras=(), enforcers=()):
    profile = json.loads(settings.read_text())
    if profile['printable_area'] != ['-110x-110','110x-110','110x110','-110x110']:
        raise ValueError('Expected the AD5M Pro centered 220 mm bed')
    if profile.get('machine_pause_gcode', '').strip() != 'PAUSE':
        raise ValueError('Expected the AD5M Pro native PAUSE command')
    supported = str(profile['enable_support']) != '0'
    if int(profile['raft_layers']) != 0:
        raise ValueError('Pause validated only without a raft')
    use_layers(profile)
    if supported and not (enforcers and str(profile['support_type']).endswith('(manual)')):
        raise ValueError('Supports need --enforcer and a "(manual)" support_type, '
                         'or auto supports fill the magnet cavities')
    if supported and str(profile.get('independent_support_layer_height')) != '0':
        raise ValueError('Supports on their own layer heights move the pause layer; '
                         'set process:independent_support_layer_height=0')
    if enforcers and not supported:
        raise ValueError('--enforcer given but enable_support is off')
    pieces, cavities, span = layout(source, extras, enforcers)
    pause_z = round(layer_top(pause_layer(span)), 3)
    ns = 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'
    model = ET.Element('model', unit='millimeter', xmlns=ns)
    ET.SubElement(model, 'metadata', name='Application').text = 'BambuStudio-2.3.2'
    ET.SubElement(model, 'metadata', name='BambuStudio:3mfVersion').text = '1'
    resources = ET.SubElement(model, 'resources')
    build = ET.SubElement(model, 'build')
    config = ET.Element('config')
    # One mesh object per piece. A piece with enforcers is an assembly of its
    # mesh plus theirs; every other piece is a plain object of its own.
    for n, (path, vertices, faces) in enumerate(pieces, 1):
        obj = ET.SubElement(resources, 'object', id=str(n), type='model')
        geometry = ET.SubElement(obj, 'mesh')
        verts = ET.SubElement(geometry, 'vertices')
        for v in vertices:
            ET.SubElement(verts, 'vertex', **dict(zip(('x','y','z'),map(str,v))))
        tris = ET.SubElement(geometry, 'triangles')
        for f in faces:
            ET.SubElement(tris, 'triangle', **dict(zip(('v1','v2','v3'),map(str,f))))
    count = len(pieces)
    solids = 1 + len(extras)
    objects = [(n, [(n, 'normal_part')]) for n in range(1, solids + 1)]
    for e in range(solids + 1, count + 1):
        ev = pieces[e - 1][1]
        cx = (min(v[0] for v in ev) + max(v[0] for v in ev)) / 2
        cy = (min(v[1] for v in ev) + max(v[1] for v in ev)) / 2
        owner = next((n for n in range(1, solids + 1)
                      if min(v[0] for v in pieces[n-1][1]) <= cx <= max(v[0] for v in pieces[n-1][1])
                      and min(v[1] for v in pieces[n-1][1]) <= cy <= max(v[1] for v in pieces[n-1][1])), None)
        if owner is None:
            raise ValueError(f'{pieces[e-1][0].name} sits on no piece')
        objects[owner - 1][1].append((e, 'support_enforcer'))
    instances = []
    for n, parts in objects:
        if len(parts) > 1:
            count += 1
            obj = ET.SubElement(resources, 'object', id=str(count), type='model')
            components = ET.SubElement(obj, 'components')
            for part_id, _ in parts:
                ET.SubElement(components, 'component', objectid=str(part_id))
            object_id = count
        else:
            object_id = n
        ET.SubElement(build, 'item', objectid=str(object_id))
        instances.append(object_id)
        obj = ET.SubElement(config, 'object', id=str(object_id))
        ET.SubElement(obj, 'metadata', key='name', value=pieces[n - 1][0].stem)
        ET.SubElement(obj, 'metadata', key='extruder', value='1')
        for part_id, subtype in parts:
            part = ET.SubElement(obj, 'part', id=str(part_id), subtype=subtype)
            ET.SubElement(part, 'metadata', key='name', value=pieces[part_id - 1][0].stem)
    plate = ET.SubElement(config, 'plate')
    images = {'thumbnail_file':'Metadata/plate_1.png',
              'thumbnail_no_light_file':'Metadata/plate_no_light_1.png',
              'top_file':'Metadata/top_1.png', 'pick_file':'Metadata/pick_1.png'}
    for k,v in {'plater_id':'1', 'plater_name':source.stem, 'locked':'false', **images}.items():
        ET.SubElement(plate, 'metadata', key=k, value=v)
    for n, object_id in enumerate(instances, 1):
        instance = ET.SubElement(plate, 'model_instance')
        for k,v in {'object_id':str(object_id),'instance_id':'0','identify_id':str(n)}.items():
            ET.SubElement(instance, 'metadata', key=k, value=v)
    pauses = ET.Element('custom_gcodes_per_layer')
    plate = ET.SubElement(pauses, 'plate')
    ET.SubElement(plate, 'plate_info', id='1')
    ET.SubElement(plate, 'layer', top_z=str(pause_z), type='1', extruder='1', color='',
                  extra=f'Insert {len(cavities)} 10x2 mm magnets; check polarity', gcode='PAUSE')
    ET.SubElement(plate, 'mode', value='SingleExtruder')
    shown = pieces[:1 + len(extras)]
    vertices = [v for _, vs, _ in shown for v in vs]
    offsets = [sum(len(vs) for _, vs, _ in shown[:i]) for i in range(len(shown))]
    faces = [[i + o for i in f] for (_, _, fs), o in zip(shown, offsets) for f in fs]
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
    extra = f' + {len(extras)} more object(s)' if extras else ''
    extra += f', supports only inside {len(enforcers)} enforcer(s)' if enforcers else ''
    print(f'{source.stem}{extra}: {len(cavities)} cavities, Z {span[0]:.2f}–{span[1]:.2f}; pause before layer Z {pause_z:.2f} -> {output}')


def verify_job(source, job, extras=(), enforcers=()):
    """Read the shipped archive and check open cavities before the actual pause."""
    pieces, cavities, span = layout(source, extras, enforcers)
    boxes = []
    for _, ev, _ in pieces[len(pieces) - len(enforcers):]:
        boxes.append([min(v[0] for v in ev), min(v[1] for v in ev), min(v[2] for v in ev),
                      max(v[0] for v in ev), max(v[1] for v in ev), max(v[2] for v in ev)])
    with zipfile.ZipFile(job) as archive:
        use_layers(json.loads(archive.read('Metadata/project_settings.config')))
    layer = pause_layer(span)
    pause_z = layer_top(layer)
    open_from = next(layer_top(i) for i in range(400) if layer_mid(i) > span[0])
    with zipfile.ZipFile(job) as archive:
        if archive.testzip() is not None:
            raise ValueError('Corrupt 3MF')
        text = archive.read('Metadata/plate_1.gcode').decode()
        xml = ET.fromstring(archive.read('Metadata/custom_gcode_per_layer.xml'))
        markers = xml.findall('./plate/layer')
        if len(markers) != 1 or markers[0].get('type') != '1' or abs(float(markers[0].get('top_z'))-pause_z) > .001:
            raise ValueError('Missing or wrong native pause marker')
    pause_lines = re.findall(r'^(?:PAUSE|M25|M600|M601)(?:[ \t].*)?$', text, re.M)
    if pause_lines != ['PAUSE']:
        raise ValueError(f'Expected exactly one PAUSE: {pause_lines}')
    blocks = text.split(';LAYER_CHANGE')[1:]
    pause_block = next(i for i,b in enumerate(blocks) if '\nPAUSE\n' in b)
    z_of = lambda b: float(re.search(r'^;Z:([\d.]+)', b, re.M)[1])
    if pause_block != layer or abs(z_of(blocks[layer-1])-layer_top(layer-1)) > .001 or abs(z_of(blocks[layer])-pause_z) > .001:
        raise ValueError('Pause moved away from the validated layer boundary')
    x = y = e = 0.0
    relative_e = False
    layer_z = 0.0
    paused = False
    bridged = set()
    support_moves = 0
    role = ''
    bounds = [math.inf, math.inf, -math.inf, -math.inf]
    for line in text.splitlines():
        if line.startswith(';TYPE:'):
            role = line[6:]
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
            if role.startswith('Support'):
                support_moves += 1
                if not boxes:
                    raise ValueError(f'Support extrusion at Z {layer_z} with no enforcer')
                # Support bases spread past the enforcer, most on the first layer.
                pad = 4.5 if layer_z < FIRST + .01 else 2.5
                if not any(box[0]-pad <= min(x,nx) and max(x,nx) <= box[3]+pad and
                           box[1]-pad <= min(y,ny) and max(y,ny) <= box[4]+pad and
                           layer_z <= box[5]+.001 for box in boxes):
                    raise ValueError(f'Support outside the enforcer at Z {layer_z}: ({x},{y})-({nx},{ny})')
                for i,(cx,cy,_) in enumerate(cavities):
                    dx,dy = nx-x,ny-y
                    t = max(0,min(1,((cx-x)*dx+(cy-y)*dy)/(dx*dx+dy*dy)))
                    if (math.hypot(x+t*dx-cx,y+t*dy-cy) < 5.25 and
                            span[0]-.001 < layer_z < span[1]+.2):
                        raise ValueError(f'Support in magnet cavity {i+1} at Z {layer_z}')
            if open_from - .001 < layer_z < pause_z + .001:
                for i,(cx,cy,_) in enumerate(cavities):
                    dx,dy = nx-x,ny-y
                    t = max(0,min(1,((cx-x)*dx+(cy-y)*dy)/(dx*dx+dy*dy)))
                    distance = math.hypot(x+t*dx-cx,y+t*dy-cy)
                    if distance < 4.95 and not paused:
                        raise ValueError(f'Extrusion in magnet opening {i+1} before pause at Z {layer_z}')
                    if distance < 2.5 and abs(layer_z-pause_z)<.001 and paused:
                        bridged.add(i)
        x,y = nx,ny
    if len(bridged) != len(cavities):
        raise ValueError(f'Expected roofs after pause over {len(cavities)} magnets, found {len(bridged)}')
    if min(bounds[:2]) < -110 or max(bounds[2:]) > 110:
        raise ValueError(f'Extrusion outside bed: {bounds}')
    if enforcers and not support_moves:
        raise ValueError('Enforcer given but the job has no support extrusion')
    for box in boxes:
        print(f'enforcer X {box[0]:.1f}..{box[3]:.1f}, Y {box[1]:.1f}..{box[4]:.1f}, Z <= {box[5]:.2f}')
    if boxes:
        print(f'supports: {support_moves} extrusion moves, all inside an enforcer; none in a cavity')
    print(f'VERIFIED {job.name}: {len(cavities)} open cavities, Z {open_from:.2f}–{span[1]:.2f}; one pause before layer {layer+1} (Z {pause_z:.2f}); all roofs after pause; extrusion bounds {bounds}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stl',type=Path)
    parser.add_argument('output',type=Path)
    parser.add_argument('--settings',type=Path)
    parser.add_argument('--verify',action='store_true',help='verify output as a sliced job instead of creating a project')
    parser.add_argument('--with',dest='extras',type=Path,action='append',default=[],
                        help='another piece for the same plate, in the same frame')
    parser.add_argument('--enforcer',dest='enforcers',type=Path,action='append',default=[],
                        help='support-enforcer volume, attached to the piece it sits on')
    args = parser.parse_args()
    if args.verify:
        verify_job(args.stl,args.output,args.extras,args.enforcers)
    elif args.settings:
        write_project(args.stl,args.output,args.settings,args.extras,args.enforcers)
    else:
        parser.error('--settings is required when creating a project')
