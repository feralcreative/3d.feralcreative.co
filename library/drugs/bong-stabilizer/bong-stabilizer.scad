// Wide foot and split retaining collar for a 95 mm glass bong base.
// Print the foot upright, both collar halves flat, and four hex-head bolts head-down.
// All fasteners are printed. The collar seats on the plastic shoulder, not glass.
// An orange PETG lens sits in the seat: its 3 mm rim carries the glass and takes
// up the measured play; its thin window covers the light. No underside pad recesses.
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
foot_d = 172;               // mm, footprint diameter
floor_h = 4.2;              // mm, outer foot thickness; centre rises for the puck
foot_edge_r = floor_h;      // mm, full-height top roundover; underside stays flat
seat_diameter_clearance = 1.5; // mm, 0.75 mm radial glass clearance
glass_top_clearance = 0.8;  // mm above the highest measured flare
liner_h = 1;               // mm, design glass lift that the seat heights are keyed to

/* [Lens] */
lens_rim_h = 3;            // mm, rim under the glass; takes up the measured ~3 mm play
lens_window_t = 0.42;      // mm, 0.30 first layer + one 0.12 layer, the thinnest reliable sheet
lens_d = glass_base_d;     // mm, outside diameter, 0.75 mm radial clearance in the seat
lens_window_d = 60;        // mm, rim opening, wider than the seat's light hole

/* [LED puck] */
puck_d = 59.4;             // mm, same Bambu puck as pumpkin and haunted trees
puck_h = 8.0;              // mm, puck body thickness
puck_fit = 0.15;           // mm per side, proven pumpkin pocket clearance
puck_depth_extra = 0.1;    // mm, puck back inset above the base underside
puck_lens_d = 47.6;        // mm, lit window must remain fully clear
puck_roof = 1.5;           // mm, proven 45-degree annular pocket stop
cable_d = 2.8;             // mm, puck cable diameter
cable_clear = 0.3;         // mm per side, underside cable groove clearance
cable_angle = 90;          // degrees, cable exits along +Y
liner_opening_d = 60;      // mm, soft ring opening keeps the light path clear
puck_entry_travel = 30;    // mm, verification starts entirely below the base

/* [Retaining collar] */
collar_outer_d = 132;       // mm, plastic support shoulder and collar diameter
collar_opening_d = 86;      // mm, overlaps the 95 mm glass rim radially
collar_h = 6.3;             // mm, each retaining half's thickness
collar_split_gap = 0;       // mm, flat ends meet flush when the halves are installed
collar_top_r = collar_h;    // mm, full-height top rounds on the retaining plates
collar_plate_gap = 4;       // mm, spacing between separately printed halves

/* [Stem cutout] */
stem_cutout_w = 25;        // mm, proven +X opening from bong-liftout-cradle
stem_cutout_from_glass = 12.8; // mm, cradle cutout bottom 17 minus glass seat 4.2
stem_cutout_top_r = 3;     // mm, same upper corner rounds as the printed cradle

/* [Printed hex-head bolts] */
screw_d = 10;               // mm, coarse printed screw major diameter
screw_pitch = 2;            // mm per turn; custom thread, not an M10 hardware fit
screw_shaft_h = 16;         // mm, below the head
screw_clearance_d = 11.2;   // mm, unthreaded collar holes
thread_diameter_clearance = 0.6; // mm, allowance for printing the internal thread
screw_xy = 40;             // mm, four screw centres at (+/-40, +/-40)
screw_head_d = 20;          // mm, original hexagonal head diameter across corners
screw_head_h = 6.3;         // mm, head-down print orientation
bearing_flat_extra = 0.1;  // mm per side, flat contact margin around screw head
screw_tip_chamfer = 0.8;    // mm, shaft insertion lead-in
thread_bottom_extra = 2;    // mm, one extra pitch below the seated screw tip
screw_plate_pitch = 25;    // mm, original four-bolt plate layout
thread_fn = 64;            // thread facets, independent of large circles

/* [Colors] */
foot_color = "White";
right_collar_color = "SIlver";
left_collar_color = "SIlver";
screw_color = "SIlver";
glass_color = [0.6, 0.85, 1, 0.25];
lens_color = "DarkOrange";
puck_color = "Silver";

/* [Output] */
show = "assembly"; // [base, lens, collar-set, screw, screw-set, coupon-base, assembly, exploded, section, glass-fit, glass-insertion, collar-fit, collar-insertion, plate-end-fit, screw-fit, screw-insertion, screw-path, puck-fit, puck-insertion]
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
stem_cutout_bottom_z = glass_bottom_z + stem_cutout_from_glass;
stem_corner_segments = $fn / 4; // matches the proven quarter-circle cutter
thread_bottom_z = screw_tip_z - thread_bottom_extra;
thread_cut_h = screw_shaft_h + 2 * thread_bottom_extra;
bore_factor = 1 / cos(180 / $fn);

assert(glass_neck_z > glass_edge_h && glass_base_d > glass_neck_d,
       "glass flare measurements are inconsistent");
assert(seat_floor_z > 0 && thread_bottom_z > floor_h,
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
       sqrt(2) * screw_xy - screw_head_d / 2 > glass_neck_d / 2 &&
       screw_plate_pitch > screw_head_d,
       "bolts must bear on the collar, turn clear of glass, and print apart");
assert(lens_d < seat_d && lens_window_t < lens_rim_h &&
       lens_window_d > pocket_d - 2 * puck_roof && lens_window_d < lens_d,
       "lens must drop into the seat, span the light hole and keep a rim");
assert(collar_top_r <= collar_h,
       "plate top rounds must leave connected material below the edges");

assert(stem_cutout_w > 0 && stem_cutout_w < collar_opening_d &&
       stem_cutout_bottom_z > seat_floor_z && stem_cutout_bottom_z < collar_z &&
       stem_cutout_top_r > 0 && stem_cutout_top_r < collar_h &&
       stem_cutout_w / 2 + stem_cutout_top_r < screw_xy - screw_head_d / 2,
       "stem opening must preserve the glass seat, plate and bolt bearing areas");

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
    // This entire top annulus is the mating face for the flat plate undersides.
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
        stem_cutout();
    }
}

// Copy the cradle's +X slot relative to the glass seat, through base and plate.
// The bottom and straight width stay fixed; only the two top corners are rounded.
module stem_cutout() {
    translate([0, -stem_cutout_w / 2, stem_cutout_bottom_z])
        cube([foot_d / 2 + eps, stem_cutout_w,
              screw_head_z - stem_cutout_bottom_z + eps]);
    for (side = [-1, 1]) scale([1, side, 1])
        rotate([90, 0, 90])
        linear_extrude(height = foot_d / 2 + eps, convexity = 10)
        polygon(concat(
            [[stem_cutout_w / 2 - eps, screw_head_z - stem_cutout_top_r]],
            [for (i = [0:stem_corner_segments])
                i == 0 ? [stem_cutout_w / 2, screw_head_z - stem_cutout_top_r] :
                i == stem_corner_segments ? [stem_cutout_w / 2 + stem_cutout_top_r, screw_head_z] :
                [stem_cutout_w / 2 + stem_cutout_top_r +
                    stem_cutout_top_r * cos(180 - 90 * i / stem_corner_segments),
                 screw_head_z - stem_cutout_top_r +
                    stem_cutout_top_r * sin(180 - 90 * i / stem_corner_segments)]],
            [[stem_cutout_w / 2 + stem_cutout_top_r, screw_head_z + eps],
             [stem_cutout_w / 2 - eps, screw_head_z + eps]]));
}

// Local tangent-circle mask: opens an inner top edge without changing its
// lower bore or adding a hidden annular slot alongside the quarter-circle.
module inner_top_round_cut(radius, round_r, top_z) {
    rotate_extrude(convexity = 10)
        translate([radius, top_z - round_r]) difference() {
            translate([-eps, 0]) square([round_r + eps, round_r + eps]);
            translate([round_r, 0]) circle(r = round_r);
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

// Printed window-down: the thin window is the first layers on the bed.
module gel_lens() {
    color(lens_color) difference() {
        cylinder(d = lens_d, h = lens_rim_h);
        translate([0, 0, lens_window_t])
            cylinder(d = lens_window_d * bore_factor, h = lens_rim_h);
    }
}

module collar_blank() {
    difference() {
        intersection() {
            // Keep the outer footprint aligned with the base's 132 mm shoulder.
            cylinder(d = collar_outer_d, h = collar_h);
            union() {
                cyl(d = collar_outer_d, h = collar_h, rounding2 = collar_top_r, anchor = BOT);
                // Keep flat bearing areas within that original footprint.
                screw_positions()
                    cylinder(d = screw_head_d + 2 * bearing_flat_extra, h = collar_h);
            }
        }
        translate([0, 0, -eps])
            cylinder(d = collar_opening_d * bore_factor, h = collar_h + 2 * eps);
        difference() {
            inner_top_round_cut(collar_opening_d * bore_factor / 2,
                                collar_top_r, collar_h);
            screw_positions() translate([0, 0, -eps])
                cylinder(d = screw_head_d + 2 * bearing_flat_extra,
                         h = collar_h + 2 * eps);
        }
        screw_positions() translate([0, 0, -eps])
            cylinder(d = screw_clearance_d * bore_factor, h = collar_h + 2 * eps);
        translate([0, 0, -collar_z]) stem_cutout();
    }
}

module collar_half(side = 1) {
    color(side > 0 ? right_collar_color : left_collar_color)
    intersection() {
        collar_blank();
        // Split along Y so the +X stem gap trims the end of each rail.
        translate([-collar_outer_d,
                   side > 0 ? collar_split_gap / 2 : -collar_outer_d, -eps])
            cube([2 * collar_outer_d,
                  collar_outer_d - collar_split_gap / 2, collar_h + 2 * eps]);
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
        translate([0, side * collar_plate_gap / 2, 0]) collar_half(side);
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
        translate([0, side * (explode ? exploded_gap : 0),
                   collar_z + (explode ? exploded_gap : 0)]) collar_half(side);
    screw_positions() translate([0, 0, screw_tip_z + (explode ? 2 * exploded_gap : 0)])
        thumbscrew();
    translate([0, 0, seat_floor_z]) gel_lens();
    translate([0, 0, puck_depth_extra - (explode ? exploded_gap : 0)]) puck_dummy();
    if (show != "section")
        %color(glass_color) translate([0, 0, seat_floor_z + lens_rim_h]) glass_envelope();
}

// Exact continuous translation sweeps along the specified assembly route.
// Clear seated fit alone is insufficient: insert glass with both halves removed,
// then move the halves sideways above the flare, then turn the screws down.
module collar_sweep(side) {
    translate([0, 0, collar_z])
        linear_extrude(height = collar_h, convexity = 10)
            minkowski() {
                projection() collar_half(side);
                translate([-eps / 2, side > 0 ? 0 : -collar_entry_travel])
                    square([eps, collar_entry_travel]);
            }
}

if (show == "base") stabilizer_base();
else if (show == "lens") gel_lens();
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
else if (show == "plate-end-fit") intersection() {
    collar_half(1);
    collar_half(-1);
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
