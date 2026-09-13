// sofa-monitor-stand.scad
//
// The monitor stand that lives on the sofa arm, in two pieces: a round TOP
// the monitor's foot sits in, and a BASE that straddles the arm and carries a
// square plug up into the top's underside. Both are in this one file, as two
// parts selected with show — they used to be two files, the base including
// this one for the plug, and Ziad merged them (2026-09-13). Parameters are
// prefixed stand_ for the top and the joint, base_ for the saddle.
//
// ---- THE TOP AND THE PLUG --------------------------------------------------
//
// WHERE THE NUMBERS COME FROM. Both pieces were measured off the SketchUp
// meshes sofa-monitor-stand-top-02.stl and -bottom-02.stl on the printer
// site, which are drawn in units of 0.1 mm like the rest of that archive
// (see hobbs-chalk-holder.scad). Every dimension below is a mesh number
// divided by ten, so a number here may be a faithfully copied mistake rather
// than a decision. None has been second-guessed yet.
//
// THE TOP is a 160.8 mm disc, 20 mm thick, with a 150.8 mm dish sunk 10 mm
// into its upper face. The 5 mm lip left around the dish is rounded over with
// a 5 mm quarter-round — the full width of the lip, so it has no flat on top
// and meets the dish wall in a sharp edge at z = 20. Under the disc, dead
// centre, a 75.4 mm square socket 5.4 mm deep takes the base's plug. The
// bottom edge of the disc is square; the mesh has no chamfer there.
//
// THE PLUG is a plain 75.0 mm square block, 5.0 mm tall, that stood on the
// crown of the old arch. Against the socket that is 0.20 mm of air per side —
// the reference's "snug sliding" figure for the 0.4 nozzle — and 0.4 mm short
// of the socket's ceiling, so the disc lands on the base around the plug and
// never bottoms out on it. Both numbers are exposed as stand_fit and
// stand_seat and the plug is derived from the socket, not sized on its own.
//
// ORIENTATION. The top prints flat, dish up, as drawn: the lip's quarter-round
// is then a gentle overhang and the socket is a 75 mm bridge across its own
// ceiling at z = 5.4, which is what the old part did too. Turning it over
// would trade the bridge for a rounded overhang that starts vertical and ends
// horizontal, and that prints worse. The plug prints on its own only as a
// coupon; in use it is part of the base.
//
// ---- THE BASE --------------------------------------------------------------
//
// THE ARM IS SQUARE, measured by Ziad 2026-09-13: 180 mm across. Ziad wants
// the legs about 90 mm down its sides. The old base was an arch shaped to a
// rounded arm on the previous sofa; this is not that part and shares nothing
// with it except the plug and the 95 mm run along the arm.
//
// EXCEPT THE TOP OF THE ARM IS NOT FLAT. It has some poof: the first coupon,
// with a flat ceiling, sat on the crown with 10 mm of daylight at each side
// (Ziad, 2026-09-13). So the cavity's ceiling is a shallow circular arch,
// base_arm_crown high at the centre, meeting the legs at the sides. The deck's
// top face stays flat for the disc; the deck is base_deck_t at the centre and
// base_deck_t + base_arm_crown at the sides.
//
// THE FORM. An inverted U: a flat deck across the arm with a plate leg down
// each side, every outside edge above the feet rounded 10 mm with spherical
// corners, the two inside bends rounded 5, and the outside edge of each foot
// rounded base_foot_r, corners included — a small round, since the leg is
// only 6.66 thick and the foot has to keep a flat to stand on. The plug
// stands on the deck dead centre. The legs are what stop the stand walking
// sideways, so they are sized to the arm plus a little air, not to the arm
// plus room — upholstery gives; a saddle that rattles on the arm rocks under
// a monitor. base_clearance is that air, per side, and is the number to
// change if the first one will not go on.
//
// PRINTED UPSIDE DOWN, ON THE PLUG. Ziad's call, 2026-09-13, over a loose
// key. Plug up needs a 190 mm bridge or a support block the size of the
// cavity; on the plug the deck's underside sits 5 mm over the bed with only
// a 5 mm slab of support under it, and the legs go straight up. So the
// support interface lands on the deck's TOP face — the one the disc rests
// on. That is a bearing surface, not a cosmetic one, but the disc seats on it
// over 160 mm and a little roughness there changes nothing. base_flip = false
// draws it the way up it is used, z = 0 at the foot of the legs.
//
// WALLS. The legs are 6.66 mm — fifteen loops on the 0.4 nozzle, which the
// profile prints as two loops a side over infill. They were 4.44 until the
// coupon was in hand and felt like it would break off under a hard press
// (Ziad, 2026-09-13); the cavity did not change, the outside grew. The deck
// is 10 mm; it is horizontal, so its thickness is layers, not loops, and
// anything on 0.2 is fine. It was 8 until the outside got its 10 mm round —
// a quarter-round has to be as deep as it is wide, and one deeper than the
// deck would come out under it as a knife edge.

/* [Output] */
// top         — the disc, as printed
// base        — the saddle, complete, plug on
// plug        — the plug alone, standing on z = 0: a fit coupon for the socket
// coupon      — the socket cut out of the disc as a 90 mm square block, with
//               the plug beside it; tests the joint without printing 160 mm
//               of disc
// base-slice  — an arm-fit coupon: the saddle's section through the middle,
//               legs cut down to base_slice_leg, no plug, lying flat with
//               base_slice_depth as its height. Everything that matters to
//               the arm fit — cavity width, crown, bend radius, deck and leg
//               thickness — is in that section; the leg length proves
//               nothing but costs most of the print
show = "base";  // [top, base, plug, coupon, base-slice]

/* [Top] */
stand_top_d      = 160.8;  // disc diameter (mm)
stand_top_h      = 20.0;   // disc thickness, bottom face to lip crest (mm)
stand_dish_d     = 150.8;  // dish diameter; the lip is what is left outside it (mm)
stand_dish_depth = 10.0;   // dish floor below the lip crest (mm)
stand_lip_r      = 5.0;    // quarter-round on the lip's outer edge (mm)

/* [Socket and plug] */
stand_socket_w     = 75.4;  // socket, square, across flats (mm)
stand_socket_depth = 5.4;   // socket ceiling above the disc's bottom face (mm)
stand_fit          = 0.20;  // air between plug and socket, per side (mm)
stand_seat         = 0.40;  // socket deeper than the plug, so the disc seats on the base (mm)

/* [Socket coupon] */
stand_coupon_w   = 90.0;  // square block cut from the disc around the socket (mm)
stand_coupon_gap = 8.0;   // clear air between block and plug on the plate (mm)

/* [Base — the arm, measured] */
base_arm_w     = 180.0;  // sofa arm, across (mm)
base_arm_crown = 10.0;   // how much higher the arm's top is at the centre than at its edges (mm)
base_clearance = 0.5;    // air between arm and leg, per side (mm)

/* [Base — the saddle] */
base_flip     = true;   // printed orientation, plug down on the bed; false draws it in use
base_leg_drop = 90.0;   // legs below the deck's underside at the sides (mm)
base_leg_t    = 6.66;   // leg plate, fifteen loops on the 0.4 nozzle; was 4.44 and Ziad thought a hard push would snap it (mm)
base_deck_t   = 10.0;   // deck at the crown, underside to the face the disc sits on; not less than base_round_r (mm)
base_depth    = 95.0;   // run along the arm; what the old base had (mm)
base_round_r  = 10.0;   // every outside edge above the feet, corners spherical; not more than base_deck_t (mm)
base_bend_r   = 5.0;    // the inside bends, arch to leg (mm)
base_foot_r   = 2.0;    // the outside edge of each foot, ends and corners included; less than base_leg_t (mm)

/* [Base — arm coupon] */
base_slice_depth = 10.0;  // height of the coupon as it lies on the bed (mm)
base_slice_leg   = 20.0;  // legs kept below the deck's underside, enough to grip the arm (mm)

/* [Quality] */
// 144 facets on an 80.4 mm radius is a 0.02 mm chord, the 0.4 nozzle's figure.
$fn = 144;

/* [Hidden] */
eps = 0.01;

// ---- derived ---------------------------------------------------------------

stand_plug_w = stand_socket_w - 2 * stand_fit;      // 75.0
stand_plug_h = stand_socket_depth - stand_seat;     // 5.0
stand_top_r  = stand_top_d / 2;
stand_dish_r = stand_dish_d / 2;
stand_lip_w  = stand_top_r - stand_dish_r;           // 5.0
stand_dish_z = stand_top_h - stand_dish_depth;       // dish floor, 10.0

base_cavity_w = base_arm_w + 2 * base_clearance;                 // 181.0
base_w        = base_cavity_w + 2 * base_leg_t;                  // 194.32
base_h        = base_leg_drop + base_arm_crown + base_deck_t;    // 110.0, foot of the legs to the deck face
// The arch: a circle through the cavity's two top corners and base_arm_crown
// above their chord.
base_crown_r  = (base_cavity_w * base_cavity_w / 4 + base_arm_crown * base_arm_crown) / (2 * base_arm_crown);   // 414.5

// ---- the top ---------------------------------------------------------------

// The disc's half profile, r along x and z along y, for rotate_extrude. The
// quarter-round's centre sits on the dish wall at lip crest minus its radius,
// so with stand_lip_r equal to the lip's width the round spans the whole lip.
module stand_top_profile() {
  difference() {
    union() {
      square([stand_top_r, stand_top_h - stand_lip_r]);
      square([stand_top_r - stand_lip_r, stand_top_h]);
      translate([stand_top_r - stand_lip_r, stand_top_h - stand_lip_r])
        circle(r = stand_lip_r);
    }
    translate([-eps, stand_dish_z])
      square([stand_dish_r + eps, stand_dish_depth + eps]);
  }
}

module stand_socket() {
  translate([-stand_socket_w / 2, -stand_socket_w / 2, -eps])
    cube([stand_socket_w, stand_socket_w, stand_socket_depth + eps]);
}

module stand_top() {
  difference() {
    rotate_extrude() stand_top_profile();
    stand_socket();
  }
}

module stand_plug() {
  translate([-stand_plug_w / 2, -stand_plug_w / 2, 0])
    cube([stand_plug_w, stand_plug_w, stand_plug_h]);
}

// The block is the disc between its bottom face and the dish floor, so it
// carries the socket and its full-thickness ceiling and nothing above.
module stand_coupon() {
  intersection() {
    stand_top();
    translate([-stand_coupon_w / 2, -stand_coupon_w / 2, -eps])
      cube([stand_coupon_w, stand_coupon_w, stand_dish_z + eps]);
  }
  translate([stand_coupon_w / 2 + stand_coupon_gap + stand_plug_w / 2, 0, 0])
    stand_plug();
}

// ---- the base --------------------------------------------------------------

// The cavity in section: base_cavity_w wide, legs h tall, the ceiling arched
// base_arm_crown above that at the centre, and the two corners where arch
// meets leg rounded base_bend_r. Open at the bottom, well past y = 0, so the
// rounding pass never reaches the feet.
module base_cavity_profile(h) {
  offset(r = base_bend_r) offset(delta = -base_bend_r) union() {
    translate([-base_cavity_w / 2, -base_bend_r - 1]) square([base_cavity_w, h + base_bend_r + 1]);
    intersection() {
      translate([0, h + base_arm_crown - base_crown_r]) circle(r = base_crown_r, $fn = 1440);
      translate([-base_cavity_w / 2, h - 1]) square([base_cavity_w, base_arm_crown + 1]);
    }
  }
}

// The outside, before the cavity: a block with every edge above the feet
// rounded base_round_r and the corners spherical, and the bottom edge
// rounded base_foot_r all the way round, corners included — a hull of four
// spheres over four posts standing on four tori. Because the plan corners
// are rounder than the legs are thick, each leg's front and back ends thin
// to an edge over the round's 10 mm, as any plate rounded past its own
// thickness must; the ends do no work and the edge is vertical, so it
// prints as a wall. The cavity cut leaves the INSIDE foot edge square, so
// each foot keeps a flat base_leg_t - base_foot_r wide to stand on.
module base_outer_body() {
  hull() for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * (base_w / 2 - base_round_r), sy * (base_depth / 2 - base_round_r), 0]) {
      translate([0, 0, base_h - base_round_r]) sphere(r = base_round_r);
      translate([0, 0, base_foot_r]) cylinder(r = base_round_r, h = base_h - base_round_r - base_foot_r);
      translate([0, 0, base_foot_r]) rotate_extrude() translate([base_round_r - base_foot_r, 0]) circle(r = base_foot_r);
    }
}

// In use: z = 0 at the foot of the legs, plug on top.
module stand_base() {
  assert(base_deck_t >= base_round_r, "base_round_r deeper than the deck: it would cut into the cavity ceiling");
  assert(base_foot_r < base_leg_t, "base_foot_r not less than base_leg_t: the foot would have no flat to stand on");
  assert(base_foot_r <= base_round_r, "base_foot_r larger than base_round_r: the foot torus would not fit inside the plan round");
  difference() {
    base_outer_body();
    rotate([90, 0, 0])
      linear_extrude(base_depth + 2 * eps, center = true, convexity = 4)
        base_cavity_profile(base_leg_drop);
  }
  // Sunk into the deck by the sphere's polar gap: an OpenSCAD sphere has no
  // vertex at its pole, its top ring sits at r * cos(180 / $fn), so the
  // hull's top face is a hair under base_h and a plug set exactly there is
  // a second shell. That plus eps off 5 mm of plug, against a 0.4 mm seat,
  // is nothing.
  translate([0, 0, base_h - base_round_r * (1 - cos(180 / $fn)) - eps]) stand_plug();
}

// A w-wide, h-tall rectangle standing on y = 0, top corners rounded r_top
// and bottom corners r_bot: the saddle's outside in elevation, through the
// middle where the plan rounds do not reach.
module base_rounded_box(w, h, r_top, r_bot) {
  hull() {
    for (sx = [-1, 1]) {
      translate([sx * (w / 2 - r_top), h - r_top]) circle(r = r_top);
      translate([sx * (w / 2 - r_bot), r_bot]) circle(r = r_bot);
    }
  }
}

// The arm coupon: the section drawn flat in XY and extruded base_slice_depth
// up, so it prints as a short U outline in one go. Not a slice of
// stand_base — that would be plug-down or standing on its feet, and either
// way tall.
module stand_base_slice() {
  h = base_slice_leg + base_arm_crown + base_deck_t;
  linear_extrude(base_slice_depth, convexity = 4)
    difference() {
      base_rounded_box(base_w, h, base_round_r, base_foot_r);
      base_cavity_profile(base_slice_leg);
    }
}

module base_oriented() {
  if (base_flip) translate([0, 0, base_h + stand_plug_h]) rotate([180, 0, 0]) children();
  else children();
}

// ---- output ----------------------------------------------------------------

if (show == "top")        stand_top();
if (show == "base")       base_oriented() stand_base();
if (show == "plug")       stand_plug();
if (show == "coupon")     stand_coupon();
if (show == "base-slice") stand_base_slice();

echo(str("plug = ", stand_plug_w, " sq x ", stand_plug_h, " mm; socket = ",
         stand_socket_w, " sq x ", stand_socket_depth, " mm"));
echo(str("saddle = ", base_w, " x ", base_depth, " x ", base_h + stand_plug_h,
         " mm over the plug; cavity = ", base_cavity_w, " wide x ", base_leg_drop,
         " deep at the sides, ", base_leg_drop + base_arm_crown, " at the crown"));
