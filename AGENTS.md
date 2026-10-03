# AGENTS.md — Feral SCAD Parts

Parametric 3D-printed parts written in OpenSCAD, printed on one specific machine (FlashForge Adventurer 5M Pro), sliced with Flash Studio. Owner: Ziad (Feral Creative). There is no application, no test suite, and no package manager here—the "build" is geometry, and the checks are visual and G-code-level.

**Read [docs/STATUS.md](docs/STATUS.md) before touching a print setting or the chalk holder.** It records where the part stands and how a whole session was lost to tuning that was never the problem.

## 1. Commands

| Task                                                                        | Command                                                                                                           |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Install deps (BOSL2 submodule)                                              | `git submodule update --init`                                                                                     |
| Render a part to PNGs (iso, front, right, top)                              | `utils/render.sh parts/<part>.scad`                                                                               |
| Render a variant without editing the file                                   | `utils/render.sh parts/<part>.scad -D 'outer_d=30'`                                                               |
| Build STL (binary, versioned, reports manifold + genus)                     | `utils/build.sh parts/<part>.scad`                                                                                |
| Build a named variant, with its own version series                          | `utils/build.sh parts/<part>.scad -D 'show="coupon"' --name <part>-coupon`                                        |
| Restamp instead of incrementing                                             | `utils/build.sh parts/<part>.scad --version 3`                                                                    |
| Build with no version stamp at all                                          | `utils/build.sh parts/<part>.scad --no-version`                                                                   |
| Collapse a finished part to one file, and delete its coupons and renders   | `utils/finalize.sh <name>`                                                                                        |
| Build or finalize inside a subfolder of `stl/`                               | `OUTDIR=stl/gridfinity utils/build.sh parts/gridfinity/<part>.scad`                                               |
| Collapse every finished series                                              | `utils/finalize.sh --all`                                                                                         |
| Collapse every name matching a pattern (quote it — zsh drops an unmatched glob) | `utils/finalize.sh 'delonghi-heater-stand*'` (or `stl/delonghi-heater-stand*`, which the shell can expand)  |
| Throw an output away for good — meshes, renders, slice job, ledger line     | `utils/finalize.sh --shitcan <name>` (lists and stops; `--apply` removes)                                         |
| Show what generated output could go (deletes nothing)                       | `utils/clean.sh`                                                                                                  |
| Delete it                                                                   | `utils/clean.sh --apply`                                                                                          |
| Also age out past models — renders, 3mf and slice jobs untouched for N days | `utils/clean.sh --stale 7 --apply`                                                                                |
| Every regenerable byte, keeping only `.keep` and tracked files              | `utils/clean.sh --all --apply`                                                                                    |
| Build ASCII STL (to read or diff a mesh)                                    | `utils/build.sh parts/<part>.scad --ascii`                                                                        |
| Publish STL to the printer site's NAS                                       | `utils/build.sh parts/<part>.scad --push` (needs explicit permission)                                             |
| Mirror every finished (unversioned, no drafts beside it) STL to the NAS     | `utils/deploy/prod.sh` (needs explicit permission; `--dry-run` to preview, `--all` to include parts still moving) |
| Build a coupon of only what changed since the last print                    | `utils/coupon.sh parts/<part>.scad`                                                                               |
| Coupon with every component, ignoring the log                               | `utils/coupon.sh parts/<part>.scad --all`                                                                         |
| Record that the last coupon was printed                                     | `utils/coupon.sh parts/<part>.scad --printed`                                                                     |
| Turn a one-path SVG trace into a BOSL2 bezpath to paste into a part        | `utils/svg2bez.py "_incoming/<trace>.svg" --height 80` (or `--width`)                                          |
| Split a scanned STL into its overlapping shells so a part can union them   | `utils/stl-shells.py "_incoming/<thing>/mesh.stl"` (then `import()` each shell; see Gotchas)                    |
| Bend budget for the screen-fence clip's legs                                | `utils/legcheck.py`                                                                                               |
| Compare leg section options                                                 | `utils/legcheck.py --sweep`                                                                                       |
| Slice and verify the job                                                    | `utils/slice.sh stl/<part>.stl` or `utils/slice.sh parts/<part>.scad`                                             |
| Slice a Gridfinity STL with buried magnets and verify its native pause      | `utils/slice.sh stl/gridfinity/<part>.stl --magnet-pause` (0.30 mm first layer, 0.12 mm thereafter; pause height read from the cavities: layer 21 for bins and trays, layer 63 for the upside-down `wire-shelf-gridfinity-4x2`; needs a `python3` with Pillow, which Homebrew's lacks—`PATH="/usr/bin:$PATH"` works) |
| Slice against untuned FlashForge stack                                      | `utils/slice.sh stl/<part>.stl --stock`                                                                           |
| One-off slicer override                                                     | `utils/slice.sh stl/<part>.stl --set filament:nozzle_temperature=235`                                             |
| Role breakdown at a height                                                  | `utils/slice.sh stl/<part>.stl --at-z 38`                                                                         |
| Read a sliced job back                                                      | `utils/gcode-probe.py slice/<part>/plate_1.gcode`                                                                 |
| Resolve slicer profile inheritance                                          | `utils/ffprofile.py --machine … --process … --filament … --outdir …`                                              |
| Preset drift report (app vs repo)                                           | `utils/profiles-check.sh`                                                                                         |
| Push presets repo → app                                                     | `utils/profiles-check.sh --install` (then restart Flash Studio)                                                   |
| Capture presets app → repo                                                  | `utils/profiles-check.sh --capture`                                                                               |

There is no lint, format, typecheck, or dev server. OpenSCAD lives at `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` and is not on `PATH`; the scripts fall back to it. Flash Studio lives at `/Applications/Flash Studio.app`; override with `FS_APP`.

`slice.sh` exports nothing to the printer. Sending a job is a separate, deliberate act performed by Ziad.

## 2. Definition of done

For a geometry change:

1. `utils/render.sh parts/<part>.scad`, then **read all seven PNGs**. One view hides things—a tab on the wrong side is invisible head-on, and an opposite face is a different picture, not a mirror of one you have already seen.
2. `utils/build.sh parts/<part>.scad`, then read the geometry summary. `Status: NoError` means manifold. `Genus` counts through-holes: a part with one bore reports `Genus: 1`. If you punched a hole and genus came back `0`, the cut did not go through.
3. Hand the renders to Ziad for the visual call. Do not self-certify appearance in a loop.
4. **If the part has to go into or onto something, prove it can GET there — not just that it fits once seated.** Model the mating part, boolean-intersect the seated pose, and then run a configuration-space path search from outside. A clean intersection is not a pass; neither is "collision-free placements exist at every tilt". `screen-fence-rail.scad` shipped twice on that mistake. Method and the specific traps are in [docs/debugging.md](docs/debugging.md).

For a print-setting change (rare—see Prohibitions):

1. Change the value in `docs/profiles/`, not in a script and not only in the GUI.
2. `utils/profiles-check.sh --install`, then restart Flash Studio.
3. `utils/slice.sh …` and confirm the value in the probe output. The G-code is the only place a setting is real.

Not required: nothing here needs a full print to be considered done by you. Printing is Ziad's step, and one variable at a time.

## 3. Prohibitions

- **Never write `.scad` and hand it over without looking at a render.** A render you have not looked at is work not done. Blind solid geometry produces plausible code with wrong results—the code compiles, the STL exports, the part is garbage.
- **Never `git commit` or `git push` without explicit permission.** See Commit conventions.
- **Never pass `--push` or run `utils/deploy/prod.sh` on your own initiative.** Both rsync to a live production host (the NAS backing <https://3d.feralcreative.co>). Only when Ziad asks. The destination for `prod.sh` is read from `.vscode/sftp.json`; `build.sh --push` still carries its own copy of the host.
- **Never verify a print setting in the slicer GUI.** Verify in the G-code with `utils/gcode-probe.py`. On 2026-08-09 a correct, correctly-selected filament preset contributed nothing to a job, the print ran 25 °C too hot, and it cost the top 6.41 mm of a collet.
- **Never reintroduce a hardcoded override array in `utils/slice.sh`.** It used to carry `LOW_STRING` `--set` flags and apply them by default; command-line overrides outrank presets, so it silently beat everything in `docs/profiles/`—including a retraction length of 1.6 mm that kept being applied for hours after the preset had been corrected to 0.4, and which ground the extruder. If a value needs changing, change the preset.
- **Be very reluctant to tune print settings at all.** Retraction length and temperature both trade against feed reliability. The 2026-08-10 session traded three working prints for a cosmetic stringing complaint and jammed the feed drive three times. Change one thing, print a part, then change the next.
- **Never `import()` an SVG from a part.** Use `include <../logos/marks.scad>` and the modules there. Reasons in [docs/decisions.md](docs/decisions.md); the failure is silent—a missing import prints an ERROR and then _exits 0_, so `build.sh` reports success and hands you an STL with no artwork on it.
- **Do not hand-edit generated trees:** `renders/`, `stl/`, `slice/`, `3mf/`, and the `MODELS` symlink (it points into the printer-site repo). All are gitignored and reproducible.
- **Do not edit `lib/BOSL2`.** It is a git submodule (v2.0.755); changes belong upstream.
- **Do not investigate Ziad's machine to answer questions about his setup.** If you need to know whether something is installed or how it is configured, ask him.
- **Do not migrate the Dropbox SketchUp archive** at `/Volumes/Feral SSD/Dropbox (Personal)/_FERAL/3d`. It stays where it is; this repo is a change of method, not a migration.

## 4. Architecture

There is no runtime. The pipeline is four stages, each with its own verification artifact:

1. `parts/<part>.scad` — the source of truth. One part per file, named after the part.
2. `utils/render.sh` → `renders/<part>-{iso,zplus,zminus,yminus,yplus,xplus,xminus}.png`. Fast preview; the six elevations are orthographic, iso is perspective. Verifies shape. The elevations are named for where the **camera** sits in the part's axes — `zplus` is the camera on +Z — never for a side of the part, because which face is the "front" is the part's business and not the script's. All six faces are rendered: pick any three and some part's own front is one of the three you left out.
3. `utils/build.sh` → `stl/<part>-v01.stl`, zero padded to two digits, binary, plus OpenSCAD's manifold/genus summary. Verifies topology. `stl/<part>.stl` is a real copy of the newest version — never a symlink (Ziad's call, 2026-09-12: a link is a pointer to a file nobody else has and dangles the moment its target is cleaned) — and is what every other stage and every path quoted in the docs uses. The numbered drafts beside it keep their numbers.

   **A finished part carries no version at all.** Versions are for a part that is still moving; once it stops, `utils/finalize.sh <name>` keeps `stl/<name>.stl` and deletes the numbered drafts beside it — and every untracked `stl/<name>-*coupon*.stl`, since a finished part has nothing left to test, and its renders — so there is exactly one file and nothing stale beside it to print by mistake. The render match is `renders/<name>-<one segment>.png`, not a prefix glob: output names extend each other (`deck-door-stop` beside `deck-door-stop-truss`), a view name carries no dash, and finalizing has no dry run to catch a wrong sweep. It trusts the plain file rather than the highest number — those differ (`slim-can-adapter` carried a v02 while both the ledger and the plain name said v01). `docs/stl-versions.txt` is deliberately left alone, so rebuilding a finished part resumes at the next number rather than colliding with its own history. `build.sh --no-version` writes the plain name directly when a part is known to be done up front. A name may be a glob, matched inside the script against the names in `stl/` and every subdirectory of it — quote it, since zsh refuses an unmatched glob and nothing in the repo root is called `delonghi-heater-stand*` — or an `stl/…*` path the shell expands itself, reduced to its name. Neither, and not `--all` either, ever finalizes a coupon: a coupon is never final and its parent's finalize sweeps it, so a name with `coupon` in it is dropped and reported unless it was typed in full.

4. `utils/slice.sh` → `slice/<part>/{plate_1.gcode,out.gcode.3mf,resolved.json,slice.log}`, plus a copy of the job as `3mf/<part>.3mf` — the file that goes to the printer, named after the part instead of the slicer's fixed `out.gcode.3mf`. Internally: `ffprofile.py` flattens the profile inheritance chain, Flash Studio slices, `gcode-probe.py` reads the result back. Verifies settings.

Dependency direction: parts include `lib/BOSL2` and `logos/marks.scad`; nothing includes a part except another part reading its numbers (`hobbs-chalk-holder.scad` is written to be includable for that). Scripts depend on parts, never the reverse.

Non-obvious coupling:

- **`OPENSCADPATH`.** `lib/` is not a directory OpenSCAD searches. `render.sh` and `build.sh` export `OPENSCADPATH` themselves, so `include <BOSL2/std.scad>` resolves. Invoking the `openscad` binary directly, outside the scripts, will fail to resolve it. So does opening the part in the OpenSCAD GUI. `include <../lib/BOSL2/std.scad>` resolves relative to the part's own file and works in both; `delonghi-heater-stand.scad` does it that way, the chalk-holder parts still use the bare form.
- **A coupon carries only what changed since the last print, by default.** `utils/coupon.sh` hashes each component's mesh, compares it against `docs/print-log.txt`, and leaves off anything identical to what was last printed — reprinting an unchanged half costs plate time and answers nothing. The part declares its own components in two comment directives (`// COUPON-COMPONENTS:`, `// COUPON-PLATE:`); the script knows nothing about any particular part. Nothing in the repo can see a print, so the printed columns move only when Ziad runs `--printed`. Pass `--all` to override.
- **The STL version counter is committed; the versioned STLs are not.** `docs/stl-versions.txt` holds one `<name> <n>` line per output name and is the only durable record of where a series is up to — every `-vNN.stl` is gitignored and regenerable, so a counter kept beside the meshes would reset to v1 the first time the tree was cleaned. It counts builds, not design changes. The finished unversioned file is committed and does not affect this.
- **The NAS is the only join to the printer site.** `~/www/feral/3d.feralcreative.co` shares no code and no history with this repo. `build.sh --push` rsyncs an STL to `/volume1/web/3d-printer-stream/public/models`, which is bind-mounted into that container, so a new model appears in the web viewer immediately with no rebuild and no deploy.
- **Slicer presets exist in two places and drift.** See [docs/architecture.md](docs/architecture.md).

## 5. Conventions

Follow `parts/example-spacer.scad`, which exists as the template:

1. Parameters at the top, grouped under `/* [Section] */` headers. Those are what OpenSCAD's Customizer panel reads, so grouping is functional.
2. Every dimension a named parameter with a unit comment. No bare numbers buried in geometry.
3. Geometry inside a named `module`, with a single call at the bottom.
4. `$fn` set once near the top. Keep it moderate while iterating; raise it before the final STL.
5. `eps = 0.01` overshoot on every subtracted solid, so no cut face is coplanar with its parent.
6. Multi-variant parts expose `show = "…";` with the choices in a trailing `// [a, b, c]` comment, and select with `-D 'show="coupon"'`.
7. Prefix parameter names per sub-assembly in merged files (`ring_collar_d`, not `collar_d`). OpenSCAD has no namespaces and the last top-level assignment wins file-wide.
8. Artwork goes through `logos/marks.scad`: `hobbs_mark(width)`, `hobbs_mark_figure`, `hobbs_mark_word`, `hobbs_word_alone`, `feral_logo`, `vmc_top_rocker`, `zr_mark`, `zr_monogram`, `wagon_queen`, `wagon_queen_crest`, `wagon_queen_word`, `wagon_queen_crest_alone`, each centred on the origin and scaled to the width given, plus `*_height(width)` functions. Only the Hobbs figure, the two ZR marks, and the Wagon Queen crest may be cut through; everything else has counters that a through-cut drops out. `zr_monogram` is a hairline design — swell it before cutting, see the ⚠️ on that module. `logos/marks-gallery.scad` draws every mark, labelled and flagged for cut-safety — open that in OpenSCAD to look at them, because `marks.scad` calls none of its own modules and previews empty, and it has to stay that way: `include` splices top-level geometry into the including part. A `*_height()` answers for its own bounding box, which is not always the module of the same name — `hobbs_word_height` and `wagon_queen_crest_height` describe the `_alone` variants, and a half-mark registered to a lockup's box comes out smaller than its own height function says.
9. **Every wire shelf part mounts with the proven rail.** `use <wire-shelf-box-platform.scad>` and call `channel_cut(length)` and `floor_wire_reliefs(width)` with their defaults: 4.5 mm open-bottom slots (3.5 mm wire + 0.5 per side) on a 20 mm pitch, plus slots for the front edge's support wires 114 mm apart in the clear, from the shelf face to just past the lower rail, with the outer jaw solid and the deck underside at Z=38.7. Ziad printed it as a coupon on 2026-10-03 and it fit perfectly—do not redraw, rescale, or retune it. The cup holder and `parts/gridfinity/wire-shelf-gridfinity-4x2.scad` show the pattern.

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
- **Legacy parts in `_incoming/` are measured, not authored.** The chalk holder and pyramid were remade from SketchUp-era meshes, so a number in those files may be a faithfully copied mistake rather than a decision—the thread groove was 0.596 mm deeper than anything needed.
- **Camera flags are verified on OpenSCAD 2026.06.12**, checked with a deliberately asymmetric rig. If you ever re-verify, do not use a rotationally symmetric part: its views are pixel-identical whether the flags work or not.
- **A render's name says where the camera is, not which side of the part you are looking at.** `zplus` is the camera on +Z; whether that is the part's front, back or end depends on the part — and on `flip`, which turns a part over for printing. The views were called iso/front/right/top until 2026-09-14 and that collided with the vocabulary inside the parts: on `doorbell-wire-channel.scad`, whose own front is its +Z face, the file called `-front.png` was an end-on view and `-top.png` was the back. Renders were read the wrong way round for a whole session before anyone noticed.
- **Render colours come from `docs/color-schemes/`, not from OpenSCAD's built-ins.** `render.sh` defaults to the repo's `Feral Magenta` scheme and copies every scheme in that directory into OpenSCAD's user config (`~/Library/Application Support/OpenSCAD/color-schemes/render/`) before rendering, because that is the only place OpenSCAD reads custom schemes from. Edit the JSON in the repo, never the installed copy; `COLORSCHEME=Cornfield` (or any built-in) overrides per run.
- **A render that looks broken may be the preview, not the part.** `render.sh` runs OpenSCAD in preview mode, and OpenCSG gives up on some parts — `deck-door-stop.scad` with its deboss loses its whole body and draws a few stray walls. Pass `--render=cgal` through `render.sh` before believing a part is broken; `build.sh` evaluates the real geometry and is never affected.
- **A DEBOSS IS INVISIBLE IN A FACE-ON ELEVATION, and the part is not broken.** A flat-bottomed recess cut into a plane parallel to the camera shows its floor at exactly the same shading as the surface around it, and its side walls edge-on, so an orthographic `xplus`-style view of a debossed plaque is a blank panel. `--render=cgal` does not help, because nothing is wrong. Read the `iso` for anything sunk into a flat face, or probe the mesh — `slim-can-holder-3in-12oz-wagon-queen.scad` was briefly called broken on exactly this, and the radii said otherwise (33.06 recess floor, 35.05 plaque floor).
- **Most of the time that preview is fixable, and the fix is `convexity`.** A `linear_extrude()` of a profile with several holes needs `convexity = 10` on the extrude, or preview shows the part gutted — faces missing, holes punched through the far wall. It is a hint to the preview rasteriser, changes no geometry, and costs nothing. `deck-door-stop-truss.scad` reproduced the same symptom as the deboss above and this cured it. Reach for it before reaching for `--render=cgal`.
- **A scanned mesh may be several overlapping shells in one STL, and `import()` keeps them that way.** Every boolean on that import leaves the overlaps in: negative genus, double-counted volume, internal faces for the slicer to guess about. Unioning the file with itself is worse (coincident faces; genus 980 on the fish). Split it with `utils/stl-shells.py` and `union()` the pieces as separate imports — `slim-can-holder-3in-12oz-fish.scad` does — and set the shell count from what the split printed, because a missing shell file is a warning and exit 0.
- **`stl/` has per-part subfolders, and `slice.sh` is the one script that does not know it.** `build.sh` takes `OUTDIR`; `finalize.sh`, `clean.sh` and `deploy/prod.sh` all reach into every subdirectory of `stl/`. But `slice.sh parts/<part>.scad` still rewrites the path to a flat `stl/<part>.stl` — hand it the real STL path instead. `prod.sh` syncs to one flat directory on the NAS, so it refuses a run where two subfolders hold the same filename rather than letting one overwrite the other.
- **The version ledger is keyed on the output name, not its path.** Two parts sharing a name in different `stl/` subfolders share one counter in `docs/stl-versions.txt` and overwrite each other's plain file. `finalize.sh` reports and skips such a name rather than guessing which one to keep; `build.sh` does not notice at all.
- **A finished mesh in a subfolder is not committable as `.gitignore` stands.** `stl/*` excludes the subdirectory itself, and git will not descend into an excluded directory, so the `!stl/*.stl` re-include cannot reach inside one. It needs `!stl/*/`, `stl/*/*`, `!stl/*/*.stl`, `stl/*/*-v[0-9][0-9]*.stl` beside the existing trio — not yet added, Ziad's call.
- **Do not rebuild knowledge that is already written down.** The two references below were expensive to produce; read them rather than re-reading the app bundle or the web.

## 7. Commit and PR conventions

- Conventional Commits, imperative mood: `type(scope): subject`. Types in use: `feat`, `fix`, `docs`, `refactor`, `chore`, `revert`. Scopes are part or subsystem names (`chalk-holder`, `slicing`, `utils`, `logos`).
- **No AI attribution of any kind**—no `Co-Authored-By`, no "Generated with" footer.
- Never commit unasked. Hand over one chained line and let Ziad run it: `git add -A && git commit -m "type(scope): subject"`.
- Never committed: `renders/`, `slice/`, `3mf/`, `_incoming/`, `MODELS`, `_PLANS` (which is why `docs/_PLANS/` is local-only—Ziad's call whether to unignore), and anything matching `.env*`. No file matching a `.gitignore` entry may be read into a commit, a log, or a chat response.
- **`stl/` is half-committed.** A finished part—no version in its name, see `utils/finalize.sh`—IS committed, because it is the deliverable. Every `-vNN.stl` beside it is not. The `.gitignore` does that with `stl/*`, then `!stl/*.stl`, then `stl/*-v[0-9][0-9]*.stl`: order matters, and the re-include only works because `stl/` itself is never excluded, only its contents.
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
