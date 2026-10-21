#!/usr/bin/env python3
"""Build the website catalog and stage selected model assets without publishing them."""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
from urllib.parse import urlsplit
from xml.etree.ElementTree import ParseError as ET_ERRORS

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('model_library', ROOT / 'utils/library.py')
library = importlib.util.module_from_spec(spec)
spec.loader.exec_module(library)
from colour_mesh import convert

FORMATS = {'.stl', '.3mf', '.obj', '.off', '.ply', '.step', '.stp', '.3dm', '.fcstd', '.glb', '.gltf'}
SKIP = re.compile(r'(coupon|enforcer|support[-_ ](?:blocker|volume)|shell-\d\d)', re.I)


def website_metadata(model):
    """Publish authored project copy, never infer instructions from filenames."""
    raw = model.get('website', {})
    if not isinstance(raw, dict):
        raise ValueError(f"{model['id']}: website must be an object")
    result = {}
    for key in ('description', 'default_view'):
        value = raw.get(key, '')
        if not isinstance(value, str):
            raise ValueError(f"{model['id']}: website.{key} must be text")
        result[key] = value
    labels = raw.get('view_labels', {})
    if not isinstance(labels, dict) or not all(isinstance(k, str) and isinstance(v, str) for k, v in labels.items()):
        raise ValueError(f"{model['id']}: website.view_labels must contain text labels")
    result['view_labels'] = labels
    for key, fields in (('instructions', ('title', 'text')), ('parts', ('name', 'quantity', 'specification', 'url')),
                        ('links', ('label', 'url'))):
        items = raw.get(key, [])
        if not isinstance(items, list):
            raise ValueError(f"{model['id']}: website.{key} must be a list")
        result[key] = []
        for item in items:
            if not isinstance(item, dict) or not all(isinstance(item.get(field, ''), str) for field in fields):
                raise ValueError(f"{model['id']}: invalid website.{key} entry")
            clean = {field: item.get(field, '') for field in fields}
            if clean.get('url'):
                url = urlsplit(clean['url'])
                if url.scheme != 'https' or not url.hostname or url.username or url.password:
                    raise ValueError(f"{model['id']}: website links must be HTTPS without credentials")
            result[key].append(clean)
    return result


def catalog_settings():
    path = ROOT / 'catalog-settings.json'
    raw = json.loads(path.read_text()) if path.is_file() else {}
    tag = raw.get('amazon_affiliate_tag', '')
    if not isinstance(tag, str) or (tag and not re.fullmatch(r'[a-zA-Z0-9-]+', tag)):
        raise ValueError('amazon_affiliate_tag must be empty or an Amazon tracking ID')
    return {'amazon_affiliate_tag': tag}


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def slug(value):
    return re.sub(r'[^a-zA-Z0-9_.-]+', '-', value).strip('-') or 'view'


def unique_view_ids(views):
    """Keep distinct files selectable when source basenames repeat."""
    used = set()
    for view in views:
        base = view['id']
        name = base
        if name in used:
            name = base + '-' + view['format']
        if name in used:
            name += '-' + view['sha256'][:10]
        index = 2
        candidate = name
        while candidate in used:
            candidate = name + '-' + str(index)
            index += 1
        view['id'] = candidate
        used.add(candidate)


def stl_bounds(path):
    with path.open('rb') as f:
        header = f.read(84)
        count = struct.unpack('<I', header[80:84])[0] if len(header) == 84 else 0
        lo, hi = [float('inf')] * 3, [float('-inf')] * 3
        if 84 + count * 50 == path.stat().st_size:
            try:
                import numpy as np
                records = np.frombuffer(f.read(), dtype=np.dtype([('n', '<3f4'), ('v', '<9f4'), ('a', '<u2')]))
                points = records['v'].reshape(-1, 3)
                if not len(points) or not np.isfinite(points).all():
                    raise ValueError('STL has empty or non-finite geometry')
                return {'min': points.min(axis=0).tolist(), 'max': points.max(axis=0).tolist()}
            except ImportError:
                pass
            for triangle in struct.iter_unpack('<12fH', f.read()):
                for offset in (3, 6, 9):
                    for i in range(3):
                        lo[i], hi[i] = min(lo[i], triangle[offset + i]), max(hi[i], triangle[offset + i])
        else:
            f.seek(0)
            for line in f:
                words = line.split()
                if len(words) == 4 and words[0] == b'vertex':
                    for i, value in enumerate(map(float, words[1:])):
                        lo[i], hi[i] = min(lo[i], value), max(hi[i], value)
        if lo[0] == float('inf'):
            raise ValueError('STL contains no vertices')
        return {'min': lo, 'max': hi}


def owned_files(model, collection, formats=FORMATS):
    directory = model['directory']
    nested = [m['directory'] for m in collection if m is not model and m['directory'].is_relative_to(directory)]
    for p in directory.rglob('*'):
        if not p.is_file() or '_work' in p.relative_to(directory).parts or any(p.is_relative_to(n) for n in nested):
            continue
        if p.suffix.lower() in formats and p.resolve().is_relative_to(directory.resolve()):
            yield p


def candidates(model, collection):
    excluded = set(model.get('publication_excluded_exports', []))
    declared = []
    for name in model.get('publish_exports', model.get('exports', [])):
        if name in excluded or SKIP.search(name):
            continue
        p = model['directory'] / (name + '.stl')
        if not p.is_file():
            p = library.workspace(model) / 'stl' / p.name
        if p.is_file():
            declared.append(p)
    if declared or 'publish_exports' in model:
        return declared
    files = sorted(owned_files(model, collection), key=lambda p: (
        p.stem != model['id'], len(p.relative_to(model['directory']).parts), p.suffix.lower() != '.stl', str(p)))
    result = []
    for p in files:
        if SKIP.search(p.stem) or p.stem in excluded or p.name.startswith('.') or p.stem.endswith('~'):
            continue
        if re.search(r'-v\d{2,}$', p.stem):
            plain = p.with_name(re.sub(r'-v\d{2,}$', '', p.stem) + p.suffix)
            if plain.exists():
                continue
        # Multi-file OBJ/glTF packages need dependency staging, so do not
        # misrepresent one selected file as a self-contained presentation.
        if p.suffix.lower() in {'.obj', '.gltf'}:
            continue
        result.append(p)
    return result


def coloured_view(model, view, openscad, force=False):
    source = library.asset(model, view.get('scad', model['scad']))
    folder = library.workspace(model) / 'web'
    folder.mkdir(parents=True, exist_ok=True)
    name = slug(view['id'])
    native, glb, record = folder / (name + '.3mf'), folder / (name + '.glb'), folder / (name + '.json')
    dependencies = []
    for base in (model['directory'], ROOT / 'logos', ROOT / 'lib/BOSL2'):
        for p in base.rglob('*'):
            if p.is_file() and '_work' not in p.parts and p.suffix.lower() in {'.scad', '.stl', '.svg', '.dxf', '.ttf'}:
                dependencies.append((str(p), p.stat().st_size, p.stat().st_mtime_ns))
    signature = hashlib.sha256(json.dumps([2, view, sorted(dependencies)]).encode()).hexdigest()
    if not force and glb.is_file() and record.is_file():
        cached = json.loads(record.read_text())
        if cached.get('signature') == signature:
            return glb, cached['bounds']
    # A failed or empty export must not reuse a previous native mesh.
    native.unlink(missing_ok=True)
    command = [openscad, '-o', str(native), '--export-format=3mf', *model.get('openscad_args', [])]
    for key, value in view.get('defines', {}).items():
        command.extend(['-D', key + '=' + json.dumps(value)])
    result = subprocess.run([*command, str(source)], capture_output=True, text=True, timeout=300)
    diagnostics = re.sub(r"(?m)^WARNING: Ignoring request to enable unknown feature 'textmetrics'\.\n?", '', result.stderr)
    if result.returncode or re.search(r'(?m)^(?:ERROR|WARNING):', diagnostics) or not native.is_file():
        raise ValueError((result.stderr.strip() or 'OpenSCAD export failed')[-1000:])
    bounds = convert(native, glb)
    record.write_text(json.dumps({'signature': signature, 'bounds': bounds}) + '\n')
    return glb, bounds


def generate(output, render=False, only=None, force=False, jobs=2):
    collection = library.models()
    output = Path(output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    staged = {}
    portable_names = {}
    models, failures = [], []
    failed_presentations = set()
    openscad = shutil.which('openscad') or '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
    if render:
        with ThreadPoolExecutor(max_workers=jobs) as pool:
            pending = {}
            for model in collection:
                if only and model['id'] not in only:
                    continue
                views = model.get('presentations') or ([{'id': 'preview', 'label': 'Model', 'scad': model['scad']}] if model.get('scad') else [])
                for view in views:
                    pending[pool.submit(coloured_view, model, view, openscad, force)] = (model['id'], view['id'])
            for future in as_completed(pending):
                mid, vid = pending[future]
                try:
                    future.result()
                    print(f'Coloured view: {mid}/{vid}', flush=True)
                except (ValueError, OSError, KeyError, subprocess.TimeoutExpired, ET_ERRORS) as exc:
                    failed_presentations.add((mid, vid))
                    failures.append({'model': mid, 'view': vid, 'error': str(exc)})
                    print(f'View unavailable: {mid}/{vid} (see report.json)', flush=True)

    def stage(path, filename):
        path = path.resolve()
        if Path(filename).name != filename or filename in {'.', '..', 'catalog.json'}:
            raise ValueError(f'Unsafe presentation filename: {filename}')
        # macOS staging may be case-insensitive even when the NAS is not.
        # Reserve the flat namespace portably before creating any symlink.
        occupied = portable_names.get(filename.casefold())
        if occupied and staged[occupied] == path:
            filename = occupied
        elif occupied:
            original = Path(filename)
            base = original.stem + '-' + digest(path)[:10]
            filename = base + original.suffix
            index = 2
            while filename.casefold() in portable_names:
                existing = portable_names[filename.casefold()]
                if staged[existing] == path:
                    filename = existing
                    break
                filename = base + '-' + str(index) + original.suffix
                index += 1
        staged[filename] = path
        portable_names[filename.casefold()] = filename
        target = output / filename
        if target.is_symlink():
            if target.resolve() != path:
                target.unlink()
        elif target.exists():
            raise ValueError(f'Refusing to replace a non-generated file: {target}')
        if not target.exists():
            target.symlink_to(path)
        return {'file': filename, 'format': path.suffix.lower()[1:], 'bytes': path.stat().st_size, 'sha256': digest(path)}

    for model in collection:
        entry = {'id': model['id'], 'title': model.get('title', model['id'].replace('-', ' ').capitalize()),
                 'category': library.category(model).split('/'), 'origin': model.get('origin', 'legacy'),
                 'status': model.get('status', 'unreviewed'), 'views': [], 'downloads': [], 'aliases': []}
        declared_sources = [model.get('scad', ''), *model.get('scad_files', []), *model.get('source_downloads', [])]
        entry['has_scad'] = any(isinstance(name, str) and name.lower().endswith('.scad') and
                                library.asset(model, name).is_file() for name in declared_sources if name)
        entry['website'] = website_metadata(model)
        # Retired exports still claim old filenames so stale published files cannot
        # reappear as unmanaged cards or remain downloadable through legacy aliases.
        excluded = model.get('publication_excluded_exports', [])
        if excluded:
            entry['excluded_files'] = [filename for name in excluded for filename in
                (name + '.stl', model['id'] + '--' + slug(name) + '.stl')]
            entry['aliases'].extend(entry['excluded_files'])
        seen = set()
        for key in model.get('aliases', {}):
            basename = Path(key).name
            if basename.lower().endswith(('.stl', '.3mf', '.gcode')):
                entry['aliases'].append(basename)
        available = candidates(model, collection)
        for p in available:
            key = digest(p)
            if key in seen:
                continue
            seen.add(key)
            filename = model['id'] + '--' + slug(p.stem) + p.suffix.lower()
            data = stage(p, filename)
            if p.suffix.lower() != '.3mf':
                view = {'id': slug(p.stem), 'label': p.stem, **data,
                        'units': 'm' if p.suffix.lower() == '.glb' else 'mm',
                        'up_axis': 'Y' if p.suffix.lower() == '.glb' else 'Z', 'colour_source': 'default'}
                if p.suffix.lower() == '.stl':
                    try:
                        view['source_bounds_mm'] = stl_bounds(p)
                    except (ValueError, struct.error) as exc:
                        failures.append({'model': model['id'], 'file': p.name, 'error': str(exc)})
                        continue
                entry['views'].append(view)
            else:
                # Slicer projects may carry geometry; convert for faithful
                # colours and avoid presenting the known dark 3MF importer.
                try:
                    glb = library.workspace(model) / 'web' / ('import-' + slug(p.stem) + '-' + key[:10] + '.glb')
                    record = glb.with_suffix('.source.json')
                    if glb.is_file() and record.is_file() and json.loads(record.read_text()).get('sha256') == key:
                        bounds = json.loads(record.read_text())['bounds']
                    else:
                        bounds = convert(p, glb)
                        record.write_text(json.dumps({'sha256': key, 'bounds': bounds}) + '\n')
                    entry['views'].append({'id': slug(p.stem), 'label': p.stem,
                        **stage(glb, model['id'] + '--' + slug(p.stem) + '-' + key[:10] + '.glb'),
                        'units': 'm', 'up_axis': 'Y', 'source_bounds_mm': bounds, 'colour_source': 'source'})
                except (ValueError, KeyError, OSError, ET_ERRORS) as exc:
                    failures.append({'model': model['id'], 'file': p.name, 'error': str(exc)})
            entry['downloads'].append({'export': p.stem, **data})
            entry['aliases'].append(p.name)
        sources = model.get('source_downloads', [])
        if not isinstance(sources, list) or not all(isinstance(name, str) for name in sources):
            raise ValueError(f"{model['id']}: source_downloads must be a list of source paths")
        for name in dict.fromkeys(sources):
            source = library.asset(model, name)
            if source.suffix.lower() != '.scad' or not source.is_file():
                raise ValueError(f"{model['id']}: source_downloads must select existing SCAD files")
            filename = model['id'] + '--' + slug(source.stem) + '.scad'
            entry['downloads'].append({'export': source.stem, **stage(source, filename)})
        presentations = model.get('presentations', [])
        if not presentations and model.get('scad'):
            presentations = [{'id': 'preview', 'label': 'Model', 'scad': model['scad']}]
        for view in reversed(presentations):
            if (model['id'], view['id']) in failed_presentations:
                continue
            glb = library.workspace(model) / 'web' / (slug(view['id']) + '.glb')
            record = glb.with_suffix('.json')
            bounds = None
            if glb.is_file() and record.is_file():
                bounds = json.loads(record.read_text()).get('bounds')
            if glb.is_file() and bounds:
                entry['views'].insert(0, {'id': view['id'], 'label': view.get('label', view['id']),
                    **stage(glb, model['id'] + '--' + slug(view['id']) + '.glb'), 'units': 'm', 'up_axis': 'Y',
                    'source_bounds_mm': bounds, 'colour_source': 'scad'})
        entry['aliases'] = sorted(set(entry['aliases']))
        if not entry['views'] and not entry['downloads']:
            for p in sorted(owned_files(model, collection, {'.skp', '.scad', '.step', '.stp'})):
                if p.stem.endswith('~'):
                    continue
                key = digest(p)
                if key in seen:
                    continue
                seen.add(key)
                name = model['id'] + '--source-' + slug(p.stem) + '-' + key[:10] + p.suffix.lower()
                entry['downloads'].append({'export': p.stem, **stage(p, name)})
        unique_view_ids(entry['views'])
        for view in entry['views']:
            view['label'] = entry['website']['view_labels'].get(view['id'], view['label'])
        requested = entry['website']['default_view']
        if requested and not any(view['id'] == requested for view in entry['views']):
            failures.append({'model': model['id'], 'view': requested, 'error': 'Preferred project preview is not staged'})
            requested = ''
        entry['default_view'] = requested or (entry['views'][0]['id'] if entry['views'] else None)
        entry['availability'] = 'viewable' if entry['views'] else 'no-mesh'
        models.append(entry)
    catalog = {'schema': 1, 'generated_at': datetime.now(timezone.utc).isoformat(), 'settings': catalog_settings(), 'models': models}
    temporary = output / 'catalog.json.tmp'
    temporary.write_text(json.dumps(catalog, indent=2, allow_nan=False) + '\n')
    temporary.replace(output / 'catalog.json')
    (output / 'report.json').write_text(json.dumps({'failures': failures, 'models': len(models), 'viewable': sum(bool(m['views']) for m in models)}, indent=2) + '\n')
    print(f"Catalog: {len(models)} models, {sum(bool(m['views']) for m in models)} viewable, {len(staged)} assets, {len(failures)} conversion warning(s).")
    return catalog


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--outdir', type=Path, default=ROOT / '_work/site-models')
    parser.add_argument('--render-colours', action='store_true', help='Export configured SCAD views to coloured GLB')
    parser.add_argument('--model', action='append', help='Limit SCAD rendering to these model IDs; the catalog still includes every model')
    parser.add_argument('--force', action='store_true')
    parser.add_argument('--jobs', type=int, default=2, choices=range(1, 5))
    args = parser.parse_args()
    generate(args.outdir, args.render_colours, args.model, args.force, args.jobs)
