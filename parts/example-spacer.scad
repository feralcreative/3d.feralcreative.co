// example-spacer.scad
//
// Template part. Shows the house style: parameters at the top, geometry in a
// module, one call at the bottom. Copy this when starting a new part.

/* [Dimensions] */
outer_d   = 20;   // outer diameter (mm)
inner_d   = 8;    // bore diameter (mm)
height    = 5;    // overall height (mm)
flange_d  = 26;   // flange diameter (mm)
flange_h  = 1.6;  // flange thickness (mm)

/* [Quality] */
$fn = 64;         // segments per full circle

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces produce zero-thickness walls that
// confuse the renderer and the slicer.
eps = 0.01;

module spacer() {
    difference() {
        union() {
            cylinder(d = outer_d, h = height);
            cylinder(d = flange_d, h = flange_h);
        }

        // bore, punched all the way through and out both ends
        translate([0, 0, -eps])
            cylinder(d = inner_d, h = height + 2 * eps);
    }
}

spacer();
