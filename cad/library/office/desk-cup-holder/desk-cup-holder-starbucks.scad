// Note 1.

/* [Envelope] */

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

bore_bot_d = 65;   // Note 4.
bore_top_d = 80;   // Note 5.

outer_bot_d = 94;    // Note 6.
outer_top_d = 90;    // Note 7.

total_h = 60;     // Note 8.

floor_t = 4;      // Note 9.

/* [Handle slots] */

slot_count = 4;
// Note 10.

slot_w = 25;      // Note 11.

slot_depth = 40;  // Note 12.

slot_segs = 16;

/* [Rules] */

wall_min  = 5;     // Note 13.
wall_max  = 15;    // Note 14.
taper_min = 4;     // Note 15.

/* [Rounding] */

// Note 16.

lip_r_req = 1.9;    // Note 17.

/* [Underside] */

// Note 18.

pad_recess_d = 60;   // Note 19.
pad_recess_h = 0;    // Note 20.

pad_w     = 26;    // Note 21.
pad_len   = 13;    // Note 22.
pad_sq_h  = 0.6;   // Note 23.
pad_edge  = 5;     // Note 24.

/* [Hidden] */

$fn = 120;
sphere_fn = 32;
eps = 0.01;

assert(outer_bot_d - outer_top_d >= taper_min,
       "rule 1: the outside must be at least taper_min wider at the foot than the rim");
assert((outer_top_d - bore_top_d) / 2 >= wall_min && (outer_bot_d - bore_bot_d) / 2 >= wall_min,
       "rule 2: a wall is thinner than wall_min");
assert((outer_top_d - bore_top_d) / 2 <= wall_max && (outer_bot_d - bore_bot_d) / 2 <= wall_max,
       "rule 2: a wall is thicker than wall_max");

bore_br   = bore_bot_d / 2;
bore_tr   = bore_top_d / 2;
r_bot     = outer_bot_d / 2;
r_top     = outer_top_d / 2;
wall_top  = r_top - bore_tr;
// Note 25.

lip_r     = min(lip_r_req, wall_top / 2 - 0.05);

// Note 26.

tilt      = atan((r_bot - r_top) / total_h);
inset_x   = lip_r / cos(tilt);

// Note 27.
function outer_r(z)  = r_bot + (r_top - r_bot) * z / total_h;
function shrunk_r(z) = outer_r(z) - inset_x;

// Note 28.

btilt     = atan((bore_tr - bore_br) / (total_h - floor_t));
inset_b   = lip_r / cos(btilt);
function bore_r(z) = bore_br + (bore_tr - bore_br) * (z - floor_t) / (total_h - floor_t);
function bs(z)     = bore_r(z) + inset_b;   // Note 29.
z_top = total_h - lip_r;         // Note 30.
z_flr = floor_t - lip_r;         // Note 31.
below = lip_r + 1;               // Note 32.

rho_mid  = (bore_tr + r_top) / 2;
slot_a   = asin(lip_r / rho_mid) + asin(slot_w / 2 / rho_mid);   // Note 33.
slot_rad = rho_mid * slot_a * PI / 180;
slot_zc  = total_h - slot_depth - lip_r + slot_rad;   // Note 34.

function slot_floor(a) =
    let (s = rho_mid * a * PI / 180)
    slot_zc - sqrt(max(0, slot_rad * slot_rad - s * s));

// Note 35.
module wall_section() {
    polygon([
        [bs(z_flr),       z_flr],
        [shrunk_r(z_flr), z_flr],
        [shrunk_r(z_top), z_top],
        [bs(z_top),       z_top],
    ]);
}

// Note 36.

module floor_section() {
    polygon([
        [0,                -below],
        [shrunk_r(-below), -below],
        [shrunk_r(z_flr),   z_flr],
        [0,                 z_flr],
    ]);
}

// Note 37.
module grown(section_convexity = 4) {
    intersection() {
        offset(r = lip_r) children();
        square([r_bot + 2 * lip_r, total_h + 2 * lip_r]);
    }
}

// Note 38.
function swing(p, a) = [p[0] * cos(a), p[0] * sin(a), p[1]];

module ball(p) { translate(p) sphere(r = lip_r, $fn = sphere_fn); }

// Note 39.

module end_cap(a) {
    hull() {
        ball(swing([bs(z_flr),       z_flr], a));
        ball(swing([shrunk_r(z_flr), z_flr], a));
        ball(swing([shrunk_r(z_top), z_top], a));
        ball(swing([bs(z_top),       z_top], a));
    }
}

// Note 40.

module slot_floor_wedges() {
    for (i = [0 : slot_segs - 1]) {
        a0 = -slot_a + 2 * slot_a * i / slot_segs;
        a1 = -slot_a + 2 * slot_a * (i + 1) / slot_segs;
        z0 = slot_floor(a0);
        z1 = slot_floor(a1);
        hull() {
            for (a = [a0, a1]) {
                ball(swing([bs(z_flr),       z_flr], a));
                ball(swing([shrunk_r(z_flr), z_flr], a));
            }
            ball(swing([bs(z0),        z0], a0));
            ball(swing([shrunk_r(z0),  z0], a0));
            ball(swing([bs(z1),        z1], a1));
            ball(swing([shrunk_r(z1),  z1], a1));
        }
    }
}

module desk_cup_holder() {
    pitch = 360 / slot_count;
    difference() {
        intersection() {
            union() {
                rotate_extrude(convexity = 4) grown() floor_section();
                for (k = [0 : slot_count - 1]) rotate([0, 0, k * pitch]) {
                    // Note 41.
                    rotate([0, 0, slot_a])
                        rotate_extrude(angle = pitch - 2 * slot_a, convexity = 4)
                            grown() wall_section();
                    end_cap(slot_a);
                    end_cap(-slot_a);
                    slot_floor_wedges();
                }
            }
            // Note 42.
            translate([-r_bot - 10, -r_bot - 10, 0])
                cube([2 * r_bot + 20, 2 * r_bot + 20, total_h + 1]);
        }
        if (pad_recess_h > 0)
            translate([0, 0, -eps])
                cylinder(d = pad_recess_d, h = pad_recess_h + eps);
        if (pad_sq_h > 0)
            for (a = [0 : 90 : 270]) rotate([0, 0, a])
                translate([r_bot - pad_edge - pad_len / 2, 0, -eps])
                    linear_extrude(pad_sq_h + eps)
                        square([pad_len, pad_w], center = true);
    }
}

// Note 43.

module feral_default_output_db88ea6beec1() {
desk_cup_holder();
}

module feral_assembly_view_db88ea6beec1(explode=false) {
feral_default_output_db88ea6beec1();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_db88ea6beec1();
else feral_assembly_view_db88ea6beec1(view == "exploded");

// Notes

// Note 1. Desk cup holder, Starbucks — the desk-cup-holder.scad collar rebored for
// a cup that is Ø60 at its base and Ø75 at 60 mm up.
//
// A copy of desk-cup-holder.scad, and meant to stay one: the only things that
// changed are the bore and the outside that follows it, so a diff between the
// two files is exactly the list of things the cup forced. The bore is a cone,
// Ø65 at the floor and Ø80 at the rim — the cup's two diameters plus 5 mm of
// wiggle room each. The outside is at the rules' limits: wall_min at the rim,
// so Ø90 there, and taper_min wider at the foot, Ø94, where the wall is 14.5
// — the bore's 7.5 of radial flare plus the rim wall plus half the taper,
// just under wall_max. It was Ø105 / Ø95 with a 20 mm foot wall before the
// wall rule, and Ø89 / Ø95 — wider at the top — before the taper rule.
//
// RULES FOR EVERY VARIANT OF THIS PART (Ziad, 2026-09-13), asserted below:
// 1. the outside tapers OUT going down — wider at the foot than the rim by
// at least taper_min on the diameter — whatever the bore does. The
// collar exists to add width to the bottom of a cup so it is harder to
// knock over; the Starbucks copy once followed its bore the other way.
// 2. the wall is never thinner than wall_min nor thicker than wall_max,
// measured at the rim and at the foot (it is a straight cone between).
// Thick walls cost print time, not plastic. On a cup whose bore widens
// going up the foot wall has to carry the bore's radial taper plus half
// the outside's, so wall_max is what caps how much the bore may flare.
//
// Four handle slots, 25 wide, let a mug sit with its handle out in any of
// four directions. Everything the hand or the mug meets is rounded:
// the rim and every edge of every slot carry the same 1.9 round, so the top
// outline reads as one continuous lip that dips into each slot and comes
// back up.
//
// HOW THE ROUNDING IS DONE. The body is drawn SHRUNK by lip_r on every face —
// bore out by lip_r, outside in by lip_r, top down by lip_r, slots widened by
// lip_r — and then grown back by lip_r. Concave corners (the floor meeting the
// bore) come back exactly where they were; every convex edge comes back as a
// fillet of lip_r. That growth is a minkowski with a sphere, and the first
// draft did it literally: one minkowski() of the whole slotted ring, which
// OpenSCAD cannot preview and has to convex-decompose, so the file took a
// minute to open. Minkowski distributes over union, so the same result is
// built here from pieces that are each convex and each grown analytically:
//
// - the ring between slots: rotate_extrude of the 2D-offset section, which
// IS that piece's minkowski, with a hull of four spheres capping each
// radial end face;
// - the wall under each slot: sixteen thin wedges following the U, each the
// hull of eight spheres at its corners;
// - the floor: rotate_extrude of its own offset section.
//
// Same surface, zero minkowski calls, and it previews instantly. The one
// design consequence is that the slot flanks are radial planes rather than
// parallel ones, because a radial cut is where the ring splits cleanly. On a
// wall this thin the difference is 1 mm of width between the bore and the
// outside, and the slot is dimensioned at the mid-wall of the rim.
//
// THE UNDERSIDE. Flat, on a 4 mm floor, with four shallow pockets — 26
// across by 13 in, 0.6 deep — at north, east, south and west, for the adhesive
// strips (Ziad, 2026-09-13). Each sits as far out as it can with pad_edge of
// floor left outside it, so the grip is at the rim of the footprint where it
// resists tipping. They are locating pockets, not sockets: three layers
// keeps a strip from wandering while it is pressed on and leaves it standing
// proud. A pocket for a round gel pad in the centre is still available — set
// pad_recess_h to a depth shallower than the pad.
//
// ORIENTATION. Printed as drawn, floor down. The outside leans inward going
// up, so it is a 4.8° overhang everywhere and needs nothing; the bore leans
// outward 7.7°, an overhang the same way, also fine. The slot bottoms
// are half-rounds, 25 across, which the slicer handles as a shallow arch.

// Note 2. Bore: a cone from the floor to the rim. The cup is Ø60 at its base and Ø75
// at 60 mm up; each gets 5 mm of room. Nothing grips it, so no compensation
// for the polygon's inscription is applied ($fn is high enough to make it
// moot).

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. mm, at the floor

// Note 5. mm, at the rim
// Outside at the foot and at the rim: the rim is the bore plus wall_min, the
// foot is the rim plus taper_min. The wall between is a straight cone.

// Note 6. mm

// Note 7. mm
// Overall height, floor to top of the lip.

// Note 8. mm
// Floor under the mug. The pad pocket is cut out of this.

// Note 9. mm

// Note 10. Width of each slot, measured across the mid-wall at the rim. The flanks
// are radial, so it is ~1 mm narrower at the bore and wider outside.

// Note 11. mm
// How far down from the rim the slot goes, to the lowest point of its round
// bottom. Two thirds of the height leaves a full ring at the base.

// Note 12. mm
// Wedges used to follow each slot's round bottom. 16 puts the chord error
// under 0.1 mm.

// Note 13. mm, thinnest the wall may be anywhere

// Note 14. mm, thickest

// Note 15. mm, how much wider the foot must be than the rim, on the diameter

// Note 16. Fillet on the rim and every slot edge. Half the rim's wall (2.5) would give
// a full half-round; Ziad wanted the sibling's 1.9 (2026-09-13), so the rim
// is a 1.2 flat between two 1.9 rounds. Anything larger than half the wall is
// clamped to that.

// Note 17. mm

// Note 18. Optional pocket for a round adhesive pad; 0 leaves the underside flat.
// If used, keep the depth less than the pad's thickness so the pad stands
// proud.

// Note 19. mm

// Note 20. mm
// Four pockets for adhesive strips, one on each axis, as far out as pad_edge
// allows: pad_w across, pad_len from the outside in. They were 26 square;
// Ziad halved the radial run (2026-09-13).

// Note 21. mm, across (tangential)

// Note 22. mm, from the outside in (radial)

// Note 23. mm, deep, three 0.2 layers for a 1 mm strip; 0.5 is not a layer count (Ziad). 0 for none

// Note 24. mm of floor left between a pocket and the outside; 2 risked a crack at the edge (Ziad)

// Note 25. The rim can only hold a fillet of half its wall; leave a hair so the shrunk
// wall never collapses to a zero-width sliver.

// Note 26. The outer wall's tilt from vertical. Shifting a tilted line inward by lip_r
// moves its x at any given z by lip_r / cos(tilt), not by lip_r.

// Note 27. Radius of the outer cone at a height z (unshrunk), and shrunk.

// Note 28. The bore cone runs from the floor to the rim, and its own tilt sets how
// far its shrunk copy sits from it.

// Note 29. shrunk bore radius

// Note 30. shrunk rim height

// Note 31. shrunk floor top = shrunk wall bottom

// Note 32. how far the shrunk floor runs under z = 0
// The slot, in the shrunk space. Its flanks are radial planes at ±slot_a
// from the slot's centreline, chosen so that after growth the opening at the
// rim's mid-wall radius is exactly slot_w. Its round bottom is an arc of
// radius slot_rad in arc-length at that same radius, tangent to the flanks.

// Note 33. deg

// Note 34. centre of the arc
// Height of the shrunk wall under the slot at angle a from its centreline.

// Note 35. 2D section of the shrunk wall, in the (r, z) plane.

// Note 36. 2D section of the shrunk floor, run past z = 0 so the base is trimmed
// square instead of rounded.

// Note 37. Grow a section by lip_r and keep it on the positive side of the axis.

// Note 38. A point of the shrunk wall section, [r, z], swung to angle a about Z.

// Note 39. The wall's radial end face at angle a, grown: hull of a sphere at each
// corner. Exactly the minkowski of that face.

// Note 40. The wall under one slot, centred on +X: thin wedges whose tops follow the
// arc, each grown as the hull of eight spheres.

// Note 41. Ring between this slot and the next.

// Note 42. Trim the below-zero extension: the base stays square.

// Note 43. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
