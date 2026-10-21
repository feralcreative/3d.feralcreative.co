#!/usr/bin/env python3
"""Prove mesh-first publication and refusal to advertise a failed asset upload."""
import json
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import tempfile
import unittest


class Publish(unittest.TestCase):
    def test_root_wrapper_publishes_custom_stage_and_help_never_publishes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            (root/'utils').mkdir()
            (root/'cad/utils/deploy').mkdir(parents=True)
            wrapper=root/'utils/models.sh'
            shutil.copy2(Path(__file__).resolve().parents[2]/'utils/models.sh', wrapper)
            generated=root/'generated'
            published=root/'published'
            (root/'cad/utils/web-library.py').write_text('from pathlib import Path\nPath('+repr(str(generated))+').touch()\n')
            (root/'cad/utils/deploy/catalog.sh').write_text('printf "%s" "$CATALOG" > "'+str(published)+'"\n')
            custom=root/'custom stage'
            result=subprocess.run(['bash',str(wrapper),'--outdir',str(custom),'--push'],capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertTrue(generated.is_file())
            self.assertEqual(published.read_text(),str(custom/'catalog.json'))
            generated.unlink(); published.unlink()
            result=subprocess.run(['bash',str(wrapper),'--push','--help'],capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertFalse(generated.exists())
            self.assertFalse(published.exists())

    def test_catalog_follows_assets_and_stops_when_transfer_fails(self):
        for fail in (False, True):
            with self.subTest(fail=fail), tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp)
                (root/'utils/deploy').mkdir(parents=True)
                script=root/'utils/deploy/catalog.sh'
                shutil.copy2(Path(__file__).parent/'deploy/catalog.sh',script)
                (root/'.vscode').mkdir()
                (root/'.vscode/sftp.json').write_text(json.dumps({'host':'example.invalid','port':22,'username':'test','remotePath':'/web/models'}))
                stage=root/'_work/site-models';stage.mkdir(parents=True)
                (stage/'model.glb').write_bytes(b'geometry')
                (stage/'catalog.json').write_text(json.dumps({'schema':1,'models':[{'views':[{'file':'model.glb'}],'downloads':[]}]}))
                bin_dir=root/'bin';bin_dir.mkdir()
                (bin_dir/'jq').write_text('#!/usr/bin/env python3\nimport json,sys\nprint(json.load(open(sys.argv[3]))[sys.argv[2][1:]])\n')
                calls=root/'calls.jsonl'
                (bin_dir/'rsync').write_text('#!/usr/bin/env python3\nimport json,sys\nwith open('+repr(str(calls))+',"a") as f:f.write(json.dumps(sys.argv[1:])+"\\n")\n'+('sys.exit(23)\n' if fail else ''))
                for p in bin_dir.iterdir():p.chmod(0o755)
                identity=root/'identity with spaces'
                identity.write_text('fixture identity')
                result=subprocess.run(['bash',str(script)],env={**os.environ,'PATH':str(bin_dir)+os.pathsep+os.environ['PATH'],'SSH_KEY_PATH':str(identity)},capture_output=True,text=True)
                rows=[json.loads(s) for s in calls.read_text().splitlines()]
                self.assertEqual(result.returncode,23 if fail else 0,result.stderr)
                self.assertEqual(len(rows),1 if fail else 2)
                self.assertIn(str(stage/'model.glb'),rows[0])
                transport=shlex.split(rows[0][rows[0].index('-e')+1])
                self.assertEqual(transport[transport.index('-i')+1],str(identity))
                self.assertIn('BatchMode=yes',transport)
                self.assertNotIn(str(stage/'catalog.json'),rows[0])
                if not fail:self.assertIn(str(stage/'catalog.json'),rows[1])
                self.assertTrue(all('--delete' not in args for args in rows))


if __name__=='__main__':unittest.main()
