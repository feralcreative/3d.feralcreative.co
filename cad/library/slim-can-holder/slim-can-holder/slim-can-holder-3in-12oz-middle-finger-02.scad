// Note 1.

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

include <middle-finger-emboss.scad>
standalone = false;

/* [Output] */

// Note 4.

show = "part";   // [part, cut, coupon]

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

/* [Shell] */

// Note 9.

outer_d = 76.20;
// Note 10.

total_h = 100.0;
// Note 11.
inner_w = 2.10;
// Note 12.

outer_w = 2.40;
// Note 13.

roof_t = 1.60;

/* [Floor] */

// Note 14.

floor_t = 5.40;
// Note 15.

drain_d = 12.0;
// Note 16.

base_round = 5.00;

// Note 17.

base_over = 45;

// Note 18.

base_cham = 0.60;

/* [Mouth] */

// Note 19.

top_cham = 1.00;
// Note 20.
mouth_cham_r = 1.20;
// Note 21.

mouth_cham_h = 2.00;

/* [Flutes] */

// Note 22.

flute_count = 24;
// Note 23.

flute_depth = 0.80;
// Note 24.

flute_cut_r = 6.00;
// Note 25.

flute_clear = 0.50;

/* [Signs] */

// Note 26.

sign_count = 2;
// Note 27.

sign_pad = 3.00;

/* [Panel art] */

// Note 28.

art_w = 34.00;

// Note 29.

art_z = 46.0;

// Note 30.

art_relief = 4.00;

/* [Grip ribs] */

// Note 31.

rib_count = 6;
// Note 32.
rib_h = 0.30;
// Note 33.

rib_w = 3.00;
// Note 34.

rib_ramp = 8.0;
// Note 35.

rib_foot = 2.0;

/* [Webs] */

// Note 36.

web_count = 8;
// Note 37.
web_t = 1.35;

/* [Fit coupon] */

// Note 38.

coupon_h = 18.00;

// Note 39.

coupon_relief = 0.60;

/* [Quality] */

// Note 40.
chord_err = 0.02;

/* [Hidden] */

// Note 41.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Note 42.
function r_hole(r, n) = r / cos(180 / n);

bore_d   = can_d + can_slop + bore_comp;
bore_r   = bore_d / 2;
out_r    = outer_d / 2;

nseg     = facets(out_r);
r_bore   = r_hole(bore_r, nseg);
r_drain  = drain_d > 0 ? r_hole(drain_d / 2, nseg) : 0;

// Note 43.
cav_ri   = bore_r + inner_w;
cav_ro   = out_r - outer_w;
cav_z0   = floor_t;
cav_z1   = total_h - roof_t;

// Note 44.

base_cz     = base_round;
base_cr     = out_r - base_round;
base_tan_r  = base_cr + base_round * cos(base_over);
base_tan_z  = base_cz - base_round * sin(base_over);
base_foot_r = base_tan_r - base_tan_z * tan(base_over);
// Note 45.
base_top_z  = base_round > 0 ? base_round : base_cham;

// Note 46.

flute_off = out_r - flute_depth + flute_cut_r;
// Note 47.
flute_a   = (pow(flute_off, 2) + pow(out_r, 2) - pow(flute_cut_r, 2))
            / (2 * flute_off);
flute_hw  = sqrt(pow(out_r, 2) - pow(flute_a, 2));

// Note 48.

art_h = art_w * art_h_mm / art_w_mm;

// Note 49.

sign_w   = art_w + 2 * sign_pad;
sign_h   = art_h + 2 * sign_pad;
// Note 50.

flat_r   = sqrt(pow(out_r * cos(180 / nseg), 2) - pow(sign_w / 2, 2));
sign_sag = out_r - flat_r;
sign_z0  = art_z - sign_h / 2;
sign_z1  = art_z + sign_h / 2;
sign_t   = flat_r - r_bore;                  // Note 51.

sign_ang = asin((sign_w / 2) / out_r);
// Note 52.

sign_back_ang = asin(min(0.98, (sign_w / 2 + 1.0) / cav_ri));

// Note 53.

function flute_bite(t, clear) =
    let (cx = flute_off * cos(t),
         cy = flute_off * sin(t),
         d  = abs(cx - flat_r))
    d >= flute_cut_r ? false
    : let (h = sqrt(pow(flute_cut_r, 2) - pow(d, 2)))
      cy - h < sign_w / 2 + clear && cy + h > -(sign_w / 2 + clear);

// Note 54.
function flute_bites(i) = sign_count == 0 ? false :
    len([for (j = [0 : sign_count - 1])
         if (flute_bite(i * 360 / flute_count - j * 360 / sign_count,
                        flute_clear)) 1]) > 0;

kept_flutes = flute_count == 0 ? []
            : [for (i = [0 : flute_count - 1]) if (!flute_bites(i)) i];

// Note 55.
rib_r    = rib_h > 0 ? (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h) : 0;
rib_ax   = bore_r + rib_r - rib_h;
rib_z0   = floor_t + 1.0;
rib_z1   = total_h - mouth_cham_h - 1.0;

assert(floor_t >= 5.0,
       "the floor is the one hard requirement: keep floor_t at 5 mm or more");
assert(cav_ro - cav_ri >= 3.0,
       "the annular cavity has collapsed: the can is too big for a 3in double wall");
assert(flute_count == 0 || flute_depth <= 0 || outer_w - flute_depth >= 1.35,
       "the flutes cut the outer shell below 3 walls: reduce flute_depth");
assert(flute_count == 0 || flute_depth <= 0
       || flute_hw * flute_count < PI * outer_d,
       "the flutes overlap: reduce flute_count or flute_cut_r");
assert(bore_r + mouth_cham_r < out_r - top_cham,
       "the mouth chamfer has run into the top chamfer");
assert(base_round == 0 || base_round < total_h / 4,
       "the base round has swallowed the barrel: reduce base_round");
assert(base_round == 0 || base_foot_r > drain_d / 2 + 8,
       "the base round has eaten the floor out to the drain: reduce base_round");
assert(sign_count == 0 || sign_w < outer_d,
       "a plaque has to be cut IN: art_w + 2 x sign_pad must be under outer_d");
assert(sign_count == 0 || sign_t >= 2.10,
       "too little wall left behind the plaque: reduce art_w");
assert(sign_count < 2 || sign_ang * sign_count < 180 - 8,
       "the plaques have run into each other: reduce art_w or sign_count");
assert(sign_count < 2 || sign_back_ang * sign_count < 180 - 8,
       "the backing wedges have met: the cavity between the plaques is gone");
assert(sign_count == 0 || art_relief < sign_sag,
       "the artwork stands out past the barrel: reduce art_relief or raise art_w");
assert(sign_count == 0
       || (sign_z0 - sign_sag > base_top_z && sign_z1 + sign_sag < total_h - top_cham),
       "the plaque and its bevels have run off the end of the barrel");

// Note 56.

module holder_solid() {
    // Note 57.

    n = max(2, ceil(facets(base_round) * base_over / 360));
    base = base_round > 0
        ? concat(
            [[base_foot_r, 0]],
            [for (i = [0 : n]) let (a = -base_over * (n - i) / n)
                [base_cr + base_round * cos(a), base_cz + base_round * sin(a)]])
        : [[out_r - base_cham, 0], [out_r, base_cham]];
    pts = concat(
        drain_d > 0 ? [[r_drain, 0]] : [[0, 0]],
        base,
        [
            [out_r,                  total_h - top_cham],
            [out_r - top_cham,       total_h],
            [r_bore + mouth_cham_r,  total_h],
            [r_bore,                 total_h - mouth_cham_h],
            [r_bore,                 floor_t]
        ],
        drain_d > 0 ? [[r_drain, floor_t]] : []
    );
    rotate_extrude(angle = 360, $fn = nseg) polygon(pts);
}

// Note 58.
module cavity() {
    rotate_extrude(angle = 360, $fn = nseg)
        polygon([[cav_ri, cav_z0], [cav_ro, cav_z0],
                 [cav_ro, cav_z1], [cav_ri, cav_z1]]);
}

module webs() {
    // Note 59.

    for (i = [0 : web_count - 1])
        rotate([0, 0, (i + 0.5) * 360 / web_count])
            translate([0, -web_t / 2, 0])
                cube([out_r, web_t, total_h]);
}

// Note 60.

module flutes() {
    n = facets(flute_cut_r);
    for (i = kept_flutes)
        rotate([0, 0, i * 360 / flute_count])
            translate([flute_off, 0, -eps])
                cylinder(r = flute_cut_r, h = total_h + 2 * eps, $fn = n);
}

// Note 61.

module sign_pockets() {
    big = 4 * outer_d;
    pts = [
        [out_r,  sign_z0 - sign_sag],
        [big,    sign_z0 - sign_sag],
        [big,    sign_z1 + sign_sag],
        [out_r,  sign_z1 + sign_sag],
        [flat_r, sign_z1],
        [flat_r, sign_z0]
    ];
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            translate([0, big / 2, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = big) polygon(pts);
}

// Note 62.

module sign_backing() {
    big = 4 * outer_d;
    n   = ceil(2 * sign_back_ang / 4);
    wedge = concat([[0, 0]],
        [for (k = [0 : n]) let (t = -sign_back_ang + 2 * sign_back_ang * k / n)
            [big * cos(t), big * sin(t)]]);
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            translate([0, 0, sign_z0 - sign_sag - 1.0])
                linear_extrude(height = sign_h + 2 * sign_sag + 2.0)
                    polygon(wedge);
}

// Note 63.

module finger_marks() {
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            translate([flat_r - eps, 0, art_z])
                rotate([0, 0, -90])
                    finger_mark(art_w, art_relief);
}

module ribs() {
    n = facets(rib_r);
    for (i = [0 : rib_count - 1])
        // Note 64.

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

module holder_body() {
    // Note 65.

    difference() {
        union() {
            holder_solid();
            if (rib_count > 0 && rib_h > 0) ribs();
        }
        // Note 66.

        difference() {
            cavity();
            webs();
            if (sign_count > 0) sign_backing();
        }
        if (flute_count > 0 && flute_depth > 0) flutes();
        if (sign_count > 0) sign_pockets();
    }
}

module slim_can_holder() {
    union() {
        holder_body();
        // Note 67.

        if (sign_count > 0 && art_relief > 0) finger_marks();
    }
}

echo(str("outside ", outer_d, "  bore ", bore_d,
         "  across ribs ", bore_d - 2 * rib_h,
         "  floor ", floor_t, "  height ", total_h,
         "  cavity ", cav_ro - cav_ri, " wide",
         "  flute ", 2 * flute_hw, " across on ",
         PI * outer_d / flute_count, " pitch  (",
         len(kept_flutes), " of ", flute_count,
         " kept; the rest would have bitten a plaque)"));
echo(str("plaque ", sign_w, " x ", sign_h,
         "  deep ", sign_sag, " (= bevel height)  wall behind ", sign_t,
         "  z ", sign_z0, "..", sign_z1,
         "  overall with bevels ", sign_h + 2 * sign_sag));
echo(str("artwork ", art_w, " x ", art_h, " standing ", art_relief,
         " proud, against ", sign_sag, " of room"));

// Note 68.

module fit_coupon() {
    z0 = total_h - coupon_h;
    c  = coupon_relief + rib_h;          // Note 69.
    assert(sign_count == 0 || z0 > sign_z1 + sign_sag,
           str("coupon_h reaches into the plaque at z ", sign_z1 + sign_sag,
               " — shorten it, or the coupon is not a plain barrel section"));
    difference() {
        translate([0, 0, -z0])
            intersection() {
                slim_can_holder();
                translate([-outer_d, -outer_d, z0])
                    cube([2 * outer_d, 2 * outer_d, coupon_h + eps]);
            }
        translate([0, 0, -eps])
            cylinder(h = c + eps, r1 = bore_r + coupon_relief + eps,
                     r2 = bore_r + coupon_relief - c, $fn = nseg);
    }
}

// Note 70.

module feral_default_output_639aa011895c() {
if (show == "coupon")
    fit_coupon();
else if (show == "cut")
    difference() {
        slim_can_holder();
        translate([-outer_d, -outer_d, -eps])
            cube([2 * outer_d, outer_d, total_h + 1]);
    }
else
    slim_can_holder();
}

module feral_assembly_view_639aa011895c(explode=false) {
feral_default_output_639aa011895c();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_639aa011895c();
else feral_assembly_view_639aa011895c(view == "exploded");

// Notes

// Note 1. Slim can holder — 3 inch outside, 355 ml / 12 oz sleek can inside.
//
// A copy of slim-can-holder-3in.scad rebored for the bigger can, and it is
// meant to stay a copy. Everything that differs from that file differs because
// 4.40 mm went onto the bore diameter; nothing else was touched, so a diff
// between the two is exactly the list of things the can forced. The outside is
// still 76.20 mm, exactly 3", and the two sit next to each other as a pair.
//
// THE CAN. Ø57.40 x 155.6 — the standard sleek 355 ml body, which is one size
// up the same family as the 250 ml slim can the sibling holds. Three
// independent sources agree, and they are not the ones a search puts first:
//
// Ball's own 12 oz sleek, via a co-packer spec:   Ø2.259" = 57.38
// Alucan sleek-family chart, 355 ml row:          Ø57.40 x 155.73
// Amazon's 4-pack footprint, 4.56" across two:    Ø57.9 including the wrap
//
// ⚠️ 58 mm is the OTHER number this can is published under — it is on Crown's
// own CrownSleek page — and it is not the body. It is the 204.5 can code,
// 2.28125", which is the flange the end is seamed to; the body is necked in
// from it. The same distinction puts a standard 12 oz can at a 211 code with a
// 66.04 body. Design to 57.40: the can goes in body-first.
//
// ⚠️ Ziad's reference image was NOT used. It gave the tall 12 oz as 2.13 in,
// but its own other rows do not survive a volume check — at the sizes it
// prints, its 16 oz can is 449 cm3 of gross cylinder holding 473 ml of drink
// and its 20 oz is 554 holding 591. Both are impossible, so none of it was
// trusted.
//
// THE PROBLEM THE FIXED OUTSIDE CREATES. 76.20 outside against 57.40 inside is
// 9.40 mm of radius to fill. Drawn as a solid that is about 190 cm3 of wall for
// the slicer to pack, which is a long print and a heavy part for no gain. So it
// is drawn the same way slim-can-adapter.scad is: an inner tube around the can,
// an outer cylinder at the finished size, a sealed annular cavity between them,
// and radial webs tying the two together. The dead air in that gap is what
// makes it a koozie rather than a lump. That cavity is 4.40 mm wide here rather
// than 6.60 — still dead air, and the roof over it is now an easier bridge
// rather than a harder one.
//
// THE OUTSIDE. Twenty-four shallow vertical flutes, cut into the 76.20 circle
// rather than added to it, so the maximum diameter stays exactly 3". They earn
// their place three ways: grip on a wet hand, they hide layer lines on a plain
// cylinder, and every one of them is a vertical cut that costs no support.
// Set flute_count or flute_depth to 0 for a plain barrel.
//
// THE SIGNS. Two of them, 180 degrees apart: a bounded flat plaque milled into
// the barrel, not a flat side. Each is exactly the artwork plus 3 mm of padding
// all round — 40.00 wide by about 53.8 tall — and nothing more, so the barrel
// above and below it is still round and still fluted.
//
// WHY THE PLAQUE IS 5.67 DEEP, AND WHY IT HAS A BEVEL. Those two numbers are
// not choices, they are the barrel's radius. A 40.00 mm chord on a Ø76.20
// circle has a sagitta of 5.67 mm, so a flat that wide is 5.67 mm below the
// surface at its centre whatever else is done — and the plaque's ceiling is
// then a 5.67 mm shelf hanging over open air with nothing under its outer
// edge, which is not a bridge (two anchors) but a cantilever (one), and it
// would droop. Relieving it at 45 degrees fixes that, and a 45-degree relief
// across 5.67 mm of depth costs exactly 5.67 mm of height. So the plaque reads
// as a flat panel with a bevelled frame above and below, and the frame is that
// tall because the printer says so. Widen the artwork and all three numbers
// grow together; art_w is the one knob.
//
// The left and right edges need no such treatment: the flat simply runs out
// where its plane meets the barrel, which is why the plaque has straight sides
// and gabled ends rather than four square corners.
//
// WHAT IS ON THE PLAQUES. The middle finger, standing out of the flat, on both
// of them (Ziad, 2026-09-14: take the words off and put the finger on instead).
// It was three lines of debossed type until then — ZAMIL'S / FUCKING / RED BULL,
// justified by size off a table of measured ink boxes. All of that is gone: the
// justification machinery, the ink table, the censored variant and the
// textmetrics note with it. git log has them if they are ever wanted back.
//
// The artwork comes from middle-finger-emboss.scad, which is where the mesh,
// the angles it is stood at and the 20 mm it is sliced to are all decided. This
// file gives it a width and a relief depth and nothing else.
//
// ⚠️ THE RELIEF IS SQUASHED, and it has to be. At 34 mm wide a true-scale
// relief would stand 7.46 mm off the plaque floor, and the floor is only 5.67
// below the barrel — so at full scale the fist would break the 3 inch envelope
// this whole part exists to hold. art_relief is 4.00, which is 54% of scale
// depth and leaves 1.67 mm between the knuckles and the barrel's own surface.
// It is still a relief; reliefs are squashed. Raising art_w makes the plaque
// deeper and buys headroom if a taller one is wanted.
//
// THE FIT — INHERITED, NOT CONFIRMED. The bore is drawn generous and six
// rounded ribs take the slack back up. bore_comp and rib_h are carried over
// from the 250 ml part unchanged, where a printed coupon settled them on
// 2026-08-22 — drawn 54.00, printed 53.77, 53.17 across the ribs, and a real
// can in snug and out without a fight. That transfer is not a guess: the loss
// this machine takes out of a bore is roughly constant in absolute terms at
// this scale rather than proportional, so the same 0.23 applies at Ø58.40 as at
// Ø54.00. The whole ladder shifts bodily by the 4.40 the can grew and lands on
// the same 0.17 of clearance across the ribs. See bore_comp and [Grip ribs]
// before changing either number, because they were sized against each other.
//
// ⚠️ What is NOT confirmed is that a 12 oz can in Ziad's hand measures 57.40.
// The number is well sourced but nothing has been miked and no coupon has been
// printed for this part. Print [Fit coupon] before the part.
//
// ORIENTATION. Printed floor-down, z = 0 at the underside. The only overhang in
// the part is the roof over the annular cavity, a 4.40 mm bridge broken into
// eight short pockets by the webs. Nothing here needs support.
//
// ⚠️ The can is 156 mm tall and this is 100, so 56 mm stands proud — more than
// the 34 the 250 ml part leaves, because the height was held while the can grew
// 22 mm. That is a deliberate hold, not an oversight: the outside diameter was
// the stated constraint and a taller barrel is a longer print. total_h = 116
// restores the same three-quarters coverage and every assert in the file passes
// at that height, so it is a one-line change if the proportion matters more
// than the plate time.
// The one thing a coupon can answer here, and the variant that puts it on a
// plate. There is only one, so the plate and the component are the same
// variant; utils/coupon.sh reads these directives and needs no knowledge of
// this part. Keep the names stable.

// Note 2. The artwork. middle-finger-emboss.scad owns the mesh, the angles it is stood
// at and the depth it is sliced to; this file only asks for it at a width and
// a relief depth. standalone = false is what stops its own hand appearing at
// this part's origin — see the note on it over there.

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. "cut" is a half-section for reading the double wall, the cavity and the ribs.
// Not for printing — build it with --name if you want it as its own STL.
// "coupon" is the fit test; see [Fit coupon].

// Note 5. organic faceting per the 0.4-nozzle rule; no global high $fn

// Note 6. Body diameter of a 355 ml / 12 oz sleek can (mm). See THE CAN in the header
// for where 57.40 comes from, and why the widely published 58 is the flange
// code rather than the body.
//
// This is the number the whole part hangs off, and three things move with it:
// the cavity narrows 1:2 as it grows — at 57.40 the cavity is 4.40 against an
// assert floor of 3.00, so Ø60.20 is the ceiling for a double-walled part — the
// wall behind each plaque thins 1:2 as well, and the rib clearance shifts 1:1.
// A squat 12 oz can at Ø66 does not fit this part at all: it would leave 4.6 mm
// of wall, which is no cavity and no plaques.

// Note 7. Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.

// Note 8. Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
//
// SETTLED, 2026-08-22, on the 250 ml part's fit coupon, and carried here
// unchanged. A bore drawn at 54.00 miked 53.77 between the ribs — a loss of
// 0.23 on diameter. Ziad pushed a real can in: "fits perfectly, snug enough but
// not difficult".
//
// It transfers to this bore because the loss does not scale. The slicing
// reference measured 0.55–0.65 off a bore drawn at 10.15; the 250 ml part
// measured 0.23 off one drawn at 54.00. A fixed loss would have taken 0.60 off
// the big bore and did not; a proportional loss would have taken 0.04 off the
// small one and did not. The small-bore figure is first-layer squish and
// extrusion pull-in — local, and roughly constant in absolute terms — so
// between Ø54.00 and Ø58.40 there is nothing left in it that changes.
//
// ⚠️ Do NOT "correct" this number to the measured 0.23. 0.60 is what produced a
// bore that fits, and the ribs were sized against it. The two are a matched
// pair; changing one without the other opens the fit back up.

// Note 9. Outside diameter (mm). 76.20 is 3 inches, and it is the whole point of the
// part — this is the number to leave alone. It is also what makes this a copy
// rather than a scale-up: the sibling holder is the same 3" barrel.

// Note 10. Overall height (mm). The can is 156, so this leaves 56 mm proud. Read the
// closing note in the header before changing it.

// Note 11. Inner shell, the tube around the can (mm). 2.10 is 5 walls at 0.42.

// Note 12. Outer shell at the top of a flute — the flats, not the valleys (mm). 2.40 is
// thicker than the inner shell on purpose: the flutes eat into it.

// Note 13. Roof over the annular cavity (mm). 1.60 is 8 layers at 0.20, bridging 4.40 —
// 2.20 mm less span than the same roof carries on the 250 ml part, so this is
// the easy end of the trade the bigger bore made.

// Note 14. Floor thickness (mm). The requirement is "at least 5"; 5.40 is 27 layers at
// 0.20 and it is what the can lands on and what you set down on things.

// Note 15. Hole through the floor (mm). Drains condensation and lets a finger push the
// can back out of a 100 mm bore, which matters more here than on a short one.
// Set to 0 for a closed floor.

// Note 16. Radius of the round on the bottom outside edge (mm). Set to 0 for a plain
// chamfer of base_cham instead.
//
// ⚠️ It is NOT a full quarter-round, and it cannot be. A round tangent to the
// bottom face is horizontal where it meets the bed: the first 0.20 mm of layer
// would grow 1.40 mm outward with nothing under it, which is a 90-degree
// overhang and prints as a drooping skirt. So the arc is truncated at
// base_over, and below that it runs on as a straight cone at that same angle
// down to the bed. The radius you asked for is the radius you get everywhere
// the eye reads it; only the last 1.46 mm is a cone.

// Note 17. Steepest overhang the round is allowed to reach, measured from vertical.
// 45 is MAX_OVERHANG_DEG out of the printer reference — safe unsupported on
// this machine, and FlashForge's own guidance is more conservative still.

// Note 18. 45-degree chamfer on the bottom outside edge (mm), used only when
// base_round is 0 — more reliable than the slicer's elephant-foot compensation.

// Note 19. 45-degree chamfer on the top outside edge (mm). Cosmetic, and it takes the
// sharpness off the rim.

// Note 20. Lead-in at the mouth of the bore: how far it opens on radius (mm)...

// Note 21. ...over how much height (mm). This is what lets the can be dropped in without
// being aimed. It opens outward going up, so it costs no support.

// Note 22. Shallow vertical flutes cut into the outside. They run the full height and
// off both chamfers, so there is no ledge anywhere and no floating detail.

// Note 23. How deep each one cuts on radius (mm). This comes straight out of outer_w —
// see the assert below.

// Note 24. Radius of the circle that cuts each flute (mm). With the defaults this makes
// a flute 5.6 mm across on a 9.97 mm pitch, so 4.4 mm of flat between them.

// Note 25. How close a flute is allowed to come to the edge of a plaque (mm) before it
// is dropped altogether. A flute that clips the corner of a plaque steals the
// padding it was supposed to leave, and there is no way to have both — so the
// flute goes. With the defaults this drops 4 of the 24; the echo says how many.

// Note 26. Bounded flat plaques milled into the barrel, one per sign, evenly spaced.
// Cut in, never stood off, so the 3 inch maximum is untouched.

// Note 27. Clear space around the type, on all four sides (mm). This IS the plaque —
// its width is art_w + 2 x this, its height is the artwork + 2 x this, and it
// is no bigger than that in either direction.

// Note 28. Width of the artwork, and with it the whole plaque (mm). Everything
// downstream is a consequence: the plaque is 6.00 wider, the flat is that much
// below the barrel surface (5.67 at 34.00), and the bevel that makes the flat
// printable is exactly as tall as the flat is deep. The height follows too —
// the artwork has a fixed aspect and the plaque is sized to it.

// Note 29. Height of the centre of the artwork above the base (mm).
//
// 55 with the old three-line block, which was 31.4 tall. The artwork is 47.8,
// so the plaque with its bevels is now 65.2 of a 100 mm barrel and there is
// only 34.8 of slack in the whole height — the freedom the old number had is
// gone. 46 is what is left after both ends are respected: the bevel has to
// clear the base round below (13.4 against 5.0) and the plaque has to stay out
// of the fit coupon above, which takes the top 18 mm, so nothing may reach
// past 81. At 46 the top bevel ends at 78.6.

// Note 30. How far the relief stands proud of the plaque's floor (mm).
//
// ⚠️ It must stay under sign_sag, the 5.67 the flat is sunk below the barrel,
// or the artwork pokes out past the 3 inch maximum that is the whole point of
// this part. There is an assert on it.
//
// It is also not the scale depth. At art_w wide a true-scale relief would
// stand art_w * 20 / 91.17 = 7.46 proud, so finger_mark squashes the depth to
// this instead of scaling it with the width. Squashing depth is what a relief
// is; the alternative here is not a deeper relief, it is a part that is no
// longer 3 inches across.

// Note 31. Rounded vertical ribs inside the bore, so the can is held rather than
// rattling, without shrinking the bore itself. Set rib_count or rib_h to 0 for
// a plain slip fit.
//
// THE ARITHMETIC. Two ribs sit across any diameter, so the working size is
// (printed bore) - 2 x rib_h. The bore is drawn 58.40 and this machine takes
// 0.23 out of a bore that size — measured, see bore_comp — so the printed bore
// is 58.17.
//
// rib_h 0.20  ->  57.77   0.37 clearance on a Ø57.4 can
// rib_h 0.30  ->  57.57   0.17 clearance   <- carried from the 250 ml part
// rib_h 0.40  ->  57.37   0.03 interference
// rib_h 0.50  ->  57.17   0.23 interference
//
// That is the same ladder the 250 ml part has, shifted bodily by the 4.40 the
// can grew, and it lands on the same 0.17 — the clearance Ziad printed and
// called snug but not difficult. Nothing here is a new decision. Go to 0.40
// only if the can measures under Ø57.4, and sand rather than reprint.

// Note 32. How far each rib stands into the bore (mm).

// Note 33. Chord width of the bump (mm). Sets the bearing area; its radius is derived so
// the arc is exactly this wide at exactly rib_h proud.

// Note 34. Lead-in at the top, over which the rib fades to nothing (mm). This is what
// makes insertion progressive instead of a step.

// Note 35. Foot at the bottom, same idea (mm). This end is the one the printer sees as
// an overhang, and at 0.30 over 2 mm it is 8.5 degrees off vertical.

// Note 36. Radial webs tying the inner tube to the outer shell across the cavity. They
// also break the cavity roof into eight short bridges.

// Note 37. Web thickness (mm). 1.35 is 3 walls at the real 0.45 inner line width.

// Note 38. The top of the part, cut off and stood on the bed, so a real can can be
// pushed into it before committing to a five-hour print. It is a genuine slice
// of the barrel — inner shell, cavity, webs, outer shell, flutes — because that
// structure is what decides whether the bore comes out round and on size, and a
// bare tube would not answer the same question.
//
// ⚠️ PRINT THIS ONE FIRST. On the 250 ml part the coupon confirmed a bore that
// had already been reasoned out. Here it is also the only thing that will tell
// you whether Ø57.40 is the can you actually have.
//
// Height (mm). The budget from the top down: 2.00 of mouth chamfer, 1.00 of
// clearance, 8.00 of rib ramp and then full-proud rib. 18.00 leaves 7 mm of
// rib at full height, which is plenty to feel, and clears the top of the
// plaque's upper bevel at z 76.42 by 5.58.

// Note 39. Relief on the bore at the cut face (mm), at 45 degrees, taking the rib tips
// with it. The real part's bore never touches the bed — the floor does — so
// without this the coupon's tightest point would be its own elephant foot and
// it would read tight for a reason the part does not share.

// Note 40. Chord error target (mm). 0.02 is the 0.4-nozzle figure.

// Note 41. Facets for a target chord error on a given radius.

// Note 42. Radius that makes the INSCRIBED polygon's inner radius equal r.

// Note 43. The cavity, and what it leaves of each shell.

// Note 44. The base round. Centre sits one radius in and one radius up, so the arc is
// tangent to the barrel at z = base_round. base_tan is where it reaches
// base_over from vertical and hands over to the cone; base_foot is where that
// cone lands on the bed.

// Note 45. Height at which the barrel first reaches full width, whichever edge is used.

// Note 46. Flute cutter: a circle of flute_cut_r whose nearest approach to the axis
// leaves flute_depth cut out of the outside.

// Note 47. Half-chord where that cutter breaks the surface — the visible flute width.

// Note 48. The artwork's height follows its width: it is a fixed relief and the plaque
// is sized to it rather than the other way round.

// Note 49. The plaque, which is the block plus sign_pad on all four sides and nothing
// else. Its width fixes its depth: flat_r is where a chord sign_w long sits on
// a circle of out_r, and sign_sag is how far below the surface that is. The
// bevel that makes the top of it printable runs at 45 degrees, so it is
// sign_sag tall as well — the frame and the depth are the same number.

// Note 50. Set against the INRADIUS of the barrel polygon, not the circle it is drawn
// in. An inscribed 97-gon runs 0.02 mm inside its circle, and taking the chord
// off the circle would have handed back a flat 39.92 wide where 40.00 was
// asked for — 2.96 of padding instead of 3.00. Off the inradius the flat is
// 40.00 at the polygon's flats and a hair over at its vertices, so the padding
// is never short.

// Note 51. solid wall left behind a plaque
// Half the angle the plaque subtends, for the do-they-collide assert.

// Note 52. Half-angle of the wedge that backs it, taken at the cavity's inner radius
// because that is where the plaque covers the widest sweep.

// Note 53. Does a flute cutter centred at angle t eat into the plaque's flat? The cutter
// is a circle of flute_cut_r at flute_off from the axis, so it reaches the
// plane x = flat_r only when the plane passes through it, and the chord it cuts
// there runs cy +/- h. If that chord reaches inside the plaque's width the
// flute takes a bite out of the corner of the flat.
//
// This is not hypothetical. Before the check went in on the 250 ml part, the
// flute at 30 degrees clipped both corners and left a flat 36.94 wide instead
// of 40.00 — 1.47 mm of side padding where 3.00 was specified. It is invisible
// in a render and shows up immediately in the mesh.

// Note 54. True if flute i bites any of the plaques.

// Note 55. Ribs: a circular arc rib_w wide at exactly rib_h proud of the bore.

// Note 56. Solid section of the holder, before the wall is hollowed out. Bottom inner
// corner first, running counter-clockwise: floor, base chamfer, barrel, top
// chamfer, rim, mouth lead-in, bore, floor again.

// Note 57. Bottom edge: a cone from the bed up to base_tan, then the arc round to
// vertical. Angles are measured at the arc's centre, 0 being the
// tangent-to-vertical point and -base_over the handover to the cone. The
// segment count comes off the same chord-error budget as everything else.

// Note 58. The annular void between the two shells.

// Note 59. Half-pitch offset keeps a web off the y = 0 plane, so the "cut" view
// shows the cavity rather than a web edge-on.

// Note 60. Full-height vertical cutters. Running them past both ends is what keeps the
// flutes free of ledges — they simply run off the chamfers.

// Note 61. One plaque pocket per sign, as a meridian profile swept the width of the
// barrel. Read bottom to top: a 45-degree ramp up to the flat, the flat itself
// from sign_z0 to sign_z1, then a 45-degree ramp back out to the surface. Both
// ramps are sign_sag tall because that is what 45 degrees costs over sign_sag
// of depth, and the top one is the one that is not optional.
//
// Nothing bounds this in y and nothing needs to. Past the plaque's edge the
// plane x = flat_r is already outside the barrel, so the cut simply stops —
// which is what gives the plaque its straight sides and gabled ends.

// Note 62. Solid behind each plaque, made by taking a wedge back out of the cavity over
// the plaque's height. The plaque floor sits at 32.41 and the cavity runs
// 31.30 to 35.70, so the pocket lands inside the cavity and something has to
// give — this is the something. The bigger bore made that overlap worse rather
// than better: only 1.11 mm now separates the plaque floor from the inner
// shell, against 3.33 on the 250 ml part.
//
// IT HAS TO BE A WEDGE, NOT A BOX. A box spanning |y| <= 21 and x >= cav_ri - 1
// looks like it covers the sector and does not: the cavity's inner corner where
// it meets a web at 22.5 degrees sits at x = 28.91, inboard of the box, so a
// 1.4 mm sliver of cavity squeaks past the block and runs the full height. The
// pocket behind each plaque then comes out as a TORUS rather than being severed
// — caught on the 250 ml part by counting shells in the mesh, where two pockets
// reported genus 1, and invisible in every render. A wedge from the axis has no
// such corner.
//
// The half-angle is taken at cav_ri, the radius where the plaque subtends the
// most, so the whole footprint is covered at every depth.

// Note 63. The finger, standing off each plaque's floor. rotate([0, 0, -90]) turns the
// relief so its flat face lands on the plaque's plane and it stands outward:
// the artwork is built facing +Y and the plaque faces +X. It reads the right
// way round doing that — a viewer at +X has +Y on their right, a viewer at +Y
// has -X on theirs, and the turn carries one onto the other.
//
// Sunk eps into the floor so the union has something to bite on rather than
// two coincident planes.

// Note 64. Half-pitch off the webs, so a rib never lands on a web edge-on in
// the cut view. Nothing structural depends on where they sit.

// Note 65. The ribs are unioned in BEFORE the cavity is cut, not after. Each rib is
// a 3.90 mm arc and only 0.30 mm of it is wanted, so left to itself a rib
// reaches 36.70 mm out — 5.40 mm into a cavity that is only 4.40 wide, so
// it crosses the whole thing. Cutting the cavity last shaves them off flush
// with the inner shell and gets the dead air back.

// Note 66. The cavity less the webs is the set of pockets to hollow out. Doing
// it in one subtraction beats hollowing and then unioning the webs back
// in — that version dropped webs to boolean robustness failures on
// slim-can-adapter.scad.

// Note 67. The artwork goes on AFTER the plaque is cut, not before: it stands
// out of the floor the pocket leaves, so it has to survive that cut.

// Note 68. The fit coupon: the top coupon_h of the finished part, dropped onto the bed
// the same way up as the part itself. Taking it off the real thing rather than
// drawing a lookalike is deliberate — every number that could move the bore is
// then the number the part will print with.

// Note 69. 45 degrees, clearing the rib tips

// Note 70. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
