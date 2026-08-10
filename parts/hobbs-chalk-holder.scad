// hobbs-chalk-holder.scad
//
// Both halves of the chalk holder on one plate: a slotted handle with a
// threaded spigot and a split collet, and the ring that screws onto it. Merged
// from chalk-holder-handle.scad and chalk-holder-tip.scad. Set show = "coupon"
// for a short fit test instead of the pair.
//
// HOW THE PAIR WORKS. The ring screws down the spigot and draws its own tapered
// bore over the collet, squeezing the four fingers onto the chalk. The thread is
// the clamp, not just a fastening, which is why a thread that binds ruins the
// whole mechanism.
//
// It stops on the chalk, not on the collar, and it does so from a long way out.
// The bore takes a 10.50 mm stick and the collet closes 2.67 mm on diameter from
// there, over 1.8 turns of the nut — so a new 9.50 mm stick arrests it with the
// ring still standing about 6.3 mm off the collar, and that gap shrinks as the
// stick wears. It is meant to feel like a drafting pencil: open wide, wind down
// a long way, grip.
//
// The legacy pair did the opposite. It squeezed 0.66 mm over half a turn, and
// its bore printed at about 9.47, so a 9.50 stick could not get in without being
// shaved to size on the way — and once in, there was nothing left to take up. It
// scraped the chalk and held it badly, and those were the same defect.
//
// WHAT SETS THE SIZE OF THIS TOOL. The clamping stroke can never exceed the
// collet's length: the ring's cone has to open from under the collet's tip to
// over its base within the collet's own span, so stroke approaches collet_h and
// never reaches it. Wanting 1.8 turns of stroke is therefore what forces a 16 mm
// collet, which forces a bigger thread under it to keep the finger roots thick,
// which forces a bigger barrel around that. None of the size here is styling.
//
// The whole mechanism is written out in [Hidden] under -- clamp --, including
// what it trades against: stroke is spent out of thread engagement, and there
// are 2.9 turns of that to spend.
//
// NAMES ARE PREFIXED ON PURPOSE. OpenSCAD has no namespaces and no scoping for
// top-level assignments: the last one in the file wins, everywhere in the file,
// regardless of where it appears. The two source files each defined collar_d,
// collar_h, thread_depth, thread_major_d, thread_profile and a dozen other
// names with *different values* — collar_d alone was 14.50 in one and 18.20 in
// the other. Concatenating them would have silently built both parts wrong
// while compiling perfectly. Everything that is not genuinely shared therefore
// carries a handle_ or ring_ prefix. Do not remove one to tidy the file up.
//
// WHAT MERGING FIXED. The pair had three numbers that lived in both files and
// had to be kept in step by hand, each with a comment begging the next person
// to remember: the spigot's crest diameter, the crest's axial width, and the
// blunt-start flag. They are single values here, under [Thread], and the ring
// derives its groove from them. That class of mistake is now impossible.
//
// ORIENTATION. Both parts sit on z = 0 the right way up for printing, which is
// how they were already drawn — merging moved them apart on the plate, it did
// not turn them over.
//
//   Handle, butt down. Keeps the collet fingers off the bed, where a small
//   four-arc footprint would print badly and elephant's foot would deform the
//   surface that does the gripping. It also puts the collar's seat face upward,
//   so the face the ring bottoms against comes out flat. The cost is the butt's
//   bullnose: see the note over handle_butt_flat.
//
//   Ring, nose down. Puts the seat face up for the same reason, and leaves the
//   outer flare and the coned bore at about 9 and 8 degrees off vertical,
//   which is nothing. Printed the other way up the seat would be squashed
//   against the bed and the coned bore would become a real overhang.
//
// Both parts are drawn in millimetres. Dimensions came off the legacy meshes in
// _incoming/, which are drawn in units of 0.1 mm — so a number here is as
// likely to be a faithfully copied mistake as a decision. Two already were.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <../logos/marks.scad>

/* [Plate] */
// Which parts to emit. Build one at a time when you want a clean STL per part,
// leave it on "both" to slice the pair as one plate, or ask for the fit coupon —
// see coupon_h. Anything else emits nothing at all, which is what you want when
// another file includes this one to get at its numbers.
show = "both";  // [both, handle, ring, coupon]

// Clear air between the two parts, surface to surface, with the ring measured
// over its ribs rather than its barrel.
part_gap = 8.00;  // (mm)

// The coupon is the top of the handle and the whole ring: every surface the
// clamp uses and none of the handle that it doesn't. It exists because this fit
// gets tuned by printing it, and a full pair is most of an hour to find out the
// bore is two tenths out.
//
// Measured down from the collet's top face, so it grows downward. It has to
// reach past the collar's top face — the seat the ring lands on — or the coupon
// leaves out the thing it exists to test; that is 34.60. 42.00 clears it with a
// stub of body to hold onto, and still stops short of the wordmark at 32.50, so
// the coupon comes out blank.
coupon_h = 42.00;  // (mm)

/* [Thread] */
// Shared by both halves. These are the numbers that describe the joint itself
// rather than either part, and they were the ones duplicated across the two
// old files.
thread_pitch   = 5.500;  // single start, so pitch equals lead (mm)
thread_crest_d = 16.800; // the spigot's crest diameter (mm)
thread_crest_w = 2.700;  // axial width of that crest at mid-flank (mm)
thread_depth   = 0.900;  // the spigot's tooth height, radially (mm)
thread_flank   = 0.300;  // axial run of each flank; 0 would be truly square (mm)
thread_left    = false;  // the original is right handed

// Off, the thread runs off the end at full height and the leading thread is a
// knife edge — easy to cross, and it shaves swarf that packs the rest of the
// run. On, it stops short and leaves a plain pilot that squares the parts up
// before anything bites. Off reproduces the original; on is BOSL2's default and
// what it recommends for anything printed. One flag now, for both halves.
thread_blunt_start = true;

// How far the thread ramps to full height at each end. BOSL2's default is
// generous, and this pair clamps through its thread, so turns lost here are
// clamp lost. It matters less than it did: the spigot now carries 17.60 mm of
// thread, about 3.2 turns, where the legacy one had under two, so the lead-in
// costs proportionally a third of what it used to. undef hands the choice back
// to BOSL2.
thread_lead_in = 0.60;  // (mm)

// Radial air between the spigot's crest and the bottom of the ring's groove. It
// does no work — the thread mates on its flanks and its land — and all of it is
// subtracted from the ring's outer wall. Do not raise it to fix a tight thread;
// that is what the clearances below are for. The legacy mesh effectively had
// 0.596 here and paid for it with a 0.499 mm wall.
thread_root_gap = 0.200;  // (mm)

// Axial gap at each flank, and which half pays for it. The allowance is taken
// entirely on the ring: taking it in both places doubles it. Both knobs exist so
// it can be moved, or split, deliberately rather than by accident. 0 on both
// reproduces the legacy pair exactly, which is a line-to-line fit that will not
// turn once printed.
handle_thread_clearance = 0.000;  // (mm)
ring_thread_clearance   = 0.150;  // (mm)

/* [Chalk] */
// The stick the tool is built around. The bore, the collet's outside diameter
// and therefore the entire clamp all follow from these three numbers, so fitting
// a different stick is one edit rather than four.
chalk_d = 9.500;  // nominal diameter of a new stick (mm)

// Diametral air between the stick and the bore, as printed. This is not a
// sliding-fit allowance — the collet closes onto the stick, so nothing here has
// to be tight. It is how much oversize, out-of-round and dusty stick the tool
// swallows without shaving it on the way in, and shaving is exactly what the
// legacy bore did: drawn at 9.637 it printed near 9.47, so a 9.50 stick could
// not physically enter it.
//
// A full millimetre is deliberate and it is what makes the tool forgiving. It is
// affordable only because the collet closes 2.67 mm on diameter — with the old
// 0.66 mm of closure, a bore this generous would have gripped nothing.
//
// It is not free either. Every 0.1 here is another 0.05 mm of collet radius,
// which is another 0.36 mm of clamping stroke, which comes straight out of
// thread engagement — see clamp_travel_budget.
chalk_slop = 1.000;  // (mm)

// Extrusion pull-in: a hole comes out this much undersize on diameter.
//
// MEASURED, not taken from the reference. docs/flashforge-ad5m-pro-scad-reference.md
// §5.3 gives 0.15 for the 0.4 nozzle and flags it as an unverified starting
// point, and on this machine it is not close: a bore drawn at 10.150 across the
// flats miked 9.5 to 9.6, a loss of 0.55 to 0.65. 0.600 is the middle of that.
//
// Two caveats. The reference's figure is tied to FlashForge's 0.20 mm profiles
// and these parts are printed at 0.12 for the sake of the thread, which is a
// different profile with its own compensations. And some of that loss is
// probably not pull-in at all but elephant's foot near the bed, which would mean
// the bore is only tight at its mouth. Both are reasons the number is soft — and
// reasons chalk_slop is generous, because the collet's range absorbs the error
// either way.
//
// The other half of the rule, that OpenSCAD's circles come out inscribed, is
// handled where the bore is derived, because it needs $fn.
hole_pull_in = 0.600;  // (mm)

/* [Handle: body] */
handle_body_d = 20.000;  // outside diameter of the tube (mm)
handle_body_h = 65.000;  // plain tube, up to the base of the collar (mm)

// The bore is not here — it is derived from [Chalk] down in [Hidden].
//
// handle_body_d was 15.000 on the legacy mesh, which made the tool a thin shaft
// with a fat head. It now matches the ring's barrel between its ribs, so the
// whole thing reads as one cylinder. It has since grown again, to 20.000, not
// for looks but because the thread under the collet had to get bigger and the
// ring's wall over the thread groove goes with it. With the bore at 11.11 the
// wall is 4.44 mm against the legacy part's 2.68.

/* [Handle: butt end] */
// The open end is rounded off on the outside. What you set is not the radius —
// it is how much flat contact ring is left between the curve and the bore, and
// the radius is whatever is left over. That way the rounding tracks the bore
// automatically and can never eat it, which is what the radius used to have to
// be kept in step with by hand.
//
// 0 is the largest rounding that means anything: the curve runs all the way in
// and arrives tangent at the bore, leaving no flat face at all. That is what the
// legacy pair does. The bore stays a sharp edge either way, which is deliberate
// — the end is open so a jammed stick can be driven out from behind, and that
// wants an edge, not a funnel.
//
// Printing cost at 0, since the handle goes butt down: the first layer is about
// a 1 mm sliver instead of the full 4.44 mm annulus, and the surface is about 20
// degrees off horizontal for the first millimetre. It will droop there or want
// support. 1.00 gives a proper contact ring and still reads as round.
handle_butt_flat = 0.000;  // flat ring left between the rounding and the bore (mm)

/* [Handle: loading slot] */
handle_slot_w  =  2.000;  // width (mm)
handle_slot_z0 =  4.600;  // start, above the bottom face (mm)
handle_slot_h  = 60.000;  // length (mm)
handle_slot_az = 270;     // which way it faces (deg)

// Break on the two long edges where the slot comes out through the outside, so
// they do not feel sharp under the fingers. It widens what you see: the walls
// stay where they are but the mouth opens up by roughly this much either side,
// so 0.40 turns a 2.00 slot into 2.80 at the surface, measured. The two ends of
// the slot are left square — nothing rests on them.
handle_slot_round = 0.400;  // (mm)

/* [Handle: collar] */
// With handle_collar_d equal to handle_body_d this is no longer a flare — it is
// just the last stretch of body before the spigot, and the only thing still
// making it a collar is its top face, which is what the ring would bottom
// against — though with this much clamping range it rarely gets that far. Set it
// back below handle_body_d to get a waist here instead.
handle_collar_d = 20.000;  // outside diameter at the top of the collar (mm)
handle_collar_h =  5.000;  // body up to collar, coned if the two differ (mm)

/* [Handle: threaded spigot] */
handle_spigot_h = 18.300;  // collar top to the base of the collet (mm)
handle_thread_h = 17.600;  // how much of the spigot carries thread (mm)

/* [Handle: collet] */
handle_collet_h      = 16.300;  // base of the collet to the top face (mm)
handle_collet_slots  = 4;      // fingers are the gaps between these
handle_collet_slot_w = 2.000;  // (mm)

// Finger thickness at the very tip, and the number the whole clamp turns on: the
// collet's outside diameter up there is the bore plus twice this, and how far
// that exceeds ring_mouth_d IS the mechanism. Everything else is second order.
// See the clamp block in [Hidden].
//
// The legacy pair had the outside diameter typed here instead, at 12.000. Held
// against the bore this file now runs, that would leave a 0.44 mm finger — one
// extrusion, on the thinnest and most heavily worked feature of the tool. 1.260
// is three 0.42 mm lines, which is what the printer reference asks for on
// anything load-bearing that flexes.
handle_collet_tip_wall = 1.260;  // (mm)

// What the fingers actually do: gripping a new 9.50 mm stick bends each one
// 0.50 mm, and the full 1.33 mm is only reached by winding the nut down on an
// empty holder. Worth not making a habit of — the handle prints butt down, so a
// finger bends across the layers rather than along them, and PETG creeps.
//
// Peak bending strain at that full deflection is about 1.5 %, against a PETG
// yield somewhere near 4 %. That is better than the shorter collet managed at
// half the closure, because strain falls with the square of the finger's length
// and this one is nearly twice as long.

// Coned relief under each slot, so the finger root is a ramp rather than a square
// corner. It is the stress riser that decides whether a finger ever cracks, and
// the root here is thinner and works harder than the legacy pair's, so this is
// the first number to reach for if one does. It is not free: the relief opens
// inward as it descends, so a longer ramp drags that erosion further down the
// spigot wall underneath the thread.
handle_collet_slot_ramp = 1.000;  // (mm)
handle_collet_slot_az   = 0;      // angle of the first slot (deg)

/* [Handle: maker's mark] */
// The wordmark, cut into the barrel. It comes from ../logos/marks.scad, which
// registers and scales it — hobbs_word_alone() rather than hobbs_mark_word()
// because the figure is not on this part, so the width asked for should be the
// width of the lettering.
//
// It is turned 90 degrees so it reads along the handle rather than around it.
// That is not only a look: cylindrical_extrude() wraps the child's X around the
// circumference and runs its Y along the axis, so a mark this long has to be
// turned to fit at all.
handle_mark       = true;   // set false for a blank barrel
handle_mark_len   = 40.00;  // length along the handle axis (mm)
handle_mark_z     = 32.50;  // centre, above the bottom face (mm)
handle_mark_depth =  0.40;  // how far it is cut into the wall (mm)

// Which way it faces. The loading slot is at 270, and cylindrical_extrude() puts
// its children at 270 by default, so this is doing real work, not just choosing
// a nice side. Keep it a multiple of 360/$fn or the wrap's facets stop lining up
// with the body's.
handle_mark_az = 90;  // (deg)

/* [Ring: body] */
ring_height    = 34.20;  // overall height (mm)
ring_collar_d  = 16.00;  // outside diameter at the bottom, between ribs (mm)
ring_collar_h  = 2.00;   // straight section at the bottom, before the flare (mm)
ring_barrel_d  = 20.00;  // outside diameter of the barrel, between ribs (mm)
ring_barrel_z0 = 15.00;   // height at which the flare reaches full diameter (mm)
ring_barrel_z1 = 27.00;  // where a top taper would start; inert while top = barrel (mm)
ring_top_d     = 20.00;  // outside diameter at the top face, between ribs (mm)

// ring_top_d was 17.39 on the legacy mesh, which put a step at the joint. It now
// matches the barrel and the handle's body, so the tool reads as one cylinder
// from the butt of the handle to the start of the nose taper. Two things fall
// out of that: the outer profile is straight from ring_barrel_z0 to ring_height,
// which is why ring_barrel_z1 no longer does anything, and the wall over the
// thread groove at the top rim goes from 0.895 mm to 1.400 mm — it was the
// thinnest section left in the part.
//
// ring_collar_d was 13.60. The collar is straight while the bore under it is
// already coning open, so the wall thinned as it climbed and hit 0.867 mm — the
// thinnest section anywhere in the part. A rib bead then sits on top of that,
// taking the section to 1.65 mm at each rib and back to 0.87 between, so the
// slicer changes its mind about how many wall loops fit twelve times a layer
// and every change leaves an unfilled pocket inside a rib. 14.50 put the thin
// spot at 1.31 mm; 16.00 puts it at 2.23. It costs diameter and nothing else:
// the collar is a grip surface and mates with nothing.

/* [Ring: grip ribs] */
ring_rib_count    = 12;    // beads around the barrel
ring_rib_r_bottom = 0.78;  // bead radius at the base (mm)
ring_rib_r_top    = 0.94;  // bead radius from ring_barrel_z0 upwards (mm)

/* [Ring: bore] */
// These two are the cone that squeezes the collet, and the line between them is
// the ramp the whole clamp rides down. Its slope decides how much nut travel a
// given amount of squeeze costs — steeper is less travel for the same grip, and
// travel is expensive because it is spent out of thread engagement.
//
// The throat cannot simply rise to whatever the slope wants: the bore has to
// step OUT as it enters the thread, so it must stay under the thread's own land,
// less the relief the bore is drawn undersize by. That ceiling is 15.792, and
// 15.48 leaves 0.156 mm of shoulder on radius. There is an assert on it in
// [Hidden], because past the ceiling the step inverts and ring_body_profile
// folds back on itself — which is not an error, just a quietly wrong part.
//
// The mouth is the other half of it. How far the collet's tip exceeds it is the
// entire clamp, so lowering ring_mouth_d buys grip range and raising it gives
// range back to get the nut closer to the collar.
ring_mouth_d  = 11.00;  // bore at the bottom face (mm)
ring_throat_d = 15.48;  // bore just under the thread shoulder (mm)

/* [Ring: thread] */
ring_thread_z0      = 16.30;    // shoulder the thread starts from (mm)
ring_thread_minor_d = 16.192;  // land diameter — what the spigot's crest bites (mm)

// Only read when blunt start is on. The pilot is how much plain bore at the
// mouth the spigot enters before any thread bites; the bevel is the lead-in
// chamfer on the lip, which is about getting the spigot in coaxially and has
// nothing to do with how the thread turns once engaged.
//
// The pilot sits at the groove root, r 8.600, not at the land — it has to clear
// the spigot's crest at 8.400, so it guides on that with 0.200 of slack. A
// pilot at the land would simply refuse the spigot.
//
// Both come out of thread engagement, so neither is free. The chamfer also
// comes out of the seat: it is cut off the top face, which is what bears
// against the handle's collar, and at 0.40 that face is 0.90 mm wide between
// the bore and the outside. Do not run it much past 0.60 or there is very
// little seat left.
ring_thread_pilot       = 1.50;  // (mm)
ring_thread_mouth_bevel = 0.40;  // (mm)

/* [Quality] */
$fn         = 64;  // segments per full circle
ring_rib_fn  = 24;  // segments on the rib beads; they are only ~1 mm across

/* [Hidden] */

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces make zero-thickness walls.
eps = 0.01;

// Radial clearance is not the knob here — see [Thread].
$slop = 0;

// How far the mark's cutting solid stands proud of the barrel, so its outer
// face is never coplanar with the surface it is cut into.
handle_mark_over = 0.05;

// Where each part sits on the plate. The ring is measured over its ribs, so the
// air between the two really is part_gap.
handle_r = handle_body_d / 2;
ring_r    = ring_barrel_d / 2 + ring_rib_r_top;
handle_x = -(handle_r + part_gap / 2);
ring_x    =   ring_r + part_gap / 2;

// -- handle -----------------------------------------------------------------

// The bore, and why it is derived down here instead of up beside its own inputs
// in [Chalk]: it reads $fn, and $fn is not assigned until [Quality], further
// down the file. OpenSCAD does not resolve forward references in top-level
// assignments — read $fn before it is set and the answer is nan, silently, and
// nan would go straight on into the butt rounding, the collet cone and the slot
// ramp without so much as a warning.
//
// The division is what circumscribes it. OpenSCAD's circles come out inscribed,
// so a bore drawn at diameter d only measures d*cos(180/$fn) across its flats:
// 0.012 mm at $fn = 64 and a bore around 10. Small, but the same sign as the
// pull-in, and the whole point of deriving any of this is to stop having to be
// right by hand.
handle_bore_d = (chalk_d + chalk_slop + hole_pull_in) / cos(180 / $fn);

// The biggest rounding that means anything is the entire wall, which arrives
// tangent at the bore and leaves no flat at all. handle_butt_flat backs it off
// from there, and because both terms follow the bore it can never eat it.
handle_butt_round = (handle_body_d - handle_bore_d) / 2 - handle_butt_flat;

handle_collet_tip_d = handle_bore_d + 2 * handle_collet_tip_wall;

handle_r_bore   = handle_bore_d / 2;
handle_r_root   = thread_crest_d / 2 - thread_depth;  // also the collet's base radius
handle_z_collar = handle_body_h + handle_collar_h;    // top of the collar
handle_z_collet = handle_z_collar + handle_spigot_h;  // base of the collet
handle_z_top    = handle_z_collet + handle_collet_h;

// Crest width as actually cut, with any allowance taken off both flanks.
handle_crest_w = thread_crest_w - 2 * handle_thread_clearance;

// One pitch of the tooth, in BOSL2's units: x is a fraction of the pitch and
// must stay inside [-1/2, 1/2]; y is depth in fractions of the pitch, with 0 at
// the crest. Flat crest, flat root, short flanks — a square thread with just
// enough draft to print. The ring's profile is the mirror of this.
handle_thread_profile = [
    [-0.5,                                                       -thread_depth / thread_pitch],
    [-(handle_crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [-(handle_crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (handle_crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (handle_crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [ 0.5,                                                       -thread_depth / thread_pitch],
];

// -- ring --------------------------------------------------------------------

ring_r_collar = ring_collar_d / 2;
ring_r_barrel = ring_barrel_d / 2;
ring_r_top    = ring_top_d / 2;
ring_r_mouth  = ring_mouth_d / 2;
ring_r_throat = ring_throat_d / 2;

ring_r_minor  = ring_thread_minor_d / 2;                  // the land
ring_r_major  = thread_crest_d / 2 + thread_root_gap;    // the bottom of the groove

// What BOSL2 actually wants: the mask rod's outside diameter, and how far its
// tooth stands off the core. Derived, so the land cannot drift when the groove
// depth changes — moving the land changes how the pair fits.
ring_thread_major_d = ring_r_major * 2;
ring_thread_depth   = ring_r_major - ring_r_minor;

// The threaded stretch of the bore is drawn undersize by this much so the
// thread mask always defines that surface itself, rather than the mask's core
// landing exactly on the bore — a subtracted face coplanar with its parent is
// what eps exists to avoid.
ring_bore_relief = 0.20;

// Half-section of the ring, walked up the outside and back down the bore.
ring_body_profile = [
    [ring_r_collar, 0],
    [ring_r_collar, ring_collar_h],
    [ring_r_barrel, ring_barrel_z0],
    [ring_r_barrel, ring_barrel_z1],
    [ring_r_top,    ring_height],
    [ring_r_minor - ring_bore_relief, ring_height],
    [ring_r_minor - ring_bore_relief, ring_thread_z0],
    [ring_r_throat, ring_thread_z0],
    [ring_r_mouth,  0],
];

// One rib, as [barrel radius, height, bead radius]. The bead sits centred on
// the barrel surface, so it stands its own radius proud of it — which is what
// the original does, including the bead thickening as it climbs.
ring_rib_path = [
    [ring_r_collar, 0,             ring_rib_r_bottom],
    [ring_r_collar, ring_collar_h,  ring_rib_r_bottom],
    [ring_r_barrel, ring_barrel_z0, ring_rib_r_top],
    [ring_r_barrel, ring_barrel_z1, ring_rib_r_top],
    [ring_r_top,    ring_height,    ring_rib_r_top],
];

// Groove width as actually cut: the male crest plus a flank gap either side.
ring_groove_w = thread_crest_w + 2 * ring_thread_clearance;

ring_thread_profile = [
    [-0.5,                                                          -ring_thread_depth / thread_pitch],
    [-(ring_groove_w / 2 + thread_flank / 2) / thread_pitch,          -ring_thread_depth / thread_pitch],
    [-(ring_groove_w / 2 - thread_flank / 2) / thread_pitch,           0],
    [ (ring_groove_w / 2 - thread_flank / 2) / thread_pitch,           0],
    [ (ring_groove_w / 2 + thread_flank / 2) / thread_pitch,          -ring_thread_depth / thread_pitch],
    [ 0.5,                                                          -ring_thread_depth / thread_pitch],
];

// -- clamp -------------------------------------------------------------------
//
// None of this draws anything. It is the mechanism written down, because until
// now it only existed as two numbers a hundred lines apart and a sentence in the
// header, and every one of these is a thing you would otherwise have to rederive
// before you could safely change anything.
//
// In use the handle stands collet up and the ring is upside down relative to how
// it is drawn: its TOP face, the threaded end, is the one that comes down onto
// the collar, and its mouth points at the sky. A point at ring-local z therefore
// sits at handle-global handle_z_collar + ring_height + g - z, where g is the
// air still left between the ring's top face and the collar, and g = 0 is fully
// seated.
//
// Two cones converge on each other. The ring's bore opens upward at
// ring_bore_slope; the collet closes upward at handle_collet_slope, which is
// negative and much shallower. For most of the stroke the contact is the collet's
// own top edge riding down the bore, and then for the last clamp_tip_protrusion
// it swaps to the ring's mouth edge biting the collet's flank, the tip having by
// then come out through the mouth.

handle_collet_r_tip = handle_collet_tip_d / 2;
handle_collet_slope = (handle_collet_r_tip - handle_r_root) / handle_collet_h;
ring_bore_slope     = (ring_r_throat - ring_r_mouth) / ring_thread_z0;

// How far the collet's tip stands out past the mouth once the ring is seated.
clamp_tip_protrusion = handle_spigot_h + handle_collet_h - ring_height;

// The one number the whole thing turns on: how much bigger the collet's tip is
// than the ring's mouth.
clamp_tip_overlap = handle_collet_r_tip - ring_r_mouth;

// First contact to full seat, and the squeeze delivered by the time it gets
// there. Both are on radius; double clamp_closure for the width of the grip
// range. Divide clamp_stroke by thread_pitch for turns of the nut.
clamp_stroke  = clamp_tip_overlap / ring_bore_slope + clamp_tip_protrusion;
clamp_closure = clamp_tip_overlap - handle_collet_slope * clamp_tip_protrusion;

// Clearance between the collet's BASE and the bore at full seat. It is small on
// purpose — that is what lets the bore lie along the whole flank rather than
// only bite at the mouth — but nothing feeding it is a free parameter. Nudge
// ring_height, handle_spigot_h, ring_mouth_d or ring_throat_d and it goes
// negative, at which point the ring stops dead on the collet's base.
clamp_base_gap = ring_r_mouth
               + ring_bore_slope * (ring_height - handle_spigot_h)
               - handle_r_root;

// What the stroke is spent out of. Stroke and the engagement still left when the
// clamp starts to load always sum to this, so buying one spends the other. The
// legacy budget was 1.6 turns, which could not cover a turn of each; it is 2.9
// now, bought by raising handle_spigot_h and ring_height together and taking
// handle_thread_h up with the spigot. That is the only way to grow it.
clamp_travel_budget = handle_thread_h - ring_thread_pilot;
clamp_engagement    = clamp_travel_budget - clamp_stroke;

// What it will actually hold, as printed rather than as drawn: the bore loses
// the inscribed-polygon slice and the extrusion pull-in, and the collet closes
// by clamp_closure on radius from there. Conservative at the bottom end, since
// printing also makes the collet fatter and the mouth smaller.
chalk_d_max = handle_bore_d * cos(180 / $fn) - hole_pull_in;
chalk_d_min = chalk_d_max - 2 * clamp_closure;

// -- the invariants ----------------------------------------------------------
//
// Three things that are true now, are not enforced by anything else, and would
// each produce a part that renders perfectly and does not work.

assert(clamp_base_gap > 0,
       str("ring bore is narrower than the collet's base at full seat: the ring ",
           "will stop on the collet instead of running down the thread"));

assert(ring_r_throat < ring_r_minor - ring_bore_relief,
       str("ring_throat_d is past the thread's land: the bore steps inward ",
           "entering the thread instead of outward, and ring_body_profile then ",
           "folds back on itself"));

assert(handle_butt_round > 0,
       str("handle_butt_flat is wider than the wall, so there is no rounding ",
           "left to take off the butt"));

// clamp_base_gap reads the bore's cone at the collet's base. If the cone stops
// short of that station the figure is an extrapolation of a surface that is not
// there, and it will happily report a healthy clearance for a ring that jams.
assert(ring_thread_z0 >= ring_height - handle_spigot_h,
       str("the ring's tapered bore ends before it reaches the collet's base at ",
           "full seat: raise ring_thread_z0 or shorten handle_spigot_h"));

// The stroke is only as long as the shorter of the two threads allows.
assert(ring_height - ring_thread_z0 >= handle_thread_h,
       str("the ring's internal thread is shorter than the spigot's, so the ",
           "spigot bottoms out before the clamp closes"));

// ===========================================================================
// Handle
// ===========================================================================

// Everything solid, before anything is taken out of it.
module handle_blank() {
    // The bore is subtracted later, and it takes exactly the flat disc this
    // rounding leaves behind — which is what puts the fillet tangent to it.
    cyl(d = handle_body_d, h = handle_body_h,
        rounding1 = handle_butt_round, anchor = BOTTOM);

    translate([0, 0, handle_body_h])
        cylinder(d1 = handle_body_d, d2 = handle_collar_d, h = handle_collar_h);

    translate([0, 0, handle_z_collar])
        cylinder(d = handle_r_root * 2, h = handle_spigot_h);

    // the thread rides on that spigot; its own core is the same cylinder, so
    // the two share a surface, which is only ever a problem in a difference
    translate([0, 0, handle_z_collar])
        generic_threaded_rod(
            d           = thread_crest_d,
            l           = handle_thread_h,
            pitch       = thread_pitch,
            profile     = handle_thread_profile,
            internal    = false,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel       = false,
            anchor      = BOTTOM);

    translate([0, 0, handle_z_collet])
        cylinder(d1 = handle_r_root * 2, d2 = handle_collet_tip_d,
                 h = handle_collet_h);
}

// Cross-section of the slot, with its two outside corners rounded off.
//
// The rounding is worked on the body's section rather than on the cut, because
// a corner that pokes into a void is convex, and rounding a convex corner means
// taking material away. Erode by the radius and dilate back and that is exactly
// what happens — the same trick the painter's pyramid uses on its lug tips. The
// cut is then whatever the rounded section does not occupy.
//
// The strip runs from the axis outward, which is what keeps the slot through
// one wall only. reach is a reach, not a diameter: it just has to clear the
// outside. The corners it leaves at the axis end get rounded too, but they sit
// at r = 1 and the bore takes them regardless.
module handle_slot_profile() {
    reach = max(handle_body_d, handle_collar_d);

    difference() {
        circle(d = handle_body_d + 2 * eps);

        offset(r = handle_slot_round, $fn = 16)
        offset(r = -handle_slot_round, $fn = 16)
            difference() {
                circle(d = handle_body_d);

                translate([0, -handle_slot_w / 2])
                    square([reach, handle_slot_w]);
            }
    }
}

// The slot down the body, cut clean through one wall only.
module handle_loading_slot() {
    rotate([0, 0, handle_slot_az])
        translate([0, 0, handle_slot_z0])
            linear_extrude(handle_slot_h)
                handle_slot_profile();
}

// One collet slot. The box gives it a constant width rather than a constant
// angle; intersecting that with a cone standing on the bore puts a ramp under
// it instead of a square corner, which is what the original does and what keeps
// the finger roots from being a stress riser.
module handle_collet_slot() {
    ramp_slope = (handle_r_root - handle_r_bore) / handle_collet_slot_ramp;
    z_ramp     = handle_z_collet - handle_collet_slot_ramp;
    r_far      = handle_collar_d;

    intersection() {
        translate([0, -handle_collet_slot_w / 2, z_ramp - 1])
            cube([r_far, handle_collet_slot_w, handle_z_top - z_ramp + 2]);

        rotate_extrude(convexity = 4)
            polygon([
                [0,     z_ramp - handle_r_bore / ramp_slope],
                [r_far, z_ramp + (r_far - handle_r_bore) / ramp_slope],
                [r_far, handle_z_top + 1],
                [0,     handle_z_top + 1],
            ]);
    }
}

// The wordmark wrapped onto the barrel and turned into a solid to subtract.
// Wrapping matters at this size: 40 mm of mark stands 7.5 mm around an 18.2 mm
// barrel, and a flat cut would come out 0.43 mm shallower at its edges than at
// its centre — most of a 0.40 mm deboss.
//
// size is given so the wrap only builds facets over the mark. Left to itself it
// assumes the child goes right round the cylinder; set it too small and it
// quietly clips the artwork instead.
module handle_mark_cut() {
    translate([0, 0, handle_mark_z])
        cylindrical_extrude(
            ir   = handle_body_d / 2 - handle_mark_depth,
            or   = handle_body_d / 2 + handle_mark_over,
            size = [hobbs_word_height(handle_mark_len) * 1.05,
                    handle_mark_len * 1.05],
            spin = handle_mark_az - 270)
                rotate(90) hobbs_word_alone(handle_mark_len);
}

module chalk_holder_handle() {
    difference() {
        handle_blank();

        translate([0, 0, -eps])
            cylinder(d = handle_bore_d, h = handle_z_top + 2 * eps);

        handle_loading_slot();

        for (i = [0 : handle_collet_slots - 1])
            rotate([0, 0, handle_collet_slot_az + i * 360 / handle_collet_slots])
                handle_collet_slot();

        if (handle_mark)
            handle_mark_cut();
    }
}

// ===========================================================================
// Ring
// ===========================================================================

module ring_rib() {
    for (i = [0 : len(ring_rib_path) - 2])
        hull() {
            translate([ring_rib_path[i][0], 0, ring_rib_path[i][1]])
                sphere(r = ring_rib_path[i][2], $fn = ring_rib_fn);
            translate([ring_rib_path[i + 1][0], 0, ring_rib_path[i + 1][1]])
                sphere(r = ring_rib_path[i + 1][2], $fn = ring_rib_fn);
        }
}

// The beads at the ends of the path overshoot the top and bottom faces by their
// own radius; the cylinder trims them back flush.
module ring_ribs() {
    intersection() {
        union() {
            for (i = [0 : ring_rib_count - 1])
                rotate([0, 0, i * 360 / ring_rib_count])
                    ring_rib();
        }

        cylinder(r = ring_r_barrel + ring_rib_r_top + 1, h = ring_height);
    }
}

// A thread-shaped rod to subtract. It starts eps below the shoulder so its end
// face is never coplanar with it.
//
// The mask always runs past the mouth, whichever entry you asked for. That is
// not cosmetic: the bore under it is drawn ring_bore_relief undersize on
// purpose, so if the mask stops level with the mouth then the relieved surface
// — not the thread's own minor diameter — becomes the visible bore. It does,
// measurably: stopping it flush puts r 7.088 on the top face and triples the
// count of degenerate facets there. The mask's core has to cover the mouth.
//
// So overrun is only ever about where the thread runs out, and the two entries
// get there differently. Blunt start off runs a full pitch past, and the thread
// walks off the face at full height as the original's does. Blunt start on
// clears the face by a hair and holds the thread back from it with end_len2
// instead, which is what leaves the plain pilot bore.
module ring_thread_mask() {
    overrun = thread_blunt_start ? eps : thread_pitch;

    translate([0, 0, ring_thread_z0 - eps])
        generic_threaded_rod(
            d           = ring_thread_major_d,
            l           = ring_height - ring_thread_z0 + overrun + eps,
            pitch       = thread_pitch,
            profile     = ring_thread_profile,
            internal    = true,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            end_len2    = thread_blunt_start ? ring_thread_pilot + overrun : undef,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel1      = false,
            bevel2      = thread_blunt_start ? ring_thread_mouth_bevel : false,
            anchor      = BOTTOM);
}

module chalk_holder_ring() {
    difference() {
        union() {
            rotate_extrude(convexity = 8)
                polygon(ring_body_profile);

            ring_ribs();
        }

        ring_thread_mask();
    }
}

// ===========================================================================
// The plate
// ===========================================================================

// The fit coupon: the top coupon_h of the handle, dropped onto the bed. It is cut
// out of the finished part rather than built as a short one, so it cannot drift
// out of agreement with the real thing — the collet, the thread and the seat are
// that geometry, not a copy of it.
//
// It prints cut face down, collet up, exactly as the handle does. The flat
// annulus it lands on is a better first layer than the handle's own bullnose.
module chalk_holder_coupon() {
    z0 = handle_z_top - coupon_h;

    assert(z0 < handle_z_collar,
           str("coupon_h does not reach the collar's top face, so the coupon ",
               "leaves out the seat the ring lands on — the thing it is for"));

    translate([0, 0, -z0])
        intersection() {
            chalk_holder_handle();

            translate([0, 0, z0])
                cylinder(d = 2 * handle_body_d, h = coupon_h + eps);
        }
}

module chalk_holder() {
    if (show == "both" || show == "handle")
        translate([show == "handle" ? 0 : handle_x, 0, 0])
            chalk_holder_handle();

    if (show == "coupon")
        translate([handle_x, 0, 0])
            chalk_holder_coupon();

    if (show == "both" || show == "ring" || show == "coupon")
        translate([show == "ring" ? 0 : ring_x, 0, 0])
            chalk_holder_ring();
}

chalk_holder();
