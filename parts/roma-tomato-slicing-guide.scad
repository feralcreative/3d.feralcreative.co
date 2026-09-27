// Roma tomato slicing guide — ⅛" crosswise slices, knife guided both sides.
//
// The tomato lies on its side in a half-round trough cut into a solid block,
// and the block is sliced through by a row of slots across its width. A knife
// dropped into a slot is held square on both sides of the fruit, so every
// slice comes out the same ⅛" (3.175 mm) thick.
//
// THE TROUGH IS ROUND so the tomato seats in it and cannot roll or wander
// sideways under the knife. It is drawn trough_gap over the tomato's radius,
// and above its centre line the sides go straight up, so the widest part of
// the fruit still drops in from above.
//
// THE WALLS CLEAR THE TOP OF THE TOMATO by guide_over, so the knife is already
// in both slots before its edge touches the skin. Walls that stopped at the
// centre line left the whole first half of every cut unguided.
//
// THE FINS ARE U-SHAPED PLATES, NOT A COMB. Everything left between two slots
// is one plate that follows the trough round: down one wall, under the fruit,
// and up the other. Each plate is rooted along its whole 90 mm bottom edge to a
// solid floor, and each arm widens toward the root because the block is square
// outside and round inside. The first draft stood 35 mm teeth up from the floor
// on a 10 mm root, and those would snap.
//
// THE PITCH IS FIXED; THE SPLIT OF IT IS NOT. Fin plus slot is 3.175 and
// nothing else. The fin is 1.29 because a fin is a thin feature with two
// exposed faces, and on the installed profile that rung is 0.42 + 0.45 + 0.42
// (slicing reference; the design reference's 1.26/1.68 ladder is wrong here).
// That leaves a 1.885 slot, which clears a serrated tomato knife or a thin
// slicer. The next rung, 1.74, would leave 1.435 — stiffer fins, but a lot of
// knives will not go in.
//
// THE SLOTS RUN BELOW THE TROUGH. A knife that stops on the trough surface
// leaves the bottom skin uncut, so every slot goes floor_kerf below the bottom
// of the trough, and the edge finishes below the fruit.
//
// THE LEAD-IN. The top of each slot flares by lead_w per side, so the knife
// finds its slot without aiming.
//
// ORIENTATION. Printed as drawn, floor down, no supports. The trough is open
// at the top and every slot is open from the top down.

/* [Tomato] */

// Largest roma diameter the trough should take.
tomato_d = 58;      // mm

// Clearance between the tomato and the trough, on the radius.
trough_gap = 1;     // mm

/* [Slices] */

// Slice thickness: fin + slot. ⅛" = 3.175.
pitch = 3.175;      // mm

// Fin thickness along the pitch. 1.29 is a 3-line wall on the 0.4 nozzle.
fin_t = 1.29;       // mm

// Number of slots, which is slices + 1. 32 covers a 100 mm tomato.
slot_n = 32;

// Wall left outside the trough. Widened from 12 when the walls went up.
wall_w = 16;        // mm

// How far the walls rise above the top of the largest tomato.
guide_over = 6;     // mm

// Solid block at each end, unslotted.
end_w = 6;          // mm

// Flare at the top of each slot, per side. Leaves a 0.69 tip on each fin.
lead_w = 0.3;       // mm

// Height over which the flare closes back to the slot width.
lead_h = 2;         // mm

/* [Base] */

// Solid floor under the bottom of the trough.
floor_t = 6;        // mm

// How far each slot runs below the bottom of the trough.
floor_kerf = 2;     // mm

/* [Hidden] */

$fn = 96;
eps = 0.01;
slot_w = pitch - fin_t;
trough_r = tomato_d / 2 + trough_gap;
body_l = 2 * end_w + (slot_n - 1) * pitch + slot_w;
body_w = 2 * trough_r + 2 * wall_w;
trough_z = floor_t + trough_r;     // centre line of the trough
body_h = floor_t + tomato_d + guide_over;

function slot_x(i) = end_w + slot_w / 2 + i * pitch;

module slot_cut(i) {
    translate([slot_x(i) - slot_w / 2, -eps, floor_t - floor_kerf])
        cube([slot_w, body_w + 2 * eps, body_h]);
    // lead-in flare: a wedge from lead_w wider at the top down to slot_w
    hull() {
        translate([slot_x(i) - slot_w / 2 - lead_w, -eps, body_h])
            cube([slot_w + 2 * lead_w, body_w + 2 * eps, eps]);
        translate([slot_x(i) - slot_w / 2, -eps, body_h - lead_h])
            cube([slot_w, body_w + 2 * eps, eps]);
    }
}

module slicing_guide() {
    difference() {
        cube([body_l, body_w, body_h]);
        // the round trough the tomato lies in
        translate([-eps, body_w / 2, trough_z])
            rotate([0, 90, 0])
                cylinder(r = trough_r, h = body_l + 2 * eps);
        // straight sides from the centre line up
        translate([-eps, body_w / 2 - trough_r, trough_z])
            cube([body_l + 2 * eps, 2 * trough_r, body_h]);
        for (i = [0 : slot_n - 1]) slot_cut(i);
    }
}

slicing_guide();
