> Implemented on 2026-10-20 in the canonical `3d.feralcreative.co` repository, with CAD under `cad/`. This document retains the initial planning evidence; the final layout, commands and verification are in [the root catalog guide](../../docs/model-catalog.md) and [implementation handoff](../../docs/3d-library-handoff.md).

# 3D library consolidation

## Objective and status

Ziad wants every model available through `3d.feralcreative.co`, including coloured interactive views, and explicitly requested that Codex work with Claude. Claude completed and revised its independent review after direct discussion and paired export tests. This brief records the agreed starting sequence and remaining technical questions; it does not record a production deployment or a completed consolidation.

## Verified starting point—2026-10-20

- Model repository: `/Users/ziad/www/feralcreative/scad`. Website repository: `/Users/ziad/www/feralcreative/3d.feralcreative.co`. Both have their own `AGENTS.md`; inspect current worktrees before any implementation.
- The model library has 256 manifests, 49 configured SCAD entrypoints, and 196 declared exports. 210 models have no declared exports; a case-insensitive inventory finds STL files within 166 of those model folders, excluding nested models' assets and `_work`. 34 have no retained STL, 3MF, OBJ, GLB or glTF. These counts are an inventory snapshot, not a statement that every mesh is a suitable presentation model.
- `utils/library.py` owns model resolution, manifest validation, finalization and publication selection. `utils/deploy/prod.sh` publishes selected STL exports to a flat runtime directory on the NAS. Protected assets, coupons, and explicit publication exclusions are excluded by the library selector.
- The website's `models.js` currently enumerates top-level STL files from `/model-catalog/`. `viewer-3d.js` forces model paths to `.stl`. The UI already has a dedicated signed-in model library; printer polling and streaming remain stopped on that page.
- The website uses `online-3d-viewer`. Its upstream supports glTF; actual colour fidelity and compatibility with the installed dependency still need a local proof.
- The NAS model directory is bind-mounted into the running site, allowing model publication independently of an application rebuild. Retain that operational property.
- Both repositories have work in progress. This checkout is on `feat/halloween-cat`; no branch switches, blanket staging, history rewriting, source deletion, or automatic production actions are part of the review.
- The website is on `feat/hub-access` with uncommitted catalog, viewer, auth, Docker, styling and documentation work. A history-only import would miss current changes, untracked additions and ignored runtime prerequisites. Its broad ignore rules also need to remain scoped to `web/` so they do not hide retained model archives or shared BOSL2 assets.

## Codex's proposal for review

Consolidate the website under `web/`, retaining the model repository's existing `library/`, `lib/`, `logos/`, `docs/`, and `utils/` paths. Preserve both Git histories and deliberately carry forward required uncommitted work and local-only runtime files without committing secrets. Exclude CAD archives and generated model work from the website's container build context.

Make model metadata drive a generated web catalog, including stable IDs, categories, selected presentation variants, printable downloads, attribution, and explicit availability when a model has no supported presentation file. Publish coloured GLB presentation assets alongside printable STLs. Imported/mesh-only models need an explicit selection policy; do not infer that every original mesh, support enforcer, test coupon, or archive should become a public model. Preserve existing exclusions until Ziad deliberately changes them.

Repository consolidation and complete publication coverage are separate deliverables. `finalize.sh --all --push` currently handles registered outputs and does not make all 256 model entries available. Coloured assemblies require a tested export method that preserves each SCAD piece's colour and position, including seated and exploded views.

## Requested Claude review

Write independent findings in `docs/3d-library-claude-review.md`. Challenge the repository layout and merge recommendation, identify migration risks in the website, propose the catalog/export contract and imported-model coverage policy, and recommend a safe implementation sequence. Check whether the current viewer can support GLB without replacement. Do not modify either application's implementation or perform Git/remote/deployment mutations during this review.

## Proposed division after review

- Codex: model metadata, presentation export, inventory coverage and publication selection.
- Claude: website catalog/viewer changes and website migration assessment.
- Agree on the shared catalog schema and file ownership before concurrent implementation. Record decisions and actual verification evidence here; do not claim that a brief was received or reviewed until Claude responds.

## Codex colour-export proof

On 2026-10-20, the existing native OpenSCAD successfully exported a local two-colour test to 3MF. The input was an olive base with an overlapping gold block:

```scad
color("#90A553") cube([20, 20, 2]);
color("Gold") translate([5, 5, 1.99]) cube([10, 10, 2]);
```

The archive contains base materials with `displaycolor="#90A553FF"` and `displaycolor="#FFD700FF"`; mesh triangles reference both through `pid`/`p1`. OpenSCAD reported `NoError`, genus 0. Temporary proof files are `/tmp/scad-colour-export-proof.scad` and `/tmp/scad-colour-export-proof.3mf` and are not project deliverables.

This proves native colour export for the small overlapping-solids case only. It does not yet prove full-assembly export, material mapping in GLB, or browser colour fidelity. Test direct coloured 3MF loading in the current viewer as well as 3MF-to-GLB conversion before making GLB mandatory; the simplest verified route should determine the presentation format. The catalog should describe presentation format explicitly rather than assume every view is STL or GLB.

The review request was submitted to Claude Code in the SCAD VS Code workspace on 2026-10-20; the UI confirmed Claude was working. Supplemental export evidence was exchanged in the same session (`440acb95-60ba-4fa5-9554-85039801b707`). Claude read the brief, wrote an independent review, tested Codex's actual GLB, and agreed to the corrections recorded below.

## Claude review and Codex response

Claude wrote [its independent review](3d-library-claude-review.md). It recommends proving the catalog integration across the existing repos before physically consolidating them. Codex accepts that implementation sequence: preserve the eventual monorepo option while proving the shared contract and one real coloured assembly first. The repository merge remains a proposal, not an operation performed or a prerequisite for the proof.

The implementation split remains Codex on model metadata, export and publication; Claude on the website catalog and viewer. Use a distinct command for the web-catalog generator: `library.py catalog` already generates `library/README.md` and must retain that entrypoint.

Codex sent the following points back for revision; Claude explicitly agreed to the corrections and incorporated them into its revised review:

- Keep GLB interoperable with other viewers: metres, Y-up, linear base-colour factors. Native 3MF can retain its declared millimetre/Z-up convention. The website should select the correct camera basis per presentation and use explicit original engineering dimensions, rather than changing the GLB convention to accommodate existing STL-statistics assumptions. The [glTF specification, coordinate system and units](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#coordinate-system-and-units) defines this convention.
- The current native two-colour 3MF was converted into `/tmp/scad-colour-export-proof.glb` with correct colour-space conversion, millimetre-to-metre scaling and `[x,z,-y]` axis mapping. Claude is checking that actual artifact with the installed viewer; its first fixture used sRGB fractions directly and therefore did not reproduce the source RGB values.
- Preserve the current SCAD colours by default, including Ziad's explicit colour choices. A further decision on hypothetical filament colours is not a prerequisite for the requested view.
- Preserve existing publication exclusions and access policy during the proof. Record the difference between listing authentication and direct-file access as an observation; do not silently expand authentication or introduce a new blanket publication embargo. Publishable file selection remains explicit, especially where several originals and variants exist.
- Retained model PDFs and licences are committed according to the current SCAD `AGENTS.md`; remove the review's contrary memory-derived assertion.
- Keep the website's `.gitignore` within `web/` if it moves, and use a website-only container build context. The reported ignored `.dockerignore`/Sass conflict is an inspected-code finding, not an executed Docker-build result.

### Paired format proof

Claude imported Codex's actual `/tmp/scad-colour-export-proof.glb` through the website's installed `online-3d-viewer` 0.18.0 engine. It returned olive RGB `(144, 165, 83)` and gold `(255, 215, 0)` exactly, and bounds consistent with the exported metre/Y-up geometry. This confirms the native SCAD → coloured 3MF → GLB → installed importer material round-trip for the small test.

Claude also parsed the native 3MF through the installed 3MF importer with a Node DOM shim. Geometry and dimensions were retained, but imported material values were `(16, 30, 2)` and `(255, 107, 0)`, differing materially from the source colours. This supports standard GLB as the leading presentation route. It is a Node importer test, not a completed browser render; browser colour fidelity, lighting, and a real multi-piece assembly still require verification. The small GLB proof contains a merged mesh with two material groups and does not prove independently selectable parts.

No application implementation, repository history, production files, or existing model sources have been changed by this collaboration review. Local proof files and the two review documents are the only new work.
