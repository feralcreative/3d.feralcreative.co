// gridfinity-watch-charger-base.scad — a flat 1x1 Gridfinity deck carrying a solid
// rectangular block. The block is 32.5 mm along X, 27.7 mm along Y, and 12 mm
// tall, centred on the cell and standing on the flat top of a one-unit base.
// The stacking lip is omitted so the deck is a plain flat surface.
// Rear is +Y: the 32.5 mm face has a cable channel that scoops upward.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>
include <../../../lib/BOSL2/std.scad>

/* [Block] */
block_x = 32.5;        // mm
block_y = 27.7;        // mm
block_h = 12;          // mm, above the deck
block_edge_r = 1;      // mm, roundover on the block and channel lips

/* [Cable] */
cable_d = 3.5;         // mm, measured cord diameter
cable_groove_w = 6;    // mm, wider channel for larger cables
cable_groove_depth = block_y / 2; // mm, total reach from rear face to centerline
cable_offset_x = 0;    // mm from the center of the rear 32.5 mm face

/* [Base] */
units_z = 1;           // 7 mm units; deck ends at 7 mm, without a stacking lip

/* [Magnets] */
magnet_hole_d = 10.5;   // mm, four enclosed cavities for 10 mm discs
magnet_cav_h = 2.2;     // mm, accommodates 2 mm thick magnets
magnet_skin = 0.4;     // mm below the cavities; insert at the usual print pause

$fn = 64;
eps = 0.01;

/* [Derived] */
deck_h = gridfinity_zpitch * units_z;

module cable_scoop() {
  rear_y = block_y / 2;
  inner_y = rear_y - cable_groove_depth;
  arc_steps = $fn;
  // Rise over the entire channel length, easing into both the deck and top.
  // The cosine ramp reaches the top exactly at the block centerline; there
  // is no flat passage followed by a separate bend or upright inner wall.
  scoop_profile = concat(
    [[rear_y + eps, deck_h]],
    [for (i = [0:arc_steps])
      let(t = i / arc_steps)
      [rear_y - cable_groove_depth * t,
       deck_h + block_h * (1 - cos(180 * t)) / 2]],
    [[inner_y, deck_h + block_h + eps],
     [rear_y + eps, deck_h + block_h + eps]]);

  translate([cable_offset_x - cable_groove_w / 2, 0, 0])
  rotate([90, 0, 90])
  linear_extrude(height = cable_groove_w, convexity = 10)
  polygon(scoop_profile);
}

module rounded_block() {
  // Round only the raised block, after carving the channel, so its convex
  // lips soften too. The base and buried magnet interfaces are separate.
  round3d(or = block_edge_r,
          size = 2 * max(block_x, block_y, deck_h + block_h), $fn = 24)
  difference() {
    translate([-block_x / 2, -block_y / 2, deck_h - eps])
    cube([block_x, block_y, block_h + eps]);
    cable_scoop($fn = 64);
  }
}

module block_base() {
  assert(max(block_x, block_y) < gridfinity_pitch - gridfinity_clearance,
         "block overhangs the cell");
  assert(magnet_hole_d <= 0 || magnet_skin + magnet_cav_h < deck_h,
         "magnet cavities break through the deck");
  assert(cable_d > 0 && cable_groove_w > cable_d &&
         abs(cable_offset_x) + cable_groove_w / 2 < block_x / 2 &&
         cable_groove_depth > cable_d &&
         cable_groove_depth <= block_y / 2,
         "cable groove must end at or before the block centerline");
  assert(block_edge_r >= 0 && 2 * block_edge_r <
         min(block_x, block_y - cable_groove_depth, block_h),
         "block edge radius is too large");

  difference() {
    union() {
      // Start one unit taller so trimming removes the entire stacking recess,
      // including its 0.1 mm overlap below the nominal deck.
      intersection() {
        grid_block(1, 1, units_z + 1, magnet_diameter = 0, screw_depth = 0, center = true);
        translate([-gridfinity_pitch / 2, -gridfinity_pitch / 2, -eps])
        cube([gridfinity_pitch, gridfinity_pitch, deck_h + eps]);
      }

      rounded_block();
    }

    if (magnet_hole_d > 0)
      magnet_cavities(1, 1, magnet_hole_d, magnet_cav_h, magnet_skin, center = true);
  }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_fc65883d7c1b() {
block_base();
}

module feral_assembly_view_fc65883d7c1b(explode=false) {
feral_default_output_fc65883d7c1b();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_fc65883d7c1b();
else feral_assembly_view_fc65883d7c1b(view == "exploded");
