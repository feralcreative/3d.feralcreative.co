// Open cradle for the measured 95 mm glass base; lift straight out.
// Separate alternative to bong-stabilizer.scad: that attached design is retained.
// Print flat underside on the bed. Use the fit coupon before the wide foot.
// A 1 mm soft seat liner brings the glass to its nominal seating height.

include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/rounding.scad>

/* [Glass measurements] */
glass_base_d = 95;           // mm, outside diameter of the glass foot
glass_edge_h = 13;           // mm, cylindrical outside edge height
glass_neck_d = 43;           // mm, chamber outside diameter
glass_neck_z = 14;           // mm, flare meets the chamber above the glass bottom
glass_connection_z = 16;     // mm, lowest bowl/downstem point above glass bottom
glass_total_h = 419.1;       // mm, measured 16.5 inch overall height
glass_filled_mass = 1020.6;  // g, approximately 36 ounces filled; reference only

/* [Seat and clearance] */
seat_diameter_clearance = 0.6; // mm, nominal 0.3 mm radial lift-out clearance
floor_h = 4.2;              // mm, glass seating height with the specified liner
liner_h = 1;               // mm, removable soft seat liner
entry_chamfer = 0.6;        // mm, 45-degree opening lead-in
rim_wall = 4.2;             // mm, radial wall at the top of the cradle
wall_base_extra = 7;        // mm, radial outward taper at the wall's foot

/* [Wall and side cutout] */
wall_h = 36;               // mm above the nominal glass seating plane
cutout_w = 25;             // mm, straight opening on the +X side
cutout_bottom_z = 17;      // mm above the printed underside, not the glass seat
cutout_top_r = 3;          // mm, rounding of the two upper cutout corners
rim_round_r = 1;           // mm, rounding along the inner and outer top edges

/* [Foot] */
foot_d = 195;               // mm, broad circular footprint
foot_edge_h = 3;            // mm, thickness at the very outside vertical edge
safe_xy = 205;              // mm, documented safe printer XY envelope

/* [Ring fit coupon] */
ring_coupon_h = 3;          // mm, bottom wall section without the seat floor or foot

/* [Colors] */
cradle_color = "SlateGray";
liner_color = "DimGray";
glass_color = [0.6, 0.85, 1, 0.3];

/* [Output] */
show = "cradle"; // [cradle, coupon, ring-coupon, assembly, glass-fit, glass-insertion]

/* [Hidden] */
$fn = 128;
eps = 0.01;
mesh_margin = 1;           // mm, containing solid used to evaluate the mesh
seat_d = glass_base_d + seat_diameter_clearance;
bore_factor = 1 / cos(180 / $fn); // opening diameter measured across polygon flats
seat_floor_z = floor_h - liner_h;
glass_bottom_z = floor_h;
rim_z = glass_bottom_z + wall_h;
mouth_d = seat_d + 2 * entry_chamfer;
wall_top_d = mouth_d * bore_factor + 2 * rim_wall;
wall_bottom_d = wall_top_d + 2 * wall_base_extra;
foot_chamfer = floor_h - foot_edge_h; // mm, 45-degree bevel above the edge
corner_segments = $fn / 4; // quarter-circle resolution matches the rim facets

assert(glass_neck_z > glass_edge_h && glass_base_d > glass_neck_d,
       "glass flare measurements are inconsistent");
assert(seat_diameter_clearance > 0 && liner_h >= 0 && seat_floor_z > 0,
       "the glass needs lift-out clearance and a solid floor");
assert(wall_h >= glass_edge_h && wall_h - entry_chamfer > 0,
       "the support wall must cover the cylindrical glass edge");
assert(cutout_w > 0 && cutout_w < seat_d &&
       cutout_bottom_z > floor_h && cutout_bottom_z < rim_z,
       "cutout must open one wall without cutting the seat floor");
assert(cutout_top_r > 0 && cutout_top_r < rim_z - cutout_bottom_z,
       "upper corner radius must fit above the cutout bottom");
assert(foot_edge_h > 0 && foot_edge_h <= floor_h,
       "outside edge thickness must fit within the base plate");
assert(rim_round_r > 0 && rim_round_r < rim_wall / 2,
       "rim rounding must leave a flat strip along the wall top");
assert(foot_d <= safe_xy && wall_bottom_d < foot_d - 2 * foot_chamfer,
       "foot must fit the documented envelope and surround the tapered wall");

module liftout_cradle(coupon = false) {
    // Revolve one continuous section; avoids tiny facets at cone/cylinder unions.
    color(cradle_color) difference() {
      intersection() {
        // The containing cube forces mesh evaluation and removes axis facets.
        translate([-foot_d / 2 - mesh_margin, -foot_d / 2 - mesh_margin, -eps])
            cube([foot_d + 2 * mesh_margin, foot_d + 2 * mesh_margin, rim_z + 2 * eps]);
        rotate_extrude(convexity = 10)
        polygon(round_corners(concat(
            [[0, 0]],
            coupon ? [[wall_bottom_d / 2, 0]] :
                [[foot_d / 2, 0],
                 [foot_d / 2, foot_edge_h],
                 [foot_d / 2 - foot_chamfer, floor_h]],
            [[wall_bottom_d / 2, floor_h],
             [wall_top_d / 2, rim_z],
             [mouth_d * bore_factor / 2, rim_z],
             [seat_d * bore_factor / 2, rim_z - entry_chamfer],
             [seat_d * bore_factor / 2, seat_floor_z],
             [0, seat_floor_z]]), radius = concat(
                 coupon ? [0, 0] : [0, 0, 0, 0],
                 [0, rim_round_r, rim_round_r, rim_round_r, 0, 0])));
      }
      // Begin inside the empty seat and overshoot the outside and top faces.
      translate([0, -cutout_w / 2, cutout_bottom_z])
          cube([foot_d / 2 + eps, cutout_w, rim_z - cutout_bottom_z + eps]);
      // Local quarter-circle cutters round only the two top shoulder points.
      // The straight opening remains cutout_w below these small rounds.
      for (side = [-1, 1]) scale([1, side, 1])
          rotate([90, 0, 90])
          linear_extrude(height = foot_d / 2 + eps, convexity = 10)
          polygon(concat(
              [[cutout_w / 2 - eps, rim_z - cutout_top_r]],
              [for (i = [0:corner_segments])
                  i == 0 ? [cutout_w / 2, rim_z - cutout_top_r] :
                  i == corner_segments ? [cutout_w / 2 + cutout_top_r, rim_z] :
                  [cutout_w / 2 + cutout_top_r +
                      cutout_top_r * cos(180 - 90 * i / corner_segments),
                   rim_z - cutout_top_r +
                      cutout_top_r * sin(180 - 90 * i / corner_segments)]],
              [[cutout_w / 2 + cutout_top_r, rim_z + eps],
               [cutout_w / 2 - eps, rim_z + eps]]));
    }
}

module glass_envelope() {
    // Outer solid envelope from measured diameters; no unmeasured bowl shape.
    union() {
        cylinder(d = glass_base_d * bore_factor, h = glass_edge_h);
        translate([0, 0, glass_edge_h - eps])
            cylinder(d1 = glass_base_d * bore_factor, d2 = glass_neck_d * bore_factor,
                     h = glass_neck_z - glass_edge_h + eps);
        translate([0, 0, glass_neck_z - eps])
            cylinder(d = glass_neck_d * bore_factor,
                     h = glass_total_h - glass_neck_z + eps);
    }
}

module ring_fit_coupon() {
    assert(ring_coupon_h > 0 && floor_h + ring_coupon_h < cutout_bottom_z,
           "ring coupon must fit below the side cutout");
    // Slice the actual wall starting at the top of the plate; keep its taper
    // and compensated bore, omit the seat floor, and move the slice to the bed.
    color(cradle_color) translate([0, 0, -floor_h]) intersection() {
        liftout_cradle(coupon = true);
        translate([-foot_d / 2, -foot_d / 2, floor_h])
            cube([foot_d, foot_d, ring_coupon_h]);
    }
}

module cradle_assembly() {
    liftout_cradle();
    %color(liner_color) translate([0, 0, seat_floor_z])
        cylinder(d = glass_base_d, h = liner_h);
    %color(glass_color) translate([0, 0, glass_bottom_z]) glass_envelope();
}

if (show == "cradle") liftout_cradle();
else if (show == "coupon") liftout_cradle(coupon = true);
else if (show == "ring-coupon") ring_fit_coupon();
else if (show == "assembly") cradle_assembly();
else if (show == "glass-fit") intersection() {
    liftout_cradle();
    translate([0, 0, glass_bottom_z]) glass_envelope();
}
else if (show == "glass-insertion") intersection() {
    liftout_cradle();
    // Conservative envelope of the entire continuous straight insertion route.
    // It includes all moving glass poses from above the rim to the seated pose.
    translate([0, 0, glass_bottom_z])
        cylinder(d = glass_base_d * bore_factor, h = glass_total_h + rim_z);
}
else assert(false, str("unknown show: ", show));
