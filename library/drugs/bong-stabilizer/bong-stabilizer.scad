// Wide foot and split retaining collar for a 95 mm glass bong base.
// Print the foot upright, both collar halves flat, and four wing screws head-down.
// All fasteners are printed. The collar seats on the plastic shoulder, not glass.
// Fit a 1 mm soft liner RING in the seat and six 1 mm nonslip pads underneath.
// The Bambu LED puck enters from underneath; its lens shines through the seat.
// Test coupon-base with the production collar and one screw before the wide foot.

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/threading.scad>

/* [Glass measurements] */
glass_base_d = 95;           // mm, maximum outside diameter
glass_edge_h = 13;           // mm, cylindrical outside edge height
glass_neck_d = 43;           // mm, chamber outside diameter
glass_neck_z = 14;           // mm, flare meets chamber above glass bottom
glass_total_h = 419.1;       // mm, 16.5 inches; reference only
glass_filled_mass = 1020.6;  // g, 36 ounces; reference only

/* [Foot and glass clearance] */
foot_d = 195;               // mm, footprint before optional nonslip pads
floor_h = 4.2;              // mm, outer foot thickness; centre rises for the puck
foot_edge_r = 1.2;          // mm, roundover on the foot's top outside edge
seat_diameter_clearance = 1.5; // mm, 0.75 mm radial glass clearance
glass_top_clearance = 0.8;  // mm above the highest measured flare
liner_h = 1;               // mm, removable soft disk in the seat
pad_d = 18;                // mm, adhesive nonslip pad pockets
pad_circle_r = 87;          // mm, radius to pad centres
pad_count = 6;              // evenly distributed nonslip pads
pad_recess = 0.6;           // mm, leaves a 1 mm pad 0.4 mm proud

/* [LED puck] */
puck_d = 59.4;             // mm, same Bambu puck as pumpkin and haunted trees
puck_h = 8.0;              // mm, puck body thickness
puck_fit = 0.15;           // mm per side, proven pumpkin pocket clearance
puck_depth_extra = 0.1;    // mm, puck back inset above the base underside
puck_lens_d = 47.6;        // mm, lit window must remain fully clear
puck_roof = 1.5;           // mm, proven 45-degree annular pocket stop
cable_d = 2.8;             // mm, puck cable diameter
cable_clear = 0.3;         // mm per side, underside cable groove clearance
cable_angle = 90;          // degrees, exits between the nonslip pad pockets
liner_opening_d = 60;      // mm, soft ring opening keeps the light path clear
puck_entry_travel = 30;    // mm, verification starts entirely below the base

/* [Retaining collar] */
collar_outer_d = 132;       // mm, plastic support shoulder and collar diameter
collar_opening_d = 86;      // mm, overlaps the 95 mm glass rim radially
collar_h = 6.3;             // mm, each retaining half's thickness
collar_split_gap = 0.6;     // mm between the installed halves
collar_edge_chamfer = 0.6;  // mm, opening edges only
collar_plate_gap = 4;       // mm, spacing between separately printed halves

/* [Printed wing screws] */
screw_d = 10;               // mm, coarse printed screw major diameter
screw_pitch = 2;            // mm per turn; custom thread, not an M10 hardware fit
screw_shaft_h = 16;         // mm, below the head
screw_clearance_d = 11.2;   // mm, unthreaded collar holes
thread_diameter_clearance = 0.6; // mm, allowance for printing the internal thread
screw_xy = 40;             // mm, four screw centres at (+/-40, +/-40)
screw_head_d = 16;          // mm, circular bearing hub under the two wings
screw_head_h = 4.2;         // mm, head-down print orientation
screw_wing_span = 36;       // mm, complete two-wing grip length
screw_wing_width = 12;      // mm, rounded outer paddle width
screw_wing_neck = 6.3;      // mm, wing root width at the bearing hub
screw_tip_chamfer = 0.8;    // mm, shaft insertion lead-in
thread_bottom_extra = 2;    // mm, one extra pitch below the seated screw tip
screw_plate_pitch = 42;    // mm, four-wing-screw plate layout
thread_fn = 64;            // thread facets, independent of large circles

/* [Colors] */
foot_color = "SlateGray";
right_collar_color = "DarkOrange";
left_collar_color = "Goldenrod";
screw_color = "MediumSeaGreen";
glass_color = [0.6, 0.85, 1, 0.25];
liner_color = "DimGray";
puck_color = "Silver";

/* [Output] */
show = "exploded"; // [base, collar-set, screw, screw-set, coupon-base, assembly, exploded, section, glass-fit, glass-insertion, collar-fit, collar-insertion, screw-fit, screw-insertion, screw-path, puck-fit, puck-insertion]
insertion_side = 1;        // [1, -1]
exploded_gap = 25;         // mm, illustration spacing
collar_entry_travel = 140; // mm, clears the complete support shoulder
screw_path_steps = 48;     // verification poses along the helical insertion route

/* [Hidden] */
$fn = 128;
eps = 0.01;
seat_d = glass_base_d + seat_diameter_clearance;
pocket_d = puck_d + 2 * puck_fit;
pocket_h = puck_h + puck_depth_extra;
seat_floor_z = pocket_h + puck_roof;
glass_bottom_z = seat_floor_z + liner_h;
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
       sqrt(2) * screw_xy + screw_head_d / 2 < collar_outer_d / 2 + foot_edge_r,
       "screws must clear glass and remain over the plastic shoulder");
assert(foot_d <= 205 && collar_outer_d < foot_d,
       "foot must fit the documented safe printer envelope");
assert(abs(thread_bottom_extra / screw_pitch - round(thread_bottom_extra / screw_pitch)) < eps,
       "extra thread depth must preserve helical phase");
assert(pocket_d - 2 * (puck_roof + 2 * eps) > puck_lens_d &&
       liner_opening_d >= pocket_d && liner_opening_d < glass_base_d,
       "puck stop and liner must clear the lens and support the glass rim");
assert(screw_head_d > screw_clearance_d &&
       sqrt(2) * screw_xy - screw_wing_span / 2 > glass_neck_d / 2 &&
       screw_plate_pitch > screw_wing_span,
       "wing screws must bear on the collar, turn clear of glass, and print apart");

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
        cyl(d = diameter, h = floor_h, rounding2 = foot_edge_r, anchor = BOT);
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
        puck_cutouts();
        if (!coupon)
            for (a = [0 : 360 / pad_count : 360 - 360 / pad_count])
                rotate([0, 0, a]) translate([pad_circle_r, 0, -eps])
                    cylinder(d = pad_d * bore_factor, h = pad_recess + eps);
    }
}

// Copy the proven open-bottom pocket and 45-degree stop, then open its roof
// into the glass seat. The remaining seat is an annulus supporting the glass.
module puck_cutouts() {
    pd = pocket_d * bore_factor;
    light_d = pd - 2 * (puck_roof + 2 * eps);
    cw = cable_d + 2 * cable_clear;
    translate([0, 0, -eps]) cylinder(d = pd, h = pocket_h + eps);
    translate([0, 0, pocket_h - eps])
        cylinder(d1 = pd, d2 = light_d, h = puck_roof + 2 * eps);
    translate([0, 0, seat_floor_z - eps])
        cylinder(d = light_d, h = collar_z - seat_floor_z + 2 * eps);
    rotate([0, 0, cable_angle]) translate([0, -cw / 2, -eps])
        cube([foot_d / 2 + eps, cw, cw + eps]);
}

module puck_dummy() {
    color(puck_color) union() {
        cylinder(d = puck_d, h = puck_h);
        rotate([0, 0, cable_angle]) translate([puck_d / 2 - cable_d, 0, cable_d / 2])
            rotate([0, 90, 0]) cylinder(d = cable_d, h = foot_d / 2);
    }
}

// Exact continuous bottom-entry translation, including the cable. Every pose
// from entirely below the base to seated is contained in this swept envelope.
module puck_entry_sweep() {
    translate([0, 0, -puck_entry_travel]) {
        cylinder(d = puck_d, h = puck_entry_travel + puck_depth_extra + puck_h);
        rotate([0, 0, cable_angle])
            translate([puck_d / 2 - cable_d, -cable_d / 2, 0])
                cube([foot_d / 2, cable_d,
                      puck_entry_travel + puck_depth_extra + cable_d]);
    }
}

module liner_ring() {
    color(liner_color) difference() {
        cylinder(d = glass_base_d, h = liner_h);
        translate([0, 0, -eps])
            cylinder(d = liner_opening_d * bore_factor, h = liner_h + 2 * eps);
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
        translate([0, 0, screw_shaft_h]) wing_head();
    }
}

// Two rounded paddles and a circular bearing hub. Both broad faces are flat,
// so the complete screw prints head-down with the original shaft upright.
module wing_head() {
    linear_extrude(height = screw_head_h, convexity = 10) union() {
        circle(d = screw_head_d);
        for (side = [-1, 1]) hull() {
            translate([side * (screw_head_d / 2 - screw_wing_neck / 2), 0])
                circle(d = screw_wing_neck);
            translate([side * (screw_wing_span - screw_wing_width) / 2, 0])
                circle(d = screw_wing_width);
        }
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
    translate([0, 0, seat_floor_z]) liner_ring();
    translate([0, 0, puck_depth_extra - (explode ? exploded_gap : 0)]) puck_dummy();
    if (show != "section")
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
else if (show == "section") difference() {
    assembly();
    translate([0, -foot_d, -puck_entry_travel])
        cube([foot_d, 2 * foot_d, glass_total_h + puck_entry_travel + collar_z]);
}
else if (show == "puck-fit") intersection() {
    stabilizer_base();
    translate([0, 0, puck_depth_extra]) puck_dummy();
}
else if (show == "puck-insertion") intersection() {
    stabilizer_base();
    puck_entry_sweep();
}
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
