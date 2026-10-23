// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>

/* [Grinders] */

// Note 3.

grinder_d = 80;     // Note 4.

well_gap = 1.5;     // Note 5.

divider_w = 5.79;   // Note 6.

/* [Tray] */

// Note 7.

wall_w = 3.99;      // Note 8.

floor_t = 4.4;      // Note 9.

rim_h = 6;          // Note 10.

/* [Pedestal] */

// Note 11.
pad_count = 3;
pad_d = 16;         // Note 12.

pad_bolt_d = grinder_d - pad_d;   // Note 13.
pad_h = 3;          // Note 14.
pad_round = 1;      // Note 15.

/* [Silicone feet] */

// Note 16.

foot_bore_d     = 13.0;  // Note 17.
foot_bore_depth = 2.0;   // Note 18.
foot_inset      = 5.0;   // Note 19.

/* [Notch] */

// Note 20.
notch_w = 22;       // Note 21.

notch_sill = 2;     // Note 22.

/* [Finish] */

// Note 23.
edge_r = 1.2;       // Note 24.

lip_r = 1;          // Note 25.

moat_r = 1.2;       // Note 26.

foot_ch = 0.6;      // Note 27.

bore_comp = 0.25;   // Note 28.

eps = 0.01;         // Note 29.
$fn = 120;

/* [Hidden] */

well_d   = grinder_d + 2 * well_gap;
pitch    = well_d + divider_w;
body_w   = well_d + 2 * wall_w;
body_l   = pitch + well_d + 2 * wall_w;
body_h   = floor_t + rim_h;
sill_z   = floor_t + notch_sill;
well_x   = [-pitch / 2, pitch / 2];

// Note 30.

foot_y   = body_w / 2 - foot_inset - foot_bore_d / 2;

// Note 31.
outline  = rect([body_l, body_w], rounding = body_w / 2);

// Note 32.

notches  = [for (x = well_x) move([x, -body_w / 2], circle(d = notch_w))];

module grinder_tray() {
    difference() {
        union() {
            // Note 33.

            offset_sweep(outline, height = sill_z,
                         bottom = os_chamfer(height = foot_ch));

            // Note 34.

            up(sill_z)
                offset_sweep(difference([outline], notches[0], notches[1]),
                             height = body_h - sill_z,
                             top = os_circle(r = edge_r));
        }

        // Note 35.

        for (x = well_x)
            move([x, 0, floor_t])
                cyl(d = well_d + bore_comp, h = rim_h + eps,
                    rounding1 = moat_r, anchor = BOTTOM);

        // Note 36.
        for (x = well_x)
            move([x, 0, body_h])
                rounding_hole_mask(d = well_d + bore_comp, rounding = lip_r);

        // Note 37.
        for (x = well_x, y = [-foot_y, foot_y])
            move([x, y, -eps])
                cyl(d = foot_bore_d, h = foot_bore_depth + eps, anchor = BOTTOM);
    }

    // Note 38.
    for (x = well_x)
        move([x, 0, floor_t])
            zrot_copies(n = pad_count, d = pad_bolt_d)
                cyl(d = pad_d, h = pad_h, rounding2 = pad_round, anchor = BOTTOM);
}

// Note 39.

module feral_default_output_589ca19d4a6b() {
grinder_tray();
}

module feral_assembly_view_589ca19d4a6b(explode=false) {
feral_default_output_589ca19d4a6b();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_589ca19d4a6b();
else feral_assembly_view_589ca19d4a6b(view == "exploded");

// Notes

// Note 1. Salt and pepper grinder tray — a two-well dust catcher for the shelf.
//
// Both grinders have a Ø80 round base and both shed a little grit every time
// they are used. The tray gives each one a well to stand in and puts the
// floor of that well BELOW where the grinder's base sits, so the dust it
// drops never ends up under the base itself.
//
// THE PEDESTAL IS THE WHOLE IDEA. Each grinder stands on three pads, Ø16 and
// 3 mm tall, on a Ø64 bolt circle — roughly under the outer rim of the base,
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
// THE OUTLINE is the hull of the two wells — a stadium, 179.77 × 90.98 —
// because there is nothing for a corner to do here except collect grit. The
// wells sit at either end of it and a 5.79 divider separates them, so each
// grinder lands in its own place instead of drifting into the other.
//
// FIT. The well is drawn 0.25 over its nominal Ø83 because a bore this size
// comes off this machine about 0.25 under on diameter (slicing reference §
// hole compensation — the 0.60 figure is a small-bore number and does not
// apply). Nominal leaves 1.5 of clearance per side: enough to drop a grinder
// in without aiming, not enough for it to wander off the pads.
//
// THE FEET are the same stick-on silicone bumpers as the phone shower holder,
// in the same Ø13 x 2.0 recesses: four of them, one under each end of each
// well, out where a foot does the most against a knock. They are the reason
// the floor is 4.4 and not 2.4 — a 2 mm recess in a 2.4 floor leaves 0.4 mm
// over it, so the floor carries the recess plus the 2.4 it had before.
//
// ORIENTATION. Printed as drawn, floor down, no supports. Every overhang is a
// fillet, the 22-wide notch sill, or the roof of a foot recess, which the
// slicer bridges across 13 mm of flat ceiling ten layers up.
// The footprint is 180 × 91, inside the 205 safe envelope with room to spare
// now that the grinders came down to Ø80 — it was 200 long at Ø90, which was
// within 5 mm of the edge.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. Diameter of the grinder's base. Both grinders measure the same.
// Ø80, corrected from Ø90 (Ziad, 2026-09-23).

// Note 4. mm
// Clearance per side between the base and the well wall.

// Note 5. mm
// Rim material left between the two wells.

// Note 6. mm

// Note 7. Wall thickness at the rim. On the two-exposed-face ladder for this machine:
// 0.42 outer + 7 x 0.45 inner + 0.42 outer.

// Note 8. mm
// Floor under the moat. 2.4 of solid over a 2.0 foot recess; see the header.

// Note 9. mm
// Lip height, measured from the moat floor to the top of the rim.

// Note 10. mm

// Note 11. The grinder stands on these. Three is deliberate — see the header.

// Note 12. mm
// Diameter of the circle the pads sit on. DERIVED, not a number: it puts the
// pads' outer edge on the base's rim, which is the whole point of where they
// are, and it has to move when grinder_d does. Held at a fixed 74 it survived
// the drop to Ø80 as pads standing 5 mm PROUD of the base and buried 3.5 mm
// into the well wall.

// Note 13. mm

// Note 14. mm, how far the base is lifted off the moat floor

// Note 15. mm, rounding on the pad's top edge

// Note 16. Recesses in the underside for stick-on silicone bumpers. Same feet, and the
// same numbers, as parts/phone-shower-holder.scad.

// Note 17. mm

// Note 18. mm

// Note 19. mm, bore edge to the outer surface

// Note 20. Width of the pour notch cut into the front lip of each well.

// Note 21. mm
// Wall left standing under the notch. This is the dust dam.

// Note 22. mm

// Note 23. Rounding on the outside top edge, which includes the notch scallops.

// Note 24. mm
// Rounding on the top edge of each well.

// Note 25. mm
// Fillet where the well wall meets the moat floor, so a cloth can reach it.

// Note 26. mm
// Chamfer at the foot, to kill the elephant's foot and let the tray sit flat.

// Note 27. mm
// Diameter added to the well to land on nominal after printing. A large bore
// on this machine comes out about this much under.

// Note 28. mm

// Note 29. mm, overshoot on subtracted solids

// Note 30. The feet sit at the well centres in x, so each one is under the load, and as
// far out in y as foot_inset allows. At x = +-pitch/2 the outline is at its
// tangent point, where the straight side and the end arc are the same distance
// away, so one number holds for both.

// Note 31. The outline is the hull of the two wells: a rect rounded by half its width.

// Note 32. Each notch is a disc centred exactly on the outer surface at the front of
// its well, so half of it lands in the wall and half is already outside.

// Note 33. Floor and the lower band of wall — the part the notch does not
// reach. One solid stadium; the wells are cut out of it below.

// Note 34. Upper band of wall, with the notches taken out of its outline so
// the top rounding follows them round instead of stopping at them.

// Note 35. The wells. The cutter's bottom face IS the moat floor; its rounded
// bottom edge leaves the fillet where that floor meets the wall.

// Note 36. Break the top edge of each well.

// Note 37. The foot recesses, cut up into the underside.

// Note 38. The pads go on after the wells are cut, or the cut would take them.

// Note 39. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
