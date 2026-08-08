# Feral SCAD Parts

Parametric 3D-printed parts, designed in OpenSCAD.

Source of truth is `parts/*.scad`. Everything in `renders/` and `stl/` is generated and gitignored—if you need it, rebuild it.

## Usage

Render a part to multi-angle PNGs for review:

```bash
utils/render.sh parts/example-spacer.scad
```

Build an STL:

```bash
utils/build.sh parts/example-spacer.scad
```

Override any top-level parameter without editing the file:

```bash
utils/render.sh parts/example-spacer.scad -D 'outer_d=30'
```

Push a finished STL to the printer site's models directory on the NAS, where it becomes visible in the web viewer at <https://3d.feralcreative.co>:

```bash
utils/build.sh parts/example-spacer.scad --push
```

## Setup

1. Clone with submodules, so BOSL2 lands at `lib/BOSL2` where the parts expect it for rounding, chamfering, and attachment helpers:

   ```bash
   git clone --recurse-submodules https://github.com/feralcreative/scad.git
   ```

   If you already cloned without it, run `git submodule update --init` instead.

2. Install OpenSCAD—see your platform below.
3. In the OpenSCAD GUI, turn on **Design → Automatic Reload and Preview** so it re-renders whenever a file is saved from an external editor.

Both scripts export `OPENSCADPATH` themselves, so `include <BOSL2/std.scad>` resolves no matter which directory you run from. Invoking the `openscad` binary directly, outside the scripts, will not find it.

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

## Notes

See `_AI_AGENT_PRIMER.md` for background, conventions, and how this connects to the `3d.feralcreative.co` printer site.
