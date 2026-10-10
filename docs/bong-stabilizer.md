# Bong stabilizer

Source: [bong-stabilizer.scad](../parts/bong-stabilizer.scad). First design for a 95 mm glass base with a 13 mm-high outside edge, tapering to a 43 mm chamber at 14 mm above the glass bottom. Overall height is 419.1 mm (16.5 inches); filled mass is approximately 1,020.6 g (36 ounces).

## Construction

A 195 mm-wide foot has a 96.5 mm seat and a solid plastic shoulder. Two 6.3 mm-thick collar halves sit on that shoulder at Z=19 mm. Their 86 mm opening overlaps the glass rim by 4.5 mm radially. Four coarse, custom printed thumbscrews hold the collar to the shoulder; tightening seats plastic against plastic rather than clamping the glass. These are 10 mm-diameter, 2 mm-pitch trapezoidal threads, not standard M10 hardware threads.

The seat allows 0.75 mm radial clearance. With a 1 mm liner, the glass bottom sits at Z=4.2 mm and its measured flare ends at Z=18.2 mm, leaving 0.8 mm below the collar. Clearance above the lower outside rim is larger because the flare rises from 13 to 14 mm. The two installed collar halves have a 0.6 mm gap.

## Files and printing

| File | Contents | Orientation |
| --- | --- | --- |
| [bong-stabilizer-base.stl](../stl/bong-stabilizer-base.stl) | One 195 mm foot | Flat underside on bed |
| [bong-stabilizer-collar-set.stl](../stl/bong-stabilizer-collar-set.stl) | Both collar halves, spaced apart | Flat faces on bed, as exported |
| [bong-stabilizer-screw-set.stl](../stl/bong-stabilizer-screw-set.stl) | Four printed thumbscrews | Heads on bed, as exported |
| [bong-stabilizer-screw.stl](../stl/bong-stabilizer-screw.stl) | One test/replacement thumbscrew | Head on bed, as exported |
| [bong-stabilizer-coupon-base.stl](../stl/bong-stabilizer-coupon-base.stl) | 132 mm fit coupon with the production seat, shoulder and threads | Flat underside on bed |

The wide foot and collar require separate plates. All exported layouts fit within the repo's documented 205 mm safe XY envelope. No profiles were changed and these files have not been sliced.

Before printing the wide foot, print the coupon base, both production collar halves and one test screw. Check that the glass drops in freely, both halves can move into position, a screw turns freely by hand in every socket, and the collar sits firmly on the plastic shoulder without pressing on the glass. The coupon checks fit and threads; its smaller footprint does not test the full stabilizer's tipping resistance. Print the remaining screws once their fit is confirmed.

## Assembly

1. Put a 1 mm-thick soft liner disk, trimmed to approximately 95 mm diameter, into the seat. It raises the glass to the design's seating height and cushions the bottom.
2. Lower the glass straight into the seat with both collar halves removed.
3. Move the collar halves in from opposite sides above the flare. Align their holes with the four threaded sockets.
4. Turn the printed screws in by hand until their heads hold the collar against the plastic shoulder. Stop if a screw binds or the collar contacts the glass before reaching the shoulder.
5. For the wide foot, fit six 18 mm-diameter, 1 mm-thick nonslip pads in the underside pockets. The pockets are 0.6 mm deep, leaving the pads 0.4 mm proud.

Remove all four screws and both collar halves to lift the glass out. Check retention while the whole assembly is supported over a soft surface before relying on the base staying attached during normal handling.

## Verification boundary

All seven views of the base, collar, screw, fit coupon and assembled reference were inspected. The closer assembly renders shorten the reference tube to 65 mm only to frame the retention detail; the full assembly renders use the measured 419.1 mm height.

The delivered binary meshes passed independent checks for collapsed triangles, edge incidence and winding: zero errors across all five exports. The foot, coupon and single screw each have one closed shell; the collar set has two; the screw set has four. OpenSCAD reported `NoError` for each.

The modeled glass has an empty seated intersection and an empty conservative continuous vertical insertion sweep with the collar removed. Both collar halves have empty conservative continuous side-entry sweeps, with the opposite half present. Their seated contact with the plastic shoulder is planar and has zero volume. The screw shaft clears the collar holes and the seated screws clear the female threads. Helical insertion uses matching translation and rotation to preserve thread phase; checks at 49 positions per screw from seated to entirely above the socket found only zero-volume planar head contact at Z=25.3 mm.

The glass envelope represents the supplied base, flare and chamber diameters. Unmeasured bowl/downstem projections are not included; they must clear the collar's 25.3 mm top and the screw heads' 29.5 mm top. Actual glass fit, printed thread fit, pad grip, fastener strength and tipping resistance remain untested. The filled centre of mass is unknown, so no tipping-force threshold is claimed.

## Rebuild

```bash
utils/build.sh parts/bong-stabilizer.scad --name bong-stabilizer-base
utils/build.sh parts/bong-stabilizer.scad -D 'show="collar-set"' --name bong-stabilizer-collar-set
utils/build.sh parts/bong-stabilizer.scad -D 'show="screw-set"' --name bong-stabilizer-screw-set
utils/build.sh parts/bong-stabilizer.scad -D 'show="screw"' --name bong-stabilizer-screw
utils/build.sh parts/bong-stabilizer.scad -D 'show="coupon-base"' --name bong-stabilizer-coupon-base
```

For visual review, select `show="assembly"` or `show="exploded"`. Probe variants are `glass-fit`, `glass-insertion`, `collar-fit`, `collar-insertion`, `screw-fit`, `screw-insertion` and `screw-path`. Use `insertion_side=1` and `insertion_side=-1` to check both collar entry routes. These are local modeling checks and export nothing to the printer.
