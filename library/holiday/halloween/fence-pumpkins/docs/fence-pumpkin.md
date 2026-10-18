# Fence-post pumpkins

Source: [fence-pumpkin.scad](../fence-pumpkin.scad). Adapted from "LED tea light jack-o-lantern pumpkins" by artwells (Printables model 1835966), licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); the original files are kept unchanged in `led-tea-light-jack-o-lantern-pumpkins-model_files/`.

## Parts

| Part | STL | Notes |
| --- | --- | --- |
| Body | `fence-pumpkin-traditional-body` | 90.7 × 69.4 × 82.8 mm; the back quarter cut off at Y=25 and closed by a flat 4.8 mm wall with the door slot |
| Door | `fence-pumpkin-traditional-door` | slides down into the back wall; carries the cork collar and the wire hole |
| Stem | `fence-pumpkin-traditional-stem` | printed in green and glued onto a peg on the pumpkin's top |
| Whole pumpkin | `fence-pumpkin-traditional` | the fused, uncut pumpkin, `show="pumpkin"` |

The pumpkin's face is −Y and its back +Y. A solar cork light (YJFWAL solar wine-bottle light: square head about 45 mm, round flange, tapered rubber cork with the light strand leaving its tip) plugs its cork into the collar like a bottle neck. The collar stands behind the back wall, far enough out that the 45 mm head clears it by 2 mm, and low enough that the head's top is level with the pumpkin's top at Z=33.09, so the panel is hidden from the front and still faces the sky. The strand goes down the collar's bore and through a 6 mm hole in the door into the pumpkin.

The cork bore (18.5 mm, a standard wine-bottle neck), its 22 mm depth, and the head's height and flange are **unmeasured**. The head height sets how low the collar sits. Measure a light and correct `cork_bore_d`, `collar_depth`, `head_h`, `flange_d` and `flange_h` before printing.

## Joining the lid

The lid drops into the shell's top opening on a stepped plate and rests on the rim, its top edge flush with the rim. The clearance ring around the plate is part of the hollow inside and is left alone; filling the opening was tried and rejected because the lid's top is a dish whose floor it raised. Lowering the lid to make it overlap the rim left a visible step, so instead it is grown outward 0.3 mm at its edge (`lid_grow`) to lap onto the rim at the same height. No step around the joint exceeds 0.06 mm.

## Stem

The stem is cut off at Z=31.5 and printed separately in green. That is the lowest height at which a cylinder around it misses the lid's dish rim: below it, the rim comes closer to the stem's centre than the stem's widest point. A 0.75 mm orange stub stays under it, the same outline as the stem's base, so the glued stem covers it. A 5 mm peg, 3 mm tall, on the stub locates the stem; the socket in its base has 0.15 mm per side for glue. The stem prints standing on its cut face with no supports; its only overhang is the 5.3 mm socket roof, a short bridge. The stem is wrapped in `render()` because OpenSCAD's preview otherwise drew the lid's whole dish green in the assembled view.

## Walls and face

The walls are thickened inward by a copy of the shell scaled toward its centre: about 0.8–1.0 mm added to the original 1.7 mm, less toward the top and bottom, and none above Z=28.5, where the copy's rim met the lid in pinhead voids. The eyes, nose and mouth are not thickened. From outside they stay carved recesses about 1–1.4 mm deep; on the inside each is closed by a membrane measured at 0.43–0.62 mm, about one extrusion line, so they glow brighter than the walls. The membrane is the innermost skin of artwells' blank shell, which matches the traditional one everywhere except the face.

## Door

The door is 40 mm wide with a V tongue on each edge, 45° flanks, riding a matching groove in the back wall with 0.3 mm clearance, so it is held front and back and drops in from the top to rest at Z=−17. The slot breaks out through the top of the dome; the door's top edge follows the pumpkin's outline there.

## Printing

Print the stem as `show="print-stem"`, standing on its cut face. Print the door as `show="print-door"`: inner face down, collar up. The bore runs sideways in that orientation, so it is a teardrop with its point cut flat inside the collar wall; the wire hole is vertical. Nothing on the door needs support.

The body has not been sliced. Upright it keeps the face membranes, back wall and grooves vertical, but the lid's plate roofs the inside with a flat ceiling about 44 mm across, which needs support or a bridge. On its back (`show="print-body"`) the face dome becomes the roof instead. Choose after a slicer preview.

## Verification

The stem is one shell, genus 0, 3,730 mm³; seated on its peg it meets the body only on the flat cut face. The body is one shell, genus 1: the inside opens to the outside only through the door slot, so all four face openings are sealed. It carries 6 non-manifold edges, under 0.15 mm long, at one corner of the left eye's membrane. The door is one shell, genus 1, the wire hole. With the door seated, door and body do not intersect; lifted in 1 mm steps up to 60 mm, the door meets nothing; a 45 mm head 1.9 mm larger all round, on its flange at the collar, clears the body. Wall and membrane thicknesses were measured by sectioning the built mesh. Fit, sliding, and glow are not printed or tested.

## Rebuild

```bash
cd ~/www/feralcreative/scad
utils/build.sh fence-pumpkins -D 'show="body"' --name fence-pumpkin-traditional-body
utils/build.sh fence-pumpkins -D 'show="door"' --name fence-pumpkin-traditional-door
utils/build.sh fence-pumpkins -D 'show="stem"' --name fence-pumpkin-traditional-stem
```

`back-outline.scad` is the pumpkin's filled outline on the cut plane, generated by `utils/section-outline.py` (command in the source header); regenerate it if `back_cut_y` changes. `show="assembled"` adds a translucent stand-in for the solar light; `show="section"` cuts everything in half.
