# Bong stabilizer

Source: [bong-stabilizer.scad](../bong-stabilizer.scad). First design for a 95 mm glass base with a 13 mm-high outside edge, tapering to a 43 mm chamber at 14 mm above the glass bottom. Overall height is 419.1 mm (16.5 inches); filled mass is approximately 1,020.6 g (36 ounces).

## Construction

A 195 mm-wide foot has a 96.5 mm seat and a solid plastic shoulder. Two 6.3 mm-thick collar halves sit on that shoulder at Z=25.4 mm. Their 86 mm opening overlaps the glass rim by 4.5 mm radially. Four coarse, custom printed wing screws hold the collar to the shoulder; tightening seats plastic against plastic rather than clamping the glass. These are 10 mm-diameter, 2 mm-pitch trapezoidal threads, not standard M10 hardware threads. Each 4.2 mm-thick head has two rounded paddles spanning 36 mm and a 16 mm circular bearing hub. The shafts and collar holes are unchanged, so the existing printed collar can be reused.

The seat allows 0.75 mm radial clearance. With a 1 mm liner ring, the glass bottom sits at Z=10.6 mm and its measured flare ends at Z=24.6 mm, leaving 0.8 mm below the collar. The centre seat is raised 6.4 mm to accommodate the light; the outer foot remains 4.2 mm thick, with a 1.2 mm-radius roundover around its top outside edge. Clearance above the lower outside rim is larger because the flare rises from 13 to 14 mm. The two installed collar halves have a 0.6 mm gap.

The Bambu LED puck is 59.4 mm in diameter and 8 mm thick. Its underside pocket uses the pumpkin's proven 0.15 mm radial clearance and 0.1 mm extra depth: a 59.7 mm × 8.1 mm nominal pocket with the same 1.5 mm, 45-degree annular stop. The stop leaves the full 47.6 mm lens clear, and the seat has a through-opening above it. A 3.4 mm-wide underside groove carries the cable toward +Y between two pad pockets. The puck back sits 0.1 mm above the base underside; the glass load is carried by the annular plastic seat and soft liner, rather than the puck.

## Files and printing

| File | Contents | Orientation |
| --- | --- | --- |
| [bong-stabilizer-base.stl](../bong-stabilizer-base.stl) | One 195 mm foot with rounded top outside edge, LED pocket and open light path, v04 | Flat underside on bed |
| [bong-stabilizer-collar-set.stl](../bong-stabilizer-collar-set.stl) | Both collar halves, spaced apart | Flat faces on bed, as exported |
| [bong-stabilizer-screw-set.stl](../bong-stabilizer-screw-set.stl) | Four printed wing screws, v03; 78 × 58 mm layout | Heads on bed, as exported |
| [bong-stabilizer-screw.stl](../bong-stabilizer-screw.stl) | One test/replacement wing screw, v03 | Head on bed, as exported |
| `_work/stl/bong-stabilizer-coupon-base.stl` | 132 mm fit coupon, v03, with the production seat, LED pocket, shoulder and threads | Flat underside on bed |

The wide foot and collar require separate plates. All exported layouts fit within the repo's documented 205 mm safe XY envelope. No profiles were changed and these files have not been sliced.

Before printing the wide foot, print the coupon base, both production collar halves and one test screw. Check that the puck enters from underneath with its cable in the groove, the glass drops in freely, both halves can move into position, a screw turns freely by hand in every socket, and the collar sits firmly on the plastic shoulder without pressing on the glass. Check the light through the actual glass and liner ring. The coupon checks fit, light clearance and threads; its smaller footprint does not test the full stabilizer's tipping resistance. Print the remaining screws once their fit is confirmed.

## Assembly

1. Insert the LED puck from underneath, lens facing up, and route its cable in the open underside groove. The proven snug pocket is the retention method; verify that this print holds it before lifting the assembly.
2. Put a 1 mm-thick soft liner ring, approximately 95 mm outside diameter with a 60 mm centre opening, into the seat. A solid disk would block the light. The ring raises the glass to the design's seating height and cushions the bottom.
3. Lower the glass straight into the seat with both collar halves removed.
4. Move the collar halves in from opposite sides above the flare. Align their holes with the four threaded sockets.
5. Turn the printed wing screws in by hand until their heads hold the collar against the plastic shoulder. Stop if a screw binds or the collar contacts the glass before reaching the shoulder.
6. For the wide foot, fit six 18 mm-diameter, 1 mm-thick nonslip pads in the underside pockets. The pockets are 0.6 mm deep, leaving the pads 0.4 mm proud.

Remove all four screws and both collar halves to lift the glass out. Check retention while the whole assembly is supported over a soft surface before relying on the base staying attached during normal handling.

## Verification boundary

All seven views of the revised base, wing screw, screw set, fit coupon, assembled reference and section were inspected. The new assembly previews shorten the reference tube to 65 mm only to frame the retention detail; the measured source height remains 419.1 mm. The section omits the glass reference to expose the puck and annular seat. Ziad's visual review is pending.

The delivered binary meshes passed independent checks for collapsed triangles, edge incidence and winding: zero errors across all five exports. The foot, coupon and single screw each have one closed shell; the collar set has two; the screw set has four. OpenSCAD reported `NoError` for each.

The modeled puck and cable have an empty seated intersection and an empty continuous bottom-entry swept-volume intersection from entirely below the base. The modeled glass has an empty seated intersection and an empty conservative continuous vertical insertion sweep with the collar removed. Both collar halves have empty conservative continuous side-entry sweeps, with the opposite half present. Their seated contact with the plastic shoulder is planar at Z=25.4 mm and has zero volume. The screw shaft clears the collar holes and the seated screws clear the female threads. Helical insertion uses matching translation and rotation to preserve thread phase; checks at 49 positions per screw from seated to entirely above the socket found only planar head contact at Z=31.7 mm. Each rotating wing head is contained within an 18 mm-radius disk centred 56.57 mm from the glass axis, leaving over 17 mm clearance to the measured chamber at every rotation; it stays above the glass flare throughout insertion.

The glass envelope represents the supplied base, flare and chamber diameters. Unmeasured bowl/downstem projections are not included; they must clear the collar's 31.7 mm top and the screw heads' 35.9 mm top. Actual glass fit, puck retention, brightness, printed thread fit, pad grip, fastener strength and tipping resistance remain untested. The filled centre of mass is unknown, so no tipping-force threshold is claimed.

## Rebuild

```bash
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="base"' --name bong-stabilizer-base
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="collar-set"' --name bong-stabilizer-collar-set
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="screw-set"' --name bong-stabilizer-screw-set
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="screw"' --name bong-stabilizer-screw
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="coupon-base"' --name bong-stabilizer-coupon-base
```

For visual review, select `show="assembly"`, `show="exploded"` or `show="section"`. Probe variants are `puck-fit`, `puck-insertion`, `glass-fit`, `glass-insertion`, `collar-fit`, `collar-insertion`, `screw-fit`, `screw-insertion` and `screw-path`. Use `insertion_side=1` and `insertion_side=-1` to check both collar entry routes. These are local modeling checks and export nothing to the printer.
