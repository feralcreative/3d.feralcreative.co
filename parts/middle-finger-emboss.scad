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
// The tilt is fitted to whatever is being kept, and what is kept is now the
// whole fist (Ziad, 2026-09-14: the entire fist, and cut only the back).
// With all of it in, the measure that matters is how much of its height
// actually lands on the face — where the back comes within bite of the
// plane — because that is what holds it on:
//
//   tilt        54    55    56    57    58    60    62    64    66    68
//   land 2mm  62.5  70.0  77.5  82.5  75.0  57.5  55.0  47.5  30.0  40.0
//   land 4mm  80.0  90.0 100.0 102.5 102.5 100.0  82.5  72.5  70.0  60.0
//
// 57° is the best of them and it is not close: 82.5 mm of the height gets a
// land, against 30 at the 66° this replaced and 40 at the 68° before that.
// Both of those were fitted to the FINGER — 68° to its centreline, 66° to
// the finger plus the knuckles — which is the right fit when the finger is
// most of what you keep and the wrong one once the fist is.
//
// The finger's back and the fist's back are a few degrees apart, so no angle
// lays all of it flat. At 57° the leftover goes into the fingertip, which
// ends up standing about 9 mm off the face: the finger tips away from the
// wall as it rises, which is what a finger does.
//
// ⚠️ back_y IS MEASURED AT THIS TILT. Change tilt and it is wrong, and
// nothing will tell you: the cut simply lands somewhere else on the hand.
// Re-measure it as the minimum y of the mesh above bottom_z after the turn.
//
// THE CUT. One plane, and only at the back. Everything behind
// y = back_y + bite goes, so the finger keeps a
// flat land along its back — that is what ties it to the face; with bite = 0
// the finger would touch the face along a line and could be snapped off it.
//
// bite HAS TO REACH THE FINGERTIP. back_y is the back of the fist, and the
// finger tips away from the wall as it rises, so its back climbs away from
// that plane — 1.5 mm up at the knuckles, 3.0 by mid-finger, 10.5 at the
// tip. At the 2.0 it used to be, the top 25 mm of the finger never touched
// the face at all: it stood off it and the land ran out (Ziad, 2026-09-14:
// cut more of the back until there is no gap between the finger and the
// back). 10.5 is where that last gap closes and 11.0 gives the tip an
// actual land instead of a tangent point.
//
// It costs finger. The cut is the same plane all the way down, so closing a
// 10.5 gap at the tip takes 9 mm off the back of the finger at its base,
// and the finger ends up standing about 8 mm proud along its whole length
// rather than 17 in the middle and nothing at the top. That is the trade:
// an even half-round finger that is attached everywhere, against a rounder
// one that lets go a third of the way up. Everything further out than relief_depth from the face
// ⚠️ THE FRONT IS NOT CUT. relief_depth used to cap it at 30 from the face,
// which sliced the knuckles off flat — and because the cap is measured from
// the face, every millimetre of extra bite took another millimetre off the
// front as well. Ziad, 2026-09-14: wrong side, the front is untouched, all
// we are doing is trimming the back so it sits flat on something. So
// relief_depth is 0, which means no cap, and the fist stands its full ~90 mm
// off the face. Set it to a number again only if you want it back as a slab.
//
// THERE IS NO BOTTOM CUT any more. bottom_z sat at 60, just above the
// knuckles, so the relief was the finger and a sliver with no hand to speak
// of; then at 55 for the knuckles. Ziad, 2026-09-14: the entire fist, cut
// only the back. So bottom_z now sits below the mesh and takes nothing, and
// the wrist's slanted end is part of the piece — it tapers off the face over
// the last 20 mm or so, which is the wrist going away from the wall. Raise
// bottom_z above -17.9 to square it off again.
//
// PRINTED FACE DOWN: the flat cut is the bed, the finger and knuckles stand
// up off it, and their rounded fronts are the top of the print. flip = false
// draws it standing, as mounted, finger up and the flat face at y = 0.

/* [Output] */
flip = true;   // printed orientation, flat face on the bed; false shows it standing as mounted

/* [Mesh] */
mesh_file  = "../_incoming/MiddleFingerToScale.stl";
mesh_scale = 25.4;   // the mesh is in inches
tilt       = 57;     // deg about X to stand the finger up, fitted to the fist's back; back_y is measured at THIS angle

/* [Cut] */
bite         = 11.0;  // how far the face cuts in past back_y. 10.5 is where the last gap under the fingertip closes; 11.0 gives the tip a land rather than a tangent point (mm)
relief_depth = 0;     // 0 = no front cap at all, the whole fist stands off the face. Set it to cut the front back to a slab that many mm thick (mm)
bottom_z     = -30;   // squared-off bottom, in the stood-up frame. Below the mesh, which bottoms out at -17.9, so nothing is cut off the bottom at all (mm)

/* [Hidden] */
big = 400;
// The back of the whole hand after the turn: the minimum y of the mesh,
// measured off it at tilt 57. Tied to tilt — see above.
back_y = -113.27;

module stood_up() rotate([tilt, 0, 0]) scale(mesh_scale) import(mesh_file, convexity = 10);

// Standing, as mounted: the flat face on y = 0, the relief standing out
// toward +y, the finger up.
module emboss() {
  translate([0, -(back_y + bite), 0]) intersection() {
    stood_up();
    translate([-big / 2, back_y + bite, bottom_z])
      cube([big, relief_depth > 0 ? relief_depth : big, big]);
  }
}

module oriented() {
  if (flip) rotate([90, 0, 0]) children();   // face (y = 0) to the bed, relief up
  else children();
}

oriented() emboss();
