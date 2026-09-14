// middle-finger-emboss.scad
//
// The middle finger, as a relief to stick on the side of things: the hand
// from _incoming/MiddleFingerToScale.stl stood up so the finger is vertical,
// then cut flat along the back of the finger and the back of the hand, and
// capped at a depth, so what is left is the finger and the knuckles standing
// proud of one flat face that goes against the object (Ziad, 2026-09-13:
// "maximum finger and knuckles, but no gap between the finger and the back
// surface").
//
// THE MESH is a Meshmixer export in INCHES — 6.5 tall, a life-size fist — so
// it is scaled by 25.4 here. It is measured, not authored: nothing about the
// hand is a decision of this file. It lives in _incoming/, which is not
// committed, so this file builds only on a machine that has it.
//
// STANDING IT UP. In the mesh the wrist is cut flat on z = 0 and the finger
// points forward and up, about 21° above horizontal along +y. Rotating 68°
// about X puts the finger's centreline vertical (fitted 2026-09-13 to the
// finger's cross-section centres; after the turn its back runs within
// ±0.8 mm of one plane over its whole length, which is the check). The back
// of the finger is then flush with the back of the hand, at y = back_y —
// which is why a cut "at the back of the finger" is a cut along the back of
// the whole hand.
//
// THE CUT. Everything behind y = back_y + bite goes, so the finger keeps a
// flat land bite deep along its back — that is what ties it to the face;
// with bite = 0 the finger would touch the face along a line and could be
// snapped off it. Everything further out than relief_depth from the face
// goes too, or the whole fist would stand 100 mm proud: the finger is 18 mm
// deep, the knuckle ridge starts about 40 mm out, so relief_depth is the
// dial between "finger on a plate" and "fist". The bottom is squared off at
// bottom_z, in the stood-up frame, so the wrist's slanted end is gone.
//
// PRINTED FACE DOWN: the flat cut is the bed, the finger and knuckles stand
// up off it, and their rounded fronts are the top of the print. flip = false
// draws it standing, as mounted, finger up and the flat face at y = 0.

/* [Output] */
flip = true;   // printed orientation, flat face on the bed; false shows it standing as mounted

/* [Mesh] */
mesh_file  = "../_incoming/MiddleFingerToScale.stl";
mesh_scale = 25.4;   // the mesh is in inches
tilt       = 68;     // deg about X to stand the finger up

/* [Cut] */
bite         = 2.0;   // mm the face cuts into the finger's back, so it is joined along a land (mm)
relief_depth = 30;    // from the face; the finger is 18 deep, the knuckle roll runs 40-60 out and is cut flat here (mm)
bottom_z     = 60;    // squared-off bottom, in the stood-up frame: below ~57 the back of the hand leaves the face, so the piece would float off it (mm)

/* [Hidden] */
big = 400;
// The back of the finger and hand after the turn, measured off the mesh.
back_y = -131.3;

module stood_up() rotate([tilt, 0, 0]) scale(mesh_scale) import(mesh_file, convexity = 10);

// Standing, as mounted: the flat face on y = 0, the relief standing out
// toward +y, the finger up.
module emboss() {
  translate([0, -(back_y + bite), 0]) intersection() {
    stood_up();
    translate([-big / 2, back_y + bite, bottom_z]) cube([big, relief_depth, big]);
  }
}

module oriented() {
  if (flip) rotate([90, 0, 0]) children();   // face (y = 0) to the bed, relief up
  else children();
}

oriented() emboss();
