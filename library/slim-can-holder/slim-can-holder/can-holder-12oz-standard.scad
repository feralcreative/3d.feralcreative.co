// Can holder — standard 355 ml / 12 oz can, with glue-in logo tiles.
//
// Started as a copy of slim-can-holder-3in-12oz-wagon-queen.scad rebored for
// the squat can, and it is now generic: no artwork is modelled on the barrel.
// Each of the four plaques is an empty rectangular pocket, and the logo is
// printed flat on a separate tile (show = "tile") and glued in. Printing a
// logo flat puts its face on the top of the print instead of on a vertical
// wall, which is the whole reason for doing it this way.
//
// Two rings drop into the bore and stack, one inside the other:
//
//     slim-can-adapter-ring-12oz-standard-to-slim.scad   standard -> slim 12 oz
//     slim-can-adapter-ring-12oz-to-8-3oz-nested.scad    slim 12 oz -> 8.3 oz
//
// THE CAN. Ø66.04 x 122.2 — the standard 12 oz body, 2.60 in. A 211 can code
// is the seam, not the body.
//
// THE OUTSIDE IS NOT 3 INCHES (Ziad, 2026-10-18). On a 76.20 barrel this bore
// leaves 4.6 mm of wall: no cavity, and no depth for a pocket. So the WALL was
// held instead of the outside — 8.90 mm on radius, the 3 in sibling's exactly
// — and the outside grew by the 8.64 the can grew: 76.20 -> 84.84. The
// cavity, the shells, the roof, the webs, the floor, the flutes and the ribs
// are all the sibling's numbers. It will not fit a 3 in cupholder.
//
// THE POCKET. A flat floor tile_t below the plane where the barrel meets a
// pocket_w chord, with vertical side walls and 45-degree ends. The tile is
// tile_t thick, so it sits flush with the barrel at its two side edges and
// sign_sag below it in the middle — the same flat-panel look the moulded
// plaques had. The ends are 45 degrees and not square for the reason the
// sibling's header gives: a square top to the pocket is a cantilevered
// ceiling with nothing under its outer edge. The tile carries a matching 45
// degree chamfer on both ends, so it fills the pocket to its own face.
//
// ⚠️ THE LOGO'S HEIGHT BUDGET TAPERS ACROSS THE TILE. The barrel curves away
// over a flat face, so a logo standing h proud stays inside the 84.84 circle
// only where |y| <= sqrt(out_r^2 - (flat_r + h)^2): at 2.00 proud that is
// ±10.6 of the tile's 32.6 width. The echo prints it. Past that the logo
// stands outside the barrel, which is harmless in a hand and matters only if
// the outside diameter does.
//
// THE FIT — INHERITED, NOT CONFIRMED. bore_comp 0.60 and rib_h 0.30 carry
// over unchanged on the sibling's argument that this machine's bore loss is
// constant in absolute terms: printed bore 66.81, 66.21 across the ribs, 0.17
// clearance on a 66.04 can. Print [Fit coupon] before the part. The tile's
// clearance is not proven either; print one tile with the coupon.
//
// ORIENTATION. Holder floor-down; nothing needs support. Tile back-down, logo
// up; its chamfered ends are 45-degree overhangs.
//
// The can is 122 tall and this is 100, so 22 mm stands proud.

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
// "tile" is one blank logo tile, as printed. "assembly" is the holder with a
// tile in every pocket — preview only, never an STL.
show = "part";   // [part, cut, coupon, tile, assembly]

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a standard 355 ml / 12 oz can (mm), 2.60 in.
//
// outer_d is derived from this, so the wall, the cavity and the plaque depth
// hold still if it changes; only the outside and the rib clearance move.
can_d = 66.04;
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

// Radial wall from bore to outside (mm). 8.90 is the 3 in sibling's, (76.20 -
// 58.40) / 2, and holding it is what keeps every shell, cavity and plaque
// number of that part valid here. See THE OUTSIDE in the header.
wall_r = 8.90;
// Outside diameter (mm): 84.84 at the defaults.
outer_d = can_d + can_slop + bore_comp + 2 * wall_r;
// Overall height (mm). The can is 122, so this leaves 22 mm proud.
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

/* [Pockets] */

// Rectangular pockets milled into the barrel, one per tile, evenly spaced.
// Cut in, never stood off, so the outside diameter is untouched.
sign_count = 4;
// Width of a pocket round the barrel, at its floor (mm). The sibling's plaque
// was 33.00 — 27.00 of artwork and 3.00 of padding a side — and this keeps
// it. Wider sinks the middle deeper, as the square of the width.
pocket_w = 33.00;
// Height of a pocket's floor along the barrel (mm), not counting the
// 45-degree ends. The ends add tile_t + sign_sag each.
pocket_h = 64.00;
// Height of the centre of the pocket above the base (mm). Centred on the
// barrel, as the sibling's plaques were (Ziad, 2026-09-16).
pocket_z = total_h / 2;

/* [Tile] */

// Thickness of a tile, and so the depth of the pocket at its side edges (mm).
// 2.00 is 10 layers at 0.20. Bounded from above by the wall it leaves over
// the bore — there is an assert at 2.10 — and from below by having something
// to glue.
tile_t = 2.00;
// Clearance per side between tile and pocket (mm). Measured square to each
// face, so the chamfered ends get the same gap as the sides. It is the glue
// gap; it is not a proven fit.
tile_clear = 0.20;

/* [Colors] */

// Preview only. STLs carry no colour.
holder_color = "MediumPurple";
tile_color   = "Gold";

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
// pushed into it before committing to a six-hour print.
//
// IT IS FOR THE INSIDE DIAMETER AND NOTHING ELSE (Ziad, 2026-09-16). What the
// outside of the coupon looks like is of no consequence — it is not a
// presentation piece and nobody is judging its plaques.
//
// It is still a genuine slice of the barrel rather than a bare tube, and that
// is not about appearance: the inner shell, cavity, webs and outer shell are
// what decide whether the bore comes out round and on size, so a bare tube
// would not answer the same question. Including a plaque is if anything BETTER
// than avoiding one, because a plaque replaces 4.40 mm of cavity with 5.79 mm
// of solid wall behind the bore, and that asymmetry is exactly the kind of
// thing that pulls a bore out of round.
//
// ⚠️ PRINT THIS ONE FIRST. On the 250 ml part the coupon confirmed a bore that
// had already been reasoned out. Here it is also the only thing that will tell
// you whether Ø57.40 is the can you actually have.
//
// Height (mm). The budget from the top down: 2.00 of mouth chamfer, 1.00 of
// clearance, 8.00 of rib ramp and then full-proud rib.
//
// That budget says 7.00 mm of full-proud rib and the mesh says 6.11: the
// coupon_relief cone eats the first 0.90 mm of the bore, so the rib is at full
// height from z 0.90 to 7.01. Still plenty to feel, and the 7.00 in the
// inherited comment was never measured. The tightest point across the bore
// measures 57.80, which is bore_d less twice rib_h exactly.
//
// It went 18.00 -> 17.50 -> 16.50 and back on 2026-09-16, chasing a constraint
// that does not exist. Centring the plaque put its bevel at 82.03 and its
// backing wedge at 83.03, and the coupon was shortened twice to stay clear of
// both — on the assumption that the coupon had to be a plain barrel section.
// It does not: the outside is of no consequence, so the coupon is free to
// contain as much plaque as the height happens to catch. 18.00 restored.
//
// What that episode DID leave behind is worth keeping: sign_back_z1, a name
// for the fact that a plaque reaches 1.0 mm further up the barrel than its
// bevel does, because sign_backing runs long at both ends. The echo below
// reports whether the coupon catches any of it, so it is legible in the log
// rather than a surprise in the mesh — a coupon that contains wedge tops
// reports a negative genus, since they subdivide its cavity into sealed
// pockets. That is now information, not an error.
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

// The pocket. flat_r is where a chord pocket_w long sits on the barrel: the
// plane of the tile's face, flush with the barrel at the tile's two edges.
// sign_sag is how far below the surface that plane is in the middle, and the
// floor is a tile thickness below it. The 45-degree ends run from the floor
// to the surface, so they are sign_bev tall.
//
// Set against the INRADIUS of the barrel polygon, not the circle it is drawn
// in — see the sibling for why; the short version is that it keeps the tile's
// edges from standing a hair proud at the polygon's flats.
sign_w   = pocket_w;
flat_r   = sqrt(pow(out_r * cos(180 / nseg), 2) - pow(sign_w / 2, 2));
sign_sag = out_r - flat_r;
floor_r  = flat_r - tile_t;
sign_bev = out_r - floor_r;
sign_z0  = pocket_z - pocket_h / 2;
sign_z1  = pocket_z + pocket_h / 2;
sign_t   = floor_r - r_bore;                 // solid wall left behind a pocket
// The top of the BACKING WEDGE, 1.0 mm past the pocket's upper end; see
// sign_backing. It is the highest thing a pocket puts into the barrel.
sign_back_z1 = sign_z1 + sign_bev + 1.0;
// Half the angle the pocket subtends, for the do-they-collide assert.
sign_ang = asin((sign_w / 2) / out_r);
// Half-angle of the wedge that backs it, taken at the cavity's inner radius
// because that is where the pocket covers the widest sweep.
sign_back_ang = asin(min(0.98, (sign_w / 2 + 1.0) / cav_ri));

// The tile, as drawn: tile_clear off every face of the pocket. On the
// 45-degree ends a square gap of c is c x sqrt(2) measured along the barrel.
tile_w  = pocket_w - 2 * tile_clear;
tile_hb = pocket_h - 2 * tile_clear * sqrt(2);   // back face, glued down
tile_hf = tile_hb + 2 * tile_t;                   // front face, logo side

// Half-width of the tile over which a logo h proud stays inside the barrel.
function logo_room(h) = sqrt(max(0, pow(out_r, 2) - pow(flat_r + h, 2)));

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
       "a pocket has to be cut IN: pocket_w must be under outer_d");
assert(sign_count == 0 || sign_t >= 2.10,
       "too little wall left behind the pocket: reduce pocket_w or tile_t");
assert(sign_count < 2 || sign_ang * sign_count < 180 - 8,
       "the pockets have run into each other: reduce pocket_w or sign_count");
assert(sign_count < 2 || sign_back_ang * sign_count < 180 - 8,
       "the backing wedges have met: the cavity between the plaques is gone");
assert(tile_clear >= 0 && tile_hb > 0,
       "the tile has no back face: reduce tile_clear or raise pocket_h");
assert(sign_count == 0
       || (sign_z0 - sign_bev > base_top_z && sign_z1 + sign_bev < total_h - top_cham),
       "the pocket and its ends have run off the end of the barrel");

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

// One pocket per tile, as a meridian profile swept pocket_w wide. Read bottom
// to top: a 45-degree ramp in from the surface to the floor, the floor itself
// from sign_z0 to sign_z1, then a 45-degree ramp back out. Both ramps are
// sign_bev tall because that is what 45 degrees costs over that depth, and the
// top one is the one that is not optional.
//
// Unlike the sibling's plaques this IS bounded in y. Its floor is a tile below
// the chord plane, and that deeper plane meets the barrel wider than pocket_w,
// so an unbounded cut would run out past the tile's edges. Bounded, the sides
// are vertical walls exactly tile_t deep at the barrel: the tile's edges land
// flush.
module sign_pockets() {
    big = 4 * outer_d;
    pts = [
        [out_r,   sign_z0 - sign_bev],
        [big,     sign_z0 - sign_bev],
        [big,     sign_z1 + sign_bev],
        [out_r,   sign_z1 + sign_bev],
        [floor_r, sign_z1],
        [floor_r, sign_z0]
    ];
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            rotate([90, 0, 0])
                linear_extrude(height = sign_w, center = true) polygon(pts);
}

// Solid behind each pocket, made by taking a wedge back out of the cavity over
// the pocket's height. The pocket floor sits at 37.06 and the cavity runs
// 35.62 to 40.02, so the pocket lands inside the cavity and something has to
// give — this is the something.
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
            translate([0, 0, sign_z0 - sign_bev - 1.0])
                linear_extrude(height = pocket_h + 2 * sign_bev + 2.0)
                    polygon(wedge);
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

module can_holder() color(holder_color) holder_body();

// One tile as printed: back on the bed at z = 0, logo face up at z = tile_t.
// X runs round the barrel, Y along it. The ends are chamfered at 45 degrees to
// match the pocket's, which makes the tile wider at its face than at its back
// — so the chamfers are 45-degree overhangs in print, and nothing worse.
//
// Put a logo on it by unioning onto the face at z = tile_t, centred on the
// origin. See THE LOGO'S HEIGHT BUDGET in the header for how far it can
// stand proud, and where.
module tile() color(tile_color)
    hull() {
        translate([-tile_w / 2, -tile_hb / 2, 0])
            cube([tile_w, tile_hb, eps]);
        translate([-tile_w / 2, -tile_hf / 2, tile_t - eps])
            cube([tile_w, tile_hf, eps]);
    }

// A tile seated in every pocket, back on the floor. The turns map the tile's
// (x, y, z) onto the barrel's (y, z, x): width round it, height along it,
// thickness outward.
module tiles_seated() {
    for (i = [0 : sign_count - 1])
        rotate([0, 0, i * 360 / sign_count])
            translate([floor_r, 0, pocket_z])
                rotate([0, 90, 0]) rotate([0, 0, 90])
                    tile();
}

echo(str("outside ", outer_d, "  bore ", bore_d,
         "  across ribs ", bore_d - 2 * rib_h,
         "  floor ", floor_t, "  height ", total_h,
         "  cavity ", cav_ro - cav_ri, " wide",
         "  flute ", 2 * flute_hw, " across on ",
         PI * outer_d / flute_count, " pitch  (",
         len(kept_flutes), " of ", flute_count,
         " kept; the rest would have bitten a pocket)"));
echo(str("pocket ", sign_w, " x ", pocket_h,
         "  floor ", tile_t + sign_sag, " deep in the middle, ", tile_t,
         " at the edges  wall behind ", sign_t,
         "  z ", sign_z0, "..", sign_z1,
         "  overall with ends ", pocket_h + 2 * sign_bev));
echo(str("tile ", tile_w, " wide x ", tile_hb, " (back) / ", tile_hf,
         " (face) x ", tile_t, " thick; logo room at the centre ", sign_sag,
         "; 1.00 proud fits |x| <= ", logo_room(1.00),
         ", 2.00 proud fits |x| <= ", logo_room(2.00)));

// The fit coupon: the top coupon_h of the finished part, dropped onto the bed
// the same way up as the part itself. Taking it off the real thing rather than
// drawing a lookalike is deliberate — every number that could move the bore is
// then the number the part will print with.
module fit_coupon() {
    z0 = total_h - coupon_h;
    c  = coupon_relief + rib_h;          // 45 degrees, clearing the rib tips
    // NOT an assert. The coupon is for the bore, so catching part of a plaque
    // is a fact about it rather than a fault in it. Said out loud because it
    // changes what the geometry summary looks like: wedge tops inside the
    // coupon subdivide its cavity into sealed pockets and the genus goes
    // negative, and that is easier to read here than to work out later.
    if (sign_count > 0 && z0 <= sign_back_z1)
        echo(str("coupon note: it catches the pocket — top of its end ",
                 sign_z1 + sign_bev, ", backing wedge top ", sign_back_z1,
                 ", coupon floor ", z0,
                 ". Expect extra sealed voids and a negative genus. Harmless; ",
                 "coupon_h under ", total_h - sign_back_z1,
                 " would avoid it if a plain section is ever wanted"));
    difference() {
        translate([0, 0, -z0])
            intersection() {
                can_holder();
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
else if (show == "tile")
    tile();
else if (show == "assembly") {
    can_holder();
    tiles_seated();
}
else if (show == "cut")
    difference() {
        union() { can_holder(); tiles_seated(); }
        translate([-outer_d, -outer_d, -eps])
            cube([2 * outer_d, outer_d, total_h + 1]);
    }
else
    can_holder();
