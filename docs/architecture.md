# Architecture

How the pieces fit. Read before changing a script or adding a stage to the loop.

## Directory roles

| Path | Role |
| --- | --- |
| `parts/` | One `.scad` per authored design. `example-spacer.scad` is the house-style template. Designs that adapt imported meshes also depend on those source STLs. |
| `logos/` | SVG artwork plus `marks.scad`, the library that places it. Parts call the library, never `import()`. |
| `lib/BOSL2` | Git submodule, v2.0.747. Rounding, chamfering, threading, attachment. |
| `docs/` | References, status, deep dives, and `profiles/` (the durable copy of slicer presets). |
| `docs/_PLANS/` | Round-by-round record of in-flight work. Gitignored by the blanket `_PLANS` rule, so local-only. |
| `utils/` | Every script. Never `scripts/`. |
| `stl/` | Finished exports are committed; numbered build drafts are gitignored. Category folders hold related models. |
| `stl/<category>/originals/` | Committed source STLs moved from `_originals/`, preserving model folders and filenames. Loose files are sorted into each category's `originals/loose/`. These archives are excluded from cleanup, finalization, and bulk publishing, including `--all`. |
| `_originals/` | Non-STL source assets and accompanying licenses; the STL archive now lives under `stl/`. |
| `renders/`, `slice/`, `3mf/` | Generated, gitignored, reproducible. |
| `_incoming/` | Legacy SketchUp-era STLs, downloaded scans, and SVG traces, gitignored. Reference geometry to measure against, not authored source. A scan that arrives as several shells is split here by `utils/stl-shells.py` into `<name>-shells/`, beside the original, and the part imports the pieces. |
| `MODELS` | Symlink into `~/www/feral/3d.feralcreative.co/public/models`. Gitignored. |

## The four-stage loop

Each stage produces an artifact that proves something the previous stage could not.

1. **Source** — `parts/<part>.scad`.
2. **See it** — `utils/render.sh` → four PNGs in `renders/`. Elevations render orthographic so they read as true drawings; iso stays perspective as an overview. Proves shape.
3. **Mesh it** — `utils/build.sh` → binary STL in `stl/`, plus OpenSCAD's summary. `Status: NoError` means manifold; `Genus` counts through-holes topologically. Proves topology. Output should be manifold by construction—unlike SketchUp exports it needs no mesh repair, so a part that fails the printer site's PyMeshLab step is a real signal.
4. **Slice it** — `utils/slice.sh` → `slice/<part>/`. Proves settings. Three sub-steps:
   - `ffprofile.py` walks each `inherits` chain, merges child over parent, applies `--set` overrides, and writes flat profiles with `inherits` stripped. It searches `docs/profiles/` before the app bundle, so repo presets resolve by name without being installed.
   - Flash Studio slices headless into `plate_1.gcode`, `out.gcode.3mf`, `resolved.json`, `slice.log`.
   - The job is copied to `3mf/<part>.3mf`, the printer-bound file with the part's name on it.
   - `gcode-probe.py` reads the G-code back: layer count, max Z, commanded temperatures, real retraction distances, and per-layer extrusion cliffs.

Nothing in this loop touches the printer.

## Slicer presets live in two places

Ziad works from two machines—Feral MacBook and Feral Studio—against one printer. Neither location is authoritative alone:

- `~/Library/Application Support/Orca-Flashforge/user/default/` is what Flash Studio actually reads. Outside version control, per-machine, one reinstall away from gone.
- `docs/profiles/` is the durable, diffable, shared record. It is inert—copying a file there changes no print.

`utils/profiles-check.sh` reports drift and moves presets either way (`--install`, `--capture`). Both directions have already caused real damage: a setting tuned on one machine and never committed is invisible on the other, and a setting committed but never installed is invisible to the GUI—that one ran a print at 265 °C while the repo said 240.

Every preset is two files: the `.json` with the settings and a `.info` sidecar that registers it in the dropdown. `profiles-check.sh` handles both, and it never touches the bundle's system profiles.

## The join to the printer site

`~/www/feral/3d.feralcreative.co` streams live video from the printer with a status overlay and serves an in-browser STL viewer, deployed as a Docker container on the Synology NAS. The two repos share no code and no history. They are joined by exactly one directory:

```text
this repo                 build.sh --push renders + rsyncs
    │
    ▼
NAS: /volume1/web/3d-printer-stream/public/models/*.stl
    │                     bind-mounted into the container
    ▼
3d.feralcreative.co       viewer serves them at /models
```

Two consequences: STLs are build artifacts and travel by rsync, not by commit (both repos gitignore them); and because the models directory is a bind mount, a pushed STL appears in the viewer immediately with no rebuild and no deploy.

`--push` writes to a live production host. It is opt-in, and only on Ziad's explicit request.
