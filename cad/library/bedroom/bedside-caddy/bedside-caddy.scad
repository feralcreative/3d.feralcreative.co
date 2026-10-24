// Bedside caddy: a two-half organizer tray on two brackets that hook over a
// bed rail. The halves join with a sliding dovetail. Remade from the
// SketchUp-era meshes in this folder; see Notes 1 and 3. The front is -y
// in the assembled views, the side face at x = 0 in each half's own frame.

/* [Display] */
view = "default"; // [default, together, exploded]
show = "assembled"; // [assembled, exploded, tray, bracket]
side = "left"; // [left, right]
explode_gap = 40; // mm, tray lift in the exploded view.

/* [Tray body] */
tray_w = 155.2; // mm, across the rail, both halves.
tray_d = 155; // mm, left half along the rail, excluding the dovetail.
tray_h = 59.85; // mm, left half overall height including the rim.
tray_corner_r = 50; // mm, rounded back corner, outer.
tray_top_r = 2; // mm, roundover on every top edge.
tray_top_steps = 16; // layers approximating the roundover.

/* [Tray rim] */
rim_t = 5; // mm, wall of the three-sided skirt that drops over the shelf.
rim_h = 5; // mm, skirt depth; matches the bracket's shelf thickness.

/* [Dovetail] */
dovetail_z = 29.86; // mm, center height above the tray bottom.
dovetail_root = 9.54; // mm, height where it meets the joint face.
dovetail_depth = 4.13; // mm, projection from the joint face.
dovetail_angle = 30; // degrees, flank flare.
groove_root = 10; // mm, female groove height at the right half's joint face.
groove_depth = 4.33; // mm, female groove depth into the right half.

/* [Right half] */
right_d = 145; // mm, along the rail.
right_h = 60; // mm, as drawn; the left half is 59.85.
right_corner_r = 46; // mm, rounded outer corner, outer.
right_cup_xy = [120.2, 32]; // mm, center, measured from the joint face.
right_cup_d = 50; // mm
right_cup_floor = 20; // mm
clip_x = 125.2; // mm, inner face of the cable clip.
clip_len = 10; // mm, across the rail.
clip_y = 113.92; // mm, clip centerline from the joint face.
clip_base_half = 11.08; // mm, half-width where the clip meets the top.
clip_flank_r = 101.33; // mm, radius of the concave outer flank.
clip_flank_c = [112.48, 62.96]; // mm, flank center as [half-width, height].
clip_shoulder_half = 20; // mm, half-width at the top of the flank.
clip_shoulder_z = 104.49; // mm
clip_ledge_z = 106.99; // mm, where each prong steps in to its cap.
clip_cap_base_half = 15.79; // mm, cap outer half-width at the ledge.
clip_cap_top_half = 17.35; // mm, cap outer half-width at the top.
clip_top_z = 112.79; // mm
clip_lip_base_half = 7.42; // mm, cap inner half-width at the ledge.
clip_lip_top_half = 5.87; // mm, cap inner half-width at the top.
clip_mouth_half = 6.5; // mm, half-width of the cable seat.
clip_mouth_r = 4.25; // mm, rounded bottom of the cable seat.
clip_slot_half = 2.25; // mm, half-width of the cable slot.
clip_slot_floor = 52; // mm, slot floor height.
clip_slot_top = 98.99; // mm, where the slot opens into the seat.
clip_back_t = 2; // mm, wall closing the slot's inner end.

/* [Pockets] */
slot_w = 15; // mm
slot_r = 2; // mm, corner radius.
slot_floor = 10; // mm, above the tray bottom.
slot_long_xy = [10.2, 13]; // mm, corner nearest the front and the joint.
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
hex_corners = 27; // mm, across corners, corners pointing along the rail.
hex_floor = 20; // mm

/* [Brackets] */
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
gusset_y_left = [39, 120]; // mm, bottom-left.stl, under the left half.
gusset_y_right = [20, 120]; // mm, bottom-right.stl, under the right half.
tray_fit_clearance = 0.2; // mm, total, across the skirt.

/* [Colors] */
tray_left_color = "#d81b60";
tray_right_color = "#f06292";
bracket_left_color = "#5e35b1";
bracket_right_color = "#9575cd";

/* [Hidden] */
$fn = 120;
eps = 0.01;
dovetail_tip = dovetail_root + 2*dovetail_depth*tan(dovetail_angle);

// ----- Tray -----

// Joint face on y = 0, rounded corner at the far end.
module tray_outline(d = tray_d, r = tray_corner_r) {
    square([tray_w, d - r]);
    square([tray_w - r, d]);
    translate([tray_w - r, d - r]) circle(r = r);
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

// Open at the joint face, where the shelves run on into the other half.
module skirt_cavity(d = tray_d, r = tray_corner_r) {
    translate([0, 0, -eps]) linear_extrude(rim_h + eps) {
        offset(r = -rim_t) tray_outline(d, r);
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

// Female groove, open at both ends so the halves slide together across the rail.
module dovetail_groove() {
    lo = dovetail_z - groove_root/2;
    hi = dovetail_z + groove_root/2;
    groove_tip = groove_root + 2*groove_depth*tan(dovetail_angle);
    translate([-eps, 0, 0]) rotate([90, 0, 90]) linear_extrude(tray_w + 2*eps) polygon([
        [-eps, lo], [groove_depth, dovetail_z - groove_tip/2],
        [groove_depth, dovetail_z + groove_tip/2], [-eps, hi]
    ]);
}

function clip_flank_half(z) = clip_flank_c[0] - sqrt(clip_flank_r^2 - (z - clip_flank_c[1])^2);

// One prong's outline in (half-width, height), from the centerline out.
module clip_half_profile() {
    flank = [for (i = [0:16]) let(z = right_h + i*(clip_shoulder_z - right_h)/16) [clip_flank_half(z), z]];
    polygon(concat(
        [[0, right_h - eps], [clip_flank_half(right_h), right_h - eps]],
        flank,
        [[clip_shoulder_half, clip_ledge_z], [clip_cap_base_half, clip_ledge_z],
         [clip_cap_top_half, clip_top_z], [0, clip_top_z]]
    ));
}

// The cable seat between the prongs, with its lip and rounded bottom.
module clip_seat_half_profile() {
    c = [clip_slot_half, clip_slot_top + clip_mouth_r];
    arc = [for (a = [270:5:360]) c + clip_mouth_r*[cos(a), sin(a)]];
    polygon(concat(
        [[-eps, clip_slot_top]], arc,
        [[clip_mouth_half, clip_ledge_z], [clip_lip_base_half, clip_ledge_z],
         [clip_lip_top_half, clip_top_z + eps], [-eps, clip_top_z + eps]]
    ));
}

module both_sides() { children(); mirror([1, 0]) children(); }

// Profile drawn in (y, z) about the clip centerline, extruded across the rail.
module clip_extrude(len) {
    translate([clip_x, clip_y, 0]) rotate([90, 0, 90]) linear_extrude(len) children();
}

// Right half in its own frame: joint face on y = 0, outer end at y = right_d.
module tray_right_local() {
    difference() {
        union() {
            linear_extrude(right_h) tray_outline(right_d, right_corner_r);
            clip_extrude(clip_len) both_sides() clip_half_profile();
        }
        skirt_cavity(right_d, right_corner_r);
        dovetail_groove();
        translate([0, 0, right_cup_floor]) linear_extrude(right_h) translate(right_cup_xy) circle(d = right_cup_d);
        translate([-eps, 0, 0]) clip_extrude(clip_len + 2*eps) both_sides() clip_seat_half_profile();
        translate([clip_x + clip_back_t, clip_y - clip_slot_half, clip_slot_floor])
            cube([tray_w - clip_x, 2*clip_slot_half, clip_slot_top - clip_slot_floor + eps]);
    }
}

// Each half sits in assembly coordinates: the left half runs from the joint
// face toward +y, the right half toward -y.
module tray(s = side) {
    if (s == "right") color(tray_right_color) mirror([0, 1, 0]) tray_right_local();
    else color(tray_left_color) tray_left();
}

// ----- Bracket, in print orientation: shelf on the bed, wall and lip up -----

module plate_outline(s = side) {
    mirrored = s == "left";
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

module bracket(s = side) {
    color(s == "right" ? bracket_right_color : bracket_left_color) {
        linear_extrude(plate_t) plate_outline(s);
        translate([0, plate_w, 0]) rotate([90, 0, 0]) linear_extrude(plate_w) rail_profile();
        for (y = s == "right" ? gusset_y_right : gusset_y_left) translate([0, y + gusset_t, 0]) gusset();
    }
}

// ----- Assembly, in tray coordinates -----

// Each bracket turns over about the rail so the wall and lip hang down
// either side of it, and runs along the rail under its half, rounded
// corner at the outer end. The two meet 5 mm past the tray joint, under
// the left half. A proper rotation, so each bracket is used as printed.
// See Note 2.
module bracket_in_use(s = side) {
    y0 = s == "right" ? -(right_d - rim_t) : tray_d - rim_t - plate_w;
    multmatrix([
        [-1, 0, 0, rim_t + tray_fit_clearance/2 + plate_d],
        [0, 1, 0, y0],
        [0, 0, -1, rim_h],
        [0, 0, 0, 1]
    ]) bracket(s);
}

// The whole caddy, turned a quarter turn so the x = 0 side faces -y, the
// front, with the left half on the left. Exploded lifts both halves and
// pulls the right half away from the joint so the dovetail shows.
module assembled(gap = 0) {
    rotate([0, 0, 90]) {
        translate([0, 0, gap]) tray("left");
        translate([0, -gap/2, gap]) tray("right");
        bracket_in_use("left");
        bracket_in_use("right");
    }
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

// Note 2. The brackets run end to end along the rail, as laid out in
// originals/bedside-caddy-working.stl. bottom-left.stl carries the left
// half and bottom-right.stl the right; side names match those files.
// Their gussets sit at different spacings, reproduced as measured.
// bottom-right.stl is 145.23 x 145.24 mm against 145 x 145; the working
// layout spaces both at 145, so both are drawn at 145 here.

// Note 3. The right half was measured from the full two-half tray in
// originals/bedside-caddy-working.stl, drawn there at 10x. It carries one
// cup, a two-pronged cable clip whose slot runs out through the outer
// side, and the female groove for the left half's dovetail.
