// gridfinity-block-base.scad — a flat 1x1 Gridfinity deck carrying a solid
// rectangular block. The block is 32.5 mm along X, 27.7 mm along Y, and 12 mm
// tall, centred on the cell and standing on the flat top of a one-unit base.
// The stacking lip is omitted so the deck is a plain flat surface.

include <gridfinity-magnets.scad>

/* [Block] */
block_x = 32.5;        // mm
block_y = 27.7;        // mm
block_h = 12;          // mm, above the deck

/* [Base] */
units_z = 1;           // 7 mm units; deck ends at 7 mm, without a stacking lip

/* [Magnets] */
magnet_hole_d = 10.5;   // mm, four enclosed cavities for 10 mm discs
magnet_cav_h = 2.2;     // mm, accommodates 2 mm thick magnets
magnet_skin = 0.4;     // mm below the cavities; insert at the usual print pause

eps = 0.01;

/* [Derived] */
deck_h = gridfinity_zpitch * units_z;

module block_base() {
  assert(max(block_x, block_y) < gridfinity_pitch - gridfinity_clearance,
         "block overhangs the cell");
  assert(magnet_hole_d <= 0 || magnet_skin + magnet_cav_h < deck_h,
         "magnet cavities break through the deck");

  difference() {
    union() {
      // Start one unit taller so trimming removes the entire stacking recess,
      // including its 0.1 mm overlap below the nominal deck.
      intersection() {
        grid_block(1, 1, units_z + 1, magnet_diameter = 0, screw_depth = 0, center = true);
        translate([-gridfinity_pitch / 2, -gridfinity_pitch / 2, -eps])
        cube([gridfinity_pitch, gridfinity_pitch, deck_h + eps]);
      }

      translate([-block_x / 2, -block_y / 2, deck_h - eps])
      cube([block_x, block_y, block_h + eps]);
    }

    if (magnet_hole_d > 0)
      magnet_cavities(1, 1, magnet_hole_d, magnet_cav_h, magnet_skin, center = true);
  }
}

block_base();
