# Architecture

## Browser boundaries

- Preserve the classic-script load order in `index.html`; `CONFIG`, `ActivityLogger`, `PrinterStatus`, `MjpegStream`, and `GoogleAuth` depend on browser globals.
- Keep `viewer-3d.js` on its existing module path and preserve its `window.modelViewer` integration. It also defines `window.modelCatalog`, which `models.js` (loaded after it) uses.
- Use `GoogleAuth.onAuthStateChanged` as the entry point for authenticated UI, stream lifecycle, and printer polling.
- Keep upload UI changes coordinated between inline handlers in `index.html`, client permission checks, and both relevant server implementations.
- Resolve printer and stream endpoints separately; their configuration objects are different.
- Read private endpoint configuration before running browser tests that could contact live infrastructure.

## Request and persistence paths

1. Printer status: `PrinterStatus` selects a configured base URL, requests product and detail data, then passes normalized status to `GoogleAuth.updatePrinterUI`.
2. Video: `GoogleAuth.getStreamUrl` selects the stream endpoint; `MjpegStream` fetches multipart bytes and presents JPEG blob URLs to the image element.
3. Production proxy: Nginx forwards `/api/` to the private Node proxy with the prefix removed; `/stream` forwards the configured camera feed with disconnect cancellation.
4. Notifications: `PrinterMonitor` polls independently of browser sessions and uses `loadMonitorState` and `saveMonitorState` to retain event state.
5. Monitor storage: `MONITOR_STATE_PATH` overrides the default container data path; writes use a temporary sibling and rename. Read/write errors remain non-fatal.
6. Models: `ModelViewer.openModal` resolves the `model` value through `window.modelCatalog` (`ModelCatalog` in `viewer-3d.js`): a model ID, a published view or download filename, an alias, or a printer job name by its stem. A catalog model shows its default or `view` query view, a view selector, and downloads. Anything the catalog does not claim falls back to `ModelViewer.loadModel`, which strips the final extension, checks the STL with HEAD, and loads it. Online 3D Viewer turns each import upright from its importer's up axis; the viewer turns the camera only for a declared Z-up file read by a Y-up importer. Dimensions come from the view's `source_bounds_mm`, otherwise from the mesh bounds scaled by `units`.
7. Activity logs: `ActivityLogger` uses console output on localhost and `/api/log.php` otherwise; `utils/log.php` appends daily JSONL with server metadata and size-based rotation.
8. Model library: `/models` and `/models/` render the shared HTML shell. `GoogleAuth.onAuthStateChanged` shows `ModelLibrary` for signed-in users while leaving the stream and printer polling stopped. Model links use `?model=<id>` (and `&view=<view id>` for a non-default view), still accept `?model=<filename>`, and reuse `ModelViewer`.
9. Catalog: `cad/utils/web-library.py` generates the base catalog and selected files under the models mount. `has_scad` records an existing declared SCAD source. The effective visitor catalog and direct-file visibility checks exclude source-less projects; only SCAD-backed projects with supported 3D previews get gallery cards. The full admin inventory retains source-less projects as **Needs SCAD**. Loose files are manageable privately and never become gallery cards. The Node middleware filters `/model-catalog/`; the gallery no longer uses a directory-listing fallback. Missing catalog metadata fails closed. See `docs/model-catalog.md` for contributor provenance and publication behavior.
10. Development models: Vite serves `/models/<basename>` from `cad/_work/site-models/` (override with `SITE_MODELS_DIR`), then from `public/models/` (or `dist/models/` in preview), and answers anything else with a real 404. Names with a slash, a backslash, NUL, or a leading dot are refused, and a staged symlink must resolve inside the repository or the staging directory. `/model-catalog/` lists both directories, staging first. `/cad/` is not served, and `cad/**` is excluded from watching and dependency scanning.
11. Project presentation: `project-content.js` normalizes plain-text descriptions, instructions, supplies and HTTPS links from manifest `website` metadata. The modal displays this beside its main viewer and uses part thumbnails to select views. The optional public Amazon.com tag comes from `cad/catalog-settings.json` through the catalog; missing tags and product URLs are not guessed.
12. Thumbnails: `model-previews.js` supplies visible cards and parts through one offscreen renderer, caches PNGs by hash, prioritizes modal thumbnails and cancels work on sign-out. It does not automatically fetch meshes over 25 MB.

## Development processes and styles

- `npm start` invokes `utils/dev.js`, compiles both expanded and minified CSS, then starts both Sass watchers, the development proxy, and Vite. A failed child or Ctrl+C stops the other process groups.
- `npm run build` compiles SCSS before Vite. Generated CSS remains ignored; edit `styles/scss/main.scss`.

## Private runtime boundary

- Treat `server.js` and `printer-proxy-server.js` as ignored local implementations, not files delivered by a clean checkout.
- The checked-in server examples have smaller route sets than the current private implementations.
- The current development server can repair STL files; production explicitly disables repair and can return original bytes under a repaired filename.
- Keep `utils/stl-repair.js` paired with `utils/stl-repair-pymeshlab.py`; other similarly named Python files are not the wrapper's call target.
- Do not describe server-side email allowlists as cryptographic authentication. The inspected upload and G-code handlers accept caller-supplied email fields.
- Do not assume the UI sign-in gate protects every proxy endpoint.

## Assets and container coupling

- Vite builds the module graph and copies `public/`; its custom plugin separately copies classic scripts and adds manifest links.
- `npm run build` compiles expanded and minified CSS before Vite; `npm start` watches both outputs with the development servers.
- Preserve the model volume mount in `docker-compose.yml`; it overlays the container model directory so runtime assets can change independently of the image.
- `.dockerignore` keeps `cad/`, the `3d` symlink, and `_PLANS/` out of the build context, and keeps `styles/scss/` in it because the builder stage compiles the CSS. The file is gitignored, so a fresh checkout has no build-context rules at all.
- The viewer's environment map is vendored in `public/images/envmaps/fishermans_bastion/` from `online-3d-viewer`'s website assets (Emil Persson, CC BY 3.0; attribution in its `readme.txt`). Without it, glTF's physically based materials render nearly black.
- Preserve the data mount for monitor state and the logs mount for activity records.
- The Docker startup script starts PHP-FPM and Nginx separately; PM2 runs the Node proxy. PM2 does not manage all three services.
- There is no database schema or database migration command to maintain.

## Website project organization

`model-admin.js` exposes bulk controls only for the existing admin role. `utils/model-management.js` validates every management request server-side and persists project snapshots in a separate runtime overlay. Vite hosts this API locally; production mounts it in the private proxy using `readSession`. Nginx obtains the effective catalog/listing and file visibility from that middleware. The CAD generator remains the base inventory; website operations change asset references, never CAD paths. See `docs/model-catalog.md` for persistence, undo, single-writer and regeneration limits.
