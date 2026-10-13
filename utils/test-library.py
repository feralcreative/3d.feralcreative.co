#!/usr/bin/env python3
"""Exercise the real utility entrypoints against an isolated model library."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parent.parent


class LibraryWorkflow(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='scad-library-test-')
        self.root = Path(self.temp.name).resolve()
        (self.root/'utils').mkdir(); (self.root/'docs').mkdir(); (self.root/'stl').mkdir()
        for name in ['library.py','model-paths.sh','build.sh','render.sh','coupon.sh','slice.sh','finalize.sh','clean.sh']:
            shutil.copy2(REPO/'utils'/name,self.root/'utils'/name)
        self.model=self.root/'library'/'hand-tools'/'sample'
        self.model.mkdir(parents=True)
        (self.model/'sample.scad').write_text('// COUPON-COMPONENTS: mouth=coupon-mouth\n// COUPON-PLATE: coupon\ncube(1);\n')
        self.metadata={'id':'sample','origin':'authored','status':'testing','scad':'sample.scad','scad_files':['sample.scad'],'exports':['sample'],'aliases':{'parts/sample.scad':'sample.scad'},'openscad_args':['--enable=textmetrics']}
        (self.model/'model.json').write_text(json.dumps(self.metadata))
        (self.root/'docs/stl-versions.txt').write_text('sample 7\n')
        (self.root/'docs/print-log.txt').write_text('# existing printed history\nother mouth 2 old 1 printed included\n')
        bin_dir=self.root/'bin';bin_dir.mkdir()
        (bin_dir/'openscad').write_text("#!/usr/bin/env python3\nimport pathlib,sys,json\na=sys.argv[1:];o=pathlib.Path(a[a.index('-o')+1]);o.parent.mkdir(parents=True,exist_ok=True);o.write_bytes(b'mesh or image')\nwith open("+repr(str(self.root/'openscad-calls.jsonl'))+",'a') as f:f.write(json.dumps(a)+'\\n')\n")
        (bin_dir/'openscad').chmod(0o755)
        (self.root/'utils/ffprofile.py').write_text("#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\np=Path(sys.argv[sys.argv.index('--outdir')+1]);p.mkdir(parents=True,exist_ok=True)\nfor n in ['machine','process','filament']:(p/(n+'.json')).write_text('{}')\n")
        (self.root/'utils/ffprofile.py').chmod(0o755)
        (self.root/'utils/gcode-probe.py').write_text('#!/usr/bin/env python3\nprint("routing fixture probe")\n')
        (self.root/'utils/gcode-probe.py').chmod(0o755)
        app=self.root/'Fake Flash Studio.app';binary=app/'Contents/MacOS/Flash Studio';binary.parent.mkdir(parents=True)
        binary.write_text("#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\na=sys.argv;out=Path(a[a.index('--outputdir')+1]);(out/'plate_1.gcode').write_text('; routing fixture only\\n');(out/'out.gcode.3mf').write_bytes(b'job')\n")
        binary.chmod(0o755)
        self.env=dict(os.environ,PATH=str(bin_dir)+os.pathsep+os.environ['PATH'],FS_APP=str(app),OPENSCAD_USER_CONFIG=str(self.root/'openscad-config'))

    def tearDown(self):self.temp.cleanup()

    def run_tool(self,name,*args,ok=True):
        cmd=['python3','utils/library.py',*args] if name=='library' else ['bash','utils/'+name+'.sh',*args]
        result=subprocess.run(cmd,cwd=self.root,env=self.env,capture_output=True,text=True)
        if ok:self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        else:self.assertNotEqual(result.returncode,0)
        return result

    def test_build_render_and_legacy_alias_use_model_workspace(self):
        self.run_tool('build','parts/sample.scad')
        self.assertTrue((self.model/'_work/stl/sample-v08.stl').is_file())
        self.assertFalse((self.model/'sample.stl').exists())
        self.assertEqual((self.root/'docs/stl-versions.txt').read_text(),'sample 8\n')
        self.run_tool('render','sample')
        self.assertEqual(len(list((self.model/'_work/renders').glob('*.png'))),7)
        calls=[json.loads(x) for x in (self.root/'openscad-calls.jsonl').read_text().splitlines()]
        self.assertTrue(all('--enable=textmetrics' in args for args in calls))

    def test_scad_slice_uses_the_mesh_just_built(self):
        self.run_tool('slice','sample')
        self.assertTrue((self.model/'_work/stl/sample.stl').is_file())
        self.assertTrue((self.model/'_work/slice/sample/plate_1.gcode').is_file())
        self.assertEqual((self.model/'_work/3mf/sample.3mf').read_bytes(),b'job')
        self.assertFalse((self.model/'sample.3mf').exists())

    def test_coupon_slice_and_print_history(self):
        self.run_tool('coupon','parts/sample.scad','--slice')
        self.assertTrue((self.model/'_work/stl/sample-coupon.stl').is_file())
        self.assertTrue((self.model/'_work/3mf/sample-coupon.3mf').is_file())
        text=(self.root/'docs/print-log.txt').read_text()
        self.assertIn('other mouth 2 old 1 printed included',text)
        line=next(x for x in text.splitlines() if x.startswith('sample mouth'))
        self.assertEqual(line.split()[4:6],['-','-'])
        self.run_tool('coupon','sample','--printed')
        before=(self.root/'docs/stl-versions.txt').read_text()
        result=self.run_tool('coupon','sample')
        self.assertIn('nothing has changed',result.stdout)
        self.assertEqual((self.root/'docs/stl-versions.txt').read_text(),before)

    def test_finalize_promotes_outputs_and_cleanup_preserves_sources(self):
        (self.model/'sample.stl').write_bytes(b'retained older mesh')
        (self.model/'docs').mkdir();(self.model/'docs/license.pdf').write_bytes(b'license')
        (self.model/'originals').mkdir();(self.model/'originals/upstream-v01.stl').write_bytes(b'source')
        self.run_tool('build','sample');self.run_tool('render','sample');self.run_tool('slice','sample')
        ledger=(self.root/'docs/stl-versions.txt').read_bytes()
        self.run_tool('finalize','sample')
        self.assertEqual((self.model/'sample.stl').read_bytes(),b'mesh or image')
        self.assertEqual((self.model/'sample.3mf').read_bytes(),b'job')
        self.assertFalse(list((self.model/'_work/stl').glob('*-v*.stl')))
        self.assertEqual((self.root/'docs/stl-versions.txt').read_bytes(),ledger)
        self.run_tool('library','clean','--all','--apply')
        for file,data in [('sample.scad',b'// COUPON-COMPONENTS: mouth=coupon-mouth\n// COUPON-PLATE: coupon\ncube(1);\n'),('docs/license.pdf',b'license'),('originals/upstream-v01.stl',b'source'),('sample.stl',b'mesh or image'),('sample.3mf',b'job')]:
            self.assertEqual((self.model/file).read_bytes(),data)

    def test_imported_mesh_and_version_names_are_not_generated_output(self):
        imported=self.root/'library/lighting/imported';imported.mkdir(parents=True)
        (imported/'model.json').write_text(json.dumps({'id':'imported','origin':'imported','scad':None,'scad_files':[],'exports':[]}))
        source=imported/'lamp-v03.stl';source.write_bytes(b'only source mesh')
        self.run_tool('build','imported',ok=False)
        self.run_tool('library','clean','--all','--apply')
        self.assertEqual(source.read_bytes(),b'only source mesh')
        self.assertIn('imported',self.run_tool('library','list','--scad','no').stdout)

    def test_workspace_symlink_cannot_redirect_cleanup(self):
        other=self.root/'outside';other.mkdir();(other/'preserve.stl').write_bytes(b'important')
        (self.model/'_work').symlink_to(other,target_is_directory=True)
        self.run_tool('library','clean','--all','--apply',ok=False)
        self.assertEqual((other/'preserve.stl').read_bytes(),b'important')

    def test_imported_job_can_be_retained_without_overwriting_original_project(self):
        imported=self.root/'library/lighting/imported';imported.mkdir(parents=True)
        (imported/'model.json').write_text(json.dumps({'id':'imported','origin':'imported','scad':None,'scad_files':[],'exports':[],'protected_assets':['lamp.3mf']}))
        (imported/'lamp.3mf').write_bytes(b'original project')
        work=imported/'_work/3mf';work.mkdir(parents=True);(work/'lamp.3mf').write_bytes(b'new job')
        self.run_tool('library','finalize','imported',ok=False)
        self.assertEqual((imported/'lamp.3mf').read_bytes(),b'original project')
        (work/'lamp.3mf').rename(work/'lamp-ad5m-pro.3mf')
        self.run_tool('finalize','imported')
        self.assertEqual((imported/'lamp-ad5m-pro.3mf').read_bytes(),b'new job')

    def test_publishing_selects_retained_outputs_and_all_can_select_latest_draft(self):
        (self.model/'sample.stl').write_bytes(b'approved')
        self.run_tool('build','sample')
        retained=self.run_tool('library','publish-files').stdout.strip()
        draft=self.run_tool('library','publish-files','--all').stdout.strip()
        self.assertEqual(retained,str(self.model/'sample.stl'))
        self.assertEqual(draft,str(self.model/'_work/stl/sample.stl'))
        self.metadata['publication_excluded_exports']=['sample']
        (self.model/'model.json').write_text(json.dumps(self.metadata))
        self.assertEqual(self.run_tool('library','publish-files','--all').stdout,'')

    def test_prod_publishes_library_exports_with_or_without_legacy_directory(self):
        deploy=self.root/'utils/deploy';deploy.mkdir()
        shutil.copy2(REPO/'utils/deploy/prod.sh',deploy/'prod.sh')
        config=self.root/'.vscode';config.mkdir()
        (config/'sftp.json').write_text(json.dumps({'host':'example.invalid','port':22,'username':'test','remotePath':'/web/models'}))
        bin_dir=self.root/'bin'
        (bin_dir/'jq').write_text("#!/usr/bin/env python3\nimport json,sys\nprint(json.load(open(sys.argv[3]))[sys.argv[2][1:]])\n")
        calls=self.root/'rsync-calls.json'
        (bin_dir/'rsync').write_text("#!/usr/bin/env python3\nimport json,pathlib,sys\npathlib.Path("+repr(str(calls))+").write_text(json.dumps(sys.argv[1:]))\n")
        for name in ['jq','rsync']:(bin_dir/name).chmod(0o755)
        (self.model/'sample.stl').write_bytes(b'approved')
        (self.root/'stl').rmdir()
        for legacy in [False,True]:
            with self.subTest(legacy=legacy):
                if legacy:
                    (self.root/'stl').mkdir()
                    (self.root/'stl/legacy.stl').write_bytes(b'legacy approved')
                result=self.run_tool('deploy/prod','--dry-run')
                self.assertEqual(result.stderr,'')
                args=json.loads(calls.read_text())
                self.assertIn(str(self.model/'sample.stl'),args)
                self.assertIn('--dry-run',args)
                if legacy:self.assertIn(str(self.root/'stl/legacy.stl'),args)

    def test_finalize_accepts_a_legacy_mesh_path(self):
        self.run_tool('build','sample')
        self.run_tool('finalize','stl/sample-v08.stl')
        self.assertTrue((self.model/'sample.stl').exists())

    def test_export_name_collision_is_rejected_before_build(self):
        other=self.root/'library/house/other';other.mkdir(parents=True)
        (other/'model.json').write_text(json.dumps({'id':'other','origin':'authored','scad':None,'scad_files':[],'exports':['other-output']}))
        before=(self.root/'docs/stl-versions.txt').read_bytes()
        self.run_tool('build','sample','--name','other-output',ok=False)
        self.assertEqual((self.root/'docs/stl-versions.txt').read_bytes(),before)
        self.assertFalse((self.root/'openscad-calls.jsonl').exists())

    def test_discard_previews_and_preserves_original_sources(self):
        self.run_tool('build','sample')
        (self.model/'sample.stl').write_bytes(b'retained export')
        original=self.model/'originals/sample.stl';original.parent.mkdir();original.write_bytes(b'original mesh')
        self.metadata['protected_assets']=['originals/sample.stl']
        (self.model/'model.json').write_text(json.dumps(self.metadata))
        self.run_tool('finalize','--shitcan','sample')
        self.assertTrue((self.model/'sample.stl').exists())
        self.run_tool('finalize','--shitcan','--apply','sample')
        self.assertFalse((self.model/'sample.stl').exists())
        self.assertEqual(original.read_bytes(),b'original mesh')
        self.assertTrue((self.model/'sample.scad').exists())
        self.assertNotIn('sample 8',(self.root/'docs/stl-versions.txt').read_text())


if __name__=='__main__':unittest.main()
