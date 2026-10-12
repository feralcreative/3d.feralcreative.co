# Pumpkin custom supports

## Files

- [Release coupon: pumpkin-body-support-coupon-overture-petg.3mf](../_work/3mf/pumpkin-body-support-coupon-overture-petg.3mf)
- [Full pumpkin: pumpkin-body-supported-overture-petg.3mf](../_work/3mf/pumpkin-body-supported-overture-petg.3mf)
- [Seven cutaway views: pumpkin-custom-supports-overview.png](../_work/renders/pumpkin-custom-supports-overview.png)

Experimental removable supports for our upright pumpkin body with the fitted LED-puck pocket. The pumpkin geometry, wall thickness, stem socket, and puck fit are unchanged. The default `show="body"` still exports the original body alone.

The supported variant adds 54 narrow radial fins, one under each roof groove, plus a hollow tower under the floating stem seat. Each fin is 0.84 mm thick and sits on its own 2.10 mm square post. The support tops follow the actual inner roof triangles in 1 mm radial steps. A nominal 0.20 mm air gap is quantized downward to the 0.20 mm layer grid, so the actual contact clearance varies slightly. These are normal model geometry; automatic slicer supports are disabled.

## Print the release coupon first

Open `_work/3mf/pumpkin-body-support-coupon-overture-petg.3mf` as a project in Flash Studio and slice it. It contains a small patch of the actual roof over two 0.84 mm contact rails, on short posts. The CLI estimate is 8m32s and 0.73 g. Check whether the roof bridges cleanly and the supports release without tearing or whitening it. This coupon tests roof contact release; it does not prove tall-post stability, stem-seat quality, or full-body extraction by hand.

The full candidate is `_work/3mf/pumpkin-body-supported-overture-petg.3mf`. Both projects target the Adventurer 5M Pro with a 0.4 mm nozzle and Overture PETG White at 240 C. They use 0.20 mm layers, 0.20 mm first layer, two walls, zero infill, four top/bottom layers, Classic walls, critical-only vertical-shell reinforcement, 80 mm/s outer walls, no brim, no raft, and no automatic supports. Retraction remains the working machine value of 0.8 mm. Process changes are stored in the project and on the object so an imported system preset cannot silently restore tree supports. Global presets were not changed.

## Comparison

All estimates below are from Flash Studio CLI G-code, using the same printer, filament, body and process settings; only the modeled supports versus automatic trees differ. They are estimates, not measured print times or verified GUI imports.

| Variant | Time | Filament |
| --- | --- | --- |
| Automatic trees, 30-degree threshold | 9h52m17s | 146.82 g |
| Custom radial fins, automatic supports off | 9h29m30s | 139.99 g |
| Roof release coupon | 8m32s | 0.73 g |

The custom fins save about 23 minutes and 6.83 g. Their main benefit is predictable placement and a planned removal route. Removing 54 individual fins may take more hand work than trees. An earlier diagonal-rod lattice used less plastic but sliced at 12h16m48s because it produced many more separate toolpaths; it is not the delivered candidate.

## Removal

Remove supports before fitting the LED puck or the stem. Pull the hollow central tower straight down through the LED opening first. Free each fin from the roof contact, lower it about 14 mm, move it about 29 mm inward along its radial direction, then withdraw it downward. Remove fins individually; moving a wide group inward can catch adjacent supports. The opening is about 56.7 mm at its narrowest; a fin translated inward occupies roughly a 28 mm radial span. Do not force a roof contact that is still bonded; the release coupon must establish whether the gap is appropriate for this PETG.

The continuous translation sweeps were checked against the body for all 54 fins and the tower. Neighbor checks cover the six distinct groove positions in one repeating lobe, with all other fins present and the central tower already removed. All intersections were empty, without warnings. This is geometric clearance evidence, not proof of physical release, access with a particular tool, or a successful print.

## Geometry checks

The supported STL contains 56 independent shells: the original pumpkin, the tower, and 54 fins. It has zero collapsed triangles and all mesh edges have incidence two. Three tiny nonzero-area triangles are inherited from the original body near the stem socket; a containing-cube Manifold re-import preserved them. The coupon contains two independent shells, zero collapsed triangles, and all edges have incidence two. G-code has zero Support/Support-interface roles in the custom candidate and coupon; modeled supports print as ordinary walls. All seven coupon and section render views are reviewed locally; Ziad still makes the appearance and physical-print call.

## Regenerate

Run from the repo root:

```bash
utils/build.sh pumpkin-body -D 'show="supported"' --name pumpkin-body-supported
utils/build.sh pumpkin-body -D 'show="support-coupon"' --name pumpkin-body-support-coupon
python3 utils/pumpkin-support-project.py library/holiday/pumpkin-body/_work/stl/pumpkin-body-supported.stl
python3 utils/pumpkin-support-project.py library/holiday/pumpkin-body/_work/stl/pumpkin-body-support-coupon.stl
```

Render with `utils/render.sh pumpkin-body -D 'show="support-section"'`. Collision checks use `show="support-removal-check"` or `show="support-neighbor-check"` and `support_index=-1`; an expected empty intersection makes OpenSCAD exit 1 with `Current top level object is empty.` Any other error or warning is a failed check.

Keep the layer height at 0.20 mm for this candidate. Changes to size, wall, lobes, ribs, support spacing, or removal distances require renewed geometry and path checks. This remains a personal-use derivative; no publication or printer transmission was performed.
