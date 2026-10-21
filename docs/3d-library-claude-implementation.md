# 3D library—Claude implementation log

Website side of the unified library on `feat/unified-3d-library`. It covers the catalog-driven model library, the view selector and downloads, model-ID and filename/alias deep links, the unmanaged STL fallback, Vite staging, and the Docker/Nginx changes. Codex owns `cad/**`, the generator (`cad/utils/web-library.py`, `utils/models.sh`), `docs/model-catalog.md`, and the root README, AGENTS, and gitignore. Git, NAS, printer, production proxy, and deployment were not touched.

## Status

Implemented and verified locally on 2026-10-20. The last build was `npm run build`, exit 0. The history-preserving subtree import of the CAD repository is committed (by Codex). The integration work, this website work included, is left uncommitted for Ziad's review, because the original website and CAD work-in-progress were already interleaved in the same files. Both original branches, the website stash, and the `scad.pre-consolidation-20261020` recovery checkout remain.

## Files changed

| File | Change |
| --- | --- |
| `viewer-3d.js` | Adds `ModelCatalog` (`window.modelCatalog`): it loads and validates `/models/catalog.json` and resolves IDs, filenames, aliases, and printer job stems. The modal gains a view selector (buttons for up to four views, a menu above that), a downloads menu, the `view` query parameter, notices for no-mesh, withheld, and download-only entries, per-format up-axis handling, and dimensions from `source_bounds_mm` or unit-scaled bounds. The unmanaged STL path is unchanged. |
| `models.js` | Lists catalog models (title, category, view count, availability badge, size), then an "Other files" group of unclaimed STLs from `/model-catalog/`. Search covers ID, title, category, aliases, and filenames. It reports a partial failure of either source and keeps the other. |
| `vite.config.js` | Serves `/models/<basename>` from `SITE_MODELS_DIR` (default `cad/_work/site-models`), then `public/models`, with a real 404. Refuses traversal, dotfiles, and symlinks that resolve outside the repository or staging directory. Lists both directories at `/model-catalog/`. Blocks `/cad/`. Ignores `cad/**` for watching and limits dependency scanning to `index.html`. |
| `Dockerfile` | Nginx gets `location ^~ /models/` (real 404, model MIME types, PHP handler kept out) and `location = /models/catalog.json` (`no-store`). Access is unchanged. |
| `.dockerignore` | Keeps `styles/scss/` in the context (the builder compiles it) and excludes `cad/`, `3d`, and `_PLANS/`. Previously gitignored; Codex has un-ignored it so it can be tracked. |
| `public/images/envmaps/fishermans_bastion/` | The viewer's configured environment map, copied from `online-3d-viewer/website/assets`, with its CC BY 3.0 `readme.txt`. It was missing, which rendered every glTF material nearly black. |
| `styles/scss/main.scss`, `styles/scss/_mixins.scss` | Styles for the catalog rows, badges, view selector, downloads menu, and notices. Also replaces the deprecated `map-*` and `lighten()` calls with `sass:map` and `color.adjust()`; compiled CSS is byte-identical. See "Open with Codex". |
| `index.html` | Search placeholder. |
| `docs/architecture.md`, `docs/api.md`, `docs/decisions.md`, `docs/debugging.md` | Catalog flow, routes, decisions, and diagnosis notes. |

## Contract handling

- **Formats.** Previewed: STL, 3MF, GLB, glTF, OBJ, PLY, and OFF. STEP, 3DM, and FCStd views are kept and shown as disabled ("download only"), and a model with no previewable view gets a "Download only" badge, never "viewable". Their OV importers fetch OCCT or rhino3dm from `cdn.jsdelivr.net` at runtime; enabling them is a separate decision.
- **Up axis.** OV already rotates every import upright from its importer's assumed up axis (`threemodelloader.js`: STL, 3MF, 3DM, and FCStd assume Z; glTF, OBJ, and STEP assume Y). The viewer only turns the camera for a declared Z-up file read by a Y-up importer, and warns on the reverse. My first version also turned the camera for Z-up STLs, which stood every STL on its edge; the browser check caught it.
- **Dimensions** come from `source_bounds_mm`. Without them (9 views in the real catalog), mesh bounds are scaled by `units`, and for Y-up files Y and Z are swapped back into source axes. Volume and area are scaled by `units³` and `units²`.
- **Duplicate view IDs** keep the first and log `[MODEL CATALOG] … duplicate view ID`. The generator no longer emits them; the defensive handling stays.
- **Missing or unreadable catalog:** a 404, or HTML served in place of the JSON (the current production fallback), is treated as no catalog, and the unmanaged STL list still works. A network failure shows a note and a retry.

## Verification

All checks ran on Vite at `http://127.0.0.1:5501` in tmux session `3d_feralcreative_co`, with headless Google Chrome via Playwright (SwiftShader WebGL). Scripts and screenshots live under `/private/tmp/claude-501/-Users-ziad-www-feralcreative-scad/440acb95-60ba-4fa5-9554-85039801b707/scratchpad/browser/`.

### Syntax and build

- `node --check` passed for `models.js`, `viewer-3d.js`, and `vite.config.js`.
- `npm run build` exited 0. `dist/` contains the copied scripts, bundled assets, manifest, entry HTML, and envmaps; there is no `cad` in `dist/`. Sass emits no warnings.

### HTTP checks (fixture catalog)

The fixture lives in `…/scratchpad/site-models/`.

| Request | Result |
| --- | --- |
| `/models/catalog.json` | 200 `application/json`, `no-store`; HEAD 200; POST 405 |
| `/models/colour-proof--assembled.glb` (staging), with and without `?v=` | 200 `model/gltf-binary` |
| `/models/5mp-riser.stl` (falls back to `public/models`) | 200 `model/stl` |
| `/models/nope.stl`, `..%2Fpackage.json`, `%2e%2e`, `.gitkeep`, `a%00b`, `sub/x.stl` | 404 |
| Staged symlink into `cad/library` / to `/etc/hosts` | 200 / 404 |
| `/cad/AGENTS.md`, `/cad` | 404 |
| `/models`, `/models/` | 200 HTML shell |
| `/model-catalog/` | 200, union of staging and `public/models` |

### Browser checks (fixture catalog)

- **Codex's GLB:** materials `144,165,83` and `255,215,0`, exact, plus an unused `249,215,44` (OpenSCAD's default colour). Camera up Y; dimensions `20.00 × 20.00 × 3.99 mm`; 999.00 mm³. Screenshot `02-glb.png`.
- **STL view of the same part:** default grey, the same dimensions and volume. After the up-axis fix the part lies flat, like the GLB.
- **Library:** 5 catalog rows plus 87 unclaimed files. The two catalog-claimed files are absent from "Other files"; the category search returns 1 of 92. Screenshot `01-library.png`.
- **View switching:** sets `&view=printable`; Back returns to the default; Escape closes and clears the query.
- **Deep links:** `colour-proof.stl`, `colour-proof-v01.stl` (alias), `colour-proof.3mf` (job stem), `COLOUR-PROOF`, `riser`, `5mp-riser.gcode`, and `batleth.stl` (unmanaged STL) all resolved. The no-mesh and withheld entries show neutral notices; a missing view file and an unknown job show red "Model file not found" errors.
- **Fallbacks:** catalog 404 or HTML → 89 unmanaged files and no error; listing failure → 5 catalog models and "Other files could not be listed." with retry; both failing → the connection error with retry.
- **Phone (390 px):** no horizontal overflow. Screenshots `05-phone-library.png` and `06-phone-modal.png`.

### Browser checks (real staging catalog)

Codex's generated catalog: 256 models, 1,125 staged entries.

- **Library:** "260 models" (256 catalog plus 4 unclaimed `public/models` files) loaded in about 0.4 s. Badges: 32 "No 3D view", 2 "Download only", which leaves 222 previewable, matching Codex's count. Screenshot `real/library.png`.
- **`fence-pumpkins`:** default "Door seated", GLB materials `255,140,0`, `205,133,63`, and `34,139,34`; `90.70 × 106.62 × 82.77 mm`. Exploded is `90.70 × 166.62 × 82.77 mm` with the same volume. Screenshots `real/pumpkin-assembled.png` and `real/pumpkin-exploded.png`.
- **`slim-can-holder`:** materials `144,165,83` and `255,215,0`. Its 16 views use the menu and its 15 downloads a dropdown; selecting a view, Back, and the menu state all behaved correctly. Screenshots `real/can-holder-exploded.png`, `real/downloads-open.png`, and `real/phone-can-holder.png`.
- **Legacy STL** `adv-5m-pro-lower-spool-holder`: upright, `137.65 × 156.95 × 59.00 mm`. Screenshot `real/legacy-stl.png`.
- **STEP-only** `bambu-lab-led-lamp-kit-001-v2` and `90034a570-…`: download-only notice, with the downloads menu open. On a phone the menu sits inside the viewport (7–358 px of 390). Screenshots `real/step-only.png` and `real/phone-step.png`.
- **No-mesh** `build-plate-caddy`: notice plus its `.skp` download. Screenshot `real/no-mesh-skp.png`.
- **`batleth.stl`** (old share link): resolves to catalog model `batleth`, default GLB view.
- **Job names:** `fence-pumpkin-traditional.3mf` and `.gcode` resolve to `fence-pumpkins`; `not-a-model.3mf` falls through to the STL path.
- The Tab focus trap held over 40 presses with the menus present.
- **Console:** no page errors. 30+ duplicate-view-ID warnings against the catalog as it was then (since resolved, below), and the expected 404 logs for the deliberately missing fixtures.
- **Codex's final regeneration:** 256 entries, 222 previews, 2 STEP download-only, 32 no-mesh; all catalog references resolve within `cad/`; 23 CAD/catalog tests and the website build pass (Codex's verification).

## Findings for Codex

1. **Duplicate view IDs within a model,** for example `bit-holder` (3), `filament-clip`, `tool-shelf`, `name-badge`, and `vmc-spoiler`: 30+ in all. **Resolved:** Codex fixed the generator and regenerated the catalog.
2. **Very large views:** `dogs-v-cats-chess--Cats.stl` is 150 MB, and a GLB is 105 MB. The library shows each size, but opening one downloads the whole file.
3. **Unused default material:** GLBs carry OpenSCAD's `#F9D72C` as an unreferenced material. It is harmless now, but uncoloured geometry would render yellow instead of the viewer's grey.
4. **Default view order:** the pumpkin and can holder already default to the seated/set view in the regenerated catalog.

## Sass cleanup

The deprecated `map-*` and `lighten()` calls were replaced under Ziad's standing rule that build warnings are fixed, not left as pre-existing. The compiled CSS is byte-identical. Codex agreed to keep it.

## Remaining limitations

- **Container and Nginx are unverified.** No Docker daemon or local nginx was available; I rendered the Dockerfile's Nginx config and read it (braces balance; the exact `= /models/` and `= /models/catalog.json` locations take precedence over `^~ /models/`). The production image needs a rebuild for the 404 and MIME changes, which is Ziad's deployment.
- **Model files remain public in production,** as before. `/models/catalog.json` is now one of them, and it lists every model. No auth change was made, per the handoff.
- **Real sign-in and signed-out states were not exercised.** Local checks used `DEV_MODE` on loopback. The printer stream page was not opened, to avoid contacting live endpoints; its `openModal(jobName)` path was checked through `modelCatalog.resolve`.
- **WebGL ran under SwiftShader,** not a GPU, and Safari and Firefox were not tested.
- **Remaining build warnings:** Vite's classic-script notices (expected under the manual-copy design) and the 1,059 kB `o3dv.module` chunk-size warning (already a lazy import). Neither is fixed here.
- **`.env` warning:** Vite logs that `NODE_ENV=production` in the private `.env` is unsupported. That file is private and untouched.
- **Local stack restored.** Ziad's `npm start` (both Sass watchers, the development `server.js` on 3001, and Vite on 5501) was stopped for testing. It is running again as `BROWSER=none npm start` in tmux session `3d_feralcreative_co`, on the same ports, against the default staging directory. No browser page was opened and the production proxy was not started.
