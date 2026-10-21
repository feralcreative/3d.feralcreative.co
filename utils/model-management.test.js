import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Readable } from 'node:stream';
import { ModelManagement, modelManagementMiddleware, localModelAdmin } from './model-management.js';

const project = id => ({ id, title: id, has_scad: true, category: ['tools'], availability: 'viewable', default_view: 'main', views: [{ id: 'main', file: `${id}.stl` }, { id: 'part', file: `${id}-part.stl` }], downloads: [{ file: `${id}.stl` }], aliases: [`${id}-old`], website: { description: `${id} description`, parts: [{ name: `${id} part` }] } });
async function fixture(t) {
  const root = await mkdtemp(join(tmpdir(), 'model-admin-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const catalogPath = join(root, 'catalog.json');
  await writeFile(catalogPath, JSON.stringify({ schema: 1, models: ['a', 'b', 'c'].map(project) }));
  const options = { catalogPath, statePath: join(root, 'organization.json') };
  return { store: new ModelManagement(options), options };
}
async function call(store, user, { method = 'GET', body, origin = 'https://site.test', host = 'site.test', headers = {}, path = '/model-library/manage' } = {}) {
  const req = Readable.from(body ? [JSON.stringify(body)] : []);
  Object.assign(req, { url: path, method, headers: { host, origin, 'content-type': 'application/json', ...headers } });
  let status, result;
  const res = { writeHead(code) { status = code; }, end(text) { result = text ? JSON.parse(text) : null; } };
  await modelManagementMiddleware(store, () => user)(req, res, () => { throw Error('Unexpected fallthrough'); });
  return { status, result };
}

test('Hide persists across instances, filters files, and can be undone with no source writes', async t => {
  const { store, options } = await fixture(t);
  const before = await readFile(options.catalogPath, 'utf8');
  await store.apply({ revision: 0, action: 'hide', ids: ['a'] });
  const fresh = new ModelManagement(options);
  assert.equal((await fresh.publicCatalog()).models.some(model => model.id === 'a'), false);
  assert.equal(await fresh.fileVisible('a.stl'), false);
  await fresh.apply({ revision: 1, action: 'undo' });
  assert.equal(await fresh.fileVisible('a.stl'), true);
  assert.equal(await readFile(options.catalogPath, 'utf8'), before);
});
test('Move removes selected views/downloads from source and preserves IDs and remaining files', async t => {
  const { store } = await fixture(t);
  await store.apply({ revision: 0, action: 'move', ids: ['a'], files: ['a.stl'], target: 'b' });
  const { catalog } = await store.read();
  const a = catalog.models.find(model => model.id === 'a'), b = catalog.models.find(model => model.id === 'b');
  assert.deepEqual(a.views.map(view => view.file), ['a-part.stl']);
  assert.equal(a.default_view, 'part');
  assert.equal(b.views.filter(view => view.file === 'a.stl').length, 1);
  assert.equal(new Set(b.views.map(view => view.id)).size, b.views.length);
  assert.equal(b.downloads.some(item => item.file === 'a.stl'), true);
});
test('Merge preserves descriptions, supplies, aliases and target identity; undo restores sources', async t => {
  const { store } = await fixture(t);
  await store.apply({ revision: 0, action: 'merge', ids: ['a', 'c'], target: 'b' });
  let { catalog } = await store.read();
  assert.equal(catalog.models.length, 1);
  const b = catalog.models[0];
  assert.equal(b.id, 'b');
  assert.ok(b.aliases.includes('a') && b.aliases.includes('c-old'));
  assert.equal(b.website.parts.length, 3);
  assert.equal(b.website.instructions[0].text, 'a description');
  await store.apply({ revision: 1, action: 'undo' });
  assert.equal((await store.read()).catalog.models.length, 3);
});
test('Split creates a hidden project, retains selected exports and supports publication/category changes', async t => {
  const { store } = await fixture(t);
  await store.apply({ revision: 0, action: 'split', ids: ['a'], files: ['a-part.stl'], title: 'Iteration' });
  const split = (await store.read()).catalog.models.find(model => model.title === 'Iteration');
  assert.equal(split.hidden, true);
  assert.equal(await store.fileVisible('a-part.stl'), false);
  await store.apply({ revision: 1, action: 'show', ids: [split.id] });
  await store.apply({ revision: 2, action: 'category', ids: [split.id], category: 'Trials / Originals' });
  assert.equal(await store.fileVisible('a-part.stl'), true);
  assert.deepEqual((await store.read()).catalog.models.find(model => model.id === split.id).category, ['Trials', 'Originals']);
});
test('Hide individual files removes both preview and download and survives moving to a project', async t => {
  const { store } = await fixture(t);
  await store.apply({ revision: 0, action: 'hide-files', ids: ['a'], files: ['a.stl'] });
  const a = (await store.publicCatalog()).models.find(model => model.id === 'a');
  assert.equal(a.views.some(item => item.file === 'a.stl'), false);
  assert.deepEqual(a.downloads, []);
  assert.equal(await store.fileVisible('a.stl'), false);
  await store.apply({ revision: 1, action: 'move', ids: ['a'], files: ['a.stl'], target: 'b' });
  assert.equal(await store.fileVisible('a.stl'), false);
  await store.apply({ revision: 2, action: 'show-files', ids: ['b'], files: ['a.stl'] });
  assert.equal(await store.fileVisible('a.stl'), true);
});
test('Invalid file ownership, self merge and stale concurrent requests cannot mutate state', async t => {
  const { store } = await fixture(t);
  await assert.rejects(store.apply({ revision: 0, action: 'move', ids: ['a'], files: ['../../secret'], target: 'b' }));
  await assert.rejects(store.apply({ revision: 0, action: 'merge', ids: ['a'], target: 'a' }));
  const results = await Promise.allSettled(['a', 'b'].map(id => store.apply({ revision: 0, action: 'hide', ids: [id] })));
  assert.equal(results.filter(item => item.status === 'fulfilled').length, 1);
  assert.equal(results.find(item => item.status === 'rejected').reason.status, 409);
  assert.equal((await store.read()).state.revision, 1);
});
test('API rejects signed-out, viewer, cross-origin and malformed requests; admin can save', async t => {
  const { store } = await fixture(t);
  const body = { revision: 0, action: 'hide', ids: ['a'] };
  assert.equal((await call(store, null)).status, 401);
  assert.equal((await call(store, { admin: false }, { method: 'POST', body })).status, 403);
  assert.equal((await call(store, { admin: true }, { method: 'POST', body, origin: 'https://evil.test' })).status, 403);
  assert.equal((await call(store, { admin: true }, { method: 'POST', body })).status, 200);
  const publicResult = await call(store, null, { path: '/model-library/catalog' });
  assert.equal(publicResult.result.models.some(model => model.id === 'a'), false);
  const admin = await call(store, { admin: true });
  assert.equal(admin.result.canUndo, true);
  assert.equal(admin.result.catalog.models.find(model => model.id === 'a').hidden, true);
});
test('Local development privileges require both loopback connection and local Host', () => {
  const req = (address, host) => ({ socket: { remoteAddress: address }, headers: { host } });
  assert.equal(localModelAdmin(req('127.0.0.1', '127.0.0.1:5501')).admin, true);
  assert.equal(localModelAdmin(req('192.168.1.10', 'localhost:5501')), null);
  assert.equal(localModelAdmin(req('127.0.0.1', 'attacker.test:5501')), null);
});
test('Legacy aliases obey visibility without returning as loose projects', async t => {
  const { store, options } = await fixture(t);
  await writeFile(join(join(options.catalogPath, '..'), 'a-old.stl'), 'legacy');
  assert.equal((await store.read()).catalog.models.length, 3);
  await store.apply({ revision: 0, action: 'hide', ids: ['a'] });
  assert.equal(await store.fileVisible('a-old.stl'), false);
  assert.equal(await store.fileVisible('A-OLD.3mf'), false);
});
test('Loose STL files can be hidden, merged and undone without resurrection or deleting bytes', async t => {
  const { store, options } = await fixture(t);
  const loosePath = join(join(options.catalogPath, '..'), 'loose.stl');
  await writeFile(loosePath, 'mesh');
  let loose = (await store.read()).catalog.models.find(model => model.title === 'loose');
  assert.ok(loose);
  await store.apply({ revision: 0, action: 'hide', ids: [loose.id] });
  assert.equal(await store.fileVisible('loose.stl'), false);
  await store.apply({ revision: 1, action: 'merge', ids: [loose.id], target: 'b' });
  assert.equal((await store.read()).catalog.models.some(model => model.id === loose.id), false);
  await store.apply({ revision: 2, action: 'undo' });
  loose = (await store.read()).catalog.models.find(model => model.id === loose.id);
  assert.equal(loose.hidden, true);
  assert.equal(await readFile(loosePath, 'utf8'), 'mesh');
});
test('Missing or corrupt persistent state fails closed instead of publishing hidden models', async t => {
  const { store, options } = await fixture(t);
  await writeFile(options.statePath, '{invalid');
  const result = await call(store, null, { path: '/model-library/catalog' });
  assert.equal(result.status, 503);
  await assert.rejects(store.fileVisible('a.stl'));
});

test('Hidden file URLs reject non-admins including legacy names; HEAD has no response body', async t => {
  const { store } = await fixture(t);
  await store.apply({ revision: 0, action: 'hide', ids: ['a'] });
  const options = { path: '/model-library/file-access', headers: { 'x-model-uri': '/models/a-old.stl?v=123' } };
  assert.equal((await call(store, null, options)).status, 403);
  assert.equal((await call(store, { admin: false }, options)).status, 403);
  assert.equal((await call(store, { admin: true }, options)).status, 200);
  const head = await call(store, null, { path: '/model-library/catalog', method: 'HEAD' });
  assert.equal(head.status, 200);
  assert.equal(head.result, null);
});

test('SCAD eligibility blocks public inventory, raw URLs and publishing without removing admin records', async t => {
  const { store, options } = await fixture(t);
  const catalog = JSON.parse(await readFile(options.catalogPath, 'utf8'));
  catalog.models[0].has_scad = false;
  delete catalog.models[2].has_scad;
  await writeFile(options.catalogPath, JSON.stringify(catalog));
  await writeFile(join(options.catalogPath, '..', 'loose.stl'), 'mesh');
  assert.deepEqual((await store.publicCatalog()).models.map(model => model.id), ['b']);
  assert.equal(await store.fileVisible('a.stl'), false);
  assert.equal(await store.fileVisible('loose.stl'), false);
  assert.equal(await store.fileVisible('unregistered.stl'), false);
  const admin = await call(store, { admin: true });
  assert.equal(admin.result.catalog.models.length, 4);
  await assert.rejects(store.apply({ revision: 0, action: 'show', ids: ['a'] }), /SCAD source is required/);
  await assert.rejects(store.apply({ revision: 0, action: 'show-files', ids: ['a'], files: ['a.stl'] }), /SCAD source is required/);
});
test('Saved overrides cannot invent a SCAD source and merged files retain their source eligibility', async t => {
  const { store, options } = await fixture(t);
  const catalog = JSON.parse(await readFile(options.catalogPath, 'utf8'));
  catalog.models[0].has_scad = false;
  await writeFile(options.catalogPath, JSON.stringify(catalog));
  await writeFile(options.statePath, JSON.stringify({ revision: 0, overrides: { a: { ...project('a'), has_scad: true } } }));
  assert.equal((await store.read()).catalog.models.find(model => model.id === 'a').has_scad, false);
  await store.apply({ revision: 0, action: 'merge', ids: ['a'], target: 'b' });
  assert.equal((await store.read()).catalog.models.find(model => model.id === 'b').has_scad, false);
  assert.equal(await store.fileVisible('a.stl'), false);
  await assert.rejects(store.apply({ revision: 1, action: 'show', ids: ['b'] }), /SCAD source is required/);
  catalog.models[0].has_scad = true;
  await writeFile(options.catalogPath, JSON.stringify(catalog));
  assert.equal((await store.read()).catalog.models.find(model => model.id === 'b').has_scad, true);
});
