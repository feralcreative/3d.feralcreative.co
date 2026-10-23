// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/threading.scad>

/* [Show] */
show = "exploded"; // [assembled, exploded, section, bottom, top, coupon-bottom, coupon-top, joint-fit, joint-wrong-phase, roll-fit, roll-loading, cap-over-roll-fit, thread-guard-fit, thread-path]

/* [Roll clearance] */
roll_d = 177.8;        // Note 3.
roll_h = 228.6;        // Note 4.
clear_d = 180;         // Note 5.
clear_h = 230;         // Note 6.

/* [Body] */
wall_t = 2.94;         // Note 7.
floor_t = 3.6;         // Note 8.
lid_t = 4.2;           // Note 9.
edge_chamfer = 0.6;    // Note 10.
top_rim_round = 2;     // Note 11.
bottom_fraction = 2/3; // Note 12.
bed_size = 220;        // Note 13.

/* [Grip ridges] */
grip_count = 48;       // Note 14.
grip_radius = 1.8;     // Note 15.
grip_height = 1.2;     // Note 16.
grip_seam_gap = 0.8;   // Note 17.
grip_facets = 24;      // Note 18.

/* [Dispensing guide] */
hole_d = 38;           // Note 19.
guide_h = 12;          // Note 20.
hole_round = 1.5;      // Note 21.
round_segments = 18;   // Note 22.

/* [Top lettering] */
label_text = "GARBAGE BAGS"; // Note 23.
label_font = "Helvetica Neue:style=Condensed Black"; // Note 24.
label_size = 16;       // Note 25.
label_radius = 28;     // Note 26.
label_start_angle = 150; // Note 27.
label_depth = 1;       // Note 28.
label_taper = 70;      // Note 29.
label_steps = 5;       // Note 30.
label_margin = 2;      // Note 31.
label_facets = 48;     // Note 32.

/* [Screw joint] */
thread_pitch = 6;      // Note 33.
thread_h = 18;         // Note 34.
thread_depth = 1.2;    // Note 35.
thread_crest = 1.2;    // Note 36.
thread_radial_clearance = 0.3; // Note 37.
thread_axial_clearance = 0.2;  // Note 38.
thread_tip_clearance = 0.8;    // Note 39.
thread_lead_angle = 60;       // Note 40.
mouth_chamfer = 0.6;          // Note 41.
coupon_grip_h = 8;            // Note 42.

/* [Inspection] */
explode_gap = 35;      // Note 43.
screw_lift = 0;        // Note 44.
wrong_phase = 180;     // Note 45.

/* [Colors] */
bottom_color = "MediumPurple"; // Note 46.
top_color = "Orchid";          // Note 47.

/* [Resolution] */
body_facets = 180;     // Note 48.
$fn = body_facets;
eps = 0.01;           // Note 49.

/* [Hidden] */
inner_r = clear_d / (2 * cos(180 / body_facets));
neck_r = inner_r + wall_t;
thread_major_d = 2 * (neck_r + thread_depth);
// Note 50.
socket_major_r = thread_major_d / (2 * cos(180 / body_facets))
                 + thread_radial_clearance;
socket_root_r = socket_major_r - thread_depth;
outer_r = socket_major_r + wall_t;
main_inner_r = outer_r - wall_t;
joint_blend_h = main_inner_r - inner_r;
assembled_h = floor_t + clear_h + guide_h + lid_t;
seam_z = assembled_h * bottom_fraction;
socket_h = thread_h + thread_tip_clearance;
guide_base_z = floor_t + clear_h - seam_z;
guide_peak_z = guide_base_z + guide_h;
top_h = guide_peak_z + lid_t;
bottom_h = seam_z + thread_h;
hole_r = hole_d / 2;
guide_slope = guide_h / (main_inner_r - hole_r);
guide_angle = atan(guide_slope);
// Note 51.
inner_round_center = [hole_r + hole_round,
    guide_peak_z + hole_round * (sqrt(1 + guide_slope * guide_slope) - guide_slope)];
inner_round_end = 270 - guide_angle;
outer_round_center = [hole_r + hole_round, top_h - hole_round];
top_rim_center = [outer_r - top_rim_round, top_h - top_rim_round];
thread_start_clear = thread_h + thread_pitch;
probe_r = outer_r + wall_t;
coupon_bottom_z = seam_z - coupon_grip_h;
coupon_top_h = socket_h + joint_blend_h + coupon_grip_h;
path_guard = 0.1;            // Note 52.
path_guard_radial = 0.18;    // Note 53.
path_guard_axial = 0.12;     // Note 54.
path_step_angle = 0.1;       // Note 55.
path_period_angle = 360 / body_facets;
path_samples = ceil(path_period_angle / path_step_angle);
path_actual_step = path_period_angle / path_samples;
path_motion_bound = 2 * (thread_major_d / 2 + path_guard)
                    * sin(path_actual_step / 4)
                    + path_actual_step * thread_pitch / 720;

function tooth_profile(extra = 0) = [
    [-0.5, -thread_depth / thread_pitch],
    [-(thread_crest / 2 + thread_depth + extra) / thread_pitch,
     -thread_depth / thread_pitch],
    [-(thread_crest / 2 + extra) / thread_pitch, 0],
    [ (thread_crest / 2 + extra) / thread_pitch, 0],
    [ (thread_crest / 2 + thread_depth + extra) / thread_pitch,
     -thread_depth / thread_pitch],
    [0.5, -thread_depth / thread_pitch]
];

function edge_arc(center, a0, a1, radius = hole_round) = [
    for (i = [0 : round_segments])
        let(a = a0 + (a1 - a0) * i / round_segments)
        center + radius * [cos(a), sin(a)]
];

assert(clear_d >= roll_d && clear_h >= roll_h,
       "Never reduce the clear cavity below the measured roll dimensions");
assert(roll_d >= 177.8 && roll_h >= 228.6,
       "The roll envelope must remain at least 7 inches diameter x 9 inches tall");
assert(2 * (outer_r + grip_height) <= bed_size && max(bottom_h, top_h) <= bed_size,
       "A print piece exceeds the 220 mm printer envelope");
assert(grip_count >= 8 && grip_count == floor(grip_count)
       && grip_radius > grip_height && grip_height > 0
       && 2 * grip_radius - grip_height < wall_t && grip_seam_gap > 0,
       "Grip ridges need wall overlap, bore clearance and a gap at the seam");
assert(min(seam_z - grip_seam_gap - edge_chamfer,
           top_h - top_rim_round - grip_seam_gap) > 2 * grip_radius,
       "Body sections are too short for the rounded grip ridges");
assert(bottom_fraction > 0 && bottom_fraction < 1,
       "The seam must divide the assembled height into two positive sections");
assert(thread_h >= 2 * thread_pitch && thread_radial_clearance > 0
       && thread_axial_clearance > 0 && thread_tip_clearance > 0,
       "The joint needs at least two turns and positive clearance");
assert(thread_crest + 2 * thread_depth + 2 * thread_axial_clearance < thread_pitch,
       "Thread flanks and clearance leave no valley");
assert(hole_d > 2 * hole_round && hole_r + hole_round < inner_r,
       "Opening too small for its rounded guide edges");
assert(top_h - hole_round > inner_round_center[1],
       "Lid too thin to separate the two opening-edge fillets");
assert(top_rim_round > 0 && top_rim_round <= lid_t
       && outer_r - top_rim_round > hole_r + hole_round,
       "Top rim radius must leave the lid and flat printing face intact");
assert(label_depth > 0 && label_depth < lid_t
       && label_taper > 0 && label_taper < 90
       && label_steps >= 1 && label_steps == floor(label_steps),
       "The label needs positive depth, a tapered cut and whole bands");
assert(label_radius > hole_r + hole_round + label_margin
       && label_radius + label_size + label_margin < outer_r - top_rim_round,
       "Keep the lettering clear of the opening and outer rim");
assert(coupon_top_h < guide_base_z && seam_z > joint_blend_h + floor_t,
       "Joint/coupon geometry overlaps the floor or guide");
assert(path_motion_bound < path_guard,
       "Motion between screw-path samples exceeds the verified guard");

module slab(z0, z1, r = probe_r) {
    translate([0, 0, z0]) cylinder(r = r, h = z1 - z0);
}

module grip_ridges(z0, z1) {
    for (i = [0 : grip_count - 1])
        rotate([0, 0, i * 360 / grip_count])
            translate([outer_r + grip_height - grip_radius, 0, 0])
                hull() {
                    translate([0, 0, z0 + grip_radius])
                        sphere(r = grip_radius, $fn = grip_facets);
                    translate([0, 0, z1 - grip_radius])
                        sphere(r = grip_radius, $fn = grip_facets);
                }
}

module label_artwork() {
    // Note 56.
    for (i = [0 : len(label_text) - 1])
        if (label_text[i] != " ")
            rotate([0, 0, label_start_angle - i * 360 / (len(label_text) + 1) - 90])
                translate([0, label_radius])
                    text(label_text[i], size = label_size, font = label_font,
                         halign = "center", valign = "baseline", $fn = label_facets);
}

module label_cut() {
    // Note 57.

    band = label_depth / label_steps;
    for (k = [0 : label_steps - 1])
        translate([0, 0, top_h - band * (k + 1)])
            linear_extrude(height = band + eps, convexity = 10)
                offset(delta = -band * k / tan(label_taper)) label_artwork();
}

module male_thread() {
    generic_threaded_rod(d = thread_major_d, l = thread_h,
        pitch = thread_pitch, profile = tooth_profile(),
        blunt_start = true, lead_in_ang = thread_lead_angle,
        bevel = false, anchor = BOTTOM);
}

// Note 58.

module full_thread() {
    generic_threaded_rod(d = thread_major_d, l = thread_h,
        pitch = thread_pitch, profile = tooth_profile(),
        blunt_start = false, bevel = false, anchor = BOTTOM);
}

module guarded_thread() {
    translate([0, 0, -thread_pitch])
        generic_threaded_rod(d = thread_major_d + 2 * path_guard_radial,
            l = thread_h + 2 * thread_pitch, pitch = thread_pitch,
            profile = tooth_profile(path_guard_axial),
            blunt_start = false, bevel = false, anchor = BOTTOM);
}

module thread_guard_fit() {
    // Note 59.
    difference() {
        minkowski() {
            full_thread();
            cube([2 * path_guard, 2 * path_guard, 2 * path_guard], center = true);
        }
        guarded_thread();
    }
}

module thread_path() {
    // Note 60.

    for (i = [0 : path_samples - 1])
        let(a = (i + 0.5) * path_actual_step) intersection() {
            translate([0, 0, -a * thread_pitch / 360]) rotate([0, 0, -a])
                guarded_thread();
            difference() {
                slab(thread_pitch, 2 * thread_pitch);
                socket_cut();
            }
        }
}

module socket_cut() {
    // Note 61.

    intersection() {
        translate([0, 0, -thread_pitch]) rotate([0, 0, 180])
            let($slop = thread_radial_clearance / 2)
                generic_threaded_rod(d = thread_major_d,
                    l = thread_h + 2 * thread_pitch, pitch = thread_pitch,
                    profile = tooth_profile(thread_axial_clearance),
                    internal = true, blunt_start = false,
                    bevel = false, anchor = BOTTOM);
        slab(-eps, socket_h + eps);
    }
    // Note 62.
    translate([0, 0, -eps])
        cylinder(r1 = socket_major_r + mouth_chamfer + eps,
                 r2 = socket_root_r, h = mouth_chamfer + thread_depth + eps);
}

module bottom() {
    color(bottom_color) difference() {
        union() {
            rotate_extrude(convexity = 10) polygon([
                [0, 0], [outer_r - edge_chamfer, 0],
                [outer_r, edge_chamfer], [outer_r, seam_z],
                [neck_r - eps, seam_z], [neck_r - eps, bottom_h],
                [inner_r, bottom_h], [inner_r, seam_z],
                [main_inner_r, seam_z - joint_blend_h],
                [main_inner_r, floor_t], [0, floor_t]
            ]);
            grip_ridges(edge_chamfer, seam_z - grip_seam_gap);
            translate([0, 0, seam_z]) male_thread();
        }
        // Note 63.
        translate([0, 0, floor_t])
            cylinder(r = inner_r, h = bottom_h - floor_t + eps);
        translate([0, 0, bottom_h - mouth_chamfer])
            cylinder(r1 = inner_r, r2 = inner_r + mouth_chamfer + eps,
                     h = mouth_chamfer + eps);
    }
}

module top() {
    color(top_color) difference() {
        union() {
            rotate_extrude(convexity = 10) polygon([
                [outer_r, 0],
                each edge_arc(top_rim_center, 0, 90, top_rim_round),
                each edge_arc(outer_round_center, 90, 180),
                each edge_arc(inner_round_center, 180, inner_round_end),
                [main_inner_r, guide_base_z],
                [main_inner_r, socket_h + joint_blend_h],
                [inner_r, socket_h], [inner_r, 0]
            ]);
            grip_ridges(grip_seam_gap, top_h - top_rim_round);
        }
        socket_cut();
        label_cut();
    }
}

module top_print() {
    translate([0, 0, top_h]) rotate([180, 0, 0]) top();
}

module top_pose(lift = 0) {
    translate([0, 0, seam_z + lift]) rotate([0, 0, 360 * lift / thread_pitch]) top();
}

module assembly(lift = 0) {
    bottom();
    top_pose(lift);
}

module roll_envelope() {
    translate([0, 0, floor_t])
        cylinder(r = roll_d / (2 * cos(180 / body_facets)), h = roll_h);
}

module coupon_bottom() {
    translate([0, 0, -coupon_bottom_z]) intersection() {
        bottom(); slab(coupon_bottom_z, bottom_h + eps);
    }
}

module coupon_top() {
    translate([0, 0, coupon_top_h]) rotate([180, 0, 0]) intersection() {
        top(); slab(-eps, coupon_top_h);
    }
}

// Note 64.
module feral_default_output_10a9d237a296() {
if (show == "assembled") assembly();
else if (show == "exploded") assembly(thread_start_clear + explode_gap);
else if (show == "section") intersection() {
    assembly();
    translate([-probe_r, -probe_r, -eps])
        cube([2 * probe_r, probe_r, assembled_h + 2 * eps]);
}
else if (show == "bottom") bottom();
else if (show == "top") top_print();
else if (show == "coupon-bottom") coupon_bottom();
else if (show == "coupon-top") coupon_top();
else if (show == "joint-fit") intersection() { bottom(); top_pose(screw_lift); }
else if (show == "joint-wrong-phase") intersection() {
    bottom(); translate([0, 0, seam_z]) rotate([0, 0, wrong_phase]) top();
}
else if (show == "roll-fit") intersection() { assembly(); roll_envelope(); }
else if (show == "roll-loading") intersection() {
    bottom();
    // Note 65.
    translate([0, 0, floor_t + eps])
        cylinder(r = roll_d / (2 * cos(180 / body_facets)),
                 h = bottom_h + 2 * roll_h);
}
else if (show == "cap-over-roll-fit") intersection() {
    top_pose(screw_lift); roll_envelope();
}
else if (show == "thread-guard-fit") thread_guard_fit();
else if (show == "thread-path") thread_path();
}

module feral_assembly_view_10a9d237a296(explode=false) {
assembly(explode ? thread_start_clear+explode_gap : 0);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_10a9d237a296();
else feral_assembly_view_10a9d237a296(view == "exploded");

// Notes

// Note 1. Centre-pull dispenser for a 9 inch tall x 7 inch diameter Kirkland roll.
// The tall bottom and short upper section screw together; features stay outside the
// full-height roll envelope. The upper half includes the dispensing lid.
// Rounded vertical grip ridges surround the straight cylinder; threads stay inside.
// Its underside is a shallow cone rising towards a rounded centre opening.
// The outside lid face is flat: print the upper half upside down on that face,
// and the bottom upright on its floor. Both orientations need no supports.
// The custom, single-start thread has 45-degree flanks and generous clearance.
// Print the full-diameter thread coupons before committing to the tall pieces.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, measured roll diameter: 7 inches

// Note 4. mm, measured roll height: 9 inches

// Note 5. mm, minimum across-flats bore, including the thread neck

// Note 6. mm, floor to lowest point of the guide underside

// Note 7. mm, body and thread-root wall thickness

// Note 8. mm, closed floor, infill supplied by the slicer

// Note 9. mm, minimum thickness beside the centre opening

// Note 10. mm, bottom outer bed edge

// Note 11. mm, radius around the outside top edge

// Note 12. fraction of assembled height below the seam, excluding threads

// Note 13. mm, maximum printable width, depth, and height

// Note 14. ridges evenly spaced around each section

// Note 15. mm, rounded ridge cross-section and end-cap radius

// Note 16. mm, radial projection beyond the cylinder wall

// Note 17. mm, each ridge's setback from the threaded seam

// Note 18. segments around each ridge and rounded end

// Note 19. mm, nominal centre opening

// Note 20. mm, shallow rise from outer guide edge to hole

// Note 21. mm, radius on both edges of the dispensing hole

// Note 22. segments per opening-edge arc

// Note 23. clockwise lettering around the dispensing opening

// Note 24. same bold face as the can-holder labels

// Note 25. mm, nominal text size

// Note 26. mm, circular baseline radius from the hole centre

// Note 27. degrees, first letter at the upper left

// Note 28. mm, deboss into the outer lid face

// Note 29. degrees from horizontal, widening toward the surface

// Note 30. bands in the settled tapered-deboss construction

// Note 31. mm, separation from hole roundover and outer rim

// Note 32. segments on curved glyph outlines

// Note 33. mm, axial travel per turn, single start/right handed

// Note 34. mm, three turns of engagement

// Note 35. mm, radial height, 45-degree flanks

// Note 36. mm, flat crest width in an axial section

// Note 37. mm per radial face

// Note 38. mm per flank, additional groove width

// Note 39. mm, space above the male thread tip

// Note 40. degrees, tapered blunt starts on the male

// Note 41. mm, female thread entry and male bore rim

// Note 42. mm, plain grip below/above the complete joint

// Note 43. mm, extra lift of the upper half in exploded view

// Note 44. mm, screw-path probe; rotation follows the pitch

// Note 45. degrees, deliberate thread misalignment for control

// Note 46. preview only

// Note 47. preview only

// Note 48. same facets in exports and inspection variants

// Note 49. mm, boolean overshoot

// Note 50. BOSL2 adds 2*$slop radially and circumscribes its internal thread mask.

// Note 51. True tangent fillet between the sloping guide and the vertical throat.

// Note 52. mm, half-size of the enclosing motion cube

// Note 53. mm, verified radial expansion of the full thread

// Note 54. mm, verified axial expansion of the full thread

// Note 55. degrees, continuous screw-path guard spacing

// Note 56. One extra blank sector separates the final S from the first G.

// Note 57. Same 70-degree/five-band treatment recorded in docs/STATUS.md.
// Full-size outlines at the mouth, progressively inset deeper in the lid.
// Offset each stroke; scaling would move letters rather than taper them.

// Note 58. A full periodic helix contains the male's smaller, tapered blunt starts.
// The longer guard avoids end effects while retaining the same phase.

// Note 59. Empty proves the guard contains the actual mesh's complete motion cube.

// Note 60. Each 2-degree mesh cell repeats under its matching axial screw advance.
// Guarded midpoints cover that whole period, not just isolated poses.
// Ends are handled separately by the open mouth and the 0.8 mm tip gap.

// Note 61. Keep the extended mask's midpoint exactly aligned with the male rod.
// BOSL2 shifts an internal profile half a pitch; 180 degrees restores
// the groove to the matching external thread's phase.

// Note 62. Full-circle lead-in so the first thread is easy to find.

// Note 63. Clear the entire male core without shrinking the loading bore.

// Note 64. Assembly display changes placement only; the original output remains the default.

// Note 65. Continuous swept roll envelope, from above the mouth to the floor.
