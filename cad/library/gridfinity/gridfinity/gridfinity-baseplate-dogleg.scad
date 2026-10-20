// gridfinity-baseplate-dogleg.scad — an L-shaped gridfinity baseplate on a flat
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

include <gridfinity-plate-modules.scad>

/* [Grid] */
run = 5;                // cells along each arm, outside corner to tip
leg = 2;                // cells across each arm; the missing corner is (run - leg) square

/* [Plate] */
floor_thickness = 3.0;  // mm of flat sheet under the frame; 0 leaves the
                        // sockets open. Skin, cavity, skin — see below.

/* [Magnets] */
magnet_hole_d = 10.5;   // mm cavity for a 10 mm disc — the same +0.5 the
                        // vendored bins allow on a 6 mm one. 0 for no magnets.
magnet_cav_h = 2.2;     // mm tall: a 2 mm disc and 0.2 to drop it in
magnet_skin = 0.4;      // mm over the cavity and under it — 2 layers at 0.2.
                        // The discs go in at a pause and the top skin bridges
                        // over them; nothing is glued and no face is broken.

$fn = 48;

// The two arms, sharing the leg x leg block at the outside corner.
plate_blocks([[0, 0, run, leg], [0, 0, leg, run]], floor_ht = floor_thickness,
             magnet_hole_d = magnet_hole_d,
             magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
