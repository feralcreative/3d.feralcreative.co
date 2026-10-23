// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>
include <../../../lib/BOSL2/std.scad>

/* [Picture frame] */
frame_l = 154.5;        // Note 3.
frame_w = 23.5;         // Note 4.
fit_clearance = 1.0;    // Note 5.

/* [Gridfinity] */
cells_x = 4;           // Note 6.
cells_y = 1;           // Note 7.
units_z = 2;           // Note 8.
floor_thickness = 2;   // Note 9.

/* [Channel] */
channel_corner_r = 0.5; // Note 10.
entry_r = 0.75;        // Note 11.
entry_steps = 12;      // Note 12.

/* [Magnets] */
magnet_hole_d = 10.5;   // Note 13.
magnet_cav_h = 2.2;     // Note 14.
magnet_skin = 0.4;     // Note 15.

$fn = 64;
eps = 0.01;

/* [Derived] */
pad_top = 5;           // Note 16.
floor_z = pad_top + floor_thickness;
holder_h = gridfinity_zpitch * units_z;
channel_depth = holder_h - floor_z;
channel_l = frame_l + fit_clearance;
channel_w = frame_w + fit_clearance;
outer_l = gridfinity_pitch * cells_x - gridfinity_clearance;
outer_w = gridfinity_pitch * cells_y - gridfinity_clearance;

module picture_frame_base() {
  assert(fit_clearance > 0, "allow clearance for removing the frame");
  assert(channel_depth > entry_r, "holder is too short for the channel roundover");
  assert(channel_corner_r <= fit_clearance / 2,
         "channel corners could foul sharp corners on the frame base");
  assert(channel_l + 2 * entry_r < outer_l &&
         channel_w + 2 * entry_r < outer_w, "channel breaks through the outside walls");
  assert(magnet_hole_d <= 0 || magnet_skin + magnet_cav_h < floor_z,
         "magnet cavities break through the channel floor");

  difference() {
    // Note 17.
    intersection() {
      grid_block(cells_x, cells_y, units_z + 1,
                 magnet_diameter = 0, screw_depth = 0, center = true);
      translate([-outer_l / 2 - eps, -outer_w / 2 - eps, -eps])
      cube([outer_l + 2 * eps, outer_w + 2 * eps, holder_h + eps]);
    }

    translate([0, 0, floor_z])
    offset_sweep(rect([channel_l, channel_w], rounding = channel_corner_r),
                 height = channel_depth,
                 top = os_circle(r = -entry_r, extra = eps),
                 steps = entry_steps, check_valid = false);

    if (magnet_hole_d > 0)
      magnet_cavities(cells_x, cells_y, magnet_hole_d, magnet_cav_h,
                      magnet_skin, center = true);
  }
}

// Note 18.

module feral_default_output_84c73e659604() {
picture_frame_base();
}

module feral_assembly_view_84c73e659604(explode=false) {
feral_default_output_84c73e659604();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_84c73e659604();
else feral_assembly_view_84c73e659604(view == "exploded");

// Notes

// Note 1. gridfinity-picture-frame-base.scad — a low 1x4 nest for an acrylic frame.
// The measured 154.5 x 23.5 mm base enters vertically into a single channel.
// The flat floor carries it; surrounding walls locate it without a press fit.
// No stacking lip: the frame occupies this base while in use.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, long outside dimension of the frame base

// Note 4. mm, short outside dimension of the frame base

// Note 5. mm added overall on each axis, 0.5 mm per side

// Note 6. cells along the frame

// Note 7. cells across it

// Note 8. 7 mm units; flat top at 14 mm, without a stacking lip

// Note 9. mm above the 5 mm base pads

// Note 10. mm, small enough to clear a sharp-cornered frame base

// Note 11. mm, roundover around the channel mouth

// Note 12. quarter-circle segments in the roundover

// Note 13. mm, four enclosed cavities per cell for 10 mm discs

// Note 14. mm, accommodates 2 mm thick magnets

// Note 15. mm below the cavities; insert at the usual print pause

// Note 16. mm, existing Gridfinity foot height

// Note 17. Generate taller, then trim, to remove the entire stacking recess.

// Note 18. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
