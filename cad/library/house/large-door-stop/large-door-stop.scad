// Large door stop.
//
// A parametric recreation of _incoming/Large+Door+Stop.stl, a 9,388-triangle
// binary mesh with no editable history. Every number below was measured off
// that mesh — see "How it was measured" at the bottom of this header.
//
// THE FORM. A 30-degree wedge with a serrated top face, a vertical nose at the
// thick end, and a heel that steps out behind it. Between the nose and the
// heel the underside is cut away parallel to the ramp, leaving a tapered arm
// of constant vertical thickness and a re-entrant notch you can hook a toe or
// a finger into to pull the stop back out from under a door.
//
// HOW IT IS BUILT. The reference is not a solid of revolution or a loft: every
// one of its 8,320 side triangles has a normal with a zero component along the
// width, and its only two flat caps sit at 0 and 50.8 mm. It is a single 2D
// profile extruded 2 inches, which is exactly how this file draws it — one
// polygon, one linear_extrude — plus the one feature the reference does not
// have, below.
//
// THE RUBBER PAD RECESS is the reason this file is not a pure extrusion. A
// groove cut in the profile would run out at both 2-inch faces and leave the
// pad's edge standing at the side of the part, which is the edge a floor peels
// first. So the recess is a separate 3D cut, inset from all four sides of the
// bottom, and plastic stands all round it. Set pad_depth to the pad's own
// thickness and the pad finishes flush: the border takes the drag, the pad's
// edge never meets the floor square-on, and the rubber still has three
// quarters of the bottom face to grip with. pad_pocket = false gives the
// reference's bare bottom back.
//
// ⚠️ The recess leaves wall - pad_depth of plastic between its floor and the
// void, 2.00 mm at the defaults. Both of that slab's faces are exposed, so the
// rungs it should land on are 1.74 and 2.19 (per the slicing reference, not
// the design reference) — 2.00 falls between them and will gap-fill. The 3 mm
// wall inherited from the reference is off-ladder to begin with, so this is
// not new, and on a hollow door stop it is cosmetic. wall = 3.09 with
// pad_depth = 0.90 puts both on a rung and leaves the pad 0.1 proud, if that
// is ever worth a reprint.
//
// THE PROFILE is authored as a sharp-cornered path plus a radius for each
// vertex, and rounded by fillet() below. That is how the reference was drawn
// too: undo its arcs and every construction line lands on a round number. The
// ramp line stands 63.5 mm (2.5 in) above the bottom at the nose face and
// falls at exactly 30 degrees; the arm is 19.05 mm (0.75 in) thick measured
// vertically; the heel ledge is the same 19.05 and stands 6.35 mm (0.25 in)
// proud of the nose; the extrusion is 50.8 (2 in); the body fillets are all
// 3 mm. Mixed units, metric details on an inch skeleton.
//
// THE SERRATIONS are a square wave riding on the ramp line: 7 mm of land
// standing 2 mm proud, 11 mm of gap, 18 mm pitch, six of them, every corner
// rounded 1 mm. The phase is the one number in this file that is not a round
// one — see ridge_first.
//
// PRINT IT ON ITS SIDE, which is the orientation this file builds: profile in
// XY, extruded up Z, so the 2-inch face is on the plate. That is what the 3 mm
// shell is for. Stood on its bottom face instead, the shell's ceiling is the
// underside of the ramp — a 30-degree-from-horizontal roof over a sealed void,
// which is a support problem for no reason. On its side the shell is just
// perimeters and the void is a through-hole the slicer never has to bridge.
//
// SET wall = 0 FOR A SOLID and let the slicer decide the infill. The reference
// is hollow with a sealed 3 mm shell, which is a fair way to save filament in
// a file you cannot re-slice, but this is not that file.
//
// HOW IT WAS MEASURED. The two cap loops were recovered from the mesh by
// collecting the triangles whose normals run along the width, keeping the
// edges that appear exactly once, and walking them into closed loops: one
// outer, one inner, no others. Collinear runs were merged, then every surviving
// run was classified by chord length and turn angle — 0.3924 mm at 7.5 degrees
// is a 3 mm arc, 0.1743 at 10 degrees is a 1 mm arc, and everything else is a
// straight line at -30, 0, 90, or 180 degrees.
//
// ONE DELIBERATE DEVIATION, in the void. The reference's inner loop sits
// 3.000 mm from the outer along every straight run, but at the three tightest
// corners — the tip, the nose, and the notch — it rounds off rather than
// running to a point, and the wall there swells to 4.700 mm. offset(r = -wall)
// is the true erosion, so this file's void does run to a point and its wall
// measures 3.000 mm everywhere, checked against the rebuilt mesh. That is the
// version worth keeping: a uniform wall is what a shell is for, and the extra
// 1.7 mm of plastic in the reference's corners buys nothing.

/* [Overall] */

// Extrusion depth. 2 in on the reference.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

width       = 50.8;   // mm

// Fall of the top face, measured from horizontal.
ramp_angle  = 30;     // deg

// Height of the ramp line where it crosses the nose face. 2.5 in.
ramp_height = 63.5;   // mm

// Vertical thickness of the tapered arm, nose face to notch cut. 0.75 in.
arm_thick   = 19.05;  // mm

// Height of the heel ledge behind the nose. 0.75 in on the reference, which is
// the same number as arm_thick by coincidence of drawing, not by construction.
heel_height = 19.05;  // mm

// How far the heel stands proud of the nose face. 0.25 in.
heel_back   = 6.35;   // mm

// Fillet on every body corner.
corner_r    = 3;      // mm

// The bottom-back corner is square on the reference. Give it a radius here to
// break the edge.
heel_corner_r = 0;    // mm

/* [Grip serrations] */

// Raised lands along the ramp. These are the sharp-cornered figures; each
// corner loses ridge_r to its fillet, so a 7 mm land reads as 5 mm of flat.
ridge_count = 6;
ridge_pitch = 18;     // mm, land start to land start, measured along the ramp
ridge_land  = 7;      // mm, length of one land along the ramp
ridge_rise  = 2;      // mm, how far a land stands proud of the ramp line
ridge_r     = 1;      // mm, fillet at each of the four corners of a land

// Distance along the ramp, from the nose face, to the first land's leading
// corner. Measured 11.7206 off the reference by averaging all six lands; it is
// not a round number and not a multiple of anything else here, so it is
// recorded rather than derived. Change it to slide the whole set along.
ridge_first = 11.7206;   // mm

/* [Shell] */

// Wall thickness of the hollow shell. 0 builds it solid.
wall = 3;             // mm

/* [Rubber pad recess] */

// A recess in the flat bottom for a self-adhesive rubber pad, bordered on all
// four sides so friction cannot get under the pad's edge.
pad_pocket   = true;

// Depth of the recess. At the pad's own thickness the pad finishes flush.
// Shallower leaves it proud — more grip, less shelter for its edge.
pad_depth    = 1.0;   // mm

// Plastic left between the recess and each edge of the bottom face.
pad_border   = 4.0;   // mm

// Corner radius of the recess. Small, so a squarely cut pad still drops in.
pad_corner_r = 2.0;   // mm

/* [Output] */

// "coupon" is a 10 mm section cut from the middle for a test print. Not the
// part — it is open where the cut went through, on two sides of the recess.
show = "part";        // [part, coupon]

// Thickness of the coupon.
coupon_len  = 10;     // mm

// Which way the cut runs. "width" takes a 10 mm slice through the 2-inch
// width: the whole silhouette, every ridge, the notch, the heel, the 3 mm wall
// and the recess with both of its end borders, in one closed shell that prints
// flat and fast. It is the default because it is the only 10 mm coupon of this
// part that holds together.
//
// ⚠️ "length" cuts a short section across the long axis instead, and while
// wall > 0 it comes off the plate as TWO LOOSE PLATES. That is the part being
// honest, not a bug: the void runs clean through the width, so a cross-section
// at mid-length is the bottom wall and the top wall with nothing joining them.
// Only useful with wall = 0.
coupon_axis = "width";   // [width, length]

/* [Quality] */

$fa = 4;              // deg, max angle per facet
$fs = 0.3;            // mm, max chord per facet
eps = 0.01;

// ---------------------------------------------------------------------------

// Where the ramp line, extended, would meet the bottom. The tip fillet cuts
// this corner off, so the part never actually reaches it.
tip_x   = ramp_height / tan(ramp_angle);

// Where the arm's underside, extended, would meet the heel ledge. Same story:
// the notch fillet cuts it off.
notch_x = (ramp_height - arm_thick - heel_height) / tan(ramp_angle);

// The flat run of the bottom face, from the heel's back face to where the tip
// fillet starts lifting it off the plate. The recess is laid out inside this,
// not inside the overall length.
bottom_len  = heel_back + tip_x - corner_r / tan(ramp_angle / 2);

// Overall length: the tip fillet's centre sits at the end of the flat run, so
// the part reaches one radius past it.
overall_len = bottom_len + corner_r;

assert(!pad_pocket || wall == 0 || pad_depth < wall,
       "pad_depth must stay inside the shell wall or the recess opens into the void");
assert(!pad_pocket || (bottom_len - 2 * pad_border > 2 * pad_corner_r &&
                       width      - 2 * pad_border > 2 * pad_corner_r),
       "pad_border leaves no room for a recess on the bottom face");

// A point on the ramp, t along it from the nose face and v out from it.
function ramp_pt(t, v) = [
    t * cos(ramp_angle) + v * sin(ramp_angle),
    ramp_height - t * sin(ramp_angle) + v * cos(ramp_angle)
];

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
        sw  = ((a2 - a1) + 540) % 360 - 180,
        n   = max(2, ceil(abs(sw) / $fa), ceil(abs(sw) * PI * r / 180 / $fs))
    )
    [ for (i = [0 : n]) ctr + r * [cos(a1 + sw * i / n), sin(a1 + sw * i / n)] ];

function round_path(pts, radii) =
    let (n = len(pts))
    [ for (i = [0 : n - 1])
        each fillet(pts[(i + n - 1) % n], pts[i], pts[(i + 1) % n], radii[i]) ];

// One land, walked from the tip end toward the nose, so t runs downhill:
// up off the ramp line, along the land, back down. k counts from the nose.
function ridge_pts(k) =
    let (t_dn = ridge_first + ridge_land + k * ridge_pitch,
         t_up = ridge_first + k * ridge_pitch)
    [ ramp_pt(t_dn, 0), ramp_pt(t_dn, ridge_rise),
      ramp_pt(t_up, ridge_rise), ramp_pt(t_up, 0) ];

// Counter-clockwise from the bottom-back corner: along the bottom to the tip,
// up the serrated ramp, down the nose face, down the arm's underside, back
// along the heel ledge.
sharp_pts = concat(
    [[-heel_back, 0], [tip_x, 0]],
    [ for (k = [ridge_count - 1 : -1 : 0]) each ridge_pts(k) ],
    [[0, ramp_height],
     [0, ramp_height - arm_thick],
     [notch_x, heel_height],
     [-heel_back, heel_height]]
);

sharp_radii = concat(
    [heel_corner_r, corner_r],
    [ for (k = [1 : ridge_count * 4]) ridge_r ],
    [corner_r, corner_r, corner_r, corner_r]
);

module door_stop_profile() {
    polygon(round_path(sharp_pts, sharp_radii));
}

module door_stop_body() {
    // Sit the part in the positive quadrant, bottom-back corner on the origin.
    translate([heel_back, 0, 0])
        linear_extrude(height = width)
            if (wall > 0)
                difference() {
                    door_stop_profile();
                    offset(r = -wall) door_stop_profile();
                }
            else
                door_stop_profile();
}

// The recess, as a solid to subtract. Drawn flat and stood up, so its 2D x is
// the part's length and its 2D y is the part's width. It starts eps below the
// bottom face so no cut face is coplanar with it.
module pad_recess() {
    translate([0, pad_depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = pad_depth + eps)
                offset(r = pad_corner_r)
                    translate([pad_border + pad_corner_r, pad_border + pad_corner_r])
                        square([bottom_len - 2 * (pad_border + pad_corner_r),
                                width      - 2 * (pad_border + pad_corner_r)]);
}

module door_stop() {
    difference() {
        door_stop_body();
        if (pad_pocket) pad_recess();
    }
}

// A slab taken out of the middle. Cut generously past the part in the two
// directions it is not slicing, so the only faces the cube contributes are the
// two it is meant to.
module door_stop_coupon() {
    over = ramp_height + corner_r;
    intersection() {
        door_stop();
        if (coupon_axis == "length")
            translate([(overall_len - coupon_len) / 2, -eps, -eps])
                cube([coupon_len, over, width + 2 * eps]);
        else
            translate([-eps, -eps, (width - coupon_len) / 2])
                cube([overall_len + 2 * eps, over, coupon_len]);
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_0c911c45941c() {
if (show == "coupon") door_stop_coupon();
else                  door_stop();
}

module feral_assembly_view_0c911c45941c(explode=false) {
feral_default_output_0c911c45941c();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_0c911c45941c();
else feral_assembly_view_0c911c45941c(view == "exploded");
