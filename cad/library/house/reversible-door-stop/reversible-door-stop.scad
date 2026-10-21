// Reversible TPU door stop.
//
// A parametric recreation of "Reversible TPU Door Stop", measured off
// _incoming/Reversible TPU Door Stop.stl. Source and licence unknown — ask
// Ziad for the model page before this leaves the repo.
//
// This file is the faithful copy at the reference's own size. The deck door
// version lives in parts/deck-door-stop-truss.scad and is free to move.
//
// WHAT MAKES IT REVERSIBLE: both faces are combed with half-round grip ridges,
// so either the floor or the ramp can be the side that lies on the ground. The
// ridges are true semicircles standing ridge_r proud, at the same pitch on both
// faces, and the reference fits twelve on each.
//
// THE INSIDE IS A WARREN TRUSS, not a honeycomb: four 45-degree webs, web_t
// thick, between a shell of the same thickness, leaving five large voids with
// r = void_r corners. That is the whole difference from parts/deck-door-stop.scad
// and the reason this shape exists — one perimeter loop per void instead of
// seventy cell walls a layer, and a wedge that flexes instead of one that is a
// stack of tubes.
//
// EVERY CORNER IS THE SAME RADIUS. Heel, knife edge, and toe are all 5 mm on
// the reference, and the toe roll is the only one that does structural work:
// the ramp runs dead straight from the heel fillet to a tangency with the toe
// roll, with no intermediate nose arc. That tangency is what closes the shape,
// so ramp_angle is DERIVED, not set — give it length, heel_height and toe_r and
// the ramp falls where it must. The echo below reports the angle it chose.
//
// THE BACK FACE IS VERTICAL. There is no rake here, which is what lets the
// truss run to a flat wall at the heel and what leaves a flat panel for a mark
// on the deck version.
//
// PRINT IT IN TPU, ON ITS SIDE, which is the orientation this file builds:
// profile in XY, extruded up Z, so the silhouette is on the plate and the
// voids are through-holes width deep. Nothing bridges, nothing overhangs.

/* [Overall] */

// Extrusion depth — the width of the wedge, and the height it prints at.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

width        = 30;       // mm

// Length of the floor, knife edge to toe, over the toe roll.
length       = 116.845;  // mm

// Height of the heel, taken to the sharp corner the fillet cuts off. peak,
// echoed below, is the real height.
heel_height  = 40;       // mm

/* [Corners] */

// Radius of the toe roll. This one is not cosmetic: the ramp is tangent to it,
// so it is one of the three numbers that decide ramp_angle.
toe_r        = 5;        // mm

// Fillet where the ramp rolls over into the back face.
heel_r       = 5;        // mm

// Fillet at the knife edge, where the back face meets the floor.
tail_r       = 5;        // mm

/* [Grip ridges] */

// Half-round ridges standing proud of both faces. They run the full width and
// each is a true semicircle, so ridge_r is both the radius and how far it
// stands out.
ridge_r      = 1.5;      // mm

// Centre to centre, measured along the face rather than horizontally.
ridge_pitch  = 9;        // mm

// 0 means as many as the pitch fits between the two corner fillets, which is
// twelve a face at the reference size. The first ridge sits one radius past the
// fillet's tangent point, which is what sets the phase of the whole comb.
ramp_ridge_count  = 0;
floor_ridge_count = 0;

/* [Truss] */

// The open web through the width. false builds the wedge solid.
truss        = true;

// Wall left between the voids and every outside face.
shell        = 4;        // mm

// Thickness of each 45-degree web.
web_t        = 4;        // mm

// Corner radius left in every void. Applied as an opening — erode then dilate —
// so it rounds each void's corners and drops anything narrower than 2 * void_r,
// which is what keeps the last void from running out to a knife point at the toe.
void_r       = 2;        // mm

// The truss nodes. Each bay is one low node with two webs springing off it, up
// and to the left and up and to the right; consecutive bays meet at a high node
// half a pitch along and half a pitch up. Measured off the reference mesh, where
// both node lines fall just outside the shell so the webs land on the faces.
truss_x0     = 38.238;   // mm, x of the first low node
truss_y      = 1.1715;   // mm, height of the low node line
truss_pitch  = 43.137;   // mm, low node to low node

// 0 means as many bays as the pitch fits before the toe — two at the reference
// size, which is four webs and five voids.
truss_bays   = 0;

/* [Output] */

// "coupon" is a short slice through the width: the whole silhouette, every
// ridge and a slice of every web, in a piece that prints in a fraction of the
// time. It answers shape, not fit.
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

// Ridges: either the number asked for, or as many as the pitch fits with a
// clear radius at each end.
ramp_ridges  = ramp_ridge_count  > 0 ? ramp_ridge_count
             : floor((ramp_run  - 2 * ridge_r) / ridge_pitch) + 1;
floor_ridges = floor_ridge_count > 0 ? floor_ridge_count
             : floor((floor_run - 2 * ridge_r) / ridge_pitch) + 1;

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

peak = max([for (p = profile_pts) p.y]);

echo(str("ramp ", ramp_angle, " deg, peak ", peak, " mm, ",
         ramp_ridges, " ramp ridges, ", floor_ridges, " floor ridges, ",
         bays, " truss bays"));

// The wedge with no ridges and no truss. This is the shape the shell is eroded
// from — erode the ridged face instead and the voids follow every bump in it.
module wedge_profile() {
    polygon(profile_pts);
}

module ramp_ridges_2d() {
    for (k = [0 : ramp_ridges - 1])
        translate(heel_tp + (ridge_r + k * ridge_pitch) * ramp_dir)
            circle(r = ridge_r);
}

module floor_ridges_2d() {
    for (k = [0 : floor_ridges - 1])
        translate([tail_r + ridge_r + k * ridge_pitch, 0])
            circle(r = ridge_r);
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
// outside radius, which is the 1 mm the reference has at the knife edge and the
// toe.
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

module reversible_door_stop_profile() {
    difference() {
        union() {
            wedge_profile();
            ramp_ridges_2d();
            floor_ridges_2d();
        }
        if (truss) voids_2d();
    }
}

module reversible_door_stop() {
    linear_extrude(height = width, convexity = 10) reversible_door_stop_profile();
}

// A slab taken out of the middle of the width. The voids run along the width,
// so this loses nothing but length of hole.
module reversible_door_stop_coupon() {
    intersection() {
        reversible_door_stop();
        translate([-eps, -heel_height, (width - coupon_len) / 2])
            cube([length + 2 * eps, 2 * heel_height, coupon_len]);
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_a6ba77c1b85c() {
if (show == "coupon") reversible_door_stop_coupon();
else                  reversible_door_stop();
}

module feral_assembly_view_a6ba77c1b85c(explode=false) {
feral_default_output_a6ba77c1b85c();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_a6ba77c1b85c();
else feral_assembly_view_a6ba77c1b85c(view == "exploded");
