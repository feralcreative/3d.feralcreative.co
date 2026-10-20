# Printables upload: Roku Remote Stand (Remix)

Everything below maps to a field on the Printables "New Model" form, top to bottom. Copy each block into its field. The files to upload are listed first.

## Files to upload

Drag these from this folder into the file drop:

| File              | What it is                                   |
| ----------------- | -------------------------------------------- |
| `roku-stand.stl`  | The stand                                    |
| `roku-stand.scad` | OpenSCAD source, parametric, no dependencies |

Images, in `images/`. Upload `roku-stand-iso.png` first so it becomes the cover, then the rest:

| File                   | Use                      |
| ---------------------- | ------------------------ |
| `roku-stand-iso.png`   | Cover                    |
| `roku-stand-front.png` | Gallery, shows the scoop |
| `roku-stand-top.png`   | Gallery, shows the slot  |
| `roku-stand-right.png` | Gallery, shows the lean  |

Not included on purpose: the `.3mf` print files in the repo's `3mf/` are sliced for a FlashForge Adventurer 5M Pro with this repo's PETG presets, and would mislead anyone on another printer. Add them only if you want to publish a printer-specific print file.

## Model name

```text
Roku Voice Remote Pro (RC-OS1) Stand
```

## Summary

115 characters, the cap is 120.

```text
Stand for the Roku Voice Remote Pro (RC-OS1): snug PETG fit, front scoop clear of the buttons, wider charging slot.
```

## Main category

Household → **Living Room** (the original is filed there too).

## Additional tags

```text
roku remote stand holder rc-os1 voice-remote-pro organizer petg openscad parametric
```

## Model origin

**Remix or variation of another model.**

## Original models used in this remix

```text
https://www.printables.com/model/1086088-universal-roku-remote-stand
```

Original: "Universal Roku Remote Stand" by RedEinstein, licensed CC-BY.

## Differences of the remix compared to the original

```text
Rebuilt from scratch in OpenSCAD, measured off the original mesh, and fitted to the Roku Voice Remote Pro (RC-OS1), so every dimension is a parameter you can change.

- Front scoop: the top 7 mm of the front wall is cut away across 37 mm so the remote's bottom row of buttons is not crowded, with the rim kept closed each side so the remote cannot pivot out when you lift the stand.
- Tighter pocket: 0.3 mm taken off every inner wall. The original gripped a remote in PETG but not in PLA; this one grips in both. Set pocket_squeeze to 0 in the .scad for the original fit.
- Uniform wall all round instead of a front wall that thins toward the corners.
- Wider cable slot: runs from the inside of the front wall to 3 mm short of the back wall, vertical rear face, no ramp.
```

## Was AI used to create this model?

**Yes — AI-assisted creation.** The description below carries the matching blurb.

## NSFW / Political

Leave both unchecked.

## Description

The editor is rich text. Paste this as-is; headings and lists survive the paste.

```text
A remix of RedEinstein's Universal Roku Remote Stand, fitted to the Roku Voice Remote Pro (RC-OS1) and rebuilt as a parametric OpenSCAD model so you can tune it to your remote and your filament.

WHAT CHANGED

- A scoop out of the top of the front wall so the remote's bottom row of buttons is not buried. It is deliberately shallow: the closed rim each side is what keeps the remote from pivoting out when you pick the stand up.
- The pocket is 0.3 mm tighter on every wall. The original held a remote in PETG but not in PLA; this one holds in both. If yours is too tight, set pocket_squeeze to 0 (or anything in between) in the .scad and re-export.
- The cable slot runs the full depth of the pocket, hard against the front wall and 3 mm short of the back, so the Remote Pro's USB-C charging cable has room.

PRINTING

- Print it as built, flat on its base. No supports needed anywhere: the back wall leans 15 degrees and the only bridge is a half-millimetre chamfer on the slot rim.
- 0.2 mm layers, any infill. Printed in PETG and PLA on a 0.4 mm nozzle.
- The printed wall is wall + pocket_squeeze, 2.3 mm as supplied. If you change either, keep the sum near a multiple of your extrusion width (2.1 or 1.68 on a 0.4 mm nozzle) or the wall will print with gaps.

THE SOURCE

roku-stand.scad has no dependencies and every dimension is a named parameter at the top of the file, grouped for OpenSCAD's Customizer. It can also deboss a letter into the front wall (mark = "Z" or "R") if you want one; the STL here is the plain version.

CREDIT

Original model: Universal Roku Remote Stand by RedEinstein, CC-BY. https://www.printables.com/model/1086088-universal-roku-remote-stand

This model was designed by a human making all geometry decisions, though I do get help from Claude Code in an IDE using the OpenSCAD CLI.
```

## License

**Creative Commons — Attribution (CC-BY)**, the same as the original. CC-BY does not require a share-alike licence on remixes, so any CC licence is permitted, but matching it is the simplest way to respect the original.
