// Verify the deployed files and public routes without starting the printer proxy.
import { readFile, stat, realpath } from 'node:fs/promises';
import { resolve, dirname, basename, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';

const requireValue = (condition, message) => { if (!condition) throw new Error(message); };
const assetName = name => typeof name === 'string' && name.length > 0 && name !== 'catalog.json' && basename(name) === name && !/[\\\0]/.test(name) && !name.startsWith('.');

export async function verifyCatalogFiles(catalogPath, expectedHash) {
  const bytes = await readFile(catalogPath);
  if (expectedHash) requireValue(createHash('sha256').update(bytes).digest('hex') === expectedHash, 'Deployed catalog differs from the prepared release.');
  const catalog = JSON.parse(bytes);
  requireValue(catalog.schema === 1 && Array.isArray(catalog.models) && catalog.models.length > 0, 'Missing or invalid model catalog.');
  const directory = await realpath(dirname(catalogPath));
  const files = new Map();
  for (const model of catalog.models) for (const item of [...(model.views || []), ...(model.downloads || [])]) {
    requireValue(assetName(item.file), 'Unsafe catalog asset filename.');
    const previous = files.get(item.file);
    requireValue(!previous || (previous.bytes === item.bytes && previous.sha256 === item.sha256), 'Conflicting catalog asset records.');
    files.set(item.file, item);
  }
  requireValue(files.size > 0, 'The model catalog has no assets.');
  for (const [name, item] of files) {
    const path = resolve(directory, name);
    const target = await realpath(path);
    requireValue(target.startsWith(directory + sep), `Asset escapes the models directory: ${name}`);
    const info = await stat(path);
    requireValue(info.isFile() && info.size === item.bytes, `Missing or incomplete model asset: ${name}`);
  }
  return { models: catalog.models.length, files: files.size };
}

export async function verifyBuild(directory) {
  const root = resolve(directory);
  const html = await readFile(resolve(root, 'index.html'), 'utf8');
  const required = new Set(['config.js', 'logger.js', 'printer.js', 'stream.js', 'auth.js', 'site.webmanifest']);
  requireValue(/site\.webmanifest/.test(html), 'Built HTML is missing its manifest link.');
  for (const match of html.matchAll(/(?:src|href)=["']([^"']+)["']/g)) {
    const url = new URL(match[1], 'https://fixture.invalid/');
    if (url.origin !== 'https://fixture.invalid') continue;
    if (/\.(js|css)$/.test(url.pathname)) required.add(decodeURIComponent(url.pathname).replace(/^\//, ''));
  }
  requireValue([...required].some(name => /^assets\/.*\.js$/.test(name)), 'Built HTML has no application bundle.');
  requireValue([...required].some(name => name.endsWith('.css')), 'Built HTML has no stylesheet.');
  for (const face of ['posx', 'negx', 'posy', 'negy', 'posz', 'negz']) required.add(`images/envmaps/fishermans_bastion/${face}.jpg`);
  for (const name of required) {
    const path = resolve(root, name);
    requireValue(path.startsWith(root + sep), 'Built asset escapes the application directory.');
    const info = await stat(path);
    requireValue(info.isFile() && info.size > 0, `Missing or empty build artifact: ${name}`);
  }
  return { artifacts: required.size + 1 };
}

export async function verifyPublicModels(baseURL) {
  const base = new URL(baseURL);
  const request = async (path, method = 'GET') => {
    const response = await fetch(new URL(path, base), { method, redirect: 'error', cache: 'no-store', headers: { 'Accept-Encoding': 'identity' }, signal: AbortSignal.timeout(10000) });
    requireValue(response.status === 200, `${method} ${path}: HTTP ${response.status}`);
    return response;
  };
  for (const path of ['/models', '/models/']) {
    const response = await request(path, 'HEAD');
    requireValue(/text\/html/.test(response.headers.get('content-type') || ''), `${path} did not return the model page.`);
  }
  const response = await request('/models/catalog.json');
  requireValue(/application\/json/.test(response.headers.get('content-type') || ''), 'Catalog route did not return JSON.');
  const catalog = await response.json();
  requireValue(catalog.schema === 1 && Array.isArray(catalog.models), 'Public catalog is invalid.');
  const visible = catalog.models.filter(model => model.has_scad === true && !model.hidden);
  requireValue(visible.length > 0, 'Public catalog contains no eligible models.');
  const assets = visible.flatMap(model => [...(model.views || []), ...(model.downloads || [])].filter(item => !(model.excluded_files || []).includes(item.file)));
  for (const format of ['stl', 'glb']) {
    const item = assets.filter(asset => asset.format === format && asset.bytes > 0).sort((a, b) => a.bytes - b.bytes)[0];
    requireValue(item && assetName(item.file), `No public ${format.toUpperCase()} model is available.`);
    const path = '/models/' + encodeURIComponent(item.file);
    const file = await request(path);
    const type = file.headers.get('content-type') || '';
    requireValue(format === 'glb' ? /model\/gltf-binary/.test(type) : /model\/stl/.test(type), `Model route returned an unexpected content type for ${item.file}.`);
    const bytes = Buffer.from(await file.arrayBuffer());
    requireValue(bytes.length === item.bytes, `Model route returned an incomplete file for ${item.file}.`);
    requireValue(createHash('sha256').update(bytes).digest('hex') === item.sha256, `Model route returned the wrong bytes for ${item.file}.`);
  }
  return { visibleModels: visible.length, formats: ['stl', 'glb'] };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  try {
    const [mode, ...args] = process.argv.slice(2);
    let result;
    if (mode === '--build' && args.length === 1) result = await verifyBuild(args[0]);
    else if (mode === '--files' && args.length >= 1 && args.length <= 2) result = await verifyCatalogFiles(...args);
    else if (mode === '--http' && args.length === 1) result = await verifyPublicModels(args[0]);
    else throw new Error('Use --build DIST, --files CATALOG [SHA256], or --http URL.');
    console.log('Deployment verification passed:', JSON.stringify(result));
  } catch (error) {
    console.error('Deployment verification failed:', error.message);
    process.exitCode = 1;
  }
}
