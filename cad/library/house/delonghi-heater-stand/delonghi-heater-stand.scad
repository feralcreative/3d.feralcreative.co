// De'Longhi panel heater stand.
//
// The heater normally stands on its bottom; this stands it on its side. Ziad
// traced the edge that goes into the stand, in section, in
// "_incoming/Asset 1.svg": a flat line 63 wide where the trace stops, two
// curved sides — one straight then curling in, one long slope — meeting at a
// 15 mm flat, 80 mm below. That trace is the whole reason the part exists,
// and it is the only measurement here that came off the heater.
//
// THE FORM. A block with that trace cut down into it from the top, so the
// heater's edge drops into a V: 63 across at the mouth, 15 at the floor, 80
// deep. It is a 2D drawing — the block's outline with the trace taken out of
// it — extruded along the heater's edge, and that is all it is. The V is the
// trace grown by a clearance and carried on above the flat edge along the
// outline's end tangents, since the heater continues past where the trace
// stops and its front is still opening out there (about 4 degrees), so a
// vertical mouth would bind on it. A short chamfer widens the mouth further
// so the heater finds its way in.
//
// THE FRONT IS BENT IN, and that is the one correction the coupon made. Held
// against the heater, the first coupon (v06, 2026-09-16) was right everywhere
// but along the front: the trace has that side as one long, nearly straight
// slope, and on the heater the upper half of it curls in toward the back.
// So the front is left as traced up to a knee, front_knee of the way up,
// and from there bent toward the back so that the tip — where the front
// meets the flat edge — lands front_tip_in to the left of where the trace
// had it, standing at front_tip_lean from vertical when it gets there. The
// shift is horizontal, so the tip stays on the flat edge. Ziad's words, over
// three coupons: the apex at the middle and the tip 5 mm in (v09); a few mm
// more with the apex about 30% up (v10); then the tip was right but the wall
// stood 1-2 mm off the heater around the apex, and the tip should be
// basically vertical (this). That last one is why the bend is a cubic and
// not an arc — see the note on front_d below. The back, the floor and the
// corners are as traced. The mouth's tangent on the front is the tip's
// lean, and the block stops at the trace anyway; only the chamfer sees it.
//
// THE BEND CAME BACK OUT, and that is the third correction — the first one
// off a printed piece rather than a coupon held against the heater. With
// front_tip_in at 8 the mouth measured 54.5 as cut, at the front's lip, and
// the heater forced the printed center open to about 60: a 5 mm
// interference, not a clearance problem. The coupons were gauges pressed
// against the rail's end profile and never a fit test over the panel, and
// the raw trace is 60.2 wide at that lip — within a few tenths of what the
// heater made the print measure. So the trace was right over the stretch the
// wall now covers, and the cubic was carrying the curl too far down the
// wall. front_tip_in is 0.25, which puts the mouth at 61.0, Ziad's number,
// 2026-09-17. Two things follow. The front follows the trace again over its
// whole height, so expect a couple of millimetres of air along its middle,
// where v10 wanted the wall to touch — a V cradles on its floor and its two
// lips and does not need that contact. And if the rail does curl in at the
// top, the curl is above y = 65: off the end of the front wall since
// front_down, and no longer the stand's business. Raising the wall back up
// would bring the bind back with it.
//
// THE BACK IS LEANED IN, and that is the second correction a coupon made.
// Held against the heater, the v13 coupon was right everywhere but low on the
// back, where Ziad saw 1.5 to 2 mm of air. Half a millimetre of that is the
// clearance and is meant to be there, so the trace is out by about 1.25 at
// the floor and by nothing at the flat edge, where the fit is right — which
// is one small angular error in an eyeballed trace, not a local bulge. So the
// back is rotated about the mouth: every traced point from the flat edge down
// to the floor flat's left end moves toward the front by back_floor_in times
// its depth over the full 80, about 0.9 degrees. Being a rotation, it carries
// the corner and the left end of the 15 mm flat with it, which is the part
// worth understanding: it says the heater's tip flat is really 13.7 wide and
// the trace put its left edge 1.3 too far back, so the heater keeps the seat
// it already has — tip on the floor, front in contact, which three coupons
// went into getting right — and only the air behind it closes. If instead
// that flat really is 15 wide, the heater will ride about 2 mm higher and the
// front's tuned curve will slide out of register with it; that shows up as
// fresh air along the front, and the answer then is to lean the back without
// moving the corner.
//
// ⚠️ THE MOUTH MAY BE NARROWER THAN THE V JUST BELOW IT, on the front, by the
// amount the echo reports as front_reentry. The heater has the same shape,
// so when that is not zero it is not a rigid drop-in from directly above: it
// goes in with a lean, or slides in along the edge. The clearance and the
// chamfer cover a small one; if it grows, watch that number.
//
// ⚠️ THIS WAS GOT WRONG TWICE, both times from the words "bend the front
// toward the back by 5 mm, apex at the middle". v07 bowed the whole front
// into the V as a fixed-ended arc; v08 bowed it outward. Neither was printed:
// each was caught in a labelled render. What he meant was the tip moving,
// with the bend centered on the middle. Anything that bends here gets a
// labelled render with the old line overlaid before a build.
//
// The block is a trapezoid, wide at the floor and narrower at the mouth,
// because the heater on edge is the best part of a metre tall and the V is
// only 63 wide: the base width is the stability, and a trapezoid gets it
// without printing a slab. Printed as drawn, floor down, the V opening up,
// nothing overhangs — every face either stands or leans back.
//
// TWO TOPS, one per wall. The block's top was flat and level with the trace's
// flat edge until 2026-09-17, when Ziad took front_down off the front and put
// back_up on the back. The V is between the two walls, so there was never one
// top edge to tilt: each wall keeps the same tapering flank and gets its own
// horizontal top, and each lip of the mouth gets its own lead-in chamfer at
// that top rather than the pair sharing one. Three things follow. The back
// wall thins as it rises, because the flank leans in while the V's back is
// plumb — the echo reports the thickness at both tops. The front's lip drops
// to where the traced wall is still opening outward, which takes
// front_reentry to zero: the mouth is the widest part of the V again and the
// heater drops straight in from above. And the added back is drawn plumb, on
// the trace's own end tangent, so the whole of it above the flat edge is an
// assumption about the heater's panel and not a measurement — it is what the
// coupon is for.
//
// ⚠️ NOTHING OF THE STAND MAY STAND AGAINST THE HEATER PAST cool_depth ABOVE
// THE RAIL. The traced edge is the heater's bottom rail and it is cool; above
// where the trace stops, only the rear cool_depth of the heater's thickness is
// the cool back panel, and forward of that is the mesh screen with the hot
// plate behind it. Anything of the stand up there and forward of that line
// cooks. This is why the block's top was level with the rail in the first
// place, and it is what killed the swoop: Ziad had me sweep the end plates'
// step into a curve running from the back's top forward to the front's flank,
// which put 5 mm of PETG above the rail across the heater's full thickness,
// about a millimetre off the end of the mesh (his catch, 2026-09-17, before
// anything was printed).
//
// SO THE OUTLINE'S INNER RUN IS THAT LINE, and the step stands on it: up the
// front flank to the front's top, back along it to cool_depth forward of the
// heater's back panel, up that line to the back's top, out along it, down the
// back flank. The run leans with the panel, parallel to it, because the back
// leans. Both its ends are inside the V, so in the center piece and
// everywhere the V is cut the whole stretch is taken away again and each wall
// simply ends at its own top; the one place it shows is the 5 mm plate
// closing each end, where the section is solid. There the step gets step_r of
// radius at its head and step_fillet in its throat — Ziad's feet are down
// there and a cut edge is a thing to kick. A radius is all the room there is
// for: the fall is 45 with 24 of run behind the line before the back wall's
// own top face, so a sweeping curve is not on offer any more.
//
// THREE SECTIONS, because the heater's edge is 500 long (casters off — they
// come off when it lies on its side) and the bed probes 210. Ziad's plan,
// 2026-09-16: an end piece with a 5 mm wall closing the left end of the V,
// the same at the right, a center between them, and the three joined by
// dovetails printed on the sections themselves — no loose keys, no rails.
// He picked three equal sections over two long ends and a stub, so the two
// ends are one design and its mirror, and every piece is 170.67 long: the
// 500 mm edge, 1 mm of end clearance each side, and the two walls, over
// three. The V is continuous across the joints.
//
// THE JOINT. The center carries two dovetail tabs on each end face, one in
// each shoulder beside the V; the end pieces carry the matching sockets on
// their inner faces. The tabs stand on the floor, tab_h tall, and a socket
// is a slot open at the UNDERSIDE of its piece, roofed at 45 degrees, so the
// end piece is lifted over the center's tab and lowered on. Once it is down
// the tab fills the slot, nothing shows, and the joint is locked in both
// horizontal directions by the dovetail; the only way apart is straight up.
// The tabs sit low on the face because that is where the shoulders are
// widest — the block is a trapezoid and the V is narrowest at its floor —
// and at tab_h = 40 there is over 10 mm of wall on either side of a 20 mm
// head. Higher up, the back shoulder narrows to 16 mm at the top, which is
// why the tab is not full height. The socket's 45-degree roof is there so it
// prints with nothing bridged; the tab's foot is chamfered 0.5 per the
// printer reference's first-layer rule. tab_clear is the printer reference's
// snug-sliding figure for a 0.4 nozzle plus 0.05; the joint coupon is there
// to check it before three big pieces are printed on trust.
//
// The center prints at 194.67 — its nominal length plus a tab each end —
// which is inside the probed bed. Nothing here needs the diagonal.
//
// THE PROFILE is the SVG's one path as an absolute cubic Bezier path, made
// with utils/svg2bez.py and flipped so y is up. The file is in PostScript
// points (72/in) at 1:1 — 226.77 pt is exactly 80 mm — so the conversion is
// a scale and nothing else; the straight runs are degenerate cubics so the
// whole outline is one bezpath. It is drawn here rather than imported: see
// logos/marks.scad for what goes wrong when a part calls import() on an SVG.
//
// BUILDS. The plain build is the assembled stand, for looking at, not for
// printing (it is 512 long). The pieces:
//
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="end-left"'  --name delonghi-heater-stand-end-left
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="end-right"' --name delonghi-heater-stand-end-right
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="center"'    --name delonghi-heater-stand-center
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="coupon"'    --name delonghi-heater-stand-coupon
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="joint-coupon"' --name delonghi-heater-stand-joint-coupon
//
// The end pieces are mirror images, and a mirror image is not a rotation:
// turning the left end round puts the V's front on the back. Both get built.
//
// The coupon is a slice of the section with the outside trimmed away: the V,
// its chamfer and its floor exactly as the stand has them, in a band of
// material just wide enough to hold, to press against the heater's edge and
// see where the trace and the clearance are wrong before printing a litre
// and a half of block around them. It is modelled lying on its face, so the
// outline prints in the plane of the bed and comes out as drawn rather than
// as layer steps. The trace was done by eye; expect to move `clearance`
// after the coupon, not before. A V forgives a lot: if the trace is off the
// heater simply seats a little higher.
//
// Axes: X across the heater's thickness, Z up, Y along the heater's edge.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/beziers.scad>
include <../../../lib/BOSL2/rounding.scad>

/* [Build] */

show = "stand";     // [stand, end-left, end-right, center, coupon, joint-coupon]

/* [Fit] */

clearance = 0.5;    // gap between the traced outline and the V, all round (mm); the trace is by eye, so start loose
cool_depth = 23;    // how far the heater's cool back panel reaches forward of its own back face (mm). Above the rail, nothing of the stand may stand against the heater past this: it is the mesh screen and the hot plate from there forward. Ziad, 2026-09-17
back_floor_in = 1.25; // how far the back comes in at the floor, nothing at the flat edge — the traced back rotated about the mouth (mm). 1.25 is the 1.5-2 of air Ziad saw on the v13 coupon, less the clearance that is meant to be in there
front_tip_in = 0.25; // how far left (toward the back) the front's tip moves, on an arc that starts at the knee (mm). 5 off the v06 coupon, then "a few mm more" off v09, so 8; 0.25 off the printed center, 2026-09-17 — see THE BEND CAME BACK OUT in the header. 0 is the trace as traced
front_knee   = 0.30; // where the bend starts, as a fraction of the front's length up from the floor corner. Was 0.5; Ziad moved it to 0.3 after v09
front_tip_lean = 0;  // the wall's angle from vertical at the tip (deg); positive opens outward like the trace's own 4, negative leans in. Plumb, off the v10 coupon
lead_in   = 2;      // 45-degree chamfer on both lips of the mouth (mm)

/* [Stand] */

heater_len = 500;   // the heater's edge, the one in the V, casters off (mm). Ziad's number, 2026-09-16
end_clear  = 1;     // room between the heater's end and each end wall (mm)
end_wall   = 5;     // the wall closing each end of the V (mm)
sections   = 3;     // equal pieces along the edge; the outer two carry the walls

/* [Joint] */

tab_len   = 12;     // how far a tab stands out of its face (mm)
tab_neck  = 14;     // tab width at the face (mm)
tab_head  = 20;     // tab width at its tip (mm); (head - neck) / 2 over tab_len is the dovetail angle, 14 degrees here
tab_h     = 40;     // tab height off the floor (mm); keep it below where the back shoulder narrows
tab_x     = 43;     // tab centers, either side of the V (mm). See the header for the room there
tab_clear = 0.25;   // socket bigger than tab, all round (mm); snug sliding is 0.20 on this machine, the joint coupon is for this
tab_foot  = 0.5;    // 45-degree chamfer on the tab's bottom edges, against elephant foot (mm)
tab_roof  = 10;     // rise of the socket's roof above the tab, a pyramid so nothing bridges (mm)

/* [Block] */

base_w   = 150;     // across the floor — this is the stability across the heater (mm)
top_w    = 100;     // across the block at the trace's flat edge, either side of the 63 mm mouth (mm); with base_w this is the flanks' lean, which both walls keep above and below it
front_down = 15;    // how far the front wall's top stops below the trace's flat edge (mm). Ziad, 2026-09-17
back_up    = 30;    // how far the back wall's top stands above the trace's flat edge (mm). Ziad, 2026-09-17
floor_t  = 6;       // under the V's floor (mm)
top_r    = 6;       // rounding on the top corners (mm)
step_r      = 16;   // radius at the head of the step, where the back's top face falls away to the front's (mm). What is left of the swoop once the cut is honoured
step_fillet = 6;    // radius in the throat of that fall, where it lands on the front's top face (mm)
foot_chamfer = 0.5; // chamfer on the bottom edges, against elephant foot (mm)

/* [Coupon] */

coupon_length = 5;  // the slice's thickness, along the heater's edge (mm). 10 until v11, then 3; 5 asked for on 2026-09-17, the wall tops being 45 apart now and the back one tall and thin
coupon_band   = 6;  // material kept around the V; the floor under it is floor_t regardless (mm)

/* [Hidden] */

$fn = 64;
eps = 0.01;

// The traced edge, "_incoming/Asset 1.svg", as an absolute cubic bezpath in
// mm: point, control, control, point, ... Origin is the SVG's left edge and
// the 15 mm flat; y is up, so the flat edge where the trace stops is at
// y = 80 and the narrow flat at y = 0. If the trace is ever redone:
//
//     utils/svg2bez.py "_incoming/Asset 1.svg" --height 80
HEATER_TRACE = [
    [62.912, 80.000],
    [41.941, 80.000], [20.971, 80.000], [ 0.000, 80.000],   // the flat edge where the trace stops
    [ 0.000, 58.397], [ 7.994, 40.757], [ 9.088, 37.472],   // one side: straight, then curling in
    [10.183, 34.187], [16.909, 16.825], [18.630, 11.976],
    [19.795,  8.694], [20.028,  4.368], [20.057,  1.915],
    [20.069,  0.853], [20.933,  0.000], [21.995,  0.000],   // corner
    [27.036,  0.000], [32.077,  0.000], [37.118,  0.000],   // the 15 mm flat
    [37.872,  0.000], [38.561,  0.422], [38.902,  1.095],   // corner
    [42.335,  7.867], [60.380, 44.907], [62.912, 80.000],   // the other side: one long slope
];
HEATER_W = 62.912;  // the trace's width at the flat edge (mm)
HEATER_H = 80;      // the trace's height, narrow flat to flat edge (mm)

// The trace with the back leaned in: a shear, +x by back_floor_in at the
// floor and nothing at the flat edge, over the back, its corner, and the left
// end of the floor flat. The front's corner and the front itself are left
// where they are, so the flat narrows from the back rather than sliding. See
// the header for why a rotation is the right correction and what it assumes.
BACK_LAST = 15;     // last index the lean touches — the floor flat's left end
HEATER_BEZ = [
    for (i = [0 : len(HEATER_TRACE) - 1])
        i <= BACK_LAST
            ? HEATER_TRACE[i] + [back_floor_in * (HEATER_H - HEATER_TRACE[i][1]) / HEATER_H, 0]
            : HEATER_TRACE[i]
];

// The front is the last cubic, from the floor corner's exit at index 21 to
// the tip. It is sampled and bent: below the knee — front_knee of the way
// up its chord — nothing moves; above it, each point moves left, straight
// along -x so the tip stays on the flat edge, by a displacement d(s) that
// grows from the knee: zero and flat there, so the wall leaves the trace
// without a kink, front_tip_in at the tip, and with the slope at the tip
// that leaves the wall standing at front_tip_lean from vertical. Four
// conditions, so d is the cubic a s^2 + b s^3 — not an arc any more: an arc
// has one curvature and cannot meet a tangent at both ends, which is exactly
// what v10 showed (the wall stood 1-2 mm off the heater around the apex
// while the tip was right). The traced tangent at the tip, m0, is what the
// displacement's slope has to cancel to leave the tip plumb.
FRONT_I    = 21;
front_bez  = select(HEATER_BEZ, FRONT_I, FRONT_I + 3);
front_A    = front_bez[0];
front_B    = front_bez[3];
front_L    = norm(front_B - front_A);                // the chord (mm)
front_u    = (front_B - front_A) / front_L;          // along it, upward
front_base = bezier_curve(front_bez, 48);            // the front as traced
front_m0   = (last(front_base)[0] - front_base[len(front_base) - 2][0])
           / (last(front_base)[1] - front_base[len(front_base) - 2][1]);   // traced tangent at the tip, x per y
front_arm  = (1 - front_knee) * front_L;             // the chord above the knee (mm)
// Slope the displacement needs at the tip, per mm along the chord, to turn
// the traced tangent m0 into tan(front_tip_lean). dl/dy along the traced
// curve near the tip is u.x * m0 + u.y.
front_k    = (front_m0 - tan(front_tip_lean)) / (front_u[0] * front_m0 + front_u[1]);
front_b    = (front_k * front_arm - 2 * front_tip_in) / pow(front_arm, 3);
front_a    = (front_k - 3 * front_b * front_arm * front_arm) / (2 * front_arm);
function front_d(s) = s <= 0 ? 0 : front_a * s * s + front_b * s * s * s;
function front_bent(p) =
    let (s = (p - front_A) * front_u - front_knee * front_L)   // distance past the knee, along the chord
    p - [front_d(s), 0];
front_pts = [for (p = front_base) front_bent(p)];
front_tip = last(front_pts);                         // where the front now meets the flat edge

// The cubic must not overshoot: if the lean asked for at the tip needs the
// wall to come in past front_tip_in and back out, the knobs disagree.
front_d_max = max([for (p = front_base) front_d((p - front_A) * front_u - front_knee * front_L)]);
assert(front_d_max <= front_tip_in + 0.05,
       str("the front would come in ", front_d_max, " and back out to ", front_tip_in,
           " at the tip: ease front_tip_lean, or move front_knee down"));

// The whole outline as points, starting at the flat edge's far end and going
// round: down the back, along the floor, up the bent front to the tip. The
// flat edge itself is the polygon's closing side, tip back to [0, 80], so it
// runs to wherever the tip has moved to. The front's first point is the
// trace's last, so it is dropped rather than doubled.
heater_pts = concat(bezpath_curve(select(HEATER_BEZ, 3, FRONT_I), splinesteps = 24),
                    list_tail(front_pts, 1));

// Where each side is heading as it leaves the trace, x per mm of y. The left
// is vertical; the right stands at front_tip_lean, which the bend was built
// to deliver, so it is taken from the knob rather than re-measured. The run
// above the trace is kept short (ext) because a lean carried far enough
// would cross the back and fold the polygon.
left_dxdy  = (HEATER_BEZ[3][0] - HEATER_BEZ[4][0]) / (HEATER_BEZ[3][1] - HEATER_BEZ[4][1]);
right_dxdy = tan(front_tip_lean);
function left_x(y)  = 0            + left_dxdy  * (y - HEATER_H);   // in the trace's own frame
function right_x(y) = front_tip[0] + right_dxdy * (y - HEATER_H);
ext = back_up + lead_in + 5;   // how far the heater is carried on above the trace (mm); past the back wall's top, chamfer and all, is what matters

// Where a wall of the V stands at a height y in the trace's own frame: side
// is +1 for the front, -1 for the back. Below the flat edge it is the traced
// wall — the bent front, or the back as traced — and both sides rise
// monotonically in y, so lookup() interpolates the sampled points. Above it,
// each side carries on along the end tangent it left on.
front_xy = [for (p = front_pts) [p[1], p[0]]];
back_xy  = [for (p = reverse(bezpath_curve(select(HEATER_BEZ, 3, 12), splinesteps = 24))) [p[1], p[0]]];
function wall_x(side, y) =
    y >= HEATER_H ? (side > 0 ? right_x(y) : left_x(y))
                  : lookup(y, side > 0 ? front_xy : back_xy);

// How much narrower the mouth is than the widest point of the V below it, on
// the front (mm). Measured at the front's own lip, which since 2026-09-17 is
// front_down below the trace's flat edge; zero when the lip is the widest
// point, as it was on the trace's tip and is again once the front is cut down
// to where the wall is still opening out.
front_lip_y   = HEATER_H - front_down;
front_reentry = max([for (p = front_pts) if (p[1] <= front_lip_y) p[0]]) - wall_x(1, front_lip_y);

// The V's opening at the front's lip, as cut (mm): the two walls where they
// end, each pushed out along its own normal by the clearance, which for a
// wall leaning m off plumb is clearance * sqrt(1 + m^2) horizontally. This
// is the aperture the heater has to pass, and it is NOT the width at the
// trace's flat edge — there is no front wall up there any more, and reading
// that number instead is how the mouth got quoted 1.4 too wide on
// 2026-09-17.
function wall_m(side, y) = (wall_x(side, y + 0.25) - wall_x(side, y - 0.25)) / 0.5;
mouth_w = (wall_x( 1, front_lip_y) + clearance * sqrt(1 + pow(wall_m( 1, front_lip_y), 2)))
        - (wall_x(-1, front_lip_y) - clearance * sqrt(1 + pow(wall_m(-1, front_lip_y), 2)));

// ---- derived ---------------------------------------------------------------

x_off   = -HEATER_W / 2;             // centers the trace on x = 0
mid_x   = -x_off;                    // the block's centerline, in the trace's frame. The V's floor flat straddles it, so it is inside the V at every height above the floor — which is what lets a lip's chamfer close on it
block_h = floor_t + HEATER_H;        // where the trace stops, and where the block's one top used to be
front_h = block_h - front_down;      // the front wall's top (mm)
back_h  = block_h + back_up;         // the back wall's top (mm)
assert(back_h > front_h + 2 * top_r, "the two wall tops are too close to round: give the outline back a single top");
assert(back_h - front_h > step_r + step_fillet, "step_r and step_fillet do not both fit in the fall");
assert(cool_face(back_h) - step_r > -half_w(back_h) + top_r + 2,
       "the step's round reaches the back's top corner: drop step_r");

// The flanks' lean, taken from base_w and top_w at the height they were
// measured at, so both walls keep the taper the block always had.
taper = (base_w - top_w) / 2 / block_h;          // x in, per mm of rise
function half_w(y) = base_w / 2 - taper * y;     // the block's half width at height y

// The line the stand may not pass, cool_depth forward of the heater's back
// panel and parallel to it — the panel leans out as it rises, by as much as
// the back was leaned in, so the line leans with it. Below the rail it is an
// extrapolation and answers for nothing: there is no hot plate down there,
// and all that matters is that it stays inside the V.
function cool_face(y) = x_off + left_x(y - floor_t) + cool_depth;


stand_len   = heater_len + 2 * end_clear + 2 * end_wall;   // wall to wall, outside (mm)
section_len = stand_len / sections;                        // each piece, nominal — the center prints longer by its tabs
assert(section_len + 2 * tab_len <= 210,
       str("the center prints ", section_len + 2 * tab_len, " long, past the bed's probed 210"));
assert(tab_h + tab_clear + tab_roof < min(front_h, back_h) - 10, "socket roof is up in the mouth");

// ---- 2D, in the section: x across, y up --------------------------------------

// The traced edge, centered on x = 0, sitting on y = floor_t.
module heater_trace() {
    translate([x_off, floor_t]) polygon(heater_pts);
}

// The trace plus the heater above it, along the end tangents, out past the
// top of the block.
module heater_section() {
    union() {
        heater_trace();
        translate([x_off, floor_t]) polygon([
            [left_x(HEATER_H),        HEATER_H - eps],
            [right_x(HEATER_H),       HEATER_H - eps],
            [right_x(HEATER_H + ext), HEATER_H + ext],
            [left_x(HEATER_H + ext),  HEATER_H + ext],
        ]);
    }
}

// A 45-degree lead-in on one lip of the mouth, in the trace's frame: side is
// +1 for the front, -1 for the back, and y_top is that wall's own top. It
// runs from the wall's face — the clearance already added — out to the
// block's centerline, well inside the V, so it unions into the V's void with
// nothing hanging off the far side.
module lip(side, y_top) {
    polygon([
        [mid_x,                                                        y_top - lead_in],
        [wall_x(side, y_top - lead_in) + side * clearance,             y_top - lead_in],
        [wall_x(side, y_top)           + side * (clearance + lead_in), y_top + eps],
        [mid_x,                                                        y_top + eps],
    ]);
}

// The V: the heater grown by the clearance, with a lead-in on each lip at its
// own wall's top. The tops are front_down + back_up apart, so one chamfer
// across the pair would hang in mid-air on the front and sit half-way up the
// back.
module v_cut() {
    union() {
        offset(r = clearance) heater_section();
        translate([x_off, floor_t]) {
            lip( 1, HEATER_H - front_down);
            lip(-1, HEATER_H + back_up);
        }
    }
}

// The block's outline. It was a symmetric trapezoid until the two walls got
// their own tops; now the path is written out, counter-clockwise from the
// front's foot: up the front flank, in along the front's top to the
// centerline, up the centerline to the back's top, out along that, and down
// the back flank. Both centerline points are inside the V, so that whole
// stretch is cut away again by v_cut() and the two tops never meet.
raw_outline = [
    [ half_w(0),          0      ],   // the front's foot, chamfered
    [ half_w(front_h),    front_h],   // the front's top, outside, rounded
    [ cool_face(front_h), front_h],   // the step's throat, filleted
    [ cool_face(back_h),  back_h ],   // the step's head, rounded
    [-half_w(back_h),     back_h ],   // the back's top, outside, rounded
    [-half_w(0),          0      ],   // the back's foot, chamfered
];

// Corner i of path, cut off square at d along each of its two edges. The feet
// want a chamfer and the tops a radius, and round_corners() does one method
// per call, so the feet are done here and the tops are left to it.
function chamfered(path, i, d) =
    let (p = path[i], a = select(path, i - 1), b = select(path, i + 1))
    [p + d * unit(a - p), p + d * unit(b - p)];

block_path = round_corners(
    concat(chamfered(raw_outline, 0, foot_chamfer),
           select(raw_outline, 1, 4),
           chamfered(raw_outline, 5, foot_chamfer)),
    radius = [0, 0, top_r, step_fillet, step_r, top_r, 0, 0]);

module block_outline() {
    polygon(block_path);
}


module section() {
    difference() {
        block_outline();
        v_cut();
    }
}

// ---- 3D -------------------------------------------------------------------

// Stand a section up: its y becomes Z, and it runs along Y.
module upright(len) {
    rotate([90, 0, 0]) linear_extrude(len, center = true, convexity = 4) children();
}

// A piece's body: the block, len long, centered on y = 0, with the V cut
// from y0 to y1 (so an end piece can leave its wall) and the bottom edge of
// each end face chamfered like the long edges are — a butt joint with an
// elephant foot on both faces stands the pieces apart.
module body(len, y0 = -1, y1 = 1) {
    difference() {
        upright(len) block_outline();
        translate([0, (y0 + y1) / 2 * len / 2, 0])
            upright(abs(y1 - y0) / 2 * len + eps) v_cut();
        for (sy = [-1, 1])
            translate([0, sy * len / 2, 0]) rotate([45, 0, 0])
                cube([2 * base_w, foot_chamfer * sqrt(2), foot_chamfer * sqrt(2)], center = true);
    }
}

// ---- the joint ------------------------------------------------------------

// A tab in plan: neck on the face at y = 0, head out at y = tab_len, and a
// millimetre back into the body so the union has something to hold.
module tab2d()
    polygon([[-tab_neck / 2, -1], [tab_neck / 2, -1],
             [tab_head / 2, tab_len], [-tab_head / 2, tab_len]]);

// The tab, standing on the floor, pointing +y, foot chamfered.
module tab(h = tab_h)
    hull() {
        translate([0, 0, tab_foot]) linear_extrude(h - tab_foot) tab2d();
        linear_extrude(eps) offset(delta = -tab_foot) tab2d();
    }

// The socket, as a void to subtract: the tab grown by tab_clear, pointing
// -y into the body from a face at y = 0, open at the floor, and roofed by
// hulling the slot with a point tab_roof above its middle — every roof face
// is then 45 degrees or steeper, and nothing bridges.
module socket_void(h = tab_h)
    hull() {
        translate([0, 0, -eps]) linear_extrude(h + tab_clear + eps)
            mirror([0, 1, 0]) offset(delta = tab_clear) tab2d();
        translate([0, -tab_len / 2, h + tab_clear + tab_roof]) cube(eps, center = true);
    }

// Turned to point -y when dir is negative; a tab or socket is drawn for +y.
module facing(dir) { if (dir < 0) mirror([0, 1, 0]) children(); else children(); }

// Tabs on the face at y = yf, pointing away from the body (dir = +1 or -1).
module tabs_on(yf, dir, h = tab_h)
    for (x = [-tab_x, tab_x])
        translate([x, yf, 0]) facing(dir) tab(h);

module sockets_on(yf, dir, h = tab_h)
    for (x = [-tab_x, tab_x])
        translate([x, yf, 0]) facing(dir) socket_void(h);

// ---- the pieces ------------------------------------------------------------

// The center: V right through, tabs out of both ends.
module center_piece()
    union() {
        body(section_len);
        tabs_on( section_len / 2,  1);
        tabs_on(-section_len / 2, -1);
    }

// The left end: wall at -y, V from the wall to the +y face, sockets in that
// face. The right end is this, mirrored.
module end_piece_left()
    difference() {
        body(section_len, -1 + 2 * end_wall / section_len, 1);
        sockets_on(section_len / 2, 1);
    }

module end_piece_right() mirror([0, 1, 0]) end_piece_left();

// The stand, assembled: for looking at, not printing.
module stand() {
    translate([0, -section_len, 0]) end_piece_left();
    center_piece();
    translate([0,  section_len, 0]) end_piece_right();
}

// The joint coupon: a tab and a socket on two small blocks, to check
// tab_clear before anything big is printed on it. The tab is jc_h tall; the
// socket block is taller by the roof, so the roof prints exactly as it will
// in the end piece and the socket is blind, as it will be. The blocks sit as
// the pieces would, socket block behind the tab block, a finger's width
// apart; lift it, drop it on.
jc_h    = 15;
jc_wall = 5;
module joint_coupon() {
    w = tab_head + 2 * tab_clear + 2 * jc_wall;
    d = tab_len + tab_clear + jc_wall;
    // The tab block, its tab pointing +y and reaching y = -8.
    translate([0, -20, 0]) union() {
        translate([-w / 2, -20, 0]) cube([w, 20, jc_h]);
        tab(jc_h);
    }
    // The socket block, from y = 10 back, its socket opening on the y = 10 face.
    translate([0, 10, 0]) difference() {
        translate([-w / 2, 0, 0]) cube([w, d, jc_h + tab_clear + tab_roof + 2]);
        mirror([0, 1, 0]) socket_void(jc_h);
    }
}

// The section, its outside trimmed to a band around the V, lying flat.
module coupon() {
    linear_extrude(coupon_length, convexity = 4) difference() {
        intersection() {
            block_outline();
            offset(r = clearance + coupon_band) heater_section();
        }
        v_cut();
    }
}

echo(str("front tip ", front_tip_in, " in, ", front_tip_lean, " deg at the tip, knee at ", front_knee * 100, "%: tip at x ", front_tip[0] + x_off,
         " (was ", HEATER_W + x_off, "), mouth ", mouth_w, " wide as cut at the front's lip (", front_tip[0], " at the trace's flat edge), ",
         "wall in by ", front_d(front_arm / 2), " halfway up the bend, ",
         "mouth narrower than the V below it by ", front_reentry));

echo(str("back leaned in ", back_floor_in, " at the floor, ",
         atan(back_floor_in / HEATER_H), " deg: floor flat now ",
         HEATER_BEZ[18][0] - HEATER_BEZ[15][0], " wide (was ",
         HEATER_TRACE[18][0] - HEATER_TRACE[15][0], "), back's tangent at the mouth ",
         atan(-left_dxdy), " deg off plumb"));

echo(str("nothing above the rail past x ", cool_face(block_h), " (", cool_depth,
         " forward of the back panel): the step stands there, ", back_h - front_h,
         " tall, with ", cool_face(back_h) - step_r + half_w(back_h),
         " of the back's top face left flat in front of its round"));

echo(str("front wall tops at ", front_h, " (", front_down, " off the flat edge), back at ", back_h,
         " (", back_up, " on): wall left at the top, front ",
         half_w(front_h) - (x_off + wall_x( 1, front_h - floor_t) + clearance), ", back ",
         half_w(back_h)  + (x_off + wall_x(-1, back_h  - floor_t) - clearance)));

echo(str("stand ", stand_len, " long wall to wall, ", sections, " pieces of ", section_len,
         "; the center prints ", section_len + 2 * tab_len, " with its tabs"));



// Assembly display changes placement only; the original output remains the default.
module feral_default_output_258f5e9d3745() {
if      (show == "coupon")       coupon();
else if (show == "joint-coupon") joint_coupon();
else if (show == "end-left")     end_piece_left();
else if (show == "end-right")    end_piece_right();
else if (show == "center")       center_piece();
else                             stand();
}

module feral_assembly_view_258f5e9d3745(explode=false) {
color("SteelBlue") translate([0,-section_len-(explode ? 30 : 0),0]) end_piece_left();
color("DarkOrange") center_piece();
color("SeaGreen") translate([0,section_len+(explode ? 30 : 0),0]) end_piece_right();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_258f5e9d3745();
else feral_assembly_view_258f5e9d3745(view == "exploded");
