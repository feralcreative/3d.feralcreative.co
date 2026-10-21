# Decisions and retained operating knowledge

## Proxy the printer and camera

- Keep printer requests behind the application proxy because the printer API does not provide the browser CORS behavior needed by this app.
- Keep the upstream camera URL server-side so the Surveillance Station stream credential is not distributed in browser configuration.
- Do not reinstate direct NAS URLs from older documentation.

## Decode MJPEG in the browser

- Preserve the `MjpegStream` fetch-and-decode implementation from `stream.js`.
- The recorded reason for rejecting a direct multipart image source is failed rendering over the HTTP/2 paths used by the site and reverse proxy.
- Preserve aborts, bounded buffering, reconnect backoff, JPEG blob URL revocation, and stalled-frame recovery.
- The private production proxy must send the unchanged multipart body as `application/octet-stream`, retain its `boundary` parameter, and set `X-Content-Type-Options: nosniff`. WebKit cancels `multipart/x-mixed-replace` subresource loads that are not image requests, including the client's fetch path; see [WebKit's subresource loader](https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/SubresourceLoader.cpp).
- An isolated local fixture on 2026-10-13 reproduced `Load failed` in desktop Safari with the original multipart response header; changing only the outer MIME type displayed JPEG frames and passed restart checks. Chrome with a mobile viewport also displayed frames. Physical iPhone and production verification remain pending.
- Live browser/proxy reproduction of the recorded HTTP/2 issue: TBD.

## Send notifications independently of the browser

- Keep notification delivery in `PrinterMonitor` so it continues without an open browser tab.
- Preserve monitor-state persistence because a restart otherwise resembles a new print and can repeat start or milestone notifications.
- Keep persistence failures non-fatal so monitoring can continue when state is unavailable.

## Infer runout conservatively

- Retain the unexpected-pause heuristic and deliberate-filament-change grace period.
- The predecessor records that firmware 5.1.8 did not expose usable filament-presence fields and that the referenced TCP commands only toggled sensing.
- Current hardware verification of that observation: TBD.
- Preserve the distinction between suspected runout and a confirmed sensor reading; use new authorized observations before changing the inference.
- Treat `[RUNOUT-CAPTURE]` payloads as private diagnostics; inspect only the fields needed and do not publish complete printer responses.

## Preserve the styling workflow

- On 2026-10-20, Ziad replaced the editor-only workflow with Sass watchers under `npm start`.
- Compile expanded `main.css` and compressed `main.min.css` before starting the watchers, Vite, and the development proxy. Keep generated CSS ignored.
- `npm run build` runs the same style compilation before Vite so production builds include current styles.

## Keep models outside the application image lifecycle

- Preserve runtime model mounting so adding an STL does not require rebuilding application code.
- Keep the filename-based mapping from printer jobs to model assets; printer uploads and viewer model files have separate lifecycles. The catalog extends it: a job name resolves by its stem to the catalog model that publishes a file or alias of that name.
- Treat model viewing, mesh integrity, and physical printability as separate verification layers.
- `/models` uses the shared signed-in shell and modal without starting camera streaming or printer polling. List every catalog model, including no-mesh and withheld entries with a badge, then every top-level STL the catalog does not claim, except the internal placeholder.
- Coloured views are standard GLB (metres, Y-up, linear `baseColorFactor`). Native 3MF imports one sRGB step too dark in the installed viewer, so it is not used as a view format.
- STEP, 3DM, and FCStd views are listed as download-only. Their Online 3D Viewer importers fetch OCCT or rhino3dm from `cdn.jsdelivr.net` at runtime; previewing them in the browser is a separate decision.
- Nginx generates `/model-catalog/` from the mounted models directory, guarded by an `auth_request` to the existing session endpoint. Do not bake the catalog into the application build; publishing a model has a separate lifecycle.
- Vite supplies the same catalog shape for development and preview. Its catalog is a local development convenience, not a replacement for production authentication.

## Preserve uncertainty in inherited deployment guidance

- The predecessor states that host networking is required for printer LAN access; current Compose retains host networking.
- A comparison with bridged networking has not been performed. Do not convert the container network as incidental cleanup.
- Do not reinterpret partially migrated PyMeshLab code as a completed repair deployment.
