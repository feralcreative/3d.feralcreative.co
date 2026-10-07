// Centre-pull dispenser for a 9 inch tall x 7 inch diameter Kirkland roll.
// Two halves screw together at the middle; every feature stays outside the
// full-height roll envelope. The upper half includes the dispensing lid.
// The outside is one straight cylinder; the thread thickening is all inside.
// Its underside is a shallow cone rising towards a rounded centre opening.
// The outside lid face is flat: print the upper half upside down on that face,
// and the bottom upright on its floor. Both orientations need no supports.
// The custom, single-start thread has 45-degree flanks and generous clearance.
// Print the full-diameter thread coupons before committing to the tall pieces.

include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/threading.scad>

/* [Show] */
show = "exploded"; // [assembled, exploded, section, bottom, top, coupon-bottom, coupon-top, joint-fit, joint-wrong-phase, roll-fit, roll-loading, cap-over-roll-fit, thread-guard-fit, thread-path]

/* [Roll clearance] */
roll_d = 177.8;        // mm, measured roll diameter: 7 inches
roll_h = 228.6;        // mm, measured roll height: 9 inches
clear_d = 180;         // mm, minimum across-flats bore, including the thread neck
clear_h = 230;         // mm, floor to lowest point of the guide underside

/* [Body] */
wall_t = 2.94;         // mm, body and thread-root wall thickness
floor_t = 3.6;         // mm, closed floor, infill supplied by the slicer
lid_t = 4.2;           // mm, minimum thickness beside the centre opening
edge_chamfer = 0.6;    // mm, bottom outer bed edge
top_rim_round = 2;     // mm, radius around the outside top edge
bed_size = 220;        // mm, maximum printable width, depth, and height

/* [Dispensing guide] */
hole_d = 38;           // mm, nominal centre opening
guide_h = 12;          // mm, shallow rise from outer guide edge to hole
hole_round = 1.5;      // mm, radius on both edges of the dispensing hole
round_segments = 18;   // segments per opening-edge arc

/* [Screw joint] */
thread_pitch = 6;      // mm, axial travel per turn, single start/right handed
thread_h = 18;         // mm, three turns of engagement
thread_depth = 1.2;    // mm, radial height, 45-degree flanks
thread_crest = 1.2;    // mm, flat crest width in an axial section
thread_radial_clearance = 0.3; // mm per radial face
thread_axial_clearance = 0.2;  // mm per flank, additional groove width
thread_tip_clearance = 0.8;    // mm, space above the male thread tip
thread_lead_angle = 60;       // degrees, tapered blunt starts on the male
mouth_chamfer = 0.6;          // mm, female thread entry and male bore rim
coupon_grip_h = 8;            // mm, plain grip below/above the complete joint

/* [Inspection] */
explode_gap = 35;      // mm, extra lift of the upper half in exploded view
screw_lift = 0;        // mm, screw-path probe; rotation follows the pitch
wrong_phase = 180;     // degrees, deliberate thread misalignment for control

/* [Colors] */
bottom_color = "MediumPurple"; // preview only
top_color = "Orchid";          // preview only

/* [Resolution] */
body_facets = 180;     // same facets in exports and inspection variants
$fn = body_facets;
eps = 0.01;           // mm, boolean overshoot

/* [Hidden] */
inner_r = clear_d / (2 * cos(180 / body_facets));
neck_r = inner_r + wall_t;
thread_major_d = 2 * (neck_r + thread_depth);
// BOSL2 adds 2*$slop radially and circumscribes its internal thread mask.
socket_major_r = thread_major_d / (2 * cos(180 / body_facets))
                 + thread_radial_clearance;
socket_root_r = socket_major_r - thread_depth;
outer_r = socket_major_r + wall_t;
main_inner_r = outer_r - wall_t;
joint_blend_h = main_inner_r - inner_r;
seam_z = floor_t + clear_h / 2;
socket_h = thread_h + thread_tip_clearance;
guide_base_z = floor_t + clear_h - seam_z;
guide_peak_z = guide_base_z + guide_h;
top_h = guide_peak_z + lid_t;
bottom_h = seam_z + thread_h;
assembled_h = seam_z + top_h;
hole_r = hole_d / 2;
guide_slope = guide_h / (main_inner_r - hole_r);
guide_angle = atan(guide_slope);
// True tangent fillet between the sloping guide and the vertical throat.
inner_round_center = [hole_r + hole_round,
    guide_peak_z + hole_round * (sqrt(1 + guide_slope * guide_slope) - guide_slope)];
inner_round_end = 270 - guide_angle;
outer_round_center = [hole_r + hole_round, top_h - hole_round];
top_rim_center = [outer_r - top_rim_round, top_h - top_rim_round];
thread_start_clear = thread_h + thread_pitch;
probe_r = outer_r + wall_t;
coupon_bottom_z = seam_z - coupon_grip_h;
coupon_top_h = socket_h + joint_blend_h + coupon_grip_h;
path_guard = 0.1;            // mm, half-size of the enclosing motion cube
path_guard_radial = 0.18;    // mm, verified radial expansion of the full thread
path_guard_axial = 0.12;     // mm, verified axial expansion of the full thread
path_step_angle = 0.1;       // degrees, continuous screw-path guard spacing
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
assert(2 * outer_r <= bed_size && max(bottom_h, top_h) <= bed_size,
       "A print piece exceeds the 220 mm printer envelope");
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
assert(coupon_top_h < guide_base_z && seam_z > joint_blend_h + floor_t,
       "Joint/coupon geometry overlaps the floor or guide");
assert(path_motion_bound < path_guard,
       "Motion between screw-path samples exceeds the verified guard");

module slab(z0, z1, r = probe_r) {
    translate([0, 0, z0]) cylinder(r = r, h = z1 - z0);
}

module male_thread() {
    generic_threaded_rod(d = thread_major_d, l = thread_h,
        pitch = thread_pitch, profile = tooth_profile(),
        blunt_start = true, lead_in_ang = thread_lead_angle,
        bevel = false, anchor = BOTTOM);
}

// A full periodic helix contains the male's smaller, tapered blunt starts.
// The longer guard avoids end effects while retaining the same phase.
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
    // Empty proves the guard contains the actual mesh's complete motion cube.
    difference() {
        minkowski() {
            full_thread();
            cube([2 * path_guard, 2 * path_guard, 2 * path_guard], center = true);
        }
        guarded_thread();
    }
}

module thread_path() {
    // Each 2-degree mesh cell repeats under its matching axial screw advance.
    // Guarded midpoints cover that whole period, not just isolated poses.
    // Ends are handled separately by the open mouth and the 0.8 mm tip gap.
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
    // Keep the extended mask's midpoint exactly aligned with the male rod.
    // BOSL2 shifts an internal profile half a pitch; 180 degrees restores
    // the groove to the matching external thread's phase.
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
    // Full-circle lead-in so the first thread is easy to find.
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
            translate([0, 0, seam_z]) male_thread();
        }
        // Clear the entire male core without shrinking the loading bore.
        translate([0, 0, floor_t])
            cylinder(r = inner_r, h = bottom_h - floor_t + eps);
        translate([0, 0, bottom_h - mouth_chamfer])
            cylinder(r1 = inner_r, r2 = inner_r + mouth_chamfer + eps,
                     h = mouth_chamfer + eps);
    }
}

module top() {
    color(top_color) difference() {
        rotate_extrude(convexity = 10) polygon([
            [outer_r, 0],
            each edge_arc(top_rim_center, 0, 90, top_rim_round),
            each edge_arc(outer_round_center, 90, 180),
            each edge_arc(inner_round_center, 180, inner_round_end),
            [main_inner_r, guide_base_z],
            [main_inner_r, socket_h + joint_blend_h],
            [inner_r, socket_h], [inner_r, 0]
        ]);
        socket_cut();
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
    // Continuous swept roll envelope, from above the mouth to the floor.
    translate([0, 0, floor_t + eps])
        cylinder(r = roll_d / (2 * cos(180 / body_facets)),
                 h = bottom_h + 2 * roll_h);
}
else if (show == "cap-over-roll-fit") intersection() {
    top_pose(screw_lift); roll_envelope();
}
else if (show == "thread-guard-fit") thread_guard_fit();
else if (show == "thread-path") thread_path();
