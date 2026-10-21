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
// above and below it. The plug here is a shell, plug_depth deep, with
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
// quieter thing on a wall. After printing, Ziad found the cover too
// delicate; the face and rails are now thicker (2026-09-15).
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
// flange under a taller raceway would print in the air. So cap_t = rw_h, and
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
// TWO PIECES, WITH A THREE-SIDED LAP. The lower keeps the front face and
// an outer cheek on each side; the upper nests inside that U, keeping the
// inner half of each rail and the back half of the face. Glue the broad
// face AND both long side faces. The 0.15 side clearance is for glue and
// fit; the face seats directly. A rounded key still locates the joint.
//
// The whole rail is 2.73 thick; over the lap each piece keeps 1.29, with
// 0.15 between them. The face is 2.28 thick and splits into two 1.14
// sections. The wire groove stays 4.2 x 2.0 through the assembled joint.
// Assemble from the open back of the lower's U before fitting to the wall.
//
// The joint starts at the first whole millimetre past the wire's bend,
// 5 mm above the cap. The upper is 229 mm long, so both pieces print face
// down on a 45-degree plate layout inside the 205 mm safe bed square.
// The upper's lap still hangs above the bed and needs local support.
//
// A stronger glued joint carries the run into the cap; holding the complete
// cover against the wall still depends on its mounting, not this joint.
//
// EXCEPT AT THE TOP, WHERE THE DOORBELL ITSELF NOW HOLDS IT. Two strips
// tab_t thick — two 0.20 layers, the height this prints at — carry on
// tab_len past the upper's doorbell end and slide between the wall and
// the doorbell's own mounting plate, so its screws trap the top of the
// cover (Ziad, 2026-09-15).
//
// They are the rails' own footprint AT THE WALL'S PLANE, z = 0 to tab_t,
// and they have to be: behind the mount means between the mount and the
// wall, and anything at the front plateau instead would sit rw_h off the
// wall and reach behind nothing. Printing face down, the wall's plane is
// the TOP of the print, so the strips are a two-layer cantilever off the
// end and want the same local support the upper's lap already needs.
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
//         upper plate_gap off the cap's edge, both diagonal on the bed
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "both";  // [lower, upper, cap, both]

// Printed orientation, front face on the bed. false draws it as it mounts.
flip = true;

// Between the two pieces on the "both" plate. They are one object to the
// slicer, so the only thing this has to clear is a brim, if one is used.
plate_gap = 3.0;
plate_angle = 45;  // diagonal layout so the joint can sit next to the cap (deg)
bed_safe = 205;    // safe square from the printer design reference (mm)

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
lower_run = 0;      // 0 = immediately after the bend; positive overrides joint position (mm)
lap_len   = 16.0;   // the lap, along the run (mm)
lap_clr   = 0.15;   // clearance at the rear shoulder (mm)
side_clr  = 0.15;   // glue clearance between the overlapping rail halves (mm)
side_wall = 1.29;   // lower outer cheek, three extrusion paths (mm)
lap_face  = 1.14;   // lower face: 0.30 first layer + seven 0.12 layers (mm)
key_w     = 4.8;    // tenon width, leaves 0.84 beside its mortise (mm)
key_len   = 6.0;    // tenon length (mm)
key_r     = 1.0;    // its corners in plan, so a printed corner cannot hold it off its seat (mm)
key_clr   = 0.15;   // the mortise over the tenon, all round (mm)
bend_r    = 22.0;   // retain the fitted bend; 0 = largest radius that reaches the hole's corner (mm)

/* [Doorbell mount tabs] */
// Off the upper's doorbell end only, at the wall plane. Thin on purpose:
// the strips shim under the doorbell's mounting plate and must not hold it
// off the wall.
tab_len = 30.0;   // how far they stick out past the end of the run; long on
                  // purpose, Ziad will cut them back to whatever the mount
                  // actually covers (2026-09-15) (mm)
tab_t   = 0.40;   // two layers at the 0.20 height this part prints at (mm)

/* [Raceway] */
rw_w     = 9.66;  // 4.2 groove + two 2.73 rails, each 1.29 + 0.15 + 1.29 at the lap (mm)
rw_h     = 4.28;  // 2.0 groove + 2.28 face; cap shares this plateau (mm)
rw_r     = 1.2;   // retain the mild round on the two front edges (mm)
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

socket_w  = rw_w - 2 * side_wall;
tongue_w  = socket_w - 2 * side_clr;
tongue_rail = (tongue_w - slot_w) / 2;
rail_w    = (rw_w - slot_w) / 2;     // one complete rail
split_z   = rw_h - lap_face;         // where the lap splits the face
tenon_t   = split_z - slot_d;        // upper face and key thickness
key_y     = (lap_len - key_len) / 2; // the tenon's start, from the joint line
cap_h     = cap_up + cap_down;                        // 47.0
cap_w     = cap_left + cap_right;                     // 33.35
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
joint_y   = lower_run > 0 ? lower_run : ceil(bend_y + eps);
upper_run = run_len - joint_y;
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
// The rotated plate's footprint, from the two pieces' OWN plan rectangles
// rather than from one rectangle drawn round the pair. The crude version
// was a 41 x 259 box, which at 45 needs 212 mm and fails the bed check —
// but the plate is not a box: it is a 259 mm bar with a 33 mm cap sitting
// beside one end of it, and rotating each piece's four corners puts the
// real need at 194 x 190. That difference is what let the mount tabs grow
// to 30 mm (2026-09-15). Each rectangle is the piece as print_plate lays
// it down, flip and offset included.
plate_lo  = flip ? [-cap_right, -cap_down, cap_left, joint_y + lap_len]
                 : [-cap_left, -cap_down, cap_right, joint_y + lap_len];
plate_updx = (flip ? 1 : -1) * (cap_left + plate_gap + rw_w / 2);
plate_updy = joint_y + lap_len - upper_run;
plate_up  = [plate_updx - rw_w / 2, plate_updy + lap_clr,
             plate_updx + rw_w / 2, plate_updy + upper_run + tab_len];
plate_pts = [for (r = [plate_lo, plate_up],
                  c = [[r[0], r[1]], [r[2], r[1]], [r[2], r[3]], [r[0], r[3]]])
               [c[0] * cos(plate_angle) - c[1] * sin(plate_angle),
                c[0] * sin(plate_angle) + c[1] * cos(plate_angle)]];
plate_x = max([for (p = plate_pts) p[0]]) - min([for (p = plate_pts) p[0]]);
plate_y = max([for (p = plate_pts) p[1]]) - min([for (p = plate_pts) p[1]]);
assert(plate_x <= bed_safe && plate_y <= bed_safe, "the rotated layout exceeds the safe bed");
assert(joint_y > bend_y && joint_y + lap_len < run_len, "the joint cuts into the bend or past the run");
assert(side_wall >= 1.29 && tongue_rail >= 1.29 - eps && side_clr > 0,
       "the side lap leaves a rail half too thin");
assert(rw_h - slot_d >= 0.8 && lap_len > 4 * lap_clr, "the lap's tongue is too thin, or too short to glue");
assert(lap_face >= 1.0 && tenon_t >= 1.0, "the lap splits the face too thin on one side");
assert(key_y > key_clr + 1.0 && tongue_w - key_w - 2 * key_clr >= 1.68 - eps, "the mortise leaves too little face around the tenon");
assert(tab_t > 0 && tab_t < slot_d && tab_len > 0, "the mount tabs are thicker than the groove's floor, or have no length");

module rr(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);

// The raceway in section, x across and y out from the wall: a bar whose two
// front edges are a quarter ellipse rin in by rup up. At rw_r, rw_r that is
// a plain round, which is what the run wears; the blend out of the cap
// sweeps it from the cap's own ellipse to that.
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
                                       : joint_y + lap_len;
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
  // End exactly at the tangent. The straight cutter already overlaps in Y;
  // overshooting the angle makes a sub-micron crescent that collapses in STL.
  translate([jog - bend, bend_y, 0]) rotate([0, 0, -45])
    rotate_extrude(angle = 45) translate([bend, 0]) rw_slot();
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
    // Open socket: leave the front face AND both outer cheeks to glue.
    translate([jog - socket_w / 2, joint_y, -eps])
      cube([socket_w, lap_len + eps, split_z + eps]);
    translate([jog, 0, 0]) along_y(bend_y - eps, joint_y + eps) rw_slot();
    diagonal_wire();
  }
  // Then the tenon goes back on, outside the cut that took the rest away.
  translate([jog, 0, 0]) lap_tenon(joint_y + key_y, 0, eps);
}

// The two mounting strips, off the far end of the upper: each rail's own
// plan footprint, tab_t deep from the wall's plane, carried tab_len past
// the end of the run so it can go behind the doorbell's mount. They lap
// eps back into the end face so the union is a solid overlap and not two
// solids touching on a plane.
module upper_tabs() for (sx = [-1, 1])
  translate([sx * (slot_w + rail_w) / 2, upper_run + (tab_len - eps) / 2, tab_t / 2])
    cube([rail_w, tab_len + eps, tab_t], center = true);

// From y = 0 at the joint to upper_run at the doorbell, plus the two mount
// strips past that. The tongue has the inner half of both rails as well as
// the back half of the face.
module upper() {
  difference() {
    along_y(lap_clr, upper_run) rw_outer();
    along_y(lap_clr - eps, upper_run + eps) rw_slot();
    translate([-rw_w / 2 - eps, -eps, split_z])
      cube([rw_w + 2 * eps, lap_len + eps, lap_face + eps]);
    for (sx = [-1, 1])
      translate([sx > 0 ? tongue_w / 2 : -rw_w / 2 - eps, -eps, -eps])
        cube([(rw_w - tongue_w) / 2 + eps, lap_len + eps, rw_h + 2 * eps]);
    lap_tenon(key_y, key_clr, eps);
  }
  upper_tabs();
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

module print_plate() rotate([0, 0, plate_angle]) {
  oriented() lower();
  // Match the top ends, with a clear gap beside the cap in either view.
  translate([flip ? cap_left + plate_gap + rw_w / 2
                  : -cap_left - plate_gap - rw_w / 2,
             joint_y + lap_len - upper_run, 0]) oriented() upper();
}






echo(str("cap ", cap_w, " x ", cap_h, " x ", cap_t,
         "; channel ", rw_w, " x ", rw_h, "; groove ", slot_w, " x ", slot_d,
         "; joint starts ", joint_y - cap_up, " above cap, overlap ", lap_len,
         "; lower length ", joint_y + lap_len + cap_down, "; upper length ", upper_run,
         "; face halves ", lap_face, " / ", tenon_t,
         "; side halves ", side_wall, " / ", tongue_rail, ", glue gap ", side_clr,
         "; mount tabs ", rail_w, " x ", tab_len, " x ", tab_t,
         "; rotated plate ", plate_x, " x ", plate_y));

// Assembly display changes placement only; the original output remains the default.
module feral_default_output_40c9ec101aa3() {
if (show == "lower") oriented() lower();
if (show == "upper") rotate([0, 0, plate_angle]) oriented() upper();
if (show == "cap")   oriented() cap_only();
if (show == "both")  print_plate();
}

module feral_assembly_view_40c9ec101aa3(explode=false) {
color("SlateGray") lower();
color("SteelBlue") translate([jog,joint_y+(explode ? 35 : 0),0]) upper();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_40c9ec101aa3();
else feral_assembly_view_40c9ec101aa3(view == "exploded");
