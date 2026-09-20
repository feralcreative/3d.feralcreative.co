// Plant screen — a lattice cylinder that drops over a spider plant so Max
// cannot chew the leaves, and stacks on itself when the plant outgrows it.
//
// A tube whose wall is a diamond lattice of helical struts, with a solid band
// at each end. Ziad asked for at least 8 inches across, as tall as the machine
// will print, no supports, transparent PETG, as light as it can be without
// being delicate, and stackable. Outside Ø205.00 (the reference's safe
// envelope) by 215.00 tall (SAFE_Z), which is 8.07 by 8.46 inches.
//
// THE LATTICE IS TWO SETS OF HELICES. Each hand is a ring of N radial bars
// twist-extruded up the tube; the two hands cross and make the diamonds. The
// struts run at 45 degrees from vertical, the reference's overhang limit, so
// nothing overhangs, and every diamond's top is a node — a point — so nothing
// bridges except the top band's underside, which crosses gaps of ~8 mm
// between struts. A hexagon or a horizontal ring would bridge or overhang;
// a diamond does neither, which is why it is a diamond.
//
// THE STRUT IS FOUR LINES. 1.74 through the wall is 0.42 + 0.45 + 0.45 + 0.42,
// the corrected four-loop rung in the slicing reference, and the installed
// process slices two wall loops, so anything wider than 1.74 comes out as the
// same four lines plus a gap-fill core. The bands are 2.10 because they can
// afford the one continuous line of gap fill and it stiffens the rim. Each
// strut is a 1.74 x 2.46 island on every lattice layer, thirty-four of them
// round the ring; the slicing reference's feed-drive rule is deposit per
// layer against retractions, and at ~9 mm of filament per layer against
// 34 x 0.8 mm retracted this is a 3:1 layer, nowhere near the 13:1 that
// starved the collet. Every island costs the same retract, hop and travel
// whatever its size, so the island count, not the plastic, is the print
// time: 62 of them was 32 s a layer for 16 mm of filament.
//
// THE PATTERN CLOSES. The strut angle floats a hair under 45 so that an integer
// number of node rows fits the visible lattice, and the left-hand set is
// rotated half a bar pitch so both ends of the lattice fall midway between
// rows. That is what keeps the top band's bridges at p/2 - island rather than
// a full pitch: at a node row the struts merge in pairs and the band would
// have to cross ~13 mm; midway between rows they are evenly spaced and it
// crosses ~8. It also makes the genus predictable: 1 + N * (rows + 2) — a
// diamond is centred on every node row, and the bands cut a row of triangles
// off each end.
//
// STACKING IS SPIGOT-DOWN ON A CONE SEAT. The bottom 6 mm of each unit is a
// spigot ring inset by the band wall plus a clearance, so it drops inside the
// top band of the unit below; the wall then cranks back out to full radius at
// 45 degrees, and that outer cone is what seats, on a matching 45-degree
// chamfer cut into the top band's inner edge. Parallel cones, so it centres
// itself and bears on a surface rather than an edge, and the clearance only
// decides how far the spigot hangs into the band below, not whether it seats.
// Printed as drawn, spigot on the bed, so the only first-layer feature is the
// spigot's outside — a loose fit with its own 0.5 chamfer against PETG's
// elephant foot — and both precision surfaces are up off the plate. The
// socket is the other way up (a recess with a ceiling) and would not print.
//
// The clearance lives entirely on the foot. The top band's bore is the fixed
// reference, so if unit #1's rim prints out of round, unit #2's foot can be
// re-cut to it without touching anything else.
//
// ⚠️ NOTHING NEAR Ø200 HAS BEEN MEASURED ON THIS MACHINE. Every fit number in
// the repo is a bore of Ø54 or less (which lose 0.23–0.27 on diameter), and
// the reference says not to extrapolate. The 0.60 radial clearance is the
// free-fit figure doubled for a ring that will not be round to 0.3 mm, and the
// coupon is the first datapoint: two of them stacked test the seat, the
// spigot, the 45-degree struts and the ring footprint. What a 30 mm coupon
// cannot see is a 215 mm print's top band shrinking free while its foot is
// held by the plate; after unit #1 is printed, drop a coupon onto its real top
// before printing unit #2.
//
// The coupon is the only thing here a plate can answer, and there is one
// variant for it, so the plate and the component are the same. Keep the
// names stable — utils/coupon.sh reads these and knows nothing about the part.
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// "cut" is a half-section for reading the foot and the seat. Not for printing.
// "coupon" is the fit test, see [Coupon]. "stack" draws two units seated on
// each other, for the render. "fitcheck" is their intersection in that pose
// and must build empty; see fitcheck_offset.
show = "part";   // [part, cut, coupon, stack, fitcheck]
// Added to the stack pitch for the fitcheck (mm). 0 is the seated pose and
// must give nothing; -0.2 must give something, or the check is not looking.
fitcheck_offset = 0;

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Envelope] */

// Outside diameter (mm). The reference's safe build envelope is 205 x 205,
// and a ring this size sits inside the probed mesh with 2.5 mm to spare.
outer_d = 205.00;
// Overall height of one unit (mm). SAFE_Z.
total_h = 215.00;

/* [Bands] */

// Wall of the top and bottom bands, and of the spigot (mm). 2.10: four loops
// and one line of gap fill, which a rim can use.
band_t = 2.10;
// Height of the top band (mm). It has to swallow the spigot of the unit above:
// spigot_h + spigot_clear + seat_cham, asserted.
top_band_h = 8.00;
// Plain full-radius band between the crank and the lattice (mm). A flat ring
// for the struts to spring from.
foot_band_h = 2.00;

/* [Lattice] */

// Strut thickness through the wall (mm). 1.74 is four lines at the slicer's
// 0.42 / 0.45 widths; see THE STRUT IS FOUR LINES.
strut_t = 1.74;
// Strut width across its own axis at 45 degrees (mm). The horizontal island
// the slicer sees is this times root two, and that island is held constant
// whatever the angle does, so the coupon slices the same strut as the part.
strut_w = 1.74;
// How far the struts' outer face sits inside the band's outer radius (mm).
// A bar is a flat chord and its corners stand 0.007 proud of the arc; the
// band is a polygon whose flats sit 0.02 inside it. Without this the buried
// strut ends poke 0.03 mm slivers out through the band.
strut_inset = 0.05;
// Target clear diagonal of each diamond (mm), across the opening. Sets N.
// Was 18, which sliced as 62 islands a layer and a 9.5 hour job; 36 halves
// the islands and the time, and Max is not a small cat (Ziad, 2026-09-19).
opening = 36.0;
// Degrees of twist per slice of the extrusion. 1.5 puts the helix's chord
// error under 0.01 mm at this radius.
slice_deg = 1.5;
// How far each end of the lattice is buried in its band (mm).
bury = 1.0;
// How much bigger the left-hand struts are drawn than the right-hand ones, on
// every face (mm), and the right-hand struts have rounded ends. At a node the
// two hands sit at the same angle with the same section, so with identical
// bars every face of one lies in a face of the other and the union throws off
// zero-area triangles — 8,000 of them in the first build, and the slicer's
// repair of those layers printed a tenth of each island. Drawn 0.05 apart the
// faces only cross, but two parallel ends still pass within a hundredth of
// each other on some layer near every node, and the slicer's polygon cleanup
// wrecked those layers just the same. A round end meets a flat one at a
// point, never along an edge, and 0.10 keeps the step in the merged island
// clear of the slicer's 0.012 resolution. What is left is the crossing
// itself: on the one or two layers where two struts have all but separated,
// the island between them necks down to nothing and the slicer starves that
// neck — 1.2% of the lattice's wall segments, all at nodes, where the
// material is doubled anyway. Every X crossing sliced flat does this.
hand_skew = 0.10;
// Round the right-hand struts' ends (see hand_skew). false leaves them flat,
// for comparison; it is not the shipping shape.
round_ends = true;

/* [Joint] */

// Height of the spigot (mm), the part of the foot that drops into the band
// below.
spigot_h = 6.00;
// Radial clearance between the spigot's outside and the band's bore (mm).
// See the ⚠️ in the header.
spigot_clear = 0.60;
// 45-degree chamfer on the spigot's outer bottom edge (mm). The reference's
// minimum for PETG on the textured plate. The inner edge mates with nothing
// and is left square so the first layer stays 1.6 wide.
foot_chamfer = 0.50;
// 45-degree chamfer on the top band's inner edge (mm): the seat the unit
// above's crank cone lands on.
seat_cham = 1.00;

/* [Coupon] */

// Height of the fit coupon (mm): the whole foot, one row of nodes, and the
// whole top band. Print two and stack them.
coupon_h = 40.00;

/* [Quality] */

// Chord error target (mm). 0.02 is the 0.4-nozzle figure.
chord_err = 0.02;

/* [Hidden] */

// Facets for a target chord error on a given radius.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));

R      = outer_d / 2;
R_in   = R - band_t;                    // the bands' bore
nseg   = facets(R);

bar_ro = R - strut_inset;               // struts' outer face
bar_ri = bar_ro - strut_t;              // struts' inner face
R_smid = bar_ro - strut_t / 2;          // struts' mid radius, where the pitch is measured

crank  = band_t + spigot_clear;         // radial shift of the foot's crank, and its height
foot_h = spigot_h + crank + foot_band_h;
sp_ro  = R_in - spigot_clear;           // spigot outer radius
sp_ri  = sp_ro - band_t;                // spigot bore, the bottom clear opening

island     = strut_w * sqrt(2);         // a strut's horizontal width at 45 degrees
N          = max(8, round(2 * PI * R_smid / (opening + island)));
p          = 2 * PI * R_smid / N;       // node pitch round the ring
half       = p / 2;                     // node-row pitch up the tube, at 45 degrees
clear_diag = p - island;                // clear diagonal of a diamond at 45 degrees
bridge_gap = half - island;             // what the top band's underside crosses

stack_pitch = total_h - (spigot_h + spigot_clear + seat_cham);

// Per-height lattice numbers, so the part and the coupon share one set of
// rules. Visible lattice, whole node rows in it, the angle that makes them fit
// exactly, twist per hand over the buried extrusion, and the half-pitch phase
// of the left-hand set, corrected for the bury so the visible ends sit midway
// between rows. Positive twist turns the profile clockwise seen from +Z.
function vis_of(h)    = h - top_band_h - foot_h;
function rows_of(h)   = floor(vis_of(h) / half);
function rate_of(h)   = rows_of(h) * half / vis_of(h);     // tan of the strut angle
function angle_of(h)  = atan(rate_of(h));
function ext_of(h)    = vis_of(h) + 2 * bury;
function twist_of(h)  = ext_of(h) * rate_of(h) / R_smid * 180 / PI;
function slices_of(h) = ceil(twist_of(h) / slice_deg);
function phase_of(h)  = 180 / N - 2 * twist_of(h) * bury / ext_of(h);
function genus_of(h)  = 1 + N * (rows_of(h) + 2);

// Volume estimate (mm3): sheared prisms are base times height, less the node
// overlaps, plus the bands as plain rings. The slicer's grams are the real
// figure; this is for the echo.
function lattice_vol(h) = 2 * N * strut_t * island * vis_of(h)
                        - N * rows_of(h) * strut_t * island * island / (2 * rate_of(h));
function ring_vol(ro, ri, hh) = PI * (ro * ro - ri * ri) * hh;
function bands_vol(h) = ring_vol(sp_ro, sp_ri, spigot_h)
                      + ring_vol(R_in + crank / 2, sp_ri + crank / 2, crank)
                      + ring_vol(R, R_in, foot_band_h)
                      + ring_vol(R, R_in, top_band_h);
function unit_vol(h) = lattice_vol(h) + bands_vol(h);

assert(outer_d <= 205.0,
       "outer_d is outside the 205 safe envelope");
assert(total_h <= 215.0,
       "total_h is above SAFE_Z 215");
assert(strut_t >= 0.84,
       "strut_t is under two lines: raise it");
assert(strut_w >= 0.84,
       "strut_w is under two lines: raise it");
assert(N >= 8,
       "fewer than 8 struts per hand: reduce opening");
assert(clear_diag > 0,
       "the struts fill the wall: raise opening or reduce strut_w");
assert(angle_of(total_h) <= 45 + 1e-9,
       "the strut angle is over 45 degrees, which cannot happen: check rows_of");
assert(sqrt(bar_ro * bar_ro + island * island / 4) < R * cos(180 / nseg),
       "bar corners poke out through the band's flats: raise strut_inset");
assert(bar_ri - hand_skew > R_in,
       "the struts' inner face is inside the band's bore: reduce strut_t or raise strut_inset");
assert(hand_skew > 0,
       "hand_skew has to be positive; identical hands make a degenerate mesh");
assert(spigot_clear > 0,
       "spigot_clear must be positive");
assert(spigot_h + spigot_clear + seat_cham < top_band_h,
       str("the spigot hangs ", spigot_h + spigot_clear + seat_cham,
           " below the rim and the band is only ", top_band_h, ": raise top_band_h"));
assert(seat_cham < band_t,
       "seat_cham is deeper than the band wall");
assert(foot_chamfer < spigot_h,
       "foot_chamfer is taller than the spigot");
assert(bridge_gap <= 30,
       str("the top band would bridge ", bridge_gap, " mm: reduce opening"));
assert(vis_of(total_h) > half,
       "the lattice is shorter than one node row: raise total_h");
assert(vis_of(coupon_h) > half,
       str("the coupon needs more than ", foot_h + top_band_h + half, " to hold one node row"));

// One hand of the lattice in 2D: N radial bars, each strut_t through the wall
// and island wide, on a ring. The right hand (skew = 0) is a stadium, its
// ends half-rounds of the strut's own half thickness; the left is a plain
// rectangle drawn skew bigger and skew further in, so no face of it ever lies
// in, or runs parallel and close to, a face of the right. See hand_skew.
module bars(skew = 0) {
    r = strut_t / 2;
    for (i = [0 : N - 1])
        rotate(i * 360 / N)
            if (skew == 0 && round_ends)
                hull() {
                    translate([bar_ri + r, -island / 2 + r]) circle(r = r, $fn = 12);
                    translate([bar_ri + r,  island / 2 - r]) circle(r = r, $fn = 12);
                }
            else
                translate([bar_ri - skew, -island / 2 - skew])
                    square([strut_t, island + 2 * skew]);
}

// Both hands, twisted opposite ways over the visible lattice plus the bury at
// each end. segments = 1 keeps each bar edge a single segment per slice;
// without it OpenSCAD re-segments every edge at $fs and the mesh is ten times
// the size for no change in shape.
module lattice(h) {
    tw = twist_of(h);
    sl = slices_of(h);
    translate([0, 0, foot_h - bury]) {
        linear_extrude(height = ext_of(h), twist = tw, slices = sl,
                       segments = 1, convexity = 10)
            bars();
        linear_extrude(height = ext_of(h), twist = -tw, slices = sl,
                       segments = 1, convexity = 10)
            rotate(phase_of(h)) bars(hand_skew);
    }
}

// The foot, one section spun round: spigot bore, spigot's chamfered outer
// bottom edge, spigot outside, the crank out to full radius, the plain band,
// then back down the inside.
module foot() {
    pts = [
        [sp_ri,                0],
        [sp_ro - foot_chamfer, 0],
        [sp_ro,                foot_chamfer],
        [sp_ro,                spigot_h],
        [R,                    spigot_h + crank],
        [R,                    foot_h],
        [R_in,                 foot_h],
        [R_in,                 spigot_h + crank],
        [sp_ri,                spigot_h]
    ];
    rotate_extrude(angle = 360, $fn = nseg) polygon(pts);
}

// The top band with the seat chamfer on its inner top edge.
module top_band(h) {
    pts = [
        [R_in,             h - top_band_h],
        [R,                h - top_band_h],
        [R,                h],
        [R_in + seat_cham, h],
        [R_in,             h - seat_cham]
    ];
    rotate_extrude(angle = 360, $fn = nseg) polygon(pts);
}

module unit(h) {
    union() {
        foot();
        lattice(h);
        top_band(h);
    }
}

// Two units seated, the upper one a stack pitch up.
module stack(dz = 0) {
    unit(total_h);
    translate([0, 0, stack_pitch + dz]) unit(total_h);
}

echo(str("plant screen: Ø", outer_d, " x ", total_h, ", bore Ø", 2 * R_in,
         ", spigot Ø", 2 * sp_ro, " over Ø", 2 * sp_ri,
         " (the bottom clear opening), stack pitch ", stack_pitch));
echo(str("lattice: ", N, " struts per hand, pitch ", p, ", clear diagonal ",
         clear_diag, ", strut ", strut_t, " x ", island, " island; ",
         rows_of(total_h), " node rows at ", angle_of(total_h),
         " degrees, twist ", twist_of(total_h), " over ", slices_of(total_h),
         " slices, phase ", phase_of(total_h), "; top band bridges ",
         bridge_gap, "; expect genus ", genus_of(total_h)));
echo(str("coupon: ", coupon_h, " tall, ", rows_of(coupon_h), " node row at ",
         angle_of(coupon_h), " degrees; expect genus ", genus_of(coupon_h)));
echo(str("volume estimate: unit ", round(unit_vol(total_h) / 100) / 10,
         " cm3 (", round(unit_vol(total_h) * 1.27 / 100) / 10, " g PETG), coupon ",
         round(unit_vol(coupon_h) / 100) / 10, " cm3 (",
         round(unit_vol(coupon_h) * 1.27 / 100) / 10, " g)"));

if (show == "coupon")
    unit(coupon_h);
else if (show == "cut")
    difference() {
        unit(total_h);
        translate([-R - 1, -R - 1, -eps]) cube([2 * R + 2, R + 1, total_h + 1]);
    }
else if (show == "stack")
    stack();
else if (show == "fitcheck")
    intersection() {
        unit(total_h);
        translate([0, 0, stack_pitch + fitcheck_offset]) unit(total_h);
    }
else if (show == "part")
    unit(total_h);
