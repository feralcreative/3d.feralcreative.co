// Slim can holder — 3 inch outside, 355 ml / 12 oz sleek can inside.
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
// THE SIGNS. Four of them, at the cardinal points (Ziad, 2026-09-16): a
// bounded flat plaque milled into the barrel, not a flat side. Each is the artwork plus 3 mm of padding at the
// sides and the top — 33.50 wide by 65.50 tall — and nothing more, so the
// barrel above and below it is still round and still fluted. There is no
// padding at the bottom, because the wrist runs off that edge.
//
// WHY THE PLAQUE IS 3.90 DEEP, AND WHY IT HAS A BEVEL. Those two numbers are
// not choices, they are the barrel's radius. A 33.50 mm chord on a Ø76.20
// circle has a sagitta of 3.90 mm, so a flat that wide is 3.90 mm below the
// surface at its centre whatever else is done — and the plaque's ceiling is
// then a 3.90 mm shelf hanging over open air with nothing under its outer
// edge, which is not a bridge (two anchors) but a cantilever (one), and it
// would droop. Relieving it at 45 degrees fixes that, and a 45-degree relief
// across 3.90 mm of depth costs exactly 3.90 mm of height. So the plaque reads
// as a flat panel with a bevelled frame above and below, and the frame is that
// tall because the printer says so. Widen the artwork and all three numbers
// grow together; art_w is the one knob.
//
// ⚠️ FOUR OF THEM COSTS THE CAVITY, and that is the real price of the pair
// Ziad added. Each plaque's floor sits inside the annular cavity, so each one
// needs a solid wedge behind it, and sign_back_ang makes that wedge 69.1 wide
// — four of those leave only 20.9 degrees of cavity between them. Over the
// plaque's 75 mm of height the dead air goes from 138 degrees' worth to 276,
// which is about 27 cm3 of air turned into PETG.
//
// ⚠️ The wedge angle is the conservative one inherited from the 250 ml part,
// where it was sized at the cavity's INNER radius after a torus-shaped pocket
// got through a box-shaped block. Measured against this plaque it is roughly
// twice what the geometry needs — the pocket only reaches the cavity between
// radius 34.20 and 35.70, which subtends 16.5 degrees, not 34.55 — so most of
// that 27 cm3 is recoverable. It has not been touched, because the number that
// is too big is the one that fixed a real bug, and this was not the round to
// re-derive it in.
//
// ⚠️ WHICH IS WHY art_w CAME DOWN FROM 34.00, and it is a trade, not a tidy-up.
// A wider plaque is a deeper plaque, and a deeper plaque is a taller one once
// its two bevels are counted — so widening the artwork costs height twice over
// while the hand needs height once. At 34.00 the whole hand cannot be shown on
// this barrel at any art_z; at 27.50 it can, with 1.85 mm to spare at each end.
// The bill is a smaller hand and a shallower relief.
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
// The artwork comes from middle-finger-wrist-emboss.scad, which is where the
// mesh, the angles it is stood at and the 16 mm it is sliced to are all
// decided. This file gives it a width, a relief depth and a height to crop to,
// and nothing else. It was middle-finger-emboss.scad — the broad life-size
// fist — until 2026-09-16; that file and its mesh are untouched and still
// build, this one just does not use them.
//
// THE HAND DOES NOT FIT, AND IS NOT MEANT TO. The new relief is 2.40 times its
// own width where the old fist was 1.41, so at art_w it stands 81.65 tall
// against a plaque that cannot clear 62.61 on a 100 mm barrel — the top bevel
// has to stay under the fit coupon and the bottom one has to clear the base
// round.
//
// ⚠️ SO THE WIDTH GAVE WAY INSTEAD (Ziad, 2026-09-16: the very bottom of the
// hand should butt up against the bottom). Cropping was the first answer and
// it is the wrong one — at 34.00 wide, a quarter of the hand had to go. At
// 27.50 the whole relief fits, and all that is cut is the 8.05 mm at its very
// bottom where the forearm was squared off flat, which is not anatomy: it is
// the cut the other file made to stand the hand on a bed. The visible bottom
// of the hand is the plaque's bottom edge.
// So the plaque is NOT sized to the artwork any more, the way it was when the
// artwork was a fist and fitted: art_h is chosen, the hand hangs from its
// fingertip, and the forearm runs off the bottom edge.
//
// WHICH IS WHY THE WRIST ENDS AT AN ANGLE (Ziad, 2026-09-16). The plaque's
// bottom edge is the top of its 45-degree sill, so a square cut across the
// forearm there would leave the relief's end hanging art_relief proud over
// open air — a ledge, and a cut you can see. Clipping the artwork on the sill's
// own plane instead makes the two coplanar: the forearm tapers away at 45
// degrees and is swallowed by the frame, with nothing to support and no step.
// The cut plane is dropped eps below the sill so the union has an overlap to
// bite on rather than two coincident faces.
//
// ⚠️ THE RELIEF IS SQUASHED, and it has to be. At 27.5 mm wide a true-scale
// relief would stand 7.05 mm off the plaque floor, and the floor is only 3.90
// below the barrel — so at full scale the hand would break the 3 inch envelope
// this whole part exists to hold. art_relief is 2.90, which is 41% of scale
// depth and leaves 1.00 mm between the knuckles and the barrel's own surface.
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
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

// The artwork. middle-finger-wrist-emboss.scad owns the mesh, the angles it is
// stood at and the depth it is sliced to; this file only asks for it at a
// width, a relief depth and a crop height. standalone = false is what stops its
// own hand appearing at this part's origin — see the note on it over there.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <middle-finger-wrist-emboss.scad>
standalone = false;

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
// Cut in, never stood off, so the 3 inch maximum is untouched. Four of them
// is the cardinal points; see the two warnings in the header for what the
// second pair costs in cavity.
sign_count = 4;
// Clear space around the artwork (mm). This IS the plaque — its width is
// art_w + 2 x this, and it is no bigger than that. Its height is art_h + ONE
// of these, not two: there is padding above the fingertip and none below,
// because the forearm runs out of the bottom edge rather than stopping short
// of it.
sign_pad = 3.00;

/* [Panel art] */

// Width of the artwork, and with it the whole plaque (mm). Everything
// downstream is a consequence: the plaque is 6.00 wider, the flat is that much
// below the barrel surface (3.90 at 27.50), and the bevel that makes the flat
// printable is exactly as tall as the flat is deep. The height does NOT follow
// — see art_h.
//
// 27.50 IS SET BY THE HEIGHT, NOT BY TASTE. It is the widest the artwork can be
// and still show the whole hand: every millimetre of width adds 2.40 mm of
// hand and about 0.25 mm of bevel at each end, and the barrel has 77.00 mm
// between the top of the base round and the bottom of the fit coupon. 34.00
// was the old fist's width and it does not fit this hand; 28.00 fits with 1.1
// of margin; 27.50 fits with 1.85, which is where it sits.
art_w = 27.50;

// How much of the hand shows, from the plaque's bottom edge up to the
// fingertip (mm). The whole relief is 81.65 tall at this width and there is
// nowhere near room for it, so this is a crop, not a scale: the hand hangs
// from its fingertip and whatever falls below the plaque's bottom edge is cut
// off on the sill's own 45-degree plane.
//
// NOTHING OF THE HAND COMES OFF ANY MORE. The whole relief is 66.05 tall at
// this width and 62.50 of it shows; the 3.55 mm difference is not a crop of
// the drawing but of the squared-off end the other file cut to stand the hand
// on a bed — 8.05 mm of the relief's own 149.94, all of it below the wrist.
//
// It has to be cut, and it has to be cut by more than art_relief: a flat end
// left standing at the plaque's bottom edge would hang art_relief proud over
// the sill as a ledge. Cutting deeper than that hands the whole end to the
// 45-degree taper instead. There is an assert on it; the slack here is 0.65.
art_h = 62.50;

// Height of the centre of the artwork above the base (mm).
//
// 48.5 PUTS THE PLAQUE IN THE MIDDLE OF THE BARREL (Ziad, 2026-09-16: centre
// the plaques vertically), and it is derived, not fitted: total_h / 2 less
// half the padding, because the padding is all at the top. That lands the flat
// at 17.25..82.75, whose centre is 50.00, and the bevels at 13.35..86.65,
// whose centre is also 50.00 — the two coincide because the bevels are the
// same height at both ends, so there is only one way to centre this and no
// choice to make between the plaque and its frame.
//
// It is NOT the middle of the artwork. The hand's own centre sits at 48.5,
// 1.5 low, and that is correct: the plaque is what you see and the padding
// above the fingertip is part of it, so centring the drawing would push the
// frame high by the same 1.5.
//
// Re-derive it if total_h or sign_pad move. 55 with the old three-line block,
// 46 with the old fist, and 42.0 while the plaque was still being crammed in
// between the base round and the fit coupon.
art_z = total_h / 2 - sign_pad / 2;

// How far the relief stands proud of the plaque's floor (mm).
//
// ⚠️ It must stay under sign_sag, the 5.67 the flat is sunk below the barrel,
// or the artwork pokes out past the 3 inch maximum that is the whole point of
// this part. There is an assert on it.
//
// It is also not the scale depth. At art_w wide a true-scale relief would
// stand art_w * 16 / 62.43 = 7.05 proud, so finger_mark squashes the depth to
// this instead of scaling it with the width. Squashing depth is what a relief
// is; the alternative here is not a deeper relief, it is a part that is no
// longer 3 inches across.
art_relief = 2.90;

// How far the relief is sunk INTO the plaque's floor before it is unioned on
// (mm), so the two solids overlap instead of sharing a plane. It comes off the
// proud height: the hand stands art_relief - this, 2.80, off the floor.
//
// ⚠️ IT IS NOT eps, AND IT MATTERS. At eps = 0.01 the cut plane through the
// relief lands where the hand's own surface leaves its flat back tangentially,
// so the footprint pinches to a point at the widest part of the fist and CGAL
// answers with five zero-area triangles there — 4 pinch points on this part,
// 16 once there were four plaques, each an edge with 4, 6 or 10 faces on it
// instead of 2. OpenSCAD still calls the result manifold and a slicer would
// not care, but the mesh stops being a clean 2-manifold and that is a poor
// thing to hand anyone.
//
// 0.10 puts the cut far enough in that the footprint is a closed curve with
// room to spare, and the whole part comes back with every edge on exactly two
// triangles. Measured both ways, not reasoned: 16 bad edges at 0.01, none at
// 0.10.
art_sink = 0.10;

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
// rib at full height, which is plenty to feel.
//
// ⚠️ IT NO LONGER CLEARS THE PLAQUE, and it cannot. Centring the plaque put
// its upper bevel at 86.65, so a coupon that misses it has to be under 13.35
// and would leave about 1 mm of full-proud rib. The coupon is for the inside
// diameter and the outside is of no consequence (Ziad, 2026-09-16, settling
// the same question on the wagon queen sibling), so 18.00 stays and the
// coupon catches the top of a plaque. What that costs is a few sealed voids
// off the backing wedge and a negative genus on the coupon; what it buys is
// 7 mm of rib to push a can against. An echo in fit_coupon says so on every
// build.
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

// The whole relief at this width, which is taller than any plaque this barrel
// can carry — art_h is the crop, and this is what it is cropped from.
art_full_h = art_w * art_h_mm / art_w_mm;

// The plaque: sign_pad on the two sides and above, and nothing below, because
// the forearm runs out of the bottom edge. Its width fixes its depth: flat_r is
// where a chord sign_w long sits on a circle of out_r, and sign_sag is how far
// below the surface that is. The bevel that makes the top of it printable runs
// at 45 degrees, so it is sign_sag tall as well — the frame and the depth are
// the same number.
sign_w   = art_w + 2 * sign_pad;
sign_h   = art_h + sign_pad;
// Set against the INRADIUS of the barrel polygon, not the circle it is drawn
// in. An inscribed 97-gon runs 0.02 mm inside its circle, and taking the chord
// off the circle would have handed back a flat 39.92 wide where 40.00 was
// asked for — 2.96 of padding instead of 3.00. Off the inradius the flat is
// 40.00 at the polygon's flats and a hair over at its vertices, so the padding
// is never short.
flat_r   = sqrt(pow(out_r * cos(180 / nseg), 2) - pow(sign_w / 2, 2));
sign_sag = out_r - flat_r;
// art_z is the middle of the ARTWORK, so the bottom edge is half the artwork
// below it and the top edge is the padding above that. The plaque is not
// centred on art_z any more; it cannot be, with the padding all at one end.
sign_z0  = art_z - art_h / 2;
sign_z1  = sign_z0 + sign_h;
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
// Both of these are gaps between NEIGHBOURS, so they are written against the
// spacing rather than against 180. They were sign_ang * sign_count < 172 until
// sign_count went to 4, which is the same test at 2 plaques and a much weaker
// one at 4 — at 4 it would have allowed a 43-degree half-angle and a 4-degree
// gap while claiming to enforce 8.
assert(sign_count < 2 || 2 * sign_ang <= 360 / sign_count - 8,
       "the plaques have run into each other: reduce art_w or sign_count");
assert(sign_count < 2 || 2 * sign_back_ang <= 360 / sign_count - 8,
       "the backing wedges have met: the cavity between the plaques is gone");
assert(sign_count == 0 || art_sink < art_relief,
       "art_sink has swallowed the relief: the artwork is buried in the plaque floor");
assert(sign_count == 0 || art_relief < sign_sag,
       "the artwork stands out past the barrel: reduce art_relief or raise art_w");
assert(sign_count == 0 || art_h < art_full_h,
       "art_h is taller than the whole hand: there is no wrist left to cut, and the relief would float clear of the plaque's bottom edge");
assert(sign_count == 0 || art_full_h - art_h >= art_relief,
       "the cut at the bottom is shallower than the relief, so the relief's own squared end survives and hangs proud over the sill as a ledge: lower art_h by at least art_relief, or lower art_relief");
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

// The plaque's envelope as a solid, for clipping the artwork to it.
//
// The bottom face IS the plaque's lower bevel — the same 45-degree plane, one
// eps lower — and that is the whole trick: the forearm's cut end comes out
// coplanar with the sill it dies into, so there is no ledge, nothing to
// support, and no visible cut. The eps is there so the two overlap rather than
// coincide, and the overhanging sliver it leaves is buried in the solid barrel
// below the sill, never outside the part.
//
// Inboard of flat_r it is a plain slab rather than a continuation of the ramp,
// which matters: a ramp carried inboard would clip the relief's FOOTPRINT
// higher than its face and undercut the whole thing.
//
// The top is the upper bevel treated the same way. With the defaults it never
// bites — the fingertip stops sign_pad short of the plaque's top edge — and it
// is here so that raising art_h runs the hand off the top of the plaque
// cleanly instead of through it.
module plaque_envelope() {
    h   = 2 * outer_d;
    big = 4 * outer_d;
    pts = [
        [flat_r - 2, sign_z0 - eps],
        [flat_r,     sign_z0 - eps],
        [flat_r + h, sign_z0 - eps - h],
        [flat_r + h, sign_z1 + eps + h],
        [flat_r,     sign_z1 + eps],
        [flat_r - 2, sign_z1 + eps]
    ];
    translate([0, big / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = big) polygon(pts);
}

// The finger, standing off each plaque's floor. rotate([0, 0, -90]) turns the
// relief so its flat face lands on the plaque's plane and it stands outward:
// the artwork is built facing +Y and the plaque faces +X. It reads the right
// way round doing that — a viewer at +X has +Y on their right, a viewer at +Y
// has -X on theirs, and the turn carries one onto the other.
//
// HUNG FROM THE FINGERTIP, NOT CENTRED. The relief is art_full_h tall and only
// art_h of it fits, so it is placed by its top edge — the tip lands sign_pad
// below the plaque's top — and then clipped. Centring it would crop the tip as
// well, and the tip is the point of the gesture.
//
// Sunk art_sink into the floor so the union has something to bite on rather
// than two coincident planes — and sunk that far rather than eps for a reason
// the parameter's own note gives.
module finger_marks() {
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            intersection() {
                translate([flat_r - art_sink, 0,
                           sign_z1 - sign_pad - art_full_h / 2])
                    rotate([0, 0, -90])
                        finger_mark(art_w, art_relief);
                plaque_envelope();
            }
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

module slim_can_holder() {
    union() {
        holder_body();
        // The artwork goes on AFTER the plaque is cut, not before: it stands
        // out of the floor the pocket leaves, so it has to survive that cut.
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
echo(str("artwork ", art_w, " x ", art_h, " standing ", art_relief - art_sink,
         " proud, against ", sign_sag, " of room",
         "  (cropped from ", art_full_h, ", so ", art_full_h - art_h,
         " of forearm runs off the bottom edge at 45 degrees)"));

// The fit coupon: the top coupon_h of the finished part, dropped onto the bed
// the same way up as the part itself. Taking it off the real thing rather than
// drawing a lookalike is deliberate — every number that could move the bore is
// then the number the part will print with.
module fit_coupon() {
    z0 = total_h - coupon_h;
    c  = coupon_relief + rib_h;          // 45 degrees, clearing the rib tips
    // Catching the plaque is a fact about the coupon, not a fault in it — see
    // the warning on coupon_h. This was an assert until the plaques were
    // centred, at which point there was no coupon_h that both clears them and
    // leaves any rib to feel.
    if (sign_count > 0 && z0 <= sign_z1 + sign_sag)
        echo(str("coupon note: it catches a plaque — bevel top ",
                 sign_z1 + sign_sag, ", coupon floor ", z0,
                 ". Expect sealed voids off the backing wedge and a negative",
                 " genus, both harmless. coupon_h under ",
                 total_h - (sign_z1 + sign_sag),
                 " would miss it, at about 1 mm of full-proud rib"));
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



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_5c2789e183ba() {
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

module feral_assembly_view_5c2789e183ba(explode=false) {
feral_default_output_5c2789e183ba();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_5c2789e183ba();
else feral_assembly_view_5c2789e183ba(view == "exploded");
