// Adapter ring — drops into the 3 inch 12 oz slim can holders and holds a
// 250 ml / 8.3 oz slim can instead.
//
// A sleeve with a lip. It goes into the bore of slim-can-holder-3in-12oz-*
// (the Wagon Queen one, and the middle-finger one, which share a bore) the
// way a 12 oz can does — past the same six grip ribs, down onto the same
// floor — and its own bore is the 250 ml can's, lifted whole from
// slim-can-holder-8-3oz.scad. The can drops in through the lip, sits on the
// holder's floor through the ring's open bottom, and is gripped by six ribs
// inside the ring. The ring is gripped by the holder's six ribs. Nothing is
// glued and nothing is tuned: both fits are ones this machine has already
// printed and Ziad has already pushed a can into.
//
// THE OUTSIDE IS A 12 OZ CAN. The holder's bore is drawn 58.40, prints 58.17
// (measured loss on a bore this size, see bore_comp in the holder), and its
// ribs stand 0.30 proud, so the ring's outside faces 57.57 across the ribs.
// A real 12 oz can is 57.40 and Ziad called that "snug, not difficult". The
// ring is drawn 57.36 — one wall ladder rung, 4 x 0.42, outside the bore —
// which is 0.21 across the ribs if the outside prints on size. An outside
// has no pull-in to lose and no floor to squish (the lip is on the bed, not
// the sleeve), so on size is the expectation; if it prints fat, sand the
// outside rather than reprint, exactly as the holders say of their ribs.
//
// THE INSIDE IS THE 250 ML HOLDER'S BORE. Ø54.00 drawn with six 0.30 ribs, the
// pair settled by the 2026-08-22 coupon: printed 53.77, 53.17 across the ribs,
// can in "fits perfectly, snug enough but not difficult". Every number in
// [Can] and [Grip ribs] is that part's number and none of them is a decision
// made here.
//
// THE WALL IS ONE RUNG. Between a Ø54.00 bore and a Ø57.36 outside there is
// 1.68 mm, four walls at 0.42, and it is all the wall there is room for: five
// walls would put the outside at 58.20, fatter than the ribs it has to pass.
// It is not a structural part — the holder carries it — and PETG at 1.68 over
// 94 mm is a tube, not a membrane.
//
// THE LIP IS THE HOLDER'S WHOLE TOP. Ø76.20, the barrel's own 3 inches, with
// the barrel's own 1.00 chamfer on its edge, so seated it reads as the rim
// of the holder rather than a washer sitting on it (Ziad, 2026-09-19: it
// should cover the existing top edge). It covers the mouth lead-in — 1.20 on
// radius over 2.00 of height, which a flush sleeve would leave showing as a
// 1.7 mm ring of air — and the top chamfer, and bears on all 6.70 mm of the
// rim's flat between them. The holder's chamfer under the lip's flat
// underside leaves a 1 mm V reveal round the joint, which is the seam
// declared rather than hidden. It also sets the ring's depth off the rim
// instead of off the floor — the sleeve hangs 0.60 clear of the floor and
// never has to be the exact depth — and it is what you get a fingernail
// under to lift the ring out. The flutes run off the holder's top chamfer,
// so under the lip's edge are twenty-four 0.8 mm crescents of air; nothing
// bears there and nothing shows.
//
// ORIENTATION. Drawn as used, z = 0 at the open bottom, lip at the top.
// PRINTED LIP-DOWN — flip = true, the default, turns it over — and that
// orientation has no overhang anywhere: the lip is a disc on the bed, the
// sleeve steps in from it, the mouth lead-in and the rib ramps both narrow
// going up, and the bottom chamfer and the rib feet do the same at the top of
// the print. Printed the other way up the lip is a 3.3 mm cantilever with
// nothing under it. The lip's outward face takes the plate texture; it is
// the face you see, and a matte ring on a matte holder is fine.
//
// ⚠️ THE ONE THING NOT PROVEN is how an OUTSIDE diameter prints on this
// machine. Every measured figure in the repo is a bore. Print [Fit coupon]
// first: it is the lip and the top 17.7 mm of the sleeve, and it tests the
// ring in the holder and a can in the ring at the same time.

// The coupon is the only thing here a plate can answer, and there is one
// variant for it, so the plate and the component are the same. Keep the
// names stable — utils/coupon.sh reads these and knows nothing about the part.
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// "cut" is a half-section for reading the wall, the lip and the ribs. Not for
// printing — build it with --name if you want it as its own STL.
// "coupon" is the fit test; see [Fit coupon].
show = "part";   // [part, cut, coupon]
// Printed orientation, lip on the bed. false draws it the way it sits in the
// holder, lip up.
flip = true;

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a 250 ml / 8.3 oz slim can (mm). Red Bull's sleek can, and
// the number slim-can-holder-8-3oz.scad is cut to.
can_d = 53.0;
// Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.
can_slop = 0.40;
// Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
//
// SETTLED, 2026-08-22, on the 250 ml holder's fit coupon: a bore drawn at
// 54.00 miked 53.77 between the ribs. Carried here unchanged, and it is the
// same bore, in the same material, at the same size.
//
// ⚠️ Do NOT "correct" this number to the measured 0.23. 0.60 is what produced a
// bore that fits, and the ribs were sized against it. The two are a matched
// pair; changing one without the other opens the fit back up.
bore_comp = 0.60;

/* [Host — the holder this drops into] */

// These are read off parts/slim-can-holder-3in-12oz-wagon-queen.scad and its
// middle-finger sibling, which share every one of them. Change them only if
// the holder changes; nothing here is a choice.

// The holder's bore as drawn (mm): can 57.40 + slop 0.40 + comp 0.60.
host_bore_d = 58.40;
// What this machine takes out of a bore that size (mm on diameter). Measured
// 2026-08-22 on the Ø54 bore and carried to the Ø58.40 one by the holder's
// own argument: the loss is constant in absolute terms, not proportional.
host_bore_loss = 0.23;
// How far the holder's grip ribs stand into its bore (mm).
host_rib_h = 0.30;
// Depth of the holder's bore, rim to floor (mm): total_h 100 - floor_t 5.40.
host_depth = 94.60;
// The holder's mouth lead-in, on radius (mm)...
host_mouth_r = 1.20;
// ...and the rim's flat runs from the top of that lead-in out to the start of
// the holder's top chamfer, at this radius (mm): out_r 38.10 - top_cham 1.00.
host_rim_flat_r = 37.10;
// The holder's outside (mm), 3 inches, and the size of its top chamfer (mm).
// The lip copies both.
host_od = 76.20;
host_top_cham = 1.00;

/* [Sleeve] */

// Wall between the can and the holder (mm). 1.68 is 4 walls at 0.42, and it is
// the only rung that fits: see THE WALL IS ONE RUNG in the header.
wall_w = 1.68;
// Gap left between the bottom of the sleeve and the holder's floor when the
// lip is seated on the rim (mm). The lip sets the depth, not the floor, so
// this only has to be more than zero.
under_gap = 0.60;
// 45-degree chamfer on the outside of the bottom edge (mm). A lead-in past the
// holder's ribs, and the top of the print, so no elephant foot to fight.
base_cham = 0.60;

/* [Lip] */

// Outside diameter of the lip (mm). The holder's own, so the lip covers the
// rim and its chamfer edge-to-edge and is flush with the barrel. It has to
// reach past the top of the holder's lead-in (r 30.40) to bear on the rim's
// flat at all; anything between that and 76.20 is a washer on the rim
// rather than a rim.
lip_od = host_od;
// Lip thickness (mm). It is the base of the print, and 2.30 is exactly the
// layer stack — a 0.30 first layer and ten at 0.20 — so the sleeve starts on
// a layer boundary.
lip_t = 2.30;
// 45-degree chamfer on the lip's outward edge (mm). The holder's own top
// chamfer, so the profile carries on up the barrel. That edge is also on the
// bed, and the chamfer is what stands in for the slicer's elephant-foot
// compensation, per the fit rules — 1.00 is twice what that needs.
lip_cham = host_top_cham;

/* [Mouth] */

// Lead-in at the mouth of the bore: how far it opens on radius (mm)...
mouth_cham_r = 1.20;
// ...over how much height (mm). Lets the can be dropped in without being
// aimed. In print it narrows going up, so it costs nothing.
mouth_cham_h = 2.00;

/* [Grip ribs] */

// Six rounded vertical ribs inside the bore, the 250 ml holder's ribs to the
// number. Two sit across any diameter, so the working size is
// (printed bore) - 2 x rib_h = 53.77 - 0.60 = 53.17 on a Ø53.0 can, which is
// the 0.17 Ziad printed and called snug. Go to 0.40 only if the can measures
// under Ø53, and sand rather than reprint.
rib_count = 6;
// How far each rib stands into the bore (mm).
rib_h = 0.30;
// Chord width of the bump (mm). Sets the bearing area; its radius is derived
// so the arc is exactly this wide at exactly rib_h proud.
rib_w = 3.00;
// Lead-in at the mouth end, over which the rib fades to nothing (mm). This
// is what makes insertion progressive instead of a step.
rib_ramp = 8.0;
// Foot at the bottom end, same idea (mm).
rib_foot = 2.0;

/* [Fit coupon] */

// The lip and the top of the sleeve, cut off and printed the same way up as
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
coupon_h = 20.00;

/* [Colors] */

// Preview only. STLs carry no colour.
ring_color = "Coral";

/* [Quality] */

// Chord error target (mm). 0.02 is the 0.4-nozzle figure.
chord_err = 0.02;

/* [Hidden] */

// Facets for a target chord error on a given radius.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Radius that makes the INSCRIBED polygon's inner radius equal r.
function r_hole(r, n) = r / cos(180 / n);

bore_d    = can_d + can_slop + bore_comp;
bore_r    = bore_d / 2;
sleeve_od = bore_d + 2 * wall_w;
sleeve_r  = sleeve_od / 2;
lip_r     = lip_od / 2;

sleeve_h  = host_depth - under_gap;      // open bottom to the lip's underside
total_h   = sleeve_h + lip_t;

nseg      = facets(lip_r);
r_bore    = r_hole(bore_r, nseg);

// What the ring faces in the holder, printed, and what it leaves.
host_across_ribs = host_bore_d - host_bore_loss - 2 * host_rib_h;
host_clear       = host_across_ribs - sleeve_od;
host_lead_in_r   = host_bore_d / 2 + host_mouth_r;   // top of the holder's lead-in

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

// Solid section, before the bore is cut. Bottom inner corner first, running
// counter-clockwise: bottom, base chamfer, sleeve, lip underside, lip, lip
// chamfer, top, mouth lead-in, bore.
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
        // Half a pitch off the x axis, so the cut view at y = 0 shows the bore
        // and not a rib edge-on.
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

// Each rib is a 3.90 mm arc of which 0.30 is wanted, so left alone it would
// poke out through a 1.68 mm wall. It is clipped to a cylinder inside the
// sleeve's outer face before it goes in — inside, not at it, so no face of
// the clip is coincident with the sleeve.
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

// The fit coupon: the top coupon_h of the part. It is cut in the as-used
// frame and then flipped like the part, so the lip is on the bed either way.
module fit_coupon() {
    z0 = total_h - coupon_h;
    translate([0, 0, -z0])
        intersection() {
            adapter_ring();
            translate([-lip_od, -lip_od, z0])
                cube([2 * lip_od, 2 * lip_od, coupon_h + eps]);
        }
}

// Entry points for can-holder-12oz-standard-set.scad, which `use`s this file.
// Unique names, because every ring in the set defines adapter_ring(). Drawn as
// used, lip up, z = 0 at the open bottom.
module ring_to_8_3oz() adapter_ring();
function ring_to_8_3oz_h()       = total_h;
function ring_to_8_3oz_sleeve_h() = sleeve_h;

// Printed orientation: lip on the bed. A rotate, not a mirror, so the ribs
// keep their handedness (not that it matters on a symmetric part).
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
