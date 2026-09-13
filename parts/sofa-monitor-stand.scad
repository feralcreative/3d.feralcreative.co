// sofa-monitor-stand.scad
//
// The monitor stand that lives on the sofa arm, in two pieces: a round TOP
// the monitor's foot sits in, and a BASE that straddles the arm and carries a
// square plug up into the top's underside. This file is the top, the plug,
// and the fit between them. It is NOT the base: the old base was an arch
// shaped to a rounded arm, and the new sofa has a square one, so that part
// gets drawn again from scratch and will include this file for the plug.
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
// coupon; in use it is part of whatever base includes this file.
//
// INCLUDING THIS FILE. Set show = "none" after the include and it emits
// nothing; every parameter is prefixed stand_ so it collides with nothing in
// the including file. Call stand_plug() to put the plug at the origin,
// standing on z = 0, centred in x and y.

/* [Output] */
// top     — the disc, as printed
// plug    — the plug alone, standing on z = 0: a fit coupon for the socket
// coupon  — the socket cut out of the disc as a 90 mm square block, with the
//           plug beside it; tests the fit without printing 160 mm of disc
// none    — nothing, for a file that includes this one for its numbers
show = "top";  // [top, plug, coupon, none]

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

/* [Coupon] */
stand_coupon_w   = 90.0;  // square block cut from the disc around the socket (mm)
stand_coupon_gap = 8.0;   // clear air between block and plug on the plate (mm)

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

if (show == "top")    stand_top();
if (show == "plug")   stand_plug();
if (show == "coupon") stand_coupon();

echo(str("plug = ", stand_plug_w, " sq x ", stand_plug_h, " mm; socket = ",
         stand_socket_w, " sq x ", stand_socket_depth, " mm"));
