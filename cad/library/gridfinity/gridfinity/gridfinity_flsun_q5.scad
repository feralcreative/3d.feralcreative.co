// Note 1.
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity_modules.scad>
use <gridfinity_baseplate.scad>   // Note 3.

ear_hole_x = 182.5; // Note 4.
ear_hole_y = 7; // Note 5.
from_ends = (ear_hole_x - gridfinity_pitch*4) / 2;
cube_z = 4.4; // Note 6.
M4_d = 4.2; // Note 7.

module feral_default_output_594214a32c21() {
translate([gridfinity_pitch/2, gridfinity_pitch/2, 0]) frame_plain(4, 1);
for (i = [0,1]) {
    x = i * ear_hole_x - from_ends;
    difference() {
        hull() {
            translate([x, ear_hole_y, 0]) cylinder(h=cube_z, d=M4_d*2, $fn=20);
            translate([x - from_ends * i, ear_hole_y - M4_d, 0]) cube([from_ends, M4_d*2, cube_z]);
            }
        translate([x, ear_hole_y, -0.01]) cylinder(h=cube_z + 0.02, d=M4_d, $fn=20);
    }
}
}

module feral_assembly_view_594214a32c21(explode=false) {
feral_default_output_594214a32c21();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_594214a32c21();
else feral_assembly_view_594214a32c21(view == "exploded");

// Notes

// Note 1. include instead of use, so we get the pitch

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. for frame_plain

// Note 4. distance between existing screw holes on FLSUN q5.

// Note 5. distance of screw hole from the front panel.

// Note 6. ht from above.

// Note 7. diameter needed for an M4 bolt.
// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
