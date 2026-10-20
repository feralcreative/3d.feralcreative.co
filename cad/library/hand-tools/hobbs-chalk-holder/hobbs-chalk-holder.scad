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
// It stops on the chalk, not on the collar. The channel admits a 9.85 mm stick
// and the collet closes 1.00 mm on diameter from there, over 0.55 turns of the
// nut — so a 9.42 mm stick (what Crayola sidewalk chalk actually mikes) arrests
// it with the ring still standing about 1.75 mm off the collar, and that gap
// shrinks as the stick wears.
//
// It used to wind a long way — 2.67 mm of closure over 1.8 turns, drafting-pencil
// fashion. That is gone, and it was spent deliberately on a flexible collet: a
// 0.84 mm finger has far less tip to overlap the ring's mouth with than a 1.52 mm
// one did, and the mouth cannot drop below about 10 mm or the chalk will not pass
// through it, which caps the stroke near 0.95 turns whatever else is changed.
// Grip and flex won; travel paid.
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
// That paragraph is the history of how the tool got this big, and it is still why
// the collet is 16 mm of thread under it. It is no longer what sets the stroke:
// the collet is 10 mm, the finger is 0.84 mm, and the stroke those two allow is
// 0.55 turns. Engagement is no longer the scarce thing either — there is 13.05 mm
// of it left at full seat.
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

// The two halves a coupon can carry, and the variant that puts both on one
// plate. utils/coupon.sh reads these to work out what has changed since the
// last print and leaves the unchanged half off — so the names on the left have
// to stay stable, and any new variant that belongs on a coupon has to be
// declared here or the script will not know it exists.
// COUPON-COMPONENTS: handle=coupon-handle ring=ring
// COUPON-PLATE: coupon

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/threading.scad>
include <../../../logos/marks.scad>

/* [Plate] */
// Which parts to emit. Build one at a time when you want a clean STL per part,
// leave it on "both" to slice the pair as one plate, or ask for the fit coupon —
// see coupon_h. Anything else emits nothing at all, which is what you want when
// another file includes this one to get at its numbers.
show = "both";  // [both, handle, ring, coupon, coupon-handle, collet-test]

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
// leaves out the thing it exists to test.
//
// That distance is now 28.30, not the 34.60 this was originally sized against:
// the collet lost 6.3 mm when it was shortened for a positive stop. 36.00 keeps
// the same 7.7 mm stub of body to hold onto, and still starts above the wordmark
// — the cut face lands at z 66.30 against a mark spanning 14.50 to 54.50, both
// having moved up 4 mm with the longer body — so the coupon comes out blank.
//
// It follows the handle for everything else, being an intersection of it, so the
// wider bore and the shorter collet arrive here without any edit.
coupon_h = 36.00;  // (mm)

// A much shorter coupon that exists only to find out whether the collet prints
// at all. show = "collet-test".
//
// The fit coupon above is 42 mm and most of an hour and a quarter, and it spends
// the first 25 mm printing thread that was never in question. The collet is the
// part that fails, so this keeps a stub of spigot to stand on and nothing else:
// the four-island geometry starts within a few layers, so a starving extruder
// shows itself in minutes instead of at the hour mark, with far less filament
// dragged through a grinding drive gear.
//
// It deliberately does NOT reach the collar, so it tells you nothing about fit.
// Wrong tool for that; use coupon_h.
collet_test_base = 3.00;  // spigot kept below the collet's base (mm)

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

// What the sticks in the studio actually mike, which is not the same number and
// is the one the grip ribs are sized against. The lip is held to the nominal
// figure above — it is the continuous passage, and it should admit any stick
// sold as 9.5 — while the ribs are allowed to come inside that, because they are
// twelve narrow contacts rather than a bore and they are meant to engage.
//
// Raise this if a batch of chalk turns out fatter, and the rib assert below will
// tell you if the ribs have become a press fit rather than a slip fit.
chalk_d_measured = 9.420;  // (mm)

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
// Opened 1.000 -> 1.750 on 2026-08-10: a printed collet still scraped the stick
// on the way in.
//
// Closed 1.750 -> 1.250 on 2026-08-11, asked for directly: 0.5 mm out of the
// channel. Note that the channel a stick actually has to pass is no longer this
// one — the bite lip at the collet's tip is 0.9 mm narrower again, and that is
// the number to reason about. See handle_collet_bite_t.
//
// Closed again 1.250 -> 0.750 on 2026-08-12, after the v1 coupon was printed and
// measured: about a millimetre of wiggle in the barrel. This is the barrel's
// number and nothing else's — the entry is set by the lip and was deliberately
// held at 9.85 by taking handle_collet_bite_t down in the same change.
//
// It does not act alone on the clamp. The collet's tip is bore + 2 * finger, so
// 0.5 off here is 0.5 off the tip's outside diameter and 0.5 of grip given away.
// ring_mouth_d paid that back and then bought more; see it and the note there.
chalk_slop = 0.750;  // (mm)

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
handle_body_h = 69.000;  // plain tube, up to the base of the collar (mm)

// The bore is not here — it is derived from [Chalk] down in [Hidden].
//
// handle_body_h was 65.000, which made the tool 98.3 mm overall against a 4 inch
// (101.6 mm) stick, so a fresh stick disappeared into the bore instead of
// reaching the butt. 69.000 puts the bore at 102.3 mm, so a new stick is fully
// contained with the ring on and 0.7 mm to spare. Two things follow it and are
// not derived: handle_slot_h, which keeps the loading slot ending 0.4 mm below
// the body top, and handle_mark_z, which keeps the wordmark centred.
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
handle_slot_h  = 64.000;  // length (mm)
handle_slot_az = 270;     // which way it faces (deg)

// Break on the two long edges where the slot comes out through the outside, so
// they do not feel sharp under the fingers. It widens what you see: the walls
// stay where they are but the mouth opens up, so 0.40 turns a 2.00 slot into
// 2.61 at the surface, measured in the mesh. The two ends of the slot are left
// square — nothing rests on them.
//
// That figure used to read 2.80, measured on a barrel that was secretly a
// 16-sided polygon; a chord across two flats is not the mouth. See
// handle_slot_round_fn.
handle_slot_round = 0.400;  // (mm)

// Segments for the erode/dilate that produces that rounding, and NOT a detail:
// this number sets the roundness of the whole barrel between the slot's ends.
//
// The profile is drawn as a disc minus the eroded-and-dilated body section, so
// everything outside the dilated shape is cut away — which means the dilated
// shape IS the barrel over the slot's length. offset() spends its $fn on a full
// circle, so at 16 the dilation came back as a 16-sided polygon and the barrel
// was shaved to it: a measured 0.192 mm flat every 22.5 degrees, which is
// exactly r*(1-cos(180/16)) at r 10, from z 4.6 to 68.6. That is the faceting
// STATUS.md had recorded as visible on the printed handle and never explained;
// it was never the part's own $fn, which is why raising that to 256 did not
// help.
//
// 256 matches the body and takes the flat to 0.0008 mm. It is not free — the
// erode/dilate runs over a 256-gon rather than a 16-gon — but it is a 2D
// operation on one profile and costs about a second.
handle_slot_round_fn = 256;

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
// Shortened from 16.300 on 2026-08-10, after a print that stopped 6.41 mm early
// turned out to clamp better than the drawn part.
//
// The reason is the hard stop. At full seat a 16.3 collet has its tip 0.4 mm
// PROUD of the mouth, so the mouth bites the flank and closes 1.333 mm on
// radius — more than a chalk stick wants, which is why it always arrested early
// and left the nut standing proud. Ending the collet 6 mm short of the mouth
// makes full seat close 0.759 instead, so the nut can be wound down until it
// stops and the grip is right when it gets there.
//
// The price is range, and it is the scale-up's gain given back: 10.50–8.98 mm
// of stick instead of 10.50–7.83. Ample for Crayola sidewalk chalk, which mikes
// 9.42 against a 9.50 nominal.
handle_collet_h      = 10.000;  // base of the collet to the top face (mm)
handle_collet_slots  = 4;      // fingers are the gaps between these
handle_collet_slot_w = 2.000;  // (mm)

// Finger thickness at the very tip, and the number the whole clamp turns on: the
// collet's outside diameter up there is the bore plus twice this, and how far
// that exceeds ring_mouth_d IS the mechanism. Everything else is second order.
// See the clamp block in [Hidden].
//
// The legacy pair had the outside diameter typed here instead, at 12.000. Held
// against the bore this file now runs, that would leave a 0.44 mm finger — one
// extrusion, on the thinnest and most heavily worked feature of the tool. It has
// been 1.260 (three 0.42 mm lines) and then 1.524 (three or four), both chosen to
// keep the finger off the one-extrusion floor.
//
// Thinned 1.524 -> 0.840 on 2026-08-11, asked for directly: two lines instead of
// three, for a finger that actually flexes. 0.840 is 0.42 + 0.42, which is the
// clean two-loop rung — and this profile lays exactly wall_loops = 2, so it is
// also the thickest wall that prints as two full perimeters with no gap fill.
// 1.290 (0.42 + 0.45 + 0.42) would need wall_loops raised to 3 and otherwise
// resolves as two perimeters plus gap fill; see docs/flash-studio-slicing-reference.md.
//
// THE TIP DIAMETER IS DERIVED, as bore + 2 * this, so this number is the clamp.
// Thinning the finger by 0.684 took 1.368 mm off the tip's outside diameter, and
// with the bore's own 0.5 mm that is 1.868 mm of overlap with the ring's mouth
// gone. Left alone it would have closed 0.20 mm and gripped nothing smaller than
// 9.45 — above the stick it is for. ring_mouth_d came down to 12.05 to pay for
// it. Change this without changing the mouth and the clamp goes with it.
handle_collet_tip_wall = 0.840;  // (mm)

// The bite lip: the top of each finger is thicker than the rest of it, and the
// extra goes INWARD, so the channel steps narrower for the last two layers and
// that edge is what closes on the chalk. Below it the finger clears the stick and
// is free to bend.
//
// Grown inward rather than outward on purpose. Outward would put a proud band on
// the cone the ring's mouth rides, and with only 0.1 mm of tip protrusion at full
// seat the mouth would ride over that band and off it again within a quarter of a
// millimetre of travel — the grip would arrive and then let go. Inward leaves the
// cone unbroken, so nothing about the clamp arithmetic knows the lip is there.
//
// 0.450 was one inner-wall line, taking the lip to 1.290 — the three-wide
// section originally asked for. 0.240 is two layers at 0.12. The lip's underside
// is an unsupported ledge running round a curve; it should bridge, but it is one
// of the two things only a printed part can answer.
//
// Cut 0.450 -> 0.200 on 2026-08-12, and it is bookkeeping rather than a
// judgement about bite. chalk_slop came down 0.5 in the same change, and the lip
// is measured inward from the bore, so left at 0.450 the entry would have
// followed the bore down to 9.35 mm as printed — under the 9.42 mm a Crayola
// stick mikes, so a fresh stick would have had to be shaved on the way in. That
// is the legacy part's defect arrived at from the other side, and the assert in
// [Hidden] refuses to render it. 0.200 holds the entry at 9.85, exactly where it
// was before either change.
//
// The cost is that 0.200 is under one extrusion line, so the ledge is no longer
// a clean inner wall — the slicer resolves it as it sees fit, and how much of a
// bite is left is now a question for a printed part rather than one the profile
// answers. If it turns out not to bite, the lever is chalk_slop back up rather
// than this back up: the entry is what this protects.
//
// It costs channel: the passage at the lip is 0.9 mm narrower than the bore, so
// the widest stick the tool admits is set here, not by chalk_slop. There is an
// assert in [Hidden] keeping it wider than a nominal stick.
handle_collet_bite_t = 0.200;  // extra finger thickness at the tip, inward (mm)
handle_collet_bite_h = 0.240;  // height of that band — two 0.12 mm layers (mm)

/* [Handle: collet grip ribs] */
// Ribs on the INSIDE of each finger, running along the tool's axis, to turn four
// broad arcs of contact into twelve narrow ones. The clamp force is the same;
// the pressure at each contact is several times higher, which is what digs into
// gypsum and stops a stick walking back down the barrel under hand pressure.
//
// AXIAL IS THE WHOLE POINT, and it is why this is safe to print where a
// horizontal rib would not be. The handle prints collet up, so a rib running
// around the bore is an unsupported ledge bridging on a curve — the same gamble
// as handle_collet_bite_h, taken once per rib. A rib running along the axis is
// just a locally thicker wall in every layer: it prints inside the same
// perimeter loop, nothing bridges, and every layer is identical to the one
// under it.
//
// They are deliberately SHORT. Bending stiffness goes as thickness cubed, so a
// 0.40 mm rib on a 0.84 mm finger is about 2.5x the local stiffness — run the
// full 10 mm and the collet stops flexing, which is exactly what plan 05 spent
// the clamp's travel to buy. Confined to the top few millimetres, the root is
// still 0.84 and still does the bending.
// HOW MANY, AND WHY NOT MORE. A rib is a step in the wall's thickness, and the
// slicer breaks its perimeter path at every step — so the gap fill it leaves
// scales with the rib COUNT, not with how much material the ribs add. Sliced
// five ways at z 33.30, everything else held:
//
//     3 x 0.42 wide      108 gap-fill fragments per layer
//     3 x 0.84            65
//     1 x 0.42            42
//     1 x 0.84            18
//     thicker rib, wall_loops = 3    113
//
// The last line is the important one: raising wall_loops does nothing, verified
// twice with `; wall_loops = 3` read back out of the G-code. This is not a print
// setting problem and nothing in docs/profiles/ should be touched for it. Two
// wide ribs is the middle of that table — eight contacts to keep a stick from
// rocking, at a fraction of the fragmentation of twelve narrow ones.
handle_collet_ribs = 2;  // per finger; 0 disables them entirely

// Measured from the LIP's passage, not from the bore. The lip already steps the
// channel in by handle_collet_bite_t, and a rib flush with that would add
// nothing at the tip — it would only extend the same narrowing further down. So
// the crest sits this much inside the lip, and the rib's own radial height is
// whatever that takes: handle_collet_bite_t + this below the lip, and just this
// within it.
//
// 0.200 puts the channel at the ribs near 9.45 as printed, against sticks that
// mike 9.42. A stick still drops in — the ribs are not a press fit — and they
// engage as the nut closes, which is what the 1.51 mm of closure is for. Raising
// it past about 0.25 turns insertion into a push fit, which is the legacy part's
// defect in miniature. There is an assert below.
handle_collet_rib_h = 0.200;  // crest, inside the lip's passage (mm)

// Two extrusion lines. 0.420 was one, and one line is a sliver the slicer will
// not run a path around — it fills it, which is where the fragmentation in the
// table above comes from. At 0.840 the rib is wide enough to carry its own pair
// of perimeters, and the same measurement drops by more than half at equal rib
// count. It bites over a wider contact, which is the trade: less pressure per
// rib than a knife edge would give, but a knife edge is what will not print.
handle_collet_rib_w = 0.840;  // tangential width (mm)

// Axial run, measured down from the collet's top face, and how much of that run
// is spent ramping up to full height. The ramp is not cosmetic: a rib that
// arrives at full height in one layer leaves a small ledge at its lower end,
// which is the overhang this whole arrangement exists to avoid.
handle_collet_rib_len  = 3.500;  // (mm)
handle_collet_rib_ramp = 1.500;  // of that run, the lead-in (mm)

// Angular pitch BETWEEN ribs, not the half-span — the set is laid out
// symmetrically about each finger's centreline, so two ribs sit at plus and
// minus half of this and three sat at minus one, zero and plus one.
//
// 40 with two ribs puts them at ±20 deg, which is exactly where the outer pair
// of the original three sat. That is deliberate: dropping the middle rib should
// not also narrow the span, because the span is what stops a stick rocking
// between contacts. It was 20 while there were three ribs.
//
// A rib that runs off the edge of a finger would be left standing over a slot
// with nothing under it; the assert in [Hidden] checks the whole set clears the
// finger's own arc, measured at the crest radius where the finger is narrowest.
handle_collet_rib_spread = 40;  // (deg)

// What the fingers actually do: gripping a 9.42 mm stick bends each one 0.215 mm,
// and the full 0.50 mm is only reached by winding the nut down on an empty
// holder. Worth not making a habit of — the handle prints butt down, so a finger
// bends across the layers rather than along them, and PETG creeps.
//
// Strain is no longer the worry it was. Peak bending strain goes as thickness
// times deflection over length squared, and thinning the finger to 0.840 halved
// the first term while the smaller closure more than halved the second: against
// the 1.5 % this collet was estimated at when it was 1.524 thick and closing
// 1.125, it now lands near 0.4 %, on a PETG yield somewhere around 4 %. The
// finger root and its relief ramp remain the place a crack would start, not the
// tip — see handle_collet_slot_ramp.

// Sacrificial webs that bridge the slots, joining the four fingers into one
// body for the duration of the print. **They must be snapped out before the
// tool is used** — left in, they stop the collet flexing and the clamp does
// nothing.
//
// This is not a stiffness aid, it is a printing fix, and the reason is worth
// understanding before changing it. Without the webs each layer up the collet is
// four separate islands, so the nozzle travels and retracts four times per layer
// while depositing about 0.06 mm of filament into each one. Two prints failed on
// that: the extruder ground a flat into the filament, lost grip, and stopped
// delivering part way up, leaving a collet that ended flat and even where the
// material simply stopped arriving. Retraction length was cut from 1.6 to 0.4 mm
// to reduce the damage per cycle, but the cycle COUNT is set by the geometry and
// only this fixes it. See docs/_PLANS/chalk-holder-04-260810T1514Z.md.
//
// Joined, the cross-section is a continuous annulus: one island, roughly a
// quarter of the travel, and several times the extrusion per layer.
// **Default OFF, because it was measured and it does not work.** Kept only so
// the idea is not had again from scratch.
//
// The reasoning was that four islands mean four travels and four retractions per
// layer, so joining them should cut both. Sliced both ways, at z 12.30 of the
// collet test:
//
//     collet_tie   path blocks   retractions   extruded
//     false             8             4          0.247 mm
//     true              4             5          0.190 mm
//
// It halves the path blocks and yet retracts MORE, while depositing LESS. An
// annulus that alternates 0.84 mm web with 1.4 mm finger is a varying-thickness
// wall, and the slicer fragments its path handling the transitions rather than
// running one clean loop. Making the web full finger thickness would fix that
// and give a solid collet nobody can cut four slots back into.
//
// Whole-print retraction counts barely moved either: 706 untied against 691
// tied. Raising retraction_minimum_travel from 1 mm to 6 mm gets 706 down to
// 543, so the slot crossings are not where most retractions come from.
collet_tie   = false;   // measured counterproductive; see above
// Dropped 0.840 -> 0.600 when the finger itself came down to 0.840. The assert
// below wants the web strictly thinner than a finger, and it only fires when
// collet_tie is true — so left at 0.840 this would have sat harmless until
// someone enabled the tie and then refused to render.
collet_tie_t = 0.600;   // radial thickness of each web, if enabled (mm)

// The web sits flush with the collet's outer cone and grows inward, so the
// outside envelope is unchanged and the ring still slides over it. It has to
// stay thinner than the thinnest part of a finger, so that it is the web that
// breaks and not the finger — that thinnest point is handle_collet_tip_wall, and
// the assert below enforces it.

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
handle_mark_z     = 34.50;  // centre, above the bottom face (mm)
handle_mark_depth =  1.00;  // how far it is cut into the wall (mm)

// The wall angle of the cut, measured from horizontal, and what makes a deep
// deboss printable at all.
//
// The handle prints barrel up, so a prismatic cut leaves a horizontal roof over
// every letter: at the top edge of each stroke the wall has to bridge inward by
// the full depth with nothing under it. At 0.40 that is a ledge small enough to
// get away with. At 1.00 it is not, and it is the kind of thing a slicer answers
// with support material inside the lettering, which then has to be picked out of
// a 1 mm deep letter.
//
// Sloping every face fixes it without support at any depth, because there is no
// horizontal roof left. The cost is paid in stroke width: the cut narrows as it
// deepens, so the deepest section is the artwork eroded by depth / tan(angle),
// and the HOBBS strokes go spindly past about 0.30 mm of erosion (rendered as a
// ladder before this was chosen; they survive 0.50 but barely).
//
// 90 is prismatic — no taper, the old behaviour. 45 is the classic
// self-supporting chamfer and costs 1.00 mm of erosion per millimetre of depth,
// which this artwork cannot pay. 70 is still 20 degrees off vertical, well
// inside what prints unsupported, and costs 0.36 — so 1.00 mm of depth erodes
// the deepest section by 0.29 and the letters hold.
handle_mark_taper = 70;  // (deg from horizontal)

// The taper is built as a stack of prismatic bands rather than a true cone,
// because cylindrical_extrude wraps a 2D child and cannot loft between two of
// them. Each band is one wrap, so this multiplies the most expensive operation
// in the part — see handle_mark_fn — and it is why the number is small.
//
// It does not need to be large. What each band leaves is a horizontal ledge as
// deep as the band itself, so 5 bands over 1.00 mm gives 0.20 mm ledges, which
// bridge without complaint. The staircase is invisible at 0.20 mm on a surface
// that is 0.40 mm of deboss to the eye.
handle_mark_steps = 5;

// Which way it faces. The loading slot is at 270, and cylindrical_extrude() puts
// its children at 270 by default, so this is doing real work, not just choosing
// a nice side. Keep it a multiple of 360/$fn or the wrap's facets stop lining up
// with the body's.
handle_mark_az = 90;  // (deg)

// Resolution of the WRAP, kept separate from the part's $fn, because the two
// have wildly different costs. marks.scad already pins $fn = 0 over the SVG
// import so the lettering is cheap, but cylindrical_extrude tessellates the
// wrapped solid at $fn and that is where the triangles go: the handle is 256 KB
// with the mark off and 10 MB with it on, at $fn = 64. Raising the part to 128
// takes it to 33 MB and to 256 it reaches 144 MB, essentially all of it wrap.
//
// Decoupling lets the body be as round as you like while the deboss stays cheap.
// The cut floor is faceted at this value rather than the part's, which on a
// 0.40 mm deboss is not something you can see or feel.
//
// Keep handle_mark_az a multiple of BOTH 360/$fn and 360/handle_mark_fn, or the
// wrap's facets stop lining up with the body's. 90 satisfies every power-of-two
// value either is likely to take.
handle_mark_fn = 32;

/* [Ring: body] */
// Shortened with the collet, 34.20 -> 28.20. This is the sawn-off top of the
// old ring, and it costs nothing: the contact point is wherever the bore's cone
// equals the collet's tip radius, and a 10 mm collet cannot reach nearer than
// 6 mm from the old mouth even at full seat. That 6 mm of bore was unreachable.
//
// Note this DOES NOT generalise. Plan 03 rejected sawing the mouth off, and was
// right at the time: a 16.3 collet works its way right up to the mouth, so every
// millimetre of that bore was load-bearing. Lengthen the collet again and this
// becomes a bad edit for exactly the reason recorded there.
ring_height    = 28.20;  // overall height (mm)
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
// 12.65 was not a new choice of mouth: it was the diameter the old 11.00 bore had
// already reached 6 mm up its own cone, which is where the end face now is.
//
// 12.05, on 2026-08-11, IS a new choice, and it is a forced one. Thinning the
// collet finger to 0.840 and closing the bore 0.5 mm together took 1.868 mm off
// the collet's tip diameter, and the clamp is nothing but the amount by which
// that tip exceeds this mouth. At 12.65 the pair would have closed 0.20 mm and
// held nothing under 9.45 mm. 12.05 restores 0.50 mm of closure and a grip range
// of 9.85–8.85, which brackets the 9.42 mm stick with wear to spare.
//
// It cannot go much lower. The mouth is a hole the chalk itself passes through, so
// somewhere near 10 mm it stops being a mouth — which is what caps the stroke at
// roughly 0.95 turns and why this design winds 0.55 rather than 1.8. Lowering it
// also eats clamp_base_gap, which is only 0.173 mm at 12.05 and has an assert on it.
//
// 12.05 -> 11.05 on 2026-08-12, and this one comes from a printed part rather
// than from arithmetic. On the v1 coupon the collet ran out of travel at about
// the diameter of the stick: it closed onto a 9.42 mm stick and stopped there
// with nothing left to bite with, so the chalk slid back into the handle under
// hand pressure. The model said the pair should reach 8.85, so the drawn closure
// was already being spent somewhere the drawing does not see — most likely the
// tip printing fat and the mouth printing small, which are the same 0.6 mm of
// extrusion pull-in the bore is compensated for and these two surfaces are not.
//
// A full millimetre off the mouth therefore buys two different things at once,
// and they are worth keeping separate: 0.5 of it replaces the grip that
// chalk_slop gave away by shrinking the collet's tip, and 0.5 of it is new
// closure, which is the part that answers the complaint.
ring_mouth_d  = 11.05;  // bore at the bottom face (mm)
ring_throat_d = 15.48;  // bore just under the thread shoulder (mm)

/* [Ring: thread] */
// Dropped 16.30 -> 10.30 with ring_height, so the thread keeps its full 17.90 mm
// of length against the spigot's 17.60. Shortening the ring without this would
// trip the engagement assert in [Hidden].
ring_thread_z0      = 10.30;    // shoulder the thread starts from (mm)
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
// Raised 64 -> 256 on 2026-08-10. Faceting was visible on the thread and collet
// in both the render and the print, and it is affordable now that the wordmark's
// wrap has its own resolution: see handle_mark_fn. At 64 the part was 10 MB and
// 256 would have been 144 MB, essentially all wrap; decoupled, 256 costs 6 MB.
//
// The clamp barely notices, because the bore is already divided by
// cos(180/$fn) so the inscribed-polygon loss cancels. Across 64 to 256 the
// closure moves 0.760 -> 0.754 and the grip range 8.980 -> 8.993.
$fn         = 256;  // segments per full circle
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

// The channel at the bite lip, which is the narrowest passage in the tool and
// therefore the one that decides what stick will go in at all. The bore above is
// only the widest part of the channel now.
handle_bite_bore_d = handle_bore_d - 2 * handle_collet_bite_t;

// The biggest rounding that means anything is the entire wall, which arrives
// tangent at the bore and leaves no flat at all. handle_butt_flat backs it off
// from there, and because both terms follow the bore it can never eat it.
handle_butt_round = (handle_body_d - handle_bore_d) / 2 - handle_butt_flat;

handle_collet_tip_d = handle_bore_d + 2 * handle_collet_tip_wall;

handle_r_bore   = handle_bore_d / 2;

// The grip ribs' crest, as a radius, and the passage they leave between them.
// Measured off the lip's passage rather than off the bore — see
// handle_collet_rib_h — so a rib stands bite_t + rib_h tall below the lip and
// rib_h tall within it, on one constant crest radius the whole way up.
//
// Below handle_r_bore and not beside handle_bite_bore_d, where it reads more
// naturally, because it needs handle_r_bore: a top-level assignment that reads a
// name declared further down the file silently evaluates to undef, and this one
// did exactly that on the first pass — the ribs' whole chain came out undef and
// the press-fit assert fired against a nonexistent number.
handle_collet_rib_r = handle_r_bore - handle_collet_bite_t - handle_collet_rib_h;
handle_rib_bore_d   = 2 * handle_collet_rib_r;

// The narrowest thing a stick has to pass, which is the ribs when there are any
// and the lip when there are not. Everything downstream that asks "what will go
// in" reads this, so turning the ribs off restores the previous behaviour
// exactly rather than leaving a stale number behind.
handle_channel_d = handle_collet_ribs > 0 ? handle_rib_bore_d : handle_bite_bore_d;

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

// What it will actually hold, as printed rather than as drawn: the channel loses
// the inscribed-polygon slice and the extrusion pull-in, and the collet closes
// by clamp_closure on radius from there. Conservative at the bottom end, since
// printing also makes the collet fatter and the mouth smaller.
//
// Measured at the narrowest passage — the grip ribs, or the lip when the ribs
// are off. Reading handle_bore_d here would overstate the top of the range by
// well over a millimetre and describe a stick the tool refuses.
chalk_d_max = handle_channel_d * cos(180 / $fn) - hole_pull_in;

// What the lip alone would admit, kept separate because the two are asserted
// against different things: the lip against a nominal stick, the ribs against a
// measured one.
chalk_lip_d = handle_bite_bore_d * cos(180 / $fn) - hole_pull_in;

// Defined here rather than beside the ribs' own parameters because they read
// chalk_d_max, and a top-level assignment that reads a name declared further
// down the file gets nan without a warning — the same trap handle_bore_d and
// $fn are documented for above.
chalk_collet_ribs_ok = handle_collet_ribs == 0 || chalk_d_max >= chalk_d_measured;

// Both angles are taken at the crest radius, where the finger is at its
// narrowest: the slot is a constant-width box, so the arc it eats grows as the
// radius falls, and checking at the bore would pass a rib that overhangs.
rib_arc_avail = 180 / handle_collet_slots
              - asin((handle_collet_slot_w / 2) / handle_collet_rib_r);
rib_arc_used  = handle_collet_rib_spread * (handle_collet_ribs - 1) / 2
              + asin((handle_collet_rib_w / 2) / handle_collet_rib_r);
rib_arc_ok    = rib_arc_used < rib_arc_avail;
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

// The lip narrows the channel at the one place a stick cannot avoid, so it is the
// gate on the whole tool. Past a nominal stick it produces a holder that grips
// beautifully and will not accept chalk — which is the legacy part's defect,
// arrived at from the other direction.
assert(chalk_lip_d >= chalk_d,
       str("the bite lip is narrower than a nominal stick: it admits ",
           chalk_lip_d, " mm as printed against chalk_d ", chalk_d,
           ". Reduce handle_collet_bite_t or open chalk_slop"));

// The ribs are allowed inside the lip's passage — that is what they are for —
// but not inside the stick, or the tool has to be forced onto its own chalk and
// scores it on the way in. That is the legacy part's defect reached from the
// other direction, and it is a slip fit by design: the closure does the biting.
assert(chalk_collet_ribs_ok,
       str("the grip ribs are a press fit: they leave ", chalk_d_max,
           " mm as printed against chalk_d_measured ", chalk_d_measured,
           ". Reduce handle_collet_rib_h or open chalk_slop"));

// A rib is placed by angle but the finger it sits on is bounded by a
// constant-WIDTH slot, so the finger's arc narrows as the radius drops and the
// crest is the worst case. Outside that arc a rib would be left standing over a
// slot with nothing under it — which renders perfectly and prints as a thread of
// plastic hanging in the gap.
assert(handle_collet_ribs == 0 || rib_arc_ok,
       str("the grip ribs run off the edge of a finger: the outer rib reaches ",
           rib_arc_used, " deg from the centreline against ", rib_arc_avail,
           " deg of finger at the crest. Reduce handle_collet_rib_spread, ",
           "handle_collet_rib_w or handle_collet_ribs"));

assert(handle_collet_rib_ramp <= handle_collet_rib_len,
       "handle_collet_rib_ramp is longer than the rib it ramps into");

// The ribs stiffen whatever they cover, and the finger has to keep a thin root
// or the collet stops being a collet. Half the collet is an arbitrary line, but
// it is the right side of one: at 3.5 of 10 mm the root is untouched.
assert(handle_collet_rib_len < handle_collet_h / 2,
       str("the grip ribs cover ", handle_collet_rib_len, " mm of a ",
           handle_collet_h, " mm collet, which stiffens the part that is ",
           "supposed to bend. Shorten handle_collet_rib_len"));

// The web has to be the weak point, or snapping it out takes a finger with it.
assert(!collet_tie || (collet_tie_t > 0 && collet_tie_t < handle_collet_tip_wall),
       str("collet_tie_t must be between 0 and handle_collet_tip_wall (",
           handle_collet_tip_wall, "), so the sacrificial web is thinner than ",
           "the thinnest part of a finger and breaks before the finger does"));

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

        // Dilated by eps more than it was eroded, so the cut's boundary lands
        // just OUTSIDE the barrel instead of exactly on it. At matching offsets
        // the two surfaces are coplanar over the slot's whole length — the case
        // eps exists to prevent everywhere else in this file — which renders as
        // z-fighting stripes up the barrel and leaves CGAL deciding a 60 mm
        // seam by rounding. It costs the slot 0.02 mm of width.
        offset(r = handle_slot_round + eps, $fn = handle_slot_round_fn)
        offset(r = -handle_slot_round, $fn = handle_slot_round_fn)
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
    // Assigning $fn here applies to the children below it, so the wrap is
    // tessellated at handle_mark_fn while the rest of the part keeps the
    // part-level $fn. This is the whole reason the two are separate parameters.
    $fn = handle_mark_fn;

    // A prismatic cut is one band with no erosion, which is what 90 degrees
    // means and what this module used to do unconditionally.
    steps = handle_mark_taper >= 90 ? 1 : max(1, handle_mark_steps);
    band  = handle_mark_depth / steps;

    // How far each band reaches back into the one above it. eps is the wrong
    // size here and it produced a mesh of genus 28 against this part's 2 — 26
    // spurious tunnels along the seams.
    //
    // The reason is that the wrap is tessellated at handle_mark_fn = 32, where
    // a cylinder near r 9.5 misses the true circle by 0.046 mm between facet
    // vertices — four times eps. Two bands nominally meeting at one radius are
    // therefore up to 0.046 apart in places, and an eps overlap does not close
    // that. This takes twice the sagitta, so they always overlap.
    //
    // It costs nothing visible: a band only ever reaches back into ground the
    // band above it has already cut, and that one is eroded less, so it is
    // wider everywhere.
    overlap = 2 * (handle_body_d / 2) * (1 - cos(180 / handle_mark_fn));

    for (i = [0 : steps - 1]) {
        // Depth at this band's outer and inner faces. The erosion is the one at
        // the OUTER face, so the topmost band is the artwork at full size and
        // the letters read their true width from outside — eroding by the inner
        // figure instead would thin the visible outline and leave the widest
        // part of the cut buried where nobody can see it.
        d_out = band * i;
        d_in  = band * (i + 1);
        erode = handle_mark_taper >= 90 ? 0
                                        : d_out / tan(handle_mark_taper);

        translate([0, 0, handle_mark_z])
            cylindrical_extrude(
                ir   = handle_body_d / 2 - d_in,
                // The outermost band stands proud of the barrel; every other one
                // reaches back into its neighbour by overlap, above.
                or   = handle_body_d / 2 - d_out
                       + (i == 0 ? handle_mark_over : overlap),
                size = [hobbs_word_height(handle_mark_len) * 1.05,
                        handle_mark_len * 1.05],
                spin = handle_mark_az - 270)
                    offset(delta = -erode)
                        rotate(90) hobbs_word_alone(handle_mark_len);
    }
}

// A thin conical shell on the collet's outer surface, spanning its full height.
//
// Unioned onto the finished collet it changes nothing where a finger already is
// — the shell's outer face is that same cone — and leaves material across each
// slot, which is the web. Doing it as one shell rather than four wedges means no
// angular bookkeeping and nothing to keep in step with handle_collet_slots.
module handle_collet_tie_shell() {
    difference() {
        cylinder(r1 = handle_r_root, r2 = handle_collet_r_tip,
                 h = handle_collet_h);

        translate([0, 0, -eps])
            cylinder(r1 = handle_r_root - collet_tie_t,
                     r2 = handle_collet_r_tip - collet_tie_t,
                     h = handle_collet_h + 2 * eps);
    }
}

// One grip rib, lying on +x and running up the tool's axis, to be rotated onto a
// finger's inner face.
//
// It is a hull of two boxes rather than a drawn prism, and that is what makes
// the ramp: the lower box has no radial height at all and sits flush in the bore
// wall, the upper one stands out to the crest, and the convex hull between them
// is a rib that grows out of the wall over handle_collet_rib_ramp and then runs
// parallel to it. Both boxes overshoot outward into the finger by eps so the
// union has thickness to bite on rather than a coincident face.
//
// The crest is one radius the whole way up, so where the rib passes through the
// bite lip — which already stands proud by handle_collet_bite_t — the two merge
// into a single surface and the rib is only handle_collet_rib_h tall there.
module handle_collet_rib() {
    z0     = handle_z_top - handle_collet_rib_len;
    height = handle_collet_rib_len - handle_collet_rib_ramp;

    hull() {
        translate([handle_r_bore - eps, -handle_collet_rib_w / 2, z0])
            cube([2 * eps, handle_collet_rib_w, eps]);

        translate([handle_collet_rib_r, -handle_collet_rib_w / 2,
                   z0 + handle_collet_rib_ramp])
            cube([handle_r_bore - handle_collet_rib_r + eps,
                  handle_collet_rib_w, height]);
    }
}

// Every rib on every finger. Fingers are the gaps BETWEEN slots, so a finger's
// centreline is half a slot pitch off a slot's, which is where the 0.5 comes
// from; the ribs then sit symmetrically about that.
module handle_collet_ribs_all() {
    pitch = 360 / handle_collet_slots;

    for (f = [0 : handle_collet_slots - 1])
        for (k = [0 : handle_collet_ribs - 1])
            rotate([0, 0, handle_collet_slot_az + (f + 0.5) * pitch
                          + (k - (handle_collet_ribs - 1) / 2)
                            * handle_collet_rib_spread])
                handle_collet_rib();
}

module chalk_holder_handle() {
    // The webs go on AFTER the slots are cut, not before — cutting first and
    // filling second is what keeps the finger roots, their ramps and the bore
    // exactly as they were.
    union() {
        difference() {
            handle_blank();

            // The channel, in two stages: full bore all the way up, then the
            // last handle_collet_bite_h narrower, which is what leaves the lip
            // standing proud on the inside of each finger. The step between them
            // is a horizontal face inside the bore — it is a subtracted-to-
            // subtracted boundary, not a subtracted-to-parent one, so it needs no
            // eps of its own; the two cylinders simply have to meet.
            translate([0, 0, -eps])
                cylinder(d = handle_bore_d,
                         h = handle_z_top - handle_collet_bite_h + eps);

            translate([0, 0, handle_z_top - handle_collet_bite_h])
                cylinder(d = handle_bite_bore_d,
                         h = handle_collet_bite_h + eps);

            handle_loading_slot();

            for (i = [0 : handle_collet_slots - 1])
                rotate([0, 0, handle_collet_slot_az + i * 360 / handle_collet_slots])
                    handle_collet_slot();

            if (handle_mark)
                handle_mark_cut();
        }

        if (collet_tie)
            translate([0, 0, handle_z_collet])
                handle_collet_tie_shell();

        // Added after the slots are cut, for the same reason the webs are: the
        // ribs are on the inner face and the slot cut is radial, so building
        // them first would let the slot take a bite out of the two ribs nearest
        // each edge and leave them half width.
        if (handle_collet_ribs > 0)
            handle_collet_ribs_all();
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

// The collet, a stub of spigot, and nothing else. Cut face down, collet up, the
// same way round as the handle and the fit coupon.
module chalk_holder_collet_test() {
    z0 = handle_z_collet - collet_test_base;

    assert(z0 > handle_z_collar,
           str("collet_test_base reaches below the collar, which makes this the ",
               "fit coupon the long way round — use show = \"coupon\" instead"));

    translate([0, 0, -z0])
        intersection() {
            chalk_holder_handle();

            translate([0, 0, z0])
                cylinder(d = 2 * handle_body_d,
                         h = handle_z_top - z0 + eps);
        }
}

module chalk_holder() {
    if (show == "both" || show == "handle")
        translate([show == "handle" ? 0 : handle_x, 0, 0])
            chalk_holder_handle();

    // "coupon-handle" is the coupon's handle with no ring beside it, for when a
    // good ring already exists and only the handle needs printing again. It is
    // what utils/coupon.sh selects when the ring has not changed since the last
    // print.
    //
    // The thermal cost is real but much smaller than this comment used to
    // claim, and it is now measured rather than assumed. Layer times up the
    // collet, sliced both ways:
    //
    //     z 26.0-28.2 (ring still printing)   5.7 s with -> 3.7 s without
    //     z 30.0-36.0 (collet alone anyway)   2.6 s with -> 2.6 s without
    //
    // The ring tops out at 28.2 and the collet starts at 26.0, so the ballast
    // only ever covered the collet's bottom 2.2 mm — above that the fingers
    // were always printing alone and the ring changed nothing. Worth knowing
    // for the other reason too: the profile asks for 8 s a layer and gets 2.6,
    // because slow_down_min_speed bottoms out at 30 mm/s before the layer can
    // be stretched that far. See docs/_PLANS/chalk-holder-04-260810T1514Z.md.
    if (show == "coupon" || show == "coupon-handle")
        translate([show == "coupon-handle" ? 0 : handle_x, 0, 0])
            chalk_holder_coupon();

    if (show == "collet-test")
        chalk_holder_collet_test();

    if (show == "both" || show == "ring" || show == "coupon")
        translate([show == "ring" ? 0 : ring_x, 0, 0])
            chalk_holder_ring();
}

chalk_holder();
