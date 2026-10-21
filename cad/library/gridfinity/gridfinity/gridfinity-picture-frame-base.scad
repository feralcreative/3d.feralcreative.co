// gridfinity-picture-frame-base.scad — a low 1x4 nest for an acrylic frame.
// The measured 154.5 x 23.5 mm base enters vertically into a single channel.
// The flat floor carries it; surrounding walls locate it without a press fit.
// No stacking lip: the frame occupies this base while in use.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>
include <../../../lib/BOSL2/std.scad>

/* [Picture frame] */
frame_l = 154.5;        // mm, long outside dimension of the frame base
frame_w = 23.5;         // mm, short outside dimension of the frame base
fit_clearance = 1.0;    // mm added overall on each axis, 0.5 mm per side

/* [Gridfinity] */
cells_x = 4;           // cells along the frame
cells_y = 1;           // cells across it
units_z = 2;           // 7 mm units; flat top at 14 mm, without a stacking lip
floor_thickness = 2;   // mm above the 5 mm base pads

/* [Channel] */
channel_corner_r = 0.5; // mm, small enough to clear a sharp-cornered frame base
entry_r = 0.75;        // mm, roundover around the channel mouth
entry_steps = 12;      // quarter-circle segments in the roundover

/* [Magnets] */
magnet_hole_d = 10.5;   // mm, four enclosed cavities per cell for 10 mm discs
magnet_cav_h = 2.2;     // mm, accommodates 2 mm thick magnets
magnet_skin = 0.4;     // mm below the cavities; insert at the usual print pause

$fn = 64;
eps = 0.01;

/* [Derived] */
pad_top = 5;           // mm, existing Gridfinity foot height
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
    // Generate taller, then trim, to remove the entire stacking recess.
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



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_84c73e659604() {
picture_frame_base();
}

module feral_assembly_view_84c73e659604(explode=false) {
feral_default_output_84c73e659604();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_84c73e659604();
else feral_assembly_view_84c73e659604(view == "exploded");
