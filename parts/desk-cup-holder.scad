// Desk cup holder — a tapered collar stuck to the desktop so a mug cannot be
// knocked over.
//
// Three fixed numbers from Ziad: a Ø90 bore, Ø115 outside at the foot, Ø105
// outside at the rim, so the wall runs from 12.5 thick at the bottom to 7.5 at
// the top. Four handle slots, 25 wide, let a mug sit with its handle out in
// any of four directions. Everything the hand or the mug meets is rounded:
// the rim and every edge of every slot carry the same full round, so the top
// outline reads as one continuous rolled lip that dips into each slot and
// comes back up.
//
// HOW THE ROUNDING IS DONE. Not a hand-drawn fillet per edge. The body is
// drawn SHRUNK by lip_r on every face — bore out by lip_r, outside in by
// lip_r, top down by lip_r, slots widened by lip_r — and then grown back with
// minkowski() against a sphere of lip_r. Concave corners (the floor meeting the
// bore) come back exactly where they were; every convex edge comes back as a
// fillet of lip_r. The base is kept square by drawing the shrunk body past
// z = 0 and trimming after the growth. With lip_r at half the rim's wall the
// rim is a full half-round and the slot flanks are too; lower down, where the
// wall is thicker, the slots have a flat between two 3.5 rounds.
//
// The shape is non-convex (four slots), so the minkowski is not free. It is
// the price of a lip that is genuinely one surface, and it is paid once per
// build, not per print.
//
// THE UNDERSIDE. A 4 mm floor with a Ø60 × 1 pocket in it for a round
// double-sided gel pad: the pocket locates the pad and stops it creeping, and
// is shallower than any pad so the pad, not the floor, is what touches the
// desk. Set pad_recess_h = 0 for a plain flat underside.
//
// ORIENTATION. Printed as drawn, floor down. The outside leans inward going
// up, so it is a 4.8° overhang everywhere and needs nothing. The slot bottoms
// are half-rounds, 25 across, which the slicer handles as a shallow arch.

/* [Envelope] */

// Bore. A mug goes in here; nothing grips it, so no compensation for the
// polygon's inscription is applied ($fn is high enough to make it moot).
bore_d = 90;      // mm

// Outside at the foot and at the rim. The wall between is a straight cone.
outer_bot_d = 115;   // mm
outer_top_d = 105;   // mm

// Overall height, floor to top of the lip.
total_h = 60;     // mm

// Floor under the mug. The pad pocket is cut out of this.
floor_t = 4;      // mm

/* [Handle slots] */

slot_count = 4;
// Width of each slot at the mid-wall; the flanks flare out by the fillet on
// both faces.
slot_w = 25;      // mm
// How far down from the rim the slot goes, to the lowest point of its round
// bottom. Two thirds of the height leaves a full ring at the base.
slot_depth = 40;  // mm

/* [Rounding] */

// Fillet on the rim and every slot edge. Half the rim's wall gives a full
// half-round; anything larger is clamped to that.
lip_r_req = 3.75;   // mm

/* [Underside] */

// Pocket for a round adhesive pad. Depth is deliberately less than a pad's
// thickness so the pad stands proud.
pad_recess_d = 60;   // mm
pad_recess_h = 1.0;  // mm

/* [Hidden] */

$fn = 120;
eps = 0.01;

bore_r    = bore_d / 2;
r_bot     = outer_bot_d / 2;
r_top     = outer_top_d / 2;
wall_top  = r_top - bore_r;
// The rim can only hold a fillet of half its wall; leave a hair so the shrunk
// wall never collapses to a zero-width sliver the minkowski would drop.
lip_r     = min(lip_r_req, wall_top / 2 - 0.05);

// The outer wall's tilt from vertical. Shifting a tilted line inward by lip_r
// moves its x at any given z by lip_r / cos(tilt), not by lip_r.
tilt      = atan((r_bot - r_top) / total_h);
inset_x   = lip_r / cos(tilt);

// Radius of the outer cone at a height z (unshrunk).
function outer_r(z) = r_bot + (r_top - r_bot) * z / total_h;

// Section of the body with every face pulled in by lip_r. Extends below z = 0
// by more than lip_r so the base edge is trimmed square rather than rounded.
module shrunk_section() {
    below = lip_r + 1;
    polygon([
        [0,                              -below],
        [outer_r(-below) - inset_x,      -below],
        [outer_r(total_h - lip_r) - inset_x, total_h - lip_r],
        [bore_r + lip_r,                 total_h - lip_r],
        [bore_r + lip_r,                 floor_t - lip_r],
        [0,                              floor_t - lip_r],
    ]);
}

// One slot cutter, widened by lip_r all round, running radially along +X
// through both faces. Hull of a round bottom and a box out the top.
module slot_cutter() {
    rad   = slot_w / 2 + lip_r;
    zc    = total_h - slot_depth + slot_w / 2;   // centre of the round bottom
    reach = r_bot + 5;
    hull() {
        translate([0, 0, zc]) rotate([0, 90, 0])
            cylinder(r = rad, h = reach, $fn = 64);
        translate([0, -rad, zc]) cube([reach, 2 * rad, total_h]);
    }
}

module shrunk_body() {
    difference() {
        rotate_extrude() shrunk_section();
        for (i = [0 : slot_count - 1])
            rotate([0, 0, i * 360 / slot_count]) slot_cutter();
    }
}

module desk_cup_holder() {
    difference() {
        // render() so the preview draws the evaluated mesh with enough
        // convexity for the bore; without it OpenCSG loses the far wall.
        render(convexity = 10) intersection() {
            minkowski() {
                shrunk_body();
                sphere(r = lip_r, $fn = 32);
            }
            // Trim the below-zero extension: the base stays square.
            translate([0, 0, total_h / 2 + eps])
                cube([outer_bot_d + 20, outer_bot_d + 20, total_h + 2 * eps], center = true);
        }
        if (pad_recess_h > 0)
            translate([0, 0, -eps])
                cylinder(d = pad_recess_d, h = pad_recess_h + eps);
    }
}

desk_cup_holder();
