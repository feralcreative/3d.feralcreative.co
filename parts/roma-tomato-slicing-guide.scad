// Roma tomato slicing guide — ⅛" crosswise slices, knife guided both sides.
//
// The tomato lies on its side in a channel between two combs. Every slot in
// the near comb lines up with one in the far comb, so a knife dropped into a
// matching pair is held square on both sides of the fruit and every slice
// comes out the same ⅛" (3.175 mm) thick.
//
// THE PITCH IS FIXED; THE SPLIT OF IT IS NOT. Tine plus slot is 3.175 and
// nothing else. The tine is 1.29 because a tine is a thin feature with two
// exposed faces, and on the installed profile that rung is 0.42 + 0.45 + 0.42
// (slicing reference; the design reference's 1.26/1.68 ladder is wrong here).
// That leaves a 1.885 slot, which clears a serrated tomato knife or a thin
// slicer. The next rung, 1.74, would leave 1.435 — stiffer tines, but a lot of
// knives will not go in.
//
// THE SLOTS RUN INTO THE FLOOR. A knife that stops on the floor surface leaves
// the bottom skin of the tomato uncut, so every slot continues as a groove
// floor_kerf deep across the full width, and the edge finishes below the fruit.
//
// THE LEAD-IN. The top of each slot flares by lead_w per side, so the knife
// finds its slot without aiming.
//
// ORIENTATION. Printed as drawn, floor down, no supports. The tines are
// vertical walls and the grooves are open-topped.

/* [Tomato] */

// Clear width of the channel the tomato lies in. Romas run 50–60.
cradle_w = 60;      // mm

/* [Slices] */

// Slice thickness: tine + slot. ⅛" = 3.175.
pitch = 3.175;      // mm

// Tine thickness along the pitch. 1.29 is a 3-line wall on the 0.4 nozzle.
tine_t = 1.29;      // mm

// Number of slots, which is slices + 1. 32 covers a 100 mm tomato.
slot_n = 32;

// Height of the combs above the floor.
comb_h = 35;        // mm

// Depth of each comb across the channel. Stiffens the tines.
comb_d = 10;        // mm

// Solid post at each end of both combs.
end_w = 6;          // mm

// Flare at the top of each slot, per side. Leaves a 0.69 tip on each tine.
lead_w = 0.3;       // mm

// Height over which the flare closes back to the slot width.
lead_h = 2;         // mm

/* [Base] */

// Floor thickness under the channel.
floor_t = 4;        // mm

// Depth of the knife groove cut into the floor under every slot.
floor_kerf = 2;     // mm

/* [Hidden] */

eps = 0.01;
slot_w = pitch - tine_t;
body_l = 2 * end_w + (slot_n - 1) * pitch + slot_w;
body_w = cradle_w + 2 * comb_d;
body_h = floor_t + comb_h;

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
        // the channel the tomato lies in
        translate([-eps, comb_d, floor_t])
            cube([body_l + 2 * eps, cradle_w, comb_h + eps]);
        for (i = [0 : slot_n - 1]) slot_cut(i);
    }
}

slicing_guide();
