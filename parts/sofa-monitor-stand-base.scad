// sofa-monitor-stand-base.scad
//
// The base of the sofa monitor stand: a saddle that straddles the sofa arm
// and carries the plug the round top drops onto. The top, the plug, and the
// fit between them live in sofa-monitor-stand.scad, which this file includes
// — nothing about the joint is sized here.
//
// THE ARM IS SQUARE, measured by Ziad 2026-09-13: 180 mm across. Ziad wants
// the legs about 90 mm down its sides. The old base was an arch shaped to a
// rounded arm on the previous sofa; this is not that part and shares nothing
// with it except the plug and the 95 mm run along the arm.
//
// EXCEPT THE TOP OF THE ARM IS NOT FLAT. It has some poof: the first coupon,
// with a flat ceiling, sat on the crown with 10 mm of daylight at each side
// (Ziad, 2026-09-13). So the cavity's ceiling is a shallow circular arch,
// arm_crown high at the centre, meeting the legs at the sides. The deck's
// top face stays flat for the disc; the deck is deck_t at the centre and
// deck_t + arm_crown at the sides.
//
// THE FORM. An inverted U: a flat deck across the arm with a plate leg down
// each side, every outside edge above the feet rounded 10 mm with spherical
// corners, the two inside bends rounded 5, and the outside edge of
// each foot rounded foot_r, corners included — a small round, since the leg
// is only 4.44 thick and the foot has to keep a flat to stand on. The plug
// stands on
// the deck dead centre. The legs are what stop the stand walking sideways, so
// they are sized to the arm plus a little air, not to the arm plus room —
// upholstery gives; a saddle that rattles on the arm rocks under a monitor.
// base_clearance is that air, per side, and is the number to change if the
// first one will not go on.
//
// PRINTED UPSIDE DOWN, ON THE PLUG. Ziad's call, 2026-09-13, over a loose
// key. Plug up needs a 190 mm bridge or a support block the size of the
// cavity; on the plug the deck's underside sits 5 mm over the bed with only
// a 5 mm slab of support under it, and the legs go straight up. So the
// support interface lands on the deck's TOP face — the one the disc rests
// on. That is a bearing surface, not a cosmetic one, but the disc seats on it
// over 160 mm and a little roughness there changes nothing. flip = false
// draws it the way up it is used, z = 0 at the foot of the legs.
//
// WALLS. The legs are 4.44 mm — ten loops on the 0.4 nozzle, which the
// profile prints as two loops a side over infill. The deck is 10 mm; it is
// horizontal, so its thickness is layers, not loops, and anything on 0.2
// is fine. It was 8 until the outside got its 10 mm round — a quarter-round
// has to be as deep as it is wide, and one deeper than the deck would come
// out under it as a knife edge.

include <sofa-monitor-stand.scad>

/* [Output] */
// base   — the saddle, complete
// slice  — an arm-fit coupon: the saddle's section through the middle, legs
//          cut down to slice_leg, no plug, lying flat with base_slice_depth
//          as its height. Everything that matters to the fit — cavity width,
//          bend radius, deck and leg thickness — is in that section; the
//          plug is proven in sofa-monitor-stand.scad and the leg length
//          proves nothing but costs most of the print
show = "base";  // [base, slice]

// Printed orientation, plug down on the bed. false draws it in use.
flip = true;

/* [Arm — measured] */
arm_w          = 180.0;  // sofa arm, across (mm)
arm_crown      = 10.0;   // how much higher the arm's top is at the centre than at its edges (mm)
base_clearance = 0.5;    // air between arm and leg, per side (mm)

/* [Saddle] */
leg_drop     = 90.0;   // legs below the deck's underside (mm)
leg_t        = 4.44;   // leg plate, ten loops on the 0.4 nozzle (mm)
deck_t       = 10.0;   // deck, underside to the face the disc sits on; not less than round_r (mm)
base_depth   = 95.0;   // run along the arm; what the old base had (mm)
round_r      = 10.0;   // every outside edge above the feet, corners spherical; not more than deck_t (mm)
bend_r       = 5.0;    // the inside bends, deck to leg (mm)
foot_r       = 2.0;    // the outside edge of each foot, ends and corners included; less than leg_t (mm)

/* [Slice] */
base_slice_depth = 10.0;  // height of the coupon as it lies on the bed (mm)
slice_leg        = 20.0;  // legs kept below the deck's underside, enough to grip the arm (mm)

/* [Quality] */
$fn = 64;

// ---- derived ---------------------------------------------------------------

cavity_w = arm_w + 2 * base_clearance;   // 181.0
base_w   = cavity_w + 2 * leg_t;         // 189.88
base_h   = leg_drop + arm_crown + deck_t; // 108.0, foot of the legs to the deck face
// The arch: a circle through the cavity's two top corners and arm_crown
// above their chord.
crown_r  = (cavity_w * cavity_w / 4 + arm_crown * arm_crown) / (2 * arm_crown);   // 414.5

// The cavity in section: cavity_w wide, legs h tall, the ceiling arched
// arm_crown above that at the centre, and the two corners where arch meets
// leg rounded bend_r. Open at the bottom, well past y = 0, so the rounding
// pass never reaches the feet.
module cavity_profile(h) {
  offset(r = bend_r) offset(delta = -bend_r) union() {
    translate([-cavity_w / 2, -bend_r - 1]) square([cavity_w, h + bend_r + 1]);
    intersection() {
      translate([0, h + arm_crown - crown_r]) circle(r = crown_r, $fn = 1440);
      translate([-cavity_w / 2, h - 1]) square([cavity_w, arm_crown + 1]);
    }
  }
}

// The outside, before the cavity: a block with every edge above the feet
// rounded round_r and the corners spherical, and the bottom edge rounded
// foot_r all the way round, corners included — a hull of four spheres over
// four posts standing on four tori. Because the plan corners are rounder
// than the legs are thick, each leg's front and back ends thin to an edge
// over their last 8 mm, as any plate rounded past its own thickness must;
// the ends do no work and the edge is vertical, so it prints as a wall. The
// cavity cut leaves the INSIDE foot edge square, so each foot keeps a flat
// leg_t - foot_r wide to stand on.
module outer_body() {
  hull() for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * (base_w / 2 - round_r), sy * (base_depth / 2 - round_r), 0]) {
      translate([0, 0, base_h - round_r]) sphere(r = round_r);
      translate([0, 0, foot_r]) cylinder(r = round_r, h = base_h - round_r - foot_r);
      translate([0, 0, foot_r]) rotate_extrude() translate([round_r - foot_r, 0]) circle(r = foot_r);
    }
}

// In use: z = 0 at the foot of the legs, plug on top.
module stand_base() {
  assert(deck_t >= round_r, "round_r deeper than the deck: it would cut into the cavity ceiling");
  assert(foot_r < leg_t, "foot_r not less than leg_t: the foot would have no flat to stand on");
  assert(foot_r <= round_r, "foot_r larger than round_r: the foot torus would not fit inside the plan round");
  difference() {
    outer_body();
    rotate([90, 0, 0])
      linear_extrude(base_depth + 2 * eps, center = true, convexity = 4)
        cavity_profile(leg_drop);
  }
  // Sunk into the deck by the sphere's polar gap: an OpenSCAD sphere has no
  // vertex at its pole, its top ring sits at r * cos(180 / $fn), so the
  // hull's top face is 0.012 mm under base_h at $fn = 64 and a plug set
  // exactly there is a second shell. That plus eps off 5 mm of plug, against
  // a 0.4 mm seat, is nothing.
  translate([0, 0, base_h - round_r * (1 - cos(180 / $fn)) - eps]) stand_plug();
}

// A w-wide, h-tall rectangle standing on y = 0, top corners rounded r_top
// and bottom corners r_bot: the saddle's outside in elevation, through the
// middle where the plan rounds do not reach.
module rounded_box(w, h, r_top, r_bot) {
  hull() {
    for (sx = [-1, 1]) {
      translate([sx * (w / 2 - r_top), h - r_top]) circle(r = r_top);
      translate([sx * (w / 2 - r_bot), r_bot]) circle(r = r_bot);
    }
  }
}

// The coupon: the section drawn flat in XY and extruded base_slice_depth up,
// so it prints as a short U outline in one go. Not a slice of stand_base —
// that would be plug-down or standing on its feet, and either way tall.
module stand_base_slice() {
  h = slice_leg + arm_crown + deck_t;
  linear_extrude(base_slice_depth, convexity = 4)
    difference() {
      rounded_box(base_w, h, round_r, foot_r);
      cavity_profile(slice_leg);
    }
}

module oriented() {
  if (flip) translate([0, 0, base_h + stand_plug_h]) rotate([180, 0, 0]) children();
  else children();
}

if (show == "base")  oriented() stand_base();
if (show == "slice") stand_base_slice();

echo(str("saddle = ", base_w, " x ", base_depth, " x ", base_h + stand_plug_h,
         " mm over the plug; cavity = ", cavity_w, " wide x ", leg_drop, " deep at the sides, ",
         leg_drop + arm_crown, " at the crown"));
