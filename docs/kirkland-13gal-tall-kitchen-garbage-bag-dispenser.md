# Kirkland 13-gallon tall kitchen bag dispenser

The replacement for the lattice basket is a freestanding, solid-walled cylinder with two screw-together halves. The upper half includes the lid. Its underside rises gently toward a rounded centre opening to guide bags from the centre of the roll. Both halves have the same outside diameter; all thread reinforcement is inside.

## Dimensions

| Feature | Dimension |
| --- | --- |
| Measured roll envelope | 177.8 mm diameter × 228.6 mm high (7 × 9 inches) |
| Minimum clear cavity | 180 mm across flats × 230 mm high |
| Outside diameter | 194.82 mm |
| Assembled height | 249.8 mm |
| Bottom print height | 136.6 mm |
| Upper print height | 131.2 mm |
| Dispensing opening | 38 mm nominal, rounded on both edges |
| Guide rise | 12 mm, entirely above the clear roll cavity |
| Screw joint | Right-handed, 6 mm pitch, 18 mm engagement |
| Main wall | 2.94 mm; joint thickening transitions inside at 45 degrees |

The 180 mm minimum bore includes the male thread neck. The cavity widens away from the joint. The lowest point of the guide is 230 mm above the floor, so its cone does not steal height from the roll. Parameter assertions protect the measured roll envelope and the 220 mm printer envelope.

## Printing and loading

Print the bottom upright on its floor. Print the upper half upside down on its flat lid face—the `top` variant already applies that orientation. Each half needs its own plate. The solid walls, floor and lid let the slicer supply infill; infill is not modelled as lattice geometry.

First print the `coupon-bottom` and `coupon-top` variants. These short, full-diameter rings preserve the complete production threads and their approach surfaces. Their heights are 26 mm and 31.25 mm. Check that they start easily, screw all the way to the shoulder and release without binding before printing the tall halves.

Load the roll vertically through the lower half's open mouth. Find the centre bag end and feed it through the upper half's opening before screwing the upper half down to the shoulder. Avoid twisting the bag end while turning the cap.

```sh
utils/build.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="bottom"' --name kirkland-13gal-tall-kitchen-garbage-bag-dispenser-bottom
utils/build.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="top"' --name kirkland-13gal-tall-kitchen-garbage-bag-dispenser-top
utils/build.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="coupon-bottom"' --name kirkland-13gal-tall-kitchen-garbage-bag-dispenser-coupon-bottom
utils/build.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="coupon-top"' --name kirkland-13gal-tall-kitchen-garbage-bag-dispenser-coupon-top
utils/render.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="assembled"' --render=cgal
utils/render.sh parts/kirkland-13gal-tall-kitchen-garbage-bag-dispenser.scad -D 'show="section"' --render=cgal
```

Always give each build variant its own output name. The source defaults to the exploded view for inspection.

## Verification—2026-10-07

All seven assembled renders and all seven section renders were inspected. Version 02 exports for both full halves and both coupons report `NoError`. The bottom has genus 0; the upper half and coupons have genus 1. The delivered binary meshes each have one connected component, zero collapsed triangles, zero bad edge incidences and consistent winding. Re-import/intersection cleanup removed export degeneracies with less than 0.000001 mm³ volume change. Repeat the independent binary checks after future exports; OpenSCAD's status alone does not detect these artifacts.

The measured roll fits the assembly, and its continuous straight loading sweep through the bottom is empty. Cap-over-roll intersections are empty from the seated pose through the outside approach. Full-half screw-pose checks from 24 mm lift to seating are empty except the seated shoulder's planar contact (about 0.000002 mm³ numerical residue). A deliberately wrong 180-degree thread phase produces about 1855 mm³ interference, confirming that the probe detects collisions.

The continuous thread check uses a full periodic male helix, an enclosing 0.1 mm motion cube and a verified enlarged guard. `thread-guard-fit` is empty. `thread-path` checks guarded midpoints every 0.1 degree over the repeating 2-degree mesh cell; the maximum intervening screw motion is below 0.084 mm. That covers the continuous path between samples. The open socket mouth, blunt male ends and 0.8 mm tip gap handle the finite ends.

Flash Studio G-code checks used the existing `0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle` process and `Flashforge PETG Pro` filament: 15% infill, two wall loops, Textured PEI Plate, supports disabled and no support toolpaths. The bottom estimate is 7h 16m / 291 g; the upper estimate is 8h 55m / 324 g. These are slicer estimates, not measured prints. The checked exports are G-code only; no new printer-ready 3MF was produced.

Physical thread fit, bag feeding, strength and actual print time still need the coupon and first print. The old basket source and generated outputs are retired.
