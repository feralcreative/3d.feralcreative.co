// Wall holster for a NACS (Tesla) charge handle, hung nose-up like Tesla's dock.
// The fixed bump on the older holders only works with a loose pocket: the plug has
// to lift over it, so it can lift back off. This bore is snug, and a printed spring
// latch snaps into the connector's own latch pocket, the one the car's pin uses.
// Print with the wall face on the bed; no supports.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

use <../../../logos/fonts/Gwendolyn-Bold.ttf>

/* [Plug] */
tilt = 45;                 // deg, plug axis above horizontal, nose toward the wall
plug_clearance = 0.4;      // mm, per side around the inlet cavity outline
bore_depth = 36;           // mm, full-outline bore from the plug face; the top of the handle flares beyond
floor_depth = 48;          // mm, the latch side of the nose stays straight to here
relief = 6;                // mm, handle relief grown outward beyond those depths
relief_floor_keep = 4;     // mm, floor height kept under the relief between the two depths
end_wall = 3;              // mm, stop behind the plug face
skin = 2.5;                // mm, extra outside thickness; pivot_z ignores it, so the bore, latch and
                           // screws stay put and the surplus behind the wall is cut off. At 2.0 the
                           // name's strips leave stray slivers (genus 5); 2.5 and 3 build clean

/* [Latch] */
latch_engage = 2.2;        // mm, tooth height into the connector's 4 mm-deep pocket
latch_hold_w = 17.4;       // mm, holding face from the stop, at the plug surface (pocket near edge 16.9-17.7)
hold_angle = 65;           // deg, holding face to the axis; steeper holds harder
ramp_angle = 35;           // deg, lead-in face to the axis
tooth_width = 8;           // mm, across the pocket, which is 9.71 mm at its base
tooth_top = 0.6;           // mm, flat on the tooth crest
arm_width = 9;             // mm, spring arm width
arm_root_thick = 5.0;      // mm, spring arm thickness at the root
arm_tip_thick = 3.0;       // mm, thickness from the tooth outward; the taper between spreads the
                           // bend along the arm. About 34 N at the tooth and 1.3% root strain;
                           // 2.6 to 1.4 on a 4 mm root gave 8.7 N and printed far too flimsy
arm_root_fillet = 1.5;     // mm, radius in both corners where the arm leaves the slot's end wall
arm_recess = 1.0;          // mm, arm top below the bore floor so the plug rests on the floor, not the arm
arm_root_w = -10;          // mm, arm root, behind the stop: printed wall-down, the arm grows up
                           // from here, so its free end toward the mouth never starts in mid-air
arm_side_gap = 0.6;        // mm, slit each side of the arm
arm_end_gap = 0.8;         // mm, gap at the arm's free end
arm_travel_extra = 0.4;    // mm, free travel under the arm's root beyond the tooth height

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

/* [Name] */
name_text = "Charlotte";
name_font = "Gwendolyn:style=Bold"; // loaded from logos/fonts by the use<> below
name_arc = 46;             // mm, ink width measured around the curve of the top face
name_w = 9.5;              // mm, ink centre along the plug axis from the stop
name_depth = 0.8;          // mm, deboss depth below the face
name_taper = 70;           // deg from the face; 90 is a prismatic cut
name_steps = 5;            // bands the taper is built from
name_swell = 0.15;         // mm, grown onto every stroke: Gwendolyn's hairlines are thinner
                           // than a 0.4 nozzle can cut at this size
name_strip = 0.4;          // mm, width of the flat strips the name is wrapped in

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
arm_root_bot = arm_top - arm_root_thick;
arm_tip_bot = arm_top - arm_tip_thick;
slot_bot = arm_root_bot - (latch_engage + arm_travel_extra);
low_v = slot_bot - wall;
sleeve_back = max(end_wall, 2 - arm_root_w + wall);
pivot_z = -low_v * sin(tilt) + sleeve_back * cos(tilt);
tooth_v = floor_v + latch_engage;
tooth_a = latch_hold_w - arm_recess / tan(hold_angle);
tooth_b = latch_hold_w + latch_engage / tan(hold_angle);
tooth_c = tooth_b + tooth_top;
tooth_d = tooth_c + (tooth_v - arm_top) / tan(ramp_angle);
arm_free_w = tooth_d + 0.5;
shell = wall + skin;

assert(tooth_a > arm_root_w + 15, "the arm needs length behind the tooth to flex");
assert(arm_free_w + arm_end_gap < bore_depth, "latch slot must end inside the full bore");
assert(arm_root_fillet < floor_v + 1 - arm_top, "top root fillet must fit under the slot roof");

// The name wraps around the outside of the sleeve's top: the cavity's upper half,
// grown by the clearance and wall the same way bore_2d grows it. The outline runs
// clockwise, so each edge's left normal points out.
function unit(d) = d / norm(d);
function out_normal(d) = unit([-d[1], d[0]]);
name_top = [for (p = inlet_cavity) if (p[1] > 0) p];
name_last = len(name_top) - 1;
name_n = [for (i = [0 : name_last]) unit(
    (i > 0 ? out_normal(name_top[i] - name_top[i - 1]) : [0, 0]) +
    (i < name_last ? out_normal(name_top[i + 1] - name_top[i]) : [0, 0]))];
name_pts = [for (i = [0 : name_last]) name_top[i] + (plug_clearance + shell) * name_n[i]];
name_cum = [for (i = 0, a = 0; i <= name_last;
                 a = a + (i < name_last ? norm(name_pts[i + 1] - name_pts[i]) : 0), i = i + 1) a];
function name_seg(s) = max([0, for (i = [0 : name_last - 1]) if (name_cum[i] <= s) i]);
// [point, outward normal] at arc length s.
function name_at(s) = let(i = name_seg(s), f = (s - name_cum[i]) / (name_cum[i + 1] - name_cum[i]))
    [name_pts[i] + f * (name_pts[i + 1] - name_pts[i]), unit(name_n[i] + f * (name_n[i + 1] - name_n[i]))];
name_s0 = let(i = max([for (i = [0 : name_last - 1]) if (name_pts[i][0] <= 0) i]))
    name_cum[i] + (0 - name_pts[i][0]) / (name_pts[i + 1][0] - name_pts[i][0]) * (name_cum[i + 1] - name_cum[i]);
name_ink = textmetrics(name_text, size = 100, font = name_font);
name_size = name_arc * 100 / name_ink.size[0];
name_span = name_arc + 2 * name_swell + 1;

// The baseline arcs with the rim of the mouth below it. The rim is where the face
// meets the front cap, and that sits farther down the face wherever the face is
// lower, so the baseline drops by the same amount and keeps a constant gap to it.
// Laid out in face coordinates: u around the curve, w along the plug axis.
function name_drop(u) = name_at(name_s0)[0][1] - name_at(name_s0 + u)[0][1];
function name_slope(u) = (name_drop(u + 0.25) - name_drop(u - 0.25)) / 0.5;
name_umax = name_span / 2 + 2;
name_du = 0.25;
name_k = 2 * ceil(name_umax / name_du);
name_us = [for (k = [0 : name_k]) -name_k / 2 * name_du + k * name_du];
// Baseline length from the left end, so glyph x is measured along the arc.
name_len = [for (k = 0, a = 0; k <= name_k;
                 a = a + (k < name_k ? norm([name_du, name_drop(name_us[k + 1]) - name_drop(name_us[k])]) : 0),
                 k = k + 1) a];
// u at baseline distance g from the middle of the name.
function name_u(g) = let(L = name_len[name_k / 2] + g,
                         k = max([0, for (i = [0 : name_k - 1]) if (name_len[i] <= L) i]))
    name_us[k] + (L - name_len[k]) / (name_len[k + 1] - name_len[k]) * name_du;

assert(name_s0 - name_span / 2 > 0 && name_s0 + name_span / 2 < name_cum[name_last],
       "the name runs off the top of the sleeve");
assert(shell - name_depth >= 1.2, "not enough wall left behind the name");

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
        plug_frame() translate([0, 0, -(sleeve_back + skin)])
            linear_extrude(sleeve_back + skin + body_back_w, convexity = 4) hull() {
                bore_2d(shell);
                translate([-(arm_width / 2 + arm_side_gap + shell), low_v - skin])
                    square([arm_width + 2 * (arm_side_gap + shell), skin - low_v]);
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

// Concave fillet in the corner at [v, w], opening toward [sv, +w].
module root_fillet_2d(v, sv) {
    r = arm_root_fillet;
    difference() {
        translate([sv > 0 ? v - 0.2 : v - r, arm_root_w - eps]) square([r + 0.2, r + eps]);
        translate([v + sv * r, arm_root_w + r]) circle(r = r);
    }
}

module latch() {
    // Profiles drawn as [v, w], extruded across the arm.
    plug_frame() {
        translate([-arm_width / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(arm_width) {
                polygon([
                    [arm_top, arm_root_w - 2], [arm_top, arm_free_w],
                    [arm_tip_bot, arm_free_w], [arm_tip_bot, tooth_a],
                    [arm_root_bot, arm_root_w], [arm_root_bot, arm_root_w - 2]]);
                root_fillet_2d(arm_top, 1);
                root_fillet_2d(arm_root_bot, -1);
            }
        // Holding face toward the stop, lead-in toward the mouth.
        translate([-tooth_width / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(tooth_width) polygon([
                [arm_top - arm_tip_thick / 2, tooth_a], [arm_top, tooth_a], [tooth_v, tooth_b],
                [tooth_v, tooth_c], [arm_top, tooth_d], [arm_top - arm_tip_thick / 2, tooth_d]]);
    }
}

// Grown 0.1 further and shrunk back, which closes the pinhole contours Gwendolyn
// leaves where cursive strokes cross. Each strip saw its own tilted copy of a
// pinhole, and where two copies overlapped they left a crumb floating in the cut.
module name_glyph(erode) {
    offset(delta = -erode) offset(r = -0.1) offset(r = name_swell + 0.1)
        translate(-(name_ink.position + name_ink.size / 2) * name_size / 100)
            text(name_text, size = name_size, font = name_font);
}

// The name, debossed across the sloping top face, read from in front of the wall.
// Tapered as a stack of bands like the chalk holder's wordmark and the roku
// stand's letters, so no stroke has a roof. Each band is held between two insets
// of the face's own outline, so the depth is constant over the curve. The glyph
// is cut into flat strips and each strip stands square to the face, which wraps
// the name instead of projecting it, so the ends are not stretched.
module name_cut() {
    steps = name_taper >= 90 ? 1 : max(1, name_steps);
    band = name_depth / steps;
    n = ceil(name_span / name_strip);
    plug_frame() for (k = [0 : steps - 1]) {
        d_out = band * k;
        d_in = band * (k + 1);
        erode = name_taper >= 90 ? 0 : d_out / tan(name_taper);
        intersection() {
            // Strips overlap 0.1 each side, so where neighbours tilt apart no sliver of
            // face is left standing between them.
            for (j = [0 : n - 1]) {
                g = -name_span / 2 + (j + 0.5) * name_strip;
                u = name_u(g);
                at = name_at(name_s0 + u);
                p = at[0];
                nn = at[1];
                t = [nn[1], -nn[0]];
                // Along the baseline, and square to it toward the stop, in face [u, w].
                m = name_slope(u);
                bu = 1 / sqrt(1 + m * m);
                bw = m / sqrt(1 + m * m);
                // Glyph x along the arc, glyph y up toward the stop, extrusion outward.
                multmatrix([[bu * t[0], bw * t[0], nn[0], p[0] - g * bu * t[0]],
                            [bu * t[1], bw * t[1], nn[1], p[1] - g * bu * t[1]],
                            [bw, -bu, 0, name_w + name_drop(u) - g * bw],
                            [0, 0, 0, 1]])
                    translate([0, 0, -(name_depth + 0.5)]) linear_extrude(name_depth + 1)
                        intersection() {
                            translate([g - name_strip / 2 - 0.1, -50]) square([name_strip + 0.2, 100]);
                            name_glyph(erode);
                        }
            }
            // Band 0 reaches eps out past the face; the rest reach into the band above.
            translate([0, 0, -50]) linear_extrude(200, convexity = 4) difference() {
                bore_2d(shell - d_out + eps);
                bore_2d(shell - d_in);
            }
        }
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
            // render(): hundreds of strip intersections overflow preview's CSG
            // normalization, which then gives up and draws nothing at all.
            if (name_text != "") render() name_cut();
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



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_b6229a878500() {
if (show == "holder") holder();
else if (show == "coupon") coupon();
else if (show == "section") difference() {
    holder();
    translate([0, -200, -1]) cube([200, 400, 200]);
}
else assert(false, str("unknown show: ", show));
}

module feral_assembly_view_b6229a878500(explode=false) {
feral_default_output_b6229a878500();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_b6229a878500();
else feral_assembly_view_b6229a878500(view == "exploded");
