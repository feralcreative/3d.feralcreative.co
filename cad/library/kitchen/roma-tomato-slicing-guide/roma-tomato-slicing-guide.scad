// Note 1.

/* [Tomato] */

// Note 2.
/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

tomato_d = 58;      // Note 4.

trough_gap = 1;     // Note 5.

/* [Slices] */

// Note 6.
pitch = 5;          // Note 7.

fin_t = 2.64;       // Note 8.

slot_n = 21;

// Note 9.
wall_w = 16;        // Note 10.

guide_over = 6;     // Note 11.

end_w = 6;          // Note 12.

lead_w = 0.3;       // Note 13.

lead_h = 2;         // Note 14.

/* [Base] */

// Note 15.
floor_t = 6;        // Note 16.

floor_kerf = 2;     // Note 17.

/* [Hidden] */

$fn = 96;
eps = 0.01;
slot_w = pitch - fin_t;
trough_r = tomato_d / 2 + trough_gap;
body_l = 2 * end_w + (slot_n - 1) * pitch + slot_w;
body_w = 2 * trough_r + 2 * wall_w;
trough_z = floor_t + trough_r;     // Note 18.
body_h = floor_t + tomato_d + guide_over;

function slot_x(i) = end_w + slot_w / 2 + i * pitch;

module slot_cut(i) {
    translate([slot_x(i) - slot_w / 2, -eps, floor_t - floor_kerf])
        cube([slot_w, body_w + 2 * eps, body_h]);
    // Note 19.
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
        // Note 20.
        translate([-eps, body_w / 2, trough_z])
            rotate([0, 90, 0])
                cylinder(r = trough_r, h = body_l + 2 * eps);
        // Note 21.
        translate([-eps, body_w / 2 - trough_r, trough_z])
            cube([body_l + 2 * eps, 2 * trough_r, body_h]);
        for (i = [0 : slot_n - 1]) slot_cut(i);
    }
}

// Note 22.

module feral_default_output_0e513b4eb0af() {
slicing_guide();
}

module feral_assembly_view_0e513b4eb0af(explode=false) {
feral_default_output_0e513b4eb0af();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_0e513b4eb0af();
else feral_assembly_view_0e513b4eb0af(view == "exploded");

// Notes

// Note 1. Roma tomato slicing guide — 5 mm crosswise slices, knife guided both sides.
//
// The tomato lies on its side in a half-round trough cut into a solid block,
// and the block is sliced through by a row of slots across its width. A knife
// dropped into a slot is held square on both sides of the fruit, so every
// slice comes out the same 5 mm thick.
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
// THE PITCH IS FIXED; THE SPLIT OF IT IS NOT. Fin plus slot is 5 and nothing
// else. A fin is a thin feature with two exposed faces, and on the installed
// profile those rungs are 0.84 + 0.45n (0.42 outer walls, 0.45 inner; slicing
// reference — the design reference's 0.42n ladder is wrong here). The fin is
// 2.64, the 6-line rung, which leaves a 2.36 slot: wide enough for the spine of
// Ziad's Global knives (just over 2.0 at the heel), which rides down inside the
// slots at the end of a cut now that the walls clear the tomato. The price is
// slop: a blade that is thinner than the slot where it cuts can wander in it.
// The first draft cut ⅛" (3.175) on a 1.29 fin and a 1.885 slot, which the
// spine would have jammed in.
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

// Note 2. Largest roma diameter the trough should take.

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. mm
// Clearance between the tomato and the trough, on the radius.

// Note 5. mm

// Note 6. Slice thickness: fin + slot.

// Note 7. mm
// Fin thickness along the pitch. 2.64 is a 6-line wall on the 0.4 nozzle.

// Note 8. mm
// Number of slots, which is slices + 1. 21 covers a 100 mm tomato.

// Note 9. Wall left outside the trough. Widened from 12 when the walls went up.

// Note 10. mm
// How far the walls rise above the top of the largest tomato.

// Note 11. mm
// Solid block at each end, unslotted.

// Note 12. mm
// Flare at the top of each slot, per side. Leaves a 2.04 tip on each fin.

// Note 13. mm
// Height over which the flare closes back to the slot width.

// Note 14. mm

// Note 15. Solid floor under the bottom of the trough.

// Note 16. mm
// How far each slot runs below the bottom of the trough.

// Note 17. mm

// Note 18. centre line of the trough

// Note 19. lead-in flare: a wedge from lead_w wider at the top down to slot_w

// Note 20. the round trough the tomato lies in

// Note 21. straight sides from the centre line up

// Note 22. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
