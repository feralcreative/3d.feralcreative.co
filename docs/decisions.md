# Decisions and retained operating knowledge

## Proxy the printer and camera

- Keep printer requests behind the application proxy because the printer API does not provide the browser CORS behavior needed by this app.
- Keep the upstream camera URL server-side so the Surveillance Station stream credential is not distributed in browser configuration.
- Do not reinstate direct NAS URLs from older documentation.

## Decode MJPEG in the browser

- Preserve the `MjpegStream` fetch-and-decode implementation from `stream.js`.
- The recorded reason for rejecting a direct multipart image source is failed rendering over the HTTP/2 paths used by the site and reverse proxy.
- Preserve aborts, bounded buffering, reconnect backoff, JPEG blob URL revocation, and stalled-frame recovery.
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

- Retain the predecessor's prohibition on manual SCSS compilation and the VS Code Live Sass Compile workflow.
- The npm build consumes generated CSS; it does not own compilation.
- Rationale for choosing editor compilation over a package script: TBD.

## Keep models outside the application image lifecycle

- Preserve runtime model mounting so adding an STL does not require rebuilding application code.
- Keep the filename-based mapping from printer jobs to model assets; printer uploads and viewer model files have separate lifecycles.
- Treat model viewing, mesh integrity, and physical printability as separate verification layers.

## Preserve uncertainty in inherited deployment guidance

- The predecessor states that host networking is required for printer LAN access; current Compose retains host networking.
- A comparison with bridged networking has not been performed. Do not convert the container network as incidental cleanup.
- Do not reinterpret partially migrated PyMeshLab code as a completed repair deployment.
