// Deck door stop, open-web version.
//
// Same job as parts/deck-door-stop.scad — hold the deck door, which has 44 mm
// of gap under it — but built on the geometry of parts/reversible-door-stop.scad
// instead: an open 45-degree truss in place of the honeycomb, grip ridges on
// both faces, and every corner a 5 mm roll. It is NOT reversible — the floor
// carries a finer comb than the ramp, on purpose, so the two faces read apart.
//
// WHY IT EXISTS. The honeycomb version failed on the plate on 2026-09-07. It
// went stringy and lost bonding around half height and came off in two pieces,
// top half and bottom half, each good on its own side. Ziad's read is that the
// honeycomb is too intricate for its own good and that open space will give the
// wedge more flex. Both are fair: a honeycomb section is seventy-odd separate
// cell walls a layer, which is seventy travel moves and seventy seams, against
// five void perimeters here. Worth saying plainly though — a print that
// delaminates cleanly at one height, having printed fine below it, is the
// signature of the feed going intermittent, not of a shape being complicated.
// This repo has three logged TPU/PETG feed jams to its name. See docs/STATUS.md.
// The truss is a good change on its own merits; do not treat it as a diagnosis.
//
// WHAT IS DIFFERENT FROM THE REFERENCE, and it is only the numbers: 130 long
// instead of 116.845, a 62 mm heel instead of 40, and 45 mm wide instead of 30.
// The ramp angle follows from those (22.43 degrees, up from 14.93) because the
// ramp is tangent to the toe roll and that tangency closes the shape. Ridge and
// bay counts are on auto, so the combs and the truss fill the larger part at
// their own spacing — 15 ridges up the ramp, 27 along the floor, still two bays.
//
// THE HEIGHT IS THE DESIGN. The wedge touches the door wherever the ramp's
// height equals the gap under it, so heel_height alone decides where it
// catches. parts/deck-door-stop.scad used 52; Ziad asked for 10 mm more, and
// the trade is worth stating: at 62 the door meets the ramp 86 mm in, 66% of
// the length rather than 82%, but the travel left in reserve behind that point
// goes 18 mm to 38. Less of the wedge under the door, twice as much room for
// the door to settle into. Peak is 59.53.
//
// 22.4 DEGREES STILL SELF-LOCKS with room to spare — TPU on decking is a
// friction angle of 35 to 45 degrees — but the margin is thinner than it was at
// 18.5, and this is the number to watch if the stop ever skids out. Lengthening
// the part is what makes it shallower again.
//
// PRINT IT IN TPU, ON ITS SIDE, which is the orientation this file builds:
// profile in XY, extruded up Z, so a 130 x 60 face is on the plate and the five
// voids are through-holes 45 mm deep. Nothing bridges, nothing overhangs.
//
// EVERYTHING ELSE IS INHERITED and documented in parts/reversible-door-stop.scad:
// the derived ramp angle, the tangency solve, the semicircular ridges, and the
// truss bands with their opening.

include <../../../logos/marks.scad>

/* [The door] */

// The gap under the door, floor to slab. Drives nothing — it is what the echo
// at render time measures the wedge against, and what the asserts below refuse
// to build a wedge that cannot reach.
door_gap     = 44;       // mm

/* [Overall] */

// Extrusion depth — the width of the wedge, and the height it prints at. Set it
// from the slab's thickness, not from the wedge: the slab's bottom edge lands
// across this, so anything narrower than the door is thick bears the door on a
// line and lets it rock.
//
// 45 IS THE DOOR, NOT MORE. A 1-3/4 in exterior slab is 44.45 mm, so this is
// flush with the door and has nothing in hand — Ziad's call, taken over the 60
// that gave 8 mm a side. It still holds; it just wants the stop squared up
// under the slab rather than shoved in at an angle.
width        = 45;       // mm

// Length of the floor, knife edge to toe, over the toe roll. With the heel
// fixed by the door gap this is the dial that sets the ramp angle: longer is
// shallower, more wedge, and more of it sticking out into the room.
length       = 130;      // mm

// Height of the heel, taken to the sharp corner the fillet cuts off. The fillet
// takes about 2.5 mm off it — peak, echoed below, is the real height. This is
// the dial that decides where the wedge catches: 1.2x door_gap catches deep
// with little in reserve, 1.4x — which is what 62 is — catches earlier with a
// lot. Read the echo rather than guessing.
heel_height  = 62;       // mm

/* [Corners] */

// Radius of the toe roll. Not cosmetic: the ramp is tangent to it, so it is one
// of the three numbers that decide ramp_angle.
toe_r        = 5;        // mm

// Fillet where the ramp rolls over into the back face.
heel_r       = 5;        // mm

// Fillet at the knife edge, where the back face meets the floor.
tail_r       = 5;        // mm

/* [Grip ridges] */

// Half-round ridges standing proud of both faces. Each is a true semicircle, so
// the radius is both the radius and how far it stands out, and the pitch is
// measured along the face rather than horizontally.
//
// THE TWO COMBS ARE DELIBERATELY DIFFERENT. The reference ran the same comb on
// both faces so the stop could be flipped; this one is not reversible, and the
// floor gets a comb at half the radius and half the pitch. It reads as the
// bottom across the room, and it puts twice as many edges into the decking on
// the face that has to hold — a fine comb bites a soft, ridged surface better
// than a coarse one, and the floor is the only face that ever touches it.
ramp_ridge_r      = 1.5;     // mm
ramp_ridge_pitch  = 9;       // mm
floor_ridge_r     = 0.75;    // mm
floor_ridge_pitch = 4.5;     // mm

// 0 means as many as the pitch fits between the two corner fillets — 14 on the
// ramp and 27 on the floor at this size. The first sits one radius past the
// fillet's tangent point, which is what sets the phase of the comb.
ramp_ridge_count  = 0;
floor_ridge_count = 0;

/* [Truss] */

// The open web through the width. false builds the wedge solid.
truss        = true;

// Wall left between the voids and every outside face, and thickness of each
// 45-degree web. Both were 4; both came down to 3 to make the wedge softer,
// which is the only lever in this file that does that — a triangulated truss is
// the stiff way to arrange material, so the way to get give out of it is to use
// less of it rather than to rearrange it.
//
// 3 mm is seven 0.42 lines and the slicer will fill it solid, so it is still a
// real wall. Below about 2.5 it stops being one and starts being two perimeters
// with a gap, which is where it would get floppy in the wrong way. It also sets
// what is left behind the mark: at shell 3 and mark_depth 1.00 that is 2 mm.
shell        = 3;        // mm
web_t        = 3;        // mm

// Corner radius left in every void, applied as an opening — erode then dilate.
// It rounds each void's corners and drops anything narrower than 2 * void_r,
// which is what stops the last void running out to a knife point at the toe.
void_r       = 2;        // mm

// The truss nodes. Each bay is one low node with two webs springing off it, up
// and to the left and up and to the right; consecutive bays meet at a high node
// half a pitch along and half a pitch up.
//
// THE HIGH NODE MUST LAND OUTSIDE THE SHELL. Its height is truss_y + pitch / 2,
// flat, while the ramp above it falls — so if the pitch is too small for the
// height the two webs cross inside the material instead of on the face, and the
// void above them splits into an X with slivers in it. Raising heel_height
// raises the ramp, which is why 48 became 54 when the heel went 52 to 62.
// Check the render, not the arithmetic: it is obvious on sight.
truss_x0     = 54;       // mm, x of the first low node
truss_y      = 2;        // mm, height of the low node line
truss_pitch  = 54;       // mm, low node to low node

// 0 means as many bays as the pitch fits before the toe — two here, which is
// four webs and five voids.
truss_bays   = 0;

/* [Mark] */

// The ZR monogram, debossed into the back face. That face is the only large
// solid panel on the part and it is the one pointing at you when the stop is
// under a door.
mark         = true;

// Width of the monogram, measured across the part's width. The face is 45 wide
// by 50 up. It has come down twice on Ziad's call — 50, then 35, now 26.25 —
// which leaves 9.4 mm a side and 17.9 mm of height.
//
// ⚠️ THIS IS PAST WHERE THE ARTWORK WANTS TO BE. zr_monogram is a high-contrast
// serif whose hairlines are 1.4% of its height: 0.70 mm at a 50 mm mark, and
// 0.25 mm at 26.25 — well under one 0.42 line, which in TPU is not a groove at
// all. mark_swell is holding it together and is now doing more work than the
// drawing, so contrast is down to roughly 3:1 from 6:1 as drawn. If it wants to
// go smaller again, switch to zr_mark, which has no hairlines to lose.
mark_width   = 26.25;    // mm

// Where its centre sits, measured up the back face from the knife edge.
mark_up      = 30;       // mm

// How far it is cut into the shell. 1.00 leaves 2 mm behind it — five lines at
// 0.42 — and is about as
// shallow as TPU can be relied on to hold a shadow line: the material is soft,
// the extrusion is fat, and a 0.40 deboss that reads on a rigid part reads as
// nothing here.
mark_depth   = 1.00;     // mm

// Wall angle of the cut, from the face. The part prints on its side, so the
// back face is a vertical wall and a prismatic pocket puts a horizontal roof
// over the top edge of every stroke — the slicer answers that with support
// material inside the lettering. Sloping the walls removes the roof entirely.
// Argued at length in parts/hobbs-chalk-holder.scad.
mark_taper   = 70;       // deg from the face

// The taper is a stack of prismatic bands, since offset() erodes a 2D shape and
// nothing lofts between two of them. Each band leaves a ledge as deep as
// itself, so 6 over 1.00 mm gives 0.17 mm ledges — under a layer, invisible.
mark_steps   = 6;

// How much every stroke is fattened before the cut, and the only reason this
// monogram works at this size. Swelling adds the same amount to every edge, so
// a stroke gains twice it: the hairlines go 0.25 -> 1.09 mm, a shade under the
// 1.19 the 50 mm mark had and about two and a half 0.42 lines. The thins gain
// proportionally far more than the thicks, so contrast falls from 6:1 as drawn
// to about 2.9:1. That is a real change to the drawing and an invisible one at
// arm's length; it is also the whole price of a 26 mm mark, and it is the
// number to lower first if the monogram prints clogged.
//
// Set it to 0 for the artwork exactly as drawn, and expect the thins to close
// up in TPU.
mark_swell   = 0.42;     // mm

/* [Output] */

// "coupon" is a short slice through the width: the whole silhouette, every
// ridge and a slice of every web, in a piece that prints in a fraction of the
// time. It answers shape, not fit — and it carries no mark, since the mark is
// on the face the coupon cuts away.
show         = "part";   // [part, coupon]
coupon_len   = 10;       // mm

/* [Quality] */

$fa = 4;                 // deg, max angle per facet
$fs = 0.3;               // mm, max chord per facet
eps = 0.01;

// ---------------------------------------------------------------------------

// The ramp is tangent to the toe roll, which sits on the floor at the end of
// the length. Writing that tangency out gives one equation in the ramp angle:
//
//   (length - toe_r) sin a + (toe_r - heel_height) cos a = -toe_r
//
// which is R sin(a + psi) = -toe_r, and the shallow root is the wedge.
ramp_A     = length - toe_r;
ramp_B     = toe_r - heel_height;
ramp_R     = norm([ramp_A, ramp_B]);
ramp_angle = asin(-toe_r / ramp_R) - atan2(ramp_B, ramp_A);

assert(ramp_R > toe_r,
       "the toe roll cannot reach the ramp — shorten the length or raise the heel");
assert(ramp_angle > 0 && ramp_angle < 45,
       "no sane ramp closes this length against this heel height");

// Down the ramp, and out of it. Unit vectors.
ramp_dir = [cos(ramp_angle), -sin(ramp_angle)];
ramp_out = [sin(ramp_angle),  cos(ramp_angle)];

// The three fillet centres. The heel's is one radius in from the back face and
// one radius below the ramp line, measured down the vertical.
toe_ctr  = [length - toe_r, toe_r];
tail_ctr = [tail_r, tail_r];
heel_ctr = [heel_r,
            heel_height - heel_r * tan(ramp_angle) - heel_r / cos(ramp_angle)];

// Both the toe roll and the heel fillet meet the ramp at the same angle on
// their own circles, because it is the same line.
tang_ang = 90 - ramp_angle;
heel_tp  = heel_ctr + heel_r * ramp_out;
toe_tp   = toe_ctr  + toe_r  * ramp_out;

// Straight run of the ramp, tangent point to tangent point, and of the floor,
// fillet to fillet. The ridges are laid out along these.
ramp_run  = norm(toe_tp - heel_tp);
floor_run = length - tail_r - toe_r;

assert(heel_ctr.y > tail_r + heel_r,
       "the heel fillet has eaten the back face — lower heel_r or raise the heel");

ramp_ridges  = ramp_ridge_count  > 0 ? ramp_ridge_count
             : floor((ramp_run  - 2 * ramp_ridge_r)  / ramp_ridge_pitch)  + 1;
floor_ridges = floor_ridge_count > 0 ? floor_ridge_count
             : floor((floor_run - 2 * floor_ridge_r) / floor_ridge_pitch) + 1;

bays = truss_bays > 0 ? truss_bays
     : max(1, floor((length - truss_x0) / truss_pitch) + 1);

// Points along an arc, inclusive of both ends, at the current facet settings.
function arc_pts(ctr, r, a1, a2) =
    let (n = max(2, ceil(abs(a2 - a1) / $fa),
                    ceil(abs(a2 - a1) * PI * r / 180 / $fs)))
    [ for (i = [0 : n]) ctr + r * [cos(a1 + (a2 - a1) * i / n),
                                   sin(a1 + (a2 - a1) * i / n)] ];

// Counter-clockwise from the knife edge: round the tail, along the floor, round
// the toe, up the ramp, over the heel, down the back face. The straights are
// implied by consecutive arc ends.
profile_pts = concat(
    arc_pts(tail_ctr, tail_r, 180, 270),
    arc_pts(toe_ctr,  toe_r,  -90, tang_ang),
    arc_pts(heel_ctr, heel_r, tang_ang, 180)
);

// Where this wedge meets that door. peak is the real height — the heel fillet
// cuts the corner heel_height is measured to — catch_in is how far the toe
// travels under the door before the top face touches it, and reserve is the
// travel still left after that, which is what holds the door when it settles.
peak     = max([for (p = profile_pts) p.y]);
catch_in = length - (heel_height - door_gap) / tan(ramp_angle);
reserve  = (peak - door_gap) / tan(ramp_angle);

assert(peak > door_gap,
       "the wedge is shorter than the gap under the door and will never touch it");
assert(door_gap > toe_tp.y && door_gap < heel_tp.y,
       "the door would land on a fillet, not on the straight ramp, where catch_in is not the arithmetic that applies");

echo(str("ramp ", ramp_angle, " deg, peak ", peak, " mm; door_gap ", door_gap,
         " mm catches ", catch_in, " mm in (", round(100 * catch_in / length),
         "% of the length), ", reserve, " mm of travel in reserve"));
echo(str(ramp_ridges, " ramp ridges, ", floor_ridges, " floor ridges, ",
         bays, " truss bays; back face runs ", tail_r, " to ", heel_ctr.y,
         " mm, mark is ", zr_monogram_height(mark_width), " mm tall"));

// The wedge with no ridges and no truss. This is the shape the shell is eroded
// from — erode the ridged face instead and the voids follow every bump in it.
module wedge_profile() {
    polygon(profile_pts);
}

module ramp_ridges_2d() {
    for (k = [0 : ramp_ridges - 1])
        translate(heel_tp + (ramp_ridge_r + k * ramp_ridge_pitch) * ramp_dir)
            circle(r = ramp_ridge_r);
}

module floor_ridges_2d() {
    for (k = [0 : floor_ridges - 1])
        translate([tail_r + floor_ridge_r + k * floor_ridge_pitch, 0])
            circle(r = floor_ridge_r);
}

// The webs, as bands of infinite length. A band at 45 degrees through (c, 0) is
// the line x - y = c; at 135 degrees it is x + y = c. Each low node sends one
// of each, so the pair meets at that node.
module truss_bands() {
    big = 2 * (length + heel_height);
    for (k = [0 : bays - 1])
        let (xn = truss_x0 + k * truss_pitch) {
            translate([xn + truss_y, 0]) rotate( 45) square([web_t, big], center = true);
            translate([xn - truss_y, 0]) rotate(-45) square([web_t, big], center = true);
        }
}

// Everything the shell leaves. Its corners come out at shell less than the
// outside radius, which is 1 mm at the knife edge and at the toe.
module inner_2d() {
    offset(r = -shell) wedge_profile();
}

// What the webs do not use, opened by void_r so every corner is radiused and no
// sliver narrower than a web survives.
module voids_2d() {
    offset(r = void_r) offset(r = -void_r)
        difference() {
            inner_2d();
            truss_bands();
        }
}

module deck_door_stop_truss_profile() {
    difference() {
        union() {
            wedge_profile();
            ramp_ridges_2d();
            floor_ridges_2d();
        }
        if (truss) voids_2d();
    }
}

// The monogram as a solid to subtract, drawn flat and laid onto the back face.
// Local x runs across the part's width, local y up the face, local z out of the
// face toward whoever is reading it — a right-handed frame, so the mark is not
// mirrored — and every band is cut from the surface down, so the union of them
// is a staircase approximating the taper.
module mark_pocket() {
    step  = mark_depth / mark_steps;
    erode = step / tan(mark_taper);

    // Columns of the matrix are those three local axes; the fourth is the
    // centre of the mark on the face, mark_up up from the knife edge.
    multmatrix([[0, 0, -1, 0],
                [0, 1,  0, mark_up],
                [1, 0,  0, width / 2]])
        for (k = [0 : mark_steps - 1])
            translate([0, 0, -(k + 1) * step])
                linear_extrude(height = step + eps)
                    offset(delta = mark_swell - k * erode)
                        zr_monogram(mark_width);
}

module deck_door_stop_truss() {
    difference() {
        linear_extrude(height = width, convexity = 10) deck_door_stop_truss_profile();
        if (mark) mark_pocket();
    }
}

// A slab taken out of the middle of the width. The voids run along the width,
// so this loses nothing but length of hole — and it loses the mark, which lives
// on the face this cuts away.
module deck_door_stop_truss_coupon() {
    intersection() {
        linear_extrude(height = width, convexity = 10) deck_door_stop_truss_profile();
        translate([-eps, -heel_height, (width - coupon_len) / 2])
            cube([length + 2 * eps, 2 * heel_height, coupon_len]);
    }
}

if (show == "coupon") deck_door_stop_truss_coupon();
else                  deck_door_stop_truss();
