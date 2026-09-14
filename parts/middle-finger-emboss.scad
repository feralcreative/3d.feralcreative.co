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
// points forward and up, about 21° above horizontal along +y. Rotating tilt
// about X stands it up. 68° was fitted to the finger's centreline alone on
// 2026-09-13; 66° is fitted to the whole of what is kept, which is what
// actually matters, because the face is one plane and everything above
// bottom_z has to lie near it.
//
// Measured off the mesh, over everything above z = 55, the back strays from
// its own flattest plane by:
//
//   tilt      58    60    62    64    65    66    67    68    70    72
//   spread  11.5   7.9   7.7   5.5   5.0   4.6   7.1   5.0   5.4   5.7
//
// So there is no angle that lays the whole thing flat: the finger's back and
// the fist's back are a few degrees apart, and every tilt trades one against
// the other. 66° is the flattest of them, and it also puts the worst of the
// lift-off at the FINGERTIP, where a rounded tip standing a few mm off the
// face reads as the tip curling. At 68° the worst of it was at the bottom
// edge instead, where it reads as the hand not sitting down properly.
//
// ⚠️ back_y IS MEASURED AT THIS TILT. Change tilt and it is wrong, and
// nothing will tell you: the cut simply lands somewhere else on the hand.
// Re-measure it as the minimum y of the mesh above bottom_z after the turn.
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
// bottom_z IS WHAT DECIDES HOW MUCH HAND YOU GET, and it was set at 60,
// which is just above the knuckles — the finger with a sliver under it, and
// no hand to speak of (Ziad, 2026-09-14). It is the bottom cut that was
// hiding the hand, not the angle. What it costs, at tilt 66, measured:
//
//   bottom_z    65    60    55    50    45    40
//   hand wide 72.3  86.9  95.3  96.6  96.2  94.9
//   worst lift 4.0   4.0   4.6   5.9   6.9   7.7
//
// 55 is the knuckles across their full width for almost nothing: the hand's
// back leaves the face by 4.6 mm at worst against 4.0 at 60. Below that the
// fist stops getting wider and only the lift-off grows.
//
// PRINTED FACE DOWN: the flat cut is the bed, the finger and knuckles stand
// up off it, and their rounded fronts are the top of the print. flip = false
// draws it standing, as mounted, finger up and the flat face at y = 0.

/* [Output] */
flip = true;   // printed orientation, flat face on the bed; false shows it standing as mounted

/* [Mesh] */
mesh_file  = "../_incoming/MiddleFingerToScale.stl";
mesh_scale = 25.4;   // the mesh is in inches
tilt       = 66;     // deg about X to stand the finger up; back_y is measured at THIS angle

/* [Cut] */
bite         = 2.0;   // mm the face cuts into the finger's back, so it is joined along a land (mm)
relief_depth = 30;    // from the face; the finger is 18 deep, the knuckle roll runs 40-60 out and is cut flat here (mm)
bottom_z     = 55;    // squared-off bottom, in the stood-up frame: the knuckles at their full width, and the hand's back still within 4.6 of the face (mm)

/* [Hidden] */
big = 400;
// The back of the finger and hand after the turn: the minimum y of the mesh
// above bottom_z, measured off it at tilt 66. Tied to tilt — see above.
back_y = -127.89;

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
