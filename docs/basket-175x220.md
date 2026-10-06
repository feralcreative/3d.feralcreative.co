# Basket with keyed glue joints

The basket in `parts/basket-75x220.scad` retains its 175 mm minimum inside clearance, approximately 186.92 mm outside diameter, and 220 mm assembled height. It is split into one bottom, three identical middle rings, and one top. The filename predates the current diameter.

## Print and assembly

| Piece | Quantity | STL | Upright print height |
| --- | --- | --- | --- |
| Bottom | 1 | `stl/basket-175x220-bottom.stl` | 34.35 mm |
| Middle ring | 3 | `stl/basket-175x220-ring.stl` | 57.10 mm |
| Top | 1 | `stl/basket-175x220-top.stl` | 30.35 mm |

Print every piece upright as exported: floor or downward-open socket on the bed, insertion lip upward. The 4 mm lips overlap the next section, so the printed heights do not add up to the assembled height. Use these three meshes for the split basket; the older whole-basket STL is not a split print set.

Each seam has an annular insertion lip, a matching socket, and three asymmetrically spaced keys. The lip is 1.29 mm thick with 4 mm axial engagement. The socket leaves 0.2 mm clearance per radial and tangential face and 0.3 mm above the lip. The flat shoulder controls seating depth. Continuous collars fill the lattice for 4.5 mm below and 7 mm above each seam, keeping the outside diameter and inside clearance unchanged. Socket roofs close at 45 degrees; collar transitions include short bridges across the diamond openings.

Dry-fit all five pieces first. Line up the three keys and slide each arriving section straight down until its shoulder seats. Each successive middle ring turns 4.5° relative to the preceding one; the keys enforce the correct phase. Apply glue to the overlapping lip and socket surfaces, then seat the joint. The keys locate the pieces—they do not snap or lock together without glue.

## Inspection

The source provides `assembled`, `exploded`, and the three print variants. `joint-section` shows a close-up cut through a key, the overlapping surfaces, and the shoulder stop. `joint-fit` intersects all four mating pairs; `joint_probe_offset` moves each arriving piece upward for path checks. At offset zero the intentional shoulder contact can appear as coplanar sheets with zero volume. `joint-insertion` intersects the lips with a conservative continuous receiver envelope. `joint-wrong-angle` deliberately rotates the key pattern by half a column and must produce interference.

On 2026-10-06, all seven assembled views, seven exploded views, and seven joint-section views were inspected. The four seated joints had no penetrating volume; the only contact was at their shoulder stops. A nine-state axial configuration-space path from 11 mm above seating to the stop was reachable, with every edge certified by the continuous envelope. The wrong-phase check produced approximately 21.93 mm³ of interference.

All three v02 binary STLs passed independent collapsed-triangle, edge-incidence, winding, and connected-component checks: one solid per piece and zero bad triangles or edges. OpenSCAD reported `NoError`, with genus 40 for the bottom, 121 for the ring, and 41 for the top. Raw exports contained collapsed triangles at coincident surfaces; re-importing each binary mesh and intersecting it with a containing cube removed those artifacts. Maximum measured volume change was less than 0.0003 mm³.

These are geometry and modeled insertion checks. The joints have not been physically printed or dry-fitted, glue strength is untested, and no revised basket print jobs were generated in this change.

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
