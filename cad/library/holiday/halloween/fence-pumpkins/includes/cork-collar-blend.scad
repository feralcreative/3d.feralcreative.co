// Note 1.

module cork_collar_blend(radius, axis_y, root_y, floor_z, depth, overlap) {
    intersection() {
        hull() {
            translate([0, axis_y, floor_z])
                scale([radius, radius, depth]) sphere(r = 1);
            translate([0, root_y + overlap, floor_z])
                scale([radius, overlap, depth]) sphere(r = 1);
        }
        translate([-radius - overlap, root_y, floor_z - depth - overlap])
            cube([2 * (radius + overlap), axis_y + radius - root_y + overlap, depth + 2 * overlap]);
    }
}

// Notes

// Note 1. Rounded lower half of the light holder; shared by both door variants.
// Tangent to the vertical collar at its old floor, then retreats into the shell.
