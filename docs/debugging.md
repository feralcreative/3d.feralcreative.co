# Debugging and verification limits

## Authoring baseline: 2026-09-28

| Check | Result | Next step |
|---|---|---|
| Dependency install | Registry DNS failed; offline attempt lacked cached metadata. | Retry the Commands-table install in an environment with registry access. |
| Frontend startup | Sandbox denied binding loopback port 5501. | Run the documented frontend command where local listening is permitted. |
| Build | Vite failed while copying `public/models/screen-fence-insert-220.stl`. | Ask Ziad to resolve asset availability; do not search deleted paths or remove links automatically. |
| Build plugin | Manifest injection then failed because entry HTML was not emitted. | Resolve the first build failure before diagnosing the secondary plugin error. |
| Automated tests | npm reported no test script. | Report suite coverage as unavailable; do not claim zero discovered tests is success. |
| JavaScript syntax | Commands-table checks passed for browser modules, utilities, and both private proxies. | Run the applicable checks after edits; syntax does not establish runtime behavior. |
| Docker and production | Not executed. | Perform only within an explicitly authorized deployment task. |
| Browser, printer, stream, Slack, repair | Not exercised end to end. | Use safe fixtures or an explicitly authorized runtime. |

## Model library and Sass verification: 2026-10-20

- Dependency installation passed with registry access. `npm run build` exited 0; required copied scripts, bundled library code and CSS, manifest, and entry HTML were present. Existing Sass deprecations, classic-script warnings, and the viewer chunk-size warning remain.
- Fourteen isolated fixture checks passed for model access gating, denied sign-in, stream-page startup, catalog filtering/search/empty/offline states, special-character and legacy links, Back/Forward, missing files, close-during-load, live directory changes, and launcher child-process cleanup. These fixtures stub the DOM, viewer renderer, authentication responses, and development child tasks; they do not verify WebGL or real sign-in.
- Local HTTP checks passed for `/models`, `/models/`, model query links, and the catalog with 88 selectable STL files. Both actual Sass watchers rebuilt their outputs after the SCSS modification time changed. Sandbox exceptions were needed for loopback networking and macOS FSEvents.
- Browser visual verification was blocked by Chrome returning `ERR_BLOCKED_BY_CLIENT` for local URLs. Container/Nginx execution was not verified because the Docker daemon was stopped. No deployment or physical printer action was performed.

## Catalog library verification: 2026-10-20

Evidence and the full list of checks are in [3d-library-claude-implementation.md](3d-library-claude-implementation.md). In short: headless Chrome against Vite, with a fixture catalog and with the generated 256-model staging catalog. The 2026-10-20 Sass deprecations above are fixed with identical CSS output; the classic-script and viewer chunk-size warnings remain. Container and Nginx execution remain unverified because no Docker daemon or local nginx was available.

## Project gallery verification: 2026-10-20

- The gallery now hides source-only, unsupported-only and withheld catalog entries and the internal placeholder. The local catalog retains all 256 entries; the live gallery shows 225 cards including four unmanaged STL files. Searching for the SketchUp-only `build-plate-caddy` returns no match.
- `npm run test:models` passed nine focused Node checks for filtering, copy/search, source-list failure, empty/sign-out behavior, unmanaged-file fallback, product-link safety and tagging, affiliate disclosure, and lazy preview priority. Eight exporter tests, seventeen library tests, and `python3 cad/utils/library.py check` also passed.
- Actual Chrome checks at `127.0.0.1:5501/models` rendered gallery PNGs and the coloured pumpkin assembly/part strip without thumbnail errors. Selecting the exploded view changed the measured bounds and URL; Back restored the assembled view. Orbiting worked. At 390 × 844, the gallery and stacked project modal had no horizontal overflow. Screenshots are `/private/tmp/3d-project-preview.jpg` and `/private/tmp/3d-project-phone.jpg`.
- The final website build exited 0; required entry HTML, classic scripts, manifest, bundled project content and CSS were present. The generated catalog reported three existing conversion warnings; unsupported/source-only entries remain preserved. The viewer bundle-size warning remains.
- Ziad subsequently supplied the exact Amazon URLs for the steel discs, solar cork lights and fence-side magnets; these are now attached to the matching supplies. Ziad subsequently supplied `feral-creative-20`; the catalog now carries that tracking ID and the product links include it with the paid-link label and disclosure. The pumpkin has authored project copy, instructions and supply specifications, while other projects show their metadata when authored. Container/production deployment, physical fit and printer actions were not verified or performed by this change.

## Production model catalog outage—2026-10-20

Read-only checks after the application deployment found `/models/catalog.json` returning 503 and both STL and GLB file requests returning 500. The running container's models mount contained 257 STL files, zero GLB files and no `catalog.json`. The configured catalog read failed with `ENOENT`. There was no organization override file either; that file is optional and its absence is handled normally.

The application image does not carry the generated CAD catalog, and the production volume overlays its models folder. Application deployment and model publication are separate operations. The new model middleware reads the catalog to resolve SCAD eligibility and file visibility; without the catalog that check fails, and Nginx's file-access subrequest turns the backend error into a 500. Rebuilding the frontend alone does not supply the missing catalog or previews. Do not restore unmanaged-file fallback to work around this dependency.

The recovery prepared locally is `utils/models.sh --push`, which stages the selected assets, transfers them first and publishes `catalog.json` last. `utils/models.sh --push --dry-run` passed without contacting the NAS. All 1,050 selected asset files were available locally (approximately 2.12 GB), and the configured publication destination matched the production models volume. Publication still requires explicit authorization; it was not performed during diagnosis. After an authorized publication, verify the live catalog and representative STL/GLB requests, then the signed-in gallery. Keep model publication in the release checklist when deploying a catalog-dependent application revision. The revised `utils/deploy/prod.sh` now generates and validates the model catalog, publishes the selected assets and catalog before recreating the container, then verifies model loading through Nginx and public HTTPS. Its tests and offline dry run passed; that revised release path has not yet been executed against production.

## Build diagnosis

- Read the first build error before the `closeBundle` messages; the plugin may run even after failure.
- Treat incomplete `dist/` contents as failed output, even when some classic files were copied.
- Preserve the Vite watch exclusion for the external `3d` symlink.
- `npm start` prepares and watches expanded/minified CSS. `npm run build:css` compiles once, and `npm run build` compiles styles before Vite.
- Do not assume the ignored lockfile, private runtime files, or external models exist in a fresh checkout.
- Treat classic-script bundling warnings separately from missing-file errors; those scripts use the manual-copy plugin.

## Runtime diagnosis

- Access denied: inspect the applicable viewer, upload, or advanced list without dumping credentials or user tokens.
- Session restoration: inspect `GoogleAuth.checkSession`; it reads localStorage and is not a server session validation step.
- Missing status: distinguish proxy failure, printer failure, idle-job fields, and cached placeholder data.
- Missing model: check `window.modelCatalog.resolve(<value>)` first; `null` means the legacy path, which substitutes `.stl` for the final extension. Do not assume the printer upload populated the model library.
- A glTF view that renders nearly black: check that `/images/envmaps/fishermans_bastion/*.jpg` loads. A Z-up STL standing on its edge: something is turning the camera although the importer already rotated the model.
- `[MODEL CATALOG] duplicate view ID` in the console: the generator emitted two views with one ID in a model; only the first is reachable.
- Offline stream: inspect stream response headers, multipart boundaries, frame progress, cancellation, and reconnect behavior without logging the upstream credential-bearing URL.
- Local stream 404: the private development server does not implement `/stream`; the example URL alone does not configure a working stream.
- Repeated notifications after restart: inspect the configured monitor-state path, writable volume, restored cooldowns, and milestones using sanitized output.
- Repair appears successful: confirm which server handled the request and whether Python actually ran. The production upload handler currently disables repair.
- Missing Python support: follow the wrapper's `isPyMeshLabInstalled` check; requirements and image build status are insufficient evidence.
- Missing activity logs: inspect the browser's `/api/log.php` request, PHP routing, and writable log directory in an authorized runtime.

## Older documentation

- Use the canonical deep-dive files linked by `AGENTS.md` as the operating reference.
- Treat `docs/STL_REPAIR_GUIDE.md` as historical ADMesh material; its function names do not match the current wrapper.
- Treat README claims about complete repair installation and example setup as unverified where contradicted by current source.
- The SCSS prohibition was superseded by Ziad on 2026-10-20 with npm-managed compilation and watch mode. Keep the inherited firmware observation and host-networking rationale until explicitly superseded; unresolved evidence is recorded in `docs/decisions.md`.
- Do not copy old credential examples, full config dumps, or blind remote probes into new debugging instructions.
