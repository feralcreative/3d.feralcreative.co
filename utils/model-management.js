import { readFile, writeFile, mkdir, rename, readdir, stat } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { randomUUID } from 'node:crypto';

const files = (model) => [...new Set([...(model.views || []), ...(model.downloads || [])].map(item => item.file))];
const stem = name => name.toLowerCase().replace(/\.[^.]+$/, '');
const claims = (model, name) => [...files(model), ...(model.aliases || []), ...(model.downloads || []).map(item => item.export).filter(Boolean)].some(alias => alias.toLowerCase() === name.toLowerCase() || stem(alias) === stem(name));
const fail = (message, status = 400) => { throw Object.assign(new Error(message), { status }); };
const plain = value => typeof value === 'string' && value.trim().length > 0 && value.length <= 200;
export class ModelManagement {
  constructor({ catalogPath, statePath, extraDirectories = [] }) {
    this.catalogPath = catalogPath;
    this.statePath = statePath;
    this.extraDirectories = extraDirectories;
    this.queue = Promise.resolve();
  }
  async read() {
    const catalog = JSON.parse(await readFile(this.catalogPath, 'utf8'));
    let state = { revision: 0, overrides: {} };
    try { state = JSON.parse(await readFile(this.statePath, 'utf8')); }
    catch (error) { if (error.code !== 'ENOENT') throw error; }
    const models = new Map(catalog.models.map(model => [model.id, model]));
    for (const [id, model] of Object.entries(state.overrides)) {
      if (model === null) models.delete(id); else models.set(id, model);
    }
    // Include loose STLs in management too, with stable IDs and no file moves.
    const known = [...catalog.models, ...models.values()];
    const claimed = new Set(known.flatMap(files));
    for (const directory of [dirname(this.catalogPath), ...this.extraDirectories]) {
      let names;
      try { names = await readdir(directory); } catch (error) { if (error.code === 'ENOENT') continue; throw error; }
      for (const name of names) {
        if (!/\.stl$/i.test(name) || name.startsWith('.') || name === 'no-model-loaded.stl' || claimed.has(name) || known.some(model => claims(model, name))) continue;
        let info;
        try { info = await stat(join(directory, name)); } catch { continue; }
        if (!info.isFile()) continue;
        const id = `file-${Buffer.from(name).toString('base64url')}`;
        if (!(id in state.overrides)) models.set(id, { id, title: name.replace(/\.stl$/i, ''), category: ['Other files'], availability: 'viewable', default_view: 'main', views: [{ id: 'main', file: name, format: 'stl', up_axis: 'Z', bytes: info.size }], downloads: [{ file: name, format: 'stl', bytes: info.size }], aliases: [name], website: {} });
        claimed.add(name);
      }
    }
    // Eligibility comes from current authored sources, never a saved admin flag.
    const sourceModels = new Map(catalog.models.map(model => [model.id, model]));
    for (const model of models.values()) {
      const sources = model.scad_source_ids || [model.id];
      model.has_scad = sources.length > 0 && sources.every(id => sourceModels.get(id)?.has_scad === true);
    }
    return { catalog: { ...catalog, models: [...models.values()] }, state };
  }
  async publicCatalog() {
    const { catalog } = await this.read();
    return { ...catalog, models: catalog.models.filter(model => !model.hidden && model.has_scad === true).map(model => {
      const excluded = new Set(model.excluded_files || []);
      return { ...model, views: (model.views || []).filter(item => !excluded.has(item.file)), downloads: (model.downloads || []).filter(item => !excluded.has(item.file)), aliases: (model.aliases || []).filter(alias => !excluded.has(alias)) };
    }) };
  }
  async fileVisible(name, catalog = null) {
    if (!catalog) ({ catalog } = await this.read());
    const owners = catalog.models.filter(model => claims(model, name));
    return owners.some(model => model.has_scad === true && !model.hidden && !(model.excluded_files || []).some(file => stem(file) === stem(name)));
  }
  async apply(command) {
    const task = this.queue.then(() => this.mutate(command));
    this.queue = task.catch(() => {});
    return task;
  }
  async mutate(command) {
    const { catalog, state } = await this.read();
    if (command.revision !== state.revision) fail('The library changed in another tab. Reload before editing.', 409);
    const previous = structuredClone(state.overrides);
    if (command.action === 'undo') {
      if (!state.history?.length) fail('No change to undo.');
      state.overrides = state.history.pop();
    } else {
      if (!Array.isArray(command.ids) || !command.ids.length || command.ids.length > 1000) fail('Select projects first.');
      const ids = [...new Set(command.ids)];
      const selected = ids.map(id => catalog.models.find(model => model.id === id) || fail('A selected project no longer exists.', 409));
      const save = model => { state.overrides[model.id] = model; };
      if (['show', 'show-files'].includes(command.action) && selected.some(model => model.has_scad !== true)) fail('A SCAD source is required before publishing. Recreate these models as SCAD first.');
      if (command.action === 'hide' || command.action === 'show') {
        selected.forEach(model => save({ ...model, hidden: command.action === 'hide' }));
      } else if (['hide-files', 'show-files'].includes(command.action)) {
        if (!Array.isArray(command.files) || !command.files.length || command.files.some(file => !selected.some(model => files(model).includes(file)))) fail('Choose files from selected projects.');
        for (const model of selected) {
          const excluded = new Set(model.excluded_files || []);
          for (const file of command.files.filter(file => files(model).includes(file))) {
            if (command.action === 'hide-files') excluded.add(file); else excluded.delete(file);
          }
          save({ ...model, excluded_files: [...excluded] });
        }
      } else if (command.action === 'category') {
        if (!plain(command.category)) fail('Enter a category.');
        selected.forEach(model => save({ ...model, category: command.category.split('/').map(part => part.trim()).filter(Boolean) }));
      } else if (['move', 'split', 'merge'].includes(command.action)) {
        let target;
        if (command.action === 'split') {
          if (!plain(command.title)) fail('Enter a project title.');
          target = { id: `project-${randomUUID()}`, title: command.title.trim(), category: selected[0].category || [], views: [], downloads: [], aliases: [], website: {}, hidden: true };
        } else {
          target = catalog.models.find(model => model.id === command.target) || fail('Choose a destination project.');
          if (ids.includes(target.id)) fail('Choose a destination outside the selected projects.');
          target = structuredClone(target);
        }
        target.scad_source_ids = [...new Set([
          ...(command.action === 'split' ? [] : target.scad_source_ids || [target.id]),
          ...selected.flatMap(model => model.scad_source_ids || [model.id]),
        ])];
        const chosen = command.action === 'merge' ? selected.flatMap(files) : command.files;
        if (!Array.isArray(chosen) || !chosen.length || chosen.some(file => !selected.some(model => files(model).includes(file)))) fail('Select files belonging to the selected projects.');
        const moving = new Set(chosen);
        for (const model of selected) {
          const source = structuredClone(model);
          target.excluded_files = [...new Set([...(target.excluded_files || []), ...(source.excluded_files || []).filter(file => moving.has(file))])];
          source.excluded_files = (source.excluded_files || []).filter(file => !moving.has(file));
          for (const kind of ['views', 'downloads']) {
            const incoming = (source[kind] || []).filter(item => moving.has(item.file));
            const existing = new Set((target[kind] || []).map(item => item.file));
            target[kind] = [...(target[kind] || []), ...incoming.filter(item => !existing.has(item.file))];
            source[kind] = (source[kind] || []).filter(item => !moving.has(item.file));
          }
          if (command.action === 'merge') {
            target.website ||= {};
            for (const kind of ['instructions', 'parts', 'links']) target.website[kind] = [...(target.website[kind] || []), ...(model.website?.[kind] || [])];
            if (model.website?.description) target.website.instructions.push({ title: model.title, text: model.website.description });
            target.aliases = [...new Set([...(target.aliases || []), model.id, ...(model.aliases || [])])];
            state.overrides[model.id] = null;
          } else {
            source.aliases = (source.aliases || []).filter(alias => !moving.has(alias));
            source.default_view = source.views.some(view => view.id === source.default_view) ? source.default_view : source.views[0]?.id;
            save(source);
          }
        }
        // Views from different projects often share IDs such as "assembled".
        const viewIds = new Set();
        for (const view of target.views) {
          let id = view.id, suffix = 2;
          while (viewIds.has(id)) id = `${view.id}-${suffix++}`;
          view.id = id;
          viewIds.add(id);
        }
        target.default_view ||= target.views[0]?.id;
        target.availability = target.views.length ? 'viewable' : 'no-mesh';
        save(target);
      } else fail('Unknown management action.');
      state.history = [...(state.history || []), previous].slice(-20);
    }
    state.revision++;
    state.updatedAt = new Date().toISOString();
    await mkdir(dirname(this.statePath), { recursive: true });
    const temporary = `${this.statePath}.${randomUUID()}.tmp`;
    await writeFile(temporary, JSON.stringify(state, null, 2) + '\n', { mode: 0o600 });
    await rename(temporary, this.statePath);
    return { revision: state.revision };
  }
}

export function localModelAdmin(req) {
  const address = req.socket.remoteAddress;
  const host = req.headers.host || '';
  return ['127.0.0.1', '::1', '::ffff:127.0.0.1'].includes(address) && /^(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/.test(host) ? { admin: true } : null;
}

// Connect/Express compatible; it never contacts the printer or access hub.
export function modelManagementMiddleware(store, authenticate) {
  return async (req, res, next) => {
    const url = new URL(req.url, 'http://localhost');
    const path = url.pathname.replace(/^\/api/, '');
    if (!path.startsWith('/model-library/')) return next();
    const send = (status, value) => {
      res.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      res.end(req.method === 'HEAD' ? undefined : JSON.stringify(value));
    };
    try {
      const user = await authenticate(req);
      const readMethod = req.method === 'GET' || req.method === 'HEAD';
      if (path === '/model-library/catalog' && readMethod) return send(200, user?.admin ? (await store.read()).catalog : await store.publicCatalog());
      if (path === '/model-library/file-access' && readMethod) {
        const uri = new URL(req.headers['x-model-uri'] || '/', 'http://localhost');
        const name = decodeURIComponent(uri.pathname.replace(/^\/models\//, ''));
        return send(user?.admin || await store.fileVisible(name) ? 200 : 403, {});
      }
      if (path === '/model-library/listing' && readMethod) {
        if (!user) return send(401, { error: 'Sign in required.' });
        const { catalog } = await store.read();
        const names = await readdir(dirname(store.catalogPath));
        const visible = [];
        for (const name of names) {
          if (name.startsWith('.') || !await store.fileVisible(name, catalog)) continue;
          try {
            const info = await stat(join(dirname(store.catalogPath), name));
            if (info.isFile()) visible.push({ name, type: 'file', size: info.size });
          } catch { /* Ignore unavailable exports. */ }
        }
        return send(200, visible);
      }
      if (!user) return send(401, { error: 'Sign in required.' });
      if (!user.admin) return send(403, { error: 'Admin access required.' });
      if (path !== '/model-library/manage') return send(404, { error: 'Not found.' });
      if (req.method === 'GET') {
        const { catalog, state } = await store.read();
        return send(200, { catalog, revision: state.revision, canUndo: Boolean(state.history?.length) });
      }
      if (req.method !== 'POST') return send(405, { error: 'Use GET or POST.' });
      // JSON + exact Origin prevents cookie-authenticated cross-site writes.
      const origin = req.headers.origin;
      const host = req.headers.host;
      if (!origin || new URL(origin).host !== host || !/^application\/json\b/.test(req.headers['content-type'] || '')) return send(403, { error: 'Same-origin JSON request required.' });
      let body = req.body;
      if (!body) {
        let raw = '';
        for await (const chunk of req) {
          raw += chunk;
          if (raw.length > 262144) return send(413, { error: 'Request too large.' });
        }
        body = JSON.parse(raw);
      }
      return send(200, await store.apply(body));
    } catch (error) {
      send(error.status || 503, { error: error.status ? error.message : 'Model management is unavailable. Reload or try again later.' });
    }
  };
}
