// Wide foot and split retaining collar for a 95 mm glass bong base.
// Print the foot upright, both collar halves flat, and four thumbscrews head-down.
// All fasteners are printed. The collar seats on the plastic shoulder, not glass.
// Fit a 1 mm soft liner in the seat and six 1 mm nonslip pads underneath.
// Test coupon-base with the production collar and one screw before the wide foot.

include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/threading.scad>

/* [Glass measurements] */
glass_base_d = 95;           // mm, maximum outside diameter
glass_edge_h = 13;           // mm, cylindrical outside edge height
glass_neck_d = 43;           // mm, chamber outside diameter
glass_neck_z = 14;           // mm, flare meets chamber above glass bottom
glass_total_h = 419.1;       // mm, 16.5 inches; reference only
glass_filled_mass = 1020.6;  // g, 36 ounces; reference only

/* [Foot and glass clearance] */
foot_d = 195;               // mm, footprint before optional nonslip pads
floor_h = 4.2;              // mm, seat height with the specified liner
foot_chamfer = 1.2;         // mm, upper outside edge bevel
seat_diameter_clearance = 1.5; // mm, 0.75 mm radial glass clearance
glass_top_clearance = 0.8;  // mm above the highest measured flare
liner_h = 1;               // mm, removable soft disk in the seat
pad_d = 18;                // mm, adhesive nonslip pad pockets
pad_circle_r = 87;          // mm, radius to pad centres
pad_count = 6;              // evenly distributed nonslip pads
pad_recess = 0.6;           // mm, leaves a 1 mm pad 0.4 mm proud

/* [Retaining collar] */
collar_outer_d = 132;       // mm, plastic support shoulder and collar diameter
collar_opening_d = 86;      // mm, overlaps the 95 mm glass rim radially
collar_h = 6.3;             // mm, each retaining half's thickness
collar_split_gap = 0.6;     // mm between the installed halves
collar_edge_chamfer = 0.6;  // mm, opening edges only
collar_plate_gap = 4;       // mm, spacing between separately printed halves

/* [Printed thumbscrews] */
screw_d = 10;               // mm, coarse printed screw major diameter
screw_pitch = 2;            // mm per turn; custom thread, not an M10 hardware fit
screw_shaft_h = 16;         // mm, below the head
screw_clearance_d = 11.2;   // mm, unthreaded collar holes
thread_diameter_clearance = 0.6; // mm, allowance for printing the internal thread
screw_xy = 40;             // mm, four screw centres at (+/-40, +/-40)
screw_head_d = 20;          // mm, hexagonal finger-grip diameter across corners
screw_head_h = 4.2;         // mm, head-down print orientation
screw_tip_chamfer = 0.8;    // mm, shaft insertion lead-in
thread_bottom_extra = 2;    // mm, one extra pitch below the seated screw tip
screw_plate_pitch = 25;    // mm, four-screw plate layout
thread_fn = 64;            // thread facets, independent of large circles

/* [Colors] */
foot_color = "SlateGray";
right_collar_color = "DarkOrange";
left_collar_color = "Goldenrod";
screw_color = "MediumSeaGreen";
glass_color = [0.6, 0.85, 1, 0.25];
liner_color = "DimGray";

/* [Output] */
show = "exploded"; // [base, collar-set, screw, screw-set, coupon-base, assembly, exploded, glass-fit, glass-insertion, collar-fit, collar-insertion, screw-fit, screw-insertion, screw-path]
insertion_side = 1;        // [1, -1]
exploded_gap = 25;         // mm, illustration spacing
collar_entry_travel = 140; // mm, clears the complete support shoulder
screw_path_steps = 48;     // verification poses along the helical insertion route

/* [Hidden] */
$fn = 128;
eps = 0.01;
seat_d = glass_base_d + seat_diameter_clearance;
seat_floor_z = floor_h - liner_h;
glass_bottom_z = floor_h;
collar_z = glass_bottom_z + glass_neck_z + glass_top_clearance;
screw_head_z = collar_z + collar_h;
screw_tip_z = screw_head_z - screw_shaft_h;
thread_bottom_z = screw_tip_z - thread_bottom_extra;
thread_cut_h = screw_shaft_h + 2 * thread_bottom_extra;
bore_factor = 1 / cos(180 / $fn);

assert(glass_neck_z > glass_edge_h && glass_base_d > glass_neck_d,
       "glass flare measurements are inconsistent");
assert(seat_floor_z > pad_recess && thread_bottom_z > floor_h,
       "floor or blind screw hole is too thin");
assert(collar_opening_d < glass_base_d && collar_opening_d > glass_neck_d,
       "collar must overlap the base and clear the chamber");
assert(sqrt(2) * screw_xy - screw_clearance_d / 2 > seat_d / 2 &&
       sqrt(2) * screw_xy + screw_head_d / 2 < collar_outer_d / 2 + foot_chamfer,
       "screws must clear glass and remain over the plastic shoulder");
assert(foot_d <= 205 && collar_outer_d < foot_d,
       "foot must fit the documented safe printer envelope");
assert(abs(thread_bottom_extra / screw_pitch - round(thread_bottom_extra / screw_pitch)) < eps,
       "extra thread depth must preserve helical phase");

module screw_positions() {
    for (x = [-screw_xy, screw_xy], y = [-screw_xy, screw_xy])
        translate([x, y, 0]) children();
}

// Trapezoidal threads with shallow 0.8 mm depth and printable 45-degree flanks.
// Internal diameter allowance is explicit; BOSL2's extra $slop is disabled.
module screw_thread(internal = false, length = screw_shaft_h) {
    // BOSL2 shifts an internal mask's profile by half a pitch; undo its phase.
    rotate([0, 0, internal ? 180 : 0])
    trapezoidal_threaded_rod(
        d = screw_d + (internal ? thread_diameter_clearance : 0),
        l = length, pitch = screw_pitch, thread_depth = screw_tip_chamfer,
        thread_angle = 90, internal = internal, blunt_start = false,
        bevel = false, anchor = BOT, $slop = 0, $fn = thread_fn);
}

module foot_blank(diameter) {
    if (diameter > collar_outer_d) {
        cylinder(d = diameter, h = floor_h - foot_chamfer);
        translate([0, 0, floor_h - foot_chamfer])
            cylinder(d1 = diameter, d2 = diameter - 2 * foot_chamfer,
                     h = foot_chamfer);
    }
    cylinder(d = collar_outer_d, h = collar_z);
}

module stabilizer_base(coupon = false) {
    color(foot_color) difference() {
        foot_blank(coupon ? collar_outer_d : foot_d);
        translate([0, 0, seat_floor_z])
            cylinder(d = seat_d * bore_factor, h = collar_z - seat_floor_z + eps);
        screw_positions() translate([0, 0, thread_bottom_z])
            screw_thread(internal = true, length = thread_cut_h);
        if (!coupon)
            for (a = [0 : 360 / pad_count : 360 - 360 / pad_count])
                rotate([0, 0, a]) translate([pad_circle_r, 0, -eps])
                    cylinder(d = pad_d * bore_factor, h = pad_recess + eps);
    }
}

module collar_blank() {
    difference() {
        cylinder(d = collar_outer_d, h = collar_h);
        translate([0, 0, -eps])
            cylinder(d = collar_opening_d * bore_factor, h = collar_h + 2 * eps);
        translate([0, 0, -eps])
            cylinder(d1 = (collar_opening_d + 2 * collar_edge_chamfer + 2 * eps) * bore_factor,
                     d2 = collar_opening_d * bore_factor, h = collar_edge_chamfer + eps);
        translate([0, 0, collar_h - collar_edge_chamfer])
            cylinder(d1 = collar_opening_d * bore_factor,
                     d2 = (collar_opening_d + 2 * collar_edge_chamfer + 2 * eps) * bore_factor,
                     h = collar_edge_chamfer + eps);
        screw_positions() translate([0, 0, -eps])
            cylinder(d = screw_clearance_d * bore_factor, h = collar_h + 2 * eps);
    }
}

module collar_half(side = 1) {
    color(side > 0 ? right_collar_color : left_collar_color)
    intersection() {
        collar_blank();
        translate([side > 0 ? collar_split_gap / 2 : -collar_outer_d,
                   -collar_outer_d, -eps])
            cube([collar_outer_d - collar_split_gap / 2,
                  2 * collar_outer_d, collar_h + 2 * eps]);
    }
}

// Modelled shaft-up; flip the complete screw so its head sits on the print bed.
module thumbscrew() {
    color(screw_color) union() {
        intersection() {
            screw_thread();
            union() {
                cylinder(d1 = screw_d - 2 * screw_tip_chamfer, d2 = screw_d,
                         h = screw_tip_chamfer);
                translate([0, 0, screw_tip_chamfer - eps])
                    cylinder(d = screw_d, h = screw_shaft_h - screw_tip_chamfer + eps);
            }
        }
        translate([0, 0, screw_shaft_h])
            cylinder(d = screw_head_d, h = screw_head_h, $fn = 6);
    }
}

module screw_print() {
    translate([0, 0, screw_shaft_h + screw_head_h])
        rotate([180, 0, 0]) thumbscrew();
}

module collar_print_set() {
    for (side = [-1, 1])
        translate([side * collar_plate_gap / 2, 0, 0]) collar_half(side);
}

module screws_print_set() {
    for (x = [-screw_plate_pitch / 2, screw_plate_pitch / 2],
         y = [-screw_plate_pitch / 2, screw_plate_pitch / 2])
        translate([x, y, 0]) screw_print();
}

module glass_envelope(height = glass_total_h) {
    // Conservative solid outer envelope; bowl and mouth hardware not measured.
    union() {
        cylinder(d = glass_base_d * bore_factor, h = glass_edge_h);
        translate([0, 0, glass_edge_h - eps])
            cylinder(d1 = glass_base_d * bore_factor, d2 = glass_neck_d * bore_factor,
                     h = glass_neck_z - glass_edge_h + eps);
        translate([0, 0, glass_neck_z - eps])
            cylinder(d = glass_neck_d * bore_factor, h = height - glass_neck_z + eps);
    }
}

module assembly(explode = false) {
    stabilizer_base();
    for (side = [-1, 1])
        translate([side * (explode ? exploded_gap : 0), 0,
                   collar_z + (explode ? exploded_gap : 0)]) collar_half(side);
    screw_positions() translate([0, 0, screw_tip_z + (explode ? 2 * exploded_gap : 0)])
        thumbscrew();
    color(liner_color) translate([0, 0, seat_floor_z])
        cylinder(d = glass_base_d, h = liner_h);
    %color(glass_color) translate([0, 0, glass_bottom_z]) glass_envelope();
}

// Exact continuous translation sweeps along the specified assembly route.
// Clear seated fit alone is insufficient: insert glass with both halves removed,
// then move the halves sideways above the flare, then turn the screws down.
module collar_sweep(side) {
    translate([0, 0, collar_z])
        linear_extrude(height = collar_h, convexity = 10)
            minkowski() {
                projection() collar_half(side);
                translate([side > 0 ? 0 : -collar_entry_travel, -eps / 2])
                    square([collar_entry_travel, eps]);
            }
}

if (show == "base") stabilizer_base();
else if (show == "coupon-base") stabilizer_base(coupon = true);
else if (show == "collar-set") collar_print_set();
else if (show == "screw") screw_print();
else if (show == "screw-set") screws_print_set();
else if (show == "assembly") assembly();
else if (show == "exploded") assembly(explode = true);
else if (show == "glass-fit") intersection() {
    union() {
        stabilizer_base();
        translate([0, 0, collar_z]) { collar_half(1); collar_half(-1); }
    }
    translate([0, 0, glass_bottom_z]) glass_envelope();
}
else if (show == "glass-insertion") intersection() {
    stabilizer_base();
    translate([0, 0, glass_bottom_z]) cylinder(d = glass_base_d * bore_factor,
        h = glass_total_h + collar_z);
}
else if (show == "collar-fit") intersection() {
    stabilizer_base();
    translate([0, 0, collar_z]) { collar_half(1); collar_half(-1); }
}
else if (show == "collar-insertion") intersection() {
    collar_sweep(insertion_side);
    union() {
        // Planar contact at the plastic shoulder is permitted; exclude it here.
        intersection() {
            stabilizer_base();
            translate([-foot_d, -foot_d, -eps])
                cube([2 * foot_d, 2 * foot_d, collar_z]);
        }
        translate([0, 0, glass_bottom_z]) glass_envelope();
        translate([0, 0, collar_z]) collar_half(-insertion_side);
    }
}
else if (show == "screw-fit") intersection() {
    stabilizer_base();
    screw_positions() translate([0, 0, screw_tip_z]) thumbscrew();
}
else if (show == "screw-insertion") intersection() {
    translate([0, 0, collar_z]) { collar_half(1); collar_half(-1); }
    screw_positions() translate([0, 0, screw_tip_z])
        cylinder(d = screw_d, h = screw_shaft_h);
}
else if (show == "screw-path") {
    // Raising by t and rotating by 360*t/pitch preserves the helical phase.
    // The finite shaft/tip is contained within that infinite compatible thread.
    for (step = [0 : screw_path_steps]) let(
        t = step / screw_path_steps * (collar_z - screw_tip_z + screw_pitch))
        intersection() {
            union() {
                stabilizer_base();
                translate([0, 0, collar_z]) { collar_half(1); collar_half(-1); }
            }
            screw_positions() translate([0, 0, screw_tip_z + t])
                rotate([0, 0, 360 * t / screw_pitch]) thumbscrew();
        }
}
else assert(false, str("unknown show: ", show));
