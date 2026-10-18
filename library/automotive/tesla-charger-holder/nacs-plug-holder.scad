// Wall holster for a NACS (Tesla) charge handle, hung nose-up like Tesla's dock.
// The fixed bump on the older holders only works with a loose pocket: the plug has
// to lift over it, so it can lift back off. This bore is snug, and a printed spring
// latch snaps into the connector's own latch pocket, the one the car's pin uses.
// Print with the wall face on the bed; no supports.

/* [Plug] */
tilt = 45;                 // deg, plug axis above horizontal, nose toward the wall
plug_clearance = 0.4;      // mm, per side around the inlet cavity outline
bore_depth = 36;           // mm, full-outline bore from the plug face; the top of the handle flares beyond
floor_depth = 48;          // mm, the latch side of the nose stays straight to here
relief = 6;                // mm, handle relief grown outward beyond those depths
relief_floor_keep = 4;     // mm, floor height kept under the relief between the two depths
end_wall = 3;              // mm, stop behind the plug face

/* [Latch] */
latch_engage = 2.2;        // mm, tooth height into the connector's 4 mm-deep pocket
latch_hold_w = 17.4;       // mm, holding face from the stop, at the plug surface (pocket near edge 16.9-17.7)
hold_angle = 60;           // deg, holding face to the axis; steeper holds harder
ramp_angle = 35;           // deg, lead-in face to the axis
tooth_width = 8;           // mm, across the pocket, which is 9.71 mm at its base
tooth_top = 0.6;           // mm, flat on the tooth crest
arm_width = 9;             // mm, spring arm width
arm_thick = 2.2;           // mm, spring arm thickness
arm_recess = 1.0;          // mm, arm top below the bore floor so the plug rests on the floor, not the arm
arm_root_w = -4;           // mm, arm root, behind the stop: printed wall-down, the arm grows up
                           // from here, so its free end toward the mouth never starts in mid-air
arm_side_gap = 0.6;        // mm, slit each side of the arm
arm_end_gap = 0.8;         // mm, gap at the arm's free end
arm_travel_extra = 0.8;    // mm, free travel under the arm beyond the tooth height

/* [Body] */
wall = 3;                  // mm, around the bore and under the latch slot
body_front = 60;           // mm, body depth from the wall
body_back_w = 50;          // mm, body length along the plug axis from the stop

/* [Mounting] */
plate_t = 5;               // mm, solid base under the body
screw_d = 4.5;             // mm, clearance for a #8 / 4 mm wood screw
screw_head_d = 9;          // mm, 90-degree countersink
screw_seat_z = 6;          // mm, countersink top above the wall: plastic clamped under the head
screw_channel_d = 10;      // mm, driver and head access from the front, through the bore
screw_x = 11;              // mm, either side of centre; the channel clears the latch slot
screw_y = -15.5;           // mm, below the stop's centre, so the channel clears the bore's top lip

/* [Coupon] */
coupon_h = 10;             // mm, fit-test sleeve length
coupon_wall = 2.1;         // mm

/* [Colors] */
holder_color = "SlateGray";

/* [Output] */
show = "holder"; // [holder, coupon, section]

/* [Hidden] */
$fn = 64;
eps = 0.01;
// Inner cavity of the NACS inlet (TS-0011139) in the supplied adapter STEP, 45 mm
// in from its mounting face: u across, v toward the handle top, latch side at -v.
inlet_cavity = [[14.442, -13.186], [12.885, -14.276], [11.986, -14.825], [10.309, -15.719], [8.564, -16.471], [6.762, -17.076], [5.749, -17.362], [4.718, -17.577], [2.844, -17.890], [0.950, -18.047], [-0.950, -18.047], [-2.844, -17.890], [-3.887, -17.746], [-5.749, -17.362], [-7.572, -16.825], [-9.344, -16.140], [-10.309, -15.719], [-11.243, -15.232], [-12.885, -14.276], [-14.442, -13.186], [-14.941, -12.754], [-15.314, -12.347], [-15.702, -11.813], [-16.748, -10.027], [-17.270, -9.021], [-18.127, -7.137], [-18.848, -5.197], [-19.188, -4.116], [-19.706, -2.112], [-20.080, -0.076], [-20.308, 1.981], [-20.390, 3.111], [-20.407, 4.244], [-20.357, 6.313], [-20.160, 8.373], [-19.915, 9.575], [-19.505, 10.731], [-18.936, 11.817], [-18.429, 12.553], [-17.374, 13.700], [-16.685, 14.269], [-15.650, 14.927], [-14.533, 15.434], [-12.287, 16.195], [-10.852, 16.606], [-8.547, 17.161], [-6.213, 17.581], [-3.858, 17.864], [-2.370, 17.978], [0.000, 18.047], [2.370, 17.978], [3.859, 17.864], [6.213, 17.581], [8.547, 17.161], [10.853, 16.606], [12.287, 16.195], [14.533, 15.434], [15.650, 14.927], [16.685, 14.269], [17.617, 13.473], [18.222, 12.814], [18.748, 12.092], [19.104, 11.530], [19.505, 10.731], [19.915, 9.575], [20.160, 8.373], [20.357, 6.313], [20.407, 4.244], [20.390, 3.111], [20.309, 1.981], [20.080, -0.076], [19.706, -2.112], [19.188, -4.116], [18.848, -5.197], [18.127, -7.137], [17.270, -9.021], [16.748, -10.027], [15.702, -11.813], [15.314, -12.347], [14.941, -12.754]];
half_h = 18.05 + plug_clearance;
floor_v = -half_h;
arm_top = floor_v - arm_recess;
arm_bot = arm_top - arm_thick;
slot_bot = arm_bot - (latch_engage + arm_travel_extra);
low_v = slot_bot - wall;
sleeve_back = max(end_wall, 2 - arm_root_w + wall);
pivot_z = -low_v * sin(tilt) + sleeve_back * cos(tilt);
tooth_v = floor_v + latch_engage;
tooth_a = latch_hold_w - arm_recess / tan(hold_angle);
tooth_b = latch_hold_w + latch_engage / tan(hold_angle);
tooth_c = tooth_b + tooth_top;
tooth_d = tooth_c + (tooth_v - arm_top) / tan(ramp_angle);
arm_free_w = tooth_d + 0.5;

assert(tooth_a > arm_root_w + 15, "the arm needs length behind the tooth to flex");
assert(arm_free_w + arm_end_gap < bore_depth, "latch slot must end inside the full bore");

// Local frame: x across the plug, y toward its top, z out of the bore.
module plug_frame() {
    translate([0, 0, pivot_z]) rotate([tilt, 0, 0]) children();
}

module bore_2d(grow = 0) {
    offset(r = plug_clearance + grow) union() {
        polygon(inlet_cavity);
        mirror([1, 0]) polygon(inlet_cavity);
    }
}

module above_floor_2d(keep) {
    translate([-100, floor_v + keep]) square([200, 200]);
}

module sleeve() {
    intersection() {
        translate([-100, -200, 0]) cube([200, 400, body_front]);
        plug_frame() translate([0, 0, -sleeve_back])
            linear_extrude(sleeve_back + body_back_w, convexity = 4) hull() {
                bore_2d(wall);
                translate([-(arm_width / 2 + arm_side_gap + wall), low_v])
                    square([arm_width + 2 * (arm_side_gap + wall), -low_v]);
            }
    }
}

// Sunk into the body: the driver reaches the head down a channel from the bore,
// with the plug out. The channels open into the bottom of the stop.
module screw_hole() {
    translate([0, 0, -eps]) cylinder(d = screw_d, h = screw_seat_z + 2 * eps);
    translate([0, 0, screw_seat_z - screw_head_d / 2])
        cylinder(d1 = 0, d2 = screw_head_d, h = screw_head_d / 2 + eps);
    translate([0, 0, screw_seat_z]) cylinder(d = screw_channel_d, h = 200);
}

module bore_cut() {
    plug_frame() {
        linear_extrude(floor_depth + eps, convexity = 4) bore_2d();
        // The top of the handle flares sooner than its latch side.
        hull() {
            translate([0, 0, bore_depth]) linear_extrude(eps)
                intersection() { bore_2d(); above_floor_2d(relief_floor_keep); }
            translate([0, 0, bore_depth + relief]) linear_extrude(200)
                intersection() { bore_2d(relief); above_floor_2d(relief_floor_keep); }
        }
        hull() {
            translate([0, 0, floor_depth]) linear_extrude(eps) bore_2d();
            translate([0, 0, floor_depth + relief]) linear_extrude(200) bore_2d(relief);
        }
    }
}

module latch_slot() {
    plug_frame()
        translate([-(arm_width / 2 + arm_side_gap), slot_bot, arm_root_w])
            cube([arm_width + 2 * arm_side_gap, floor_v - slot_bot + 1,
                  arm_free_w + arm_end_gap - arm_root_w]);
}

module latch() {
    plug_frame() {
        translate([-arm_width / 2, arm_bot, arm_root_w - 2])
            cube([arm_width, arm_thick, arm_free_w - arm_root_w + 2]);
        // Profile drawn as [v, w]: holding face toward the stop, lead-in toward the mouth.
        translate([-tooth_width / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(tooth_width) polygon([
                [arm_top - arm_thick / 2, tooth_a], [arm_top, tooth_a], [tooth_v, tooth_b],
                [tooth_v, tooth_c], [arm_top, tooth_d], [arm_top - arm_thick / 2, tooth_d]]);
    }
}

module holder() {
    color(holder_color) {
        difference() {
            hull() {
                sleeve();
                linear_extrude(plate_t) projection() sleeve();
            }
            bore_cut();
            latch_slot();
            for (sx = [-screw_x, screw_x]) translate([sx, screw_y, 0]) screw_hole();
        }
        latch();
    }
}

module coupon() {
    // Bore fit only, printed flat; the tab marks the latch side.
    color(holder_color) linear_extrude(coupon_h) difference() {
        union() {
            bore_2d(coupon_wall);
            translate([-3, floor_v - coupon_wall - 3]) square([6, 3 + eps]);
        }
        bore_2d();
    }
}

if (show == "holder") holder();
else if (show == "coupon") coupon();
else if (show == "section") difference() {
    holder();
    translate([0, -200, -1]) cube([200, 400, 200]);
}
else assert(false, str("unknown show: ", show));
