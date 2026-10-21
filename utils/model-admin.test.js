import test from 'node:test';
import assert from 'node:assert/strict';
import { ModelAdmin } from '../model-admin.js';
class Element {
  constructor(tag) { this.tag = tag; this.children = []; this.listeners = {}; this.value = ''; this.parentElement = { before() {} }; }
  append(...children) { this.children.push(...children); if (this.tag === 'select' && !this.value) this.value = children[0]?.value || ''; }
  replaceChildren(...children) { this.children = children; }
  setAttribute(name, value) { this[name] = value; }
  addEventListener(event, handler) { this.listeners[event] = handler; }
}
function fixture() {
  global.document = { createElement: tag => new Element(tag), createTextNode: value => ({ textContent: value }) };
  let refreshes = 0;
  const admin = new ModelAdmin({ search: new Element('input'), async load() { refreshes++; } });
  return { admin, refreshes: () => refreshes };
}
const inventory = { revision: 1, canUndo: true, catalog: { models: [{ id: 'a', title: 'A', has_scad: true, category: ['test'], views: [{ id: 'main', file: 'a.stl' }], downloads: [], hidden: true }] } };
test('Management controls stay hidden for signed-out/viewer accounts; sign-out clears private inventory', async () => {
  const { admin } = fixture();
  assert.equal(admin.button.hidden, true);
  admin.setUser({ admin: false });
  assert.equal(admin.button.hidden, true);
  admin.setUser({ admin: true });
  global.fetch = async () => ({ ok: true, json: async () => inventory });
  await admin.load();
  assert.equal(admin.button.hidden, false);
  assert.equal(admin.models.length, 1);
  admin.selected.add('a');
  admin.setUser(null);
  assert.equal(admin.button.hidden, true);
  assert.equal(admin.panel.hidden, true);
  assert.equal(admin.models.length, 0);
  assert.equal(admin.projects.children.length, 0);
  assert.equal(admin.selected.size, 0);
});
test('Denied and offline management requests display errors without enabling writes', async () => {
  const { admin } = fixture(); admin.setUser({ admin: true });
  global.fetch = async () => ({ ok: false, json: async () => ({ error: 'Admin access required.' }) });
  await admin.load();
  assert.equal(admin.message.textContent, 'Admin access required.');
  assert.equal(admin.submit.disabled, true);
  global.fetch = async () => { throw Error('offline'); };
  await admin.load();
  assert.equal(admin.message.textContent, 'offline');
  assert.equal(admin.submit.disabled, true);
});
test('A pending management response cannot repopulate inventory after sign-out', async () => {
  const { admin } = fixture(); admin.setUser({ admin: true });
  let complete;
  global.fetch = () => new Promise(resolve => { complete = resolve; });
  const pending = admin.load();
  admin.setUser(null);
  complete({ ok: true, json: async () => inventory });
  await pending;
  assert.equal(admin.models.length, 0);
  assert.equal(admin.projects.children.length, 0);
});
test('Bulk selection follows filtered projects and file operations require file selection', async () => {
  const { admin } = fixture(); admin.setUser({ admin: true });
  global.fetch = async () => ({ ok: true, json: async () => inventory });
  await admin.load();
  admin.search.value = 'hidden';
  assert.deepEqual(admin.filtered().map(model => model.id), ['a']);
  admin.search.value = 'absent';
  assert.equal(admin.filtered().length, 0);
  admin.selected.add('a');
  admin.action.value = 'move'; admin.updateAction();
  assert.equal(admin.submit.disabled, true);
  admin.files.add('a\na.stl'); admin.updateAction();
  assert.equal(admin.submit.disabled, false);
});
