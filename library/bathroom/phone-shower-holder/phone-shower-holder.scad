// phone-shower-holder.scad
//
// Three pieces, glued. Hangs on the front face of a half-inch glass shower
// panel by a hook over the panel's top edge, and holds a phone by the two
// long edges of its bottom half, leaning the top of the phone out toward the
// viewer.
//
// Second design. The first was a full-length tray rebuilt from a SketchUp-era
// mesh: it stood the phone flat against the glass in a pocket with nothing in
// front to keep it there, and Ziad scrapped it on 2026-09-20 for this. Nothing
// here is measured off that mesh. Every number is authored, and the hook's are
// the ones the first design settled on.
//
// FRAME. Authored hung, the way it is used:
//
//     x  ->  across the panel, centered
//     y  ->  out from the glass toward the viewer. The glass's front face is
//            y = 0 and the glass itself is y < 0, so the hook's leg is the
//            only thing at negative y.
//     z  ->  up, with z = 0 at the top of the cap. Everything hangs below.
//
// The cradle is authored in its own frame, tilted `tilt` degrees about x, and
// placed with in_cradle(): x is shared, y' is out from the backrest (normal to
// the phone), z' runs up the phone's long axis from the ledge. Every cradle
// dimension is in that frame, so "front" means the phone's screen side and
// "top" means toward the phone's top, whatever those come to in hung z.
//
// PIECES. One body, cut into three at two shoulders and glued back together,
// the way the first design's tray and hook were. It is cut for one reason:
// the columns. Ziad wanted the back opened up the way the original tray's
// floor was - long slots down its length, for weight and to see through it.
// Printed in one piece the part lies on its -x side, which stands the spine
// up as a vertical wall, and a slot down a vertical wall has a roof as long
// as the slot and 3 mm wide with nothing under it. Every opening would have
// had to be taller across the panel than it is long down it, which is the
// opposite of a column. Split, the spine lies flat on the plate and the slots
// are vertical holes: any shape at all, no roof, no support.
//
//     hook    prints standing on the cap, channel opening upward
//     spine   prints flat on its back face, columns straight down through it
//     cradle  upright on its flat bottom, exactly as it hangs
//
// All three fit one plate side by side, and none of them needs the 45 degree
// yaw the 216 mm one-piece version needed to fit the envelope.
//
// JOINTS. A dovetail at each shoulder. It is cut through the plate's PLAN and
// not through its thickness: 3.09 mm of thickness leaves about 0.3 mm of
// undercut at any angle a printer will take, which is not a joint, and a
// plain lap in it is a glue joint with a shoulder - it holds in compression
// and nothing at all in tension, which is the direction the phone pulls.
//
// So the spine's end is a tab whose plan is a trapezoid, narrow at the
// shoulder and `lap_len` wider each side at its tip, and the mating piece
// has the matching socket. The flare is 45 degrees because that is what the
// two mating pieces can print: on both of them the socket's far flank is the
// surface material has to creep over, and 45 is the limit.
//
// The tab is `lap_tab` thick and sits on the spine's BACK face; the mating
// piece keeps `lap_cover` in front of it, so the socket is a blind pocket
// opening backward. The tab drops in along y - both joints in one motion,
// lay the hook and the cradle face down and set the spine on them - and is
// then locked in z and in x by the dovetail's flanks and forward by the
// cover. The one direction left is straight back out, and that is the face
// that lies on the glass. Glue is what holds it together off the wall; on
// the wall the load path is mechanical.
//
// WATER. The spine lies on the glass, and water behind it does not drain on
// its own - the first design's slots were for that and were not enough. Two
// shallow bores in the back face at the bottom take stick-on silicone feet,
// which stand the bottom of the spine off the glass by whatever the feet are
// proud of the bore. The part carries no feet of its own. The columns drain
// and dry the middle of it for free.
//
// ROUNDING. Nothing on it is sharp, and the rounding is computed on the whole
// body before it is cut, so the rounds run across the glue lines. The big
// corners are rounded where they are drawn - the side profile through
// round_corners(), the cradle's front and bottom corners through
// corner_keep() prisms the body is intersected with, each in the frame its
// edge actually runs in - and then every remaining convex edge gets `rnd` by
// a morphological opening: the whole part is built `rnd` smaller than drawn
// (2D erosion of every profile, every cutter grown by `rnd`), and minkowski()
// with a sphere of `rnd` grows it back. Faces land exactly where drawn,
// convex edges come out at `rnd`, concave ones stay sharp. Anything thinner
// than 2 * rnd would vanish in the erosion, which is why the walls and the
// leg are 2.64 and not 2.19, and why `rnd` is the one number here that must
// not be raised casually. Pass -D rnd=0 for the sharp part, which builds in a
// second instead of a minute.
//
// The joint faces are cut after the minkowski and stay sharp, which is what a
// mating face wants. So do the columns and the foot bores, for the same
// reason the bores always did: a slot rim is a hundred reflex edges for the
// minkowski to decompose around, and none of these rims is an edge a hand
// ever touches.
//
// THREE BED PLANES, AND ONLY ONE NEEDS ANYTHING. The spine's back face and
// the cradle's bottom are both big flat faces, and a round tangent to a face
// that size costs nothing - they take `rnd` like every other edge. The cap's
// top is 89 x 18 and the rounds that used to meet it were 2.5 and 4, which
// would have left almost nothing to print the first layer on, so the core is
// built `cap_ext` past z = 0 and cut back with a 45 degree chamfer all
// round. That chamfer is what replaced those two rounds.
//
// NO TEARDROPS ANYWHERE. There were five: three on the rounds that met the
// old -x print bed, and two on the foot bores. Nothing prints on -x now, and
// Orca asks for supports on this part whatever the geometry does - Ziad's
// call on 2026-09-21 - so none of them was buying anything. They are all
// plain rounds and plain circles.
//
// What is left that is not vertical in its own pose, as a note rather than a
// constraint: the lips' 45 degree top cutback; the two sockets' far flanks,
// at 45; and the roofs of the two foot bores. Standing the cradle up got rid
// of the two worst ones the side-lying pose had - the pocket's ceiling, a
// 13.6 mm bridge from the backrest to the lip, and the upper lip hanging off
// its wall with nothing under it. Upright, the two rails are identical and
// both lips run within 11 degrees of vertical.

include <../../../lib/BOSL2/std.scad>

/* [Which output] */
// A piece on its own, the three of them laid out on one plate, or the whole
// thing glued. "fitcheck" adds the glass in the hook and the phone in the
// cradle - not for printing, it is the view that proves the tilt and the
// clearances.
show   = "assembled";  // [assembled, exploded, hook, spine, cradle, coupon, plate, fitcheck]

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon
// "print" lays a piece down the way it should be sliced, centered on the
// origin. Ignored by "assembled" and "fitcheck"; "plate" is always printed.
orient = "hung";       // [hung, print]

/* [Phone] */
// A 16 Pro Max in its case. The v02 coupon was printed on 2026-09-21:
// side-to-side fit is confirmed; reduce the front-to-back gap by 2 mm.
// Thickness below is the revised fit basis, not a new caliper measurement.
phone_w = 83.0;   // width, in its case (mm)
phone_t = 11.0;   // fit basis: 13.0 minus the requested 2 mm correction (mm)
phone_l = 166.0;  // length, in its case; fitcheck only (mm)
// Free clearance on a 0.4 nozzle is 0.30 per the ladder in
// docs/flashforge-ad5m-pro-scad-reference.md; opened because the phone goes in
// and out wet, one-handed.
phone_fit_w = 1.0;  // total slack across the width (mm)
phone_fit_t = 0.6;  // slack between the backrest and the root of the lips (mm)

/* [Hang] */
tilt        = 15;     // deg; the top of the phone leans out toward the viewer
overall_len = 216.0;  // top of the cap to the lowest point of the cradle (mm)

/* [Hook - over the glass] */
glass_t   = 12.0;  // panel thickness, calipered 2026-09-20 (mm)
// Printed holder fits and is usable, but the hook is snug on the glass.
// Open the channel by 1 mm for the next print; the measured glass stays 12.
glass_fit = 1.40;  // total channel slack; increased from 0.40 after the fit test (mm)
// Both faces exposed, so the rungs are 0.84, 1.29, 1.74, 2.19, 2.64, 3.09.
// 2.64 rather than 2.19 so that 2 * rnd leaves something. The leg's end is
// rounded by rnd, which is the lead-in.
leg_t     = 2.64;  // the leg that drops behind the glass (mm)
cap_t     = 5.0;   // material over the glass's top edge (mm)
wrap      = 15.0;  // how far the leg reaches down the back face (mm)

/* [Spine] */
// The plate down the glass from the hook to the cradle. It is the channel's
// front wall and it carries the cradle's whole moment.
spine_t = 3.09;  // (mm)

/* [Columns] */
// Slots down the spine, for weight and to see through it. The original tray
// had five 6 mm slots at 13.5 pitch through its floor; these are the same,
// across the wider plate. The spine prints flat, so these are plain vertical
// holes and their shape is free - stadiums only because that is what the
// original had.
col_n     = 6;     // how many
col_w     = 6.0;   // each slot's width, across the panel (mm)
col_pitch = 13.5;  // center to center (mm)
col_gap   = 7.0;   // from each shoulder to the end of the slots (mm)

/* [Joints] */
// Where the two shoulders sit, in hung z. Both bands have to sit in plain
// spine. The hook's has to clear the bottom of the leg at -20, because the
// pocket takes the back lap_pocket out of the plate and that stretch of
// plate is the glass channel's front wall; the cradle's has to clear the top
// of the wedge at -122.6 by more than lap_len.
joint_z_hook   = -30.0;   // (mm)
joint_z_cradle = -105.0;  // (mm)
// The tab's length past the shoulder is also its flare per side, which is
// what makes the flanks 45 degrees. Raising one without the other is what
// would make the mating pieces unprintable, so there is one number.
lap_len   = 8.0;   // (mm)
dove_w    = 76.0;  // the tab across its tip, the widest it gets (mm)
lap_tab   = 1.74;  // tab thickness, on the spine's back face (mm)
lap_cover = 1.20;  // what the mating piece keeps in front of it (mm)
joint_fit = 0.20;  // clearance on all three free edges of the tab (mm)

/* [Silicone feet] */
// Two recesses in the back face at the bottom corners, for stick-on silicone
// bumpers. Sized to the feet Ziad has, 2026-09-20. Where the bores sit the
// wedge is behind the spine, so a 2 mm bore leaves over 5 mm of solid. They
// are on the cradle piece.
foot_bore_d     = 13.0;  // (mm)
foot_bore_depth = 2.0;   // (mm)
foot_inset      = 5.0;   // bore edge to the part's side face and bottom (mm)

/* [Cradle] */
cradle_len = 82.0;  // how much of the phone's edge is held, up from its bottom (mm)
wall       = 2.64;  // the rail walls, outside the phone's edges; see leg_t (mm)
// The lip is a 45 degree bevel, not a flat tab, so that it prints with the
// part on its side: the upper rail's lip hangs from its wall and 45 is the
// steepest it can hang. Its reach is measured at the front face; at the level
// of the phone's own face the bevel is just leaving the wall.
lip_r      = 7.0;   // inward reach; extended 2 mm per fin after the v02 coupon (mm)
ledge_t    = 3.09;  // the shelf the phone's bottom edge stands on (mm)
back_min   = 2.64;  // backrest thickness at the ledge, where the wedge is thinnest (mm)
// Open at the front, so the lanyard drops in from the front rather than being
// fed through. Its width is at the face the phone stands on; the sides flare
// out at 45 degrees through the ledge so the ledge over it prints on its side.
notch_w    = 40.0;  // lanyard gap in the ledge, centered (mm)

/* [Coupon] */
// A band of the cradle, for a fit test before committing to the whole piece:
// both rails, both lips, the 45 degree lead-in at their top ends, and a plate
// behind the phone standing in for the wedge.
//
// It is cut in HUNG z rather than in the cradle's own frame, so its faces are
// horizontal and it stands on the plate the way the cradle does. That matters:
// the lips meet the build direction at the same angle they will in the real
// part, and a lip that droops is most of what this is printed to find out.
coupon_len  = 45.0;   // how far down from the top of the cradle it reaches (mm)
coupon_back = 3.09;   // the plate behind the backrest, in place of the wedge (mm)

/* [Rounding] */
rnd        = 1.2;   // every convex edge; see ROUNDING above (mm)
// The corners of the side profile. Anything under rnd comes out at rnd.
r_wedge    = 3.0;   // fillet where the wedge's top meets the spine (mm)
r_bottom   = 2.0;   // where the flat bottom meets the glass face (mm)
// The cradle box's front-top and front-bottom edges in the side profile, and
// its front-side edges. Not its top-side edges: a round there would end in a
// step against the spine's side face. Not its bottom-side edges either -
// those stand on the plate now and a 4 mm bullnose there is more than the
// first layer wants, so they take rnd like everything else.
r_cradle   = 4.0;   // (mm)
// The rim of each column slot, on the FRONT face only. The back face lies on
// the glass, and is also the spine's print bed, so it stays sharp and flat.
col_round  = 1.2;   // (mm)
// The cap's top, all four edges. A chamfer and not a round, because the cap's
// top is the hook's print bed and a round tangent to a bed plane leaves
// nothing to print the first layer on.
cap_chamfer = 2.5;  // (mm)

/* [Quality] */
$fn = 48;       // segments per full circle, for the bores and the drawn rounds
sphere_fn = 20; // for the rounding sphere; every facet of it lands on every edge

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's.
eps = 0.01;

// Long enough to pass through anything here.
tall = 300;

// ---------------------------------------------------------------- derived

gch   = glass_t + glass_fit;          // the channel the glass sits in
ch_w  = phone_w + phone_fit_w;        // between the rail walls
W     = ch_w + 2 * wall;              // the part's width
h_ch  = phone_t + phone_fit_t;        // backrest to the root of the lips
front = h_ch + lip_r;                 // backrest to the cradle's front face

s = sin(tilt);
c = cos(tilt);
sq2 = sqrt(2);

// Cradle origin: the phone's bottom-back corner. In front of the spine by the
// thinnest the backrest gets, and as far down as puts the lowest point of the
// cradle - the front-bottom corner of the ledge - at overall_len.
y0 = spine_t + back_min;
z0 = -overall_len + front * s + ledge_t * c;

// Cradle frame to hung frame. Same map as in_cradle().
function H(yp, zp) = [y0 + yp * c + zp * s, z0 - yp * s + zp * c];

// Where the cradle's top plane runs back into the spine's front face.
yp_top = (spine_t - y0 - cradle_len * s) / c;

// The bottom is flat and horizontal, at the lowest point the cradle reaches,
// and it runs straight back from there to the glass face. That is the
// cradle's print bed. It used to follow the ledge's underside, which is
// tilted 15 degrees with it, and left the back of the part 6 mm short of the
// front - nothing to stand on. Ziad's call, 2026-09-21.
z_bot = -overall_len;
y_bot = H(front, -ledge_t).x;  // how far forward the bottom face reaches

y_min = -(gch + leg_t);
y_max = H(front, cradle_len).x;

// How far past the cap's bed plane the core is built, so the part is full
// section there when it is cut back. It is measured in the profile, which is
// eroded by rnd first, so it has to clear that too.
cap_ext = rnd + 1.0;

// The joints. lap_gap is what is left between the tab's front face and the
// cover behind it: the glue line.
lap_pocket = spine_t - lap_cover;
lap_gap    = lap_pocket - lap_tab;
dove_root  = dove_w - 2 * lap_len;  // the tab across its shoulder

// Posed extents, for centering each piece on the plate.
z_sp_hi = joint_z_hook   + lap_len - joint_fit;  // tip of the spine's upper tab
z_sp_lo = joint_z_cradle - lap_len + joint_fit;  // tip of its lower one

module in_cradle() {
    translate([0, y0, z0])
        rotate([-tilt, 0, 0])
            children();
}

function corner_arc(cp, r, a0, a1) =
    let (n = max(3, round($fn * abs(a1 - a0) / 360)))
    [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n) cp + r * [cos(a), sin(a)]];

// ---------------------------------------------------------------- body

// The whole side silhouette - hook, spine, wedge, and the cradle's box - as
// one polygon in (y, z). Everything that is not full width is cut out of the
// sweep of this or added to it afterward. Top level rather than inside body()
// because the pieces and the plate layout read it too.
//
// The top edge is drawn cap_ext above z = 0 and sharp: it is the hook's bed
// and cap_cut() trims it back to z = 0 with a chamfer.
silhouette = [
    [y_min,   cap_ext],                  // leg outer face, top
    [spine_t, cap_ext],                  // cap front, top
    H(yp_top, cradle_len),               // the wedge's top meets the spine
    H(front,  cradle_len),               // cradle front, top
    H(front, -ledge_t),                  // cradle front, bottom: the lowest point
    [0, z_bot],                          // flat bottom, straight back to the glass
    [0,    -cap_t],                      // up the glass face to the cap
    [-gch, -cap_t],                      // across the channel's closed end
    [-gch, -cap_t - wrap],               // down the leg's inner face
    [y_min, -cap_t - wrap],              // leg outer face, bottom
];
// One radius per vertex above. The two at the top are sharp because they are
// cut away; the channel's corners stay sharp because the glass's top edge
// sits in them.
silhouette_r = [0, 0, r_wedge, r_cradle, r_cradle, r_bottom, 0, 0, 0, 0];
silhouette_rounded = round_corners(silhouette, radius = silhouette_r);

// Everything but one corner, in a local (u, v) frame: u runs from one face
// of the part inward, v from the other, and the edge between them is the
// origin. The corner is rounded to R - rnd about the center the finished R
// will have, so the sphere brings it out at exactly R. The outer boundary
// sits half a millimetre outside the core's faces so no two faces coincide.
//
// These used to come in a teardrop variant, for an edge sitting on the -x
// print bed where the rest of the arc would have lain flat and hung. No
// piece prints on -x any more, so there is no such edge and no teardrop.
module corner_keep(R) {
    big = tall;
    r   = R - rnd;
    cp  = [R, R];

    polygon(concat([[big, rnd - 0.5], [R, rnd - 0.5]],
                   corner_arc(cp, r, -90, -180),
                   [[rnd - 0.5, R], [rnd - 0.5, big], [big, big]]));
}

// The body, rnd under size: the rounded silhouette eroded by rnd, swept from
// rnd inside one side face to rnd inside the other, then the two big corners
// that are not in the silhouette, each cut in the frame its edge runs in.
//
// There is no overshoot on either side face any more. Both are ordinary
// rounded faces: the cradle stands on its bottom now, so nothing prints on
// -x and nothing needs a full-section first layer there.
module body() {
    intersection() {
        translate([-W / 2 + rnd, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = W - 2 * rnd, convexity = 6)
                    offset(r = -rnd)
                        polygon(silhouette_rounded);

        // the cradle's front-side edges, along z': u in from the side, v back
        in_cradle() translate([-W / 2, front, 0])
            mirror([0, 1, 0])
                linear_extrude(height = 2 * tall, center = true)
                    corner_keep(r_cradle);
        in_cradle() translate([W / 2, front, 0])
            mirror([1, 0, 0]) mirror([0, 1, 0])
                linear_extrude(height = 2 * tall, center = true)
                    corner_keep(r_cradle);
    }
}

// What the phone sits in: open at the front and at the top, floored by the
// ledge, backed by the wedge. Grown by rnd on every side but with its own
// edges left sharp, so the sphere leaves a fillet of rnd along the pocket's
// inside corners. A cutter with rounded edges would keep them sharp, but
// every facet of that rounding is a reflex edge for the minkowski to
// decompose around and it cost minutes; the phone's case has bigger radii
// than the fillets anyway.
module pocket() {
    in_cradle()
        translate([-ch_w / 2 - rnd, -rnd, -rnd])
            cube([ch_w + 2 * rnd, tall, tall]);
}

// Through the ledge, backrest to front face, so the lanyard drops in from the
// front. notch_w wide at the top face, a ledge thickness wider each side at
// the underside: the 45 degree flanks are what let the ledge over it print
// with the part on its side, where that underside would otherwise be a flat
// 18.6 mm cantilever.
module notch() {
    in_cradle()
        translate([0, front + rnd, 0])
            rotate([90, 0, 0])
                linear_extrude(height = front + 2 * rnd)
                    offset(delta = rnd)  // sharp, for the same reason as pocket()
                        polygon([
                            [-notch_w / 2, 0],
                            [ notch_w / 2, 0],
                            [ notch_w / 2 + ledge_t, -ledge_t],
                            [-notch_w / 2 - ledge_t, -ledge_t],
                        ]);
}

// One 45 degree bevel per rail, root on the wall, running the length of the
// cradle, with its top end cut back at 45 degrees so a phone coming down from
// above is steered in behind it rather than stopped on it.
//
// Drawn already eroded, as the rail - wall plus lip - would erode as one
// solid: the front face and the hypotenuse move in by rnd, the wall's inner
// face is not a boundary where the lip joins it, and the root is carried out
// to the wall's eroded outer face so the two are one piece. The chamfer's
// plane moves by rnd along its normal.
module lips() {
    yp_root = h_ch + rnd * (sq2 - 1);               // hypotenuse meets the eroded wall
    x_tip   = ch_w / 2 - lip_r + rnd * (sq2 + 1);   // hypotenuse meets the eroded front

    for (side = [-1, 1])
        in_cradle()
            difference() {
                translate([0, 0, -rnd - 0.5])
                    linear_extrude(height = cradle_len + 0.5)
                        polygon([
                            [side * (W / 2 - rnd),    yp_root],
                            [side * (W / 2 - rnd),    front - rnd],
                            [side * x_tip,            front - rnd],
                            [side * (ch_w / 2 + rnd), yp_root],
                        ]);

                translate([0, h_ch - rnd / sq2, cradle_len - rnd / sq2])
                    rotate([-45, 0, 0])
                        translate([-W, 0, 0])
                            cube([2 * W, tall, tall]);
            }
}

// The two recesses for the silicone feet, in the glass face at the bottom
// corners. Cut after the rounding, not before: a round hole is 48 reflex
// edges for the minkowski and these are against the glass where no edge is
// ever touched, so their rims stay sharp.
//
// Plain circles. They were teardrops until 2026-09-21, pointed toward +x,
// which is up in the cradle's print pose, so the roof of a 13 mm hole would
// not hang 9 mm across at the top. Ziad's call to drop that: Orca wants
// supports on this part whatever the bores look like, so the teardrop was
// buying a distorted foot recess and nothing else. With supports on, the
// roof is the slicer's problem.
module foot_bores() {
    for (side = [-1, 1])
        translate([side * (W / 2 - foot_inset - foot_bore_d / 2),
                   foot_bore_depth,
                   z_bot + foot_inset + foot_bore_d / 2])
            rotate([90, 0, 0])
                linear_extrude(height = foot_bore_depth + eps)
                    circle(d = foot_bore_d);
}

// The columns: stadium slots straight through the spine, between the two
// shoulders. Cut after the rounding for the same reason the bores are, and
// they need no printable roof at all - the spine prints flat, so every one
// of these is a vertical hole.
//
// The rim is rounded on the FRONT face and left sharp on the BACK, which is
// the face that lies on the glass and also the spine's print bed. The cutter
// carries the round itself: os_circle with a negative radius flares it out
// where it leaves the front face, which takes col_round off the part's rim.
// In the print that flare is the hole getting wider as it rises, so it is
// material leaving, never material over a void.
module columns() {
    z_hi = joint_z_hook   - col_gap;
    z_lo = joint_z_cradle + col_gap;
    len  = z_hi - z_lo;

    for (i = [0 : col_n - 1])
        translate([(i - (col_n - 1) / 2) * col_pitch, -eps, (z_hi + z_lo) / 2])
            rotate([-90, 0, 0])
                offset_sweep(rect([col_w, len], rounding = col_w / 2),
                             height = spine_t + eps,
                             top = os_circle(r = -col_round, extra = eps),
                             check_valid = false);
}

// The part rnd under size everywhere, sharp, and running past both bed planes.
//
// The lips are clipped back to the body. They are drawn as full-length
// prisms running to the eroded side and front faces and past the ledge, but
// those two faces meet each other and the bottom at rounded corners, and a
// lip unioned on afterward stands proud of all three - a square stub hanging
// off the bottom-front corner of each rail, with the round cut out from
// behind it.
module core() {
    union() {
        difference() {
            body();
            pocket();
            notch();
        }

        intersection() {
            lips();
            body();
        }
    }
}

// The hook's bed plane: everything above z = 0 goes, and the cap's top comes
// back as a flat face with a cap_chamfer 45 degree chamfer round all four
// edges. Only the cap's own footprint is chamfered, so the prism is bounded
// just below the chamfer and everything under that is kept whole - the plan
// outline down there is the cradle's, not the cap's.
module cap_cut() {
    slack = 0.05;
    h     = cap_chamfer + 1;

    union() {
        translate([0, 0, -h - tall])
            cube([4 * tall, 4 * tall, 2 * tall], center = true);

        translate([0, 0, -h])
            offset_sweep(ccw_polygon([[-W / 2 - slack, y_min   - slack],
                                      [ W / 2 + slack, y_min   - slack],
                                      [ W / 2 + slack, spine_t + slack],
                                      [-W / 2 - slack, spine_t + slack]]),
                         height = h,
                         top = os_chamfer(width = cap_chamfer + slack));
    }
}

// The whole thing, glued: rounded, trimmed to both bed planes, bored, and
// slotted. Every piece is cut out of this, so the rounds and the columns line
// up across the glue lines by construction.
module monolith() {
    difference() {
        intersection() {
            if (rnd > 0)
                // "aligned" puts vertices of the sphere on its axes.
                // OpenSCAD's own sphere() has none at the poles, and every
                // flat face would land rnd * (1 - cos(90 / rings)) short of
                // where it was drawn.
                minkowski() {
                    core();
                    spheroid(r = rnd, style = "aligned", $fn = sphere_fn);
                }
            else
                core();

            cap_cut();
        }

        foot_bores();
        columns();
    }
}

// ---------------------------------------------------------------- pieces

// `into` is +1 where the tab reaches up from the shoulder into the hook, and
// -1 where it reaches down into the cradle. Either way the spine keeps the
// back and the mating piece keeps the cover in front of it.
//
// Both plans are drawn in (x, -z) and extruded along +y, which is what
// rotate([-90, 0, 0]) does to a linear_extrude.

// The socket, cut into the mating piece's back face. Open a hair past the
// shoulder so the tab can come in.
module dove_pocket(a, into) {
    z_root = a - into * eps;
    z_tip  = a + into * lap_len;

    rotate([-90, 0, 0])
        translate([0, 0, -eps])
            linear_extrude(height = lap_pocket + eps)
                polygon([[-dove_root / 2, -z_root],
                         [-dove_w    / 2, -z_tip],
                         [ dove_w    / 2, -z_tip],
                         [ dove_root / 2, -z_root]]);
}

// The tab, on the spine's back face, joint_fit clear of the socket on all
// three of its free edges. The flanks are at 45 degrees, so a clearance of
// joint_fit measured perpendicular to a flank is joint_fit * sqrt(2)
// measured across the plate. The root edge runs back past the shoulder into
// the spine, where the slab picks it up.
module dove_tab(a, into) {
    jx     = joint_fit * sq2;
    z_root = a - into * 2 * eps;
    z_tip  = a + into * (lap_len - joint_fit);

    rotate([-90, 0, 0])
        translate([0, 0, -eps])
            linear_extrude(height = lap_tab + eps)
                polygon([[-(dove_root / 2 - jx),             -z_root],
                         [-(dove_w / 2 - joint_fit - jx),    -z_tip],
                         [  dove_w / 2 - joint_fit - jx,     -z_tip],
                         [  dove_root / 2 - jx,              -z_root]]);
}

module z_above(z) {
    translate([-2 * tall, -2 * tall, z]) cube([4 * tall, 4 * tall, 2 * tall]);
}

module z_below(z) {
    translate([-2 * tall, -2 * tall, z - 2 * tall]) cube([4 * tall, 4 * tall, 2 * tall]);
}

module piece_hook() {
    difference() {
        intersection() {
            monolith();
            z_above(joint_z_hook);
        }
        dove_pocket(joint_z_hook, 1);
    }
}

module piece_spine() {
    intersection() {
        monolith();
        union() {
            intersection() {
                z_above(joint_z_cradle);
                z_below(joint_z_hook);
            }
            dove_tab(joint_z_hook, 1);
            dove_tab(joint_z_cradle, -1);
        }
    }
}

module piece_cradle() {
    difference() {
        intersection() {
            monolith();
            z_below(joint_z_cradle);
        }
        dove_pocket(joint_z_cradle, -1);
    }
}

module piece(name) {
    if (name == "hook")        piece_hook();
    else if (name == "spine")  piece_spine();
    else if (name == "cradle") piece_cradle();
}

// ---------------------------------------------------------------- coupon

// The top coupon_len of the cradle, its wedge cut back to a plate, dropped
// onto z = 0 and centred. It carries no joint: the sockets are above the
// band and the ledge, the notch, and the bores are all well below it.
module coupon() {
    z_hi  = H(yp_top, cradle_len).y;   // the top of the cradle, at the spine
    z_lo  = z_hi - coupon_len;
    // Where the cut-back face lands at the bottom of the band. The face is
    // tilted with the cradle, so this is the coupon's own lowest y and what
    // it has to be centred against.
    zp_lo = (z_lo - z0 - coupon_back * s) / c;
    y_lo  = y0 - coupon_back * c + zp_lo * s;

    translate([0, -(y_lo + y_max) / 2, -z_lo])
        intersection() {
            difference() {
                monolith();

                // everything further back than coupon_back behind the phone
                in_cradle()
                    translate([-tall, -tall - coupon_back, -tall])
                        cube([2 * tall, tall, 2 * tall]);
            }

            translate([-tall, -tall, z_lo])
                cube([2 * tall, 2 * tall, coupon_len]);
        }
}

// ---------------------------------------------------------------- output

// Each piece lying the way it is sliced, centered on the origin.
//
//     hook    cap down, so the channel opens upward and the cap's chamfered
//             top is the first layer
//     spine   back face down, so the columns are vertical holes and the two
//             tabs are the bed-side layer of a flat plate; on the front face
//             they would be a 76 mm slab hanging 1.35 mm off the bed
//     cradle  upright on its flat bottom, the way it hangs - no rotation at
//             all, just set down on the plate
module posed(name) {
    if (name == "hook")
        translate([0, (spine_t + y_min) / 2, 0])
            rotate([180, 0, 0])
                children();
    else if (name == "spine")
        translate([0, (z_sp_lo + z_sp_hi) / 2, 0])
            rotate([90, 0, 0])
                children();
    else if (name == "cradle")
        translate([0, -y_max / 2, overall_len])
            children();
}

module maybe_posed(name) {
    if (orient == "print") posed(name) children();
    else children();
}

// One plate, three pieces, no yaw: every one of them is 89 across, and they
// stack well inside the safe envelope.
plate_gap = 8.0;

module plate() {
    spine_d  = z_sp_hi - z_sp_lo;
    cradle_d = y_max;
    hook_d   = spine_t - y_min;
    total    = spine_d + cradle_d + hook_d + 2 * plate_gap;

    translate([0, total / 2 - spine_d / 2, 0])
        posed("spine") piece_spine();
    translate([0, total / 2 - spine_d - plate_gap - cradle_d / 2, 0])
        posed("cradle") piece_cradle();
    translate([0, -total / 2 + hook_d / 2, 0])
        posed("hook") piece_hook();
}

// The spine lifted straight off its two sockets, which is the one direction
// it can go: backward, the way it went on, and the way the glass blocks.
explode = 25.0;

if (show == "plate") {
    plate();
} else if (show == "exploded") {
    piece_hook();
    piece_cradle();
    color("Goldenrod") translate([0, -explode, 0]) piece_spine();
} else if (show == "coupon") {
    coupon();
} else if (show == "hook" || show == "spine" || show == "cradle") {
    maybe_posed(show) piece(show);
} else {
    monolith();

    if (show == "fitcheck") {
        // The panel, centered in the channel, its top edge on the cap.
        color("PaleTurquoise", 0.35)
            translate([-W / 2 - 20, -gch + glass_fit / 2, -cap_t - 230])
                cube([W + 40, glass_t, 230]);

        // The phone, on the ledge, centered in the slack.
        color("DimGray", 0.5)
            in_cradle()
                translate([-phone_w / 2, phone_fit_t / 2, 0])
                    cube([phone_w, phone_t, phone_l]);
    }
}
