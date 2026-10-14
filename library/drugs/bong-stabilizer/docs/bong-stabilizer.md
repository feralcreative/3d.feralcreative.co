# Bong stabilizer

Source: [bong-stabilizer.scad](../bong-stabilizer.scad). First design for a 95 mm glass base with a 13 mm-high outside edge, tapering to a 43 mm chamber at 14 mm above the glass bottom. Overall height is 419.1 mm (16.5 inches); filled mass is approximately 1,020.6 g (36 ounces).

## Construction

A 172 mm-wide foot (20 mm beyond the 132 mm shoulder on each side) has a 96.5 mm seat and a solid plastic shoulder. Two 6.3 mm-thick collar halves sit on that shoulder at Z=25.4 mm. Their 86 mm opening overlaps the glass rim by 4.5 mm radially. Four coarse, custom printed hex-head bolts hold the collar to the shoulder; tightening seats plastic against plastic rather than clamping the glass. These are 10 mm-diameter, 2 mm-pitch trapezoidal threads, not standard M10 hardware threads. The hex heads are 20 mm across corners (17.32 mm across flats) and 6.3 mm thick, with flat upper and bearing faces. The shafts and collar hole dimensions remain unchanged. Use the updated plates for the flush end joints.

The raised base's complete mating annulus is flat at Z=25.4 mm, from the 96.5 mm seat opening to its 132 mm outside diameter, apart from the threaded sockets and front stem relief. Both plate undersides are flat, without a bevel around their 86 mm opening. Their outside edges align with the base shoulder so the halves seat flush across the mating area. The two rails now split along Y=0: each +X end is shortened by 12.5 mm to form the 25 mm stem gap. The opposite ends meet flush on Y=0, with no nominal gap or rounded recess. Each rail stays one connected printed piece with two bolt holes. The plates keep full-height 6.3 mm rounds on their exposed outer and inner top edges. Flat bearing areas beneath the bolt heads are clipped to the original 132 mm outer footprint. The wide foot's 4.2 mm top outside round, glass-seat dimensions, threaded shafts and LED pocket remain unchanged.

The seat allows 0.75 mm radial clearance. With a 1 mm liner ring, the glass bottom sits at Z=10.6 mm and its measured flare ends at Z=24.6 mm, leaving 0.8 mm below the collar. The centre seat is raised 6.4 mm to accommodate the light; the outer foot remains 4.2 mm thick, with a full-height 4.2 mm-radius roundover on its top outside edge and a flat underside. The six nonslip-pad recesses have been removed; only the LED pocket and cable groove interrupt the underside. Clearance above the lower outside rim is larger because the flare rises from 13 to 14 mm.

The stem opening copies [bong-liftout-cradle.scad](../../bong-liftout-cradle/bong-liftout-cradle.scad): 25 mm wide on +X, with 3 mm upper corner rounds. Ziad reported about 3 mm clearance on each side and 5 mm below the stem on the printed cradle. Its cutout floor was Z=17 mm with glass seated at Z=4.2 mm, so the copied floor is 12.8 mm above the glass bottom. Raising both the glass and opening by 6.4 mm puts the LED base opening at Z=23.4 mm. The opening passes through the two rail ends, while the base retains the lower wall and complete glass seat. Align the stem with +X; the cable exits separately along +Y. This preserves the tested opening relative to the glass, but the complete LED assembly still needs a physical check.

The Bambu LED puck is 59.4 mm in diameter and 8 mm thick. Its underside pocket uses the pumpkin's proven 0.15 mm radial clearance and 0.1 mm extra depth: a 59.7 mm × 8.1 mm nominal pocket with the same 1.5 mm, 45-degree annular stop. The stop leaves the full 47.6 mm lens clear, and the seat has a through-opening above it. A 3.4 mm-wide underside groove carries the cable toward +Y. The puck back sits 0.1 mm above the base underside; the glass load is carried by the annular plastic seat and soft liner, rather than the puck.

## Files and printing

| File | Contents | Orientation |
| --- | --- | --- |
| [bong-stabilizer-base.stl](../bong-stabilizer-base.stl) | One 172 mm foot with flat mating shoulder and no pad recesses, flat bottom and 4.2 mm top edge radius, LED pocket and open light path and stem relief, v11 | Flat underside on bed |
| [bong-stabilizer-collar-set.stl](../bong-stabilizer-collar-set.stl) | Both rounded-top collar halves with fully flat undersides and rear end faces and 25 mm front gap, spaced apart, v06 | Flat undersides on bed, as exported |
| [bong-stabilizer-screw-set.stl](../bong-stabilizer-screw-set.stl) | Four printed hex-head bolts, v06; 45 × 42.3 mm layout | Flat heads on bed, as exported |
| [bong-stabilizer-screw.stl](../bong-stabilizer-screw.stl) | One hex-head test/replacement bolt, v06 | Flat head on bed, as exported |
| `_work/stl/bong-stabilizer-coupon-base.stl` | 132 mm fit coupon, v06, with the production flat mating shoulder, seat, stem relief, LED pocket and threads | Flat underside on bed |

The wide foot and collar require separate plates. All exported layouts fit within the repo's documented 205 mm safe XY envelope. No profiles were changed and these files have not been sliced.

Before printing the wide foot, print the coupon base, both production collar halves and one test bolt. Check that the puck enters from underneath with its cable in the groove, the glass drops in freely, both halves can move into position, a bolt turns freely by hand in every socket, and the collar sits firmly on the plastic shoulder without pressing on the glass. Check the light through the actual glass and liner ring. The coupon checks fit, light clearance and threads; its smaller footprint does not test the full stabilizer's tipping resistance. Print the remaining bolts once their fit is confirmed.

## Assembly

1. Insert the LED puck from underneath, lens facing up, and route its cable in the open underside groove. The proven snug pocket is the retention method; verify that this print holds it before lifting the assembly.
2. Put a 1 mm-thick soft liner ring, approximately 95 mm outside diameter with a 60 mm centre opening, into the seat. A solid disk would block the light. The ring raises the glass to the design's seating height and cushions the bottom.
3. Lower the glass straight into the seat with both collar halves removed.
4. Move the rails in from opposite Y sides above the flare. Bring their rear ends together, align the 25 mm front gap with the +X stem, and align their holes with the four threaded sockets.
5. Turn the printed hex-head bolts in by hand until their heads hold the collar against the plastic shoulder. Stop if a bolt binds or the collar contacts the glass before reaching the shoulder.

Remove all four bolts and both collar halves to lift the glass out. Check retention while the whole assembly is supported over a soft surface before relying on the base staying attached during normal handling.

## Verification boundary

All seven views of the revised base, collar set, hex-head bolt, bolt set, fit coupon, assembly and section were inspected. The preview reference tube is shortened to 65 mm only to frame the retention detail; the measured source height remains 419.1 mm. Evaluated-geometry renders of the base, collar, assembly and section avoid the noisy OpenCSG rounding previews and omit the background glass reference. Ziad's visual review is pending.

The delivered binary meshes passed independent checks for collapsed triangles, edge incidence and winding: zero errors across all five exports. The foot, coupon and single bolt each have one closed shell; the collar set has two; the bolt set has four. OpenSCAD reported `NoError` for each.

The rounded collar's binary exports contained collapsed triangles at the upper rounded cuts. Geometry-preserving STL re-import and intersection with a containing cube removed those defects; the current v06 cleanup changed the volume by 0 mm³. The retained collar and its v06 workspace copies are the cleaned mesh. Future collar rebuilds need an independent binary mesh check and the same cleanup if the defects recur.

The modeled puck and cable have an empty seated intersection and an empty continuous bottom-entry swept-volume intersection from entirely below the base. The modeled glass has an empty seated intersection and an empty conservative continuous vertical insertion sweep with the collar removed. Both conservative continuous side-entry sweeps, with the opposite rail present, are empty. The rear plate-end join also intersects only in that plane, with no solid overlap. Their seated contact with the plastic shoulder is planar at Z=25.4 mm and has zero volume. The bolt shafts clear the collar holes and the seated bolts clear the female threads. Helical insertion uses matching translation and rotation to preserve thread phase; checks at 49 positions per bolt from seated to entirely above the socket found only planar head contact at Z=31.7 mm. Each rotating hex head is contained within a 10 mm-radius disk centred 56.57 mm from the glass axis, leaving over 25 mm clearance to the measured chamber at every rotation; it stays above the glass flare throughout insertion.

The glass envelope represents the supplied base, flare and chamber diameters. A separate conservative +X rectangular stem proxy uses the reported clearances: 19 mm wide within the 25 mm gap, starting at Z=28.4 mm (5 mm above the opening floor), and extending out beyond the foot and above the entire entry path. Its seated intersection with the complete assembly, continuous vertical entry against the base, and both continuous rail-entry sweeps are empty. This proxy is inferred from approximate clearance feedback, not a measured stem or bowl shape. Other unmeasured bowl/downstem projections are not included; they must clear the collar's 31.7 mm top and the bolt heads' 38 mm top. Actual glass fit, puck retention, brightness, printed thread fit, underside grip, fastener strength and tipping resistance remain untested. The filled centre of mass is unknown, so no tipping-force threshold is claimed.

## Rebuild

```bash
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="base"' --name bong-stabilizer-base
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="collar-set"' --name bong-stabilizer-collar-set
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="screw-set"' --name bong-stabilizer-screw-set
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="screw"' --name bong-stabilizer-screw
utils/build.sh library/drugs/bong-stabilizer/bong-stabilizer.scad -D 'show="coupon-base"' --name bong-stabilizer-coupon-base
```

For visual review, select `show="assembly"`, `show="exploded"` or `show="section"`. Probe variants are `puck-fit`, `puck-insertion`, `glass-fit`, `glass-insertion`, `collar-fit`, `collar-insertion`, `plate-end-fit`, `screw-fit`, `screw-insertion` and `screw-path`. Use `insertion_side=1` and `insertion_side=-1` to check both collar entry routes. These are local modeling checks and export nothing to the printer. The existing `screw` export names are retained for compatibility; their current files contain hex-head bolts.
