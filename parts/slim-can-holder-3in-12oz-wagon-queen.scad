// Slim can holder — 3 inch outside, 355 ml / 12 oz sleek can, Wagon Queen crest.
//
// A copy of slim-can-holder-3in-12oz.scad with different artwork on it, and it
// is meant to stay a copy. Everything that differs from that file differs
// because the artwork changed — four plaques instead of two, sized to the
// lockup's 1 : 2.1607 instead of the finger's, and the Wagon Queen lockup in
// place of the finger. The can, the bore, the ribs, the cavity, the webs, the flutes, the
// floor and the fit coupon are untouched, so a diff between the two is exactly
// the list of things the logo forced.
//
// That file is itself a copy of slim-can-holder-3in.scad rebored for the
// bigger can. The outside is still 76.20 mm, exactly 3", on all three.
//
// THE CAN. Ø57.40 x 155.6 — the standard sleek 355 ml body, which is one size
// up the same family as the 250 ml slim can the sibling holds. Three
// independent sources agree, and they are not the ones a search puts first:
//
//     Ball's own 12 oz sleek, via a co-packer spec:   Ø2.259" = 57.38
//     Alucan sleek-family chart, 355 ml row:          Ø57.40 x 155.73
//     Amazon's 4-pack footprint, 4.56" across two:    Ø57.9 including the wrap
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
// THE SIGNS. FOUR of them, at the cardinal directions: a bounded flat plaque
// milled into the barrel, not a flat side. Each is exactly the artwork plus
// 3 mm of padding all round — 30.00 wide by 57.9 tall — and nothing more, so
// the barrel above and below it is still round and still fluted.
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
// WHAT IS ON THE PLAQUES. The Wagon Queen crest, from logos/marks.scad, four
// times. art_mode picks emboss or deboss; it is embossed by default, the way
// the sibling's finger is.
//
// THE WHOLE LOCKUP, CREST AND LETTERING, and the lettering only works because
// it is SWELLED. Measured, by eroding the artwork until its thinnest stroke
// pinches off:
//
//     lockup script   thinnest stroke  1.94% of the mark's width
//     crest bars      thinnest stroke  7.09% of the crest's width
//
// At art_w 24 that puts the script's thins at 0.47 mm, which is one extrusion
// line and change — it would print as a broken dotted line. Making the
// artwork bigger is not the way out: for the script to reach 0.84 unswelled it
// needs art_w >= 43.3, which puts sign_w at 49.3, and a 49.3 mm chord on this
// barrel's inradius sits at flat_r 29.03 against a bore at 29.215 — the plaque
// floor would be inside the bore. That is a radius problem on a fixed 3 inch
// diameter and no amount of height or padding fixes it.
//
// So the script is swelled instead, which is what marks.scad's note on
// zr_monogram prescribes for exactly this: let the thins gain and let the
// thicks carry the extra. art_swell 0.185 takes the thins 0.47 -> 0.84 while
// the heavy strokes grow by the same absolute amount, which at reading
// distance is the same drawing a little heavier.
//
// The budget on that is the COUNTERS, not the strokes: swelling closes the
// holes in the a, the g, the o, the e's and the Q by twice itself, and the
// first of the eight shuts at 0.354 mm. 0.19 spends 54% of that, measured by
// swelling the lettering and watching the genus hold at 5 | 2 | 1.
//
// ⚠️ An earlier round of this part left the lettering OFF and called it
// impossible. That was wrong, and wrong in a specific way worth recording: it
// reasoned only about scaling the artwork up and never about swelling it,
// despite the library documenting the technique. The geometry that ruled out
// art_w 43.3 is real; the conclusion drawn from it was not.
//
// THE CREST IS NOT SWELLED. It does not need it — registered to the lockup's
// box it is 19.5 mm wide at art_w 24 and its bars come out 1.38 mm — and
// swelling it would close its own gaps for nothing. The two halves come from
// wagon_queen_crest() and wagon_queen_word(), which are both registered to
// the LOCKUP's bounding box rather than their own, so they land on the plaque
// in the same relationship they have in the artwork. That shared registration
// is the whole reason marks.scad splits them.
//
// THE RELIEF IS NOT SQUASHED HERE. The sibling's finger is a 3D mesh whose
// true-scale depth would break the 3 inch envelope, so it is squashed to 54%.
// This is flat artwork extruded to whatever depth is asked for, so art_relief
// is a free choice under sign_sag rather than a compromise: 2.00 against 3.10
// of room, leaving 1.10 mm between the crest and the barrel's own surface.
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
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

// The artwork. logos/marks.scad owns the mark, its registration and its
// bounding box; this file only asks for the crest at a width. The library
// defines modules and calls none, so unlike middle-finger-emboss.scad there is
// no standalone flag to switch off — nothing appears at this part's origin
// just from including it.
include <../logos/marks.scad>

/* [Output] */

// "cut" is a half-section for reading the double wall, the cavity and the ribs.
// Not for printing — build it with --name if you want it as its own STL.
// "coupon" is the fit test; see [Fit coupon].
show = "part";   // [part, cut, coupon]

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a 355 ml / 12 oz sleek can (mm). See THE CAN in the header
// for where 57.40 comes from, and why the widely published 58 is the flange
// code rather than the body.
//
// This is the number the whole part hangs off, and three things move with it:
// the cavity narrows 1:2 as it grows — at 57.40 the cavity is 4.40 against an
// assert floor of 3.00, so Ø60.20 is the ceiling for a double-walled part — the
// wall behind each plaque thins 1:2 as well, and the rib clearance shifts 1:1.
// A squat 12 oz can at Ø66 does not fit this part at all: it would leave 4.6 mm
// of wall, which is no cavity and no plaques.
can_d = 57.40;
// Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.
can_slop = 0.40;
// Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
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
bore_comp = 0.60;

/* [Shell] */

// Outside diameter (mm). 76.20 is 3 inches, and it is the whole point of the
// part — this is the number to leave alone. It is also what makes this a copy
// rather than a scale-up: the sibling holder is the same 3" barrel.
outer_d = 76.20;
// Overall height (mm). The can is 156, so this leaves 56 mm proud. Read the
// closing note in the header before changing it.
total_h = 100.0;
// Inner shell, the tube around the can (mm). 2.10 is 5 walls at 0.42.
inner_w = 2.10;
// Outer shell at the top of a flute — the flats, not the valleys (mm). 2.40 is
// thicker than the inner shell on purpose: the flutes eat into it.
outer_w = 2.40;
// Roof over the annular cavity (mm). 1.60 is 8 layers at 0.20, bridging 4.40 —
// 2.20 mm less span than the same roof carries on the 250 ml part, so this is
// the easy end of the trade the bigger bore made.
roof_t = 1.60;

/* [Floor] */

// Floor thickness (mm). The requirement is "at least 5"; 5.40 is 27 layers at
// 0.20 and it is what the can lands on and what you set down on things.
floor_t = 5.40;
// Hole through the floor (mm). Drains condensation and lets a finger push the
// can back out of a 100 mm bore, which matters more here than on a short one.
// Set to 0 for a closed floor.
drain_d = 12.0;
// Radius of the round on the bottom outside edge (mm). Set to 0 for a plain
// chamfer of base_cham instead.
//
// ⚠️ It is NOT a full quarter-round, and it cannot be. A round tangent to the
// bottom face is horizontal where it meets the bed: the first 0.20 mm of layer
// would grow 1.40 mm outward with nothing under it, which is a 90-degree
// overhang and prints as a drooping skirt. So the arc is truncated at
// base_over, and below that it runs on as a straight cone at that same angle
// down to the bed. The radius you asked for is the radius you get everywhere
// the eye reads it; only the last 1.46 mm is a cone.
base_round = 5.00;

// Steepest overhang the round is allowed to reach, measured from vertical.
// 45 is MAX_OVERHANG_DEG out of the printer reference — safe unsupported on
// this machine, and FlashForge's own guidance is more conservative still.
base_over = 45;

// 45-degree chamfer on the bottom outside edge (mm), used only when
// base_round is 0 — more reliable than the slicer's elephant-foot compensation.
base_cham = 0.60;

/* [Mouth] */

// 45-degree chamfer on the top outside edge (mm). Cosmetic, and it takes the
// sharpness off the rim.
top_cham = 1.00;
// Lead-in at the mouth of the bore: how far it opens on radius (mm)...
mouth_cham_r = 1.20;
// ...over how much height (mm). This is what lets the can be dropped in without
// being aimed. It opens outward going up, so it costs no support.
mouth_cham_h = 2.00;

/* [Flutes] */

// Shallow vertical flutes cut into the outside. They run the full height and
// off both chamfers, so there is no ledge anywhere and no floating detail.
flute_count = 24;
// How deep each one cuts on radius (mm). This comes straight out of outer_w —
// see the assert below.
flute_depth = 0.80;
// Radius of the circle that cuts each flute (mm). With the defaults this makes
// a flute 5.6 mm across on a 9.97 mm pitch, so 4.4 mm of flat between them.
flute_cut_r = 6.00;
// How close a flute is allowed to come to the edge of a plaque (mm) before it
// is dropped altogether. A flute that clips the corner of a plaque steals the
// padding it was supposed to leave, and there is no way to have both — so the
// flute goes. With the defaults this drops 4 of the 24; the echo says how many.
flute_clear = 0.50;

/* [Signs] */

// Bounded flat plaques milled into the barrel, one per sign, evenly spaced.
// Cut in, never stood off, so the 3 inch maximum is untouched.
sign_count = 4;
// Clear space around the type, on all four sides (mm). This IS the plaque —
// its width is art_w + 2 x this, its height is the artwork + 2 x this, and it
// is no bigger than that in either direction.
sign_pad = 3.00;

/* [Panel art] */

// Width of the artwork, and with it the whole plaque (mm). Everything
// downstream is a consequence: the plaque is 6.00 wider, the flat is that much
// below the barrel surface (3.10 at 24.00), and the bevel that makes the flat
// printable is exactly as tall as the flat is deep. The height follows too —
// the crest has a fixed 1 : 1.5505 aspect and the plaque is sized to it.
//
// 24.00 is the balance point between three things that pull against each other
// once there are FOUR plaques rather than two:
//
//   up    the crest's bars are 7.09% of its width, so they are 1.70 mm here
//         and would be 1.42 at 20.00 — both fine, and 0.84 is the floor
//   down  each plaque needs a solid backing wedge, and four of them eat the
//         cavity: at 24.00 they cover 246 of 360 degrees and 32% of the
//         cavity survives, against 53% on the two-plaque sibling
//   down  sign_sag grows as the square of the chord, and the relief has to fit
//         under it inside a 2.40 mm outer shell
art_w = 24.00;

// Height of the centre of the artwork above the base (mm).
//
// The lockup's plaque is 64.1 tall with its bevels — close to the finger's
// 65.2 — so the slack is back to a few millimetres at each end. The two that
// bound it: the lower bevel must clear the base round (11.97 against 5.0) and
// the upper must stay out of the fit coupon, which takes the top 18 mm, so
// nothing may reach past 82. At 44 the top bevel ends at 76.03. Legal range is
// 37.1 to 50.0; 44 centres what is left.
art_z = 44.0;

// Emboss the crest out of the plaque floor, or deboss it into it.
//
// The crest is the one half of the lockup with no counters — extruded it is
// seven disjoint solids, all genus 0 — so either direction is safe. That only
// matters for a through-cut, which this is not, but it is why the crest is
// also the half that COULD be cut through a thin wall on some other part.
art_mode = "emboss";   // [emboss, deboss]

// How much to swell the LETTERING before placing it (mm, per side).
//
// The script's thins are 1.94% of the lockup's width, so at art_w 24 they are
// 0.47 mm — under two 0.42 lines, and it would print broken. This is the knob
// that fixes that without growing the plaque, which cannot grow. 0.185 takes
// them to 0.84.
//
// ⚠️ It is bounded from ABOVE by the counters, not by the strokes. Swelling
// closes the eight holes in the lettering by twice itself and the first shuts
// at 0.354 mm; there is an assert. Set to 0 to see the artwork as drawn, and
// expect a dotted script.
art_swell = 0.19;

// Radius the CREST's outline is rounded to (mm). 0 leaves it as drawn.
//
// The crown is geometric where the script is not: the bars and the rule end in
// square corners and the three points meet in sharp Vs, and next to a script
// whose terminals are all round that is what reads as sharp (Ziad,
// 2026-09-16). This softens the silhouette without redrawing the mark.
//
// It is the erode-dilate-erode that logos/marks.scad uses on the cat's face —
// offset(-k) offset(+2k) offset(-k) — because it rounds CONVEX and CONCAVE
// corners alike, where a plain closing or opening only gets one kind. The
// valleys between the crown's points are concave and they need it as much as
// the bar ends do. Net offset is zero, so stroke widths on the flats are
// untouched.
//
// ⚠️ THE FIRST ERODE IS WHAT BOUNDS IT. It cuts 2 x this off the narrowest
// feature, and if that reaches zero the feature is gone for good — dilating
// afterwards cannot bring back something that was severed. The bars are
// art_w x crest_thin_frac = 1.38 mm here, so this has to stay well under
// 0.69; 0.35 leaves them 0.68 through the pinch. There is an assert.
//
// The script is deliberately NOT rounded. Its thins are already down to 0.846
// after the swell, so the same erode would leave them 0.146 and the round
// would be fighting the swell for the same millimetre.
crest_round = 0.35;

// How far the relief stands proud of the plaque's floor, or sinks into it (mm).
//
// ⚠️ Embossed it must stay under sign_sag, the 3.10 the flat is sunk below the
// barrel, or the artwork pokes out past the 3 inch maximum that is the whole
// point of this part. There is an assert on it.
//
// Debossed the binding number is different and looser: sign_t, the 5.79 mm of
// solid wall the plaque leaves over the bore. The same assert covers both,
// since sign_sag is the smaller of the two.
//
// Unlike the sibling this is a free choice rather than a compromise — see THE
// RELIEF IS NOT SQUASHED HERE in the header. 2.00 is 10 layers at 0.20.
art_relief = 2.00;

/* [Grip ribs] */

// Rounded vertical ribs inside the bore, so the can is held rather than
// rattling, without shrinking the bore itself. Set rib_count or rib_h to 0 for
// a plain slip fit.
//
// THE ARITHMETIC. Two ribs sit across any diameter, so the working size is
// (printed bore) - 2 x rib_h. The bore is drawn 58.40 and this machine takes
// 0.23 out of a bore that size — measured, see bore_comp — so the printed bore
// is 58.17.
//
//     rib_h 0.20  ->  57.77   0.37 clearance on a Ø57.4 can
//     rib_h 0.30  ->  57.57   0.17 clearance   <- carried from the 250 ml part
//     rib_h 0.40  ->  57.37   0.03 interference
//     rib_h 0.50  ->  57.17   0.23 interference
//
// That is the same ladder the 250 ml part has, shifted bodily by the 4.40 the
// can grew, and it lands on the same 0.17 — the clearance Ziad printed and
// called snug but not difficult. Nothing here is a new decision. Go to 0.40
// only if the can measures under Ø57.4, and sand rather than reprint.
rib_count = 6;
// How far each rib stands into the bore (mm).
rib_h = 0.30;
// Chord width of the bump (mm). Sets the bearing area; its radius is derived so
// the arc is exactly this wide at exactly rib_h proud.
rib_w = 3.00;
// Lead-in at the top, over which the rib fades to nothing (mm). This is what
// makes insertion progressive instead of a step.
rib_ramp = 8.0;
// Foot at the bottom, same idea (mm). This end is the one the printer sees as
// an overhang, and at 0.30 over 2 mm it is 8.5 degrees off vertical.
rib_foot = 2.0;

/* [Webs] */

// Radial webs tying the inner tube to the outer shell across the cavity. They
// also break the cavity roof into eight short bridges.
web_count = 8;
// Web thickness (mm). 1.35 is 3 walls at the real 0.45 inner line width.
web_t = 1.35;

/* [Fit coupon] */

// The top of the part, cut off and stood on the bed, so a real can can be
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
coupon_h = 18.00;

// Relief on the bore at the cut face (mm), at 45 degrees, taking the rib tips
// with it. The real part's bore never touches the bed — the floor does — so
// without this the coupon's tightest point would be its own elephant foot and
// it would read tight for a reason the part does not share.
coupon_relief = 0.60;

/* [Quality] */

// Chord error target (mm). 0.02 is the 0.4-nozzle figure.
chord_err = 0.02;

/* [Hidden] */

// Facets for a target chord error on a given radius.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Radius that makes the INSCRIBED polygon's inner radius equal r.
function r_hole(r, n) = r / cos(180 / n);

bore_d   = can_d + can_slop + bore_comp;
bore_r   = bore_d / 2;
out_r    = outer_d / 2;

nseg     = facets(out_r);
r_bore   = r_hole(bore_r, nseg);
r_drain  = drain_d > 0 ? r_hole(drain_d / 2, nseg) : 0;

// The cavity, and what it leaves of each shell.
cav_ri   = bore_r + inner_w;
cav_ro   = out_r - outer_w;
cav_z0   = floor_t;
cav_z1   = total_h - roof_t;

// The base round. Centre sits one radius in and one radius up, so the arc is
// tangent to the barrel at z = base_round. base_tan is where it reaches
// base_over from vertical and hands over to the cone; base_foot is where that
// cone lands on the bed.
base_cz     = base_round;
base_cr     = out_r - base_round;
base_tan_r  = base_cr + base_round * cos(base_over);
base_tan_z  = base_cz - base_round * sin(base_over);
base_foot_r = base_tan_r - base_tan_z * tan(base_over);
// Height at which the barrel first reaches full width, whichever edge is used.
base_top_z  = base_round > 0 ? base_round : base_cham;

// Flute cutter: a circle of flute_cut_r whose nearest approach to the axis
// leaves flute_depth cut out of the outside.
flute_off = out_r - flute_depth + flute_cut_r;
// Half-chord where that cutter breaks the surface — the visible flute width.
flute_a   = (pow(flute_off, 2) + pow(out_r, 2) - pow(flute_cut_r, 2))
            / (2 * flute_off);
flute_hw  = sqrt(pow(out_r, 2) - pow(flute_a, 2));

// The artwork's height follows its width: the crest has a fixed aspect and the
// plaque is sized to it rather than the other way round. The function comes
// from marks.scad and answers for the crest's OWN bounding box, which is the
// one wagon_queen_crest_alone is registered to — see the warning over the
// height functions there before reaching for a different one.
art_h = wagon_queen_height(art_w);
// Thinnest features and the swell budget, all as fractions of the LOCKUP's
// width, measured by eroding or swelling the artwork until the mesh changes:
//
//   script thins     survives offset(r = -7.0) of a native 746.806, breaks -7.5
//   crest bars       survives -21 of the crest's own native 606.804, breaks -22
//   counter closure  all eight holes hold at +11, the first shuts by +12
script_thin_frac  = 2 * 7.25 / 746.806;                  // 1.94%
crest_thin_frac   = (2 * 21.5 / 606.804) * (606.804 / 746.806);  // 5.76%
counter_budget_frac = 11.0 / 746.806;                    // 1.47%

// The plaque, which is the block plus sign_pad on all four sides and nothing
// else. Its width fixes its depth: flat_r is where a chord sign_w long sits on
// a circle of out_r, and sign_sag is how far below the surface that is. The
// bevel that makes the top of it printable runs at 45 degrees, so it is
// sign_sag tall as well — the frame and the depth are the same number.
sign_w   = art_w + 2 * sign_pad;
sign_h   = art_h + 2 * sign_pad;
// Set against the INRADIUS of the barrel polygon, not the circle it is drawn
// in. An inscribed 97-gon runs 0.02 mm inside its circle, and taking the chord
// off the circle would have handed back a flat 39.92 wide where 40.00 was
// asked for — 2.96 of padding instead of 3.00. Off the inradius the flat is
// 40.00 at the polygon's flats and a hair over at its vertices, so the padding
// is never short.
flat_r   = sqrt(pow(out_r * cos(180 / nseg), 2) - pow(sign_w / 2, 2));
sign_sag = out_r - flat_r;
sign_z0  = art_z - sign_h / 2;
sign_z1  = art_z + sign_h / 2;
sign_t   = flat_r - r_bore;                  // solid wall left behind a plaque
// Half the angle the plaque subtends, for the do-they-collide assert.
sign_ang = asin((sign_w / 2) / out_r);
// Half-angle of the wedge that backs it, taken at the cavity's inner radius
// because that is where the plaque covers the widest sweep.
sign_back_ang = asin(min(0.98, (sign_w / 2 + 1.0) / cav_ri));

// Does a flute cutter centred at angle t eat into the plaque's flat? The cutter
// is a circle of flute_cut_r at flute_off from the axis, so it reaches the
// plane x = flat_r only when the plane passes through it, and the chord it cuts
// there runs cy +/- h. If that chord reaches inside the plaque's width the
// flute takes a bite out of the corner of the flat.
//
// This is not hypothetical. Before the check went in on the 250 ml part, the
// flute at 30 degrees clipped both corners and left a flat 36.94 wide instead
// of 40.00 — 1.47 mm of side padding where 3.00 was specified. It is invisible
// in a render and shows up immediately in the mesh.
function flute_bite(t, clear) =
    let (cx = flute_off * cos(t),
         cy = flute_off * sin(t),
         d  = abs(cx - flat_r))
    d >= flute_cut_r ? false
    : let (h = sqrt(pow(flute_cut_r, 2) - pow(d, 2)))
      cy - h < sign_w / 2 + clear && cy + h > -(sign_w / 2 + clear);

// True if flute i bites any of the plaques.
function flute_bites(i) = sign_count == 0 ? false :
    len([for (j = [0 : sign_count - 1])
         if (flute_bite(i * 360 / flute_count - j * 360 / sign_count,
                        flute_clear)) 1]) > 0;

kept_flutes = flute_count == 0 ? []
            : [for (i = [0 : flute_count - 1]) if (!flute_bites(i)) i];

// Ribs: a circular arc rib_w wide at exactly rib_h proud of the bore.
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
assert(sign_count == 0 || art_w * crest_thin_frac >= 0.84,
       str("the crest's bars come out ", art_w * crest_thin_frac,
           " mm wide, under two 0.42 lines: raise art_w to at least ",
           0.84 / crest_thin_frac));
assert(sign_count == 0 || art_w * script_thin_frac + 2 * art_swell >= 0.84,
       str("the lettering's thin strokes come out ",
           art_w * script_thin_frac + 2 * art_swell,
           " mm wide, under two 0.42 lines: raise art_swell to at least ",
           (0.84 - art_w * script_thin_frac) / 2));
assert(sign_count == 0 || crest_round <= 0
       || art_w * crest_thin_frac - 2 * crest_round >= 0.20,
       str("crest_round pinches the crown's bars to ",
           art_w * crest_thin_frac - 2 * crest_round,
           " mm during its erode and they would be severed: keep it under ",
           (art_w * crest_thin_frac - 0.20) / 2));
assert(sign_count == 0 || art_swell < art_w * counter_budget_frac,
       str("art_swell has closed the lettering's counters: keep it under ",
           art_w * counter_budget_frac));
assert(art_mode == "emboss" || art_mode == "deboss",
       "art_mode is emboss or deboss");
assert(sign_count == 0
       || (sign_z0 - sign_sag > base_top_z && sign_z1 + sign_sag < total_h - top_cham),
       "the plaque and its bevels have run off the end of the barrel");

// Solid section of the holder, before the wall is hollowed out. Bottom inner
// corner first, running counter-clockwise: floor, base chamfer, barrel, top
// chamfer, rim, mouth lead-in, bore, floor again.
module holder_solid() {
    // Bottom edge: a cone from the bed up to base_tan, then the arc round to
    // vertical. Angles are measured at the arc's centre, 0 being the
    // tangent-to-vertical point and -base_over the handover to the cone. The
    // segment count comes off the same chord-error budget as everything else.
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

// The annular void between the two shells.
module cavity() {
    rotate_extrude(angle = 360, $fn = nseg)
        polygon([[cav_ri, cav_z0], [cav_ro, cav_z0],
                 [cav_ro, cav_z1], [cav_ri, cav_z1]]);
}

module webs() {
    // Half-pitch offset keeps a web off the y = 0 plane, so the "cut" view
    // shows the cavity rather than a web edge-on.
    for (i = [0 : web_count - 1])
        rotate([0, 0, (i + 0.5) * 360 / web_count])
            translate([0, -web_t / 2, 0])
                cube([out_r, web_t, total_h]);
}

// Full-height vertical cutters. Running them past both ends is what keeps the
// flutes free of ledges — they simply run off the chamfers.
module flutes() {
    n = facets(flute_cut_r);
    for (i = kept_flutes)
        rotate([0, 0, i * 360 / flute_count])
            translate([flute_off, 0, -eps])
                cylinder(r = flute_cut_r, h = total_h + 2 * eps, $fn = n);
}

// One plaque pocket per sign, as a meridian profile swept the width of the
// barrel. Read bottom to top: a 45-degree ramp up to the flat, the flat itself
// from sign_z0 to sign_z1, then a 45-degree ramp back out to the surface. Both
// ramps are sign_sag tall because that is what 45 degrees costs over sign_sag
// of depth, and the top one is the one that is not optional.
//
// Nothing bounds this in y and nothing needs to. Past the plaque's edge the
// plane x = flat_r is already outside the barrel, so the cut simply stops —
// which is what gives the plaque its straight sides and gabled ends.
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

// Solid behind each plaque, made by taking a wedge back out of the cavity over
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

// The crest on each plaque's floor. The mark is drawn flat in XY and has to
// end up on a plane facing +X, so the pair of turns maps its width onto +Y and
// its height onto +Z, leaving the extrusion running along +X:
//
//     rotate([0, 90, 0]) rotate([0, 0, 90])   (x, y, z) -> (z, x, y)
//
// It reads the right way round doing that, and the check is the same one the
// sibling makes for its finger: a viewer out at +X looking back at the origin
// has +Z up and +Y on their right, so the mark's own width runs left to right
// for them. Getting this wrong gives a mirrored logo that no render of the
// front face will show you — look at the -X side too.
//
// Embossed, the extrusion starts eps INSIDE the floor so the union has
// something to bite on rather than two coincident planes. Debossed, it starts
// eps OUTSIDE it for the same reason, and runs inward instead; the turns are
// identical either way, so the artwork cannot silently mirror between modes.
// Crest as drawn, lettering swelled, both on the LOCKUP's registration so they
// sit in the same relationship they have in the artwork. offset(r = ) rather
// than offset(delta = ): it is what the swell budget was measured with, and a
// rounded swell is kinder to a script's terminals than a mitred one, which
// would spike them.
module logo_art() {
    if (crest_round > 0)
        offset(r = -crest_round) offset(r = 2 * crest_round)
            offset(r = -crest_round) wagon_queen_crest(art_w);
    else
        wagon_queen_crest(art_w);
    offset(r = art_swell) wagon_queen_word(art_w);
}

module logo_marks() {
    x0 = art_mode == "deboss" ? flat_r + eps - art_relief : flat_r - eps;
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            translate([x0, 0, art_z])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    linear_extrude(height = art_relief + eps)
                        logo_art();
}

module ribs() {
    n = facets(rib_r);
    for (i = [0 : rib_count - 1])
        // Half-pitch off the webs, so a rib never lands on a web edge-on in
        // the cut view. Nothing structural depends on where they sit.
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
    // The ribs are unioned in BEFORE the cavity is cut, not after. Each rib is
    // a 3.90 mm arc and only 0.30 mm of it is wanted, so left to itself a rib
    // reaches 36.70 mm out — 5.40 mm into a cavity that is only 4.40 wide, so
    // it crosses the whole thing. Cutting the cavity last shaves them off flush
    // with the inner shell and gets the dead air back.
    difference() {
        union() {
            holder_solid();
            if (rib_count > 0 && rib_h > 0) ribs();
        }
        // The cavity less the webs is the set of pockets to hollow out. Doing
        // it in one subtraction beats hollowing and then unioning the webs back
        // in — that version dropped webs to boolean robustness failures on
        // slim-can-adapter.scad.
        difference() {
            cavity();
            webs();
            if (sign_count > 0) sign_backing();
        }
        if (flute_count > 0 && flute_depth > 0) flutes();
        if (sign_count > 0) sign_pockets();
    }
}

// The artwork goes on AFTER the plaque is cut, not before: it sits on the floor
// the pocket leaves, so it has to survive that cut either way round.
module slim_can_holder() {
    if (sign_count > 0 && art_relief > 0 && art_mode == "deboss")
        difference() { holder_body(); logo_marks(); }
    else
        union() {
            holder_body();
            if (sign_count > 0 && art_relief > 0) logo_marks();
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
echo(str("lockup ", art_w, " x ", art_h, " ", art_mode, "ed ", art_relief,
         ", against ", sign_sag, " of room"));
echo(str("crest rounded ", crest_round, "; bars pinch to ",
         art_w * crest_thin_frac - 2 * crest_round, " mid-round"));
echo(str("thinnest: crest bar ", art_w * crest_thin_frac,
         ", script thin ", art_w * script_thin_frac, " swelled to ",
         art_w * script_thin_frac + 2 * art_swell,
         " (floor 0.84); swell ", art_swell, " of a ",
         art_w * counter_budget_frac, " counter budget"));

// The fit coupon: the top coupon_h of the finished part, dropped onto the bed
// the same way up as the part itself. Taking it off the real thing rather than
// drawing a lookalike is deliberate — every number that could move the bore is
// then the number the part will print with.
module fit_coupon() {
    z0 = total_h - coupon_h;
    c  = coupon_relief + rib_h;          // 45 degrees, clearing the rib tips
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
