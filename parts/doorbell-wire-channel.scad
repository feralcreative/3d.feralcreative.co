// doorbell-wire-channel.scad
//
// A surface raceway for the Aqara doorbell's power wire, and the cap on the
// hole it disappears into. The wire is two conductors joined by their
// insulation, 1.7 thick x 3.8 wide (Ziad, 2026-09-13). From the doorbell it
// runs 260 mm down the wall, jogs 15 mm to the left, and goes into the old
// doorbell's wire hole. Grey PETG, to match the paint.
//
// THE HOLE AND THE OLD CAP. The hole is a rounded rectangle, about 16 x 19,
// and _incoming/doorbell-hole-cap.stl is what has been in it: a hollow plug
// of that section 8 mm deep under a 24 x 26 flange 0.8 thick with a rounded
// rim (measured off the mesh 2026-09-13). Ziad: the plug is the right size
// but does not go in far enough to stay put, and the flange does not reach
// the old doorbell's screw holes, which sit about 10 mm outside the hole
// above and below it. So the plug here is solid, plug_depth deep, with
// crush ribs a little proud of the hole's size, and the cap is cap_w x cap_h
// — tall enough to cover a screw hole at 19/2 + 10 from the centre with
// cap_margin to spare.
//
// ⚠️ ASSUMED: the hole's 19 mm dimension is the vertical one, in line with
// the screw holes. hole_w and hole_h swap if not. Also assumed: 14 mm of
// plug can go in before it hits anything; the old one went 8.
//
// THE RACEWAY IS A COVER. The wire runs against the wall, in a groove down
// the BACK of a rw_w x rw_h bar; the front is a plain chamfered face. Nothing
// holds the wire in but the wall — the bar is laid over the wire and taped
// down by the two rails either side of the groove. (Ziad, 2026-09-13: the
// first draft had the slot on the front, wire showing.) Every front edge is
// chamfered rw_ch at 45 — a chamfer rather than a round because the front
// face goes on the bed (below) and a round would start at 90 degrees.
//
// THE CAP IS AS THICK AS THE RACEWAY. The old cap was 0.8. Here the groove
// has to cross the cap to reach the plug, and cap and raceway have to share
// one front face if the piece is to print face down in one go — a 0.8 flange
// under a 3.6 raceway would print in the air. So cap_t = rw_h. The cap is
// also wide enough (cap_right > jog + rw_w/2) that the vertical run comes
// down onto the cap's top edge and the jog happens inside the plate, as a
// turn in the groove, rather than as a visible elbow beside it.
//
// THE TURN IS ONE LONG ARC. The groove leaves the vertical run on an arc
// through 45 that arrives at the plug's nearest corner — the top right —
// heading diagonally into it; by default the arc is as big as will still
// reach the corner (about 24 mm radius), so there is no straight and no
// kink anywhere (Ziad, 2026-09-13: the square turn was too tight, then the
// sharp 45 was rounded, then "as gradually as possible"). It passes through
// a notch in the plug's wall at that corner, on the same diagonal, and is
// inside the plug.
//
// THE PLUG IS A SHELL, open to the hole: plug_wall of wall around the hole's
// section and the cap as its front, like the old one but plug_depth deep and
// ribbed. The wire comes through the corner notch into the hollow and down
// into the hole from there. The notch runs the whole depth, splitting the
// corner open to the tip, so the wire is laid into it from the side rather
// than threaded through a hole (Ziad, 2026-09-13).
//
// TWO PIECES, because 260 does not fit a 220 bed. The lower piece is the
// cap, the jog, and lower_run of the vertical; the upper is the rest. They
// meet in a half-lap IN PLAN: the lower's left half carries on lap mm past
// its right half, and the upper's left half is cut back the same, so the
// seam steps across the width. Full height everywhere, so both pieces print
// face down with nothing in the air — a lap in the thickness would put one
// half of the joint 0.8 mm off the bed. The tape does the holding; the lap
// only keeps them in line. Set lower_run so the lower piece — lower_run +
// lap + cap_h/2 tall — and upper_run both stay under 205.
//
// PRINTED FACE DOWN. flip = true (the default) turns each piece over so the
// front face, chamfers and all, is on the bed and the groove, rails and plug
// are on top. flip = false draws it the way it goes on the wall: x to the
// right, y up, z out of the wall, the wall at z = 0, the hole's centre at
// the origin.
//
// COUPON. show = "cap" is the cap and plug alone, with the groove from its
// edge — print that first: if the plug will not go in, drop plug_rib; if it
// does not hold, raise it or plug_depth.

/* [Output] */
// lower — jog, cap, plug, and the lower part of the vertical run
// upper — the rest of the vertical run
// cap   — cap and plug alone, the fit coupon
// both  — lower and upper laid side by side, to look at
show = "lower";  // [lower, upper, cap, both]

// Printed orientation, front face on the bed. false draws it as it mounts.
flip = true;

/* [Wire — measured] */
wire_t = 1.7;    // wire, thick (mm)
wire_w = 3.8;    // wire, wide (mm)

/* [Hole — measured off the old cap] */
hole_w = 16.0;   // across (mm)
hole_h = 19.0;   // up and down, in line with the screw holes (mm)
hole_r = 3.0;    // the hole's corner radius, from the old plug (mm)
screw_off = 10.0;  // old screw holes, from the hole's edge, above and below (mm)

/* [Run] */
run_len   = 260.0;  // doorbell to the jog's centreline (mm)
jog       = 15.0;   // the run's centreline is this far right of the hole (mm)
lower_run = 120.0;  // of run_len, on the lower piece; the rest is the upper (mm)
lap       = 10.0;   // the lap joint (mm)
lap_clr   = 0.2;    // between tongue end and the upper's back plate (mm)
bend_r    = 0;      // centreline radius of the bend out of the run; 0 = as large as will reach the corner (mm)

/* [Raceway] */
rw_w     = 8.0;   // across (mm)
rw_h     = 3.6;   // off the wall; also the cap's thickness (mm)
slot_w   = 4.2;   // the groove, for the wire's 3.8 (mm)
slot_d   = 2.0;   // the groove, for the wire's 1.7; what is left in front is the skin (mm)
rw_ch    = 0.8;   // chamfer on every front edge, 45 deg (mm)

/* [Cap] */
cap_right  = 21.0;  // hole centre to the cap's right edge; enough that the run lands on the cap, not beside it (mm)
cap_left   = 18.5;  // hole centre to the left edge; was 21, Ziad took 2.5 off looking at the front view (mm)
cap_margin = 6.5;   // past the far edge of a screw hole, above and below (mm)
cap_r      = 8.0;   // corner radius (mm)

/* [Plug] */
plug_depth = 14.0;  // into the hole; the old one went 8 (mm)
plug_rib   = 0.3;   // crush ribs proud of the hole's size, per side (mm)
rib_w      = 1.2;   // (mm)
plug_lead  = 1.0;   // chamfer on the plug's leading edge (mm)
plug_wall  = 1.68;  // the shell, four loops on the 0.4 nozzle (mm)
notch_d    = plug_depth + 1;  // the wire notch through the top-right corner: the full depth, so the wire is laid in from the side, not threaded (mm)

/* [Quality] */
$fn = 48;

eps = 0.01;

// ---- derived ---------------------------------------------------------------

upper_run = run_len - lower_run;
cap_h     = hole_h + 2 * (screw_off + cap_margin);   // 52.0
cap_w     = cap_left + cap_right;                     // 39.5
cap_x     = (cap_right - cap_left) / 2;               // the cap's centre, right of the hole
cap_t     = rw_h;
plug_hw   = hole_w / 2;
plug_hh   = hole_h / 2;
// The diagonal runs at 45 down to the plug's top-right corner; a straight
// line from the run would leave it diag_y above the hole's centre. The bend
// is an arc tangent to both, so the run's groove actually ends bend_y up,
// and the straight part of the diagonal starts at (diag_x0, diag_y0) and is
// diag_len long to the corner. The biggest arc that still reaches the
// corner is bend_max, at which the straight part vanishes and the arc runs
// from the run to the corner in one sweep; that is the default, Ziad having
// asked for the bend to be as gradual as possible.
diag_y    = plug_hh + (jog - plug_hw);            // 16.5
bend_max  = (jog - plug_hw) / (1 - sqrt(2) / 2);  // 23.90
bend      = bend_r > 0 ? min(bend_r, bend_max) : bend_max;
bend_y    = diag_y + bend * (sqrt(2) - 1);        // 26.40 at bend_max
diag_x0   = jog - bend * (1 - sqrt(2) / 2);       // 8.00 at bend_max
diag_y0   = bend_y - bend * sqrt(2) / 2;          // 9.50 at bend_max
diag_len  = (diag_x0 - plug_hw) * sqrt(2);        // 0 at bend_max
// Where the arc starts above the cap's top edge, it has to stay inside the
// raceway's rails; this is how far it has strayed from the centreline by
// the time it reaches the cap.
stray     = bend_y > cap_h / 2 ? bend - sqrt(bend * bend - pow(bend_y - cap_h / 2, 2)) : 0;
assert(stray < (rw_w - slot_w) / 2 - 0.8, "the bend leaves the raceway before it reaches the cap");

assert(slot_d > wire_t && slot_w > wire_w, "the wire does not fit the groove");
assert(lower_run + lap + cap_h / 2 <= 205 && upper_run <= 205, "a piece is longer than the safe bed");

module rr(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);

// The raceway in section, x across and y out from the wall.
module rw_outer() polygon([
  [-rw_w / 2, 0], [rw_w / 2, 0], [rw_w / 2, rw_h - rw_ch], [rw_w / 2 - rw_ch, rw_h],
  [-rw_w / 2 + rw_ch, rw_h], [-rw_w / 2, rw_h - rw_ch]]);
// The groove, open to the wall.
module rw_slot() translate([-slot_w / 2, -eps]) square([slot_w, slot_d + eps]);

// A section, run from y = a to y = b, or from x = a to x = b.
module along_y(a, b) translate([0, b, 0]) rotate([90, 0, 0]) linear_extrude(b - a) children();
module along_x(a, b) rotate([0, 0, -90]) along_y(a, b) children();

// The cap plate, front edges chamfered, centred cap_x right of the hole.
module cap_plate() translate([cap_x, 0, 0]) hull() {
  linear_extrude(cap_t - rw_ch) rr(cap_w, cap_h, cap_r);
  translate([0, 0, cap_t - eps]) linear_extrude(eps) offset(delta = -rw_ch) rr(cap_w, cap_h, cap_r);
}

// The plug, hanging below z = 0: a shell of the hole's section, ribbed,
// with a lead-in, hollow to the back of the cap.
module plug() {
  mirror([0, 0, 1]) difference() {
    union() {
      hull() {
        linear_extrude(plug_depth - plug_lead) rr(hole_w, hole_h, hole_r);
        translate([0, 0, plug_depth - eps]) linear_extrude(eps) offset(delta = -plug_lead) rr(hole_w, hole_h, hole_r);
      }
      // Ribs: two a side on the long faces, one a side on the short, each
      // fading to nothing over its last plug_lead so the plug still starts in.
      for (sx = [-1, 1], y = [-plug_hh * 0.6, plug_hh * 0.6])
        rib([sx * plug_hw, y], [sx * plug_rib, 0], [0, rib_w]);
      for (sy = [-1, 1])
        rib([0, sy * plug_hh], [0, sy * plug_rib], [rib_w, 0]);
    }
    translate([0, 0, -eps]) linear_extrude(plug_depth + 2 * eps)
      rr(hole_w - 2 * plug_wall, hole_h - 2 * plug_wall, max(hole_r - plug_wall, 0.5));
  }
}
// A rib on a face at p, standing out by v, span s along the face; z down.
module rib(p, v, s) hull() {
  translate([p[0] + v[0] / 2, p[1] + v[1] / 2, (plug_depth - plug_lead) / 2])
    cube([max(abs(v[0]), s[0]) + eps, max(abs(v[1]), s[1]) + eps, plug_depth - plug_lead], center = true);
  translate([p[0], p[1], plug_depth - eps])
    cube([max(eps, s[0]), max(eps, s[1]), eps], center = true);
}

// The wire's way from the vertical run into the plug: a 45 arc of radius
// bend out of the run, a straight groove on the diagonal to the plug's
// top-right corner (none at all at bend_max), then a notch through the
// corner's wall on the same line, notch_d deep. The arc's centre is bend
// left of the run, level with where the run's groove ends.
module diagonal_wire() {
  translate([jog - bend, bend_y, 0]) rotate([0, 0, -45])
    rotate_extrude(angle = 45 + eps) translate([bend, 0]) rw_slot();
  translate([diag_x0, diag_y0, 0]) rotate([0, 0, -135]) {
    along_x(-eps, diag_len + eps) rw_slot();
    // From hole_r before the corner point to the corner round's centre,
    // hole_r * sqrt(2) past it — the wall's inner face is that way, at
    // (hole_r - plug_wall) short of the centre, and a cutter stopped at
    // plug_wall past the corner point never reached it (the first cut).
    translate([diag_len - hole_r, -slot_w / 2, -notch_d])
      cube([hole_r * (1 + sqrt(2)) + eps, slot_w, notch_d + slot_d]);
  }
}

module lower() difference() {
  union() {
    cap_plate();
    plug();
    translate([jog, 0, 0]) along_y(-rw_w / 2, lower_run + lap - lap_clr) rw_outer();
  }
  // The right half stops at lower_run; the left carries on as the tongue.
  translate([jog, lower_run, -eps]) cube([rw_w / 2 + eps, lap + eps, rw_h + 2 * eps]);
  translate([jog, 0, 0]) along_y(bend_y - eps, lower_run + lap + eps) rw_slot();
  diagonal_wire();
}

// From y = 0 at the joint to upper_run at the doorbell; the left half is
// cut back lap mm to take the lower's tongue.
module upper() difference() {
  along_y(0, upper_run) rw_outer();
  along_y(-eps, upper_run + eps) rw_slot();
  translate([-rw_w / 2 - eps, -eps, -eps]) cube([rw_w / 2 + eps, lap + eps, rw_h + 2 * eps]);
}

// The fit coupon: cap and plug, with the groove in from the cap's top edge
// the way the run would bring it.
module cap_only() difference() {
  union() { cap_plate(); plug(); }
  translate([jog, 0, 0]) along_y(min(bend_y, cap_h / 2) - eps, cap_h / 2 + eps) rw_slot();
  diagonal_wire();
}

module oriented() {
  if (flip) translate([0, 0, rw_h]) rotate([180, 0, 0]) children();
  else children();
}

if (show == "lower") oriented() lower();
if (show == "upper") oriented() upper();
if (show == "cap")   oriented() cap_only();
if (show == "both") {
  oriented() lower();
  translate([cap_w / 2 + rw_w + 10, -cap_h / 2, 0]) oriented() upper();
}

echo(str("cap ", cap_w, " x ", cap_h, " x ", cap_t, " (", cap_left, " left of the hole, ", cap_right, " right); plug ", hole_w, " x ", hole_h,
         " + ", plug_rib, " ribs, ", plug_depth, " deep; lower piece ",
         lower_run + lap + cap_h / 2, " tall, upper ", upper_run));
