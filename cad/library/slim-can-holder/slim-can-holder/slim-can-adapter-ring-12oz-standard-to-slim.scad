// Note 1.

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

show = "part";   // [part, cut, coupon]
// Note 4.

flip = true;

$fa = 4;   // Note 5.
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Note 6.

can_d = 57.40;
// Note 7.

can_slop = 0.40;
// Note 8.

bore_comp = 0.60;

/* [Host — the holder this drops into] */

// Note 9.

host_bore_d = 67.04;
// Note 10.

host_bore_loss = 0.23;
// Note 11.
host_rib_h = 0.30;
// Note 12.
host_depth = 94.60;
// Note 13.
host_mouth_r = 1.20;
// Note 14.

host_rim_flat_r = 41.42;
// Note 15.

host_od = 84.84;
host_top_cham = 1.00;

/* [Sleeve] */

// Note 16.

wall_w = 3.78;
// Note 17.

under_gap = 0.60;
// Note 18.

base_cham = 0.60;

/* [Lip] */

// Note 19.

lip_od = host_od;
// Note 20.

lip_t = 2.30;
// Note 21.

lip_cham = host_top_cham;

/* [Mouth] */

// Note 22.
mouth_cham_r = 1.20;
// Note 23.

mouth_cham_h = 2.00;

/* [Grip ribs] */

// Note 24.

rib_count = 6;
// Note 25.
rib_h = 0.30;
// Note 26.

rib_w = 3.00;
// Note 27.

rib_ramp = 8.0;
// Note 28.
rib_foot = 2.0;

/* [Fit coupon] */

// Note 29.

coupon_h = 20.00;

/* [Colors] */

// Note 30.
ring_color = "#90A553";

/* [Quality] */

// Note 31.
chord_err = 0.02;

/* [Hidden] */

// Note 32.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Note 33.
function r_hole(r, n) = r / cos(180 / n);

bore_d    = can_d + can_slop + bore_comp;
bore_r    = bore_d / 2;
sleeve_od = bore_d + 2 * wall_w;
sleeve_r  = sleeve_od / 2;
lip_r     = lip_od / 2;

sleeve_h  = host_depth - under_gap;      // Note 34.
total_h   = sleeve_h + lip_t;

nseg      = facets(lip_r);
r_bore    = r_hole(bore_r, nseg);

// Note 35.
host_across_ribs = host_bore_d - host_bore_loss - 2 * host_rib_h;
host_clear       = host_across_ribs - sleeve_od;
host_lead_in_r   = host_bore_d / 2 + host_mouth_r;   // Note 36.

rib_r    = rib_h > 0 ? (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h) : 0;
rib_ax   = bore_r + rib_r - rib_h;
rib_z0   = base_cham + 1.0;
rib_z1   = total_h - mouth_cham_h - 1.0;

assert(sleeve_od < host_bore_d - 2 * host_rib_h,
       str("the sleeve is fatter than the holder's ribs will pass: ",
           sleeve_od, " against ", host_bore_d - 2 * host_rib_h));
assert(wall_w >= 1.26,
       "the wall is under 3 lines at 0.42: raise wall_w");
assert(lip_r > host_lead_in_r + 1.0,
       str("the lip does not reach the rim's flat: it needs r > ",
           host_lead_in_r + 1.0, " to land a millimetre of it"));
assert(lip_r <= host_od / 2,
       "the lip is wider than the holder: reduce lip_od");
assert(lip_cham < lip_t,
       "the lip's chamfer is taller than the lip");
assert(under_gap > 0,
       "the sleeve would bottom on the holder's floor before the lip seats");
assert(bore_r + mouth_cham_r < lip_r - lip_cham,
       "the mouth lead-in has run into the lip's chamfer");
assert(rib_z1 - rib_ramp > rib_z0 + rib_foot,
       "the rib ramp and foot overlap: the sleeve is too short for them");
assert(coupon_h > lip_t + mouth_cham_h + 1.0 + rib_ramp,
       "the coupon is too short to reach full-proud rib");

// Note 37.

module ring_solid() {
    pts = [
        [r_bore,                 0],
        [sleeve_r - base_cham,   0],
        [sleeve_r,               base_cham],
        [sleeve_r,               sleeve_h],
        [lip_r,                  sleeve_h],
        [lip_r,                  total_h - lip_cham],
        [lip_r - lip_cham,       total_h],
        [r_bore + mouth_cham_r,  total_h],
        [r_bore,                 total_h - mouth_cham_h]
    ];
    rotate_extrude(angle = 360, $fn = nseg) polygon(pts);
}

module ribs() {
    n = facets(rib_r);
    for (i = [0 : rib_count - 1])
        // Note 38.

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

// Note 39.

module adapter_ring() {
    color(ring_color) union() {
        ring_solid();
        if (rib_count > 0 && rib_h > 0)
            intersection() {
                ribs();
                cylinder(r = sleeve_r - 0.20, h = sleeve_h, $fn = nseg);
            }
    }
}

// Note 40.

module fit_coupon() {
    z0 = total_h - coupon_h;
    translate([0, 0, -z0])
        intersection() {
            adapter_ring();
            translate([-lip_od, -lip_od, z0])
                cube([2 * lip_od, 2 * lip_od, coupon_h + eps]);
        }
}

// Note 41.

module ring_standard_to_slim() adapter_ring();
function ring_standard_to_slim_h()       = total_h;
function ring_standard_to_slim_sleeve_h() = sleeve_h;

// Note 42.

module oriented(h) {
    if (flip) translate([0, 0, h]) rotate([180, 0, 0]) children();
    else children();
}

echo(str("ring: outside ", sleeve_od, "  bore ", bore_d,
         "  across ribs ", bore_d - 2 * rib_h,
         "  wall ", wall_w, "  sleeve ", sleeve_h, " under a ", lip_t,
         " lip  (", total_h, " overall)  lip ", lip_od));
echo(str("in the holder: faces ", host_across_ribs,
         " across its printed ribs, clearance ", host_clear,
         " on diameter; lip bears on ",
         min(lip_r, host_rim_flat_r) - host_lead_in_r,
         " mm of rim and stands ", lip_r - host_od / 2,
         " proud of the barrel; bottom hangs ", under_gap, " off the floor"));
echo(str("on the can: printed bore ", bore_d - host_bore_loss,
         ", across ribs ", bore_d - host_bore_loss - 2 * rib_h,
         ", clearance ", bore_d - host_bore_loss - 2 * rib_h - can_d,
         " on a ", can_d, " can"));

// Note 43.

module feral_default_output_bf0e541f5996() {
if (show == "coupon")
    oriented(coupon_h) fit_coupon();
else if (show == "cut")
    difference() {
        adapter_ring();
        translate([-lip_od, -lip_od, -eps])
            cube([2 * lip_od, lip_od, total_h + 1]);
    }
else
    oriented(total_h) adapter_ring();
}

module feral_assembly_view_bf0e541f5996(explode=false) {
feral_default_output_bf0e541f5996();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_bf0e541f5996();
else feral_assembly_view_bf0e541f5996(view == "exploded");

// Notes

// Note 1. Adapter ring — drops into can-holder-12oz-standard.scad and
// holds a 355 ml / 12 oz SLIM can instead of a standard one.
//
// A copy of slim-can-adapter-ring-12oz-to-8-3oz.scad with the numbers moved
// one can up, and meant to stay a copy: a sleeve with a lip, gripped by the
// holder's six ribs on the outside, gripping the can with six of its own on
// the inside. The can drops in through the lip and sits on the holder's floor
// through the ring's open bottom. Every fit in it is one the repo has already
// drawn; nothing here is a new tolerance.
//
// THE OUTSIDE IS A STANDARD 12 OZ CAN. The holder's bore is drawn 67.04,
// prints 66.81 (the same constant 0.23 loss), and its ribs stand 0.30 proud,
// so the ring faces 66.21 across the ribs. A standard can is 66.04. The
// sleeve is drawn 65.96 — bore plus nine lines at 0.42 — which is 0.25 across
// the ribs if the outside prints on size, against the 0.21 the 8.3 oz ring
// was drawn to.
//
// THE INSIDE IS THE 3 IN SLIM 12 OZ HOLDER'S BORE. Ø58.40 drawn with six 0.30
// ribs: slim-can-holder-3in-12oz-wagon-queen.scad's bore to the number, so
// 57.57 across the ribs on a 57.40 can. That bore is itself inherited from
// the 250 ml coupon of 2026-08-22, not separately confirmed.
//
// THE WALL IS 3.78, nine lines at 0.42. The gap between the cans is 4.32 on
// radius and the bores eat 0.50 of it; there is no room for a cavity and no
// reason for one in a part the holder carries.
//
// THE LIP IS THE HOLDER'S WHOLE TOP. Ø84.84 with the holder's 1.00 chamfer,
// bearing on the rim's flat from the top of the holder's mouth lead-in
// (r 34.72) out to the start of its top chamfer (r 41.42) — the same
// arrangement as the 8.3 oz ring, see its header for why.
//
// ORIENTATION. Drawn as used, lip at the top. PRINTED LIP-DOWN — flip = true
// turns it over — which has no overhang anywhere.
//
// ⚠️ THE ONE THING NOT PROVEN is how an OUTSIDE diameter prints on this
// machine. Print [Fit coupon] first: the lip and the top of the sleeve, which
// tests the ring in the holder and a can in the ring at the same time.
// The coupon is the only thing here a plate can answer, and there is one
// variant for it, so the plate and the component are the same. Keep the
// names stable — utils/coupon.sh reads these and knows nothing about the part.

// Note 2. "cut" is a half-section for reading the wall, the lip and the ribs. Not for
// printing — build it with --name if you want it as its own STL.
// "coupon" is the fit test; see [Fit coupon].

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. Printed orientation, lip on the bed. false draws it the way it sits in the
// holder, lip up.

// Note 5. organic faceting per the 0.4-nozzle rule; no global high $fn

// Note 6. Body diameter of a 355 ml / 12 oz slim (sleek) can (mm). The number
// slim-can-holder-3in-12oz-wagon-queen.scad is cut to; see its header for
// where 57.40 comes from.

// Note 7. Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.

// Note 8. Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
//
// SETTLED, 2026-08-22, on the 250 ml holder's fit coupon: a bore drawn at
// 54.00 miked 53.77 between the ribs. Carried here unchanged, as the 3 in
// slim 12 oz holder carries it to this same Ø58.40.
//
// ⚠️ Do NOT "correct" this number to the measured 0.23. 0.60 is what produced a
// bore that fits, and the ribs were sized against it. The two are a matched
// pair; changing one without the other opens the fit back up.

// Note 9. These are read off can-holder-12oz-standard.scad. Change them
// only if the holder changes; nothing here is a choice.
// The holder's bore as drawn (mm): can 66.04 + slop 0.40 + comp 0.60.

// Note 10. What this machine takes out of a bore that size (mm on diameter). Measured
// 2026-08-22 on the Ø54 bore and carried to the Ø67.04 one by the holder's
// own argument: the loss is constant in absolute terms, not proportional.

// Note 11. How far the holder's grip ribs stand into its bore (mm).

// Note 12. Depth of the holder's bore, rim to floor (mm): total_h 100 - floor_t 5.40.

// Note 13. The holder's mouth lead-in, on radius (mm)...

// Note 14. ...and the rim's flat runs from the top of that lead-in out to the start of
// the holder's top chamfer, at this radius (mm): out_r 42.42 - top_cham 1.00.

// Note 15. The holder's outside (mm), and the size of its top chamfer (mm). The lip
// copies both.

// Note 16. Wall between the can and the holder (mm). 3.78 is 9 walls at 0.42; ten
// would put the outside at 66.80, fatter than the holder's ribs will pass.

// Note 17. Gap left between the bottom of the sleeve and the holder's floor when the
// lip is seated on the rim (mm). The lip sets the depth, not the floor, so
// this only has to be more than zero.

// Note 18. 45-degree chamfer on the outside of the bottom edge (mm). A lead-in past the
// holder's ribs, and the top of the print, so no elephant foot to fight.

// Note 19. Outside diameter of the lip (mm). The holder's own, so the lip covers the
// rim and its chamfer edge-to-edge and is flush with the barrel. It has to
// reach past the top of the holder's lead-in (r 34.72) to bear on the rim's
// flat at all; anything between that and 84.84 is a washer on the rim
// rather than a rim.

// Note 20. Lip thickness (mm). It is the base of the print, and 2.30 is exactly the
// layer stack — a 0.30 first layer and ten at 0.20 — so the sleeve starts on
// a layer boundary.

// Note 21. 45-degree chamfer on the lip's outward edge (mm). The holder's own top
// chamfer, so the profile carries on up the barrel. That edge is also on the
// bed, and the chamfer is what stands in for the slicer's elephant-foot
// compensation, per the fit rules — 1.00 is twice what that needs.

// Note 22. Lead-in at the mouth of the bore: how far it opens on radius (mm)...

// Note 23. ...over how much height (mm). Lets the can be dropped in without being
// aimed. In print it narrows going up, so it costs nothing.

// Note 24. Six rounded vertical ribs inside the bore, the slim 12 oz holder's ribs to
// the number. Two sit across any diameter, so the working size is
// (printed bore) - 2 x rib_h = 58.17 - 0.60 = 57.57 on a Ø57.40 can, the same
// 0.17 Ziad printed on the 250 ml coupon and called snug. Go to 0.40 only if
// the can measures under Ø57.4, and sand rather than reprint.

// Note 25. How far each rib stands into the bore (mm).

// Note 26. Chord width of the bump (mm). Sets the bearing area; its radius is derived
// so the arc is exactly this wide at exactly rib_h proud.

// Note 27. Lead-in at the mouth end, over which the rib fades to nothing (mm). This
// is what makes insertion progressive instead of a step.

// Note 28. Foot at the bottom end, same idea (mm).

// Note 29. The lip and the top of the sleeve, cut off and printed the same way up as
// the part, so it can be dropped into the holder and a can dropped into it
// before committing to the full height.
//
// It answers two questions at once. Outside: the holder's ribs are at full
// height from 11 mm below its rim downward (2.00 of lead-in, 1.00 clear,
// 8.00 of ramp), so a coupon this tall puts 6.7 mm of sleeve against them.
// Inside: same arithmetic on the ring's own ribs, 2.00 + 1.00 + 8.00 from
// the top, so the can meets 6.7 mm of full-proud rib.
//
// No relief cone at the cut face, unlike the holders' coupons: the cut face
// is the top of the print here, not the bed, and there is no elephant foot
// on it to fake a tight reading.

// Note 30. Preview only. STLs carry no colour.

// Note 31. Chord error target (mm). 0.02 is the 0.4-nozzle figure.

// Note 32. Facets for a target chord error on a given radius.

// Note 33. Radius that makes the INSCRIBED polygon's inner radius equal r.

// Note 34. open bottom to the lip's underside

// Note 35. What the ring faces in the holder, printed, and what it leaves.

// Note 36. top of the holder's lead-in

// Note 37. Solid section, before the bore is cut. Bottom inner corner first, running
// counter-clockwise: bottom, base chamfer, sleeve, lip underside, lip, lip
// chamfer, top, mouth lead-in, bore.

// Note 38. Half a pitch off the x axis, so the cut view at y = 0 shows the bore
// and not a rib edge-on.

// Note 39. Each rib is a 3.90 mm arc of which 0.30 is wanted, so left alone it would
// poke out through a 3.78 mm wall. It is clipped to a cylinder inside the
// sleeve's outer face before it goes in — inside, not at it, so no face of
// the clip is coincident with the sleeve.

// Note 40. The fit coupon: the top coupon_h of the part. It is cut in the as-used
// frame and then flipped like the part, so the lip is on the bed either way.

// Note 41. Entry points for can-holder-12oz-standard-set.scad, which `use`s this file.
// Unique names, because every ring in the set defines adapter_ring(). Drawn as
// used, lip up, z = 0 at the open bottom.

// Note 42. Printed orientation: lip on the bed. A rotate, not a mirror, so the ribs
// keep their handedness (not that it matters on a symmetric part).

// Note 43. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
