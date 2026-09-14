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
// meet in a LAP THROUGH THE FACE, lap_len long, ONE BEHIND THE OTHER: the
// face — what is left in front of the groove, rw_h - slot_d = 1.2, ten
// layers at the 0.12 this gets sliced at — splits down its thickness, the
// lower keeping the front lap_face of it and the upper the back tenon_t
// along with its two rails. Both halves are the full 6.9 across and they
// glue face to face over the whole of it. Set lower_run so the lower piece
// — lower_run + lap_len + cap_down tall — and upper_run both stay under 205.
//
// The wire channel runs through unchanged: over the lap its floor is the
// upper's own half of the face, at the same slot_d as everywhere else, and
// its walls are the upper's rails.
//
// Two seams show. The front one, where the lower's tongue ends and the
// upper's face takes over, is butted tight. The other is on the wall side
// at the lower's shoulder, held lap_clr open so the first one can close.
//
// AND THE LAP IS TENONED, so the two lock rather than just butt (Ziad,
// 2026-09-14: one bit should embed in the other). Halfway along it the
// lower's tongue carries a pad key_w x key_len, key_r round in plan,
// standing tenon_t off its back — exactly filling the upper's half of the
// face — and the upper has the matching mortise through that half, key_clr
// looser all round. It is caught on all four sides: pull the joint along
// the run or push it across and the tenon has to shear, not just the glue.
//
// Nothing in it is thin. The tenon is a 5 x 4 x 0.66 pad on a 0.54 tongue;
// what is left of the upper's face beside the mortise is 0.8 wide, and that
// sits on top of a rail for its whole length rather than standing free.
//
// ⚠️ lap_face is 0.54 and not the 0.6 that would split the face evenly,
// for two reasons either of which would do it on its own. The lower's
// tongue lies flat on the bed, so its thickness is a layer count, and 0.54
// is the 0.3 first layer plus two of 0.12. And 0.6 puts the split plane at
// z = 2.6, which is exactly a vertex of the faceted front round — the round
// is centred at z = slot_d with r = rw_r and steps 10°, so a = 30 lands on
// 2.0 + 0.6 — and a cut through a profile vertex came back with four edges
// shared by four facets each. Move lap_face and check the mesh, not just
// the render.
//
// BOTH PIECES PRINT FACE DOWN, front face on the bed. flip = true (the
// default) lays each one out that way. That keeps the wire channel opening
// upward on both, which is the whole point: printed the other way up, back
// down, the upper bridges the entire 133 mm of the channel in one layer and
// the sag lands on the 0.3 mm the wire has spare in the groove.
//
// ⚠️ THE UPPER'S HALF OF THE LAP NEEDS SUPPORT. Its back half of the face
// starts lap_face off the bed and hangs there for the whole lap_len — the
// price of a lap one behind the other rather than side by side, and Ziad's
// call, 2026-09-14, over a joint split in plan. Sliced with support on, it
// is a 10 x 18 pad two layers tall, 0.04 g, tucked under that one tab with
// a 0.15 gap over it; nothing else on the plate asks for any. Slice it with
// supports enabled or that tab prints as a 12 mm cantilever, and its
// underside is the glue face.
//
// Otherwise nothing is unsupported: the front rounds and the cap's ellipse
// step out about 0.5 mm over the first layer and 0.1 after that, which PETG
// carries. If the cap's edge comes out ragged, slice that one with support
// too — and slice it before claiming how any of this prints (2026-09-14:
// three turns were spent arguing that from memory and all of it was wrong).
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
lap_clr   = 0.15;   // the upper's rails stop this short of the lower's shoulder (mm)
lap_face  = 0.54;   // of the face's 1.2, what the lower keeps over the lap; the upper carries the rest. Three layers on the bed at 0.3 + 2 x 0.12, and it misses the facet vertex that sits exactly at 0.6 (mm)
key_w     = 5.0;    // the tenon across (mm)
key_len   = 4.0;    // the tenon along the run (mm)
key_r     = 1.0;    // its corners in plan, so a printed corner cannot hold it off its seat (mm)
key_clr   = 0.15;   // the mortise over the tenon, all round (mm)
bend_r    = 22.0;   // centreline radius of the bend out of the run; 0 = as large as will reach the corner, 23.9. Held at 22 since the cap's top came in to 21: any bigger and the arc has wandered more than 0.55 off the run's centreline by the time it crosses that edge, and the assert below catches it (mm)

/* [Raceway] */
rw_w     = 6.9;   // across: the groove plus a three-loop rail each side; it is a cover, not a beam (mm)
rw_h     = 3.2;   // off the wall; also the cap's thickness at its plateau (mm)
rw_r     = 1.2;   // round on the two front edges; the one Ziad liked, and the most a 1.35 rail can take. 0.8 was a touch crisp; 1.9 was tried on the 8 wide bar (mm)
slot_w   = 4.2;   // the groove, for the wire's 3.8 (mm)
slot_d   = 2.0;   // the groove, for the wire's 1.7; what is left in front is the skin (mm)

/* [Cap] */
// The four edges, each from the hole's centre. Ziad trimmed three of them
// on 2026-09-14, reading the front view: 5 off the left, 5 off the top, and
// the right edge in flush with the channel instead of 3 proud of it.
cap_left   = 13.5;            // was 18.5, and 21 before that (mm)
cap_right  = jog + rw_w / 2 + 0.02;  // flush with the channel's right face, bar two hundredths so the two are not exactly coplanar — coplanar faces are what the mesh trips over; was 21.5 (mm)
cap_up     = 21.0;            // was 26 = hole_h/2 + screw_off + 6.5 of margin; this leaves 1.5 past the upper screw hole (mm)
cap_down   = 26.0;            // hole_h/2 + screw_off + 6.5 of margin (mm)
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
blend_steps = 12;  // slices in the blend where the bar grows out of the cap

eps = 0.01;

// ---- derived ---------------------------------------------------------------

upper_run = run_len - lower_run;
rail_w    = (rw_w - slot_w) / 2;     // 1.35, one rail
split_z   = rw_h - lap_face;         // 2.66, where the lap splits the face
tenon_t   = split_z - slot_d;        // 0.66, the tenon's own thickness
key_y     = (lap_len - key_len) / 2; // the tenon's start, from the joint line
cap_h     = cap_up + cap_down;                        // 47.0
cap_w     = cap_left + cap_right;                     // 31.95
cap_x     = (cap_right - cap_left) / 2;               // the cap's centre, right of the hole
cap_y     = (cap_up - cap_down) / 2;                  // and below it, now the top is cut
// Where the raceway's bar starts, up the cap. Below the cap's top edge the
// cap IS the cover — it is the same rw_h thick and shares the front plateau
// — so the bar down there was a ridge for nothing, and it took the cap's
// rounded right edge with it: flush with the channel, the bar's own square
// side replaces that round wherever the bar exists, and it used to run down
// to -rw_w/2, stopping the round well before it reached the chute (Ziad,
// 2026-09-14). One short of where the cap's top-right corner starts to
// curve, so the bar's end face still lands on the straight part of the edge
// and nothing jinks out past the plan outline.
bar_start = cap_up - cap_r - 1;                       // 12.0
blend_len = 8.0;                                      // and it takes this far to grow to full section
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
stray     = bend_y > cap_up ? bend - sqrt(bend * bend - pow(bend_y - cap_up, 2)) : 0;
// The chute, measured along the diagonal from the plug's corner point. The
// hole's rounded corner crosses that line edge_u in; the channel's floor
// leaves the groove there and climbs the whole ramp_drop — out of the
// groove, through the wall's plane and on into the hole — by ramp_end.
edge_u    = hole_r * (sqrt(2) - 1);
ramp_drop = slot_d + ramp_depth;
ramp_run  = ramp_drop / tan(ramp_angle);
ramp_end  = edge_u + ramp_run;
// The floor has to run out THROUGH the underside of its own stock and not
// exactly at the far corner of it, or the wedge tapers to a knife edge on
// the very line where three surfaces already meet, and the mesh comes back
// with four facets to an edge. So the stock runs fill_tail past where the
// floor reaches depth, and the cut carries on down the same slope past that.
fill_tail = 2.0;
fill_end  = ramp_end + fill_tail;
ramp_far  = fill_end + 1;
ramp_farz = slot_d - (ramp_far - edge_u) * tan(ramp_angle);
ramp_x1   = diag_x0 - (diag_len + fill_end) / sqrt(2);   // the chute's far end, in plan
ramp_y1   = diag_y0 - (diag_len + fill_end) / sqrt(2);
assert(stray < (rw_w - slot_w) / 2 - 0.8, "the bend leaves the raceway before it reaches the cap");

assert(slot_d > wire_t && slot_w > wire_w, "the wire does not fit the groove");
assert(ramp_depth < plug_depth - 2 && ramp_angle > 10 && ramp_angle < 80, "the chute is deeper than the plug, or its slope is silly");
assert(abs(ramp_x1) + slot_w / 2 < plug_hw - plug_wall && abs(ramp_y1) + slot_w / 2 < plug_hh - plug_wall,
       "the chute runs out through the far side of the plug: less ramp_depth, or steepen ramp_angle");
assert(slot_d / tan(ramp_angle) > slot_w / 2,
       "the floor reaches the wall's plane before the channel is clear of the hole's edge: shallower ramp_angle");
assert(2 * rw_r <= rw_w - slot_w && rw_r < rw_h, "rw_r is bigger than the rails");
assert(cap_round_up < cap_t, "cap_round_up is the whole thickness: no edge left");
assert(cap_right >= jog + rw_w / 2, "the cap's right edge is inside the channel's");
assert(bar_start < cap_up - cap_r && bar_start > plug_hh,
       "the bar starts on the cap's plan corner, or down over the plug");
assert(bar_start + blend_len <= cap_up, "the bar is still growing when it leaves the cap");
assert(cap_left > plug_hw + cap_round_in && cap_right > plug_hw + cap_round_in
       && cap_up > plug_hh + cap_round_in && cap_down > plug_hh + cap_round_in,
       "the cap's flat does not clear the plug on one of its four sides");
assert(cap_up >= hole_h / 2 + screw_off && cap_down >= hole_h / 2 + screw_off,
       "the cap no longer reaches a screw hole");
assert(lower_run + lap_len + cap_down <= 205 && upper_run <= 205, "a piece is longer than the safe bed");
assert(rw_h - slot_d >= 0.8 && lap_len > 4 * lap_clr, "the lap's tongue is too thin, or too short to glue");
assert(lap_face >= 0.5 && tenon_t >= 0.5, "the lap splits the face too thin on one side");
assert(key_y > key_clr + 1.0 && rw_w - key_w - 2 * key_clr >= 1.6, "the mortise leaves too little face around the tenon");

module rr(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);

// The raceway in section, x across and y out from the wall: a bar whose two
// front edges are a quarter ellipse rin in by rup up. At rw_r, rw_r that is
// a plain round, which is what the run wears; the blend out of the cap
// sweeps it from the cap's own ellipse to that. Keep the 10 degree step:
// lap_face is chosen to miss the vertex it puts at z = 2.6.
function rw_pts(rin, rup) = concat(
  [[-rw_w / 2, 0], [rw_w / 2, 0]],
  [for (a = [0 : 10 : 90]) [rw_w / 2 - rin * (1 - cos(a)), rw_h - rup + rup * sin(a)]],
  [for (a = [90 : 10 : 180]) [-rw_w / 2 + rin * (1 + cos(a)), rw_h - rup + rup * sin(a)]]);
module rw_edge(rin, rup) polygon(rw_pts(rin, rup));
module rw_outer() rw_edge(rw_r, rw_r);

// Where the bar grows out of the cap. Butting the two edge treatments
// against each other left a 1.8 mm step in the front plateau, the cap's
// ellipse 3.0 in and the bar's round only 1.2 (Ziad, 2026-09-14: make a
// smoother transition from one arc to the other). So the section is swept
// from one to the other over blend_len on a cosine, which is flat at both
// ends and leaves no crease where the blend meets either. It starts 0.15
// rounder than the cap's own edge so the first slice is strictly inside the
// plate rather than coincident with its surface.
function blend_t(i)  = (1 - cos(180 * i / blend_steps)) / 2;
function blend_in(i) = cap_round_in + 0.15 + (rw_r - cap_round_in - 0.15) * blend_t(i);
function blend_up(i) = cap_round_up + 0.15 + (rw_r - cap_round_up - 0.15) * blend_t(i);
//
// One polyhedron and not a chain of hulls: chained hulls share a slice, so
// consecutive ones meet on identical cross-sections and the mesh came back
// with 40-odd edges carrying four facets. Skinned by hand there are no
// internal faces at all.
// The station list runs one past the blend, at the run's own profile, so the
// whole bar from the cap to the lap is this one solid. Handing the last of
// it to a separate along_y() put two prisms with the same outer rectangle
// over the top of each other, and every one of their four sides was then a
// coplanar pair.
function blend_y(j) = j <= blend_steps ? bar_start + blend_len * j / blend_steps
                                       : lower_run + lap_len;
function blend_rin(j) = j <= blend_steps ? blend_in(j) : rw_r;
function blend_rup(j) = j <= blend_steps ? blend_up(j) : rw_r;
module lower_bar() {
  n   = blend_steps + 1;
  pts = [for (j = [0 : n]) rw_pts(blend_rin(j), blend_rup(j))];
  np  = len(pts[0]);
  polyhedron(
    points = [for (j = [0 : n], k = [0 : np - 1])
                [pts[j][k][0], blend_y(j), pts[j][k][1]]],
    faces = concat(
      // ends first, then the skin. OpenSCAD wants every face clockwise seen
      // from outside, which is the reverse of the profile's own order at the
      // near end and the same as it at the far one.
      [[for (k = [np - 1 : -1 : 0]) k]],
      [[for (k = [0 : np - 1]) n * np + k]],
      [for (j = [0 : n - 1], k = [0 : np - 1])
         let (k2 = (k + 1) % np)
         [j * np + k, j * np + k2, (j + 1) * np + k2, (j + 1) * np + k]]),
    convexity = 6);
}
// The groove, open to the wall.
module rw_slot() translate([-slot_w / 2, -eps]) square([slot_w, slot_d + eps]);

// A section, run from y = a to y = b, or from x = a to x = b.
module along_y(a, b) translate([0, b, 0]) rotate([90, 0, 0]) linear_extrude(b - a) children();
module along_x(a, b) rotate([0, 0, -90]) along_y(a, b) children();

// The cap plate, centred cap_x right of the hole and cap_y above it, its front edge a quarter
// ellipse all round: a hull of slices, each the plate inset and raised
// along the curve. Plate and round are both convex, so one hull is exact.
module cap_plate() translate([cap_x, cap_y, 0]) hull()
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
      cube([fill_end, slot_w + 2 * plug_wall, ramp_depth + 2 * eps]);
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
               [diag_len + ramp_far,     ramp_farz],
               [diag_len + ramp_far,     -plug_depth - 1],
               [diag_len - hole_r - eps, -plug_depth - 1]]);
  }
}

// The tenon in the middle of the lap: a pad key_w x key_len standing off the
// back of the lower's half of the face and filling the upper's half, its
// corners rounded key_r. g grows it all round for the mortise; o takes it o
// past the face's two planes at both ends, into space that is void either
// way — a cut left flush with a face leaves a zero-thickness facet behind
// and the mesh comes back a genus out.
module lap_tenon(y0, g, o)
  translate([0, y0 + key_len / 2, slot_d - o])
    linear_extrude(tenon_t + 2 * o) offset(delta = g) rr(key_w, key_len, key_r);

module lower() {
  difference() {
    union() {
      cap_plate();
      plug();
      entry_fill();
      translate([jog, 0, 0]) lower_bar();
    }
    // Past lower_run the lower keeps only the front lap_face of the face,
    // full width and rounds and all; the upper carries the rest of it.
    translate([jog - rw_w / 2 - 1, lower_run, -1])
      cube([rw_w + 2, lap_len + 1, split_z + 1]);
    translate([jog, 0, 0]) along_y(bend_y - eps, lower_run + eps) rw_slot();
    diagonal_wire();
  }
  // Then the tenon goes back on, outside the cut that took the rest away.
  translate([jog, 0, 0]) lap_tenon(lower_run + key_y, 0, eps);
}

// From y = 0 at the joint to upper_run at the doorbell. Over the first
// lap_len it keeps the back tenon_t of the face and both rails, and that
// half of the face is the tab that hangs: it starts lap_face off the plate
// and needs support under it.
module upper() difference() {
  along_y(lap_clr, upper_run) rw_outer();
  along_y(lap_clr - eps, upper_run + eps) rw_slot();
  translate([-rw_w / 2 - 1, -eps, split_z])
    cube([rw_w + 2, lap_len + eps, rw_h - split_z + 1]);
  lap_tenon(key_y, key_clr, eps);
}

// The fit coupon: cap and plug, with the groove in from the cap's top edge
// the way the run would bring it.
module cap_only() difference() {
  union() { cap_plate(); plug(); entry_fill(); }
  translate([jog, 0, 0]) along_y(min(bend_y, cap_up) - eps, cap_up + eps) rw_slot();
  diagonal_wire();
}

// Face down for printing, turned over about the LONG axis and not the short
// one. Either turn puts the face on the bed; about X it also stands the run
// on its head, so every render of the plate came out upside down, cap at the
// top and the run going away from the doorbell (Ziad, 2026-09-14). About Y
// the run still goes up the picture the way it goes up the wall, and what
// swaps instead is left for right — which is what turning a thing over to
// look at its back does anyway.
module oriented() {
  if (flip) translate([0, 0, rw_h]) rotate([0, 180, 0]) children();
  else children();
}

if (show == "lower") oriented() lower();
if (show == "upper") oriented() upper();
if (show == "cap")   oriented() cap_only();
if (show == "both") {
  oriented() lower();
  // Alongside the cap, plate_gap off its far edge, and hung from the top of
  // the run so the upper sits inside the lower's own length: the head
  // crosses plate_gap between the two and the plate is no longer than the
  // lower piece. It used to sit 12 away and 135 further up the bed, which
  // put the plate 241 long — over the 220 the machine has. The cap's edge
  // is at -cap_x + cap_w/2 and not +cap_x, because oriented() has turned
  // the lower over about Y and swapped its left for its right.
  translate([-cap_x + cap_w / 2 + plate_gap + rw_w / 2,
             lower_run + lap_len - upper_run, 0]) oriented() upper();
}

echo(str("cap ", cap_w, " x ", cap_h, " x ", cap_t, " (", cap_left, " left of the hole, ", cap_right, " right, ", cap_up, " up, ", cap_down, " down); plug ", hole_w, " x ", hole_h,
         " + ", plug_rib, " ribs, ", plug_depth, " deep; lower piece ",
         lower_run + lap_len + cap_down, " tall, upper ", upper_run,
         "; lap ", lap_len, " long, the face split ", lap_face, " to the lower and ",
         tenon_t, " to the upper, tenon ", key_w, " x ", key_len, " x ", tenon_t,
         ", ", (rw_w - key_w) / 2 - key_clr, " of face each side of its mortise"));
