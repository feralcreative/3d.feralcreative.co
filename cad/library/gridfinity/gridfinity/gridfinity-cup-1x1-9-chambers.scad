// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>
use <gridfinity_cup_modules.scad>
include <../../../logos/marks.scad>

/* [Output] */
show = "cup";            // [cup, coupon]

/* [Size] */
height = 6;              // Note 3.
columns = 3;             // Note 4.
rows = 3;                // Note 5.

/* [Cup] */
floor_thickness = 0.7;   // Note 6.
wall_thickness = 0.95;   // Note 7.
divider_thickness = 1.2; // Note 8.
stacking_clearance = 0.15; // Note 9.

/* [Front and back artwork] */
art_enabled = true;
art_w = 15;             // Note 10.
art_relief = 0.32;      // Note 11.
art_word_swell = 0.08;  // Note 12.
art_corner_r = 0.10;   // Note 13.
art_edge_r = 0.06;     // Note 14.
art_round_steps = 3;   // Note 15.

/* [Cartridge seats] */
connector_d = 7;         // Note 16.
connector_h = 4.5;       // Note 17.
connector_d_clearance = 0.8; // Note 18.
connector_depth_clearance = 0.2; // Note 19.
seat_min_web = 1;        // Note 20.
coupon_wall_h = 3;       // Note 21.

/* [Magnets] */
magnet_hole_d = 10.5;    // Note 22.
magnet_cav_h = 2.2;      // Note 23.
magnet_skin = 0.4;       // Note 24.

$fn = 48;
eps = 0.01;

/* [Derived] */
body_span = gridfinity_pitch - gridfinity_clearance - 2 * wall_thickness;
seat_d = connector_d + connector_d_clearance;
seat_depth = connector_h + connector_depth_clearance;
magnet_ceiling = magnet_hole_d > 0 ? magnet_skin + magnet_cav_h : 0;
base_floor_z = 5 + floor_thickness; // Note 25.
floor_z = max(base_floor_z, magnet_ceiling + seat_min_web + seat_depth);
effective_floor_thickness = floor_z - 5;
divider_top = gridfinity_zpitch * height - stacking_clearance;
chamber_x = (body_span - (columns - 1) * divider_thickness) / columns;
chamber_y = (body_span - (rows - 1) * divider_thickness) / rows;
lip_corner_offset = 4;   // Note 26.
lip_corner_d = 2.3;      // Note 27.
lip_span = gridfinity_pitch - 2 * lip_corner_offset + lip_corner_d;
art_h = wagon_queen_height(art_w);
art_center_z = (5 + gridfinity_zpitch * height) / 2;
front_y = -(gridfinity_pitch - gridfinity_clearance) / 2;

module artwork_shape() {
  if (art_corner_r > 0)
    offset(r = -art_corner_r, $fn = 24)
    offset(r = 2 * art_corner_r, $fn = 24)
    offset(r = -art_corner_r, $fn = 24)
    wagon_queen_crest(art_w);
  else wagon_queen_crest(art_w);
  offset(r = art_word_swell, $fn = 24) wagon_queen_word(art_w);
}

// Note 28.

module rounded_art_relief() {
  relief_h = art_relief + eps;
  core_h = relief_h - art_edge_r;
  if (art_edge_r == 0)
    linear_extrude(height = relief_h, convexity = 10) artwork_shape();
  else {
    linear_extrude(height = core_h, convexity = 10) artwork_shape();
    for (i = [1:art_round_steps])
      let(a = 90 * i / art_round_steps,
          slab_top = core_h + art_edge_r * sin(a),
          inset = art_edge_r * (1 - cos(a)))
      translate([0, 0, core_h / 2])
      linear_extrude(height = slab_top - core_h / 2, convexity = 10)
      offset(r = -inset, $fn = 24) artwork_shape();
  }
}

module face_artwork() {
  assert(art_w > 0 && art_relief > 0 &&
         art_word_swell >= 0 && art_corner_r >= 0 &&
         art_edge_r >= 0 && art_edge_r <= art_relief &&
         art_round_steps >= 3 && art_round_steps == floor(art_round_steps) &&
         art_w + 2 * art_word_swell < 2 * (gridfinity_pitch / 2 - lip_corner_offset) &&
         art_center_z - art_h / 2 - art_word_swell > 5 &&
         art_center_z + art_h / 2 + art_word_swell < gridfinity_zpitch * height,
         "rounded artwork must stay on the flat wall");
  translate([0, front_y + eps, art_center_z])
  rotate([90, 0, 0])
  rounded_art_relief();
}

// Note 29.

function seat_center(i, chamber_size) =
  let(lo = -body_span / 2 + i * (chamber_size + divider_thickness),
      hi = lo + chamber_size)
  (max(lo, -lip_span / 2) + min(hi, lip_span / 2)) / 2;

module cartridge_seats() {
  for (x = [0:columns - 1]) for (y = [0:rows - 1])
    translate([seat_center(x, chamber_x), seat_center(y, chamber_y),
               floor_z - seat_depth])
    cylinder(d = seat_d, h = seat_depth + eps, $fn = 64);
}

module chamber_dividers() {
  for (i = [1:columns - 1])
    translate([-body_span / 2 + i * chamber_x + (i - 1) * divider_thickness,
               -gridfinity_pitch / 2 - eps, floor_z - eps])
    cube([divider_thickness, gridfinity_pitch + 2 * eps,
          divider_top - floor_z + eps]);

  for (i = [1:rows - 1])
    translate([-gridfinity_pitch / 2 - eps,
               -body_span / 2 + i * chamber_y + (i - 1) * divider_thickness,
               floor_z - eps])
    cube([gridfinity_pitch + 2 * eps, divider_thickness,
          divider_top - floor_z + eps]);
}

module nine_chamber_cup() {
  assert(columns >= 2 && rows >= 2 &&
         columns == floor(columns) && rows == floor(rows),
         "rows and columns must be whole numbers of at least two");
  assert(chamber_x > divider_thickness && chamber_y > divider_thickness &&
         divider_top > floor_z && stacking_clearance > 0,
         "chambers or divider height are too small");
  assert(magnet_hole_d <= 0 || magnet_skin + magnet_cav_h < floor_z,
         "magnet cavities would break into the cup interior");
  assert(connector_d > 0 && connector_h > 0 &&
         connector_d_clearance > 0 && connector_depth_clearance > 0 &&
         seat_min_web > 0 &&
         seat_d < min(chamber_x, chamber_y) - (body_span - lip_span) / 2,
         "connector seats must clear the chamber openings and retain a floor");

  difference() {
    grid_block(1, 1, height, magnet_diameter = 0, screw_depth = 0);

    // Note 30.
    difference() {
      basic_cavity(1, 1, height, fingerslide = false,
                   magnet_diameter = 0, screw_depth = 0,
                   floor_thickness = effective_floor_thickness,
                   wall_thickness = wall_thickness,
                   efficient_floor = false, lip_style = "normal");
      chamber_dividers();
    }

    cartridge_seats();

    if (magnet_hole_d > 0)
      magnet_cavities(1, 1, magnet_hole_d, magnet_cav_h, magnet_skin);
  }
}

module fit_coupon() {
  intersection() {
    nine_chamber_cup();
    translate([-gridfinity_pitch / 2, -gridfinity_pitch / 2, -eps])
    cube([gridfinity_pitch, gridfinity_pitch, floor_z + coupon_wall_h + eps]);
  }
}

module decorated_cup() {
  union() {
    nine_chamber_cup();
    if (art_enabled)
      for (side = [0, 180]) rotate([0, 0, side]) face_artwork();
  }
}

// Note 31.

module feral_default_output_e3ea3b3643f6() {
if (show == "cup") decorated_cup();
else if (show == "coupon") fit_coupon();
else assert(false, "unknown output");
}

module feral_assembly_view_e3ea3b3643f6(explode=false) {
feral_default_output_e3ea3b3643f6();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_e3ea3b3643f6();
else feral_assembly_view_e3ea3b3643f6(view == "exploded");

// Notes

// Note 1. gridfinity-cup-1x1-9-chambers.scad — a one-cell cup with a 3 x 3 grid.
// Smooth cartridge connector recesses sit above the buried magnet cavities.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. 7 mm units; 45.75 mm overall with the stacking lip

// Note 4. chambers across X

// Note 5. chambers across Y

// Note 6. mm above the base cutouts, existing cup default

// Note 7. mm, existing cup default

// Note 8. mm, existing upstream divider thickness

// Note 9. mm below the next cup's seated bottom

// Note 10. mm, width of the combined Wagon Queen lockup

// Note 11. mm raised outward; 0.12 mm extra, 42.14 mm overall depth

// Note 12. mm added around the fine script strokes

// Note 13. mm, soften corners in the crest outline

// Note 14. mm, round the exposed edges of both crest and script

// Note 15. segments around the small quarter-circle edge

// Note 16. mm, measured connector outside diameter

// Note 17. mm, measured protrusion below the cartridge body

// Note 18. mm added to diameter for a loose printed fit

// Note 19. mm below the connector tip

// Note 20. mm of solid plastic above the magnet cavities

// Note 21. mm of chamber walls retained above the coupon floor

// Note 22. mm, four enclosed cavities for 10 mm discs; 0 disables

// Note 23. mm, for 2 mm-thick discs

// Note 24. mm below the cavities

// Note 25. mm, inherited basic_cavity floor formula

// Note 26. mm, inherited basic_cavity corner-center offset

// Note 27. mm, inherited basic_cavity narrow lip diameter

// Note 28. Roll only the exposed edge, retaining a full-width attachment to the wall.
// Upper slabs overlap the core instead of touching along coplanar faces.

// Note 29. Center each seat below its clear lip opening so a cartridge can enter
// vertically; perimeter openings are narrower than the body of the chamber.

// Note 30. Remove nine parts of the proven cavity, leaving the crossing dividers.

// Note 31. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
