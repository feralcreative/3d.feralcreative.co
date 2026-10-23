// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <../../../logos/marks.scad>

/* [The door] */

// Note 3.

door_gap    = 44;     // Note 4.

/* [Overall] */

// Note 5.

width       = 60;     // Note 6.

length      = 130;    // Note 7.

heel_height = 52;     // Note 8.

ramp_angle  = 20;     // Note 9.

back_rake    = 11.14; // Note 10.

heel_r       = 3;     // Note 11.

tail_r       = 0;     // Note 12.

/* [Toe] */

// Note 13.
toe_r        = 3;     // Note 14.

toe_lift     = 1.43;  // Note 15.

nose_r       = 56;    // Note 16.

/* [Grip ridges] */

// Note 17.

ridge_count  = 0;
ridge_r      = 1;     // Note 18.

ridge_pitch  = 7.167; // Note 19.

ridge_first  = 6.046; // Note 20.

/* [Floor grooves] */

// Note 21.

groove_count = 0;
groove_w     = 2;     // Note 22.
groove_d     = 1;     // Note 23.

groove_margin = 2;    // Note 24.

groove_pitch = 3.9167;  // Note 25.

/* [Honeycomb] */

// Note 26.
honeycomb    = true;

// Note 27.
shell        = 3;     // Note 28.

cell_af      = 6;     // Note 29.

cell_wall    = 1.68;  // Note 30.

cell_min_web = 1.68;  // Note 31.

cell_x0      = 4;     // Note 32.
cell_z0      = 6.2;   // Note 33.

/* [Mark] */

// Note 34.

mark        = true;

// Note 35.

mark_width  = 50;     // Note 36.

mark_up     = 26;     // Note 37.

mark_depth  = 1.00;   // Note 38.

mark_taper  = 70;     // Note 39.

mark_steps  = 6;

// Note 40.

mark_swell  = 0.25;   // Note 41.

/* [Output] */

// Note 42.

show         = "part";  // [part, coupon]
coupon_len   = 10;      // Note 43.

/* [Quality] */

$fa = 4;              // Note 44.
$fs = 0.3;            // Note 45.
eps = 0.01;

// Note 46.

heel_pt  = [heel_height * tan(back_rake), heel_height];

// Note 47.
ramp_dir = [ cos(ramp_angle), -sin(ramp_angle)];
ramp_out = [ sin(ramp_angle),  cos(ramp_angle)];

// Note 48.
toe_ctr  = [length - toe_r, toe_lift];

// Note 49.

nose_v   = heel_pt - toe_ctr - nose_r * ramp_out;
nose_b   = 2 * (nose_v * ramp_dir);
nose_c   = nose_v * nose_v - (nose_r - toe_r) * (nose_r - toe_r);
ramp_len = (-nose_b - sqrt(nose_b * nose_b - 4 * nose_c)) / 2;

assert(nose_b * nose_b - 4 * nose_c > 0,
       "nose_r cannot reach both the ramp line and the toe roll — raise it");

// Note 50.

nose_ctr = heel_pt + ramp_len * ramp_dir - nose_r * ramp_out;
ramp_pt  = heel_pt + ramp_len * ramp_dir;
toe_pt   = nose_ctr + nose_r * (toe_ctr - nose_ctr) / norm(toe_ctr - nose_ctr);

function ang_at(ctr, p) = atan2(p.y - ctr.y, p.x - ctr.x);

nose_a1  = ang_at(nose_ctr, ramp_pt);   // Note 51.
nose_a2  = ang_at(nose_ctr, toe_pt);    // Note 52.
toe_a2   = ang_at(toe_ctr,  toe_pt);

// Note 53.

top_len  = ramp_len + nose_r * (nose_a1 - nose_a2) * PI / 180;

// Note 54.

ridges  = ridge_count  > 0 ? ridge_count
                           : floor((top_len - ridge_first) / ridge_pitch) + 1;

grooves = groove_count > 0 ? groove_count
                           : floor((length - 2 * groove_margin - groove_w)
                                   / groove_pitch) + 1;

assert(ridge_first + (ridges - 1) * ridge_pitch < top_len,
       "the last ridge falls past the end of the top face");
assert(grooves > 1, "the floor is too short for two grooves at this pitch");

// Note 55.

function top_pt(s) =
    s <= ramp_len
      ? heel_pt + s * ramp_dir
      : let (a = nose_a1 - (s - ramp_len) / nose_r * 180 / PI)
        nose_ctr + nose_r * [cos(a), sin(a)];

// Note 56.
function arc_pts(ctr, r, a1, a2) =
    let (n = max(2, ceil(abs(a2 - a1) / $fa),
                    ceil(abs(a2 - a1) * PI * r / 180 / $fs)))
    [ for (i = [0 : n]) ctr + r * [cos(a1 + (a2 - a1) * i / n),
                                   sin(a1 + (a2 - a1) * i / n)] ];

function unit2(v) = v / norm(v);

// Note 57.

function fillet(a, b, c, r) =
    r <= 0 ? [b] :
    let (
        u1  = unit2(a - b),
        u2  = unit2(c - b),
        ang = acos(max(-1, min(1, u1 * u2))),
        t1  = b + u1 * (r / tan(ang / 2)),
        t2  = b + u2 * (r / tan(ang / 2)),
        ctr = b + unit2(u1 + u2) * (r / sin(ang / 2)),
        a1  = atan2(t1.y - ctr.y, t1.x - ctr.x),
        a2  = atan2(t2.y - ctr.y, t2.x - ctr.x),
        // Note 58.
        sw  = ((a2 - a1) + 540) % 360 - 180
    )
    arc_pts(ctr, r, a1, a1 + sw);

// Note 59.

profile_pts = concat(
    fillet(heel_pt, [0, 0], [length, 0], tail_r),
    [[length, 0], [length, toe_lift]],
    arc_pts(toe_ctr,  toe_r,  0, toe_a2),
    arc_pts(nose_ctr, nose_r, nose_a2, nose_a1),
    fillet(ramp_pt, heel_pt, [0, 0], heel_r)
);

// Note 60.

peak     = max([for (p = profile_pts) p.y]);
catch_x  = heel_pt.x + (heel_height - door_gap) / tan(ramp_angle);
catch_in = length - catch_x;
reserve  = (peak - door_gap) / tan(ramp_angle);

assert(peak > door_gap,
       "the wedge is shorter than the gap under the door and will never touch it");
assert(door_gap > heel_height - ramp_len * sin(ramp_angle),
       "the door would land on the nose arc, where catch_in below is not the arithmetic that applies");

echo(str("door_gap ", door_gap, " mm: catches ", catch_in, " mm in (",
         round(100 * catch_in / length), "% of the length), peak ", peak,
         " mm, ", reserve, " mm of travel in reserve"));

// Note 61.

module wedge_profile() {
    polygon(profile_pts);
}

module grip_ridges() {
    for (k = [0 : ridges - 1])
        translate(top_pt(ridge_first + k * ridge_pitch))
            circle(r = ridge_r);
}

// Note 62.
module grooves() {
    pitch = (length - 2 * groove_margin - groove_w) / (grooves - 1);
    for (k = [0 : grooves - 1])
        translate([groove_margin + k * pitch, -eps])
            square([groove_w, groove_d + eps]);
}

// Note 63.

module lattice() {
    p  = cell_af + cell_wall;         // Note 64.
    dx = p * sqrt(3) / 2;             // Note 65.
    for (i = [-1 : ceil(length / dx) + 1], j = [-1 : ceil(heel_height / p) + 1])
        translate([cell_x0 + i * dx,
                   cell_z0 + j * p + (i % 2 != 0 ? p / 2 : 0)])
            circle(r = cell_af / sqrt(3), $fn = 6);
}

// Note 66.
module core_cut() {
    offset(r =  cell_min_web / 2)
        offset(r = -cell_min_web / 2)
            intersection() {
                lattice();
                offset(r = -shell) wedge_profile();
            }
}

module deck_door_stop_profile() {
    difference() {
        union() {
            wedge_profile();
            grip_ridges();
        }
        grooves();
        if (honeycomb) core_cut();
    }
}

// Note 67.

module mark_pocket() {
    step  = mark_depth / mark_steps;
    erode = step / tan(mark_taper);

    // Note 68.

    multmatrix([[0, sin(back_rake), -cos(back_rake), mark_up * sin(back_rake)],
                [0, cos(back_rake),  sin(back_rake), mark_up * cos(back_rake)],
                [1, 0,               0,              width / 2]])
        for (k = [0 : mark_steps - 1])
            translate([0, 0, -(k + 1) * step])
                linear_extrude(height = step + eps)
                    offset(delta = mark_swell - k * erode)
                        zr_monogram(mark_width);
}

module deck_door_stop() {
    difference() {
        linear_extrude(height = width) deck_door_stop_profile();
        if (mark) mark_pocket();
    }
}

// Note 69.

module deck_door_stop_coupon() {
    intersection() {
        deck_door_stop();
        translate([-eps, -eps, (width - coupon_len) / 2])
            cube([length + 2 * eps, heel_height + 2 * eps, coupon_len]);
    }
}

// Note 70.

module feral_default_output_d9f2df454147() {
if (show == "coupon") deck_door_stop_coupon();
else                  deck_door_stop();
}

module feral_assembly_view_d9f2df454147(explode=false) {
feral_default_output_d9f2df454147();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_d9f2df454147();
else feral_assembly_view_d9f2df454147(view == "exploded");

// Notes

// Note 1. Deck door stop.
//
// The 44 mm version. Same geometry as parts/tpu-door-stop.scad — which is a
// parametric recreation of "TPU Door Stop" by Kyle Plansinis, CC BY-SA 4.0, so
// this file is a derivative of that work and carries the attribution with it —
// resized around the door it is actually for: the deck door, with 44 mm of gap
// under it. That file stays as the faithful copy at the reference's own size;
// this one is free to move.
//
// WHAT IS DIFFERENT, and it is only the numbers: 130 long instead of 100, a
// 52 mm heel instead of 30, the top face falling at 20 degrees instead of 12,
// and 60 mm wide instead of 25. Both counts are on auto, so the ridges and the
// grooves fill the larger part at the reference's own spacing — 18 and 33.
//
// THE HEIGHT IS THE DESIGN. The wedge touches the door wherever the top face's
// height equals the gap under it, so heel_height alone decides where it
// catches, and length and ramp_angle decide whether that is a sane object. At
// 52 it catches 97.8 mm in — three quarters of the way — over full-depth
// honeycomb, with 7 mm of heel and 19 mm of travel still in front of it. Sized
// exactly to the gap it would catch on the heel with nothing in reserve, and
// the first time the door settled it would be loose. Sized to catch at the
// middle of the ramp, which is the textbook answer, it would need a 70 mm heel
// and would be a brick.
//
// DO NOT AIM IT AT THE TOE. The last 20 mm is a 3 mm shell over clipped cells
// and it folds rather than compresses. The TPU squish is real but it is the
// last of the preload, not the mechanism — what holds the door is the travel
// left in the ramp when it first touches.
//
// SET door_gap AND READ THE ECHO. It changes no geometry. It is there so the
// file can tell you where this wedge catches on your door, and refuse to build
// one shorter than the gap.
//
// 20 DEGREES STILL SELF-LOCKS with room to spare — TPU on decking is a
// friction angle of 35 to 45 degrees — but it is the number to watch if the
// stop ever skids out. Shallower is more wedge and more length.
//
// WIDTH IS THE DOOR'S BUSINESS, not the wedge's. The slab's bottom edge lands
// across the width, so anything narrower than the slab is thick bears the door
// on a line and lets it rock. 60 covers a 1-3/4 in exterior slab with 8 mm a
// side, and takes the roll-over angle from 16 degrees at the reference's 25 mm
// to 34 at the contact height.
//
// PRINT IT IN TPU, ON ITS SIDE, which is the orientation this file builds:
// profile in XY, extruded up Z, so a 130 x 51 face is on the plate and the
// honeycomb is a set of vertical through-holes 60 mm deep. Nothing bridges,
// nothing overhangs, no supports. The width is the print's height, and that is
// the whole cost of the extra 35 mm.
//
// THE FOUR HOUSE VIEWS DO NOT SHOW THE MARK, and the preview cannot draw it.
// utils/render.sh renders in OpenSCAD's preview mode, and OpenCSG gives up on
// this part once the deboss is in the tree — the body disappears and you get a
// couple of stray walls, which looks like a broken part and is not one: the
// same file renders and builds correctly. Pass the flag through to see it:
//
// utils/render.sh parts/deck-door-stop.scad --render=cgal
//
// and to look at the back face itself, which none of the four standard views
// face, add --camera=0,0,0,90,0,258.9,0 --projection=o. utils/build.sh is
// unaffected — it evaluates the real geometry and always did.
//
// EVERYTHING ELSE IS INHERITED and documented in parts/tpu-door-stop.scad: the
// nose arc placed by its two tangencies, the shell erosion, the rebuilt
// honeycomb, and cell_min_web culling the slivers the shell cuts.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. The gap under the door, floor to slab. Drives nothing — it is what the echo
// at render time measures the wedge against, and what the assert below refuses
// to build shorter than.

// Note 4. mm

// Note 5. Extrusion depth — the width of the wedge, and the height it prints at. Set
// it from the slab's thickness, not from the wedge: 60 covers a 1-3/4 in door
// with 8 mm a side.

// Note 6. mm
// Length of the floor, knife edge to toe.

// Note 7. mm
// Height of the heel, taken to the sharp corner the fillet cuts off. The
// fillet takes about a millimetre off it — peak, echoed below, is the real
// height. Aim for about 1.2x door_gap.

// Note 8. mm
// Fall of the top face, measured from horizontal. The ridges ride this line.
// Steeper catches sooner and needs less length; shallower is more wedge.

// Note 9. deg
// Rake of the back face, measured from vertical. It leans toward the toe, so
// the base runs heel_height * tan(back_rake) behind the heel.

// Note 10. deg
// Fillet where the top face rolls over into the back face.

// Note 11. mm
// The knife edge where the back face meets the floor. Sharp on the reference;
// give it a radius here to take the point off.

// Note 12. mm

// Note 13. Radius of the nose roll at the toe.

// Note 14. mm
// Height of the toe's vertical face, below where the nose roll starts. This is
// also the height of the nose roll's centre.

// Note 15. mm
// Radius of the long arc that carries the top face down into the toe. It is
// tangent to the ramp line at one end and to the toe roll at the other, and
// those two conditions place it — nothing else here needs adjusting when it
// changes.

// Note 16. mm

// Note 17. Half-round ridges standing proud of the top face, spaced along it. They run
// the full width. 0 means as many as the pitch fits, which is what this size
// wants — 18 of them at the defaults.

// Note 18. mm, and also how far each stands proud
// Centre to centre, measured along the top face rather than horizontally, so
// the spacing holds across the nose arc as well as the straight ramp.

// Note 19. mm
// Distance along the top face, from the heel corner, to the first ridge's
// centre. Measured, not derived — it is what sets the phase of the whole set.

// Note 20. mm

// Note 21. Square grooves combed across the floor, full width. 0 means as many as it
// takes to hold groove_pitch across the floor — 33 at the defaults.

// Note 22. mm

// Note 23. mm
// Plastic left at each end of the floor, outside the first and last groove.
// The pitch falls out of this and the count.

// Note 24. mm
// Target centre-to-centre spacing, used only when groove_count is 0. The
// reference's own pitch, which is what 25 grooves come to across 100 mm.

// Note 25. mm

// Note 26. The lattice through the width. false builds the wedge solid.

// Note 27. Wall left between the lattice and every outside face.

// Note 28. mm
// Cell size across the flats. Flat side up, point to point along the length.

// Note 29. mm
// Wall between two cells. 1.68 is four 0.42 lines on a 0.4 nozzle.

// Note 30. mm
// Narrowest cut the lattice may leave where it is clipped by the shell.
// Fragments thinner than this fill in solid; cell corners round by half of it.
// At cell_wall the rule reads as one sentence — nothing thinner than a wall —
// and it is enough to clear every scrap the ramp cuts. 0 keeps them all, the
// way the reference does.

// Note 31. mm
// Where the lattice sits under the part. Both wrap at one cell pitch, so any
// value works — these two just slide the pattern until it clips well.

// Note 32. mm

// Note 33. mm

// Note 34. The ZR monogram, debossed into the back face. That face is the only solid
// panel left once the honeycomb is cut — the two big faces are mostly holes,
// the ramp is interrupted by ridges and the floor by grooves — and it is the
// face pointing at you when the stop is under a door.

// Note 35. Width of the monogram, measured across the part's width. The face is 60 wide
// by about 50 up the rake, and the mark stands 0.68 x its width, so 50 fills it
// with 5 mm a side and 34 mm of height. Take it as large as the face allows:
// the monogram's hairlines scale with it and they are the constraint.

// Note 36. mm
// Where its centre sits, measured up the back face from the knife edge.

// Note 37. mm
// How far it is cut into the 3 mm wall. 1.00 leaves 2 mm of shell behind it,
// which is five lines at 0.42, and is about as shallow as TPU can be relied on
// to hold a shadow line: the material is soft, the extrusion is fat, and a
// 0.40 deboss that reads on a rigid part reads as nothing here.

// Note 38. mm
// Wall angle of the cut, from the face. The part prints on its side, so the
// back face is a vertical wall and a prismatic pocket puts a horizontal roof
// over the top edge of every stroke — the slicer answers that with support
// material inside the lettering. Sloping the walls removes the roof entirely.
// The cost is stroke width: the deepest section is the artwork eroded by
// mark_depth / tan(taper), 0.36 mm here, which this monogram's strokes can pay
// several times over. See the same argument at length in
// parts/hobbs-chalk-holder.scad, where the artwork could not.

// Note 39. deg from the face
// The taper is a stack of prismatic bands, since offset() erodes a 2D shape and
// nothing lofts between two of them. Each band leaves a ledge as deep as itself,
// so 6 over 1.00 mm gives 0.17 mm ledges — under a layer, and invisible.

// Note 40. How much every stroke is fattened before the cut, and the only reason this
// monogram works at this size. It is a high-contrast serif: its hairlines are
// 1.4% of its height, which is 0.70 mm at a 50 mm mark — under two 0.42 lines,
// and in TPU that is a groove the nozzle never reaches the bottom of. The
// artwork would have to stand 86 mm wide for the thins to carry themselves, and
// the face is 60. Swelling adds the same amount to every edge, so the thins gain
// proportionally far more than the thicks: at 0.25 they go to 1.20 mm while the
// heavy diagonal only goes 4.2 to 4.7. Contrast drops from 6:1 to 4:1, which is
// a real change to the drawing and an invisible one at arm's length.
//
// Set it to 0 for the artwork exactly as drawn, and expect the thins to close
// up in TPU.

// Note 41. mm

// Note 42. "coupon" is a short slice through the width: the whole silhouette, every
// ridge and a column of cells, in one piece that prints in a fraction of the
// time. It answers shape, not fit — the fit question here is the whole part.

// Note 43. mm

// Note 44. deg, max angle per facet

// Note 45. mm, max chord per facet

// Note 46. ---------------------------------------------------------------------------
// The heel corner: where the ramp line and the back face would meet if the
// fillet did not cut them off. The whole top face is measured from here.

// Note 47. Down the ramp, and out of it. Unit vectors.

// Note 48. Centre of the toe roll.

// Note 49. Distance along the ramp line, from the heel corner, to where the nose arc
// takes over. Solved from the two tangencies: the nose arc's centre lies
// nose_r off the ramp line, and nose_r - toe_r from the toe roll's centre,
// which is one quadratic in that distance.

// Note 50. Centre of the nose arc, and the two points it runs between: ramp_pt on the
// ramp line, toe_pt on the toe roll.

// Note 51. where the arc leaves the ramp line

// Note 52. where it meets the toe roll

// Note 53. Total run of the top face, heel corner to the toe roll. The ridges are laid
// out along this, not along x.

// Note 54. Ridges and grooves, counted. Either the number asked for, or as many as the
// pitch fits — the second is what makes a resized wedge come out right without
// a second pass of arithmetic.

// Note 55. A point s along the top face from the heel corner: on the ramp line while
// the ramp lasts, on the nose arc after that.

// Note 56. Points along an arc, inclusive of both ends, at the current facet settings.

// Note 57. The arc that rounds corner b, between a and c, by radius r. Returns [b]
// unrounded when r is zero, so a path can carry a mix of both.

// Note 58. signed sweep, taken the short way round

// Note 59. Counter-clockwise from the knife edge: along the floor to the toe, up the
// toe face, round the nose, up the long arc, along the ramp, over the heel.

// Note 60. Where this wedge meets that door. peak is the real height — the heel fillet
// cuts the corner heel_height is measured to — catch_in is how far the toe
// travels under the door before the top face touches it, and reserve is the
// travel still left after that, which is what holds the door when it settles.

// Note 61. The wedge with no ridges, no grooves and no lattice. This is the shape the
// shell is eroded from — erode the ridged face instead and the lattice follows
// every bump in it.

// Note 62. Cut generously below the floor so no cut face is coplanar with it.

// Note 63. Hexes on a true honeycomb lattice, flat side up. circle($fn = 6) puts a
// vertex on +x, which is the orientation wanted: points along the length,
// flats across it, so no cell ceiling is a bridge in any print orientation.

// Note 64. centre to centre, across a wall

// Note 65. column pitch

// Note 66. The lattice, clipped to the inside of the shell and opened to drop slivers.

// Note 67. The monogram as a solid to subtract, drawn flat, swollen, and then laid onto
// the back face. Local x runs across the part's width, local y up the rake, local z out
// of the face toward whoever is reading it — a right-handed frame, so the mark
// is not mirrored — and every band is cut from the surface down, so the union
// of them is a staircase approximating the taper.

// Note 68. Columns of the matrix are those three local axes; the fourth is the
// centre of the mark on the face, mark_up along the rake from the origin.

// Note 69. A slab taken out of the middle of the width. The lattice runs along the
// width, so this loses nothing but length of hole.

// Note 70. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
