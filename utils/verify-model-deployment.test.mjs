import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, writeFile, rm, symlink, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { verifyBuild, verifyCatalogFiles, verifyPublicModels } from './verify-model-deployment.mjs';

const digest = data => createHash('sha256').update(data).digest('hex');
async function fixture(t) {
  const root = await mkdtemp(join(tmpdir(), 'model-release-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const items = [];
  for (const name of ['part with +.stl', 'assembly.glb']) {
    const data = Buffer.from(name);
    await writeFile(join(root, name), data);
    items.push({ file: name, format: name.endsWith('.glb') ? 'glb' : 'stl', bytes: data.length, sha256: digest(data) });
  }
  const catalog = { schema: 1, models: [{ id: 'fixture', has_scad: true, views: items, downloads: items }] };
  const path = join(root, 'catalog.json');
  await writeFile(path, JSON.stringify(catalog));
  return { root, path, catalog, items };
}

test('catalog checks the expected release and all selected files', async t => {
  const f = await fixture(t);
  assert.deepEqual(await verifyCatalogFiles(f.path, digest(await readFile(f.path))), { models: 1, files: 2 });
  await assert.rejects(verifyCatalogFiles(f.path, 'wrong-release'), /differs/);
  await rm(join(f.root, f.items[0].file));
  await assert.rejects(verifyCatalogFiles(f.path), /ENOENT/);
});

test('catalog rejects incomplete files and links outside the model mount', async t => {
  const f = await fixture(t);
  const item = f.items[0];
  await writeFile(join(f.root, item.file), 'short');
  await assert.rejects(verifyCatalogFiles(f.path), /incomplete/);
  await rm(join(f.root, item.file));
  const outside = await mkdtemp(join(tmpdir(), 'outside-release-'));
  t.after(() => rm(outside, { recursive: true, force: true }));
  await writeFile(join(outside, 'file'), Buffer.alloc(item.bytes));
  await symlink(join(outside, 'file'), join(f.root, item.file));
  await assert.rejects(verifyCatalogFiles(f.path), /escapes/);
});

test('catalog rejects unsafe paths before accessing them', async t => {
  const f = await fixture(t);
  for (const file of ['../outside.stl', 'folder/file.stl', 'folder\\file.stl', '.hidden', 'bad\0name', 'catalog.json']) {
    f.catalog.models[0].views = [{ file }];
    await writeFile(f.path, JSON.stringify(f.catalog));
    await assert.rejects(verifyCatalogFiles(f.path), /Unsafe/);
  }
});

test('build verification catches missing copied scripts and environment maps', async t => {
  const { root } = await fixture(t);
  const html = '<link rel="manifest" href="/site.webmanifest"><link rel="stylesheet" href="/assets/main.css"><script src="/assets/main.js"></script>';
  await writeFile(join(root, 'index.html'), html);
  const names = ['config.js', 'logger.js', 'printer.js', 'stream.js', 'auth.js', 'site.webmanifest', 'assets/main.css', 'assets/main.js', ...['posx', 'negx', 'posy', 'negy', 'posz', 'negz'].map(face => `images/envmaps/fishermans_bastion/${face}.jpg`)];
  for (const name of names) {
    await mkdir(join(root, name, '..'), { recursive: true });
    await writeFile(join(root, name), 'fixture');
  }
  assert.equal((await verifyBuild(root)).artifacts, names.length + 1);
  await rm(join(root, 'auth.js'));
  await assert.rejects(verifyBuild(root), /ENOENT/);
  await writeFile(join(root, 'auth.js'), 'fixture');
  await rm(join(root, names.at(-1)));
  await assert.rejects(verifyBuild(root), /ENOENT/);
});

async function httpFixture(t) {
  const f = await fixture(t);
  const state = { mode: 'ok' };
  const requests = [];
  const server = createServer(async (req, res) => {
    requests.push([req.method, req.url]);
    if (req.url === '/models' || req.url === '/models/') {
      res.writeHead(200, { 'Content-Type': state.mode === 'bad-page' ? 'application/json' : 'text/html' });
      return res.end('page');
    }
    if (req.url === '/models/catalog.json') {
      res.writeHead(state.mode === 'unavailable' ? 503 : 200, { 'Content-Type': 'application/json' });
      return res.end(JSON.stringify(state.mode === 'empty' ? { schema: 1, models: [] } : f.catalog));
    }
    const name = decodeURIComponent(req.url.slice('/models/'.length));
    const item = f.items.find(item => item.file === name);
    if (!item) { res.writeHead(404); return res.end(); }
    if (state.mode === 'redirect') { res.writeHead(302, { Location: '/models' }); return res.end(); }
    let data = await readFile(join(f.root, name));
    if (state.mode === 'truncated') data = data.subarray(1);
    if (state.mode === 'wrong-bytes') data = Buffer.alloc(data.length);
    res.writeHead(200, { 'Content-Type': state.mode === 'html-model' ? 'text/html' : item.format === 'glb' ? 'model/gltf-binary' : 'model/stl' });
    res.end(data);
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }));
  return { state, requests, url: `http://127.0.0.1:${server.address().port}` };
}

test('HTTP verification checks model pages, catalog, and actual STL/GLB bytes', async t => {
  const f = await httpFixture(t);
  assert.deepEqual(await verifyPublicModels(f.url), { visibleModels: 1, formats: ['stl', 'glb'] });
  assert(f.requests.some(([method, path]) => method === 'GET' && path.endsWith('.glb')));
  assert(f.requests.some(([method, path]) => method === 'GET' && path.includes('%2B.stl')));
});

test('HTTP verification refuses catalog outages, false HTML successes and corrupt downloads', async t => {
  const f = await httpFixture(t);
  for (const [mode, error] of [['unavailable', /HTTP 503/], ['empty', /no eligible models/], ['bad-page', /model page/], ['html-model', /content type/], ['truncated', /incomplete/], ['wrong-bytes', /wrong bytes/], ['redirect', /fetch failed/]]) {
    f.state.mode = mode;
    await assert.rejects(verifyPublicModels(f.url), error);
  }
});
