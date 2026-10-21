#!/usr/bin/env python3
"""Check presentation colours, transforms, source preservation and catalog coverage."""
import importlib.util
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).parent))
from colour_mesh import convert, linear

spec = importlib.util.spec_from_file_location('web_library', Path(__file__).with_name('web-library.py'))
web = importlib.util.module_from_spec(spec)
spec.loader.exec_module(web)


def archive(path, components=False):
    mesh = '<mesh><vertices><vertex x="0" y="0" z="0"/><vertex x="20" y="0" z="0"/><vertex x="0" y="20" z="2"/></vertices><triangles><triangle v1="0" v2="1" v3="2" pid="1" p1="0"/></triangles></mesh>'
    extra = '<object id="3"><components><component objectid="2" transform="1 0 0 0 1 0 0 0 1 0 0 30"/></components></object>' if components else ''
    xml = '<model xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" unit="millimeter"><resources><basematerials id="1"><base name="Olive" displaycolor="#90A553FF"/></basematerials><object id="2" name="Door">' + mesh + '</object>' + extra + '</resources><build><item objectid="' + ('3' if components else '2') + '"/></build></model>'
    with ZipFile(path, 'w') as z:
        z.writestr('3D/3dmodel.model', xml)


class Presentations(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def glb(self, path):
        data = path.read_bytes()
        magic, version, length = struct.unpack('<4sII', data[:12])
        self.assertEqual((magic, version, length), (b'glTF', 2, len(data)))
        n, kind = struct.unpack('<II', data[12:20])
        self.assertEqual(kind, 0x4E4F534A)
        return json.loads(data[20:20+n])

    def test_repeated_source_basenames_keep_all_views_selectable(self):
        views = [dict(id='part', format=f, sha256=h) for f, h in
                 [('glb', 'aaa'), ('stl', 'bbb'), ('stl', 'ccc'), ('stl', 'ddd')]]
        web.unique_view_ids(views)
        self.assertEqual([v['id'] for v in views], ['part', 'part-stl', 'part-stl-ccc', 'part-stl-ddd'])
        self.assertEqual(len({v['id'] for v in views}), len(views))

    def test_staging_case_only_names_keep_distinct_bytes_and_stable_filenames(self):
        folder = self.root/'library/parts/case'
        sources = []
        for subdir, name, width in [('originals', 'Part.stl', 20), ('authored', 'part.stl', 40)]:
            source = folder/subdir/name
            source.parent.mkdir(parents=True)
            source.write_bytes(b' ' * 80 + struct.pack('<I', 1) + struct.pack('<12fH', 0,0,1, 0,0,0, width,0,0, 0,20,2, 0))
            sources.append(source)
        before = {source: source.read_bytes() for source in sources}
        stage = self.root/'stage'
        stage.mkdir()
        # Simulate a stale symlink left by the old case-insensitive collision.
        (stage/'case--Part.stl').symlink_to(sources[1])
        model = {'id': 'case', 'directory': folder, 'exports': []}
        with patch.object(web.library, 'models', return_value=[model]), patch.object(web.library, 'LIBRARY', self.root/'library'):
            first = web.generate(stage)['models'][0]
            second = web.generate(stage)['models'][0]
        names = [item['file'] for item in first['downloads']]
        self.assertEqual(len({name.casefold() for name in names}), 2)
        self.assertEqual(names, [item['file'] for item in second['downloads']])
        self.assertEqual({item['sha256'] for item in first['downloads']}, {web.digest(source) for source in sources})
        for item in first['downloads']:
            self.assertEqual(web.digest(stage/item['file']), item['sha256'])
            self.assertEqual((stage/item['file']).stat().st_size, item['bytes'])
        self.assertTrue(all(source.read_bytes() == data for source, data in before.items()))

    def test_project_copy_parts_and_instructions_are_authored_and_preserved(self):
        model = {'id': 'pumpkin', 'website': {
            'description': 'A pumpkin.', 'default_view': 'assembled',
            'view_labels': {'assembled': 'Assembly'},
            'instructions': [{'title': 'Insert disc', 'text': 'Pause before covering the pocket.'}],
            'parts': [{'name': 'Steel disc', 'quantity': '1', 'specification': '25 x 2 mm', 'url': ''}],
            'links': [{'label': 'Source', 'url': 'https://example.com/original'}],
        }}
        result = web.website_metadata(model)
        self.assertEqual(result, model['website'])
        self.assertEqual(result['parts'][0]['url'], '')

    def test_project_links_reject_scripts_and_credential_bearing_urls(self):
        for url in ('javascript:alert(1)', 'https://user:password@example.com/item', 'http://example.com/item'):
            with self.subTest(url=url), self.assertRaisesRegex(ValueError, 'HTTPS'):
                web.website_metadata({'id': 'one', 'website': {'parts': [{'name': 'disc', 'url': url}]}})

    def test_failed_colour_render_does_not_advertise_an_old_cached_view(self):
        folder=self.root/'library/parts/one'
        cache=folder/'_work/web'
        cache.mkdir(parents=True)
        (cache/'preview.glb').write_bytes(b'old geometry')
        (cache/'preview.json').write_text(json.dumps({'bounds': {'min': [0,0,0], 'max': [1,1,1]}}))
        models=[{'id': 'one', 'directory': folder, 'scad': 'one.scad', 'exports': []}]
        with patch.object(web.library, 'models', return_value=models), patch.object(web.library, 'LIBRARY', self.root/'library'), patch.object(web, 'coloured_view', side_effect=ValueError('export failed')):
            catalog=web.generate(self.root/'stage', render=True)
        self.assertEqual(catalog['models'][0]['views'], [])
        self.assertTrue((cache/'preview.glb').exists())
        report=json.loads((self.root/'stage/report.json').read_text())
        self.assertEqual(report['failures'][0]['view'], 'preview')

    def test_exact_colour_factors_and_standard_units(self):
        source, dest = self.root / 'part.3mf', self.root / 'part.glb'
        archive(source)
        before = source.read_bytes()
        bounds = convert(source, dest)
        doc = self.glb(dest)
        self.assertEqual(source.read_bytes(), before)
        self.assertEqual(bounds, {'min': [0, 0, 0], 'max': [20, 20, 2]})
        self.assertEqual(doc['materials'][0]['pbrMetallicRoughness']['baseColorFactor'], [linear(144), linear(165), linear(83), 1])
        self.assertEqual(doc['nodes'][0]['matrix'][0], .001)
        self.assertEqual(doc['nodes'][0]['matrix'][6], -.001)
        self.assertEqual(doc['meshes'][0]['name'], 'Door')

    def test_component_transform_is_retained_and_bounds_are_mm(self):
        source, dest = self.root / 'assembly.3mf', self.root / 'assembly.glb'
        archive(source, components=True)
        bounds = convert(source, dest)
        self.assertEqual(bounds, {'min': [0, 0, 30], 'max': [20, 20, 32]})
        self.assertEqual(self.glb(dest)['nodes'][2]['matrix'][14], 30)

    def test_cyclic_components_are_rejected(self):
        source = self.root / 'bad.3mf'
        with ZipFile(source, 'w') as z:
            z.writestr('3D/3dmodel.model', '<model><resources><object id="1"><components><component objectid="1"/></components></object></resources><build><item objectid="1"/></build></model>')
        with self.assertRaisesRegex(ValueError, 'Cyclic'):
            convert(source, self.root / 'bad.glb')

    def test_curated_parts_and_one_scad_exclude_retired_exports(self):
        folder = self.root / 'library/parts/pumpkin'
        folder.mkdir(parents=True)
        payload = b' ' * 80 + struct.pack('<I', 1) + struct.pack('<12fH', 0,0,1, 0,0,0, 20,0,0, 0,20,2, 0)
        (folder/'body.stl').write_bytes(payload)
        (folder/'old-trial.stl').write_bytes(payload + b'old')
        (folder/'assembly.scad').write_text('import("pumpkin--body.stl");')
        (folder/'private-helper.scad').write_text('cube(1);')
        model = {'id': 'pumpkin', 'directory': folder, 'exports': ['body', 'old-trial'],
                 'publish_exports': ['body'], 'publication_excluded_exports': ['old-trial'],
                 'source_downloads': ['assembly.scad']}
        with patch.object(web.library, 'models', return_value=[model]), patch.object(web.library, 'LIBRARY', self.root/'library'):
            catalog = web.generate(self.root/'stage')
        entry = catalog['models'][0]
        self.assertEqual([item['file'] for item in entry['downloads']], ['pumpkin--body.stl', 'pumpkin--assembly.scad'])
        self.assertEqual([item['file'] for item in entry['views']], ['pumpkin--body.stl'])
        self.assertIn('pumpkin--old-trial.stl', entry['excluded_files'])
        self.assertIn('old-trial.stl', entry['aliases'])
        self.assertTrue((folder/'old-trial.stl').exists())
        self.assertTrue((folder/'private-helper.scad').exists())

    def test_scad_eligibility_requires_an_existing_declared_source(self):
        library_root = self.root/'library'
        collection = []
        for key in ['authored', 'mesh-only', 'missing-source']:
            folder = library_root/'parts'/key
            folder.mkdir(parents=True)
            collection.append({'id': key, 'directory': folder, 'publish_exports': []})
        (collection[0]['directory']/'main.scad').write_text('cube(1);')
        collection[0]['scad_files'] = ['main.scad']
        (collection[1]['directory']/'unregistered-helper.scad').write_text('module helper() {}')
        collection[2]['scad'] = 'missing.scad'
        with patch.object(web.library, 'models', return_value=collection), patch.object(web.library, 'LIBRARY', library_root):
            catalog = web.generate(self.root/'stage')
        self.assertEqual([model['has_scad'] for model in catalog['models']], [True, False, False])

    def test_explicit_empty_or_missing_selection_does_not_fall_back_to_originals(self):
        folder = self.root/'one'
        folder.mkdir()
        (folder/'old-trial.stl').write_bytes(b'original')
        for exports in ([], ['missing-final']):
            model = {'id': 'one', 'directory': folder, 'publish_exports': exports}
            self.assertEqual(web.candidates(model, [model]), [])

    def test_source_download_rejects_traversal_and_missing_scad(self):
        folder = self.root/'library/parts/one'
        folder.mkdir(parents=True)
        for filename in ('../../outside.scad', 'missing.scad', 'file.stl'):
            model = {'id': 'one', 'directory': folder, 'exports': [], 'publish_exports': [], 'source_downloads': [filename]}
            with patch.object(web.library, 'models', return_value=[model]), patch.object(web.library, 'LIBRARY', self.root/'library'), self.assertRaises(ValueError):
                web.generate(self.root/'stage')

    def test_catalog_includes_meshless_entries_and_preserves_originals(self):
        library_root = self.root / 'library'
        a, b = library_root / 'imported/one', library_root / 'legacy/two'
        a.mkdir(parents=True); b.mkdir(parents=True)
        (b/'two.skp').write_bytes(b'original SketchUp')
        (b/'originals').mkdir()
        (b/'originals/two.skp').write_bytes(b'original SketchUp')
        source = a / 'originals/part.STL'; source.parent.mkdir()
        triangles = [0., 0., 1., 0., 0., 0., 20., 0., 0., 0., 20., 2.]
        source.write_bytes(b' ' * 80 + struct.pack('<I', 1) + struct.pack('<12fH', *triangles, 0))
        before = source.read_bytes()
        collection = [{'id': 'one', 'origin': 'imported', 'directory': a, 'exports': [], 'protected_assets': ['originals/part.STL']},
                      {'id': 'two', 'origin': 'legacy', 'directory': b, 'exports': []}]
        previous = web.library.models, web.library.LIBRARY
        web.library.models = lambda: collection
        web.library.LIBRARY = library_root
        try:
            catalog = web.generate(self.root / 'stage')
            again = web.generate(self.root / 'stage')
        finally:
            web.library.models, web.library.LIBRARY = previous
        self.assertEqual(len(catalog['models']), 2)
        self.assertEqual(catalog['models'][0]['availability'], 'viewable')
        self.assertEqual(catalog['models'][1]['availability'], 'no-mesh')
        self.assertEqual(len(catalog['models'][1]['downloads']), 1)
        self.assertEqual(source.read_bytes(), before)
        view = again['models'][0]['views'][0]
        self.assertEqual(view['format'], 'stl')
        self.assertTrue((self.root / 'stage' / view['file']).is_symlink())
        self.assertEqual(view['source_bounds_mm']['max'], [20., 20., 2.])


if __name__ == '__main__':
    unittest.main()
