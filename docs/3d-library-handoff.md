# Unified 3D project handoff

Implemented locally on 2026-10-20 with the website at `/Users/ziad/www/feralcreative/3d.feralcreative.co` and the complete CAD tree under `cad/`. The current branch is `feat/unified-3d-library`. Both original Git histories are preserved by an unsquashed subtree import; CAD branch refs are retained under `cad-history/`. The integration changes remain uncommitted alongside the preserved pre-existing website and CAD work, rather than bundling that unfinished work into implementation commits.

## Standalone repository retired

The physical old checkout is now on clean `main` at `a2df3e3`, tagged `archive/scad-2026-10-20`; all remaining branch history has been merged and oversized assets converted to Git LFS for GitHub publication. Its final state and every legacy branch are preserved in this repository under `cad-history/`; the original shade-drive branch tip remains recoverable there after its history was merged into the retired main. See [the archive handoff](3d-library-archive.md). This close-out leaves the active unified branch and pending implementation intact. The explicitly authorized final main/tag publication and GitHub archival are complete and verified; only main remains in the retired repository. Details are in the archive handoff.

## Recovery and compatibility

The former `/Users/ziad/www/feralcreative/scad` path is a compatibility symlink to the canonical `cad/` directory. Its original checkout is retained at `/Users/ziad/www/feralcreative/scad.pre-consolidation-20261020`. The website's pre-import stash was reapplied and retained as a recovery point. Private runtime files and CAD workspaces were preserved locally, and existing external symlinks were copied without following them. BOSL2 is registered in the root `.gitmodules` at `cad/lib/BOSL2`, pinned to `f1493a8425f51bd0585dd6d89aea962561100d32`.

Open the canonical root in the editor for future work. Root forwarding commands preserve the build, render, slice, coupon, finalize and clean entrypoints; existing commands also work from `cad/`.

## Catalog and presentations

The generated catalog contains all 256 model entries: 222 have browser-supported previews, two have STEP downloads but no supported browser preview, and 32 have no display mesh. Source downloads remain available where present. All configured SCAD presentations exported successfully. The pumpkin has seated and exploded door views; the can-holder presentations preserve olive `#90A553` and gold `#FFD700`. Retained files are not declared physically tested by catalog inclusion or finalization.

Run `utils/models.sh --render-colours` from the root to regenerate the complete catalog and configured coloured views. Generated outputs remain in model-local `_work/web/` and `cad/_work/site-models/`, outside the application image. The publication helper sends referenced assets before `catalog.json`, stops if an asset transfer fails, and never deletes unrelated remote files. `utils/models.sh --push --dry-run` is an offline preview. `utils/finalize.sh --all --push` finalizes existing generated exports first, then stages/publishes the complete catalog; it does not rebuild or slice every model.

## Verification and limits

- Library validation: 256 manifests and 2,636 aliases pass.
- Automated checks: 17 library/finalization tests, six colour/catalog tests, and two mocked publication/wrapper tests pass. Publication tests never contact the NAS.
- Catalog integrity: every referenced file exists within the CAD tree; all view IDs within each model are unique.
- Website syntax and `npm run build` pass. Build artifacts include the viewer and lighting assets; the CAD archive is excluded. Existing classic-script notices and the lazy viewer chunk-size warning remain.
- Browser verification covers real coloured pumpkin and can-holder views, dimensions, legacy STL links, selectable presentations, source/download-only states, navigation history, keyboard focus and phone layouts. See [Claude's browser report](3d-library-claude-implementation.md). Generated evidence copies are in root `_work/verification/`.
- The three conversion warnings are G-code-only/meshless 3MF archives; other models continue to generate. Large retained meshes are still large downloads.
- The container build and Nginx runtime were not executed because no local Docker daemon or Nginx was available. Real authentication, production printer monitoring, GPU-specific rendering, Safari/Firefox and physical prints are outside the local checks.

No website deployment, NAS upload or printer action was performed. The subsequent standalone SCAD GitHub close-out is recorded in the archive handoff. Publishing the catalog and deploying the changed website remain separate, explicit production operations. The local development stack is managed in tmux session `3d_feralcreative_co`.

## Installer policy

DMG and PKG installers are excluded from the active tree, local branch/tag history and future commits by `.gitignore`. Pending CAD and website edits remain intact. The archived SCAD repository was republished without installers and re-archived; see the archive handoff for the current commit and the separate GitHub LFS storage-retention limitation.
