// TPU door stop.
//
// A parametric recreation of _incoming/tpu-door-stop-model_files/tpu_door_stop.stl
// — "TPU Door Stop" by Kyle Plansinis, published 2024-05-15, CC BY-SA 4.0.
// The reference is a 3,338-triangle mesh with no editable history; every number
// below was measured off it. See "How it was measured" at the bottom of this
// header. Attribution is a licence condition of the original, so keep this
// paragraph with the file.
//
// THE FORM. A 100 x 25 wedge, 30 mm tall at the heel, whose top face falls at
// 12 degrees and then rolls over a long 56 mm arc into a 3 mm nose, so the toe
// lands on the floor almost tangentially instead of as a chisel edge. Thirteen
// half-round ridges ride that face at an even spacing measured along it — they
// are what the door's edge bites into. The floor is combed with twenty-five
// square grooves that do the same job against the floor. The back is raked
// forward 11 degrees and meets the floor in a knife edge that the door pushes
// down onto. The body between those faces is not solid: a honeycomb runs clean
// through the 25 mm width inside a 3 mm shell, which is most of what makes the
// thing squash and grip rather than skid.
//
// PRINT IT IN TPU, ON ITS SIDE, which is the orientation this file builds:
// profile in XY, extruded up Z, so a 100 x 30 face is on the plate and the
// honeycomb is a set of vertical through-holes. Nothing bridges, nothing
// overhangs, no supports. Stood on its floor instead, every hex ceiling is a
// 6.9 mm bridge and the ridges are 13 unsupported bumps.
//
// THE HONEYCOMB IS REBUILT, NOT COPIED. The reference's lattice is skewed:
// its walls measure 1.50, 1.69 and 2.00 mm depending on which way you cross
// them, and its rows step 3.5 then 4.0 mm alternately. That is a pattern that
// was placed, not generated, and there is nothing to be learned by reproducing
// its drift. This file lays a true honeycomb on the same 6 mm cell with one
// wall thickness everywhere — 1.68, which is four passes of a 0.42 line, where
// the reference's 1.69/2.00 sit off the ladder and gap-fill.
//
// CELL FRAGMENTS ARE CULLED, which the reference does not do. Clipping a
// lattice against a shell leaves slivers, and the reference keeps them: one
// of its cells comes to a 0.2 mm point against the ramp. Those print as
// stringy scraps in TPU. cell_min_web opens the cut region — erode, then
// dilate — so any fragment narrower than it fills in solid instead. The same
// pass rounds every cell corner by half that, which is no loss.
//
// SET honeycomb = false for a solid wedge and let the slicer's own infill do
// the work. That is a fair thing to want from TPU at a low infill percentage,
// and it is a much shorter render.
//
// RESIZING IT FOR A REAL DOOR. The wedge contacts the door wherever the top
// face's height equals the gap under it, so heel_height alone chooses where it
// catches, and length and ramp_angle decide whether that is a sane object.
// Aim for a heel about 1.2x the gap: contact lands around three quarters of
// the way in, over full-depth honeycomb, with the rest of the ramp left as
// travel to drive it tighter. Sized exactly to the gap it catches on the heel
// with nothing in reserve, and any settle in the door loses it. Sized to catch
// at the middle — the textbook answer — it is a brick. Do not aim it at the
// toe: the last 20 mm is a 3 mm shell over clipped cells and it folds rather
// than compresses. The nose looks after itself, since nose_r is placed by its
// two tangencies. Set ridge_count and groove_count to 0 and both fill the
// resized part at the reference's own spacing. Anything past about 20 degrees
// starts trading away the mechanical advantage, though TPU on wood has
// friction to spare — it holds to 35 degrees and more.
//
// A 44 mm deck gap, for instance, is length 130, heel_height 52, ramp_angle
// 20, width 60: it catches 98 mm in with 8 mm of heel still above the door.
// The width is the door's business, not the wedge's — the slab's bottom edge
// lands across it, so anything narrower than the slab is thick bears the door
// on a line and lets it rock. 60 covers a 1-3/4 in slab with 8 mm a side.
//
// HOW IT WAS MEASURED. Both 25 mm faces of the reference carry the same 40
// closed loops and every side triangle has a zero normal component along the
// width, so it is one profile extruded — recovered by keeping the edges that
// appear exactly once on the y = 0 cap and walking them into loops. The outer
// loop was then classified run by run: the floor grooves and the toe face are
// straight, the ridges are 13 arcs of exactly r = 1.000, the toe is r = 3.000
// centred on (97, 1.43), and the long top run is dead straight at 12.000
// degrees for 65 mm before it curves. Extending that straight run to meet the
// back face puts their intersection at (5.907, 30.000) — a 30 mm heel — with
// equal 3.045 mm tangent lengths to the arc between them, which is a 3 mm
// fillet. The nose is the one guess: a single arc constrained to touch both
// the ramp line and the toe circle fits the reference to 0.135 mm at r = 56,
// so either it is a 56 mm arc or it is a spline nobody will tell apart.
// The lattice cell is 6.000 across the flats, flat side up, in both files.

/* [Overall] */

// Extrusion depth — the width of the wedge, and the height it prints at.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

width       = 25;     // mm

// Length of the floor, knife edge to toe.
length      = 100;    // mm

// Height of the heel, taken to the sharp corner the fillet cuts off.
heel_height = 30;     // mm

// Fall of the top face, measured from horizontal. The ridges ride this line.
ramp_angle  = 12;     // deg

// Rake of the back face, measured from vertical. It leans toward the toe, so
// the base runs heel_height * tan(back_rake) behind the heel.
back_rake    = 11.14; // deg

// Fillet where the top face rolls over into the back face.
heel_r       = 3;     // mm

// The knife edge where the back face meets the floor. Sharp on the reference;
// give it a radius here to take the point off.
tail_r       = 0;     // mm

/* [Toe] */

// Radius of the nose roll at the toe.
toe_r        = 3;     // mm

// Height of the toe's vertical face, below where the nose roll starts. This is
// also the height of the nose roll's centre.
toe_lift     = 1.43;  // mm

// Radius of the long arc that carries the top face down into the toe. It is
// tangent to the ramp line at one end and to the toe roll at the other, and
// those two conditions place it — nothing else here needs adjusting when it
// changes.
nose_r       = 56;    // mm

/* [Grip ridges] */

// Half-round ridges standing proud of the top face, spaced along it. They run
// the full width. 13 is the reference's count and it fills the reference's top
// face exactly; 0 means as many as the pitch fits, which is what a resized
// wedge wants — see RESIZING in the header.
ridge_count  = 13;
ridge_r      = 1;     // mm, and also how far each stands proud

// Centre to centre, measured along the top face rather than horizontally, so
// the spacing holds across the nose arc as well as the straight ramp.
ridge_pitch  = 7.167; // mm

// Distance along the top face, from the heel corner, to the first ridge's
// centre. Measured, not derived — it is what sets the phase of the whole set.
ridge_first  = 6.046; // mm

/* [Floor grooves] */

// Square grooves combed across the floor, full width. 25 is the reference's
// count; 0 means as many as it takes to hold groove_pitch on a floor of
// whatever length — again, see RESIZING.
groove_count = 25;
groove_w     = 2;     // mm
groove_d     = 1;     // mm

// Plastic left at each end of the floor, outside the first and last groove.
// The pitch falls out of this and the count.
groove_margin = 2;    // mm

// Target centre-to-centre spacing, used only when groove_count is 0. The
// reference's own pitch, which is what 25 grooves come to across 100 mm.
groove_pitch = 3.9167;  // mm

/* [Honeycomb] */

// The lattice through the width. false builds the wedge solid.
honeycomb    = true;

// Wall left between the lattice and every outside face.
shell        = 3;     // mm

// Cell size across the flats. Flat side up, point to point along the length.
cell_af      = 6;     // mm

// Wall between two cells. 1.68 is four 0.42 lines on a 0.4 nozzle.
cell_wall    = 1.68;  // mm

// Narrowest cut the lattice may leave where it is clipped by the shell.
// Fragments thinner than this fill in solid; cell corners round by half of it.
// At cell_wall the rule reads as one sentence — nothing thinner than a wall —
// and it is enough to clear every scrap the ramp cuts. 0 keeps them all, the
// way the reference does.
cell_min_web = 1.68;  // mm

// Where the lattice sits under the part. Both wrap at one cell pitch, so any
// value works — these two just slide the pattern until it clips well.
cell_x0      = 4;     // mm
cell_z0      = 6.2;   // mm

/* [Output] */

// "coupon" is a short slice through the width: the whole silhouette, both end
// ridges and a few cells, in one piece that prints in minutes.
show         = "part";  // [part, coupon]
coupon_len   = 10;      // mm

/* [Quality] */

$fa = 4;              // deg, max angle per facet
$fs = 0.3;            // mm, max chord per facet
eps = 0.01;

// ---------------------------------------------------------------------------

// The heel corner: where the ramp line and the back face would meet if the
// fillet did not cut them off. The whole top face is measured from here.
heel_pt  = [heel_height * tan(back_rake), heel_height];

// Down the ramp, and out of it. Unit vectors.
ramp_dir = [ cos(ramp_angle), -sin(ramp_angle)];
ramp_out = [ sin(ramp_angle),  cos(ramp_angle)];

// Centre of the toe roll.
toe_ctr  = [length - toe_r, toe_lift];

// Distance along the ramp line, from the heel corner, to where the nose arc
// takes over. Solved from the two tangencies: the nose arc's centre lies
// nose_r off the ramp line, and nose_r - toe_r from the toe roll's centre,
// which is one quadratic in that distance.
nose_v   = heel_pt - toe_ctr - nose_r * ramp_out;
nose_b   = 2 * (nose_v * ramp_dir);
nose_c   = nose_v * nose_v - (nose_r - toe_r) * (nose_r - toe_r);
ramp_len = (-nose_b - sqrt(nose_b * nose_b - 4 * nose_c)) / 2;

assert(nose_b * nose_b - 4 * nose_c > 0,
       "nose_r cannot reach both the ramp line and the toe roll — raise it");

// Centre of the nose arc, and the two points it runs between: ramp_pt on the
// ramp line, toe_pt on the toe roll.
nose_ctr = heel_pt + ramp_len * ramp_dir - nose_r * ramp_out;
ramp_pt  = heel_pt + ramp_len * ramp_dir;
toe_pt   = nose_ctr + nose_r * (toe_ctr - nose_ctr) / norm(toe_ctr - nose_ctr);

function ang_at(ctr, p) = atan2(p.y - ctr.y, p.x - ctr.x);

nose_a1  = ang_at(nose_ctr, ramp_pt);   // where the arc leaves the ramp line
nose_a2  = ang_at(nose_ctr, toe_pt);    // where it meets the toe roll
toe_a2   = ang_at(toe_ctr,  toe_pt);

// Total run of the top face, heel corner to the toe roll. The ridges are laid
// out along this, not along x.
top_len  = ramp_len + nose_r * (nose_a1 - nose_a2) * PI / 180;

// Ridges and grooves, counted. Either the number asked for, or as many as the
// pitch fits — the second is what makes a resized wedge come out right without
// a second pass of arithmetic.
ridges  = ridge_count  > 0 ? ridge_count
                           : floor((top_len - ridge_first) / ridge_pitch) + 1;

grooves = groove_count > 0 ? groove_count
                           : floor((length - 2 * groove_margin - groove_w)
                                   / groove_pitch) + 1;

assert(ridge_first + (ridges - 1) * ridge_pitch < top_len,
       "the last ridge falls past the end of the top face");
assert(grooves > 1, "the floor is too short for two grooves at this pitch");

// A point s along the top face from the heel corner: on the ramp line while
// the ramp lasts, on the nose arc after that.
function top_pt(s) =
    s <= ramp_len
      ? heel_pt + s * ramp_dir
      : let (a = nose_a1 - (s - ramp_len) / nose_r * 180 / PI)
        nose_ctr + nose_r * [cos(a), sin(a)];

// Points along an arc, inclusive of both ends, at the current facet settings.
function arc_pts(ctr, r, a1, a2) =
    let (n = max(2, ceil(abs(a2 - a1) / $fa),
                    ceil(abs(a2 - a1) * PI * r / 180 / $fs)))
    [ for (i = [0 : n]) ctr + r * [cos(a1 + (a2 - a1) * i / n),
                                   sin(a1 + (a2 - a1) * i / n)] ];

function unit2(v) = v / norm(v);

// The arc that rounds corner b, between a and c, by radius r. Returns [b]
// unrounded when r is zero, so a path can carry a mix of both.
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
        // signed sweep, taken the short way round
        sw  = ((a2 - a1) + 540) % 360 - 180
    )
    arc_pts(ctr, r, a1, a1 + sw);

// Counter-clockwise from the knife edge: along the floor to the toe, up the
// toe face, round the nose, up the long arc, along the ramp, over the heel.
profile_pts = concat(
    fillet(heel_pt, [0, 0], [length, 0], tail_r),
    [[length, 0], [length, toe_lift]],
    arc_pts(toe_ctr,  toe_r,  0, toe_a2),
    arc_pts(nose_ctr, nose_r, nose_a2, nose_a1),
    fillet(ramp_pt, heel_pt, [0, 0], heel_r)
);

// The wedge with no ridges, no grooves and no lattice. This is the shape the
// shell is eroded from — erode the ridged face instead and the lattice follows
// every bump in it.
module wedge_profile() {
    polygon(profile_pts);
}

module grip_ridges() {
    for (k = [0 : ridges - 1])
        translate(top_pt(ridge_first + k * ridge_pitch))
            circle(r = ridge_r);
}

// Cut generously below the floor so no cut face is coplanar with it.
module grooves() {
    pitch = (length - 2 * groove_margin - groove_w) / (grooves - 1);
    for (k = [0 : grooves - 1])
        translate([groove_margin + k * pitch, -eps])
            square([groove_w, groove_d + eps]);
}

// Hexes on a true honeycomb lattice, flat side up. circle($fn = 6) puts a
// vertex on +x, which is the orientation wanted: points along the length,
// flats across it, so no cell ceiling is a bridge in any print orientation.
module lattice() {
    p  = cell_af + cell_wall;         // centre to centre, across a wall
    dx = p * sqrt(3) / 2;             // column pitch
    for (i = [-1 : ceil(length / dx) + 1], j = [-1 : ceil(heel_height / p) + 1])
        translate([cell_x0 + i * dx,
                   cell_z0 + j * p + (i % 2 != 0 ? p / 2 : 0)])
            circle(r = cell_af / sqrt(3), $fn = 6);
}

// The lattice, clipped to the inside of the shell and opened to drop slivers.
module core_cut() {
    offset(r =  cell_min_web / 2)
        offset(r = -cell_min_web / 2)
            intersection() {
                lattice();
                offset(r = -shell) wedge_profile();
            }
}

module tpu_door_stop_profile() {
    difference() {
        union() {
            wedge_profile();
            grip_ridges();
        }
        grooves();
        if (honeycomb) core_cut();
    }
}

module tpu_door_stop() {
    linear_extrude(height = width) tpu_door_stop_profile();
}

// A slab taken out of the middle of the width. The lattice runs along the
// width, so this loses nothing but length of hole.
module tpu_door_stop_coupon() {
    intersection() {
        tpu_door_stop();
        translate([-eps, -eps, (width - coupon_len) / 2])
            cube([length + 2 * eps, heel_height + 2 * eps, coupon_len]);
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_78af042f4709() {
if (show == "coupon") tpu_door_stop_coupon();
else                  tpu_door_stop();
}

module feral_assembly_view_78af042f4709(explode=false) {
feral_default_output_78af042f4709();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_78af042f4709();
else feral_assembly_view_78af042f4709(view == "exploded");
