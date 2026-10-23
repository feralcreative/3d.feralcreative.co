// Note 1.

/* [Output] */
// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

show = "set";  // [set, clip]

// Note 4.
count = 1;

/* [Shelf] */
// Note 5.
shelf_w = 21;

/* [Wire] */
// Note 6.
wire_d = 3.5;
// Note 7.
groove_w = 3.8;
// Note 8.
groove_depth = 3.5;

/* [Clip] */
// Note 9.
clip_w = 18;
// Note 10.
clip_len = 15;
// Note 11.
cover_t = 1.4;
// Note 12.
front_r = 1.5;
// Note 13.
back_r = 0.4;

/* [Plate] */
// Note 14.
plate_gap = 4;
// Note 15.
plate_cols = 4;

/* [Colors] */
clip_color = "SlateGray";

/* [Hidden] */
$fn = 96;
eps = 0.01;

clip_t = groove_depth + cover_t;

assert(clip_w <= shelf_w, "clip_w is wider than the shelf");
assert(groove_w > wire_d, "groove_w must clear the wire");
assert(front_r + back_r <= clip_t, "edge rounds overlap");

// Note 16.
module clip_profile() {
  difference() {
    hull() {
      for (s = [-1, 1]) {
        translate([s * (clip_w / 2 - back_r), back_r]) circle(r = back_r);
        translate([s * (clip_w / 2 - front_r), clip_t - front_r]) circle(r = front_r);
      }
    }
    // Note 17.
    hull() {
      translate([-groove_w / 2, -eps]) square([groove_w, eps]);
      translate([0, groove_depth - groove_w / 2]) circle(d = groove_w);
    }
  }
}

// Note 18.
module simplisafe_wire_guide() {
  color(clip_color)
    rotate([90, 0, 0])
      translate([0, 0, -clip_len / 2])
        linear_extrude(height = clip_len, convexity = 4) clip_profile();
}

// Note 19.
module clip_face_down() {
  translate([0, 0, clip_t]) rotate([180, 0, 0]) simplisafe_wire_guide();
}

module print_set() {
  pitch_x = clip_w + plate_gap;
  pitch_y = clip_len + plate_gap;
  rows = ceil(count / plate_cols);
  for (i = [0 : count - 1])
    translate([
      (i % plate_cols - (plate_cols - 1) / 2) * pitch_x,
      (floor(i / plate_cols) - (rows - 1) / 2) * pitch_y,
      0,
    ])
      clip_face_down();
}

// Note 20.

module feral_default_output_4713f7da4156() {
if (show == "clip") simplisafe_wire_guide();
else print_set();
}

module feral_assembly_view_4713f7da4156(explode=false) {
feral_default_output_4713f7da4156();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_4713f7da4156();
else feral_assembly_view_4713f7da4156(view == "exploded");

// Notes

// Note 1. simplisafe-wire-guide.scad
//
// Taped-on clips that hold a 3.5 mm round wire up the side of a shelf whose
// edge is 21 mm wide (Ziad, 2026-10-11).
//
// THE WIRE RUNS BEHIND THE CLIP. Each clip is a plain plate with a groove
// down its back; lay the wire on the shelf, set a clip over it, and the
// tape on the two rails either side of the groove holds both down. The
// shelf itself is the groove's fourth wall. (Ziad, 2026-10-11: the first
// draft was a snap channel on the front, wire showing; he wanted it behind.)
// doorbell-wire-channel.scad is the same idea as a continuous raceway.
//
// THE GROOVE IS AS DEEP AS THE WIRE, so with thin tape the wire is held
// snug against the shelf. Foam tape stands the rails off the shelf by its
// own thickness and leaves the wire that much slack; take groove_depth down
// by the tape's thickness if that matters.
//
// The plate is clip_w wide, centred in shelf_w with a margin either side so
// it does not hang over the edge if placed a little off.
//
// Prints face down: the groove opens upward and nothing overhangs, and the
// rails' top surface is the smooth one, for the tape.
//
// Drawn as mounted: back against the shelf at z = 0, wire along Y, front
// facing +Z.

// Note 2. set  — count clips face down, the way they print
// clip — one clip, as mounted

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. Clips on the plate.

// Note 5. Width of the shelf face the clip sits on, mm.

// Note 6. Wire diameter, mm.

// Note 7. Groove width over the wire, mm.

// Note 8. Groove depth from the back face, mm. Wire depth for a snug hold on thin tape.

// Note 9. Width across the shelf face, mm.

// Note 10. Length along the wire, mm.

// Note 11. Plate over the groove, mm (four loops' worth of layers is plenty).

// Note 12. Round on the front edges, mm.

// Note 13. Round on the back edges, mm.

// Note 14. Gap between clips on the plate, mm.

// Note 15. Clips per row on the plate.

// Note 16. Section across the wire: x across the shelf, y out from the shelf.

// Note 17. Groove, round at its roof so the wire seats in it.

// Note 18. As mounted: back on z = 0, wire along Y.

// Note 19. Face down on the bed, groove up.

// Note 20. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
