# Project agent instructions

## Commands

Run commands from the repository root. Read the verification limits below before treating setup as complete.

| Task | Command | Verification |
|---|---|---|
| Install dependencies without lifecycle scripts | `npm install --ignore-scripts --no-audit --no-fund --package-lock=false --fetch-retries=0` | Blocked by registry DNS in the authoring environment. |
| Frontend only | `BROWSER=none npm run dev -- --host 127.0.0.1 --strictPort` | Blocked by sandbox permission to bind the local port. |
| Build | `npm run build` | Fails on an unavailable local model asset; see debugging guide. |
| Check authentication syntax | `node --check auth.js` | Passed. |
| Check printer client syntax | `node --check printer.js` | Passed. |
| Check stream syntax | `node --check stream.js` | Passed. |
| Check viewer syntax | `node --check viewer-3d.js` | Passed. |
| Check logger syntax | `node --check logger.js` | Passed. |
| Check monitor persistence syntax | `node --check utils/monitor-state.js` | Passed. |
| Check repair wrapper syntax | `node --check utils/stl-repair.js` | Passed. |
| Check local development proxy syntax | `node --check server.js` | Passed with the ignored local implementation present. |
| Check local production proxy syntax | `node --check printer-proxy-server.js` | Passed with the ignored local implementation present. |
| Automated tests | TBD | No test script or maintained suite is configured. |
| Single test file | TBD | No maintained test runner is configured. |
| Lint / format | TBD | No project lint or format command is configured. |
| Typecheck | TBD | No project typecheck command is configured. |
| Fresh-checkout runtime setup | TBD | Checked-in examples do not reproduce the current local runtime. |

- Treat these results as the 2026-09-28 local authoring baseline, not a guarantee for another checkout.
- The attempted test invocation failed because `package.json` has no test script; do not report a passing suite.
- The offline install attempt also failed because the npm cache lacked required registry metadata.
- Existing dependencies allowed the build to start; a clean dependency installation remains unverified.
- Request the private runtime configuration from Ziad before attempting a complete application setup.
- Do not overwrite existing local configuration with example files.
- Read [docs/debugging.md](docs/debugging.md) when any command is blocked.

## Definition of done

1. Inspect the current diff and preserve changes outside the requested task.
2. Read the relevant deep-dive document before changing a cross-cutting behavior.
3. Run the applicable syntax checks above for changed JavaScript files.
4. Run the build for application changes and report its actual exit status.
5. Inspect build output for missing copied scripts, CSS, manifest, and entry HTML; plugin logging can conceal incomplete output.
6. Exercise the changed behavior using local fixtures or an explicitly authorized runtime.
7. For UI changes, verify the affected signed-in, signed-out, denied-access, and offline states as applicable.
8. For stream changes, verify reconnect, stop, stalled-frame recovery, and background/resume behavior.
9. For model changes, verify filename mapping, missing-model feedback, modal close, and URL navigation.
10. For upload changes, distinguish downloaded bytes, repair success, and actual printer transfer.
11. For monitor changes, verify state restoration and duplicate-notification suppression with isolated state and a stubbed sender.
12. Review the final diff for credentials, generated files, and unrelated edits.
13. State failed checks and unverified behavior explicitly in the handoff.

- Do not require production access, real Slack messages, or physical printer actions for a documentation change.
- Do not add a test framework or repair unrelated build failures solely to make documentation checks pass.
- A syntax check does not execute browser globals or verify authentication, network behavior, or hardware.
- A build does not validate PyMeshLab availability, printer reachability, deployment, or physical print quality.
- No automated CI gate is defined in this checkout.
- When a change makes anything in this file inaccurate—a command, a path, a convention, a prohibition—update this file in the same change.

## Prohibitions

### Scope and authorization

- Never commit, push, deploy, rsync, SFTP, mutate cloud state, or touch a remote server without explicit permission for that task.
- Treat printer uploads, heating, movement, filament-change commands, and print starts as hardware actions requiring explicit authorization.
- Do not start the production proxy merely to inspect it; startup launches the printer monitor and can send Slack notifications.
- Do not send real Slack notifications as a routine test.
- Do not reset monitor state on the mounted production data volume for a local test.
- Do not follow the `3d` symlink during recursive repository searches; it leaves the project and can contain symlink loops.
- Do not remove unavailable model links or hunt for intentionally missing assets without the user's direction.
- Do not expand a documentation task into application, authentication, infrastructure, or dependency changes.

### Generated and private files

- Edit SCSS sources, not generated `styles/css/` files.
- Preserve the predecessor's rule: use the VS Code Live Sass Compile workflow; do not compile SCSS manually.
- Do not hand-edit `dist/`; Vite and the `copy-js-files` plugin regenerate it.
- Do not hand-edit `node_modules/` or dependency lockfiles.
- Keep the existing ignored-lockfile policy unless the task explicitly changes dependency management.
- Keep `.env`, `.env.*.local`, `.secrets/`, and `.vscode/` private.
- Keep `config.js`, `server.js`, and `printer-proxy-server.js` private under their existing ignore rules.
- Keep the private deployment scripts under `utils/deploy/` ignored.
- Keep uploads, logs, model payloads, build output, and journal cursor files out of commits.
- Do not force-add an ignored directory to publish one documentation file.

### Credential handling

- Document credential names and acquisition sources only; never include full, masked, or partial values.
- Do not copy private configuration, OAuth JSON, request payloads, or credential-bearing URLs into logs or chat.
- Do not log the complete `CONFIG` object or stored Google credential.
- Treat `config.js` as browser-visible output, even though Git ignores it.
- Keep camera upstream credentials and Slack webhook URLs on the server.
- Request private configuration and credential access from Ziad; do not infer values from historical docs.
- Use `.env.example` for the checked-in environment template; its current coverage is incomplete.
- Read the credential-source table in [docs/deployment.md](docs/deployment.md) before runtime setup.
- Report leaked credentials without reproducing their values; do not rewrite Git history without authorization.

## Architecture

1. `index.html` loads the classic configuration, logger, printer, stream, and authentication scripts in dependency order; `viewer-3d.js` is loaded as a module.
2. `GoogleAuth.onAuthStateChanged` controls the stream, printer polling, permission-dependent UI, and model deep links.
3. `PrinterStatus` chooses `CONFIG.PRINTER_PROXY_URL.DEV` for localhost or loopback and `.PROD` otherwise, then calls proxy endpoints.
4. The production Nginx `/api/` route strips the prefix and forwards to the Node printer proxy; PHP files use the separate PHP handler.
5. The private production proxy communicates with the printer and camera; its independent `PrinterMonitor` sends notifications without a browser tab.
6. `utils/monitor-state.js` persists notification state through a temporary-file write and rename on the mounted data volume.
7. `ModelViewer.loadModel` maps printer filenames to STL assets served from `/models/`; uploaded printer files do not populate that model library.
8. The development upload path can invoke `utils/stl-repair.js`, which calls `utils/stl-repair-pymeshlab.py`; the current production upload implementation disables repair.

- Keep browser classes independent of Node/Python utilities; communicate across the proxy boundary.
- Preserve script load order and explicit browser-global assignments when changing module boundaries.
- Keep notification persistence on the server; browser status events do not own Slack delivery.
- There is no application database or migration workflow; monitor JSON and activity logs are file-backed state.
- Read [docs/architecture.md](docs/architecture.md) before changing more than one layer.

## Conventions

### JavaScript and contracts

- Preserve surrounding JavaScript style; no repository formatter enforces a separate style.
- Keep classic browser scripts compatible with their globals and their order in `index.html`.
- Add any new classic script to the build copy list when it must ship separately.
- Keep Node imports compatible with the package's ES-module mode.
- Preserve existing DOM IDs when changing HTML consumed by `auth.js` or inline upload handlers.
- Search for symbol consumers before renaming global classes, callback names, configuration keys, or response fields.
- Keep exact-email and domain-suffix permission matching consistent across relevant clients and servers.
- Preserve the distinct viewer, uploader, and advanced-feature permission checks.
- Do not treat client-supplied email checks as verified server authentication.
- Use the existing log prefixes to keep stream, upload, printer, and monitor diagnostics distinguishable.
- Keep Python repair results as JSON on stdout and verbose diagnostics on stderr.
- Preserve upload cleanup on success, failure, and completed downloads.
- Preserve the repair-only default; sending to the printer must remain an explicit selection.

### Styling and assets

- Use existing variables from `styles/scss/_variables.scss`; do not invent undefined color names.
- Use the existing breakpoint mixins in `styles/scss/_mixins.scss`.
- Keep generated CSS available before building; the npm build does not compile SCSS.
- Preserve the existing Live Sass Compile workflow until the user requests a different build pipeline.
- Match model basenames to printer job filenames; the viewer replaces the final extension with `.stl`.
- Treat model files as external runtime assets, not application source.
- Verify special-character filenames through the existing query-string and model-path logic before changing encoding.

### Documentation

- Keep Markdown paragraphs and bullets on single logical lines; do not hard-wrap prose.
- Use tight em dashes and language-tagged code fences.
- Reference paths and symbols, not source line numbers.
- Put durable detail in the canonical deep-dive files linked below.
- Keep `CLAUDE.md` as the single-line `@AGENTS.md` import.
- Preserve verified instructions on reruns; correct stale facts without restyling unrelated content.
- Mark unresolved setup or verification details `TBD` rather than inventing a working procedure.

## Gotchas

### Setup and build

- A fresh clone is incomplete: private runtime files, generated CSS, and model assets are ignored. Obtain the required local setup before expecting parity.
- `config.example.js` lacks `PRINTER_PROXY_URL`, `UPLOAD_ALLOWED_EMAILS`, and `ADVANCED_FEATURES`; it is not a drop-in replacement for the current app configuration.
- The example proxy servers omit runtime features. Compare the intended endpoint with the private implementation before editing an example.
- The `3d` watcher exclusion prevents recursive symlink errors. Preserve it when changing Vite watch settings.
- Vite can fail while copying `public/` before writing the entry HTML. Diagnose the first missing asset, not only the later manifest-injection error.
- The build plugin catches copy/injection failures. A success exit alone does not prove every required artifact exists.
- Vite warnings about classic script tags are expected from the current manual-copy design; do not convert script types as an incidental cleanup.
- `NODE_ENV=production` in the local environment file produces a Vite warning. Do not edit private configuration just to silence it during documentation work.
- Docker uses `npm ci`, but the lockfile is ignored. A clean checkout does not contain every build-context prerequisite.
- Existing docs describe a complete PyMeshLab installation, but `requirements.txt` currently comments it out and Docker tolerates Python-install failure.

### Runtime and permissions

- Browser sessions are restored from `localStorage`, not `sessionStorage`; closing a tab does not implement logout.
- `DEV_MODE` bypass applies only to localhost and loopback. It does not grant corresponding server upload or advanced permissions.
- Empty viewer restrictions allow Google accounts in the client; empty upload and advanced lists deny those features.
- Do not assume every local browser request stays local. Inspect private proxy and stream configuration before browser testing.
- The local development server has no `/stream` handler, while the stream example points at it. Local streaming setup remains `TBD`.
- The development `/health` handler is not a production health contract; the production catch-all does not accept that endpoint.
- `SLACK_ENABLED=false` suppresses notification sending but does not stop production monitor polling.
- Persist cooldowns and milestones across monitor restarts to avoid re-announcing an active print.
- Filament runout is inferred from unexpected pauses; preserve the grace period after deliberate filament-change requests.
- The predecessor's firmware observation about unavailable filament-presence fields is unverified locally; retain the heuristic until new evidence supports a change.

### Streaming, models, and repair

- Preserve `MjpegStream` multipart parsing, blob URL cleanup, abort behavior, reconnect backoff, and stalled-frame checks.
- Do not replace the streaming implementation with a raw MJPEG image URL without validating the recorded HTTP/2 behavior.
- Register `/stream` before the production proxy catch-all; preserve Nginx buffering and timeout settings for long responses.
- The `ModelViewer` methods named `setHash` and `getHashFileName` operate on the `model` query parameter, not a URL fragment.
- Cached job data can appear while the printer is idle; the client also starts with placeholder cache data. Do not treat it as a live reading.
- Downloaded files labeled as repaired do not prove repair ran: production repair is disabled, and development repair can fall back to the original.
- `utils/pymeshlab-repair.py` is not the current Node wrapper's invoked script; follow `repairSTL` to `utils/stl-repair-pymeshlab.py`.
- Old ADMesh instructions in `docs/STL_REPAIR_GUIDE.md` do not describe the current wrapper.
- A model loaded successfully in the viewer is not proof of a watertight mesh or a printable part.

## Commit and PR conventions

- Commit or push only when explicitly requested for this task.
- Inspect and stage only intended files; never use blanket staging around private runtime files or model collections.
- Use a concise imperative summary; history contains both conventional prefixes and plain summaries, with no enforced format.
- Branch naming policy: TBD.
- Do not assume a branch named in an old primer is the current working branch.
- State the concrete behavior change, validation performed, failed checks, and private-runtime dependencies in PR descriptions.
- Call out backend or container changes explicitly; a frontend-only build does not validate them.
- Do not add AI co-author trailers, generated-by text, or self-attribution.
- Do not include credential incident values in commits or PRs.

## Deep-dive index

- [docs/architecture.md](docs/architecture.md)—Read before changing browser/server boundaries, assets, or persistence.
- [docs/api.md](docs/api.md)—Read before changing proxy routes, upload contracts, or permission checks.
- [docs/deployment.md](docs/deployment.md)—Read before runtime setup, container work, or an authorized release.
- [docs/decisions.md](docs/decisions.md)—Read before replacing the stream, monitor-state, styling, or proxy design.
- [docs/debugging.md](docs/debugging.md)—Read when setup, build, streaming, repair, or validation fails.
