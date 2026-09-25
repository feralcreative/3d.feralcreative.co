// gridfinity-cup.scad — the vendored basic_cup with magnets BURIED in it.
//
// gridfinity_basic_cup.scad is the upstream entry point and its magnet option
// opens pockets on the underside, to glue discs into from below. This is the
// same cup with that turned off and closed cavities cut instead, which the
// discs drop into at a print pause and get bridged over. Everything else about
// the cup is upstream's; only the magnets differ.
//
// Sizes come from the command line, and a variant needs its own --name or it
// shares this file's version series:
//   utils/build.sh parts/gridfinity/gridfinity-cup.scad \
//     -D 'width=2' -D 'depth=2' -D 'height=6' --name gridfinity-cup-2x2x6

include <gridfinity-magnets.scad>
use <gridfinity_cup_modules.scad>

/* [Size] */
width = 2;              // cells across
depth = 2;              // cells deep
height = 6;             // 7 mm units tall

/* [Magnets] */
magnet_hole_d = 10.5;   // mm cavity for a 10 mm disc, four per cell. 0 for none.
magnet_cav_h = 2.2;     // mm tall: a 2 mm disc and 0.2 to drop it in
magnet_skin = 0.4;      // mm of plastic under the cavity — 2 layers at 0.2

/* [Cup] */
chambers = 1;           // divisions across the width
floor_thickness = 0.7;  // mm above the base cutouts, upstream's default
wall_thickness = 0.95;  // mm, upstream's default
fingerslide = false;    // larger corner fillet to scoop things out
lip_style = "normal";   // [normal, reduced, none]

$fn = 48;

difference() {
  basic_cup(num_x = width, num_y = depth, num_z = height,
            chambers = chambers,
            magnet_diameter = 0, screw_depth = 0,
            floor_thickness = floor_thickness,
            wall_thickness = wall_thickness,
            fingerslide = fingerslide,
            lip_style = lip_style);

  // The cup's own floor sits at 5.7 mm whatever the options, so a cavity
  // ending at skin + height has solid material above it to bridge across.
  if (magnet_hole_d > 0) {
    assert(magnet_skin + magnet_cav_h < 5.7,
           "the cavity would break into the cup's interior");
    magnet_cavities(width, depth, magnet_hole_d, magnet_cav_h, magnet_skin);
  }
}
