# AGENTS.md — Feral SCAD Parts

Parametric 3D-printed parts written in OpenSCAD, printed on one specific machine (FlashForge Adventurer 5M Pro), sliced with Flash Studio. Owner: Ziad (Feral Creative). There is no application, no test suite, and no package manager here—the "build" is geometry, and the checks are visual and G-code-level.

**Read [docs/STATUS.md](docs/STATUS.md) before touching a print setting or the chalk holder.** It records where the part stands and how a whole session was lost to tuning that was never the problem.

## 1. Commands

| Task                                                                        | Command                                                                                                           |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Install deps (BOSL2 submodule)                                              | `git submodule update --init`                                                                                     |
| Render a part to seven PNGs (iso and six elevations)                              | `utils/render.sh <source.scad>`                                                                               |
| Render a variant without editing the file                                   | `utils/render.sh <source.scad> -D 'outer_d=30'`                                                               |
| Build STL (binary, versioned, reports manifold + genus)                     | `utils/build.sh <source.scad>`                                                                                |
| Build a named variant, with its own version series                          | `utils/build.sh <source.scad> -D 'show="coupon"' --name <part>-coupon`                                        |
| Restamp instead of incrementing                                             | `utils/build.sh <source.scad> --version 3`                                                                    |
| Build with no version stamp at all                                          | `utils/build.sh <source.scad> --no-version`                                                                   |
| Collapse a finished part to one file, and delete its coupons and renders   | `utils/finalize.sh <name>`                                                                                        |
| Build to an explicit scratch folder                               | `OUTDIR=/tmp/model-build utils/build.sh <source.scad>`                                               |
| Collapse every finished series                                              | `utils/finalize.sh --all`                                                                                         |
| Collapse every name matching a pattern (quote it — zsh drops an unmatched glob) | `utils/finalize.sh 'delonghi-heater-stand*'` (or `stl/delonghi-heater-stand*`, which the shell can expand)  |
| Throw an output away for good — meshes, renders, slice job, ledger line     | `utils/finalize.sh --shitcan <name>` (lists and stops; `--apply` removes)                                         |
| Show what generated output could go (deletes nothing)                       | `utils/clean.sh`                                                                                                  |
| Delete it                                                                   | `utils/clean.sh --apply`                                                                                          |
| Also age out past models — renders, 3mf and slice jobs untouched for N days | `utils/clean.sh --stale 7 --apply`                                                                                |
| Every regenerable byte, keeping only `.keep` and tracked files              | `utils/clean.sh --all --apply`                                                                                    |
| Build ASCII STL (to read or diff a mesh)                                    | `utils/build.sh <source.scad> --ascii`                                                                        |
| Publish STL to the printer site's NAS                                       | `utils/build.sh <source.scad> --push` (needs explicit permission)                                             |
| Mirror every finished (unversioned, no drafts beside it) STL to the NAS     | `utils/deploy/prod.sh` (needs explicit permission; `--dry-run` to preview, `--all` to include parts still moving) |
| Build a coupon of only what changed since the last print                    | `utils/coupon.sh <source.scad>`                                                                               |
| Coupon with every component, ignoring the log                               | `utils/coupon.sh <source.scad> --all`                                                                         |
| Record that the last coupon was printed                                     | `utils/coupon.sh <source.scad> --printed`                                                                     |
| Turn a one-path SVG trace into a BOSL2 bezpath to paste into a part        | `utils/svg2bez.py "_incoming/<trace>.svg" --height 80` (or `--width`)                                          |
| Split a scanned STL into its overlapping shells so a part can union them   | `utils/stl-shells.py "_incoming/<thing>/mesh.stl"` (then `import()` each shell; see Gotchas)                    |
| Bend budget for the screen-fence clip's legs                                | `utils/legcheck.py`                                                                                               |
| Compare leg section options                                                 | `utils/legcheck.py --sweep`                                                                                       |
| Slice and verify the job                                                    | `utils/slice.sh <model-folder>/<output>.stl` or `utils/slice.sh <source.scad>`                                             |
| Slice a Gridfinity STL with buried magnets and verify its native pause      | `utils/slice.sh library/gridfinity/gridfinity/<output>.stl --magnet-pause` (layer heights read from the process profile, so `PROCESS="0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle"` works as well as the 0.30/0.12 default; pause height read from the cavities: layer 21 for bins and trays, layer 63 for the upside-down `wire-shelf-gridfinity-4x2`; needs a `python3` with Pillow, which Homebrew's lacks—`PATH="/usr/bin:$PATH"` works) |
| Slice several pieces on one plate with a magnet pause, supports only inside an enforcer volume | `FILAMENT="Flashforge Generic PLA" utils/slice.sh library/gridfinity/gridfinity/<magnet-part>.stl --magnet-pause --with library/gridfinity/gridfinity/<other>.stl --enforcer library/gridfinity/gridfinity/<enforcer>.stl [--enforcer …] --name <job> --set process:enable_support=1 --set 'process:support_type=normal(manual)' --set process:independent_support_layer_height=0` (all STLs exported from one layout; the verifier fails on any support in a magnet cavity) |
| Slice against untuned FlashForge stack                                      | `utils/slice.sh <model-folder>/<output>.stl --stock`                                                                           |
| One-off slicer override                                                     | `utils/slice.sh <model-folder>/<output>.stl --set filament:nozzle_temperature=235`                                             |
| Role breakdown at a height                                                  | `utils/slice.sh <model-folder>/<output>.stl --at-z 38`                                                                         |
| Read a sliced job back                                                      | `utils/gcode-probe.py <model-folder>/_work/slice/<job>/plate_1.gcode`                                                                 |
| Resolve slicer profile inheritance                                          | `utils/ffprofile.py --machine … --process … --filament … --outdir …`                                              |
| Preset drift report (app vs repo)                                           | `utils/profiles-check.sh`                                                                                         |
| Push presets repo → app                                                     | `utils/profiles-check.sh --install` (then restart Flash Studio)                                                   |
| Capture presets app → repo                                                  | `utils/profiles-check.sh --capture`                                                                               |

There is no lint, format, typecheck, or dev server. OpenSCAD lives at `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` and is not on `PATH`; the scripts fall back to it. Flash Studio lives at `/Applications/Flash Studio.app`; override with `FS_APP`.

`slice.sh` exports nothing to the printer. Sending a job is a separate, deliberate act performed by Ziad.

## 2. Definition of done

For a geometry change:

1. `utils/render.sh <source.scad>`, then **read all seven PNGs**. One view hides things—a tab on the wrong side is invisible head-on, and an opposite face is a different picture, not a mirror of one you have already seen.
2. `utils/build.sh <source.scad>`, then read the geometry summary. `Status: NoError` means manifold. `Genus` counts through-holes: a part with one bore reports `Genus: 1`. If you punched a hole and genus came back `0`, the cut did not go through.
3. Hand the renders to Ziad for the visual call. Do not self-certify appearance in a loop.
4. **If the part has to go into or onto something, prove it can GET there — not just that it fits once seated.** Model the mating part, boolean-intersect the seated pose, and then run a configuration-space path search from outside. A clean intersection is not a pass; neither is "collision-free placements exist at every tilt". `screen-fence-rail.scad` shipped twice on that mistake. Method and the specific traps are in [docs/debugging.md](docs/debugging.md).

For a print-setting change (rare—see Prohibitions):

1. Change the value in `docs/profiles/`, not in a script and not only in the GUI.
2. `utils/profiles-check.sh --install`, then restart Flash Studio.
3. `utils/slice.sh …` and confirm the value in the probe output. The G-code is the only place a setting is real.

Not required: nothing here needs a full print to be considered done by you. Printing is Ziad's step, and one variable at a time.

## 3. Prohibitions

- **Never write `.scad` and hand it over without looking at a render.** A render you have not looked at is work not done. Blind solid geometry produces plausible code with wrong results—the code compiles, the STL exports, the part is garbage.
- **Never `git push` without explicit permission.** Commits are made by the agent in logical blocks; see Commit conventions.
- **Never pass `--push` or run `utils/deploy/prod.sh` on your own initiative.** Both rsync to a live production host (the NAS backing <https://3d.feralcreative.co>). Only when Ziad asks. The destination for `prod.sh` is read from `.vscode/sftp.json`; `build.sh --push` still carries its own copy of the host.
- **Never verify a print setting in the slicer GUI.** Verify in the G-code with `utils/gcode-probe.py`. On 2026-08-09 a correct, correctly-selected filament preset contributed nothing to a job, the print ran 25 °C too hot, and it cost the top 6.41 mm of a collet.
- **Never reintroduce a hardcoded override array in `utils/slice.sh`.** It used to carry `LOW_STRING` `--set` flags and apply them by default; command-line overrides outrank presets, so it silently beat everything in `docs/profiles/`—including a retraction length of 1.6 mm that kept being applied for hours after the preset had been corrected to 0.4, and which ground the extruder. If a value needs changing, change the preset.
- **Be very reluctant to tune print settings at all.** Retraction length and temperature both trade against feed reliability. The 2026-08-10 session traded three working prints for a cosmetic stringing complaint and jammed the feed drive three times. Change one thing, print a part, then change the next.
- **Never `import()` an SVG from a part.** Use `include <../logos/marks.scad>` and the modules there. Reasons in [docs/decisions.md](docs/decisions.md); the failure is silent—a missing import prints an ERROR and then _exits 0_, so `build.sh` reports success and hands you an STL with no artwork on it.
- **Do not hand-edit generated model work:** `library/**/_work/` and the remaining legacy generated trees. Retained files outside `_work/` are source assets or selected deliverables; cleanup must preserve them. `MODELS` remains a local symlink into the printer-site repo.
- **Do not edit `lib/BOSL2`.** It is a git submodule (v2.0.755); changes belong upstream.
- **Do not investigate Ziad's machine to answer questions about his setup.** If you need to know whether something is installed or how it is configured, ask him.
- **Do not migrate the Dropbox SketchUp archive** at `/Volumes/Feral SSD/Dropbox (Personal)/_FERAL/3d`. It stays where it is; this repo is a change of method, not a migration.

## 4. Architecture

There is no runtime. Every model or assembly lives in `library/<category>/<model-id>/`, with optional subcategories such as `library/holiday/halloween/<model-id>/`; its `model.json` records origin, configured SCAD entrypoint, sources, export names, and old-path aliases. Read [docs/library.md](docs/library.md) and browse [library/README.md](library/README.md).

1. Retained source: the model's SCAD files, original meshes, SketchUp files, and companion assets. Shared BOSL2 and artwork remain at the repository root. An imported mesh can be the only source; never assume an STL is disposable.
2. `utils/render.sh <model-id-or-source>` → model-local `_work/renders/<source>-{iso,zplus,zminus,yminus,yplus,xplus,xminus}.png`. Camera names identify axis positions, not the part's own front/back vocabulary. Read all seven views.
3. `utils/build.sh <model-id-or-source>` → `_work/stl/<output>-vNN.stl` and a real current plain-name copy. The global version ledger stays in `docs/stl-versions.txt`. Output names must be globally unique; the builder rejects collisions before consuming a version.
4. `utils/slice.sh <model-id-or-source-or-mesh>` → `_work/slice/<job>/` plus `_work/3mf/<job>.3mf` after successful export. Preset resolution and G-code verification are unchanged. Slicing sends nothing to the printer.

`utils/finalize.sh <model-id-or-export>` promotes generated plain-name STL/3MF deliverables into the model folder, deletes numbered drafts and coupons, and preserves the version ledger. Protected source assets are never overwritten. Finalization is an intentional design decision; migration does not declare a part physically tested. `utils/clean.sh` touches only model `_work/` folders and remaining legacy generated trees. `--shitcan` previews generated output removal and preserves source assets, original downloads, licenses, and saved jobs; `--apply` removes the listed outputs and their ledger/history rows.

The existing commands accept former paths through metadata aliases. New files belong in the model folder, with model-specific docs in `docs/` there. Global workflow docs and profiles remain under root `docs/`.

Non-obvious coupling:

- **`OPENSCADPATH`.** `lib/` is not a directory OpenSCAD searches. `render.sh` and `build.sh` export `OPENSCADPATH` themselves, so `include <BOSL2/std.scad>` resolves. Invoking the `openscad` binary directly, outside the scripts, will fail to resolve it. So does opening the part in the OpenSCAD GUI. `include <../lib/BOSL2/std.scad>` resolves relative to the part's own file and works in both; `delonghi-heater-stand.scad` does it that way, the chalk-holder parts still use the bare form.
- **A coupon carries only what changed since the last print, by default.** `utils/coupon.sh` hashes each component's mesh, compares it against `docs/print-log.txt`, and leaves off anything identical to what was last printed — reprinting an unchanged half costs plate time and answers nothing. The part declares its own components in two comment directives (`// COUPON-COMPONENTS:`, `// COUPON-PLATE:`); the script knows nothing about any particular part. Nothing in the repo can see a print, so the printed columns move only when Ziad runs `--printed`. Pass `--all` to override.
- **The STL version counter is committed; the versioned STLs are not.** `docs/stl-versions.txt` holds one `<name> <n>` line per output name and is the only durable record of where a series is up to — every `-vNN.stl` is gitignored and regenerable, so a counter kept beside the meshes would reset to v1 the first time the tree was cleaned. It counts builds, not design changes. The finished unversioned file is committed and does not affect this.
- **The NAS is the only join to the printer site.** `~/www/feral/3d.feralcreative.co` shares no code and no history with this repo. `build.sh --push` rsyncs an STL to `/volume1/web/3d-printer-stream/public/models`, which is bind-mounted into that container, so a new model appears in the web viewer immediately with no rebuild and no deploy.
- **Slicer presets exist in two places and drift.** See [docs/architecture.md](docs/architecture.md).

## 5. Conventions

Follow these conventions when creating a SCAD source in its model folder:

1. Parameters at the top, grouped under `/* [Section] */` headers. Those are what OpenSCAD's Customizer panel reads, so grouping is functional.
2. Every dimension a named parameter with a unit comment. No bare numbers buried in geometry.
3. Geometry inside a named `module`, with a single call at the bottom.
4. `$fn` set once near the top. Keep it moderate while iterating; raise it before the final STL.
5. `eps = 0.01` overshoot on every subtracted solid, so no cut face is coplanar with its parent.
6. Multi-variant parts expose `show = "…";` with the choices in a trailing `// [a, b, c]` comment, and select with `-D 'show="coupon"'`.
7. Prefix parameter names per sub-assembly in merged files (`ring_collar_d`, not `collar_d`). OpenSCAD has no namespaces and the last top-level assignment wins file-wide.
8. Artwork goes through `logos/marks.scad`: `hobbs_mark(width)`, `hobbs_mark_figure`, `hobbs_mark_word`, `hobbs_word_alone`, `feral_logo`, `feral_favicon`, `vmc_top_rocker`, `zr_mark`, `zr_monogram`, `wagon_queen`, `wagon_queen_crest`, `wagon_queen_word`, `wagon_queen_crest_alone`, each centred on the origin and scaled to the width given, plus `*_height(width)` functions. Only the Hobbs figure, the two ZR marks, the feral favicon, and the Wagon Queen crest may be cut through; everything else has counters that a through-cut drops out. `zr_monogram` is a hairline design — swell it before cutting, see the ⚠️ on that module. `logos/marks-gallery.scad` draws every mark, labelled and flagged for cut-safety — open that in OpenSCAD to look at them, because `marks.scad` calls none of its own modules and previews empty, and it has to stay that way: `include` splices top-level geometry into the including part. A `*_height()` answers for its own bounding box, which is not always the module of the same name — `hobbs_word_height` and `wagon_queen_crest_height` describe the `_alone` variants, and a half-mark registered to a lockup's box comes out smaller than its own height function says.
9. **Every separately printed piece gets its own `color()`**, set as a named parameter under `/* [Colors] */` and applied inside the piece's module, so every view that shows it—assembled, exploded, or coupon—tells the pieces apart. Preview only; STLs carry no colour. Ziad's standing rule, 2026-10-03; `library/gridfinity/gridfinity/wire-shelf-gridfinity-4x2.scad` shows the pattern.
10. **Every wire shelf part mounts with the proven rail.** `use <wire-shelf-box-platform.scad>` and call `channel_cut(length)` and `floor_wire_reliefs(width)` with their defaults: 4.5 mm open-bottom slots (3.5 mm wire + 0.5 per side) on a 20 mm pitch, plus slots for the front edge's support wires 114 mm apart in the clear, from the shelf face to just past the lower rail, with the outer jaw solid and the deck underside at Z=38.7. Ziad printed it as a coupon on 2026-10-03 and it fit perfectly—do not redraw, rescale, or retune it. The cup holder and `library/gridfinity/gridfinity/wire-shelf-gridfinity-4x2.scad` show the pattern.
11. **Use the proven two-piece sliding dovetail for every new or redesigned wire shelf part.** Ziad reported the complete Gridfinity shelf printed perfectly on 2026-10-05 and chose its dovetail style as the standard from now on. The reference is `library/gridfinity/gridfinity/wire-shelf-gridfinity-4x2.scad`; `use <wire-shelf-dovetail.scad>` provides the same section for other parts: male tail on the separate mounting rail, female groove in the deck/body underside, sliding along X. Preserve its 5 mm groove mouth, 7 mm roof, 2.94 mm depth, 0.2 mm clearance per face, and 0.5 mm mouth chamfer. Print the rail as mounted, channel mouth on the bed and tail up; print the deck/body underside on the bed, with its working face up. The 7 mm groove roof bridges without supports in the successfully printed shelf. Keep future parts support-free in these orientations and retain the proven shelf interface from rule 10. Change joint length and body geometry to suit the part; do not retune the tested joint cross-section or replace it with a one-piece mount by default. Current parts default to `show="print-set"`; available sets and verification boundaries are recorded in `docs/wire-shelf-sets.md`.

Scripts live in `utils/`, never `scripts/`. Documentation other than `README.md` and this file lives in `docs/`. Bash scripts are `set -euo pipefail` with a header comment explaining why the script exists, not what it does.

## 6. Gotchas

- **OpenSCAD variables are not variables.** They behave like compile-time constants: assignment is not sequential and the last assignment in a scope wins regardless of position. Never write code that depends on reassignment.
- **A missing `include`/`import` exits 0.** OpenSCAD prints an ERROR and succeeds, so `build.sh` reports a clean build of a part with a piece missing. Check the render, not the exit status.
- **`difference()` subtracts every child after the first.** A misplaced brace silently changes the result.
- **Polygons are inscribed**, so holes come out undersized before any printing effect is considered. See the faceting rules in the printer reference.
- **`build.sh` on a complex part is genuinely slow** because it runs the real mesh computation, not the preview. It has not hung.
- **A wall thickness that is not an integer multiple of the extrusion width prints with gaps or over-extrusion.** On a 0.4 nozzle, 2 mm is a bad number; 1.68 and 2.10 are good ones. Inner walls are 0.45, not 0.42—the slicing reference corrects the design reference here.
- **A variant built without `--name` shares the parent part's version series and overwrites its file.** The stamp is keyed on the output name and the default name is the `.scad`'s basename, so `-D 'show="coupon"'` alone produces another `hobbs-chalk-holder-vN.stl`, not a coupon of its own. Name the variant.
- **Installing a preset is not applying it, and applying it is not reaching the job.** Verify in G-code.
- **A preset is two files.** The `.json` holds the settings; the `.info` sidecar is how Flash Studio registers it. Copy only the `.json` and the preset never appears in the dropdown, with no error and no clue.
- **The plate type is a project setting, not a preset one.** No profile carries `curr_bed_type` and the CLI has no flag for it, so every job used to slice for a "Cool Plate" the machine does not have. `slice.sh` now passes `BED_TYPE` (default `Textured PEI Plate`) through `ffprofile.py --bed-type`, which writes it into the process settings; it selects which of the filament preset's `*_plate_temp` values the slicer reads. Check `; curr_bed_type =` in the G-code header.
- **`--export-3mf` resolves relative to `--outputdir`; `--export-settings` ignores `--outputdir` entirely.** Both quirks are already handled in `slice.sh`—do not "fix" the asymmetry.
- **The Flash Studio CLI does not walk `inherits` chains.** Point it at a bare child profile and only the keys physically in that file take effect; everything else falls back to slicer built-ins, not to the parent. That is why `ffprofile.py` exists, and why slicing straight from the bundle's PETG profile produced a PLA job with zero-width walls.
- **Legacy meshes retained under model `originals/` are measured, not authored.** The chalk holder and pyramid were remade from SketchUp-era meshes, so a number in those files may be a faithfully copied mistake rather than a decision—the thread groove was 0.596 mm deeper than anything needed.
- **Camera flags are verified on OpenSCAD 2026.06.12**, checked with a deliberately asymmetric rig. If you ever re-verify, do not use a rotationally symmetric part: its views are pixel-identical whether the flags work or not.
- **A render's name says where the camera is, not which side of the part you are looking at.** `zplus` is the camera on +Z; whether that is the part's front, back or end depends on the part — and on `flip`, which turns a part over for printing. The views were called iso/front/right/top until 2026-09-14 and that collided with the vocabulary inside the parts: on `doorbell-wire-channel.scad`, whose own front is its +Z face, the file called `-front.png` was an end-on view and `-top.png` was the back. Renders were read the wrong way round for a whole session before anyone noticed.
- **Render colours come from `docs/color-schemes/`, not from OpenSCAD's built-ins.** `render.sh` defaults to the repo's `Feral Magenta` scheme and copies every scheme in that directory into OpenSCAD's user config (`~/Library/Application Support/OpenSCAD/color-schemes/render/`) before rendering, because that is the only place OpenSCAD reads custom schemes from. Edit the JSON in the repo, never the installed copy; `COLORSCHEME=Cornfield` (or any built-in) overrides per run.
- **A render that looks broken may be the preview, not the part.** `render.sh` runs OpenSCAD in preview mode, and OpenCSG gives up on some parts — `deck-door-stop.scad` with its deboss loses its whole body and draws a few stray walls. Pass `--render=cgal` through `render.sh` before believing a part is broken; `build.sh` evaluates the real geometry and is never affected.
- **A DEBOSS IS INVISIBLE IN A FACE-ON ELEVATION, and the part is not broken.** A flat-bottomed recess cut into a plane parallel to the camera shows its floor at exactly the same shading as the surface around it, and its side walls edge-on, so an orthographic `xplus`-style view of a debossed plaque is a blank panel. `--render=cgal` does not help, because nothing is wrong. Read the `iso` for anything sunk into a flat face, or probe the mesh — `slim-can-holder-3in-12oz-wagon-queen.scad` was briefly called broken on exactly this, and the radii said otherwise (33.06 recess floor, 35.05 plaque floor).
- **Most of the time that preview is fixable, and the fix is `convexity`.** A `linear_extrude()` of a profile with several holes needs `convexity = 10` on the extrude, or preview shows the part gutted — faces missing, holes punched through the far wall. It is a hint to the preview rasteriser, changes no geometry, and costs nothing. `deck-door-stop-truss.scad` reproduced the same symptom as the deboss above and this cured it. Reach for it before reaching for `--render=cgal`.
- **A scanned mesh may be several overlapping shells in one STL, and `import()` keeps them that way.** Every boolean on that import leaves the overlaps in: negative genus, double-counted volume, internal faces for the slicer to guess about. Unioning the file with itself is worse (coincident faces; genus 980 on the fish). Split it with `utils/stl-shells.py` and `union()` the pieces as separate imports — `slim-can-holder-3in-12oz-fish.scad` does — and set the shell count from what the split printed, because a missing shell file is a warning and exit 0.
- **A model's source and generated meshes can share a basename.** Keep original inputs in `protected_assets`. Finalization refuses to overwrite them; name a new output distinctly.
- **The version ledger is keyed on output name, not folder.** `model.json` export names are globally unique. `build.sh` checks collisions before exporting. The NAS remains flat and its publisher also rejects duplicate filenames.
- **Retained library assets are committed; `_work/` is not.** Source PDFs, upstream archives, and original versioned meshes stay with the model and are preserved by cleanup.
- **Do not rebuild knowledge that is already written down.** The two references below were expensive to produce; read them rather than re-reading the app bundle or the web.

## 7. Commit and PR conventions

- Conventional Commits, imperative mood: `type(scope): subject`. Types in use: `feat`, `fix`, `docs`, `refactor`, `chore`, `revert`. Scopes are part or subsystem names (`chalk-holder`, `slicing`, `utils`, `logos`).
- **Use Ziad's configured Git name and identity and submit PRs through his account.** Never add co-author credit, generated-by text, or attribution for the agent or anyone else.
- **Standing authorization for personal/Feral projects:** the agent may create branches, commit in logical blocks, and submit PRs on Ziad's behalf without requesting per-task permission for those actions. One feature, fix, or refactor step per commit. Publishing a branch as necessary to submit a PR is included; unrelated pushes, deployment, and other remote mutations still need explicit permission. This personal/Feral rule, confirmed by Ziad on 2026-10-05, supersedes inherited per-task approval requirements for these Git actions; it does not extend to Cannonball/client projects.
- Never committed: `renders/`, `slice/`, `3mf/`, `_incoming/`, `MODELS`, `_PLANS` (which is why `docs/_PLANS/` is local-only—Ziad's call whether to unignore), and anything matching `.env*`. No file matching a `.gitignore` entry may be read into a commit, a log, or a chat response.
- **Retained model deliverables and sources are committed together.** Draft STLs, renders, G-code, and generated job copies remain under gitignored `_work/`; finalization promotes selected plain-name deliverables.
- Work on `main`. Branch first if the change is speculative.

## Credentials

No secrets are required to build, render, or slice. `--push` uses Ziad's existing SSH agent identity for the NAS; there is no key material, token, or `.env` in this repo, and none should be added.

| Variable       | Source                          | Notes                                                                                                    |
| -------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `OPENSCADPATH` | set by `render.sh` / `build.sh` | Points at `lib/`. Not a secret.                                                                          |
| `FS_APP`       | optional env override           | Path to Flash Studio, defaults to `/Applications/Flash Studio.app`.                                      |
| `APP_DIR`      | optional env override           | Flash Studio user preset tree, defaults to `~/Library/Application Support/Orca-Flashforge/user/default`. |

## 8. Deep-dive index

- [docs/STATUS.md](docs/STATUS.md) — current state of the chalk holder, what to try next, wrong turns already taken. Read before touching print settings or that part.
- [docs/architecture.md](docs/architecture.md) — pipeline stages, directory roles, preset drift, the NAS join. Read before changing a script or adding a stage.
- [docs/decisions.md](docs/decisions.md) — why the marks library, binary STL, `ffprofile.py`, repo-side presets, and the deferred configurator are the way they are. Read before "improving" any of them.
- [docs/debugging.md](docs/debugging.md) — known failure modes, where the logs are, what each verification artifact proves. Read when something built clean but came out wrong.
- [docs/flashforge-ad5m-pro-scad-reference.md](docs/flashforge-ad5m-pro-scad-reference.md) — the machine's constraint set: safe build envelope, wall-thickness ladders per nozzle, clearance ladders, faceting rules, materials matrix, OpenSCAD constants block. Read before picking a wall thickness, clearance, facet count, or plate position.
- [docs/flash-studio-slicing-reference.md](docs/flash-studio-slicing-reference.md) — the slicer as installed: profile paths, inheritance chains, resolved values, headless CLI. **Outranks the reference above wherever they disagree.** Read before quoting any print setting.
- [docs/printer-profile-research-prompt.md](docs/printer-profile-research-prompt.md) — the prompt that produced the design reference. Only needed if the hardware changes or someone wants the same document for another printer.
- [docs/\_PLANS/](docs/_PLANS/) — running record, one file per round, `part-NN-<UTC stamp>.md`. **Read the highest-numbered file before starting anything**, and check any siblings it references (a reverted patch parked for later sits next to the note explaining it). Write the next one at a stopping point rather than leaving state in a conversation.

Evidence markers in the two references are not interchangeable: `[SPEC]` is a hard constraint, `[FIELD]` a field report, `[DERIVED]` arithmetic done inside the document, and ⚠️ contested or unverified. A ⚠️ is something to raise with Ziad, not something to quietly design around.

## Maintenance

When a change makes anything in this file inaccurate—a command, a path, a convention, a prohibition—update this file in the same change.
