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
// the BACK of a low ridge rw_w wide and rw_h tall; the front is plain.
// Nothing holds the wire in but the wall — the ridge is laid over the wire
// and taped down by the two rails either side of the groove. (Ziad,
// 2026-09-13: the first draft had the slot on the front, wire showing.)
//
// THE RACEWAY'S EDGES ARE A MILD ROUND, rw_r. It was briefly 18 wide with
// the cap's long blend on each side, and that made it MORE conspicuous, not
// less (Ziad, 2026-09-13); a narrow ridge with softened corners is the
// quieter thing on a wall. The rails are three loops: this is a cosmetic
// cover over a wire that was bare before, not a load path, and Ziad asked
// why the walls were so thick.
//
// THE CAP'S EDGE IS A QUARTER ELLIPSE, cap_round_in deep by cap_round_up
// tall, over a short vertical edge. It had a 6.5 mm half-cosine blend down
// to a two-layer edge for a while — the raceway wore it too, briefly, and
// looked worse for it — then the raceway's 1.2 round, which Ziad found too
// little; this is the middle ("rounded more, but not as flat as it just
// was", 2026-09-13). Vertical where it meets the wall, so it reads as a
// rounded plate rather than a blended one.
//
// THE CAP IS AS THICK AS THE RACEWAY. The old cap was 0.8. Here the groove
// has to cross the cap to reach the plug, and cap and raceway have to share
// one front plateau if the piece is to print face down in one go — a 0.8
// flange under a 3.2 raceway would print in the air. So cap_t = rw_h, and
// the run comes down onto the cap's top edge and the jog happens inside
// the plate, as a turn in the groove, rather than as a visible elbow
// beside it.
//
// THE TURN IS ONE LONG ARC. The groove leaves the vertical run on an arc
// through 45 that arrives at the plug's nearest corner — the top right —
// heading diagonally into it; by default the arc is as big as will still
// reach the corner (about 24 mm radius), so there is no straight and no
// kink anywhere (Ziad, 2026-09-13: the square turn was too tight, then the
// sharp 45 was rounded, then "as gradually as possible").
//
// AND IT GOES IN ON A CHUTE, not over a cliff. It was a notch through the
// plug's corner at full depth: the wire ran flat along the wall and then
// had to turn square down the bore at the hole's very edge (Ziad,
// 2026-09-14: smooth out that step, take the channel farther into the hole
// than the very edge and bring the floor up gradually).
//
// So the channel carries on past the edge and its FLOOR CLIMBS at
// ramp_angle: it leaves the groove where the hole starts, reaches the
// wall's plane a little inside it, and keeps going until it stands
// ramp_depth proud, ramp_run in all. Proud of the wall is only possible
// over the hole, which is the point — the floor is the underside of a
// wedge hanging off the cap's back into the bore, and it presses the wire
// down and in over ramp_run instead of letting it kink at the edge. Off
// the end of the wedge the wire is ramp_depth into the hole already and
// carries on down the hollow on its own.
//
// Two walls plug_wall thick run down either side of the wedge, hanging the
// same ramp_depth, so the whole thing is a chute and the wire cannot wander
// out of it sideways. It stays open downward — into the bore — for its
// whole length, so the wire is still laid into it from the side rather than
// threaded through anything.
//
// The floor must not reach the wall's plane until the channel is clear of
// the hole's edge, or the wire is pinched between the ramp and the wall
// instead of being let into the hole. That is what the ramp_angle assert
// is checking.
//
// THE PLUG IS A SHELL, open to the hole: plug_wall of wall around the hole's
// section and the cap as its front, like the old one but plug_depth deep and
// ribbed. The chute's floor and the two walls beside it fill the top
// ramp_depth of that hollow along the diagonal; everything else is empty,
// and the wire drops into it off the end of the chute.
//
// TWO PIECES, because 255 does not fit a 220 bed. The lower piece is the
// cap, the jog, and lower_run of the vertical; the upper is the rest. They
// meet in a LAP IN PLAN, lap_len long: past lower_run the lower keeps the
// channel's floor and nothing else — a tongue slot_w wide and rw_h - slot_d
// thick — and the upper's first lap_len is its two rails with the socket
// cut clean through between them. Set lower_run so the lower piece —
// lower_run + lap_len + cap_h/2 tall — and upper_run both stay under 205.
//
// The channel runs through unbroken: the tongue IS its floor over the lap,
// at the same slot_d as everywhere else, and the upper's rails are its
// walls. The socket is lap_clr wider than the tongue and lap_clr longer at
// the root, which leaves sock_rail of rail each side of it, and the tip
// butts tight because that is the seam that shows across the face.
//
// ⚠️ IN PLAN, NOT THROUGH THE THICKNESS, and that is the whole reason both
// pieces can print face down. A lap through the thickness gives one piece
// the front of the face and the other the back, and only the front half
// lands on the bed — sliced face down, the back half hangs 0.54 mm in the
// air for the whole lap_len and comes out as bridge. In plan both pieces
// are full depth right down to the bed in their own half of the footprint,
// and nothing anywhere on either piece is unsupported.
//
// What it costs is the lock. A joint split in plan can only be keyed by
// widening the tongue into the rails, and there is not enough rail to do
// it: 1.35 has to cover both the key's ear and the wall beside it, so one
// of the two comes out at 0.4 to 0.8 — which is exactly the 0.8 mm socket
// wall Ziad threw the dovetail out for on 2026-09-14. So the tongue is
// straight. It locates the joint in every direction but one: across, up and
// down, and along the run in compression, where the shoulders butt. Pulling
// the two apart is the glue's job alone, over the tongue's two long faces
// and the two shoulders.
//
// BOTH PIECES PRINT FACE DOWN, front face on the bed. flip = true (the
// default) lays each one out that way. There is no bridge anywhere on
// either piece and the slicer asks for no support: the channel opens
// upward, the tongue and the rails both sit on the plate, and the front
// rounds and the cap's ellipse are the only overhangs — those step out
// about 0.5 mm over the first layer and 0.1 after that, which PETG carries.
// If the cap's edge comes out ragged, slice that one with support.
//
// Getting here took an argument that should have been a slice (2026-09-14).
// Back down, with the lap through the thickness, the upper bridges the
// whole 133 mm of the wire channel in one layer and the sag lands on the
// 0.3 mm the wire has spare in the groove. Face down it bridges nothing.
// Slice it before claiming otherwise.
//
// flip = false draws both the way they go on the wall: x to the right, y
// up, z out of the wall, the wall at z = 0, the hole's centre at the
// origin.
//
// COUPON. show = "cap" is the cap and plug alone, with the groove from its
// edge — print that first: if the plug will not go in, drop plug_rib; if it
// does not hold, raise it or plug_depth.

/* [Output] */
// lower — jog, cap, plug, and the lower part of the vertical run
// upper — the rest of the vertical run
// cap   — cap and plug alone, the fit coupon
// both  — the print plate: both pieces, each the way up it prints, the
//         upper plate_gap off the cap's edge and inside the lower's length
show = "both";  // [lower, upper, cap, both]

// Printed orientation, front face on the bed. false draws it as it mounts.
flip = true;

// Between the two pieces on the "both" plate. They are one object to the
// slicer, so the only thing this has to clear is a brim, if one is used.
plate_gap = 3.0;

/* [Wire — measured] */
wire_t = 1.7;    // wire, thick (mm)
wire_w = 3.8;    // wire, wide (mm)

/* [Hole — measured off the old cap] */
hole_w = 16.0;   // across (mm)
hole_h = 19.0;   // up and down, in line with the screw holes (mm)
hole_r = 3.0;    // the hole's corner radius, from the old plug (mm)
screw_off = 10.0;  // old screw holes, from the hole's edge, above and below (mm)

/* [Run] */
run_len   = 255.0;  // doorbell to the jog's centreline; was 260, Ziad measured the upper piece at 135 (mm)
jog       = 15.0;   // the run's centreline is this far right of the hole (mm)
lower_run = 120.0;  // of run_len, on the lower piece; the rest is the upper (mm)
lap_len   = 12.0;   // the lap, along the run (mm)
lap_clr   = 0.15;   // the socket over the tongue, sideways and at the root; the tip butts (mm)
bend_r    = 0;      // centreline radius of the bend out of the run; 0 = as large as will reach the corner (mm)

/* [Raceway] */
rw_w     = 6.9;   // across: the groove plus a three-loop rail each side; it is a cover, not a beam (mm)
rw_h     = 3.2;   // off the wall; also the cap's thickness at its plateau (mm)
rw_r     = 1.2;   // round on the two front edges; the one Ziad liked, and the most a 1.35 rail can take. 0.8 was a touch crisp; 1.9 was tried on the 8 wide bar (mm)
slot_w   = 4.2;   // the groove, for the wire's 3.8 (mm)
slot_d   = 2.0;   // the groove, for the wire's 1.7; what is left in front is the skin (mm)

/* [Cap] */
cap_left   = 18.5;  // hole centre to the left edge; was 21, Ziad took 2.5 off looking at the front view (mm)
cap_right  = 21.5;  // hole centre to the right edge; the run's edge at jog + rw_w/2 has to land on the flat, inside the round (mm)
cap_margin = 6.5;   // past the far edge of a screw hole, above and below (mm)
cap_r      = 8.0;   // corner radius, in plan (mm)
cap_round_in = 3.0; // the edge round, in from the edge (mm)
cap_round_up = 2.4; // the edge round, up from the wall; what is left below it is a vertical edge (mm)

/* [Plug] */
plug_depth = 14.0;  // into the hole; the old one went 8 (mm)
plug_rib   = 0.3;   // crush ribs proud of the hole's size, per side (mm)
rib_w      = 1.2;   // (mm)
plug_lead  = 1.0;   // chamfer on the plug's leading edge (mm)
plug_wall  = 1.35;  // the shell, three loops on the 0.4 nozzle; it only has to hold the ribs against the hole (mm)

/* [The wire's way into the hole] */
ramp_depth = 5.0;   // how far the channel's floor ends up proud of the wall, inside the hole (mm)
ramp_angle = 40;    // the floor's slope as it comes up; shallower is gentler on the wire, and costs run (deg)

/* [Quality] */
$fn = 48;

eps = 0.01;

// ---- derived ---------------------------------------------------------------

upper_run = run_len - lower_run;
rail_w    = (rw_w - slot_w) / 2;     // 1.35, one rail
sock_rail = rail_w - lap_clr;        // 1.20, what is left of a rail beside the socket
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
// The chute, measured along the diagonal from the plug's corner point. The
// hole's rounded corner crosses that line edge_u in; the channel's floor
// leaves the groove there and climbs the whole ramp_drop — out of the
// groove, through the wall's plane and on into the hole — by ramp_end.
edge_u    = hole_r * (sqrt(2) - 1);
ramp_drop = slot_d + ramp_depth;
ramp_run  = ramp_drop / tan(ramp_angle);
ramp_end  = edge_u + ramp_run;
ramp_x1   = diag_x0 - (diag_len + ramp_end) / sqrt(2);   // where it lets go, in plan
ramp_y1   = diag_y0 - (diag_len + ramp_end) / sqrt(2);
assert(stray < (rw_w - slot_w) / 2 - 0.8, "the bend leaves the raceway before it reaches the cap");

assert(slot_d > wire_t && slot_w > wire_w, "the wire does not fit the groove");
assert(ramp_depth < plug_depth - 2 && ramp_angle > 10 && ramp_angle < 80, "the chute is deeper than the plug, or its slope is silly");
assert(abs(ramp_x1) + slot_w / 2 < plug_hw - plug_wall && abs(ramp_y1) + slot_w / 2 < plug_hh - plug_wall,
       "the chute runs out through the far side of the plug: less ramp_depth, or steepen ramp_angle");
assert(slot_d / tan(ramp_angle) > slot_w / 2,
       "the floor reaches the wall's plane before the channel is clear of the hole's edge: shallower ramp_angle");
assert(2 * rw_r <= rw_w - slot_w && rw_r < rw_h, "rw_r is bigger than the rails");
assert(cap_round_up < cap_t, "cap_round_up is the whole thickness: no edge left");
assert(cap_right >= jog + rw_w / 2 + cap_round_in, "the run's edge lands on the cap's round: widen cap_right");
assert(cap_left > plug_hw + cap_round_in && cap_h / 2 > plug_hh + cap_round_in, "the cap's flat does not clear the plug");
assert(lower_run + lap_len + cap_h / 2 <= 205 && upper_run <= 205, "a piece is longer than the safe bed");
assert(rw_h - slot_d >= 0.8 && lap_len > 4 * lap_clr, "the lap's tongue is too thin, or too short to glue");
assert(sock_rail >= 0.8, "the socket leaves less than two loops of rail beside it");

module rr(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);

// The raceway in section, x across and y out from the wall: a bar with its
// two front corners rounded rw_r.
module rw_outer() polygon(concat(
  [[-rw_w / 2, 0], [rw_w / 2, 0]],
  [for (a = [0 : 10 : 90]) [rw_w / 2 - rw_r + rw_r * cos(a), rw_h - rw_r + rw_r * sin(a)]],
  [for (a = [90 : 10 : 180]) [-rw_w / 2 + rw_r + rw_r * cos(a), rw_h - rw_r + rw_r * sin(a)]]));
// The groove, open to the wall.
module rw_slot() translate([-slot_w / 2, -eps]) square([slot_w, slot_d + eps]);

// A section, run from y = a to y = b, or from x = a to x = b.
module along_y(a, b) translate([0, b, 0]) rotate([90, 0, 0]) linear_extrude(b - a) children();
module along_x(a, b) rotate([0, 0, -90]) along_y(a, b) children();

// The cap plate, centred cap_x right of the hole, its front edge a quarter
// ellipse all round: a hull of slices, each the plate inset and raised
// along the curve. Plate and round are both convex, so one hull is exact.
module cap_plate() translate([cap_x, 0, 0]) hull()
  for (a = [0 : 7.5 : 90])
    linear_extrude(cap_t - cap_round_up + cap_round_up * sin(a))
      offset(delta = -cap_round_in * (1 - cos(a))) rr(cap_w, cap_h, cap_r);

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
// The stock the chute's floor and its two side walls are carved out of: a
// bar down the diagonal standing ramp_depth proud of the cap's back, into
// the hole. Clipped to the plug's own footprint, because material anywhere
// outside it would hold the cap off the wall. diagonal_wire() then takes
// everything below the ramp away and what is left is the floor.
module entry_fill() intersection() {
  translate([0, 0, -ramp_depth]) linear_extrude(ramp_depth) rr(hole_w, hole_h, hole_r);
  translate([diag_x0, diag_y0, 0]) rotate([0, 0, -135])
    translate([diag_len, -(slot_w / 2 + plug_wall), -ramp_depth - eps])
      cube([ramp_end, slot_w + 2 * plug_wall, ramp_depth + 2 * eps]);
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
// top-right corner (none at all at bend_max), and then a CHUTE. The arc's
// centre is bend left of the run, level with where the run's groove ends.
//
// The chute is the channel carried on past the hole's edge with its floor
// falling away at ramp_angle: flush with the wall where the hole starts,
// ramp_depth down by ramp_end, and open to the plug's hollow from there on.
// Before it the wire ran along the wall and then had to turn square down
// the bore at the hole's edge (Ziad, 2026-09-14: smooth out that step, take
// the channel farther in than the very edge and bring the floor up
// gradually). It is still open to the wall for its whole length, so the
// wire is laid into it from the side and not threaded through anything.
module diagonal_wire() {
  translate([jog - bend, bend_y, 0]) rotate([0, 0, -45])
    rotate_extrude(angle = 45 + eps) translate([bend, 0]) rw_slot();
  translate([diag_x0, diag_y0, 0]) rotate([0, 0, -135]) {
    along_x(-eps, diag_len + eps) rw_slot();
    // The chute, in section, everything under the wire: the groove's floor
    // as far as the hole's edge, then the ramp climbing out of the cap and
    // on into the hole, and the whole plug's depth below it so the corner
    // is open and the wire drops off the ramp's end into the hollow.
    translate([0, slot_w / 2, 0]) rotate([90, 0, 0]) linear_extrude(slot_w)
      polygon([[diag_len - hole_r - eps, slot_d],
               [diag_len + edge_u,       slot_d],
               [diag_len + ramp_end,     -ramp_depth],
               [diag_len + ramp_end,     -plug_depth - 1],
               [diag_len - hole_r - eps, -plug_depth - 1]]);
  }
}

// The tongue in plan, from the joint line at y = 0: the channel's own width,
// so the channel's floor carries through the lap unbroken. g grows it
// sideways, tail past its tip. The socket takes g = lap_clr and tail = 0,
// so the tip butts tight — that is the seam that shows across the face. The
// lower cuts round it with g = -eps, so the tongue's sides and the groove's
// walls overlap instead of meeting in a zero-thickness face, and tail = 1
// so the tongue's tip is the bar's own end rather than a cut.
module lap_plan(g, tail) translate([-slot_w / 2 - g, -1])
  square([slot_w + 2 * g, 1 + lap_len + tail]);

module lower() difference() {
  union() {
    cap_plate();
    plug();
    entry_fill();
    translate([jog, 0, 0]) along_y(-rw_w / 2, lower_run + lap_len) rw_outer();
  }
  // Past lower_run everything outside the tongue goes, the whole depth of
  // the bar: the rails there are the upper's, and what is left of the lower
  // is the channel's floor and nothing else.
  translate([jog, lower_run, -1]) linear_extrude(rw_h + 2) difference() {
    translate([-rw_w / 2 - 1, 0]) square([rw_w + 2, lap_len + 2]);
    lap_plan(-eps, 1);
  }
  translate([jog, 0, 0]) along_y(bend_y - eps, lower_run + lap_len + eps) rw_slot();
  diagonal_wire();
}

// From y = 0 at the joint to upper_run at the doorbell. Its first lap_len is
// the two rails with the socket cut clean through between them; the rails
// start lap_clr short so the tongue's tip can butt the socket's end face
// without the two shoulders fighting over the same millimetre.
module upper() difference() {
  along_y(lap_clr, upper_run) rw_outer();
  along_y(lap_clr - eps, upper_run + eps) rw_slot();
  translate([0, 0, -1]) linear_extrude(rw_h + 2) lap_plan(lap_clr, 0);
}

// The fit coupon: cap and plug, with the groove in from the cap's top edge
// the way the run would bring it.
module cap_only() difference() {
  union() { cap_plate(); plug(); entry_fill(); }
  translate([jog, 0, 0]) along_y(min(bend_y, cap_h / 2) - eps, cap_h / 2 + eps) rw_slot();
  diagonal_wire();
}

// Face down for printing. The upper piece never uses it: it prints back
// down, which is how it is already drawn, so it is the same either way.
module oriented() {
  if (flip) translate([0, 0, rw_h]) rotate([180, 0, 0]) children();
  else children();
}

if (show == "lower") oriented() lower();
if (show == "upper") oriented() upper();
if (show == "cap")   oriented() cap_only();
if (show == "both") {
  oriented() lower();
  // Alongside the cap's right edge, plate_gap off it, and hung from the
  // cap's top so the upper sits inside the lower's own length: the head
  // crosses plate_gap between the two and the plate is no longer than the
  // lower piece. It used to sit 12 away and 135 further up the bed, which
  // put the plate 241 long — over the 220 the machine has.
  translate([cap_x + cap_w / 2 + plate_gap + rw_w / 2, cap_h / 2, 0]) oriented() upper();
}

echo(str("cap ", cap_w, " x ", cap_h, " x ", cap_t, " (", cap_left, " left of the hole, ", cap_right, " right); plug ", hole_w, " x ", hole_h,
         " + ", plug_rib, " ribs, ", plug_depth, " deep; lower piece ",
         lower_run + lap_len + cap_h / 2, " tall, upper ", upper_run,
         "; lap ", lap_len, " long, tongue ", slot_w, " x ", rw_h - slot_d,
         " in a socket ", lap_clr, " looser, ", sock_rail, " of rail each side of it"));
