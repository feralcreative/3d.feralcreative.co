#!/usr/bin/env python3
"""Exercise the private production entrypoint with fake transports and containers."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parent / 'deploy/prod.sh'


@unittest.skipUnless(SOURCE.is_file(), 'Private production entrypoint is not configured')
class ProductionDeploy(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='prod-deploy-fixture-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / 'repo with spaces'
        (self.root / 'utils/deploy').mkdir(parents=True)
        shutil.copy2(SOURCE, self.root / 'utils/deploy/prod.sh')
        self.bin = Path(self.tmp.name) / 'bin'
        self.bin.mkdir()
        self.log = Path(self.tmp.name) / 'calls.jsonl'
        source = SOURCE.read_text()
        settings = {key: re.search(r'^' + key + r'="([^"]+)"$', source, re.M).group(1) for key in ['NAS_HOST', 'NAS_USER', 'NAS_SSH_PORT', 'NAS_DEPLOY_PATH']}
        (self.root / 'cad/.vscode').mkdir(parents=True)
        (self.root / 'cad/.vscode/sftp.json').write_text(json.dumps({'host': settings['NAS_HOST'], 'username': settings['NAS_USER'], 'port': int(settings['NAS_SSH_PORT']), 'remotePath': settings['NAS_DEPLOY_PATH'].removeprefix('/volume1') + '/public/models'}))
        (self.root / 'docker-compose.yml').write_text('services:\n  app:\n    volumes:\n      - ' + settings['NAS_DEPLOY_PATH'] + '/public/models:/app/dist/models\n')
        (self.root / 'cad/utils/deploy').mkdir(parents=True)
        for name, tool in [('utils/models.sh', 'models'), ('cad/utils/deploy/catalog.sh', 'publish')]:
            (self.root / name).write_text('#!/usr/bin/env bash\npython3 "$FAKE_BIN/stub.py" ' + tool + ' "$@"\n')
        for name in ['config.js', 'printer-proxy-server.js', 'package-lock.json', 'utils/verify-model-deployment.mjs']:
            (self.root / name).write_text('fixture')
        stage = self.root / 'cad/_work/site-models'
        stage.mkdir(parents=True)
        items = []
        for name in ['part.stl', 'assembly.glb']:
            data = name.encode()
            (stage / name).write_bytes(data)
            items.append({'file': name, 'format': name.split('.')[-1], 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
        (stage / 'catalog.json').write_text(json.dumps({'schema': 1, 'models': [{'id': 'fixture', 'has_scad': True, 'views': items, 'downloads': items}]}))
        (stage / 'report.json').write_text('{"failures": []}')
        stub = self.bin / 'stub.py'
        stub.write_text('''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
tool=Path(sys.argv[0]).name
args=sys.argv[1:]
if tool=='stub.py':tool,args=args[0],args[1:]
with open(os.environ['FAKE_LOG'],'a') as f:f.write(json.dumps({'tool':tool,'args':args,'key':os.environ.get('SSH_KEY_PATH','')})+'\\n')
if tool=='git':
 if args[:2]==['rev-parse','--short']:print('fixture-sha')
 elif args[:2]==['rev-parse','--abbrev-ref']:print(os.environ.get('BRANCH','main'))
 elif args[:2]==['status','--porcelain']:print(os.environ.get('DIRTY',''),end='')
if tool=='docker':
 if args[0]=='build' and os.environ.get('FAIL_BUILD'):sys.exit(21)
 if args[0]=='save' and os.environ.get('FAIL_SAVE'):sys.exit(27)
 if args[0]=='run' and os.environ.get('FAIL_ARTIFACTS'):sys.exit(28)
 if args[0]=='save':sys.stdout.buffer.write(b'fixture image')
if tool=='ssh':
 command=args[-1]
 if 'cat >' in command:sys.stdin.buffer.read()
 if 'State.Running' in command:print('true')
 elif 'image inspect' in command:print('sha256:fixture')
 elif '{{.Image}}' in command:print('sha256:wrong' if os.environ.get('WRONG_IMAGE') else 'sha256:fixture')
 if '--files ' in command and os.environ.get('FAIL_FILES'):sys.exit(22)
 if '--http ' in command and os.environ.get('FAIL_ORIGIN'):sys.exit(23)
if tool=='publish' and os.environ.get('FAIL_PUBLISH'):sys.exit(24)
if tool=='node' and '--http' in args and os.environ.get('FAIL_PUBLIC'):sys.exit(25)
if tool=='curl':
 if os.environ.get('FAIL_PURGE'):sys.exit(26)
 print('{"success":true}')
''')
        stub.chmod(0o755)
        for name in ['git', 'docker', 'ssh', 'ssh-add', 'rsync', 'jq', 'curl', 'node', 'sleep']:
            (self.bin / name).symlink_to(stub)
        self.key = Path(self.tmp.name) / 'identity with spaces'
        self.key.write_text('fixture identity')
        self.env = {**os.environ, 'PATH': str(self.bin) + os.pathsep + os.environ['PATH'], 'FAKE_BIN': str(self.bin), 'FAKE_LOG': str(self.log), 'SSH_KEY_PATH': str(self.key), 'CLOUDFLARE_API_TOKEN': '', 'CLOUDFLARE_ZONE_ID': ''}

    def run_deploy(self, args=('--force',), answer='yes\n', **env):
        result = subprocess.run(['bash', str(self.root / 'utils/deploy/prod.sh'), *args], input=answer, text=True, capture_output=True, cwd=self.tmp.name, env={**self.env, **env}, timeout=20)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []
        return result, calls

    def test_help_and_unknown_option_have_no_side_effects(self):
        for args, status in [(('--help',), 0), (('--typo',), 64)]:
            result, calls = self.run_deploy(args)
            self.assertEqual(result.returncode, status, result.stderr)
            self.assertEqual(calls, [])

    def test_dry_run_is_offline_and_does_not_build_or_load_environment(self):
        (self.root / '.env').write_text('touch "' + str(Path(self.tmp.name) / 'env-ran') + '"\n')
        result, calls = self.run_deploy(('--dry-run', '--force'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual({c['tool'] for c in calls}, {'git'})
        self.assertFalse((Path(self.tmp.name) / 'env-ran').exists())
        self.assertIn('DRY RUN', result.stdout)

    def test_force_does_not_bypass_confirmation(self):
        result, calls = self.run_deploy(answer='no\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual({c['tool'] for c in calls}, {'git'})

    def test_dirty_tree_and_wrong_branch_block_without_force(self):
        for env in [{'DIRTY': ' M file'}, {'BRANCH': 'feature'}]:
            result, calls = self.run_deploy((), **env)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('ssh', {c['tool'] for c in calls})

    def test_wrong_model_target_blocks_even_with_force(self):
        path = self.root / 'cad/.vscode/sftp.json'
        data = json.loads(path.read_text()); data['remotePath'] += '/wrong'; path.write_text(json.dumps(data))
        result, calls = self.run_deploy()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual({c['tool'] for c in calls}, {'git'})

    def test_release_publishes_models_before_container_and_checks_origin_and_public(self):
        (self.root / '.env').write_text("CLOUDFLARE_API_TOKEN='fixture token with spaces'\nCLOUDFLARE_ZONE_ID=fixture-zone\n")
        result, calls = self.run_deploy()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(next(c for c in calls if c['tool'] == 'models')['args'], ['--render-colours'])
        model = next(i for i, c in enumerate(calls) if c['tool'] == 'models')
        build = next(i for i, c in enumerate(calls) if c['tool'] == 'docker' and c['args'][0] == 'build')
        first_ssh = next(i for i, c in enumerate(calls) if c['tool'] == 'ssh')
        publish = next(i for i, c in enumerate(calls) if c['tool'] == 'publish')
        restart = next(i for i, c in enumerate(calls) if c['tool'] == 'ssh' and 'docker-compose up' in c['args'][-1])
        files = next(i for i, c in enumerate(calls) if c['tool'] == 'ssh' and '--files ' in c['args'][-1])
        origin = next(i for i, c in enumerate(calls) if c['tool'] == 'ssh' and '--http ' in c['args'][-1])
        public = next(i for i, c in enumerate(calls) if c['tool'] == 'node')
        purge = next(i for i, c in enumerate(calls) if c['tool'] == 'curl')
        self.assertTrue(model < build < first_ssh < publish < restart < files < origin < public < purge)
        self.assertEqual(calls[publish]['key'], str(self.key))
        self.assertTrue(any(c['tool'] == 'ssh' and str(self.key) in c['args'] for c in calls))
        self.assertFalse(any(c['tool'] == 'ssh' and 'docker-compose down' in c['args'][-1] for c in calls))
        self.assertIn('Status: catalog and model loading verified.', result.stdout)

    def test_failed_build_does_not_contact_production(self):
        for flag in ['FAIL_BUILD', 'FAIL_SAVE', 'FAIL_ARTIFACTS']:
            with self.subTest(flag=flag):
                if self.log.exists(): self.log.unlink()
                result, calls = self.run_deploy(**{flag: '1'})
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('ssh', {c['tool'] for c in calls})

    def test_failed_model_publication_does_not_replace_container(self):
        result, calls = self.run_deploy(FAIL_PUBLISH='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(c['tool'] == 'ssh' and 'docker-compose up' in c['args'][-1] for c in calls))
        self.assertNotIn('Status: catalog and model loading verified.', result.stdout)

    def test_missing_asset_or_failed_presentation_stops_before_build(self):
        for variant in ['missing', 'hash', 'presentation']:
            with self.subTest(variant=variant):
                if variant == 'missing': (self.root / 'cad/_work/site-models/part.stl').unlink()
                elif variant == 'hash':
                    (self.root / 'cad/_work/site-models/part.stl').write_bytes(b'bad.stl!')
                else:
                    (self.root / 'cad/_work/site-models/part.stl').write_bytes(b'part.stl')
                    (self.root / 'cad/_work/site-models/report.json').write_text('{"failures":[{"view":"assembled"}]}')
                if self.log.exists(): self.log.unlink()
                result, calls = self.run_deploy()
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('docker', {c['tool'] for c in calls})
                self.assertNotIn('ssh', {c['tool'] for c in calls})

    def test_failed_verification_never_reports_success(self):
        for flag in ['WRONG_IMAGE', 'FAIL_FILES', 'FAIL_ORIGIN', 'FAIL_PUBLIC']:
            with self.subTest(flag=flag):
                if self.log.exists(): self.log.unlink()
                result, calls = self.run_deploy(**{flag: '1'})
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('Status: catalog and model loading verified.', result.stdout)
                self.assertNotIn('curl', {c['tool'] for c in calls})

    def test_cloudflare_failure_is_nonfatal(self):
        result, calls = self.run_deploy(FAIL_PURGE='1', CLOUDFLARE_API_TOKEN='fixture', CLOUDFLARE_ZONE_ID='fixture')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('non-fatal', result.stdout)
        self.assertIn('Status: catalog and model loading verified.', result.stdout)


if __name__ == '__main__':
    unittest.main()
