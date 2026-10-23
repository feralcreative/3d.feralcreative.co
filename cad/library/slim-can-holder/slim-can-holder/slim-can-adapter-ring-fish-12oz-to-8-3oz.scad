// Note 1.

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

show = "part";   // [part, cut, coupon]

$fa = 4;   // Note 4.
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Note 5.

can_d = 53.0;
// Note 6.

can_slop = 0.40;
// Note 7.

bore_comp = 0.60;

/* [Host — the fish this drops into] */

// Note 8.

host_bore_d = 58.40;
// Note 9.

host_bore_loss = 0.23;
// Note 10.
host_rib_h = 0.30;
// Note 11.
host_floor_z = 5.40;
// Note 12.
host_bore_top_z = 86.03;
// Note 13.

host_mouth_low_z = 89.3;
// Note 14.

host_drain_d = 12.0;

/* [Sleeve] */

// Note 15.

wall_w = 1.68;
// Note 16.

proud = -1.0;
// Note 17.

base_cham = 0.50;
// Note 18.
rim_cham = 0.50;
// Note 19.

mouth_cham_r = 0.60;
mouth_cham_h = 1.20;

/* [Grip ribs] */

// Note 20.
rib_count = 6;
rib_h     = 0.30;   // Note 21.
rib_w     = 3.00;   // Note 22.
rib_ramp  = 8.0;    // Note 23.
rib_foot  = 2.0;    // Note 24.

/* [Fit coupon] */

// Note 25.

coupon_h = 20.00;

/* [Quality] */

// Note 26.
chord_err = 0.02;

/* [Hidden] */

// Note 27.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Note 28.
function r_hole(r, n) = r / cos(180 / n);

bore_d    = can_d + can_slop + bore_comp;
bore_r    = bore_d / 2;
sleeve_od = bore_d + 2 * wall_w;
sleeve_r  = sleeve_od / 2;

rim_z     = host_mouth_low_z + proud;      // Note 29.
total_h   = rim_z - host_floor_z;          // Note 30.

nseg      = facets(sleeve_r);
r_bore    = r_hole(bore_r, nseg);

// Note 31.
host_across_ribs = host_bore_d - host_bore_loss - 2 * host_rib_h;
host_clear       = host_across_ribs - sleeve_od;

rib_r    = rib_h > 0 ? (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h) : 0;
rib_ax   = bore_r + rib_r - rib_h;
rib_z0   = base_cham + 1.0;
rib_z1   = total_h - mouth_cham_h - 1.0;

assert(sleeve_od < host_bore_d - 2 * host_rib_h,
       str("the sleeve is fatter than the fish's ribs will pass: ",
           sleeve_od, " against ", host_bore_d - 2 * host_rib_h));
assert(wall_w >= 1.26,
       "the wall is under 3 lines at 0.42: raise wall_w");
assert(bore_r + mouth_cham_r < sleeve_r - rim_cham,
       "the mouth lead-in has run into the rim's chamfer: the rim has no top");
assert(bore_d > host_drain_d + 2,
       "the sleeve's bottom ring sits over the fish's drain");
assert(rim_z > host_bore_top_z + 1,
       "the rim is down inside the fish's bore: raise proud");
assert(rib_z1 - rib_ramp > rib_z0 + rib_foot,
       "the rib ramp and foot overlap: the sleeve is too short for them");
assert(coupon_h > rib_z0 + rib_foot + 5,
       "the coupon is too short to reach full-proud rib");

// Note 32.

module sleeve_solid() {
    pts = [
        [r_bore,                 0],
        [sleeve_r - base_cham,   0],
        [sleeve_r,               base_cham],
        [sleeve_r,               total_h - rim_cham],
        [sleeve_r - rim_cham,    total_h],
        [r_bore + mouth_cham_r,  total_h],
        [r_bore,                 total_h - mouth_cham_h]
    ];
    rotate_extrude(angle = 360, $fn = nseg) polygon(pts);
}

module ribs() {
    n = facets(rib_r);
    for (i = [0 : rib_count - 1])
        // Note 33.

        rotate([0, 0, 30 + i * 360 / rib_count])
            hull() {
                translate([bore_r + rib_r, 0, rib_z0])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([rib_ax, 0, rib_z0 + rib_foot])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([rib_ax, 0, rib_z1 - rib_ramp])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([bore_r + rib_r, 0, rib_z1])
                    cylinder(r = rib_r, h = eps, $fn = n);
            }
}

// Note 34.

module sleeve() {
    union() {
        sleeve_solid();
        if (rib_count > 0 && rib_h > 0)
            intersection() {
                ribs();
                cylinder(r = sleeve_r - 0.20, h = total_h, $fn = nseg);
            }
    }
}

// Note 35.
module fit_coupon() {
    intersection() {
        sleeve();
        translate([-sleeve_od, -sleeve_od, -eps])
            cube([2 * sleeve_od, 2 * sleeve_od, coupon_h + eps]);
    }
}

echo(str("sleeve: outside ", sleeve_od, "  bore ", bore_d,
         "  across ribs ", bore_d - 2 * rib_h, "  wall ", wall_w,
         "  ", total_h, " tall, floor at ", host_floor_z,
         " to rim at ", rim_z, " on the fish"));
echo(str("in the fish: faces ", host_across_ribs,
         " across its printed ribs, clearance ", host_clear,
         " on diameter; rim stands ", proud,
         " above the low corner of the mouth (negative is below it) and ",
         rim_z - host_bore_top_z, " above the bore's top"));
echo(str("on the can: printed bore ", bore_d - host_bore_loss,
         ", across ribs ", bore_d - host_bore_loss - 2 * rib_h,
         ", clearance ", bore_d - host_bore_loss - 2 * rib_h - can_d,
         " on a ", can_d, " can"));

// Note 36.

module feral_default_output_1a8d7f3046da() {
if (show == "coupon")
    fit_coupon();
else if (show == "cut")
    difference() {
        sleeve();
        translate([-sleeve_od, -sleeve_od, -eps])
            cube([2 * sleeve_od, sleeve_od, total_h + 1]);
    }
else if (show == "part")
    sleeve();
}

module feral_assembly_view_1a8d7f3046da(explode=false) {
feral_default_output_1a8d7f3046da();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_1a8d7f3046da();
else feral_assembly_view_1a8d7f3046da(view == "exploded");

// Notes

// Note 1. Sleeve — drops into the fish koozie and holds a 250 ml / 8.3 oz slim can
// instead of the 12 oz one.
//
// The fish-koozie cousin of slim-can-adapter-ring-12oz-to-8-3oz.scad, and
// the same sleeve: Ø54.00 bore with six grip ribs for the 250 ml can, a 1.68
// wall, Ø57.36 outside, which goes into the fish's Ø58.40 bore past its six
// ribs exactly as a 12 oz can does. The fish's bore is the holders' bore to
// the last digit — same recipe, same ribs, same 0.23 of pull-in assumed — so
// every number in [Can], [Host] and [Grip ribs] is lifted from that ring and
// none of them is a decision made here.
//
// WHAT IS DIFFERENT IS THE TOP, AND THERE ISN'T ONE. The holders have a flat
// Ø76.20 rim for a lip to sit on and be lifted by. The fish has a mouth. Its
// Ø58.40 bore is cut straight up through both jaws to the tips of the lips,
// so above the bore's top (z 86.0 on the fish, lead-in to 86.6) there is no
// rim, no ledge and no room: the mouth is the bore, continued, with the jaws
// standing 105 to 117 mm up on two sides and the corners of the mouth down
// at 89 and 92–98 on the other two. Measured on the built mesh of
// slim-can-holder-3in-12oz-fish v02, in 30-degree sectors from +x: 97.5, 110.1, 116.9,
// 116.8, 109.9, 98.3, 89.3, 104.6, 111.9, 111.9, 105.5, 91.9. A lip cannot
// go anywhere in that.
//
// So there is no lip, and the sleeve works the other way round from the
// ring: it stands on the fish's floor instead of hanging off a rim, and it
// comes up through the bore's top and the lead-in to end 1 mm below the low
// corner of the mouth, so that nothing of it shows outside the fish (Ziad,
// 2026-09-19: the ring should not be visible outside the fish's mouth; the
// first draft stood 10 mm proud there as a handle). The bottom is open, like
// the ring's, so the can sits on the fish's own floor and the fish's drain
// still pushes it out from underneath. Nothing sets the depth but the
// floor, which is flat and on the axis; a lip seated on the fish's skewed
// lead-in would have sat crooked.
//
// ⚠️ WITH THE RIM HIDDEN THERE IS NOTHING TO PULL THE SLEEVE OUT BY. The
// fish's ribs hold it at 0.21 on diameter, snug, and the rim is a 1.68 mm
// edge flush inside a Ø58.4 channel. The can comes out through the drain
// as before; the sleeve does not, short of a fingernail on its rim. If that
// matters, the fix is a floor: a closed bottom with its own small drain
// turns the fish's Ø12 drain into an ejector for the sleeve, and gives the
// print a disc to stand on instead of a ring. Not done, not asked for.
//
// THE WALL IS ONE RUNG, for the ring's reason: between a Ø54.00 bore and an
// outside that has to pass the fish's ribs there is 1.68 of wall and no more.
// The slicing reference's four-loop figure is 1.74; 1.68 is what the ring is
// drawn at and the two should be printed and judged together.
//
// ORIENTATION. Drawn as used and PRINTED THE SAME WAY, open bottom on the
// bed: there is no lip to turn it over for, and printed this way up the
// first layer is the base with its 0.50 chamfer and a square inside edge,
// 1.18 wide, where the rim end would put a 0.4 mm ring on the plate. Going
// up, the rib feet grow inward at 8 degrees, the rib ramps and the base
// chamfer narrow, and the mouth lead-in at the top opens the bore outward,
// all of which the printer sees as nothing. The rim's outside chamfer
// narrows going up too. An 83 mm tube on a 1.2 mm ring is tall for its foot;
// if it lets go of the plate, a brim is the slicer's answer, not a wider
// foot that would not pass the ribs.
//
// ⚠️ THE ONE THING NOT PROVEN is how an outside diameter prints on this
// machine — the same gap the ring has, and neither has been printed yet.
// The coupon is the bottom 20 mm of the sleeve, printed exactly as the
// sleeve prints, so the base chamfer is on the bed and the cut face is at
// the top where there is no elephant foot to fake a tight reading. It tests
// the sleeve in the fish and a can in the sleeve at once.
//
// The coupon is the only thing here a plate can answer, and there is one
// variant for it, so the plate and the component are the same. Keep the
// names stable — utils/coupon.sh reads these and knows nothing about the part.

// Note 2. "cut" is a half-section for reading the wall, the chamfers and the ribs.
// Not for printing. "coupon" is the fit test; see [Fit coupon].

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. organic faceting per the 0.4-nozzle rule; no global high $fn

// Note 5. Body diameter of a 250 ml / 8.3 oz slim can (mm). Red Bull's sleek can, and
// the number slim-can-holder-8-3oz.scad is cut to.

// Note 6. Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.

// Note 7. Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
// Settled 2026-08-22 on the 250 ml holder's fit coupon and carried here
// unchanged, as the ring carries it. ⚠️ Do NOT "correct" this to the measured
// 0.23: it and rib_h are a matched pair.

// Note 8. Read off parts/slim-can-holder-3in-12oz-fish.scad and its built mesh. Change them only
// if the fish changes; nothing here is a choice.
// The fish's bore as drawn (mm): can 57.40 + slop 0.40 + comp 0.60.

// Note 9. What this machine takes out of a bore that size (mm on diameter), measured
// on the Ø54 bore and carried by the holders' own argument that the loss is
// absolute, not proportional.

// Note 10. How far the fish's grip ribs stand into its bore (mm).

// Note 11. Top of the fish's floor (mm above its bed): floor_t. The sleeve stands on it.

// Note 12. Top of the fish's bore (mm), where the lead-in starts opening: bore_top.

// Note 13. The lowest point of the mouth's rim at the bore (mm above the fish's bed):
// the corner of the mouth at 180–210 degrees, measured on the built mesh.
// The sleeve's rim stands proud of this.

// Note 14. Drain through the fish's floor (mm), on the axis. The sleeve's bottom ring
// has to clear it.

// Note 15. Wall between the can and the fish (mm). 1.68 is 4 walls at 0.42; see THE
// WALL IS ONE RUNG in the header.

// Note 16. How far the rim stands above the lowest corner of the fish's mouth (mm).
// Negative puts it below, out of sight: -1 is a millimetre of margin under
// the corner, and still 2.3 above the top of the bore.

// Note 17. 45-degree chamfer on the outside of the bottom edge (mm). On the bed, so
// it is the elephant-foot chamfer — the reference's PETG minimum — and the
// lead-in past the fish's ribs on the way down.

// Note 18. 45-degree chamfer on the outside of the rim (mm). Narrows going up.

// Note 19. Lead-in at the mouth, for the can (mm): how far out on radius, and over
// what height. Small, because the wall has 1.68 to share between this and
// the rim chamfer and the rim still has to have a top.

// Note 20. Rounded vertical ribs in the bore. The 250 ml holder's six, unchanged.

// Note 21. how far each rib stands into the bore (mm)

// Note 22. chord width of the bump (mm)

// Note 23. lead-in at the top, over which the rib fades to nothing (mm)

// Note 24. the same at the bottom, where the printer sees it as an overhang (mm)

// Note 25. Height of the coupon (mm): the bottom of the sleeve, base chamfer and rib
// feet included, printed the same way up as the sleeve. 20 is the 2 mm foot
// and 16.5 mm of full-proud rib.

// Note 26. Chord error target (mm). 0.02 is the 0.4-nozzle figure.

// Note 27. Facets for a target chord error on a given radius.

// Note 28. Radius that makes the INSCRIBED polygon's inner radius equal r.

// Note 29. the rim, on the fish's scale

// Note 30. floor to rim

// Note 31. What the sleeve faces in the fish, printed, and what it leaves.

// Note 32. Solid section, before the bore is cut. Bottom inner corner first, running
// counter-clockwise: bottom, base chamfer, outside, rim chamfer, top, mouth
// lead-in, bore.

// Note 33. Half a pitch off the x axis, so the cut view at y = 0 shows the bore
// and not a rib edge-on.

// Note 34. Each rib is a 3.90 mm arc of which 0.30 is wanted, so left alone it would
// poke out through a 1.68 mm wall. It is clipped to a cylinder inside the
// sleeve's outer face before it goes in — inside, not at it, so no face of
// the clip is coincident with the sleeve.

// Note 35. The fit coupon: the bottom coupon_h of the sleeve, as it is.

// Note 36. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
