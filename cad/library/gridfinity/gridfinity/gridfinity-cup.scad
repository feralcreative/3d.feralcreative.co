// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>
use <gridfinity_cup_modules.scad>

/* [Size] */
width = 2;              // Note 3.
depth = 2;              // Note 4.
height = 6;             // Note 5.

/* [Magnets] */
magnet_hole_d = 10.5;   // Note 6.
magnet_cav_h = 2.2;     // Note 7.
magnet_skin = 0.4;      // Note 8.

/* [Cup] */
chambers = 1;           // Note 9.
floor_thickness = 0.7;  // Note 10.
wall_thickness = 0.95;  // Note 11.
fingerslide = false;    // Note 12.
lip_style = "normal";   // [normal, reduced, none]

$fn = 48;

// Note 13.

module feral_default_output_1423db6f9a04() {
difference() {
  basic_cup(num_x = width, num_y = depth, num_z = height,
            chambers = chambers,
            magnet_diameter = 0, screw_depth = 0,
            floor_thickness = floor_thickness,
            wall_thickness = wall_thickness,
            fingerslide = fingerslide,
            lip_style = lip_style);

  // Note 14.

  if (magnet_hole_d > 0) {
    assert(magnet_skin + magnet_cav_h < 5.7,
           "the cavity would break into the cup's interior");
    magnet_cavities(width, depth, magnet_hole_d, magnet_cav_h, magnet_skin);
  }
}
}

module feral_assembly_view_1423db6f9a04(explode=false) {
feral_default_output_1423db6f9a04();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_1423db6f9a04();
else feral_assembly_view_1423db6f9a04(view == "exploded");

// Notes

// Note 1. gridfinity-cup.scad — the vendored basic_cup with magnets BURIED in it.
//
// gridfinity_basic_cup.scad is the upstream entry point and its magnet option
// opens pockets on the underside, to glue discs into from below. This is the
// same cup with that turned off and closed cavities cut instead, which the
// discs drop into at a print pause and get bridged over. Everything else about
// the cup is upstream's; only the magnets differ.
//
// Sizes come from the command line, and a variant needs its own --name or it
// shares this file's version series:
// utils/build.sh parts/gridfinity/gridfinity-cup.scad \
// -D 'width=2' -D 'depth=2' -D 'height=6' --name gridfinity-cup-2x2x6

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. cells across

// Note 4. cells deep

// Note 5. 7 mm units tall

// Note 6. mm cavity for a 10 mm disc, four per cell. 0 for none.

// Note 7. mm tall: a 2 mm disc and 0.2 to drop it in

// Note 8. mm of plastic under the cavity — 2 layers at 0.2

// Note 9. divisions across the width

// Note 10. mm above the base cutouts, upstream's default

// Note 11. mm, upstream's default

// Note 12. larger corner fillet to scoop things out

// Note 13. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.

// Note 14. The cup's own floor sits at 5.7 mm whatever the options, so a cavity
// ending at skin + height has solid material above it to bridge across.
