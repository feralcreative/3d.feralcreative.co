// Note 1.

/* [Fit] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

side_clearance = 2;      // Note 3.
outer_extension = 7;     // Note 4.
inner_extension = 10;    // Note 5.
outer_wall = 3;          // Note 6.
bottom_round = 0.5;      // Note 7.
outer_bottom_round = 1;  // Note 8.
outer_vertical_round = 1; // Note 9.
top_round = 1;           // Note 10.
inner_vertical_round = 0.5; // Note 11.
rim_slot_height = 4;     // Note 12.
slot_fraction = 0.5;     // Note 13.
skirt_gap = 4;          // Note 14.
inner_lean = 2.5;       // Note 15.
skirt_trim = 10;         // Note 16.
seat_diameter = 17;      // Note 17.
seat_taper = 2;          // Note 18.
seat_entry_round = 0.5;  // Note 19.
cap_wedge_angle = 100;   // Note 20.

/* [Measured source geometry] */
source_outer_radius = 22; // Note 21.
wall = 2;                // Note 22.
arc_origin = 2;          // Note 23.
source_height = 27;      // Note 24.
source_slot_center = 21; // Note 25.
cap_thickness = 3;       // Note 26.
cap_corner_radius = 9;   // Note 27.
seat_anchor_diameter = 15; // Note 28.
source_seat_diameter = 13; // Note 29.
seat_depth = 2;          // Note 30.
seat_offset = 9;         // Note 31.

/* [Display] */
orient = "source";       // [source, cap_down]
$fn = 200;

/* [Hidden] */
eps = 0.01;
top_round_steps = 24;    // Note 32.
height = source_height - skirt_trim;
outer_skirt_height = height - cap_thickness + outer_extension;
inner_skirt_height = height - cap_thickness + inner_extension;
lowest_z = -max(outer_extension, inner_extension);
slot_center = source_slot_center - skirt_trim;
slot_top = slot_center + rim_slot_height / 2;
// Note 33.
seat_shift = (seat_anchor_diameter - source_seat_diameter) / (2 * sqrt(2));
seat_bottom_diameter = seat_diameter - seat_taper;
seat_center = seat_offset + seat_shift;
outer_inside_radius = source_outer_radius + side_clearance - wall;
outer_radius = outer_inside_radius + outer_wall;
inner_skirt_radius = outer_inside_radius - skirt_gap;
extent = arc_origin + outer_radius;
pose_offset = (arc_origin + source_outer_radius + side_clearance) / 2;
slot_span = 90 * slot_fraction;
slot_start = (90 - slot_span) / 2;
cap_flare = (cap_wedge_angle - 90) / 2;
cap_corner_center = cap_corner_radius / (cos(cap_flare) + sin(cap_flare));
cap_tangent_reach = cap_corner_center * (cos(cap_flare) - sin(cap_flare));
assert(inner_vertical_round > 0 && 2 * inner_vertical_round < wall);
assert(seat_taper > 0 && seat_bottom_diameter > 0);
assert(seat_entry_round > 0 && seat_entry_round < min(seat_taper / 2, seat_depth));
assert(outer_extension >= 0 && inner_extension >= 0);
assert(cap_wedge_angle >= 90 && cap_wedge_angle < 150);
assert(bottom_round > 0 && 2 * bottom_round < wall);
assert(outer_bottom_round > 0 && 2 * outer_bottom_round < outer_wall);
assert(outer_vertical_round > 0 && 2 * outer_vertical_round < outer_wall);
assert(top_round > 0 && top_round < min(cap_thickness, seat_depth));
assert(side_clearance >= 0, "This fit adjustment only supports widening.");
assert(skirt_trim >= 0 && slot_top > 0);
assert(skirt_gap > 0 && inner_skirt_radius > wall);
assert(inner_lean >= 0 && inner_lean < 90);
assert(inner_skirt_radius - wall - inner_skirt_height * tan(inner_lean) > 0);
assert(rim_slot_height > 0 && slot_top < height - cap_thickness);
assert(seat_depth < cap_thickness);
assert(slot_fraction > 0 && slot_fraction <= 1);

module outer_profile(radius = outer_radius) {
    intersection() {
        translate([arc_origin, arc_origin]) circle(r = radius);
        square([extent, extent]);
    }
}

module bottom_rounded_section(radius = bottom_round) {
    union() {
        offset(r = radius)
            offset(delta = -radius) children();
        // Note 34.
        intersection() {
            children();
            translate([0, 2 * radius]) square([2 * extent, height - lowest_z]);
        }
    }
}

module outer_skirt() {
    translate([0, 0, -outer_extension])
    intersection() {
        translate([arc_origin, arc_origin, 0])
            rotate_extrude(convexity = 10)
                bottom_rounded_section(outer_bottom_round)
                    translate([outer_inside_radius, 0])
                        square([outer_wall, outer_skirt_height + eps]);
        cube([extent, extent, outer_skirt_height + 2 * eps]);
    }
}

// Note 35.
module bottom_end_cut(length, radius = bottom_round) {
    difference() {
        translate([-eps, -eps, -eps])
            cube([length + 2 * eps, radius + eps, radius + eps]);
        translate([-2 * eps, radius, radius])
            rotate([0, 90, 0]) cylinder(r = radius, h = length + 4 * eps);
    }
}

module bottom_end_cuts() {
    // Note 36.
    translate([0, 0, -inner_extension])
        intersection() {
            union() {
                bottom_end_cut(extent);
                mirror([1, -1, 0]) bottom_end_cut(extent);
            }
            translate([arc_origin, arc_origin, -eps])
                cylinder(r = inner_skirt_radius + eps, h = bottom_round + 2 * eps);
        }
    translate([0, 0, -outer_extension]) {
        intersection() {
            union() {
                bottom_end_cut(extent, outer_bottom_round);
                mirror([1, -1, 0]) bottom_end_cut(extent, outer_bottom_round);
            }
            translate([arc_origin, arc_origin, -eps])
                linear_extrude(height = outer_bottom_round + 2 * eps)
                    difference() {
                        circle(r = outer_radius + eps);
                        circle(r = outer_inside_radius - eps);
                    }
        }
        // Note 37.
        translate([arc_origin, arc_origin, 0]) {
            rotate([0, 0, slot_start])
                translate([outer_inside_radius - eps, 0, 0])
                    mirror([0, 1, 0]) bottom_end_cut(outer_wall + 2 * eps, outer_bottom_round);
            rotate([0, 0, slot_start + slot_span])
                translate([outer_inside_radius - eps, 0, 0])
                    bottom_end_cut(outer_wall + 2 * eps, outer_bottom_round);
        }
    }
}

module cap_profile() {
    // Note 38.

    intersection() {
        translate([arc_origin, arc_origin]) circle(r = outer_radius);
        polygon([
            [0, 0],
            [3 * extent * cos(-cap_flare), 3 * extent * sin(-cap_flare)],
            [3 * extent * cos(90 + cap_flare), 3 * extent * sin(90 + cap_flare)]
        ]);
        union() {
            translate([cap_corner_center, cap_corner_center])
                circle(r = cap_corner_radius);
            for (angle = [-cap_flare, 90 + cap_flare])
                rotate(angle)
                    translate([cap_tangent_reach, -2 * extent])
                        square([4 * extent, 4 * extent]);
        }
    }
}

module vertical_corner_cut_profile(center_y) {
    // Note 39.
    radius = outer_vertical_round;
    center_x = sqrt(pow(outer_radius - radius, 2) - pow(radius - center_y, 2));
    tangent_y = center_y + (radius - center_y) * outer_radius / (outer_radius - radius);
    difference() {
        translate([center_x, -eps])
            square([outer_radius - center_x + eps, tangent_y + eps]);
        translate([center_x, radius]) circle(r = radius);
    }
}

module vertical_corner_cut(center_y, cut_height) {
    translate([0, 0, -outer_extension - eps])
        linear_extrude(height = cut_height + outer_extension + eps, convexity = 10)
            vertical_corner_cut_profile(center_y);
}

module cap_rounded_corner_profile() {
    // Note 40.
    offset(r = outer_vertical_round)
        offset(delta = -outer_vertical_round) cap_profile();
}

module outer_vertical_round_cuts() {
    // Note 41.
    translate([arc_origin, 0, 0])
        vertical_corner_cut(arc_origin, height - cap_thickness);
    mirror([1, -1, 0])
        translate([arc_origin, 0, 0])
            vertical_corner_cut(arc_origin, height - cap_thickness);
    // Note 42.
    translate([arc_origin, arc_origin, 0]) {
        rotate([0, 0, slot_start])
            mirror([0, 1, 0]) vertical_corner_cut(0, slot_top);
        rotate([0, 0, slot_start + slot_span])
            vertical_corner_cut(0, slot_top);
    }
}

module rounded_cap() {
    translate([0, 0, height - cap_thickness])
        linear_extrude(height = cap_thickness - top_round, convexity = 10)
            cap_rounded_corner_profile();
    // Note 43.

    for (i = [0 : top_round_steps - 1])
        hull()
            for (j = [i, i + 1]) {
                angle = 90 * j / top_round_steps;
                inset = top_round * (1 - cos(angle));
                z = height - top_round + top_round * sin(angle);
                translate([0, 0, z - eps])
                    linear_extrude(height = eps, convexity = 10)
                        offset(delta = -inset) cap_rounded_corner_profile();
            }
}

module tapered_seat_cut() {
    top_radius = seat_diameter / 2;
    bottom_radius = seat_bottom_diameter / 2;
    radius = seat_entry_round;
    dr = top_radius - bottom_radius;
    dz = seat_depth - radius;
    // Note 44.

    tangent_angle = acos(radius / sqrt(dr * dr + dz * dz)) - atan2(dz, dr);
    translate([seat_center, seat_center, 0])
        rotate_extrude(convexity = 10)
            polygon(concat(
                [[0, height - seat_depth], [bottom_radius, height - seat_depth]],
                [for (i = [0 : top_round_steps])
                    let(a = tangent_angle + (90 - tangent_angle) * i / top_round_steps)
                    [top_radius - radius * cos(a), height - radius + radius * sin(a)]],
                [[top_radius, height + eps], [0, height + eps]]
            ));
}

function inner_corner_center_x(z) =
    let(r = inner_skirt_radius - wall + (z - height + cap_thickness) * tan(inner_lean))
    arc_origin + sqrt(pow(r + inner_vertical_round, 2)
                      - pow(inner_vertical_round - arc_origin, 2)) + eps;

module inner_vertical_corner_cut() {
    // Note 45.

    z0 = -inner_extension - eps;
    z1 = height - cap_thickness;
    x0 = inner_corner_center_x(z0);
    x1 = inner_corner_center_x(z1);
    slope = (x1 - x0) / (z1 - z0);
    radius = inner_vertical_round;
    multmatrix([[1, 0, slope, x0], [0, 1, 0, 0],
                [0, 0, 1, z0], [0, 0, 0, 1]])
        linear_extrude(height = z1 - z0, convexity = 10)
            difference() {
                translate([-extent, -eps])
                    square([extent, 1.25 * radius + eps]);
                translate([0, radius]) circle(r = radius);
            }
}

module flange_slot() {
    translate([arc_origin, arc_origin, 0])
        rotate([0, 0, slot_start])
            rotate_extrude(angle = slot_span, convexity = 10)
                // Note 46.
                translate([outer_inside_radius - eps, -outer_extension - eps])
                    square([outer_wall + 2 * eps, slot_top + outer_extension + eps]);
}

module inner_skirt() {
    skirt_height = inner_skirt_height;
    pivot_radius = inner_skirt_radius - wall;
    lean_slope = tan(inner_lean);
    radial_thickness = wall / cos(inner_lean);
    bottom_radius = pivot_radius - skirt_height * lean_slope;
    joined_radius = pivot_radius + eps * lean_slope;
    // Note 47.

    translate([0, 0, -inner_extension])
    intersection() {
        translate([arc_origin, arc_origin, 0])
            rotate_extrude(convexity = 10)
                bottom_rounded_section()
                polygon([
                    [bottom_radius, 0],
                    [bottom_radius + radial_thickness, 0],
                    [joined_radius + radial_thickness, skirt_height + eps],
                    [joined_radius, skirt_height + eps]
                ]);
        cube([extent, extent, skirt_height + 2 * eps]);
    }
}

module bin_stacking_clip() {
    difference() {
        union() {
            // Note 48.

            outer_skirt();
            inner_skirt();
            rounded_cap();
        }
        flange_slot();
        bottom_end_cuts();
        outer_vertical_round_cuts();
        tapered_seat_cut();
        inner_vertical_corner_cut();
        mirror([1, -1, 0]) inner_vertical_corner_cut();
    }
}

module posed_clip() {
    if (orient == "cap_down")
        translate([-pose_offset, pose_offset, height])
            rotate([180, 0, 0]) bin_stacking_clip();
    else
        translate([-pose_offset, -pose_offset, -lowest_z]) bin_stacking_clip();
}

// Note 49.

module feral_default_output_ac1d13a78fcd() {
posed_clip();
}

module feral_assembly_view_ac1d13a78fcd(explode=false) {
feral_default_output_ac1d13a78fcd();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_ac1d13a78fcd();
else feral_assembly_view_ac1d13a78fcd(view == "exploded");

// Notes

// Note 1. Tray-corner stacking clip, reconstructed from the supplied STL.
// Two concentric skirts straddle the tray wall; the inside skirt leans inward.
// The cap joins both skirts; the outside skirt has a bottom-open tab gap.
// Nominal source dimensions were measured from the mesh, not the tray.
// Tray insertion, retention and load stability remain physical fit trials.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. outward shift of the original skirt profile (mm)

// Note 4. extend outside pillars downward from their previous bottoms (mm)

// Note 5. extend inside skirt downward from its previous bottom (mm)

// Note 6. outer pillar thickness, added toward the outside (mm)

// Note 7. inner skirt bottom-edge radius (mm)

// Note 8. outer pillar bottom-edge radius (mm)

// Note 9. exposed outer vertical corners of the back tabs (mm)

// Note 10. cap perimeter radius (mm)

// Note 11. inward-facing inner wall end corners only (mm)

// Note 12. reference slit height locating the top of the bottom-open gap (mm)

// Note 13. fraction of the original quarter-circle slot span

// Note 14. clear radial distance between the two skirts (mm)

// Note 15. inward lean about the inner skirt's top inside edge (degrees)

// Note 16. remove this much from the original skirt's bottom (mm)

// Note 17. actual top opening, including the previous rounded entry (mm)

// Note 18. diameter reduction from top to recess floor (mm)

// Note 19. blend the tapered wall into the top surface (mm)

// Note 20. top platform angle; skirts retain their existing fit (degrees)

// Note 21. outside radius of the curved wall (mm)

// Note 22. inner wall thickness and original outer wall thickness (mm)

// Note 23. arc centre from both open-end cut planes (mm)

// Note 24. original overall height before trimming the skirt (mm)

// Note 25. centre of the previous 3 mm slot before skirt trimming (mm)

// Note 26. solid cap thickness before the stacking recess (mm)

// Note 27. rounding at the inner corner of the cap (mm)

// Note 28. diameter used when the existing recess centre was positioned (mm)

// Note 29. original upper tray foot recess diameter (mm)

// Note 30. foot recess depth (mm)

// Note 31. original recess centre from each open-end cut plane (mm)

// Note 32. segments along the quarter-circle top round-over

// Note 33. Preserve the centre established before rounding and tapering the entry.

// Note 34. Restore the top corners so the cap joint stays unchanged.

// Note 35. Bottom round-over at an open end, with material on the +Y side.

// Note 36. Each skirt's end rounds follow its own new bottom elevation.

// Note 37. The exposed ends beside the outer pillars' central gap.

// Note 38. Open the two top-platform sides symmetrically about the diagonal.
// Retain the outer arc and the corner's true circular fillet.

// Note 39. Circle tangent to the end plane and to the outer curved face.

// Note 40. Round the widened cap's new end corners before its top sweep.

// Note 41. Keep the original skirt ends; the wider cap has its own end rounds.

// Note 42. The two exposed outside corners beside the central gap.

// Note 43. The cap profile is convex: hull each pair of inset sections to
// follow a quarter-circle without changing the lower perimeter.

// Note 44. Tangent from the fixed floor edge to the circular entry blend.
// Both specified diameters include the round-over, rather than
// adding the rounding outside the requested top opening.

// Note 45. Sweep a circular corner cut along the inclined inside edge. Extend
// its tail slightly past tangency so it remains an open cut across
// the wall's polygonal facets. It never reaches the bin-contact face.

// Note 46. Carry the existing slit down through the skirt's bottom.

// Note 47. Tilt the radial section about its top inside edge. Keep 2 mm normal
// thickness and trim the ends level with the bottom and cap overlap.

// Note 48. End both skirts inside the cap to give each a solid joint.
// The skirts stay separate below the cap.

// Note 49. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
