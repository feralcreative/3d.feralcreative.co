# Feral Model Library

3D-print models, including OpenSCAD designs, adapted models, and earlier SketchUp or mesh-only projects.

Each model lives in `library/<category>/<model-id>/`, with its SCAD, STL, 3MF, SKP, instructions, and licenses together. `model.json` records its origin and SCAD entrypoint; `_work/` holds regenerable builds and previews. Browse [the model catalog](library/README.md) or read [the library workflow](docs/library.md).

## Usage

Render a part to multi-angle PNGs for review:

```bash
utils/render.sh awl-sheath
```

Build an STL:

```bash
utils/build.sh awl-sheath
```

Override any top-level parameter without editing the file:

```bash
utils/render.sh awl-sheath -D 'outer_d=30'
```

Push a finished STL to the printer site's models directory on the NAS, where it becomes visible in the web viewer at <https://3d.feralcreative.co>:

```bash
utils/build.sh awl-sheath --push
```

## Setup

1. Clone with submodules, so BOSL2 lands at `lib/BOSL2` where the parts expect it for rounding, chamfering, and attachment helpers:

   ```bash
   git clone --recurse-submodules https://github.com/feralcreative/scad.git
   ```

   If you already cloned without it, run `git submodule update --init` instead.

2. Install OpenSCAD—see your platform below.
3. In the OpenSCAD GUI, turn on **Design → Automatic Reload and Preview** so it re-renders whenever a file is saved from an external editor.

Both scripts resolve model IDs and former source paths, supply model-specific OpenSCAD feature flags, and export `OPENSCADPATH`. Migrated sources use relative references to shared libraries so they also open in the GUI.

### macOS

Install the app bundle. The CLI does not land on `PATH`, but the scripts fall back to `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` automatically, so there is nothing else to do.

### Linux

Install from your distribution, so that `openscad` ends up on `PATH`:

```bash
sudo apt install openscad     # Debian, Ubuntu
sudo dnf install openscad     # Fedora
sudo pacman -S openscad       # Arch
```

`PATH` is the only place the scripts look once they are off macOS, so AppImage, Flatpak and Snap installs need a shim first—symlink the AppImage onto `PATH` as `openscad`, or drop a one-line wrapper around `flatpak run org.openscad.OpenSCAD`. Everything else matches macOS: the scripts are bash, and `OPENSCADPATH` is colon-separated. `--push` additionally wants `rsync` and `ssh`.

### Windows

Use WSL. Install a Linux distribution, then follow the Linux instructions inside it—the scripts are bash, and `--push` shells out to `rsync` over `ssh`.

Running them under Git Bash or MSYS2 against a native Windows OpenSCAD will not work as written, for two reasons visible in `utils/render.sh` and `utils/build.sh`:

- `OPENSCADPATH` is semicolon-separated on Windows; both scripts join with a colon.
- Git Bash hands the scripts a POSIX repo path (`/c/Users/...`) that a native `openscad.exe` cannot resolve. It would need `cygpath -w`.

If you want the native build anyway, `winget install --id=OpenSCAD.OpenSCAD -e` installs it. Note that `openscad.com` is the console wrapper and `openscad.exe` is the GUI, which does not hand output back to the terminal.

## Printer profile

Parts here are designed against one specific machine, and its constraints are written down rather than remembered.

### My printer

[docs/flashforge-ad5m-pro-scad-reference.md](docs/flashforge-ad5m-pro-scad-reference.md) is the profile for the FlashForge Adventurer 5M Pro this repo prints on: safe build envelope after the purge and wipe strips are subtracted, per-nozzle wall-thickness ladders, flow-capped real speeds, clearance ladders for press/snug/free fits, faceting rules for `$fn`, a materials matrix, and a copy-paste OpenSCAD constants block. Every figure carries a source and an evidence marker, so you can tell at a glance whether a number is a manufacturer spec, a field report, or arithmetic done inside the document—and an independent verification pass has been run over the whole thing.

Read it before picking a wall thickness, a clearance, or a facet count. If you print on something else, its numbers are wrong for you—don't borrow them.

### Your printer

[docs/printer-profile-research-prompt.md](docs/printer-profile-research-prompt.md) is how to build the equivalent for your own printer, so your agent designs against your machine instead of a generic one. It is a reusable prompt for any agent with web search and subagents: fill in a hardware block—printer, nozzles, plates, materials, slicer, firmware—paste it in, and it assembles the same kind of document for your machine. It also explains why it is shaped the way it is, and how to adapt it for resin, CNC, or laser.

Expect it to be a heavy one-time job. The reference above took three parallel research agents, roughly a hundred tool calls, and a separate verification agent that caught four real errors. It only has to run once per machine, and only needs re-running when the nozzles, plates, or firmware change.

### Our printers

If you do use my instructions to build profiles for your printer(s), please commit them and submit a PR. I'd love a library of printer specs for people to use off the shelf without burning tokens.

## Status

[docs/STATUS.md](docs/STATUS.md) is the current state of play: what is designed and finished, what is broken, and what to try next. Read it before changing a print setting or picking the chalk holder back up.

## Notes

See [AGENTS.md](AGENTS.md) for the working rules and conventions, [docs/architecture.md](docs/architecture.md) for how this connects to the `3d.feralcreative.co` printer site, and [docs/decisions.md](docs/decisions.md) for background on why things are the way they are.
