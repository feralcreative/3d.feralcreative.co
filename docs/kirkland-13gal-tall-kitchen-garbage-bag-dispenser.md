# Kirkland 13-gallon tall kitchen bag dispenser

The replacement for the lattice basket is a freestanding, solid-walled cylinder with two screw-together sections. The seam divides the assembled height into a two-thirds bottom and one-third top. The upper section includes the lid. Its underside rises gently toward a rounded centre opening to guide bags from the centre of the roll. Both sections have the same outside diameter and rounded vertical grip ridges all the way around; all thread reinforcement is inside.

## Dimensions

| Feature | Dimension |
| --- | --- |
| Measured roll envelope | 177.8 mm diameter × 228.6 mm high (7 × 9 inches) |
| Minimum clear cavity | 180 mm across flats × 230 mm high |
| Cylinder diameter between ridges | 194.82 mm |
| Maximum diameter with ridges | 197.22 mm nominal |
| Grip ridges | 48 per section, 1.2 mm projection, rounded cross-section and ends |
| Assembled height | 249.8 mm |
| Seam height from bottom | 166.53 mm (two-thirds of assembled height) |
| Bottom print height | 184.53 mm, including the 18 mm threaded neck |
| Upper print height | 83.27 mm |
| Outside top rim | 2 mm radius |
| Dispensing opening | 38 mm nominal, rounded on both edges |
| Guide rise | 12 mm, entirely above the clear roll cavity |
| Screw joint | Right-handed, 6 mm pitch, 18 mm engagement |
| Main wall | 2.94 mm; joint thickening transitions inside at 45 degrees |

The 180 mm minimum bore includes the male thread neck. The cavity widens away from the joint. The lowest point of the guide is 230 mm above the floor, so its cone does not steal height from the roll. Parameter assertions protect the measured roll envelope and the 220 mm printer envelope.

The vertical ridges cover both sidewalls. Each ridge ends 0.8 mm short of its section's seam face, leaving clearance as the halves turn. The upper ridges also stop below the rounded top rim. The ridges add grip without changing the internal joint or roll envelope.

## Printing and loading

Print the bottom upright on its floor. Print the upper half upside down on its flat lid face—the `top` variant already applies that orientation. Each half needs its own plate. The solid walls, floor and lid let the slicer supply infill; infill is not modelled as lattice geometry.

First print the `coupon-bottom` and `coupon-top` variants. These short, full-diameter rings preserve the complete production threads and their approach surfaces. Their heights are 26 mm and 31.25 mm. Check that they start easily, screw all the way to the shoulder and release without binding before printing the tall halves.

Scaling both coupons to 50% checks engagement at half size, but also halves the nominal clearances: 0.3 mm radial becomes 0.15 mm and 0.2 mm per flank becomes 0.1 mm. Printer dimensional errors do not scale along with the model, so this is not a full-size fit check.

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

Current exports are bottom version 04, upper version 05 and both coupons version 03. All report `NoError`. The bottom has genus 0; the upper section and coupons have genus 1. Each delivered binary mesh has one connected component, zero collapsed triangles, zero bad edge incidences and consistent winding. Re-import/intersection cleanup removed bottom and bottom-coupon export degeneracies, changing each volume by less than 0.495 mm³ (under ten parts per million). Repeat the independent binary checks after future exports; OpenSCAD's status alone does not detect these artifacts.

All seven current assembled renders were inspected; the original internal guide was also reviewed in seven section renders. With the ridges, whole-piece screw-pose checks at 24, 12, 3, 0.1 and 0 mm lift are empty. Roll-fit, the continuous straight loading sweep through the bottom and the cap-over-roll intersection are empty. The ridges remain on opposite sides of the seam throughout the screw approach, so they cannot interfere between sampled poses. Earlier deliberately wrong 180-degree thread alignment produced about 1855 mm³ interference, confirming that the probe detects collisions.

The continuous thread check uses a full periodic male helix, an enclosing 0.1 mm motion cube and a verified enlarged guard. `thread-guard-fit` is empty. `thread-path` checks guarded midpoints every 0.1 degree over the repeating 2-degree mesh cell; the maximum intervening screw motion is below 0.084 mm. That covers the continuous path between samples. The open socket mouth, blunt male ends and 0.8 mm tip gap handle the finite ends.

The earlier equal-height, smooth-wall version was checked in Flash Studio G-code using the existing `0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle` process and `Flashforge PETG Pro` filament: 15% infill, two wall loops, Textured PEI Plate, supports disabled and no support toolpaths. Its estimates were 7h 16m / 291 g for the bottom and 8h 55m / 324 g for the upper half. Those estimates predate the rounded rim, taller bottom and grip ridges. The current geometry has not been resliced; no new printer-ready 3MF was produced.

The refreshed coupons include matching grip ridges. Their thread geometry and clearances are unchanged, so the original smooth-wall coupons already being printed still test this joint.

Physical thread fit, bag feeding, strength and actual print time still need the coupon and first print. The old basket source and generated outputs are retired.
