// Note 1.

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

show = "part";   // [part, cut, coupon, stack, fitcheck]
// Note 4.

fitcheck_offset = 0;

$fa = 4;   // Note 5.
$fs = 0.4;
eps = 0.01;

/* [Envelope] */

// Note 6.

outer_d = 205.00;
// Note 7.
total_h = 215.00;

/* [Bands] */

// Note 8.

band_t = 2.10;
// Note 9.

top_band_h = 8.00;
// Note 10.

foot_band_h = 2.00;

/* [Lattice] */

// Note 11.

strut_t = 1.74;
// Note 12.

strut_w = 1.74;
// Note 13.

strut_inset = 0.05;
// Note 14.

opening = 36.0;
// Note 15.

slice_deg = 1.5;
// Note 16.
bury = 1.0;
// Note 17.

fork = true;
fork_frac = fork ? 0.25 : 0;            // Note 18.

hand_skew = 0.10;
// Note 19.

round_ends = true;

/* [Joint] */

// Note 20.

spigot_h = 6.00;
// Note 21.

spigot_clear = 0.60;
// Note 22.

foot_chamfer = 0.50;
// Note 23.

seat_cham = 1.00;

/* [Coupon] */

// Note 24.

coupon_h = 45.00;

/* [Quality] */

// Note 25.
chord_err = 0.02;

/* [Hidden] */

// Note 26.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));

R      = outer_d / 2;
R_in   = R - band_t;                    // Note 27.
nseg   = facets(R);

bar_ro = R - strut_inset;               // Note 28.
bar_ri = bar_ro - strut_t;              // Note 29.
R_smid = bar_ro - strut_t / 2;          // Note 30.

crank  = band_t + spigot_clear;         // Note 31.
foot_h = spigot_h + crank + foot_band_h;
sp_ro  = R_in - spigot_clear;           // Note 32.
sp_ri  = sp_ro - band_t;                // Note 33.

island     = strut_w * sqrt(2);         // Note 34.
N          = max(8, round(2 * PI * R_smid / (opening + island)));
p          = 2 * PI * R_smid / N;       // Note 35.
half       = p / 2;                     // Note 36.
clear_diag = p - island;                // Note 37.
bridge_gap = (fork ? p / 4 : half) - island;   // Note 38.

stack_pitch = total_h - (spigot_h + spigot_clear + seat_cham);

// Note 39.

function zone_of(h)   = h - top_band_h - foot_h;
function rows_of(h)   = floor(zone_of(h) / half - fork_frac);
function pitch_of(h)  = zone_of(h) / (rows_of(h) + fork_frac);
function vis_of(h)    = rows_of(h) * pitch_of(h);
function fork_of(h)   = fork_frac * pitch_of(h);
function rate_of(h)   = half / pitch_of(h);                // Note 40.
function angle_of(h)  = atan(rate_of(h));
function ext_of(h)    = vis_of(h) + fork_of(h) + 2 * bury;
function twist_of(h)  = ext_of(h) * rate_of(h) / R_smid * 180 / PI;
function slices_of(h) = ceil(twist_of(h) / slice_deg);
function phase_of(h)  = 180 / N - 2 * twist_of(h) * bury / ext_of(h);
function genus_of(h)  = 1 + N * (rows_of(h) + 2) + (fork ? 2 * N : 0);
// Note 41.

function top_turn(h)  = twist_of(h) * (vis_of(h) + bury) / ext_of(h);

// Note 42.

function lattice_vol(h) = 2 * N * strut_t * island * (vis_of(h) + 2 * fork_of(h))
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
assert(rows_of(total_h) >= 1,
       "the lattice is shorter than one node row: raise total_h");
assert(rows_of(coupon_h) >= 1,
       str("the coupon needs more than ", foot_h + top_band_h + (1 + fork_frac) * half,
           " to hold one node row"));

// Note 43.

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

// Note 44.

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

// Note 45.

module forks(h) {
    fh = fork_of(h) + bury;
    tw = fh * rate_of(h) / R_smid * 180 / PI;
    sl = max(2, ceil(tw / slice_deg));
    translate([0, 0, foot_h + vis_of(h)]) {
        rotate(-top_turn(h))
            linear_extrude(height = fh, twist = -tw, slices = sl,
                           segments = 1, convexity = 10)
                bars(hand_skew);
        rotate(-top_turn(h) + 180 / N)
            linear_extrude(height = fh, twist = tw, slices = sl,
                           segments = 1, convexity = 10)
                bars();
    }
}

// Note 46.

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

// Note 47.
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
        if (fork) forks(h);
        top_band(h);
    }
}

// Note 48.
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
         " degrees, pitch ", pitch_of(total_h), ", forks ", fork_of(total_h),
         " tall, twist ", twist_of(total_h), " over ", slices_of(total_h),
         " slices, phase ", phase_of(total_h), "; top band bridges ",
         bridge_gap, "; expect genus ", genus_of(total_h)));
echo(str("coupon: ", coupon_h, " tall, ", rows_of(coupon_h), " node row at ",
         angle_of(coupon_h), " degrees; expect genus ", genus_of(coupon_h)));
echo(str("volume estimate: unit ", round(unit_vol(total_h) / 100) / 10,
         " cm3 (", round(unit_vol(total_h) * 1.27 / 100) / 10, " g PETG), coupon ",
         round(unit_vol(coupon_h) / 100) / 10, " cm3 (",
         round(unit_vol(coupon_h) * 1.27 / 100) / 10, " g)"));

// Note 49.
module feral_default_output_39cf3076f0e1() {
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
}

module feral_assembly_view_39cf3076f0e1(explode=false) {
color("DarkSeaGreen") unit(total_h);
color("MediumSeaGreen") translate([0,0,stack_pitch+(explode ? 35 : 0)]) unit(total_h);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_39cf3076f0e1();
else feral_assembly_view_39cf3076f0e1(view == "exploded");

// Notes

// Note 1. Plant screen — a lattice cylinder that drops over a spider plant so Max
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
// bridges except the top band's underside, which crosses the gaps between
// strut tops. A hexagon or a horizontal ring would bridge or overhang; a
// diamond does neither, which is why it is a diamond.
//
// THE STRUTS FORK UNDER THE RIM. At 36 mm openings the 34 strut tops sit
// 18.8 apart and a flat band over them would hang 16 mm between each pair —
// Flash Studio calls that a cantilever (anything whose far point is over
// 6 mm from what holds it, TreeSupport.cpp) and asks for supports, and it
// would print as 34 free-hanging wall loops. So a quarter pitch below the
// band every strut top sprouts a second strut of the other hand: the same
// section, the same angle, crossing its parent like any node. That doubles
// the count to 68 just under the band, evenly spaced at p/4, and the band
// crosses 6.9 mm — under the 7.8 the 18 mm design had. Ziad rejected teeth
// (a serrated band underside, no bridge at all) as looking like a saw blade;
// the forks are 4.8 mm tall and read as the mesh tightening at the rim.
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
// rows. That is what makes the strut tops evenly spaced where the forks
// spring, and the forked tops evenly spaced again a quarter pitch up where
// the band lands: at a node row the struts merge in pairs, a pitch apart. It
// also makes the genus predictable: 1 + N * (rows + 2) + 2N — a diamond
// centred on every node row, a row of triangles cut off each end, and the
// notch between every strut and its fork.
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

// Note 2. "cut" is a half-section for reading the foot and the seat. Not for printing.
// "coupon" is the fit test, see [Coupon]. "stack" draws two units seated on
// each other, for the render. "fitcheck" is their intersection in that pose
// and must build empty; see fitcheck_offset.

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. Added to the stack pitch for the fitcheck (mm). 0 is the seated pose and
// must give nothing; -0.2 must give something, or the check is not looking.

// Note 5. organic faceting per the 0.4-nozzle rule; no global high $fn

// Note 6. Outside diameter (mm). The reference's safe build envelope is 205 x 205,
// and a ring this size sits inside the probed mesh with 2.5 mm to spare.

// Note 7. Overall height of one unit (mm). SAFE_Z.

// Note 8. Wall of the top and bottom bands, and of the spigot (mm). 2.10: four loops
// and one line of gap fill, which a rim can use.

// Note 9. Height of the top band (mm). It has to swallow the spigot of the unit above:
// spigot_h + spigot_clear + seat_cham, asserted.

// Note 10. Plain full-radius band between the crank and the lattice (mm). A flat ring
// for the struts to spring from.

// Note 11. Strut thickness through the wall (mm). 1.74 is four lines at the slicer's
// 0.42 / 0.45 widths; see THE STRUT IS FOUR LINES.

// Note 12. Strut width across its own axis at 45 degrees (mm). The horizontal island
// the slicer sees is this times root two, and that island is held constant
// whatever the angle does, so the coupon slices the same strut as the part.

// Note 13. How far the struts' outer face sits inside the band's outer radius (mm).
// A bar is a flat chord and its corners stand 0.007 proud of the arc; the
// band is a polygon whose flats sit 0.02 inside it. Without this the buried
// strut ends poke 0.03 mm slivers out through the band.

// Note 14. Target clear diagonal of each diamond (mm), across the opening. Sets N.
// Was 18, which sliced as 62 islands a layer and a 9.5 hour job; 36 halves
// the islands and the time, and Max is not a small cat (Ziad, 2026-09-19).

// Note 15. Degrees of twist per slice of the extrusion. 1.5 puts the helix's chord
// error under 0.01 mm at this radius.

// Note 16. How far each end of the lattice is buried in its band (mm).

// Note 17. Fork every strut top a quarter pitch under the top band, see THE STRUTS
// FORK UNDER THE RIM. false is the plain lattice with a 16 mm span under the
// band, for comparison.

// Note 18. of a pitch, the height of the forks
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

// Note 19. Round the right-hand struts' ends (see hand_skew). false leaves them flat,
// for comparison; it is not the shipping shape.

// Note 20. Height of the spigot (mm), the part of the foot that drops into the band
// below.

// Note 21. Radial clearance between the spigot's outside and the band's bore (mm).
// See the ⚠️ in the header.

// Note 22. 45-degree chamfer on the spigot's outer bottom edge (mm). The reference's
// minimum for PETG on the textured plate. The inner edge mates with nothing
// and is left square so the first layer stays 1.6 wide.

// Note 23. 45-degree chamfer on the top band's inner edge (mm): the seat the unit
// above's crank cone lands on.

// Note 24. Height of the fit coupon (mm): the whole foot, one row of nodes, and the
// whole top band. Print two and stack them.

// Note 25. Chord error target (mm). 0.02 is the 0.4-nozzle figure.

// Note 26. Facets for a target chord error on a given radius.

// Note 27. the bands' bore

// Note 28. struts' outer face

// Note 29. struts' inner face

// Note 30. struts' mid radius, where the pitch is measured

// Note 31. radial shift of the foot's crank, and its height

// Note 32. spigot outer radius

// Note 33. spigot bore, the bottom clear opening

// Note 34. a strut's horizontal width at 45 degrees

// Note 35. node pitch round the ring

// Note 36. node-row pitch up the tube, at 45 degrees

// Note 37. clear diagonal of a diamond at 45 degrees

// Note 38. what the top band's underside crosses

// Note 39. Per-height lattice numbers, so the part and the coupon share one set of
// rules. The zone between the bands is the visible lattice — whole node rows
// with half a pitch above and below — plus the forks, a quarter pitch more.
// Whole rows, the pitch that makes them fit exactly (never under half, so the
// angle never passes 45), twist per hand over the extrusion (which runs
// through the forks and a bury into each band), and the half-pitch phase of
// the left-hand set, corrected for the bury so the lattice's ends sit midway
// between rows. Positive twist turns the profile clockwise seen from +Z.

// Note 40. tan of the strut angle

// Note 41. Degrees the right-hand struts have turned clockwise by the top of the
// visible lattice, where the forks spring; the left-hand set is 180 / N on.

// Note 42. Volume estimate (mm3): sheared prisms are base times height, less the node
// overlaps, plus the bands as plain rings. The slicer's grams are the real
// figure; this is for the echo.

// Note 43. One hand of the lattice in 2D: N radial bars, each strut_t through the wall
// and island wide, on a ring. The right hand (skew = 0) is a stadium, its
// ends half-rounds of the strut's own half thickness; the left is a plain
// rectangle drawn skew bigger and skew further in, so no face of it ever lies
// in, or runs parallel and close to, a face of the right. See hand_skew.

// Note 44. Both hands, twisted opposite ways over the visible lattice plus the bury at
// each end. segments = 1 keeps each bar edge a single segment per slice;
// without it OpenSCAD re-segments every edge at $fs and the mesh is ten times
// the size for no change in shape.

// Note 45. The forks: on every right-hand strut top a left-hand bar, and on every
// left-hand top a right-hand one, each starting where the visible lattice
// ends and running the fork height plus a bury into the band. Same section,
// same rate, the other twist, so each crosses its parent like a node, and the
// opposite hand's shape keeps their faces off each other (see hand_skew).

// Note 46. The foot, one section spun round: spigot bore, spigot's chamfered outer
// bottom edge, spigot outside, the crank out to full radius, the plain band,
// then back down the inside.

// Note 47. The top band with the seat chamfer on its inner top edge.

// Note 48. Two units seated, the upper one a stack pitch up.

// Note 49. Assembly display changes placement only; the original output remains the default.
