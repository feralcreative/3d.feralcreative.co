# Bong lift-out cradle

Separate alternative to [bong-stabilizer.scad](../../bong-stabilizer/bong-stabilizer.scad). The original attached design and its exports remain unchanged. Source for this version: [bong-liftout-cradle.scad](../bong-liftout-cradle.scad).

## Dimensions and use

The one-piece cradle has a 195 mm-wide foot, a 95.6 mm seat and walls reaching 36 mm above the glass seat. A 25 mm-wide opening on the +X side runs from the top down to Z=17 mm, measured from the printed underside. Align the bowl/downstem with this opening before lowering the glass. The two upper cutout corners have 3 mm rounds, and the inner and outer top rim edges have 1 mm rounds. The outside edge of the base plate is 3 mm thick, beveling up to the 4.2 mm plate over 1.2 mm inward. The inside stays straight and opens outward at the mouth, so the glass drops in and lifts straight out without a retaining lip or fasteners.

The 95 mm glass base has nominal radial clearance of 0.3 mm. This closer fit is intended to limit rocking of the thick base inside the cradle; it needs a printed fit check because the glass diameter and edge profile were given approximately. The outside wall tapers outward into the broad foot. With the specified 1 mm soft seat liner, the glass bottom is at Z=4.2 mm and the cradle rim at Z=40.2 mm. The lowest connection is nominally at Z=20.2 mm, 3.2 mm above the cutout's lower edge. Its width and shape remain unmeasured; the 25 mm cutout is Ziad's requested dimension.

## Print files

| File | Contents | Bounds |
| --- | --- | --- |
| [bong-liftout-cradle.stl](../bong-liftout-cradle.stl) | Wide foot and tall open cradle with side cutout | 195 × 195 × 40.2 mm |
| `_work/stl/bong-liftout-cradle-coupon.stl` | Same seat, floor, wall height, mouth and cutout, without the wide foot | Approximately 119.2 × 119.2 × 40.2 mm |
| `_work/stl/bong-liftout-cradle-ring-coupon.stl` | Bottom 3 mm of the inner wall, retaining its 95.6 mm bore and outward taper | Approximately 119.2 × 119.2 × 3 mm |

The ring coupon is sliced from the production wall at Z=4.2–7.2 mm and translated onto the bed. It has no seat floor or broad foot. Use it for a quick diameter fit check against the glass base; it does not test the full wall, bowl cutout or cradle stability. Its v01 export passed `NoError`, genus 1, and an independent binary mesh check: one closed shell with zero collapsed triangles, bad edges or winding errors. All seven views were inspected, and a conservative continuous vertical insertion sweep of the measured glass base was empty. Printed fit remains unverified.

Print either file with the flat underside on the bed. Print the coupon first, fit a 1 mm soft disk approximately 95 mm in diameter in its seat, then align the bowl/downstem with the side opening and check that the glass enters freely and lifts out easily. It must not require force. Check the connection clears the opening and assess play gently while holding the glass upright. Report any binding before changing clearance or printing the wide foot. The coupon tests fit, not the wide foot's resistance to tipping.

For the full cradle, add a thin nonslip layer under the flat foot if needed for the tabletop. There are no underside pockets to bridge. Lift the bong by its glass; the cradle stays on the table. Its stability depends on the actual base profile, clearance and tabletop grip.

## Verification

All seven views of the updated cradle and coupon were inspected. The source retains the measured 419.1 mm overall glass height and approximately 1,020.6 g filled mass. The 36 mm wall height preserves Ziad's manual source edit.

OpenSCAD reported `NoError`, genus 0 for both v06 exports. Independent binary-STL checks verify one closed shell per file with no collapsed triangles, incorrect edge incidence or winding errors. The measured base/flare/chamber envelope has an empty seated intersection and an empty conservative continuous vertical insertion sweep. The reverse route is the lift-out path. The connection's nominal vertical clearance is based on the supplied lowest-point height; its unmeasured shape is not drawn, and actual fit through the cutout remains unverified.

The files have not been sliced or printed. Physical fit, rocking resistance, grip and tipping resistance are unverified. No print settings were changed and no job was sent to the printer.

## Rebuild

```bash
utils/render.sh library/drugs/bong-liftout-cradle/bong-liftout-cradle.scad
utils/build.sh library/drugs/bong-liftout-cradle/bong-liftout-cradle.scad
utils/build.sh library/drugs/bong-liftout-cradle/bong-liftout-cradle.scad -D 'show="coupon"' --name bong-liftout-cradle-coupon
utils/build.sh library/drugs/bong-liftout-cradle/bong-liftout-cradle.scad -D 'show="ring-coupon"' --name bong-liftout-cradle-ring-coupon
```

Preview with `show="assembly"`. Use `show="glass-fit"` and `show="glass-insertion"` for the clearance checks. Set `liner_h=0` when building for a bare solid seat rather than the 1 mm liner; the nominal glass seating height remains 4.2 mm in that variant.
