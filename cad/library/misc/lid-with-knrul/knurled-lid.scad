// Note 1.
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

measured_neck_diameter = 30.0; // Note 3.
measured_neck_height = 12.0;   // Note 4.
clearance = 0.3;               // Note 5.

thread_pitch = 3.0;            // Note 6.
thread_depth = 1.0;            // Note 7.

shell_thickness = 2.0;         // Note 8.
knurl_size = 1.5;              // Note 9.

lid_inner_d = measured_neck_diameter + clearance;
lid_outer_d = lid_inner_d + (shell_thickness * 2);
lid_total_h = measured_neck_height + shell_thickness;
thread_turns = (measured_neck_height - 2) / thread_pitch;

// Note 10.
knurl_count = round((PI * lid_outer_d) / (knurl_size * 2));

$fn = 60; // Note 11.

module thread_profile(angle) {
    z_pos = angle * (thread_pitch / 360);
    rotate([0, 0, angle])
    translate([lid_inner_d / 2, 0, z_pos])
    rotate([0, -90, 0])
    // Note 12.
    cylinder(h = thread_depth, r1 = thread_pitch / 2.2, r2 = 0, $fn = 4);
}
// Note 13.

module feral_default_output_f4fa69363fa9() {
union() {
    // Note 14.
    difference() {
        cylinder(h = lid_total_h, d = lid_outer_d);
        translate([0, 0, shell_thickness])
            cylinder(h = lid_total_h + 1, d = lid_inner_d);
    }

    // Note 15.
    translate([0, 0, shell_thickness + 1])
    for (i = [0 : 6 : 360 * thread_turns]) {
        hull() {
            thread_profile(i);
            thread_profile(i + 6);
        }
    }

    // Note 16.
    for (i = [0 : knurl_count - 1]) {
        rotate([0, 0, i * (360 / knurl_count)])
        translate([lid_outer_d / 2, 0, 0])
        cylinder(h = lid_total_h, d = knurl_size, $fn = 20);
    }
}
}

module feral_assembly_view_f4fa69363fa9(explode=false) {
feral_default_output_f4fa69363fa9();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_f4fa69363fa9();
else feral_assembly_view_f4fa69363fa9(view == "exploded");

// Notes

// Note 1. --- [1. User Measurement Input] ---

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. Measured max diameter of the bottle neck (including threads)

// Note 4. Measured height of the bottle neck

// Note 5. Fitting clearance (added to the inner diameter)
// --- [2. Thread Specification] ---

// Note 6. Vertical distance between thread peaks

// Note 7. How far the thread extends inward
// --- [3. Structure & Knurling Settings] ---

// Note 8. Uniform thickness for walls and top lid

// Note 9. Diameter of each external embossed rib
// --- [Internal Calculated Variables] ---

// Note 10. Calculate number of knurls to maintain a 1:1 ratio between rib and flat space

// Note 11. Resolution for cylinders
// --- [Main Modeling] ---
// Module for generating the thread cross-section

// Note 12. Sharp triangular profile pointing inward

// Note 13. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.

// Note 14. 1. Main Lid Body

// Note 15. 2. Internal Helical Threads

// Note 16. 3. External Embossed Knurling (Ribs only)
