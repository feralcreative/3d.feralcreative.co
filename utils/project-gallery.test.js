import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFile } from 'node:fs/promises';
import { normalizeProject, productLink, safeProjectUrl, renderProjectContent } from '../project-content.js';

class Element {
  constructor() { this.style = {}; this.dataset = {}; this.children = []; this.listeners = {}; this.value = ''; this.textContent = ''; this.isConnected = true; }
  appendChild(child) { this.children.push(child); return child; }
  append(...children) { this.children.push(...children); }
  replaceChildren(...children) { this.children = children; }
  after() {}
  setAttribute(name, value) { this[name] = value; }
  addEventListener(name, handler) { this.listeners[name] = handler; }
  get childElementCount() { return this.children.length; }
}
const documentFixture = () => {
  const nodes = new Map();
  const get = (id) => { if (!nodes.has(id)) nodes.set(id, new Element()); return nodes.get(id); };
  return { readyState: 'loading', getElementById: get, querySelector: get, createElement: () => new Element(), addEventListener() {} };
};
const tick = () => new Promise((resolve) => setImmediate(resolve));
const moduleSource = async (file) => (await readFile(new URL(file, import.meta.url), 'utf8')).replace(/^import .*?;\n/gm, '');

async function libraryFixture(rawModels, listing = [], failListing = false) {
  const document = documentFixture();
  const window = { location: new URL('https://fixture.test/models'), addEventListener() {}, formatModelBytes: () => '1 KB' };
  const context = vm.createContext({ window, document, URL, URLSearchParams, AbortController, normalizeProject,
    ModelAdmin: class { setUser() {} },
    modelPreviews: { create: () => new Element(), prune() {} }, console,
    fetch: async () => { if (failListing) throw new Error('offline'); return { ok: true, json: async () => listing }; },
  });
  vm.runInContext(await moduleSource('../viewer-3d.js'), context);
  const catalog = window.modelCatalog;
  catalog.index({ schema: 1, models: rawModels });
  catalog.load = async () => catalog;
  vm.runInContext(await moduleSource('../models.js'), context);
  window.modelLibrary.setAuthenticated(true);
  await tick();
  return { library: window.modelLibrary, catalog, document };
}
const viewable = (id, website) => ({ id, title: id, has_scad: true, availability: 'viewable', category: ['tools'],
  views: [{ id: 'main', file: `${id}.stl`, format: 'stl' }], downloads: [], website });

test('Source-only, unsupported, withheld and internal-placeholder projects are not listed', async () => {
  const { library, catalog } = await libraryFixture([
    viewable('printable'), viewable('no-model-loaded'),
    { id: 'sketchup', availability: 'no-mesh', downloads: [{ file: 'source.skp' }] },
    { id: 'step-only', availability: 'viewable', views: [{ id: 'main', file: 'part.step', format: 'step' }] },
    { ...viewable('withheld'), availability: 'withheld' },
  ]);
  assert.deepEqual(Array.from(library.models, (entry) => entry.model.id), ['printable']);
  assert(catalog.resolve('sketchup'), 'Hidden models remain resolvable through old links');
});

test('Project descriptions and supply names are searchable', async () => {
  const { library, document } = await libraryFixture([viewable('pumpkin', { description: 'Fence decoration', parts: [{ name: 'Steel disc' }] })]);
  document.getElementById('model-search').value = 'steel disc'; library.render();
  assert.equal(document.getElementById('models-list').children.length, 1);
  document.getElementById('model-search').value = 'not found'; library.render();
  assert.equal(document.getElementById('models-status').textContent, 'No models match your search.');
});

test('Catalog projects remain usable when unmanaged-file listing is offline', async () => {
  const { library, document } = await libraryFixture([viewable('one')], [], true);
  assert.equal(library.models.length, 1);
  assert.doesNotMatch(document.getElementById('models-status').textContent, /Other files/);
});

test('Empty source-only library has an empty state and sign-out removes cards', async () => {
  const { library, document } = await libraryFixture([{ id: 'skp', availability: 'no-mesh' }]);
  assert.equal(document.getElementById('models-status').textContent, 'No models are available yet.');
  library.setAuthenticated(false);
  assert.equal(document.getElementById('models-page').style.display, 'none');
  assert.equal(document.getElementById('models-list').children.length, 0);
});

test('Unmanaged STL files are never listed without a verified SCAD source', async () => {
  const { library } = await libraryFixture([viewable('one')], [
    { type: 'file', name: 'one.stl' }, { type: 'file', name: 'loose.stl' },
    { type: 'file', name: 'source.skp' }, { type: 'file', name: 'no-model-loaded.stl' },
  ]);
  assert.equal(library.list.children.length, 1);
  assert.equal(library.models[0].model.id, 'one');
});

test('Amazon tracking tags are optional and added only to Amazon.com URLs', () => {
  assert.equal(new URL(productLink('https://www.amazon.com/dp/EXAMPLE').href).searchParams.has('tag'), false);
  const tagged = productLink('https://www.amazon.com/dp/EXAMPLE?tag=old&th=1', 'example-20');
  assert.equal(new URL(tagged.href).searchParams.get('tag'), 'example-20');
  assert.equal(new URL(tagged.href).searchParams.get('th'), '1'); assert.equal(tagged.affiliate, true);
  assert.equal(productLink('https://notamazon.com/dp/EXAMPLE', 'example-20').affiliate, false);
  assert.equal(productLink('https://amazon.com.example.org/dp/EXAMPLE', 'example-20').amazon, false);
  assert.equal(productLink('https://amzn.to/example', 'example-20').affiliate, false);
});

test('Unsafe URLs and absent product links do not become links', () => {
  assert.equal(productLink('javascript:alert(1)', 'example-20'), null);
  assert.equal(safeProjectUrl('https://user:password@example.test'), null);
  const project = normalizeProject({ parts: [{ name: 'Disc', url: '' }, { name: 'Magnet', url: 'javascript:bad' }] });
  assert.equal(project.parts.length, 2); assert(project.parts.every((part) => !part.url));
});

test('Authored text renders as text and affiliate disclosure appears only for tagged links', () => {
  const previous = globalThis.document; globalThis.document = documentFixture();
  try {
    const container = new Element();
    const model = { website: normalizeProject({ description: '<script>not HTML</script>', parts: [{ name: 'Disc', url: 'https://www.amazon.com/dp/EXAMPLE' }] }) };
    renderProjectContent(container, model);
    assert.equal(container.children[0].children[1].textContent, '<script>not HTML</script>');
    assert.equal(container.children[1].children.length, 2);
    renderProjectContent(container, model, { amazon_affiliate_tag: 'example-20' });
    assert.match(container.children[1].children.at(-1).textContent, /Amazon Associate/);
    assert.equal(container.children[1].children[1].children[0].children.at(-1).rel, 'sponsored noopener noreferrer');
  } finally { globalThis.document = previous; }
});

test('Large meshes do not download automatically; modal previews have priority', async () => {
  let observer;
  const context = vm.createContext({ document: documentFixture(), window: { location: new URL('https://fixture.test/models') },
    URL, Response, setTimeout, clearTimeout, IntersectionObserver: class {
      constructor(callback) { observer = callback; } observe() {} unobserve() {} disconnect() {}
    },
  });
  const source = (await readFile(new URL('../model-previews.js', import.meta.url), 'utf8')).replace('export const modelPreviews =', 'globalThis.previews =');
  vm.runInContext(source, context);
  const previews = context.previews; const calls = [];
  previews.cache = async () => null; previews.render = async (view) => { calls.push(view.file); return 'data:image/png;base64,fixture'; };
  previews.setEnabled(true);
  const large = previews.create({ file: 'huge.stl', bytes: 30 * 1024 * 1024 }, 'Huge');
  observer([{ target: large, isIntersecting: true }]); await tick();
  assert.equal(calls.length, 0); assert.equal(large.dataset.state, 'large');
  previews.setModalOpen(true);
  const gallery = previews.create({ file: 'gallery.stl' }, 'Gallery');
  const part = previews.create({ file: 'part.stl' }, 'Part', true);
  observer([{ target: gallery, isIntersecting: true }, { target: part, isIntersecting: true }]); await tick();
  assert.deepEqual(calls, ['part.stl']);
  previews.setModalOpen(false); await tick(); assert.deepEqual(calls, ['part.stl', 'gallery.stl']);
});

test('Gallery excludes mesh-only and old catalog entries without SCAD eligibility', async () => {
  const valid = viewable('authored');
  const meshOnly = { ...viewable('mesh-only'), has_scad: false };
  const oldEntry = viewable('unknown-source'); delete oldEntry.has_scad;
  const { library } = await libraryFixture([valid, meshOnly, oldEntry]);
  assert.deepEqual(Array.from(library.models, item => item.model.id), ['authored']);
});
