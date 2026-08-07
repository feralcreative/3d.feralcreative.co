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

1. Install OpenSCAD. The macOS app bundle does not put the CLI on `PATH`; the scripts fall back to `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` automatically.
2. Add BOSL2 at `lib/BOSL2` for rounding, chamfering, and attachment helpers.
3. In the OpenSCAD GUI, turn on **Design → Automatic Reload and Preview** so it re-renders whenever a file is saved from an external editor.

## Notes

See `_AI_AGENT_PRIMER.md` for background, conventions, and how this connects to the `3d.feralcreative.co` printer site.
