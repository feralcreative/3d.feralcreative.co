// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/rounding.scad>

/* [Glass measurements] */
glass_base_d = 95;           // Note 3.
glass_edge_h = 13;           // Note 4.
glass_neck_d = 43;           // Note 5.
glass_neck_z = 14;           // Note 6.
glass_connection_z = 16;     // Note 7.
glass_total_h = 419.1;       // Note 8.
glass_filled_mass = 1020.6;  // Note 9.

/* [Seat and clearance] */
seat_diameter_clearance = 0.6; // Note 10.
floor_h = 4.2;              // Note 11.
liner_h = 1;               // Note 12.
entry_chamfer = 0.6;        // Note 13.
rim_wall = 4.2;             // Note 14.
wall_base_extra = 7;        // Note 15.

/* [Wall and side cutout] */
wall_h = 36;               // Note 16.
cutout_w = 25;             // Note 17.
cutout_bottom_z = 17;      // Note 18.
cutout_top_r = 3;          // Note 19.
rim_round_r = 1;           // Note 20.

/* [Foot] */
foot_d = 195;               // Note 21.
foot_edge_h = 3;            // Note 22.
safe_xy = 205;              // Note 23.

/* [Ring fit coupon] */
ring_coupon_h = 3;          // Note 24.

/* [Colors] */
cradle_color = "SlateGray";
liner_color = "DimGray";
glass_color = [0.6, 0.85, 1, 0.3];

/* [Output] */
show = "cradle"; // [cradle, coupon, ring-coupon, assembly, glass-fit, glass-insertion]

/* [Hidden] */
$fn = 128;
eps = 0.01;
mesh_margin = 1;           // Note 25.
seat_d = glass_base_d + seat_diameter_clearance;
bore_factor = 1 / cos(180 / $fn); // Note 26.
seat_floor_z = floor_h - liner_h;
glass_bottom_z = floor_h;
rim_z = glass_bottom_z + wall_h;
mouth_d = seat_d + 2 * entry_chamfer;
wall_top_d = mouth_d * bore_factor + 2 * rim_wall;
wall_bottom_d = wall_top_d + 2 * wall_base_extra;
foot_chamfer = floor_h - foot_edge_h; // Note 27.
corner_segments = $fn / 4; // Note 28.

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
    // Note 29.
    color(cradle_color) difference() {
      intersection() {
        // Note 30.
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
      // Note 31.
      translate([0, -cutout_w / 2, cutout_bottom_z])
          cube([foot_d / 2 + eps, cutout_w, rim_z - cutout_bottom_z + eps]);
      // Note 32.

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
    // Note 33.
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
    // Note 34.

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

// Note 35.

module feral_default_output_66e6506d7bf1() {
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
    // Note 36.

    translate([0, 0, glass_bottom_z])
        cylinder(d = glass_base_d * bore_factor, h = glass_total_h + rim_z);
}
else assert(false, str("unknown show: ", show));
}

module feral_assembly_view_66e6506d7bf1(explode=false) {
feral_default_output_66e6506d7bf1();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_66e6506d7bf1();
else feral_assembly_view_66e6506d7bf1(view == "exploded");

// Notes

// Note 1. Open cradle for the measured 95 mm glass base; lift straight out.
// Separate alternative to bong-stabilizer.scad: that attached design is retained.
// Print flat underside on the bed. Use the fit coupon before the wide foot.
// A 1 mm soft seat liner brings the glass to its nominal seating height.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, outside diameter of the glass foot

// Note 4. mm, cylindrical outside edge height

// Note 5. mm, chamber outside diameter

// Note 6. mm, flare meets the chamber above the glass bottom

// Note 7. mm, lowest bowl/downstem point above glass bottom

// Note 8. mm, measured 16.5 inch overall height

// Note 9. g, approximately 36 ounces filled; reference only

// Note 10. mm, nominal 0.3 mm radial lift-out clearance

// Note 11. mm, glass seating height with the specified liner

// Note 12. mm, removable soft seat liner

// Note 13. mm, 45-degree opening lead-in

// Note 14. mm, radial wall at the top of the cradle

// Note 15. mm, radial outward taper at the wall's foot

// Note 16. mm above the nominal glass seating plane

// Note 17. mm, straight opening on the +X side

// Note 18. mm above the printed underside, not the glass seat

// Note 19. mm, rounding of the two upper cutout corners

// Note 20. mm, rounding along the inner and outer top edges

// Note 21. mm, broad circular footprint

// Note 22. mm, thickness at the very outside vertical edge

// Note 23. mm, documented safe printer XY envelope

// Note 24. mm, bottom wall section without the seat floor or foot

// Note 25. mm, containing solid used to evaluate the mesh

// Note 26. opening diameter measured across polygon flats

// Note 27. mm, 45-degree bevel above the edge

// Note 28. quarter-circle resolution matches the rim facets

// Note 29. Revolve one continuous section; avoids tiny facets at cone/cylinder unions.

// Note 30. The containing cube forces mesh evaluation and removes axis facets.

// Note 31. Begin inside the empty seat and overshoot the outside and top faces.

// Note 32. Local quarter-circle cutters round only the two top shoulder points.
// The straight opening remains cutout_w below these small rounds.

// Note 33. Outer solid envelope from measured diameters; no unmeasured bowl shape.

// Note 34. Slice the actual wall starting at the top of the plate; keep its taper
// and compensated bore, omit the seat floor, and move the slice to the bed.

// Note 35. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.

// Note 36. Conservative envelope of the entire continuous straight insertion route.
// It includes all moving glass poses from above the rim to the seated pose.
