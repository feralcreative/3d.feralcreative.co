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
// AND A TURN ABOUT THE VERTICAL, after the tilt. The fist does not face
// square on to the knuckle plane, so turning it brings more of it inside the
// slab (Ziad, 2026-09-14: turn it to expose more of the fist).
//
// ⚠️ IT HAS TO BE THE VERTICAL, and for a while it was not. The first
// version turned the mesh about its own long axis BEFORE the tilt, which in
// the mounted frame is a vector 84% along the face's normal and only 54%
// along the vertical — so five sixths of it was spinning the picture and the
// rest was doing the work. It looked like something was happening because
// the hand rotated in the view. Ziad asked whether it was the right axis; it
// was not. Turning about the face's normal cannot change what the cut keeps,
// because it does not change any distance to the plane.
//
// Counting mesh points inside a 20 mm slab, against the turn:
//
//   about the long axis (wrong)   3: 53638   8: 53754  12: 53897  18: 54228
//   about the vertical (right)    4: 53707   8: 53942  12: 54483  16: 55217
//                                20: 56091  24: 54763
//
// The wrong axis moved it 1.1% across 18 degrees, which is noise. The right
// one moves it 7% and peaks at +20, which is where it sits. That is also
// where the finger does best: at +20 it lands in every band from z 95 to
// 139, where at 0 it skipped 115 and at 18 it skipped one too.
//
// ⚠️ back_y IS MEASURED AT THIS TILT AND THIS SPIN. Change either and it is
// wrong, and nothing will tell you: the cut simply lands somewhere else on
// the hand. Re-measure it as the minimum y of the mesh after the turns.
//
// THE CUT IS ON THE PALM SIDE, and nothing at all comes off the knuckles.
// The knuckle side is what you look at; the palm side is what goes against
// the object. So the piece is the slab of the hand from its knuckle surface
// inward, relief_depth thick, and the flat face is the far end of that slab
// — the cut through the palm, the curled fingers and the thumb.
//
// It was the other way round until 2026-09-14, cutting a flat on the KNUCKLE
// side and capping the palm side too. That flattened the very thing the
// piece is for (Ziad: you are cutting the front and only the front), and the
// face it left was the knuckles rather than the palm, so it read as a hand
// seen from the wrong side. There is no `bite` any more: a bite is a cut
// into the display surface and there is no reason to want one.
//
// HOW THICK: FAR ENOUGH THAT THE FINGER IS CUT, not merely enclosed. At 25
// the finger sat wholly inside the slab with 1.8 mm of air behind it, so it
// would have bridged over the mounting surface instead of sitting on it.
//
// The finger's back is not parallel to the face — measured at tilt 57, in
// 2 mm bands, its distance in from the knuckle surface is:
//
//   z    143  141  139  137  135  133  131  129  127  125  123
//   in  18.7 20.2 21.9 22.6 23.1 23.2 23.1 22.7 22.3 21.6 20.9
//   z    121  119  117  115  113  111  109  107  105  103  101   99   97   95
//   in  20.3 20.1 19.7 19.6 19.8 20.3 20.5 20.6 20.5 20.4 20.3 20.1 19.8 19.8
//
// It bulges to 23.2 in the upper third, sits around 20 through the lower two
// thirds, and the rounded end of the tip falls back to 18.7.
//
// 19.0 touches everywhere but the last 2 mm of the tip, and costs 4 mm off
// the finger's back where it bulges. 20.0 is what it is at, because Ziad
// asked for a little less and said a gap behind the finger is fine as long
// as it is attached top and bottom (2026-09-14): at 20.0 it lands from z 123
// to 139 at the top and from z 99 to 113 lower down, the fist carries it
// below that, and what is left is a 1.4 mm gap over the last 4 mm of the tip
// and a couple of 0.3 mm dips in between.
//
// The ceiling is 23.2: above that the whole finger floats. The floor is
// 18.7: below that nothing is gained and the finger is being sliced for
// nothing. The same number is the fist's thickness, because it is one plane.
//
// The bottom is squared off at bottom_z, in the stood-up frame; it sits
// below the mesh by default, so nothing is cut off the bottom either.
//
// PRINTED FACE DOWN: the flat cut is the bed, the finger and knuckles stand
// up off it, and their rounded fronts are the top of the print. flip = false
// draws it standing, as mounted, finger up and the flat face at y = 0.

/* [Output] */
flip = true;   // printed orientation, flat face on the bed; false shows it standing as mounted

// False when another part includes this file for finger_mark() and wants the
// modules without the hand turning up at its origin. Nothing else uses it.
standalone = true;

/* [Mesh] */
mesh_file  = "../_incoming/MiddleFingerToScale.stl";
mesh_scale = 25.4;   // the mesh is in inches
tilt       = 57;     // deg about X to stand the finger up, fitted to the fist's back; back_y is measured at THIS angle
spin       = 20;     // deg about the VERTICAL, after the tilt: turns the fist toward you. back_y is measured at THIS too

/* [Cut] */
relief_depth = 20.0;  // the slab's thickness, measured in from the knuckle surface. Lands the finger top and bottom and leaves a small gap between; see the profile above. 18.7 touches even the tip, 23.2 and the finger floats entirely (mm)
bottom_z     = -30;   // squared-off bottom, in the stood-up frame. Below the mesh, which bottoms out at -17.9, so nothing is cut off the bottom at all (mm)

/* [Hidden] */
big = 400;

// The relief's own size, measured off the built mesh: what it comes out
// wide and tall, and where the middle of that is. A part that puts this on
// one of its faces needs them to place and scale it, and OpenSCAD cannot
// measure an import.
//
// ⚠️ Tied to tilt, spin and relief_depth exactly as back_y is. Change any of
// them and re-measure these too, or finger_mark() places the artwork off
// centre and scales it wrong.
art_w_mm  = 91.17;    // across
art_h_mm  = 128.16;   // up
art_cx_mm = -19.94;   // the middle of that, across
art_cz_mm = 80.36;    // and up
// The back of the whole hand after the turn: the minimum y of the mesh,
// measured off it at tilt 57. Tied to tilt — see above.
back_y = -109.36;

module stood_up() rotate([0, 0, spin]) rotate([tilt, 0, 0])
  scale(mesh_scale) import(mesh_file, convexity = 10);

// Standing, as mounted: the flat face on y = 0, the knuckles standing out
// toward +y, the finger up.
module emboss() {
  // The slab, from the knuckle surface inward; then the flat face to y = 0,
  // and turned to look at the knuckles rather than the cut.
  rotate([0, 0, 180]) translate([0, -(back_y + relief_depth), 0]) intersection() {
    stood_up();
    translate([-big / 2, back_y - 1, bottom_z]) cube([big, relief_depth + 1, big]);
  }
}

// The relief as artwork for another part: centred on the origin across and
// up, its flat face on y = 0, scaled to w wide, and its depth squashed to d
// rather than scaled with it. Squashing is the point — at full scale a
// relief w wide stands w * relief_depth / art_w_mm proud, which on anything
// small is far more than the face it is sitting in can give back.
module finger_mark(w, d)
  scale([w / art_w_mm, d / relief_depth, w / art_w_mm])
    translate([-art_cx_mm, 0, -art_cz_mm]) emboss();

module oriented() {
  if (flip) rotate([90, 0, 0]) children();   // face (y = 0) to the bed, relief up
  else children();
}

if (standalone) oriented() emboss();
