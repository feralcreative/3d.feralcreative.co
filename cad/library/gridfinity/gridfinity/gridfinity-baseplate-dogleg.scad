// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-plate-modules.scad>

/* [Grid] */
run = 5;                // Note 3.
leg = 2;                // Note 4.

/* [Plate] */
floor_thickness = 3.0;  // Note 5.

/* [Magnets] */
magnet_hole_d = 10.5;   // Note 6.

magnet_cav_h = 2.2;     // Note 7.
magnet_skin = 0.4;      // Note 8.

$fn = 48;

// Note 9.

module feral_default_output_982633bb8bd2() {
plate_blocks([[0, 0, run, leg], [0, 0, leg, run]], floor_ht = floor_thickness,
             magnet_hole_d = magnet_hole_d,
             magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
}

module feral_assembly_view_982633bb8bd2(explode=false) {
feral_default_output_982633bb8bd2();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_982633bb8bd2();
else feral_assembly_view_982633bb8bd2(view == "exploded");

// Notes

// Note 1. gridfinity-baseplate-dogleg.scad — an L-shaped gridfinity baseplate on a flat
// floor, so it can be stuck down with adhesive strips.
//
// Sized to a 9 x 9 in corner: the long run is 5 cells (210 mm, 8.27 in), the
// closest whole-cell fit under 9 in on the 42 mm grid. The bite out of the
// inside corner is 3 x 3 cells (Ziad, 2026-09-22), which sets the legs at 2
// cells wide (84 mm, 3.31 in). 16 cells, 210 x 210 mm bounding box.
//
// Widening the legs back to 3 cells while keeping a 3 x 3 bite means a 6 x 6
// envelope — 252 mm, past the 220 mm bed entirely, not just past the safe
// envelope. The run and the leg width cannot both grow.
//
// ⚠️ 210 mm on BOTH axes is over the 205 x 205 safe envelope in
// docs/flashforge-ad5m-pro-scad-reference.md — 5 mm to the bed edge each way,
// inside the unprobed border, with no room to rotate the plate. Ziad's call,
// 2026-09-22: print it in one piece and accept the corner-lift risk. Split it
// at the inside corner if a print does lift.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. cells along each arm, outside corner to tip

// Note 4. cells across each arm; the missing corner is (run - leg) square

// Note 5. mm of flat sheet under the frame; 0 leaves the
// sockets open. Skin, cavity, skin — see below.

// Note 6. mm cavity for a 10 mm disc — the same +0.5 the
// vendored bins allow on a 6 mm one. 0 for no magnets.

// Note 7. mm tall: a 2 mm disc and 0.2 to drop it in

// Note 8. mm over the cavity and under it — 2 layers at 0.2.
// The discs go in at a pause and the top skin bridges
// over them; nothing is glued and no face is broken.

// Note 9. The two arms, sharing the leg x leg block at the outside corner.
// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
