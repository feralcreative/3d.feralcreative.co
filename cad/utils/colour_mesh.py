"""Convert colour-preserving 3MF geometry to interoperable GLB presentation files."""
import json
from pathlib import Path, PurePosixPath
import struct
import tempfile
from xml.etree import ElementTree as ET
from zipfile import ZipFile


def linear(channel):
    c = channel / 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def rgba(value):
    value = value.lstrip('#')
    if len(value) == 6:
        value += 'FF'
    return [*(linear(int(value[i:i + 2], 16)) for i in (0, 2, 4)), int(value[6:8], 16) / 255]


def transform(value):
    if not value:
        return [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    m = [float(v) for v in value.split()]
    if len(m) != 12:
        raise ValueError('Invalid 3MF transform')
    return [*m[0:3], 0, *m[3:6], 0, *m[6:9], 0, *m[9:12], 1]


def multiply(a, b):
    return [sum(a[k * 4 + row] * b[col * 4 + k] for k in range(4)) for col in range(4) for row in range(4)]


def convert(source, destination):
    """Preserve objects, transforms and base/vertex colours; report source bounds in mm."""
    binary = bytearray()
    gltf = {'asset': {'version': '2.0'}, 'scene': 0, 'scenes': [{'nodes': [0]}],
            'nodes': [{'name': 'OpenSCAD coordinates', 'children': [],
                       'matrix': [.001, 0, 0, 0, 0, 0, -.001, 0, 0, .001, 0, 0, 0, 0, 0, 1]}],
            'meshes': [], 'materials': [], 'bufferViews': [], 'accessors': []}
    bounds = [[float('inf')] * 3, [float('-inf')] * 3]
    material_cache = {}
    mesh_cache = {}

    def buffer(values, component, kind, target, minimum=None, maximum=None):
        while len(binary) % 4:
            binary.append(0)
        data = struct.pack('<' + ('f' if component == 5126 else 'I') * len(values), *values)
        view = len(gltf['bufferViews'])
        gltf['bufferViews'].append({'buffer': 0, 'byteOffset': len(binary), 'byteLength': len(data), 'target': target})
        binary.extend(data)
        a = {'bufferView': view, 'componentType': component, 'count': len(values) // {'SCALAR': 1, 'VEC3': 3, 'VEC4': 4}[kind], 'type': kind}
        if minimum is not None:
            a.update(min=minimum, max=maximum)
        gltf['accessors'].append(a)
        return len(gltf['accessors']) - 1

    with ZipFile(source) as archive:
        documents = {}
        for name in archive.namelist():
            if name.lower().endswith('.model'):
                root = ET.fromstring(archive.read(name))
                resources = next((e for e in root if e.tag.rsplit('}', 1)[-1] == 'resources'), [])
                documents[name] = (root, {e.attrib['id']: e for e in resources if 'id' in e.attrib})
        if not documents:
            raise ValueError('3MF has no model geometry')
        primary = next((n for n in documents if n.lower() == '3d/3dmodel.model'), next(iter(documents)))
        unit = documents[primary][0].attrib.get('unit', 'millimeter')
        unit_mm = {'micron': .001, 'millimeter': 1, 'centimeter': 10, 'inch': 25.4, 'foot': 304.8, 'meter': 1000}.get(unit)
        if unit_mm is None:
            raise ValueError(f'Unsupported 3MF unit: {unit}')

        def material(doc, pid, index):
            resource = documents[doc][1].get(pid)
            if resource is None:
                return None
            entries = list(resource)
            if not 0 <= index < len(entries):
                raise ValueError('3MF colour index out of bounds')
            entry = entries[index]
            colour = entry.attrib.get('displaycolor', entry.attrib.get('color'))
            if colour is None:
                raise ValueError('Unsupported 3MF material resource')
            # Native OpenSCAD assigns this to geometry without a color().
            if entry.attrib.get('name') == 'Default':
                return None
            key = (doc, pid, index)
            if key not in material_cache:
                material_cache[key] = len(gltf['materials'])
                gltf['materials'].append({'name': colour, 'pbrMetallicRoughness': {
                    'baseColorFactor': rgba(colour), 'metallicFactor': 0, 'roughnessFactor': .65}})
            return material_cache[key]

        def mesh(doc, obj):
            key = (doc, obj.attrib['id'])
            if key in mesh_cache:
                return mesh_cache[key]
            node = next(e for e in obj if e.tag.rsplit('}', 1)[-1] == 'mesh')
            vs = next(e for e in node if e.tag.rsplit('}', 1)[-1] == 'vertices')
            ts = next(e for e in node if e.tag.rsplit('}', 1)[-1] == 'triangles')
            vertices = [[float(v.attrib[k]) * unit_mm for k in ('x', 'y', 'z')] for v in vs]
            if not vertices:
                raise ValueError('Empty mesh')
            lo = [min(v[i] for v in vertices) for i in range(3)]
            hi = [max(v[i] for v in vertices) for i in range(3)]
            position = buffer([c for v in vertices for c in v], 5126, 'VEC3', 34962, lo, hi)
            groups = {}
            for t in ts:
                ids = [int(t.attrib[k]) for k in ('v1', 'v2', 'v3')]
                if any(i < 0 or i >= len(vertices) for i in ids):
                    raise ValueError('Triangle vertex out of bounds')
                pid = t.attrib.get('pid', obj.attrib.get('pid'))
                p1 = int(t.attrib.get('p1', obj.attrib.get('pindex', '0')))
                if any(int(t.attrib.get(k, p1)) != p1 for k in ('p2', 'p3')):
                    raise ValueError('Per-vertex interpolated 3MF colours require explicit conversion')
                mat = material(doc, pid, p1) if pid else None
                groups.setdefault(mat, []).extend(ids)
            primitives = []
            for mat, ids in groups.items():
                p = {'attributes': {'POSITION': position}, 'indices': buffer(ids, 5125, 'SCALAR', 34963)}
                if mat is not None:
                    p['material'] = mat
                primitives.append(p)
            index = len(gltf['meshes'])
            gltf['meshes'].append({'name': obj.attrib.get('name', f'Object {obj.attrib["id"]}'), 'primitives': primitives})
            mesh_cache[key] = (index, vertices)
            return index, vertices

        def add_object(doc, object_id, matrix, parent, stack):
            key = (doc, object_id)
            if any(item[:2] == key for item in stack):
                raise ValueError('Cyclic 3MF component reference')
            obj = documents[doc][1][object_id]
            index = len(gltf['nodes'])
            node_matrix = list(matrix)
            node_matrix[12:15] = [v * unit_mm for v in matrix[12:15]]
            gltf['nodes'].append({'name': obj.attrib.get('name', f'Object {object_id}'), 'matrix': node_matrix})
            gltf['nodes'][parent].setdefault('children', []).append(index)
            full = multiply(stack[-1][2], matrix) if stack else matrix
            if any(e.tag.rsplit('}', 1)[-1] == 'mesh' for e in obj):
                mi, vertices = mesh(doc, obj)
                gltf['nodes'][index]['mesh'] = mi
                for v in vertices:
                    out = [sum(full[k * 4 + i] * v[k] for k in range(3)) + full[12 + i] * unit_mm for i in range(3)]
                    for i in range(3):
                        bounds[0][i] = min(bounds[0][i], out[i])
                        bounds[1][i] = max(bounds[1][i], out[i])
            for container in obj:
                if container.tag.rsplit('}', 1)[-1] != 'components':
                    continue
                for component in container:
                    external = next((v for k, v in component.attrib.items() if k.rsplit('}', 1)[-1] == 'path'), None)
                    child_doc = doc
                    if external:
                        child_doc = str(PurePosixPath(external.lstrip('/')))
                        if child_doc not in documents:
                            raise ValueError(f'Missing external model: {child_doc}')
                    add_object(child_doc, component.attrib['objectid'], transform(component.attrib.get('transform')), index, stack + [(doc, object_id, full)])

        root = documents[primary][0]
        build = next((e for e in root if e.tag.rsplit('}', 1)[-1] == 'build'), [])
        for item in build:
            add_object(primary, item.attrib['objectid'], transform(item.attrib.get('transform')), 0, [])
    if not gltf['meshes']:
        raise ValueError('3MF build contains no meshes')
    # Drop unused material definitions, keeping primitive references stable.
    if not gltf['materials']:
        del gltf['materials']
    gltf['buffers'] = [{'byteLength': len(binary)}]
    data = json.dumps(gltf, separators=(',', ':')).encode()
    data += b' ' * (-len(data) % 4)
    binary += b'\0' * (-len(binary) % 4)
    result = struct.pack('<4sII', b'glTF', 2, 28 + len(data) + len(binary))
    result += struct.pack('<II', len(data), 0x4E4F534A) + data
    result += struct.pack('<II', len(binary), 0x004E4942) + binary
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=destination.parent, suffix='.glb.tmp', delete=False) as f:
        temporary = Path(f.name)
        f.write(result)
    temporary.replace(destination)
    return {'min': bounds[0], 'max': bounds[1]}
