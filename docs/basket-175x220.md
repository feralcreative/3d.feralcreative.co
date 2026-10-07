# Basket with keyed glue joints

The basket in `parts/basket-75x220.scad` retains its 175 mm minimum inside clearance, approximately 186.92 mm outside diameter, and 220 mm assembled height. It is split into one bottom, three identical middle rings, and one top. The filename predates the current diameter.

The default `shell_style="solid"` has continuous 3.54 mm walls and a closed 3.6 mm floor. Skins, perimeters, and infill are supplied by the slicer; solid CAD does not mean 100% printed infill. The reinforced ends, floor-to-wall gusset, envelope, section heights, and keyed glue joints are unchanged. The current bottom is v04; the middle ring and top are v03.

`shell_style="lattice"` retains the previous diamond side lattice and open cross-hatch floor, including its 109 drainage openings. Build this option under separate output names so it cannot overwrite the solid pieces.

## Print and assembly

| Piece | Quantity | STL | Upright print height |
| --- | --- | --- | --- |
| Bottom | 1 | `stl/basket-175x220-bottom.stl` | 34.35 mm |
| Middle ring | 3 | `stl/basket-175x220-ring.stl` | 57.10 mm |
| Top | 1 | `stl/basket-175x220-top.stl` | 30.35 mm |

Print every piece upright as exported: floor or downward-open socket on the bed, insertion lip upward. The 4 mm lips overlap the next section, so the printed heights do not add up to the assembled height. Use these three meshes for the split basket; the older whole-basket STL is not a split print set.

Each seam has an annular insertion lip, a matching socket, and three asymmetrically spaced keys. The lip is 1.29 mm thick with 4 mm axial engagement. The socket leaves 0.2 mm clearance per radial and tangential face and 0.3 mm above the lip. The flat shoulder controls seating depth. Continuous collars surround each seam for 4.5 mm below and 7 mm above it, keeping the outside diameter and inside clearance unchanged. Socket roofs close at 45 degrees; in the lattice variant, collar transitions include short bridges across the diamond openings.

Dry-fit all five pieces first. Line up the three keys and slide each arriving section straight down until its shoulder seats. Each successive middle ring turns 4.5° relative to the preceding one; the keys enforce the correct phase. Apply glue to the overlapping lip and socket surfaces, then seat the joint. The keys locate the pieces—they do not snap or lock together without glue.

## Inspection

The source provides `assembled`, `exploded`, and the three print variants. `joint-section` shows a close-up cut through a key, the overlapping surfaces, and the shoulder stop. `joint-fit` intersects all four mating pairs; `joint_probe_offset` moves each arriving piece upward for path checks. At offset zero the intentional shoulder contact can appear as coplanar sheets with zero volume. `joint-insertion` intersects the lips with a conservative continuous receiver envelope. `joint-wrong-angle` deliberately rotates the key pattern by half a column and must produce interference.

On 2026-10-06, all seven assembled views, seven exploded views, and seven joint-section views were inspected. The four seated joints had no penetrating volume; the only contact was at their shoulder stops. A nine-state axial configuration-space path from 11 mm above seating to the stop was reachable, with every edge certified by the continuous envelope. The wrong-phase check produced approximately 21.93 mm³ of interference.

All three keyed-joint v02 binary STLs passed independent collapsed-triangle, edge-incidence, winding, and connected-component checks: one solid per piece and zero bad triangles or edges. OpenSCAD reported `NoError`, with genus 40 for the original solid-floor bottom, 121 for the ring, and 41 for the top. Raw exports contained collapsed triangles at coincident surfaces; re-importing each binary mesh and intersecting it with a containing cube removed those artifacts. Maximum measured volume change was less than 0.0003 mm³.

The open-floor v03 bottom was subsequently inspected in all seven views and independently checked: 8,910 triangles, one connected solid, zero collapsed triangles, bad edges, or winding errors, and `NoError` with genus 149. Cross-sections at Z=0.05, 1.80, and 3.59 mm each had 109 floor openings plus the outer perimeter, confirming that the cells remain open throughout the floor. Cleanup changed the volume by less than 0.0003 mm³. Floor cutters end at Z=3.61 mm, entirely below the lowest glue collar at Z=25.85 mm.

These are geometry and modeled insertion checks. The joints and floor have not been physically printed, floor load capacity and glue strength are untested, and no revised basket print jobs were generated in these changes.

## Solid shell revision

On 2026-10-07, Ziad reported that the basket was too brittle. The default was changed to continuous walls and floor while retaining the previous lattice as an option. All seven assembled views were inspected using full geometry rendering; fast preview shows coplanar surface artifacts on the continuous shell.

After the same re-import/containing-cube cleanup described below, the solid bottom, ring, and top have 4,422, 4,616, and 3,824 triangles respectively. All three have zero collapsed triangles, bad edges, or winding errors. OpenSCAD reports `NoError`, with genus 0 for the closed-bottom piece and genus 1 for each open ring/top. Cleanup preserved each volume to within 0.000001 mm³.

All four seams were rechecked at axial offsets 11, 8, 6, 4, 3, 2, 1, 0.5, and 0 mm. Every elevated state is empty; the seated intersection contains only planar shoulder contacts with effectively zero signed volume. The unchanged conservative continuous insertion envelope is also empty, certifying the axial path between the sampled states.

The old and new split pieces were sliced using the existing basket job's named profiles: `0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle` and `Flashforge PETG Pro`. G-code confirms 0.20 mm layers, two wall loops, 15% grid infill, and no supports. These are slicer estimates, not measured print times.

| Piece | Quantity | Lattice time | Solid time | Lattice filament | Solid filament |
| --- | --- | --- | --- | --- | --- |
| Bottom | 1 | 3h 53m 00s | 2h 46m 26s | 97.11 g | 115.58 g |
| Middle ring | 3 | 4h 01m 41s each | 2h 12m 29s each | 77.75 g each | 87.51 g each |
| Top | 1 | 1h 38m 04s | 1h 15m 25s | 45.53 g | 49.33 g |
| Complete basket | 5 pieces | 17h 36m 07s | 10h 39m 18s | 375.89 g | 427.44 g |

The solid basket is estimated to print 39.5% faster with 13.7% more filament. Strength remains untested. Comparison G-code stays in the session's temporary directory. Flash Studio's known OpenGL thumbnail failure prevented the initial 3MF exports; subsequent timing runs skipped that export. No new printer job was delivered or sent, and the existing whole-basket 3MF still represents the previous design. Use the three current split STLs above to create the revised jobs.

## Rebuild

This reproduces the cleaned exports without changing the general build utility. The intermediate files stay outside the repo; the final build assigns the next version to each piece. Run an independent binary-STL check after rebuilding.

```bash
basket_build_dir=$(mktemp -d /private/tmp/basket-joints.XXXXXX)
for piece in bottom ring top; do
    name="basket-175x220-$piece"
    OUTDIR="$basket_build_dir" utils/build.sh parts/basket-75x220.scad \
        -D "show=\"$piece\"" --name "$name" --no-version
    cat > "$basket_build_dir/$name.scad" <<EOF
intersection() {
    import("$basket_build_dir/$name.stl", convexity = 10);
    translate([-100, -100, -1]) cube([200, 200, 222]);
}
EOF
    utils/build.sh "$basket_build_dir/$name.scad" --name "$name"
done
```
