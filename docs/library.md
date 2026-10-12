# Model library workflow

Every model or assembly lives in `library/<category>/<model-id>/`. Its source files, retained printable files, instructions, and licenses stay together. Shared BOSL2, logo modules, utilities, and printer profiles remain at the repository root.

## Folder roles

| Location within a model | Role |
| --- | --- |
| `model.json` | Stable model ID, SCAD entrypoint, origin, status, export names, source-asset protection, and aliases for former paths. |
| `*.scad`, `*.skp`, `*.stl`, `*.3mf` | Retained sources or printable files. A mesh-only model's STL may be its only source. |
| `originals/` | Upstream or earlier design assets, retaining original filenames and folders. |
| `docs/` | Model-specific notes, licenses, instructions, and PDFs. |
| `saved-jobs/` | Previously retained slicer jobs. Migration preserves these files and their embedded settings unchanged. |
| `_work/stl/` | New builds, numbered drafts, current plain-name copies, and fit coupons. |
| `_work/renders/` | Seven-view previews. |
| `_work/slice/` | G-code, resolved profiles, and slicer diagnostics. |
| `_work/3mf/` | Newly generated, named printer-job copies. |

Only `_work/` is regenerable library output. It is gitignored. Source assets and retained model files are committed, including model PDFs and upstream download archives. Cleanup never traverses retained model assets.

Migration also retains previously committed working STL deliverables as snapshots. Their `draft_exports` entries keep them out of the publisher's default finished selection until explicit finalization; `--all` can select their current workspace copy. Retention does not imply physical print success.

## Finding and identifying models

Open [the catalog](../library/README.md), browse the category folders, or filter the inventory:

```bash
python3 utils/library.py list --scad yes
python3 utils/library.py list --scad no
python3 utils/library.py list --origin adapted
python3 utils/library.py list --category hand-tools
```

`origin` is `authored` for designs created here, `adapted` for known adaptations, `imported` for identified downloads, and `legacy` where earlier provenance has not been established. SCAD availability is recorded separately. `status` records design progress; migration does not infer physical print success from an existing file.

A stable model ID is unique across the library. Export names also remain globally unique because the version ledger, print history, and printer site's flat namespace use those names. A multi-piece assembly keeps its separate SCAD sources and exports in one folder.

## Designing and printing

The existing utilities accept a model ID, a current source path, or an indexed former path. Old `parts/<name>.scad` command lines continue to resolve through metadata; source files have one actual home.

```bash
utils/render.sh awl-sheath
utils/build.sh awl-sheath
utils/coupon.sh awl-sheath
utils/slice.sh library/hand-tools/awl-sheath/_work/stl/awl-sheath-coupon.stl
```

A model with several SCAD sources can select the desired file directly:

```bash
utils/build.sh library/3d-printer-tools/overture-spool/overture-spool-screwtop-ribbed.scad
```

An imported model can be sliced by naming its STL or 3MF. Give a new job a distinct name when the original project has the same basename:

```bash
utils/slice.sh library/3d-printer-tools/bed-scraper/Scraper_no_words.stl --name bed-scraper-ad5m-pro
```

The model resolver supplies folder defaults and required OpenSCAD feature flags. Explicit `OUTDIR`, `OUTROOT`, and `MF_ROOT` overrides still work. Printer-profile resolution, G-code probing, magnet pauses, coupon component hashes, version numbering, and the explicit `--printed` operation retain their existing behavior. Slicing sends nothing to the printer.

## Retaining finished outputs

```bash
utils/finalize.sh awl-sheath
```

Finalization promotes workspace plain-name STL exports and matching generated 3MF jobs into the model folder. It removes obsolete numbered drafts, coupons, and corresponding renders; it leaves the version ledger unchanged. Imported models can retain newly sliced jobs without a SCAD source. A source project or mesh listed in `protected_assets` is never overwritten by finalization; use a distinct generated output name.

```bash
utils/clean.sh
utils/clean.sh --stale 7
utils/clean.sh --all
```

These commands preview cleanup. `--apply` removes selected workspace files. Retained sources, PDFs, licenses, original versioned meshes, and saved jobs are preserved. The model-folder workspace also protects source data before it has been staged in Git.

`utils/finalize.sh --shitcan <export>` previews removal of that generated output, its retained deliverables, and its ledger/history rows. Add `--apply` to perform the removal. Protected source assets, model metadata, original downloads, licenses, and saved jobs stay in place.

## Maintaining the inventory

```bash
python3 utils/library.py check
python3 utils/library.py catalog
python3 utils/test-library.py
```

Keep `model.json` with the model. Add a source path to `scad_files`, choose its default `scad` entrypoint, and add retained input files to `protected_assets`. Successful builds register new globally unique export names. Aliases are compatibility records, not symlinks or copies. `docs/library-migration.json` records persistent file moves and their hashes.

`utils/migrate-library.py` plans remaining moves without changing files. `--apply` performs no-overwrite moves and rewrites source references to their new relative paths. It preserves existing model metadata and skips non-model software/configuration material and unrelated documents.
