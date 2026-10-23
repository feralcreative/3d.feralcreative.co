// Note 1.

/* [Output] */
flip = true;   // Note 2.

standalone = true;

/* [Mesh] */
mesh_file  = "originals/middle-finger.stl";
mesh_scale = 1.0;   // Note 3.
tilt       = -3;    // Note 4.
spin       = 0;     // Note 5.

/* [Cut] */
relief_depth = 16.0;  // Note 6.
bottom_z     = 1.6;   // Note 7.

/* [Hidden] */
big = 400;

// Note 8.

art_w_mm  = 62.43;    // Note 9.
art_h_mm  = 149.94;   // Note 10.
art_cx_mm = 4.55;     // Note 11.
art_cz_mm = 76.57;    // Note 12.

back_y = -38.50;

module stood_up() rotate([0, 0, spin]) rotate([tilt, 0, 0])
  scale(mesh_scale) import(mesh_file, convexity = 10);

// Note 13.

module emboss() {
  // Note 14.

  rotate([0, 0, 180]) translate([0, -(back_y + relief_depth), 0]) intersection() {
    stood_up();
    translate([-big / 2, back_y - 1, bottom_z]) cube([big, relief_depth + 1, big]);
  }
}

// Note 15.

module finger_mark(w, d)
  scale([w / art_w_mm, d / relief_depth, w / art_w_mm])
    translate([-art_cx_mm, 0, -art_cz_mm]) emboss();

module oriented() {
  if (flip) rotate([90, 0, 0]) children();   // Note 16.
  else children();
}

if (standalone) oriented() emboss();

// Notes

// Note 1. middle-finger-wrist-emboss.scad
//
// The middle finger, again, as a relief to stick on the side of things — the
// same treatment as middle-finger-emboss.scad, on the other hand in
// originals/ (Ziad, 2026-09-16: cut the back off this hand just like we did
// the other). Stood up, sliced flat through the palm side, and squared off
// at the wrist, so what is left is the back of the hand standing proud of one
// flat face that goes against the object.
//
// IT IS A DIFFERENT MESH AND NOT A BETTER VERSION OF THE SAME ONE. This is
// originals/middle-finger.stl: a slimmer hand with a forearm stub, the finger
// fully extended, the other three curled, the thumb across them. The other
// file's mesh is MiddleFingerToScale.stl, a broad life-size fist cut off at
// the wrist. Both parts stand; neither replaces the other, and nothing that
// includes the other file is touched by this one.
//
// THE MESH IS ALREADY IN MILLIMETRES AND ALREADY UPRIGHT, which is the whole
// difference in method. 69.23 x 60.68 x 150.00, exactly 150.00 tall — a round
// number, so somebody scaled it to that deliberately. The wrist is cut flat
// on z = 0, the finger points up +z, the back of the hand faces -y and the
// palm +y, and the thumb and index are on +x. So there is no standing-up
// rotation to fit here: the tilt below is a 3 degree trim, not the 57 degrees
// the other one needs.
//
// It arrives clean: one shell, genus 0, 29,296 triangles, every edge shared by
// exactly two of them, no degenerate triangles. Measured, not assumed. Like
// the other one it is measured rather than authored — nothing about the hand
// is a decision of this file. The matching original is now retained in
// originals/middle-finger.stl with this model; its millimetre scale is unchanged.
//
// ⚠️ IT READS AS A LEFT HAND. Back toward you, the thumb and index are on the
// right, which is a left hand — a right one has them on the left from behind.
// mirror([1, 0, 0]) turns it into a right hand and nothing else about the part
// changes, because the cut plane is perpendicular to that mirror. Say the word.
//
// WHY THERE IS A TILT AT ALL, on a mesh that is already standing: the back of
// this hand is not plumb. Measured in 2 mm bands, as a distance in from the
// deepest knuckle, the back recedes 15.6 mm at the forearm and 6.8 at the
// fingertip, while the finger is only 17.7 mm deep front to back where it
// leaves the fist. So an untilted plane has nowhere to stand. All three of
// these were BUILT at tilt 0 to watch it fail, rather than argued from the
// numbers:
//
// 15 mm in   the forearm's back is BEHIND the plane, z 8 to 24 is cut away
// entirely, and the piece comes out as two shells (Genus: -1)
// 16 mm in   the forearm survives as a 0.4 mm knife edge, and the flat face
// has already given up at z 141.5 — the top 8.5 mm of the finger
// is standing off it
// 18 mm in   the face stops at z 102.4, and that is the whole finger, from
// where it leaves the fist, floating clear
//
// A small negative tilt fixes both ends at once, because it rotates the
// finger's front and the wrist's back in opposite directions relative to the
// plane. The usable window for relief_depth, being [deepest the back recedes,
// shallowest the front reaches] over the whole height:
//
// tilt        0     -1     -2     -3     -4     -5     -6
// back     15.6   14.4   13.3   12.1   12.9   17.0   19.3
// front     9.9   12.7   14.9   16.6   15.1   17.0   18.8
// window   -5.7   -1.8    1.7    4.5    2.2    0.0   -0.5
//
// A negative window is that disconnected piece; anything under about 2 mm
// means the slab is a knife edge somewhere. -3 is the peak and it is a real
// peak, not a plateau: one degree either side halves it. Past -5 the tip is
// swinging back faster than the plane can follow and the numbers cross again.
//
// Those two rows are sampled off the mesh's VERTICES, which reads a little
// pessimistic — a band's surface can reach past the vertices that bound it,
// and on the topmost band of the fingertip it does. Use them to choose a tilt;
// use a built mesh, as above, to believe a number.
//
// ⚠️ back_y IS MEASURED AT THIS TILT AND THIS SPIN. Change either and it is
// wrong, and nothing will tell you — the cut simply lands somewhere else on
// the hand. Re-measure it as the minimum y of the mesh after the turns.
//
// SPIN IS ZERO, unlike the other file, and deliberately. This hand faces
// square on already. Turning it +8 degrees does buy 1.5 mm of slab at the
// thinnest point (the back recedes 10.6 instead of 12.1), which is real but
// not needed at the depth below — and it costs the square-on presentation,
// which on a hand making this particular gesture is the thing you are looking
// at. The knob is here because the other file's is, and because that 1.5 mm is
// there to spend if the wrist ever needs it.
//
// HOW DEEP: 16.0, and everything lands. Read off the built mesh, the flat face
// runs from z 1.60 to 150.36 with NO 2 mm band of the piece missing it, so the
// plane cuts the hand's whole 149.94 mm from the forearm to the tip and there
// is no floating fingertip on this one — which the other file has to live with.
// The only thing standing off the face is the last 1.18 mm of the tip's crown,
// and that is the dome over its own flat, not a gap. The face comes out 52% of
// its own bounding rectangle: 4,867 mm² of glue area.
//
// The thinnest the slab gets is 3.91 mm, at z 19.6 in the middle of the
// forearm, where the back recedes 12.09. The knuckles stand the full 16 proud
// and the finger, whose own back sits 4.1 to 10.0 in, stands 6.0 to 11.9.
//
// The ceiling is 16.63 — above that the crown of the tip floats. The floor is
// about 14: below that the forearm thins past 2 mm and the cut stops being a
// slab and starts being a peel.
//
// THE BOTTOM IS SQUARED OFF, barely. The 3 degree tilt slants the wrist's
// flat cut, but only across the 16 mm of it that survives the slab, so the
// slant is 0.34 mm end to end. bottom_z = 1.6 trims that to a flat horizontal
// face and costs 1.6 mm of forearm, which also puts the cut clear of the
// mesh's own bottom plane rather than coplanar with it. Lower it below -0.23
// to keep every last sliver and accept the slope.
//
// PRINTED FACE DOWN: the flat cut is the bed, the hand stands up off it, and
// the cross-section only ever shrinks with height, so there is nothing to
// support. flip = false draws it standing, as mounted, finger up and the flat
// face at y = 0.

// Note 2. printed orientation, flat face on the bed; false shows it standing as mounted
// False when another part includes this file for finger_mark() and wants the
// modules without the hand turning up at its origin. Nothing else uses it.

// Note 3. the mesh is already in millimetres

// Note 4. deg about X, to plumb the back of the hand; NOT to stand it up. back_y is measured at THIS angle

// Note 5. deg about the VERTICAL, after the tilt. Zero: this hand faces square on. back_y is measured at THIS too

// Note 6. the slab's thickness, measured in from the deepest knuckle. Every band of the hand lands at this depth; past 16.63 the fingertip floats, 14 and the forearm peels (mm)

// Note 7. squared-off bottom, in the stood-up frame. Just above the tilted wrist face, which spans 1.18 to 1.52 inside the slab (mm)

// Note 8. The relief's own size, measured off the built mesh: what it comes out wide
// and tall, and where the middle of that is. A part that puts this on one of
// its faces needs them to place and scale it, and OpenSCAD cannot measure an
// import.
//
// ⚠️ Tied to tilt, spin and relief_depth exactly as back_y is. Change any of
// them and re-measure these too, or finger_mark() places the artwork off
// centre and scales it wrong.

// Note 9. across

// Note 10. up

// Note 11. the middle of that, across

// Note 12. and up
// The back of the whole hand after the turns: the minimum y of the mesh,
// measured off it at tilt -3. Tied to tilt — see above.

// Note 13. Standing, as mounted: the flat face on y = 0, the knuckles standing out
// toward +y, the finger up.

// Note 14. The slab, from the knuckle surface inward; then the flat face to y = 0,
// and turned to look at the knuckles rather than the cut.

// Note 15. The relief as artwork for another part: centred on the origin across and up,
// its flat face on y = 0, scaled to w wide, and its depth squashed to d rather
// than scaled with it. Squashing is the point — at full scale a relief w wide
// stands w * relief_depth / art_w_mm proud, which on anything small is far
// more than the face it is sitting in can give back.

// Note 16. face (y = 0) to the bed, relief up
