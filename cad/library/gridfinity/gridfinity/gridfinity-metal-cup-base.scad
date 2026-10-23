// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-magnets.scad>

/* [Cup] */
cup_base_d = 36;        // Note 3.
cup_rim_d = 40;         // Note 4.
cup_h = 56;            // Note 5.
diameter_clearance = 0.5; // Note 6.

/* [Holder] */
units_z = 3;           // Note 7.
floor_thickness = 2;   // Note 8.
entry_chamfer = 0.5;   // Note 9.

/* [Magnets] */
magnet_hole_d = 10.5;   // Note 10.
magnet_cav_h = 2.2;     // Note 11.
magnet_skin = 0.4;     // Note 12.

/* [Output] */
show = "holder";       // [holder, assembly]

$fn = 64;
eps = 0.01;

/* [Derived] */
pad_top = 5;           // Note 13.
holder_h = gridfinity_zpitch * units_z;
floor_z = pad_top + floor_thickness;
seat_depth = holder_h - floor_z;
cup_taper = (cup_rim_d - cup_base_d) / cup_h; // Note 14.
facet_factor = 1 / cos(180 / $fn); // Note 15.

function cup_d(z) = cup_base_d + cup_taper * z;
function pocket_d(z) = cup_d(z) + diameter_clearance;

module metal_cup_base() {
  assert(cup_h > 0 && cup_rim_d >= cup_base_d, "cup must widen toward its rim");
  assert(diameter_clearance > 0, "allow clearance for removing the metal cup");
  assert(seat_depth > entry_chamfer && seat_depth < cup_h, "invalid pocket depth");
  assert((pocket_d(seat_depth) + 2 * entry_chamfer) * facet_factor <
         gridfinity_pitch - gridfinity_clearance, "pocket breaks through the side wall");
  assert(magnet_hole_d <= 0 || magnet_skin + magnet_cav_h < floor_z,
         "magnet cavities break through the cup floor");

  difference() {
    // Note 16.

    intersection() {
      grid_block(1, 1, units_z + 1, magnet_diameter = 0, screw_depth = 0, center = true);
      translate([-gridfinity_pitch / 2, -gridfinity_pitch / 2, -eps])
      cube([gridfinity_pitch, gridfinity_pitch, holder_h + eps]);
    }

    translate([0, 0, floor_z])
    cylinder(d1 = pocket_d(0) * facet_factor,
             d2 = pocket_d(seat_depth + eps) * facet_factor,
             h = seat_depth + eps);

    // Note 17.
    translate([0, 0, holder_h - entry_chamfer])
    cylinder(d1 = pocket_d(seat_depth - entry_chamfer) * facet_factor,
             d2 = (pocket_d(seat_depth) + 2 * entry_chamfer +
                   (2 + cup_taper) * eps) * facet_factor,
             h = entry_chamfer + eps);

    if (magnet_hole_d > 0)
      magnet_cavities(1, 1, magnet_hole_d, magnet_cav_h, magnet_skin, center = true);
  }
}

// Note 18.
module cup_envelope() {
  cylinder(d1 = cup_base_d * facet_factor,
           d2 = cup_rim_d * facet_factor, h = cup_h);
}

// Note 19.

module feral_default_output_a8ff7fe6f10e() {
metal_cup_base();
if (show == "assembly")
  %translate([0, 0, floor_z]) cup_envelope();
}

module feral_assembly_view_a8ff7fe6f10e(explode=false) {
feral_default_output_a8ff7fe6f10e();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_a8ff7fe6f10e();
else feral_assembly_view_a8ff7fe6f10e(view == "exploded");

// Notes

// Note 1. gridfinity-metal-cup-base.scad — a short tapered nest for a metal cup.
// Cup measurements are treated as outside diameters: 36 mm at its bottom,
// 40 mm at its rim, 56 mm tall. The cup rests on the floor; its bottom 14 mm
// is surrounded by the matching taper, with clearance for lifting it out.
// This is an open holder, not a snap fit. The stacking lip is omitted so
// the top remains a short, unobstructed collar around the cup.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, outside diameter at the bottom

// Note 4. mm, outside diameter at the top

// Note 5. mm, total cup height

// Note 6. mm added to the pocket diameter, 0.25 mm per side

// Note 7. 7 mm units; holder ends at 21 mm, without a stacking lip

// Note 8. mm above the 5 mm Gridfinity foot

// Note 9. mm height and radial widening of the mouth

// Note 10. mm, four enclosed cavities for 10 mm discs

// Note 11. mm, accommodates 2 mm thick magnets

// Note 12. mm below the cavities; insert at the usual print pause

// Note 13. mm, existing Gridfinity foot height

// Note 14. diameter growth per mm of height

// Note 15. retain specified bore diameter across flats

// Note 16. Start one unit taller so trimming removes the entire stacking recess,
// including its 0.1 mm overlap below the nominal deck.

// Note 17. A short lead-in at the mouth, above the unchanged matching taper.

// Note 18. Conservative outer envelope for fit and insertion checks, not a cup wall model.

// Note 19. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
