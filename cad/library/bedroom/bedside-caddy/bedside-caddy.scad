// Bedside caddy: an organizer tray on a bracket that hooks over a bed rail.
// Remade from the SketchUp-era meshes in this folder; see Note 1.

/* [Display] */
view = "default"; // [default, together, exploded]
show = "assembled"; // [assembled, exploded, tray, bracket]
side = "left"; // [left, right]
explode_gap = 40; // mm, tray lift in the exploded view.

/* [Tray body] */
tray_w = 155.2; // mm, side to side.
tray_d = 155; // mm, front to back, excluding the dovetail.
tray_h = 59.85; // mm, overall height including the rim.
tray_corner_r = 50; // mm, rounded back corner, outer.
tray_top_r = 2; // mm, roundover on every top edge.
tray_top_steps = 16; // layers approximating the roundover.

/* [Tray rim] */
rim_t = 5; // mm, wall of the three-sided skirt that drops over the shelf.
rim_h = 5; // mm, skirt depth; matches the bracket's shelf thickness.

/* [Front dovetail] */
dovetail_z = 29.86; // mm, centre height above the tray bottom.
dovetail_root = 9.54; // mm, height where it meets the front face.
dovetail_depth = 4.13; // mm, projection from the front face.
dovetail_angle = 30; // degrees, flank flare.

/* [Pockets] */
slot_w = 15; // mm
slot_r = 2; // mm, corner radius.
slot_floor = 10; // mm, above the tray bottom.
slot_long_xy = [10.2, 13]; // mm, front-left corner.
slot_long_len = 132; // mm
slot_short_xy = [30.2, 60]; // mm
slot_short_len = 85; // mm
cup_large_xy = [100.2, 100]; // mm, centre.
cup_large_d = 90; // mm
cup_large_floor = 10; // mm
cup_mid_xy = [85.44, 28.26]; // mm
cup_mid_d = 42; // mm
cup_mid_floor = 18; // mm
cup_small_xy = [131.17, 25.52]; // mm
cup_small_d = 28; // mm
cup_small_floor = 10; // mm
hex_xy = [46.04, 35.91]; // mm
hex_corners = 27; // mm, across corners, corners pointing front and back.
hex_floor = 20; // mm

/* [Bracket] */
plate_w = 145; // mm, along the bed rail.
plate_d = 145; // mm, across the rail.
plate_t = 5; // mm
plate_corner_r = 45; // mm
wall_x = 110; // mm, outer face of the hanging wall.
wall_t = 5; // mm
wall_h = 105; // mm
lip_x = 140; // mm, rail-side face of the lip.
lip_t = 5; // mm
lip_h = 24; // mm
channel_fillet_r = 1; // mm, inside corners of the rail channel.
gusset_t = 5; // mm
gusset_x0 = 60; // mm, where the 45-degree brace leaves the shelf.
gusset_y_left = [20, 120]; // mm, under the left tray.
gusset_y_right = [39, 120]; // mm, under the right tray.
tray_fit_clearance = 0.2; // mm, total, across the skirt.

/* [Colors] */
tray_color = "#d81b60";
bracket_color = "#5e35b1";

/* [Hidden] */
$fn = 120;
eps = 0.01;
dovetail_tip = dovetail_root + 2*dovetail_depth*tan(dovetail_angle);
mirrored = side == "right";

// ----- Tray -----

module tray_outline() {
    square([tray_w, tray_d - tray_corner_r]);
    square([tray_w - tray_corner_r, tray_d]);
    translate([tray_w - tray_corner_r, tray_d - tray_corner_r]) circle(r = tray_corner_r);
}

module rounded_slot(xy, len) {
    translate(xy) offset(r = slot_r) offset(delta = -slot_r) square([slot_w, len]);
}

module hex_pocket() {
    translate(hex_xy) rotate(90) circle(d = hex_corners, $fn = 6);
}

// Each pocket as [floor, outline]; the outline is selected by index.
pocket_floors = [slot_floor, slot_floor, cup_large_floor, cup_mid_floor, cup_small_floor, hex_floor];

module pocket_2d(i) {
    if (i == 0) rounded_slot(slot_long_xy, slot_long_len);
    else if (i == 1) rounded_slot(slot_short_xy, slot_short_len);
    else if (i == 2) translate(cup_large_xy) circle(d = cup_large_d);
    else if (i == 3) translate(cup_mid_xy) circle(d = cup_mid_d);
    else if (i == 4) translate(cup_small_xy) circle(d = cup_small_d);
    else if (i == 5) hex_pocket();
}

module top_face() {
    difference() {
        tray_outline();
        for (i = [0:len(pocket_floors) - 1]) pocket_2d(i);
    }
}

// Quarter-round on every top edge, outer and pocket alike, as thin layers.
module top_roundover() {
    step = tray_top_r/tray_top_steps;
    for (i = [0:tray_top_steps - 1]) {
        dz = (i + 1)*step;
        inset = tray_top_r - sqrt(tray_top_r^2 - dz^2);
        translate([0, 0, tray_h - tray_top_r + i*step])
            linear_extrude(step) offset(delta = -inset) top_face();
    }
}

// Open at the front so the skirt slides over the bracket shelf.
module skirt_cavity() {
    translate([0, 0, -eps]) linear_extrude(rim_h + eps) {
        offset(r = -rim_t) tray_outline();
        translate([rim_t, -eps]) square([tray_w - 2*rim_t, rim_t + 2*eps]);
    }
}

module dovetail() {
    lo = dovetail_z - dovetail_root/2;
    hi = dovetail_z + dovetail_root/2;
    // rotate([90,0,90]) maps the profile's (u, v) to (y, z) and extrudes along x.
    rotate([90, 0, 90]) linear_extrude(tray_w) polygon([
        [eps, lo], [-dovetail_depth, dovetail_z - dovetail_tip/2],
        [-dovetail_depth, dovetail_z + dovetail_tip/2], [eps, hi]
    ]);
}

module tray_left() {
    difference() {
        union() {
            linear_extrude(tray_h - tray_top_r) tray_outline();
            top_roundover();
            dovetail();
        }
        skirt_cavity();
        for (i = [0:len(pocket_floors) - 1])
            translate([0, 0, pocket_floors[i]]) linear_extrude(tray_h) pocket_2d(i);
    }
}

module tray() {
    color(tray_color)
        if (mirrored) translate([tray_w, 0, 0]) mirror([1, 0, 0]) tray_left();
        else tray_left();
}

// ----- Bracket, in print orientation: shelf on the bed, wall and lip up -----

module plate_outline() {
    corner_y = mirrored ? plate_w - plate_corner_r : plate_corner_r;
    hull() {
        translate([plate_corner_r, corner_y]) circle(r = plate_corner_r);
        translate([plate_corner_r, 0]) square([plate_d - plate_corner_r, plate_w]);
        translate([0, mirrored ? 0 : plate_corner_r]) square([eps, plate_w - plate_corner_r]);
    }
}

// Wall and lip in the XZ plane; together they form the rail channel.
module rail_profile() {
    translate([wall_x, 0]) {
        square([wall_t, wall_h - wall_t]);
        translate([wall_t, wall_h - wall_t]) intersection() {
            circle(r = wall_t);
            translate([-wall_t, 0]) square(wall_t);
        }
    }
    translate([lip_x, 0]) {
        square([lip_t, lip_h - lip_t]);
        translate([0, lip_h - lip_t]) intersection() {
            circle(r = lip_t);
            square(lip_t);
        }
    }
    for (x = [wall_x + wall_t, lip_x]) {
        dir = x == lip_x ? -1 : 1;
        translate([x, plate_t]) difference() {
            translate([dir < 0 ? -channel_fillet_r : 0, -eps]) square([channel_fillet_r, channel_fillet_r + eps]);
            translate([dir*channel_fillet_r, channel_fillet_r]) circle(r = channel_fillet_r, $fn = 24);
        }
    }
}

module gusset() {
    rotate([90, 0, 0]) linear_extrude(gusset_t) polygon([
        [gusset_x0, plate_t - eps], [wall_x + eps, plate_t - eps],
        [wall_x + eps, plate_t + wall_x - gusset_x0]
    ]);
}

module bracket() {
    color(bracket_color) {
        linear_extrude(plate_t) plate_outline();
        translate([0, plate_w, 0]) rotate([90, 0, 0]) linear_extrude(plate_w) rail_profile();
        for (y = mirrored ? gusset_y_right : gusset_y_left) translate([0, y + gusset_t, 0]) gusset();
    }
}

// ----- Assembly, in tray coordinates -----

// The bracket turns over so the wall and lip hang down either side of the
// rail; its outer edge meets the skirt's back wall. A proper rotation, so
// each bracket is used exactly as printed. See Note 2.
module bracket_in_use() {
    multmatrix([
        [0, -1, 0, rim_t + tray_fit_clearance/2 + plate_w],
        [-1, 0, 0, tray_d - rim_t],
        [0, 0, -1, rim_h],
        [0, 0, 0, 1]
    ]) bracket();
}

module assembled(gap = 0) {
    translate([0, 0, gap]) tray();
    bracket_in_use();
}

if (view == "together") assembled();
else if (view == "exploded") assembled(explode_gap);
else if (show == "bracket") bracket();
else if (show == "assembled") assembled();
else if (show == "exploded") assembled(explode_gap);
else tray();

// Note 1. Every dimension was measured from bedside-caddy-left.stl and the
// two bottom-*.stl brackets, which were drawn in SketchUp and printed. The
// tray printed upright, skirt down, with tree supports under the dovetail
// and the skirt roof; that orientation is unchanged here.

// Note 2. Turned over for use, the bracket saved as bottom-right.stl is the
// one whose rounded corner lands in the left tray's rounded skirt corner;
// bottom-left.stl fits the mirrored right tray. The originals were named
// by how they lay on the print bed. Here side names the tray it carries.
// Their gussets sit at different spacings, reproduced as measured.
