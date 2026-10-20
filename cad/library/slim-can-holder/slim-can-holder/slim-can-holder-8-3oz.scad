// Slim can holder — 3 inch outside, 250 ml Red Bull can inside.
//
// A new part, not a recreation. The three fixed requirements are the outside
// diameter (76.20 mm, exactly 3"), the bore (a 250 ml Red Bull sleek can, Ø53),
// and a floor of at least 5 mm. Everything else below follows from those.
//
// THE PROBLEM THOSE THREE NUMBERS CREATE. 76.20 outside against 53 inside is
// 11.10 mm of radius to fill. Drawn as a solid that is about 340 cm3 of
// envelope for the slicer to pack, which is a long print and a heavy part for
// no gain. So it is drawn the same way slim-can-adapter.scad is: an inner tube
// around the can, an outer cylinder at the finished size, a sealed annular
// cavity between them, and radial webs tying the two together. The dead air in
// that gap is what makes it a koozie rather than a lump.
//
// THE OUTSIDE. Twenty-four shallow vertical flutes, cut into the 76.20 circle
// rather than added to it, so the maximum diameter stays exactly 3". They earn
// their place three ways: grip on a wet hand, they hide layer lines on a plain
// cylinder, and every one of them is a vertical cut that costs no support.
// Set flute_count or flute_depth to 0 for a plain barrel.
//
// THE SIGNS. Two of them, 180 degrees apart: a bounded flat plaque milled into
// the barrel, not a flat side. Each is exactly the three-line block plus 3 mm
// of padding all round — 40.00 wide by about 31.4 tall — and nothing more, so
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
// tall because the printer says so. Widen the type and all three numbers grow
// together; text_w is the one knob.
//
// The left and right edges need no such treatment: the flat simply runs out
// where its plane meets the barrel, which is why the plaque has straight sides
// and gabled ends rather than four square corners.
//
// THE WORDING. Three lines, debossed 0.70 deep, justified flush left AND flush
// right — and justified by SIZE, not by tracking, so every line is the same
// typeface at its own scale rather than the same scale spaced out. The widest
// line sets the smallest type: RED BULL is 23% wider than ZAMIL’S at a common
// size, so it lands at 81% of its size. `wording` switches the second line
// between the explicit and the censored build.
//
// ⚠️ The two builds are NOT dimensionally identical. F@#KING is wider than
// FUCKING, so it justifies to a smaller size and a shorter line, and since the
// plaque is the block plus a fixed 3 mm the censored plaque comes out 0.45 mm
// shorter. The padding is what is held constant, not the plaque.
//
// HOW THE JUSTIFICATION IS DONE. OpenSCAD cannot measure a string at render
// time unless it is run with --enable=textmetrics, an experimental flag that
// utils/render.sh and utils/build.sh do not pass and should not have to. So the
// ink boxes are MEASURED ONCE and recorded in ink() below, exactly the way the
// stubby records its section fits. Re-measure with:
//
//     openscad --enable=textmetrics -o /dev/null --export-format asciistl f.scad
//
// where f.scad echoes textmetrics(s, size = 100, font = text_font) for each
// string. Any string not in the table fails an assert rather than going quietly
// unjustified.
//
// THE FIT — CONFIRMED. The bore is drawn generous and six rounded ribs take the
// slack back up. Drawn 54.00, printed 53.77, 53.17 across the ribs, and a real
// 250 ml can goes in snug and comes out without a fight. Measured off the fit
// coupon on 2026-08-22; see bore_comp and [Grip ribs] before changing either
// number, because they were sized against each other.
//
// ORIENTATION. Printed floor-down, z = 0 at the underside. The only overhang in
// the part is the roof over the annular cavity, a 6.60 mm bridge broken into
// eight short pockets by the webs. Nothing here needs support.
//
// ⚠️ The can is 134 mm tall and this is 100, so 34 mm stands proud. That is
// deliberate — it is what you grab and what you drink from. total_h is a
// parameter if that is wrong.

// The one thing a coupon can answer here, and the variant that puts it on a
// plate. There is only one, so the plate and the component are the same
// variant; utils/coupon.sh reads these directives and needs no knowledge of
// this part. Keep the names stable.
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Output] */

// "cut" is a half-section for reading the double wall, the cavity and the ribs.
// Not for printing — build it with --name if you want it as its own STL.
// "coupon" is the fit test; see [Fit coupon].
show = "part";   // [part, cut, coupon]

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a 250 ml slim can (mm). Red Bull's 250 ml sleek can.
can_d = 53.0;
// Clearance on diameter at the bore itself (mm). The ribs, not this, set the
// grip — this only has to let the can pass.
can_slop = 0.40;
// Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
//
// SETTLED, 2026-08-22, by the fit coupon. A bore drawn at 54.00 miked 53.77
// between the ribs — a loss of 0.23 on diameter. Ziad pushed a real 250 ml can
// in: "fits perfectly, snug enough but not difficult".
//
// That closes an argument that had been open since this part was started. The
// design reference predicted +0.15 would cover it. The slicing reference
// refuted that from a bore drawn at 10.15 that miked 9.5–9.6, a loss of
// 0.55–0.65, which would have put this bore at 53.40. The stubby recorded 0.27
// off a Ø54 bore. The stubby was right and the slicing reference does not
// generalise: 0.23 on Ø54 against 0.60 on Ø10 is not one effect at two sizes.
// A fixed loss would have taken 0.60 off here and did not; a proportional loss
// would have taken 0.04 off the 10 mm bore and did not. The small-bore figure
// is first-layer squish and extrusion pull-in — local, and roughly constant in
// absolute terms — and it must not be applied to a bore of this size.
//
// ⚠️ Do NOT "correct" this number to the measured 0.23. 0.60 is what produced a
// bore that fits, and the ribs were sized against it. The two are a matched
// pair; changing one without the other opens the fit back up.
bore_comp = 0.60;

/* [Shell] */

// Outside diameter (mm). 76.20 is 3 inches, and it is the whole point of the
// part — this is the number to leave alone.
outer_d = 76.20;
// Overall height (mm). The can is 134, so this leaves 34 mm proud.
total_h = 100.0;
// Inner shell, the tube around the can (mm). 2.10 is 5 walls at 0.42.
inner_w = 2.10;
// Outer shell at the top of a flute — the flats, not the valleys (mm). 2.40 is
// thicker than the inner shell on purpose: the flutes eat into it.
outer_w = 2.40;
// Roof over the annular cavity (mm). 1.60 is 8 layers at 0.20, bridging 6.60.
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
sign_count = 2;
// Clear space around the type, on all four sides (mm). This IS the plaque —
// its width is text_w + 2 x this, its height is the block + 2 x this, and it
// is no bigger than that in either direction.
sign_pad = 3.00;

/* [Panel text] */

// Width of the type, and with it the whole plaque (mm). Everything downstream
// is a consequence: the plaque is 6.00 wider, the flat is that much below the
// barrel surface (5.67 at 34.00), and the bevel that makes the flat printable
// is exactly as tall as the flat is deep. Raise it for bigger lettering and a
// deeper, more heavily framed plaque; drop it for the reverse.
text_w = 34.00;

// Which build. The two are identical but for the second line.
wording = "explicit";   // [explicit, censored]

// Heavy and condensed on purpose. Condensed buys type size — justification
// pins the width, so a narrower face is a taller line — and Black gives a
// 1.9 mm stem at these sizes, which is four passes of a 0.4 nozzle.
// Alternatives measured on this machine: "Impact", "Arial Black",
// "Futura:style=Condensed ExtraBold", "DIN Condensed:style=Bold".
// ⚠️ Changing this invalidates every number in ink(). Re-measure.
text_font = "Helvetica Neue:style=Condensed Black";
// Gap between lines (mm). The only free vertical dimension — the line heights
// themselves are consequences of the justification.
line_gap = 2.00;
// Height of the centre of the three-line block above the base (mm). A little
// over half, because the eye reads a block on a cylinder as low when it is
// geometrically centred.
text_z = 55.0;
// How deep the letters are cut (mm).
deboss_d = 0.70;

// Wall angle of the cut, from horizontal — the same treatment as the chalk
// holder's wordmark, and for the same reason.
//
// The plaque is a vertical wall and the part prints upright, so a prismatic cut
// leaves a horizontal roof over the top edge of every stroke: the wall has to
// reach back in by the full depth with nothing under it. At 0.40 that is a
// ledge you get away with. At 0.70 it is marginal, and a slicer's answer to
// marginal is support material inside the lettering, which then has to be
// picked out of a 0.70 mm deep letter.
//
// Sloping every face removes the roof entirely. The cost is stroke width: the
// cut narrows as it deepens, so the deepest section is the artwork eroded by
// depth / tan(angle). 90 is prismatic — no taper. 45 is the classic
// self-supporting chamfer and costs 1.00 mm per mm of depth. 70 is still 20
// degrees off vertical, well inside what prints unsupported, and costs 0.36.
// Measured off the built mesh: the floor of the cut comes out 0.408 narrower
// than the opening, so each edge loses 0.204. Against stems of roughly 1.7 to
// 2.1 mm at these sizes that leaves about 1.3 at the narrowest — three passes
// of a 0.4 nozzle, and the opening is still full width where it is read.
deboss_taper = 70;   // (deg from horizontal)

// The taper is a stack of prismatic bands, not a true draft, because
// linear_extrude cannot loft between two offsets of a 2D shape. What each band
// leaves is a horizontal ledge as deep as the band, so 5 over 0.70 gives 0.14 mm
// ledges — below one layer, and invisible.
//
// Unlike the chalk holder this is a flat cut and not a cylindrical wrap, so the
// bands are cheap and there is no faceting mismatch to overlap away. eps is
// enough here.
deboss_steps = 5;

/* [Grip ribs] */

// Rounded vertical ribs inside the bore, so the can is held rather than
// rattling, without shrinking the bore itself. Set rib_count or rib_h to 0 for
// a plain slip fit.
//
// THE ARITHMETIC, now measured rather than predicted. Two ribs sit across any
// diameter, so the working size is (printed bore) - 2 x rib_h, and the printed
// bore is 53.77 — see bore_comp for how that was established.
//
//     rib_h 0.20  ->  53.37   0.37 clearance on a Ø53 can
//     rib_h 0.30  ->  53.17   0.17 clearance   <- printed, and it fits
//     rib_h 0.40  ->  52.97   0.03 interference
//     rib_h 0.50  ->  52.77   0.23 interference
//
// 0.30 was chosen when the printed bore could have been anything from 53.40 to
// 53.70, on the grounds that it was the only value that was at worst a firm
// push and at worst a light rattle. It landed at 0.17 of clearance and Ziad
// called it snug but not difficult, so it stays. Go to 0.40 only if a future
// can measures under Ø53, and sand rather than reprint.
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
// Height (mm). The budget from the top down: 2.00 of mouth chamfer, 1.00 of
// clearance, 8.00 of rib ramp and then full-proud rib. 18.00 leaves 7 mm of
// rib at full height, which is plenty to feel, and clears the top of the plaque
// at z 76.42 by 1.58.
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

// Ink boxes, measured once at size = 100 in text_font. [position, size], both
// in the units text() itself uses, so a line set at size S has ink S/100 times
// these. position is the bottom-left of the ink relative to the pen, which is
// why it is needed as well as the size: it is what centres a line on the panel
// by its INK rather than by its advance width, and flush edges are the whole
// point here.
function ink(s) =
    s == "ZAMIL’S"  ? [[2.752, -1.536], [441.856, 102.656]] :
    s == "FUCKING"  ? [[6.080, -1.536], [480.918, 102.656]] :
    s == "F@#KING"  ? [[6.080, -1.536], [512.446, 102.656]] :
    s == "RED BULL" ? [[6.080, -1.536], [543.978, 100.672]] :
    undef;

lines    = ["ZAMIL’S", wording == "censored" ? "F@#KING" : "FUCKING", "RED BULL"];

// Justify by size: each line is scaled until its ink is exactly text_w wide.
// Its height is then a consequence, not a choice.
sizes    = [for (l = lines) text_w * 100 / ink(l)[1][0]];
heights  = [for (i = [0 : len(lines) - 1]) ink(lines[i])[1][1] * sizes[i] / 100];
function hsum(v, i) = i <= 0 ? 0 : v[i - 1] + hsum(v, i - 1);
block_h  = hsum(heights, len(heights)) + (len(lines) - 1) * line_gap;
// Bottom of line i's ink, measured from the bottom of the block. Line 0 is top.
function ink_z(i) = block_h - hsum(heights, i + 1) - i * line_gap;

// The plaque, which is the block plus sign_pad on all four sides and nothing
// else. Its width fixes its depth: flat_r is where a chord sign_w long sits on
// a circle of out_r, and sign_sag is how far below the surface that is. The
// bevel that makes the top of it printable runs at 45 degrees, so it is
// sign_sag tall as well — the frame and the depth are the same number.
sign_w   = text_w + 2 * sign_pad;
sign_h   = block_h + 2 * sign_pad;
// Set against the INRADIUS of the barrel polygon, not the circle it is drawn
// in. An inscribed 97-gon runs 0.02 mm inside its circle, and taking the chord
// off the circle would have handed back a flat 39.92 wide where 40.00 was
// asked for — 2.96 of padding instead of 3.00. Off the inradius the flat is
// 40.00 at the polygon's flats and a hair over at its vertices, so the padding
// is never short.
flat_r   = sqrt(pow(out_r * cos(180 / nseg), 2) - pow(sign_w / 2, 2));
sign_sag = out_r - flat_r;
sign_z0  = text_z - sign_h / 2;
sign_z1  = text_z + sign_h / 2;
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
// This is not hypothetical. Before the check went in, the flute at 30 degrees
// clipped both corners and left a flat 36.94 wide instead of 40.00 — 1.47 mm of
// side padding where 3.00 was specified. It is invisible in a render and shows
// up immediately in the mesh.
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
       "the annular cavity has collapsed: reduce inner_w or outer_w");
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
       "a plaque has to be cut IN: text_w + 2 x sign_pad must be under outer_d");
assert(sign_count == 0 || sign_t - deboss_d >= 2.10,
       "too little wall left behind the plaque: reduce text_w");
assert(sign_count < 2 || sign_ang * sign_count < 180 - 8,
       "the plaques have run into each other: reduce text_w or sign_count");
assert(sign_count < 2 || sign_back_ang * sign_count < 180 - 8,
       "the backing wedges have met: the cavity between the plaques is gone");
assert(sign_count == 0 || len([for (l = lines) if (is_undef(ink(l))) l]) == 0,
       "a line has no measured ink box: re-measure it into ink() (see header)");
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
// the plaque's height. The plaque floor sits at 32.43 and the cavity runs
// 29.10 to 35.70, so the pocket lands inside the cavity and something has to
// give — this is the something.
//
// IT HAS TO BE A WEDGE, NOT A BOX. A box spanning |y| <= 21 and x >= cav_ri - 1
// looks like it covers the sector and does not: the cavity's inner corner where
// it meets a web at 22.5 degrees sits at x = 26.88, inboard of the box, so a
// 1.2 mm sliver of cavity squeaked past the block and ran the full height. The
// pocket behind each plaque came out as a TORUS rather than being severed —
// caught by counting shells in the mesh, where two pockets reported genus 1,
// and invisible in every render. A wedge from the axis has no such corner.
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

// The three-line block as 2D, centred on the origin. Each line is placed by its
// measured ink box, not by halign/valign — halign centres on the advance width,
// which includes the right side bearing and would leave the flush right edge
// short by a fraction of a stem.
module wordmark() {
    for (i = [0 : len(lines) - 1]) {
        m = ink(lines[i]);
        k = sizes[i] / 100;
        translate([-(m[0][0] + m[1][0] / 2) * k,
                   ink_z(i) - m[0][1] * k - block_h / 2])
            // No $fn here on purpose — the file's $fa/$fs govern, so a bowl
            // on a 9 mm cap and one on a 7 mm cap get the same chord error
            // instead of the same segment count.
            text(lines[i], size = sizes[i], font = text_font,
                 halign = "left", valign = "baseline");
    }
}

// Extruded outward through the panel face. rotate([90, 0, 90]) sends the 2D x
// axis to +Y and the 2D y axis to +Z, which is exactly how the text reads to
// someone standing at +X — no mirroring needed, and getting that backwards is
// the classic way to emboss a part in reverse.
//
// The stack runs from the plaque surface inward, band 0 outermost. Erosion is
// taken from each band's OUTER face, so band 0 is the artwork at full size and
// the letters read their true width from outside — eroding by the inner figure
// instead would thin the visible outline and bury the widest part of the cut
// where nobody can see it. It also means the flush left and right edges are
// still exactly text_w apart at the surface, which is where they are measured.
module text_cutters() {
    steps = deboss_taper >= 90 ? 1 : max(1, deboss_steps);
    band  = deboss_d / steps;
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            for (k = [0 : steps - 1]) {
                erode = deboss_taper >= 90 ? 0
                                           : (band * k) / tan(deboss_taper);
                translate([flat_r - band * (k + 1), 0, text_z])
                    rotate([90, 0, 90])
                        // Every band reaches eps outward into its neighbour —
                        // band 0 out past the plaque surface, the rest into the
                        // band above — so no two bands meet on a shared plane.
                        linear_extrude(height = band + eps)
                            offset(delta = -erode) wordmark();
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

module slim_can_holder() {
    // The ribs are unioned in BEFORE the cavity is cut, not after. Each rib is
    // a 3.90 mm arc and only 0.30 mm of it is wanted, so left to itself a rib
    // reaches 34.50 mm out — 5.40 mm into the cavity, six times over. Cutting
    // the cavity last shaves them off flush with the inner shell and gets the
    // dead air back.
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
        if (sign_count > 0 && deboss_d > 0) text_cutters();
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
echo(str("wording=", wording, "  plaque ", sign_w, " x ", sign_h,
         "  deep ", sign_sag, " (= bevel height)  wall behind ", sign_t,
         "  z ", sign_z0, "..", sign_z1,
         "  overall with bevels ", sign_h + 2 * sign_sag));
for (i = [0 : len(lines) - 1])
    echo(str("  line ", i, "  \"", lines[i], "\"  size ", sizes[i],
             "  cap ", heights[i]));

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
