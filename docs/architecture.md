# Architecture

## Browser boundaries

- Preserve the classic-script load order in `index.html`; `CONFIG`, `ActivityLogger`, `PrinterStatus`, `MjpegStream`, and `GoogleAuth` depend on browser globals.
- Keep `viewer-3d.js` on its existing module path and preserve its `window.modelViewer` integration.
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
6. Models: `ModelViewer.loadModel` strips the final filename extension, checks the corresponding STL path with HEAD, then loads it through Online 3D Viewer.
7. Activity logs: `ActivityLogger` uses console output on localhost and `/api/log.php` otherwise; `utils/log.php` appends daily JSONL with server metadata and size-based rotation.

## Private runtime boundary

- Treat `server.js` and `printer-proxy-server.js` as ignored local implementations, not files delivered by a clean checkout.
- The checked-in server examples have smaller route sets than the current private implementations.
- The current development server can repair STL files; production explicitly disables repair and can return original bytes under a repaired filename.
- Keep `utils/stl-repair.js` paired with `utils/stl-repair-pymeshlab.py`; other similarly named Python files are not the wrapper's call target.
- Do not describe server-side email allowlists as cryptographic authentication. The inspected upload and G-code handlers accept caller-supplied email fields.
- Do not assume the UI sign-in gate protects every proxy endpoint.

## Assets and container coupling

- Vite builds the module graph and copies `public/`; its custom plugin separately copies classic scripts and adds manifest links.
- Generated CSS must exist before the build; SCSS compilation belongs to the existing editor workflow.
- Preserve the model volume mount in `docker-compose.yml`; it overlays the container model directory so runtime assets can change independently of the image.
- Preserve the data mount for monitor state and the logs mount for activity records.
- The Docker startup script starts PHP-FPM and Nginx separately; PM2 runs the Node proxy. PM2 does not manage all three services.
- There is no database schema or database migration command to maintain.
