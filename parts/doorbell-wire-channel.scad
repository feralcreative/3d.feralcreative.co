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
// THE RACEWAY. A rw_w x rw_h bar with a slot down its front the wire presses
// into: slot_w wide at the bottom for the wire's 3.8, narrowed to mouth_w at
// the lips so it stays pressed in. The back is flat, for tape. Every front
// edge is chamfered rw_ch at 45 — a chamfer rather than a round because the
// front face goes on the bed (below) and a round would start at 90 degrees.
//
// THE CAP IS AS THICK AS THE RACEWAY. The old cap was 0.8. Here the raceway
// has to cross the cap to reach the plug, and cap and raceway have to share
// one front face if the piece is to print face down in one go — a 0.8 flange
// under a 3.6 raceway would print in the air. So cap_t = rw_h, and the slot
// runs across the cap to the plug's edge, then drops through the cap into a
// groove down the plug's side; the wire goes into the hole beside the plug.
// The cap is also wide enough (cap_w/2 > jog + rw_w/2) that the vertical
// run comes down onto the cap's top edge and the jog happens inside the
// plate, as a turn in the slot, rather than as a visible elbow beside it.
//
// TWO PIECES, because 260 does not fit a 220 bed. The lower piece is the
// jog, the cap, and lower_run of the vertical; the upper is the rest. They
// meet in a lap: the lower's back plate carries on lap mm as a tongue with
// no walls, and the upper's walls carry on lap mm with no back plate, so the
// upper sits over the tongue. The tape does the holding; the lap only keeps
// them in line. Set lower_run so the lower piece — lower_run + lap + cap_h/2
// tall — and upper_run both stay under 205.
//
// PRINTED FACE DOWN. flip = true (the default) turns each piece over so the
// front face, chamfers and all, is on the bed and the plug stands up off the
// back of the cap. flip = false draws it the way it goes on the wall: x to
// the right, y up, z out of the wall, the wall at z = 0, the hole's centre
// at the origin.
//
// COUPON. show = "cap" is the cap and plug alone, with the wire slot from
// its edge — print that first: if the plug will not go in, drop plug_rib;
// if it does not hold, raise it or plug_depth.

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

/* [Raceway] */
rw_w    = 8.0;   // across (mm)
rw_h    = 3.6;   // off the wall; also the cap's thickness (mm)
rw_back = 1.0;   // back plate, under the wire (mm)
slot_w  = 4.2;   // the slot, at the wire (mm)
mouth_w = 3.4;   // the slot, between the lips (mm)
lip_t   = 0.6;   // the lips (mm)
rw_ch   = 0.8;   // chamfer on every front edge, 45 deg (mm)

/* [Cap] */
cap_w      = 42.0;  // across; wide enough that the run lands on the cap, not beside it (mm)
cap_margin = 6.5;   // past the far edge of a screw hole, above and below (mm)
cap_r      = 8.0;   // corner radius (mm)

/* [Plug] */
plug_depth = 14.0;  // into the hole; the old one went 8 (mm)
plug_rib   = 0.3;   // crush ribs proud of the hole's size, per side (mm)
rib_w      = 1.2;   // (mm)
plug_lead  = 1.0;   // chamfer on the plug's leading edge (mm)
groove_d   = 2.0;   // the wire groove down the plug's side, deep (mm)

/* [Quality] */
$fn = 48;

eps = 0.01;

// ---- derived ---------------------------------------------------------------

upper_run = run_len - lower_run;
cap_h     = hole_h + 2 * (screw_off + cap_margin);   // 52.0
cap_t     = rw_h;
plug_hw   = hole_w / 2;
plug_hh   = hole_h / 2;

assert(rw_back + wire_t + lip_t < rw_h, "the wire does not fit under the lips");
assert(mouth_w < wire_w, "the mouth is wider than the wire: nothing holds it in");
assert(lower_run + lap + cap_h / 2 <= 205 && upper_run <= 205, "a piece is longer than the safe bed");

module rr(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);

// The raceway in section, x across and y out from the wall.
module rw_outer() polygon([
  [-rw_w / 2, 0], [rw_w / 2, 0], [rw_w / 2, rw_h - rw_ch], [rw_w / 2 - rw_ch, rw_h],
  [-rw_w / 2 + rw_ch, rw_h], [-rw_w / 2, rw_h - rw_ch]]);
module rw_slot() polygon([
  [-slot_w / 2, rw_back], [slot_w / 2, rw_back], [slot_w / 2, rw_h - lip_t],
  [mouth_w / 2, rw_h - lip_t], [mouth_w / 2, rw_h + eps], [-mouth_w / 2, rw_h + eps],
  [-mouth_w / 2, rw_h - lip_t], [-slot_w / 2, rw_h - lip_t]]);

// A section, run from y = a to y = b, or from x = a to x = b.
module along_y(a, b) translate([0, b, 0]) rotate([90, 0, 0]) linear_extrude(b - a) children();
module along_x(a, b) rotate([0, 0, -90]) along_y(a, b) children();

// The cap plate, front edges chamfered.
module cap_plate() hull() {
  linear_extrude(cap_t - rw_ch) rr(cap_w, cap_h, cap_r);
  translate([0, 0, cap_t - eps]) linear_extrude(eps) offset(delta = -rw_ch) rr(cap_w, cap_h, cap_r);
}

// The plug, hanging below z = 0: the hole's section, ribbed, with a lead-in.
module plug() {
  mirror([0, 0, 1]) {
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
}
// A rib on a face at p, standing out by v, span s along the face; z down.
module rib(p, v, s) hull() {
  translate([p[0] + v[0] / 2, p[1] + v[1] / 2, (plug_depth - plug_lead) / 2])
    cube([max(abs(v[0]), s[0]) + eps, max(abs(v[1]), s[1]) + eps, plug_depth - plug_lead], center = true);
  translate([p[0], p[1], plug_depth - eps])
    cube([max(eps, s[0]), max(eps, s[1]), eps], center = true);
}

module lower() difference() {
  union() {
    cap_plate();
    plug();
    translate([jog, 0, 0]) along_y(-rw_w / 2, lower_run) rw_outer();
    along_x(0, jog + rw_w / 2) rw_outer();
    // The tongue: back plate only.
    translate([jog - rw_w / 2, lower_run - eps, 0]) cube([rw_w, lap - lap_clr + eps, rw_back]);
  }
  translate([jog, 0, 0]) along_y(-slot_w / 2, lower_run + eps) rw_slot();
  along_x(plug_hw - groove_d, jog + eps) rw_slot();
  translate([plug_hw - groove_d, -slot_w / 2, -plug_depth - eps])
    cube([groove_d + eps, slot_w, plug_depth + rw_back + 2 * eps]);
}

// From y = 0 at the joint to upper_run at the doorbell; no back plate over
// the first lap mm, where it sits on the lower's tongue.
module upper() difference() {
  along_y(0, upper_run) rw_outer();
  along_y(-eps, upper_run + eps) rw_slot();
  translate([-rw_w / 2 - eps, -eps, -eps]) cube([rw_w + 2 * eps, lap + eps, rw_back + eps]);
}

// The fit coupon: cap and plug, slot from the cap's right edge to the plug.
module cap_only() difference() {
  union() { cap_plate(); plug(); }
  along_x(plug_hw - groove_d, cap_w / 2 + eps) rw_slot();
  translate([plug_hw - groove_d, -slot_w / 2, -plug_depth - eps])
    cube([groove_d + eps, slot_w, plug_depth + rw_back + 2 * eps]);
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

echo(str("cap ", cap_w, " x ", cap_h, " x ", cap_t, "; plug ", hole_w, " x ", hole_h,
         " + ", plug_rib, " ribs, ", plug_depth, " deep; lower piece ",
         lower_run + lap + cap_h / 2, " tall, upper ", upper_run));
