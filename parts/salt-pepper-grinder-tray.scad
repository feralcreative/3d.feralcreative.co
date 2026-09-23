// Salt and pepper grinder tray — a two-well dust catcher for the shelf.
//
// Both grinders have a Ø90 round base and both shed a little grit every time
// they are used. The tray gives each one a well to stand in and puts the
// floor of that well BELOW where the grinder's base sits, so the dust it
// drops never ends up under the base itself.
//
// THE PEDESTAL IS THE WHOLE IDEA. Each grinder stands on three pads, Ø16 and
// 3 mm tall, on a Ø74 bolt circle — roughly under the outer rim of the base,
// where a grinder's foot is flat and stiff. Three and not four: three points
// cannot rock, and four on a shelf that is not flat will. The base overhangs
// the pads by 8 mm on every side, so everything that falls off the mechanism
// falls past them onto the moat floor 3 mm below and stays there. The pads are
// separate rather than a continuous ring for the same reason: a ring would
// seal the middle of the well off from the moat and give the dust two pockets
// to live in instead of one open floor to wipe.
//
// THE NOTCH. One per well, 22 wide, cut into the front lip down to a sill 2 mm
// above the moat floor. It is a pour spout and a finger hole: the 2 mm of wall
// left under it is the dam that keeps settled dust in, and everything above it
// is out of the way of a cloth. Tipping the whole tray over a bin empties it
// over the notch.
//
// THE OUTLINE is the hull of the two wells — a stadium, 199.77 × 100.98 —
// because there is nothing for a corner to do here except collect grit. The
// wells sit at either end of it and a 5.79 divider separates them, so each
// grinder lands in its own place instead of drifting into the other.
//
// FIT. The well is drawn 0.25 over its nominal Ø93 because a bore this size
// comes off this machine about 0.25 under on diameter (slicing reference §
// hole compensation — the 0.60 figure is a small-bore number and does not
// apply). Nominal leaves 1.5 of clearance per side: enough to drop a grinder
// in without aiming, not enough for it to wander off the pads.
//
// ORIENTATION. Printed as drawn, floor down, no supports. Every overhang is a
// fillet or the 22-wide notch sill, which is a short ledge over solid wall.
// It is a 200 mm footprint on a 205 safe envelope, so it wants the plate to
// itself and it is a long first layer — check the corners are down before
// walking away.

include <../lib/BOSL2/std.scad>

/* [Grinders] */

// Diameter of the grinder's base. Both grinders measure the same.
grinder_d = 90;     // mm

// Clearance per side between the base and the well wall.
well_gap = 1.5;     // mm

// Rim material left between the two wells.
divider_w = 5.79;   // mm

/* [Tray] */

// Wall thickness at the rim. On the two-exposed-face ladder for this machine:
// 0.42 outer + 7 x 0.45 inner + 0.42 outer.
wall_w = 3.99;      // mm

// Floor under the moat.
floor_t = 2.4;      // mm

// Lip height, measured from the moat floor to the top of the rim.
rim_h = 6;          // mm

/* [Pedestal] */

// The grinder stands on these. Three is deliberate — see the header.
pad_count = 3;
pad_d = 16;         // mm
pad_bolt_d = 74;    // mm, diameter of the circle the pads sit on
pad_h = 3;          // mm, how far the base is lifted off the moat floor
pad_round = 1;      // mm, rounding on the pad's top edge

/* [Notch] */

// Width of the pour notch cut into the front lip of each well.
notch_w = 22;       // mm

// Wall left standing under the notch. This is the dust dam.
notch_sill = 2;     // mm

/* [Finish] */

// Rounding on the outside top edge, which includes the notch scallops.
edge_r = 1.2;       // mm

// Rounding on the top edge of each well.
lip_r = 1;          // mm

// Fillet where the well wall meets the moat floor, so a cloth can reach it.
moat_r = 1.2;       // mm

// Chamfer at the foot, to kill the elephant's foot and let the tray sit flat.
foot_ch = 0.6;      // mm

// Diameter added to the well to land on nominal after printing. A large bore
// on this machine comes out about this much under.
bore_comp = 0.25;   // mm

eps = 0.01;         // mm, overshoot on subtracted solids
$fn = 120;

/* [Hidden] */

well_d   = grinder_d + 2 * well_gap;
pitch    = well_d + divider_w;
body_w   = well_d + 2 * wall_w;
body_l   = pitch + well_d + 2 * wall_w;
body_h   = floor_t + rim_h;
sill_z   = floor_t + notch_sill;
well_x   = [-pitch / 2, pitch / 2];

// The outline is the hull of the two wells: a rect rounded by half its width.
outline  = rect([body_l, body_w], rounding = body_w / 2);

// Each notch is a disc centred exactly on the outer surface at the front of
// its well, so half of it lands in the wall and half is already outside.
notches  = [for (x = well_x) move([x, -body_w / 2], circle(d = notch_w))];

module grinder_tray() {
    difference() {
        union() {
            // Floor and the lower band of wall — the part the notch does not
            // reach. One solid stadium; the wells are cut out of it below.
            offset_sweep(outline, height = sill_z,
                         bottom = os_chamfer(height = foot_ch));

            // Upper band of wall, with the notches taken out of its outline so
            // the top rounding follows them round instead of stopping at them.
            up(sill_z)
                offset_sweep(difference([outline], notches[0], notches[1]),
                             height = body_h - sill_z,
                             top = os_circle(r = edge_r));
        }

        // The wells. The cutter's bottom face IS the moat floor; its rounded
        // bottom edge leaves the fillet where that floor meets the wall.
        for (x = well_x)
            move([x, 0, floor_t])
                cyl(d = well_d + bore_comp, h = rim_h + eps,
                    rounding1 = moat_r, anchor = BOTTOM);

        // Break the top edge of each well.
        for (x = well_x)
            move([x, 0, body_h])
                rounding_hole_mask(d = well_d + bore_comp, rounding = lip_r);
    }

    // The pads go on after the wells are cut, or the cut would take them.
    for (x = well_x)
        move([x, 0, floor_t])
            zrot_copies(n = pad_count, d = pad_bolt_d)
                cyl(d = pad_d, h = pad_h, rounding2 = pad_round, anchor = BOTTOM);
}

grinder_tray();
