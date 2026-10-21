# Architecture

How the pieces fit. Read before changing a script or adding a stage to the loop.

## Directory roles

| Path | Role |
| --- | --- |
| `library/<category>/[<subcategory>/]<model-id>/` | Model sources, retained print files, model notes, and `model.json`. SCAD availability and provenance are separate metadata. |
| `library/**/originals/` | Upstream and earlier assets, including measured meshes and their original companion files. |
| `library/**/docs/` | Model instructions, licenses, PDFs, and design notes. |
| `library/**/saved-jobs/` | Pre-existing slicer projects preserved during migration. |
| `library/**/_work/` | Regenerable STL drafts, seven-view renders, slice diagnostics, and generated 3MF jobs. Gitignored. |
| `logos/` | Shared artwork and `marks.scad`. Parts call the modules rather than importing SVGs. |
| `lib/BOSL2` | Shared Git submodule. |
| `docs/` | Global references, status, version ledger, print history, and durable slicer presets. |
| `utils/` | Utility entrypoints and `library.py`, which resolves model IDs and former paths. |
| `parts/`, `renders/`, `stl/`, `slice/`, `3mf/` | Legacy paths still accepted by the tools through aliases or fallback handling. New model work belongs in the library. |
| `_originals/`, `_incoming/` | Unmigrated non-model material and temporary incoming assets. Retained model dependencies belong with their model. |
| `MODELS` | Existing local symlink into the printer-site repo. Gitignored. |

See [the library workflow](library.md) for commands and metadata conventions.

## The four-stage loop

1. **Source**—the selected SCAD entrypoint in a model folder. Imported models can instead start from retained STL or 3MF files.
2. **See it**—`utils/render.sh <model-id>` writes seven PNGs into the model's `_work/renders/`. Read the iso view and all six orthographic elevations.
3. **Mesh it**—`utils/build.sh <model-id>` writes a binary numbered STL plus its current plain-name copy into `_work/stl/`. The global version ledger remains keyed by output name. OpenSCAD's summary and independent mesh checks verify topology; imported meshes may retain pre-existing defects.
4. **Slice it**—`utils/slice.sh <source-or-mesh>` uses `ffprofile.py` to resolve presets, slices locally into `_work/slice/<job>/`, probes the G-code, and copies a successfully exported job into `_work/3mf/<job>.3mf`. SCAD inputs use the mesh just built; `--with` and `--enforcer` also resolve indexed former paths.

`utils/finalize.sh <model-id-or-export>` promotes selected plain STL and 3MF outputs into the model folder and removes obsolete drafts. It preserves the version ledger and refuses to overwrite protected source assets. Cleanup traverses only `_work/` inside the library. Sources and licenses remain safe before they have been staged in Git. See `utils/test-library.py` for isolated routing and preservation checks.

Nothing in this loop sends a job to the printer. Migration preserves slicer projects and profiles without changing their settings.

## Slicer presets live in two places

Ziad works from two machines—Feral MacBook and Feral Studio—against one printer. Neither location is authoritative alone:

- `~/Library/Application Support/Orca-Flashforge/user/default/` is what Flash Studio actually reads. Outside version control, per-machine, one reinstall away from gone.
- `docs/profiles/` is the durable, diffable, shared record. It is inert—copying a file there changes no print.

`utils/profiles-check.sh` reports drift and moves presets either way (`--install`, `--capture`). Both directions have already caused real damage: a setting tuned on one machine and never committed is invisible on the other, and a setting committed but never installed is invisible to the GUI—that one ran a print at 265 °C while the repo said 240.

Every preset is two files: the `.json` with the settings and a `.info` sidecar that registers it in the dropdown. `profiles-check.sh` handles both, and it never touches the bundle's system profiles.

## The join to the printer site

The canonical project is `~/www/feralcreative/3d.feralcreative.co`, with website source at the root and this CAD toolchain under `cad/`. Both histories are preserved in the unified repository. The website streams printer video, displays status, and serves the model catalog. Publication remains independent of an application rebuild through the existing models bind mount:

```text
cad/library/              utils/models.sh stages selected files and catalog
    │
    ▼
NAS: /volume1/web/3d-printer-stream/public/models/
    │                     bind-mounted into the container
    ▼
3d.feralcreative.co       catalog-driven viewer serves them at /models
```

Retained STL deliverables are committed with their model here. Publication still uses rsync to the NAS: the publisher selects declared retained exports, or current workspace outputs with `--all`, and refuses duplicate filenames because the NAS directory is flat. A published STL appears in the viewer without a site rebuild because that directory is a bind mount.

The unified root `utils/models.sh` stages every model entry, selected retained files, and cached coloured GLB views into `cad/_work/site-models/`. `--render-colours` evaluates configured SCAD presentations through native coloured 3MF and converts them into standard metre/Y-up GLB with linear material factors. `--push` sends the selected asset set followed by `catalog.json`; unrelated NAS files are preserved. Imported meshes and source-only entries remain visible according to availability. The website consumes explicit formats rather than rewriting every model to STL. See the unified root `docs/model-catalog.md` for the contract.

`--push` writes to a live production host. It is opt-in, and only on Ziad's explicit request.
