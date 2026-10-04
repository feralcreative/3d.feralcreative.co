// 4 x 2 Gridfinity plate that hangs off the wire shelf on the proven mount.
// +X runs along the shelf, +Y points away from it, +Z is up in use.
// Reuse the exact channel and wire cutters; do not redraw the wire seats.
use <../wire-shelf-box-platform.scad>
include <gridfinity-plate-modules.scad>

/* [Grid] */
xsize = 4;               // cells along the shelf
ysize = 2;               // cells projecting away from the shelf

/* [Plate] */
// The split deck prints face up, underside on the bed, with the joint groove cut
// up into that underside. The floor is thick enough to bury the magnets above
// the groove: 2.94 mm groove, 0.72 mm roof, then skin, cavity and skin.
floor_thickness = 6.28;  // mm of flat sheet under the sockets; it is the deck

/* [Magnets] */
// Face up, the cavities run 3.66 to 5.82 mm off the bed, both on 0.30/0.12
// layer boundaries, so slice.sh --magnet-pause pauses cleanly.
magnet_hole_d = 10.5;    // mm cavity for a 10 x 2 mm disc; 0 for none
magnet_cav_h = 2.16;     // mm, a 2 mm disc plus 0.16, eighteen 0.12 layers
magnet_skin = 0.46;      // mm between cavity and socket floor

/* [Print] */
flip = true;             // one-piece plate only: socket rim on the bed; false shows it as mounted

/* [Mount] */
mount_depth = 12;        // mm, retain the tested attachment's outer depth
deck_z = 38.7;           // mm, retain the tested deck underside elevation
mount_wall_t = 3.54;     // mm, brace thickness; two outer plus six inner lines
brace_run = 34;          // mm forward of the mounting beam
brace_x = [-80, -30, 30, 80]; // mm, brace centres

/* [Joint] */
// Split print: the deck prints face up and the rail prints as mounted, channel
// mouth on the bed. They glue together on a sliding dovetail along X: the tail
// stands on the rail top and slides into a groove in the deck's underside.
dt_mouth_w = 5;          // mm, groove width at the deck underside
dt_root_w = 7;           // mm, groove width at its roof; 18 deg flanks
dt_depth = 2.94;         // mm up into the deck; its roof is a 7 mm bridge, so neither
                         // piece needs supports: the rail prints as mounted, tail up
dt_clear = 0.2;          // mm per face, snug sliding plus a glue film
dt_chamfer = 0.5;        // mm at 45 deg on the groove mouth, which prints on the bed
coupon_len = 30;         // mm of joint in the fit coupon
coupon_roof = 1.2;       // mm of strip above the coupon's groove
set_gap = 8;             // mm between deck and rail on the shared print plate

/* [Display] */
show = "plate";          // [plate, deck, rail, print-set, set-rail, enforcer, joint-coupon, split, mount, section]

/* [Colors] */
// Preview only; STLs carry no colour. Each printed piece gets its own.
deck_color = "SteelBlue";
rail_color = "DarkOrange";
coupon_color = "MediumSeaGreen"; // the coupon's floor strip, which no full piece has

/* [Hidden] */
$fn = 48;
mount_eps = 0.01;        // mm boolean overshoot
plate_w = xsize * gridfinity_pitch;
plate_d = ysize * gridfinity_pitch;

assert(mount_depth == 12 && deck_z == 38.7,
       "Keep the proven channel surround and deck elevation unchanged");
assert(mount_depth + brace_run < plate_d, "Braces must end beneath the plate");
assert(dt_root_w < mount_depth - 4, "Leave at least 2 mm of rail beside the tail");
assert(magnet_hole_d == 0 ||
       floor_thickness - magnet_skin - magnet_cav_h - dt_depth >= 0.6,
       "Magnet cavities must clear the groove roof by at least 0.6 mm");

module gf_plate() {
    // plate_blocks centres cell 0 on the origin and puts its floor at Z=-floor.
    translate([-plate_w / 2 + gridfinity_pitch / 2, gridfinity_pitch / 2,
               deck_z + floor_thickness])
        plate_blocks([[0, 0, xsize, ysize]], floor_ht = floor_thickness,
                     magnet_hole_d = magnet_hole_d,
                     magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
}

module mount_braces() {
    for (x = brace_x)
        translate([x - mount_wall_t / 2, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = mount_wall_t, convexity = 10)
                    polygon([[mount_depth - mount_eps, 0],
                             [mount_depth + brace_run, deck_z + mount_eps],
                             [mount_depth - mount_eps, deck_z + mount_eps]]);
}

module mount() {
    // Trim the beam's square ends to the plate's rounded corners.
    intersection() {
        plate_footprint(-mount_eps, deck_z + 2 * mount_eps);
        mount_body();
    }
}

module mount_body() {
    difference() {
        union() {
            translate([-plate_w / 2, 0, 0])
                cube([plate_w, mount_depth, deck_z + mount_eps]);
            mount_braces();
        }
        channel_cut(plate_w);
        floor_wire_reliefs(plate_w);
    }
}

module plate_footprint(z0, h) {
    translate([-plate_w / 2 + gridfinity_pitch / 2, gridfinity_pitch / 2, z0])
        linear_extrude(height = h, convexity = 10)
            plate_outline_2d([[0, 0, xsize, ysize]]);
}

// Groove section in [Y, Z], narrow mouth on the joint face, wide roof above it.
// It extends 1 mm below the joint face so the offset tail keeps the same flank
// line through it; extra adds the 45 deg mouth chamfer.
module dovetail_2d(extra = 0) {
    yc = mount_depth / 2;
    slope = (dt_root_w - dt_mouth_w) / 2 / dt_depth;
    low = deck_z - 1;
    polygon([[yc - dt_mouth_w / 2 + slope * (low - deck_z), low],
             [yc + dt_mouth_w / 2 - slope * (low - deck_z), low],
             [yc + dt_root_w / 2, deck_z + dt_depth],
             [yc - dt_root_w / 2, deck_z + dt_depth]]);
    if (extra > 0)
        polygon([[yc - dt_mouth_w / 2 - extra, low],
                 [yc + dt_mouth_w / 2 + extra, low],
                 [yc + dt_mouth_w / 2 + extra, deck_z - mount_eps],
                 [yc + dt_mouth_w / 2, deck_z + extra],
                 [yc - dt_mouth_w / 2, deck_z + extra],
                 [yc - dt_mouth_w / 2 - extra, deck_z - mount_eps]]);
}

module along_x(len) {
    translate([-len / 2, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = len, convexity = 10) children();
}

module dovetail_groove() {
    along_x(plate_w + 2 * mount_eps) dovetail_2d(dt_chamfer);
}

module dovetail_tail() {
    intersection() {
        along_x(plate_w) intersection() {
            offset(delta = -dt_clear) dovetail_2d();
            translate([0, deck_z - mount_eps]) square([mount_depth, dt_depth + mount_eps]);
        }
        plate_footprint(deck_z - mount_eps, dt_depth + 2 * mount_eps);
    }
}

module rail() {
    color(rail_color) {
        intersection() {
            mount();
            translate([-plate_w, -mount_eps, -mount_eps])
                cube([2 * plate_w, plate_d, deck_z + mount_eps]);
        }
        dovetail_tail();
    }
}

module deck() {
    color(deck_color) difference() {
        gf_plate();
        dovetail_groove();
    }
}

module deck_pose() {
    // Face up, underside on the bed.
    translate([0, 0, -deck_z]) children();
}

module set_rail_pose() {
    // Behind the deck on the shared plate, as mounted, channel mouth on the bed.
    translate([0, -(mount_depth + brace_run) - set_gap, 0]) children();
}

module groove_enforcer() {
    // Support enforcer for the shared plate: the groove, mouth chamfer included,
    // from the bed to 1 mm past its roof, so the roof layer is inside it.
    // Supports grow only under overhangs, so the overlap with solid is harmless.
    w = max(dt_root_w, dt_mouth_w + 2 * dt_chamfer);
    color("Gold", 0.5) deck_pose() intersection() {
        translate([-plate_w / 2, (mount_depth - w) / 2, deck_z])
            cube([plate_w, w, dt_depth + 1]);
        plate_footprint(deck_z, dt_depth + 1);
    }
}

module joint_coupon() {
    // A slice of the real rail with its tail, and a strip carrying the groove,
    // both in their print poses.
    intersection() {
        rail();
        translate([-coupon_len / 2, -mount_eps, -mount_eps])
            cube([coupon_len, plate_d, deck_z + dt_depth + 1]);
    }
    color(coupon_color) translate([0, -mount_depth - 6, -deck_z]) difference() {
        translate([-coupon_len / 2, -2, deck_z])
            cube([coupon_len, mount_depth + 4, dt_depth + coupon_roof]);
        intersection() {
            dovetail_groove();
            translate([-coupon_len / 2 - 1, -3, deck_z - 2])
                cube([coupon_len + 2, mount_depth + 6, dt_depth + 3]);
        }
    }
}

module shelf_plate() {
    color(rail_color) mount();
    color(deck_color) gf_plate();
}

module print_pose() {
    // Turn over about X and stand the socket rim on the bed.
    if (flip) translate([0, plate_d, deck_z + floor_thickness + 5]) rotate([180, 0, 0]) children();
    else children();
}

if (show == "plate") print_pose() shelf_plate();
else if (show == "deck") deck_pose() deck();
else if (show == "rail") rail();
else if (show == "print-set") { deck_pose() deck(); set_rail_pose() rail(); groove_enforcer(); }
else if (show == "set-rail") set_rail_pose() rail();
else if (show == "enforcer") groove_enforcer();
else if (show == "joint-coupon") joint_coupon();
else if (show == "split") { translate([0, 0, 15]) deck(); rail(); }
else if (show == "mount") mount();
else if (show == "section") {
    intersection() {
        shelf_plate();
        translate([-mount_wall_t / 2, -mount_eps, -mount_eps])
            cube([mount_wall_t, plate_d + 2 * mount_eps, deck_z + 20]);
    }
}
