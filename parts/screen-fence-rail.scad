// screen-fence-rail.scad
//
// Snap-in fence for the bottom track of the roll-up screen doors. It drops into
// the track from the room side, hooks under the near wall's internal ledge, and
// reaches across to trap the screen mesh under the far wall's top lip — so a cat
// can no longer pull the mesh out of the channel and climb under it.
//
// Replaces _incoming/screen-fence-rail.stl, which was glued into the channel
// and failed twice over: the bond let go, and it did not actually stop the cats.
// Nothing here is glued.
//
// ---------------------------------------------------------------------------
// THE TRACK, AS MEASURED
// ---------------------------------------------------------------------------
// Reverse-engineered from _incoming/bottom-track-dimensions.png. That drawing
// is to scale: its 23.8 mm width, 15.9 mm height and 6.4 mm ledge datum all
// resolve to 56.66 px/mm, three independent agreements. Its "9.5 mm" is the
// only figure that does not — the extension line sits 1.6 mm high — but 9.5
// is 15.9 - 6.4, so the VALUE is right and only its witness line is misplaced.
//
// The profile is an aluminium extrusion, 0.76 mm wall throughout, 23.80 mm
// across the outside, 15.90 mm tall, with an inner floor 0.79 mm above the
// outer bottom. Every number below is referenced to that inner floor, and to
// the inner face of one wall, because those are the surfaces a part inside the
// channel actually touches. Each wall carries three inward features:
//
//     z 4.76 - 5.56   LEDGE      reaches 5.56 mm inboard   (gap 11.11 mm)
//     z 6.96 - 9.01   MID HOOK   reaches 3.18 mm inboard   (gap 15.88 mm)
//     z 13.28 - 15.08 TOP LIP    reaches 3.18 mm inboard   (gap 15.88 mm)
//
// ---------------------------------------------------------------------------
// THE DRAWING IS NOT THE RAIL — CORRECTED 2026-09-10
// ---------------------------------------------------------------------------
// Ziad put a caliper across the real rail: 11.11 mm between the two fins (the
// lower ledges), 15.80 mm between the top two rolls. The drawing gives 15.76
// and 19.34. It is generous at BOTH apertures, by 4.65 and 3.54 mm, and the
// two errors are not a common scale factor (1.418 and 1.224), so the drawing
// is a similar section and not this one. Nothing may be re-derived from it.
//
// What that changes: both apertures are much tighter than assumed, and both
// undercuts are much DEEPER — 5.56 mm of fin and 3.18 mm of rolled lip to hook
// under, against 3.14 and 1.35. Tighter entry, better hold, once something can
// get in at all.
//
// ---------------------------------------------------------------------------
// THE RAIL IS IMPERIAL, ON A 1/32 INCH GRID
// ---------------------------------------------------------------------------
// The bore cannot be caliper'd with the rail screwed to the floor, so it is
// inferred instead — and the inference is a strong one, because every number
// anyone has produced for this section is a sixteenth of an inch:
//
//     drawing   23.8 -> 15/16 = 23.8125     15.9 -> 5/8  = 15.8750
//                6.4 ->  1/4  =  6.3500      9.5 -> 3/8  =  9.5250
//     measured  11.11 -> 7/16 = 11.1125    15.80 -> 5/8  = 15.8750
//
// 11.11 lands on 7/16 to two microns. So take the envelope as 15/16 x 5/8 on a
// 1/32 skin, which the drawing gives directly, and the bore follows:
//
//     bore = 15/16 - 2 x 1/32 = 7/8 = 22.2250
//
// The CHECK is that this was not fitted to anything. Feed that bore back into
// Ziad's two gaps and both reaches come out exact:
//
//     fin  reach = (22.2250 - 11.1125) / 2 = 5.5563 = 7/32   exact
//     roll reach = (22.2250 - 15.8750) / 2 = 3.1750 = 1/8    exact
//
// Two independent quantities landing on 32nds is what a right bore looks like.
// The old 22.04 puts them at 5.465 and 3.120 — both off-grid, and both off by
// the same half of the same 0.185 mm error.
//
// The ledge falls on the grid the same way once you use it: its top face is
// 1/4 - 1/32 = 7/32 above the inner floor and its underside 3/16, against 5.65
// and 4.77 read off the pixels.
//
// ⚠️ Confirmable without getting inside the channel: the outside width, jaws
// across the two outer wall faces, should read 23.81. If it does, the bore is
// settled. If it reads anything else, everything in this block moves.
//
// ⚠️ Still NOT on the grid and still drawing-derived: the mid hook's reach
// (held equal to the top lip's, as drawn) and the two rolled bands' heights.
// Nothing has confirmed those.
//
// ---------------------------------------------------------------------------
// WHY THIS SHAPE
// ---------------------------------------------------------------------------
// The mesh floats free in the channel. The first version of this part left it a
// clear 2.10 mm slot and only stopped it being pushed INBOARD — which was not
// the failure: the mesh is flexible, the cats pull it up OUT of the channel and
// go under. Holding it therefore means gripping the mesh itself, not just
// walling it in. See the back grip parameters.
//
// The part still cannot be a symmetric two-sided snap. The mesh must remain free
// to slide along the track, and a rigid part cannot engage an undercut on both
// walls at once and still get in — see the dead ends below. So the structural
// grip comes off the near wall alone, and the far side does its work by pinching
// rather than by hooking under anything it has to fight its way past.
//
// Of the three features on that wall the LEDGE is the one worth having: 5.56 mm
// of positive undercut against 3.18 mm at either hook, and the chamber beneath
// it is the one region of the section the mesh cannot reach (the far ledge stops
// the mesh descending past z 5.65). So the part carries a wedge-shaped tongue
// that slides under the near ledge, and stands on the channel floor.
//
// It is NOT a cantilever snap. Nothing here has to flex to go in: tilt the part
// so the tongue leads, slide the tongue under the ledge, then rotate the far
// side down until the base plate lies on the floor. That was a deliberate
// choice — a PETG finger long enough to clear the 1.35 mm hooks without
// over-straining has to be anchored above the rail, and every version of that
// put a truss in a doorway. Seated, the part is held by:
//
//   * UP          the tongue, under 2.84 mm of aluminium ledge.
//   * DOWN        the base plate, flat on the channel floor.
//   * OUTBOARD    the ramp root, 0.25 mm off the near ledge tip.
//   * INBOARD     the fence face, 0.31 mm off the far ledge tip — so the part
//                 can travel a third of a millimetre before it is stopped, and
//                 the tongue never comes close to disengaging.
//   * TIPPING OUT a push on the fence from the room side is the load case that
//                 matters, and it drives the tongue harder under the ledge.
//   * THE BACK    the rib's top face sits under the far top lip with 0.85 mm of
//                 overlap, so the far side is positively capped as well.
//
// Rotating the far side up is the removal motion, and the only way out. A cat
// is on the wrong side of the fence to do it.
//
// MESH SAFETY. The mesh is squeezed, so the faces that touch it matter. Every
// corner it wraps is rounded by the global fillet, the pinch bears on a flat
// 0.85 mm land rather than an edge, and the fence face is printed as a vertical
// wall so its layer lines run along the direction the mesh travels. The pinch is
// a tenth of a millimetre on a compressible woven mesh — enough for friction,
// not enough to cut. back_pinch is the number to tune, and the coupon ladders
// it.
//
// STRENGTH. The fence is the handle, so it is sized for hand loads, not for
// looks: the first printed coupon snapped the moment it was pushed on. Printed
// lying down, pushing or pulling the fence bends it ACROSS the layers, so the
// two levers that matter are its thickness (wall, doubled to 3.54) and its
// unsupported length (set by ramp_angle, which carries the ramp up to meet it
// 6 mm from the top instead of 11). Together, about 8x less root stress.
//
// PRINT. Lying down, cross-section in the bed's XZ, length along Y — as built.
// The base plate gives a 15.2 x seg_len first layer and the fence face is a
// vertical wall. The only overhang is the tongue's underside, cut at 45 deg.
// Fence and mesh face are both 1.74 mm, four lines at the 0.4 nozzle's real
// inner width. PETG.

/* [Output] */

// "fence" is the printable part. "coupon" is three 30 mm slices at different
// back pinches — print it and find which one grips the mesh and still rotates
// home, before committing to a full segment.
//
// "track" is the aluminium extrusion itself, drawn from the measured profile,
// and "assembly" shows the fence hooked into it with the mesh in the slot.
// Both are previews for checking the interlock by eye — NOT for printing. If
// you ever want one as an STL, build it with --name so it does not overwrite
// the fence's own version series.
// "fitcheck" is the interference test — see the module.
//
// This defaults to a PREVIEW, not the part, so that opening the file in
// OpenSCAD shows the live design sitting in the corrected rail without
// touching anything. That is now "clipassembly" — the wall clip on the near
// wall — and no longer "assembly", which draws the dead rotate-in fence. The cost is
// that building the part now needs the flag:
//
//     utils/build.sh parts/screen-fence-rail.scad -D 'show="fence"'
//
// A bare build.sh run would otherwise stamp the assembly into the fence's own
// version series and leave stl/screen-fence-rail.stl pointing at a rail with a
// fence inside it. There is an echo at the bottom of this file to catch that.
show = "key";  // [fence, coupon, pair, pairfit, twin, twincoupon, twinfit, twinpath, twinassembly, key, keyfit, keyblock, clip, clipcoupon, clipfit, clippath, clipassembly, track, assembly, fitcheck, compare, concepts, fixture]

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Track — MEASURED, see header. Do not change without re-measuring] */

// Clear width of the channel, inner wall face to inner wall face (mm).
// 7/8 in. Not measurable with the rail down — inferred off the imperial grid,
// see the header, and confirmable from the OUTSIDE width alone.
trk_clear_w  = 22.2250;
// Inner floor to the top of the walls (mm). 5/8 - 1/32 in.
trk_depth    = 15.0813;

// THE TWO APERTURES, CALIPER'D OFF THE REAL RAIL 2026-09-10 (mm), and taken to
// the nearest 1/32 in — 7/16 and 5/8. These are the measured facts of this
// section; the inboard reaches below are derived from them rather than the
// other way round, because a gap is what a caliper reads and what an insertion
// has to pass through.
trk_fin_gap  = 11.1125;   // 7/16 in, between the two fins (the lower ledges)
trk_lip_gap  = 15.8750;   // 5/8 in,  between the two top rolled lips

// How far the mid hooks and the top lips reach inboard of the wall face (mm).
// The mid hook is NOT measured — held equal to the top lip, as drawn.
trk_hook_x   = (trk_clear_w - trk_lip_gap) / 2;   // 3.1750 = 1/8 in
// How far the lower ledge reaches inboard of the wall face (mm).
trk_ledge_x  = (trk_clear_w - trk_fin_gap) / 2;   // 5.5563 = 7/32 in

// Underside of the lower ledge, above the inner floor (mm). 3/16 in.
trk_ledge_z0 = 4.7625;
// Top face of the lower ledge, above the inner floor (mm). 1/4 - 1/32 in, which
// is the drawing's 6.4 datum less the base skin.
trk_ledge_z1 = 5.5563;
// Underside and top of the mid hook, above the inner floor (mm).
trk_hook_z0  = 6.96;
trk_hook_z1  = 9.01;
// Underside of the top rolled lip, above the inner floor (mm).
trk_lip_z0   = 13.28;

/* [Track shell — drawing only, nothing is designed against these] */

// Outside of the extrusion (mm) — the two figures the drawing dimensions
// directly, and the two that fixed its scale.
trk_outer_w = 23.8125;   // 15/16 in
trk_outer_h = 15.8750;   // 5/8 in

// Wall and base skin (mm), from the centre-to-centre spacing of the drawn wall
// lines.
//
// These now CLOSE with the bore rather than disagreeing with it: 15/16 less
// two 1/32 skins is 7/8 exactly. Under the old pixel readings they missed by
// 0.22 mm and the gap had to be explained away as line width. It was not line
// width; it was the wrong bore.
trk_skin = 0.79375;   // 1/32 in

// Diameter of the void inside the rolled hook and the rolled top lip (mm).
// Cosmetic — it is what makes them read as curls rather than plain beads.
trk_roll_void = 0.55;

/* [Concept study — previews only, none of these is print-ready] */

// The rotate-in concept is dead: a full configuration-space path search says
// the seated pose is unreachable, and the maximum under-ledge engagement any
// RIGID motion can insert is 0.54 mm against the 2.84 mm designed. See the
// round 01f notes. These are the three replacements, drawn to compare.
//
//   slide  Today's section, unchanged. Only goes in by sliding along the rail
//          from its end. Keeps the deep tongue, the deep rib and positive
//          retention every way. Strongest by far; needs end access.
//   drop   Fits the 15.76 mm gap between the ledge tips at EVERY height, so it
//          lowers straight in. The deep back rib cannot exist. Hold-down is
//          barbs that flex in past the ledge tips and spring out under them;
//          the mesh is pinched against the far hook tips by the fence face.
//   key    Two pieces. The body drops in, slides outboard under the far ledge;
//          then a key drops in beside it and slides under the near ledge,
//          filling the gap so neither can come back. Positive at both ends and
//          nothing flexes, at the cost of a second piece to fit each time.
concept = "slide";  // [slide, drop, key]

// Clearance each side of the ledge-tip aperture for the drop-in body (mm).
drop_clr = 0.23;
// How far the key concept's body slides outboard once it is down (mm).
key_push = 2.40;
// How far the drop concept's barbs stand out past the body's face (mm). Net
// engagement under the ledge tip is this minus drop_clr, so 1.50 buys 1.27 mm
// of hook — and costs 1.50 mm of inward flex on insertion, which needs a leg
// of at least 10.2 mm at 1.29 mm thick to stay inside PETG's strain budget.
drop_barb = 1.50;

/* [Wall clip — the current design] */

// A hairpin that snaps over the NEAR WALL from above, outside the channel.
// This is round 01h's concept made real: nothing has to squeeze through the
// mouth, nothing is glued, and the deep 1/8 in roll the corrected profile
// exposed is what it hooks.
//
// WHY A HAIRPIN AND NOT A RIGID CLIP. Work it through and the rigid version is
// impossible, for the same reason round 01f's rotate-in was:
//
//   * To descend, the clip's slot has to pass over wall + roll = 3.97 mm.
//   * To hook, its slot has to end up NARROWER than 3.97 by the engagement.
//   * Shifting the part inboard to let the tab clear the roll on the way down
//     puts the outer prong inboard of the wall face, where the roll blocks it.
//   * Rotating about the wall's top-outer corner does not reach either: the
//     tab's top corner sweeps to x 2.95 at best, and the roll tip is at 3.175.
//
// So the slot must SPRING OPEN by the engagement, and close under the roll.
// That is the whole design. It is also why the crossbar is at the TOP of the
// fence and not over the rail: legs rooted at the rail top are ~5 mm long and
// 0.6 mm of splay strains them 4.8 %, past PETG. Rooted at the fence top they
// are 16 and 20 mm, and the same splay is 0.57 % and 0.45 %.
//
// Seated, it is held by:
//
//   DOWN      the foot, resting on top of the roll.
//   UP        the tab, hooked under the roll's underside 1.80 mm below it.
//   INBOARD   the outer prong, against the wall's outside face.
//   OUTBOARD  the inner leg, against the roll's tip.
//
// PRINT IT STANDING UP, section in the bed's XY, length vertical — same as the
// fixture and the same reason. Every face of this section is then a vertical
// wall: the tab's hook face comes out flat instead of as a 1.2 mm overhang,
// and the legs bend within a layer rather than across one. It is why the real
// part wants Ziad's original three interlocking segments rather than one
// 200 mm extrusion.

// How far the tab reaches past the roll's tip, seated (mm). THE variable the
// coupon ladders: it is both the engagement and the splay the legs must give.
clip_hook = 1.00;
// Clearance from the inner leg's outboard face to the roll's tip (mm).
clip_clr = 0.15;
// Clearance from the outer prong's inboard face to the wall's outside (mm).
// It is slop the part can take up by sliding inboard, so it comes straight off
// the engagement: net hook is clip_hook - clip_out_clr.
clip_out_clr = 0.10;
// Drop from a feature's underside to the tab's top face (mm).
//
// This was 0.15, and 0.15 was the leftover of a JAW: a foot resting on the
// fin's top face set the height, and the tab got whatever the fin's thickness
// left over. That jaw is the thing that failed on the rail — the foot landed
// on the fin and the tab never reached under it — so the foot is gone (see
// twin_side) and this is no longer a leftover. It is deliberate slack.
//
// trk_ledge_z0 and trk_lip_z0 are the last drawing-derived numbers the catches
// still depend on, and the drawing is discredited. The skirt on the rail's top
// face is the datum now, so the whole error between it and a feature's
// underside lands here. Too little and the tab fouls the underside and the
// part will not seat; too much and the part can lift by that much before the
// barb bears. Half a millimetre of lift on a fence costs nothing. A no-go
// costs a print.
clip_tab_clr = 0.50;
// Inner leg and outer prong thickness (mm). Upright, EVERY dimension of this
// section is a wall width, so these are line counts, not round numbers: 1.74
// is four lines and 2.19 is five, at 0.42 outer and 0.45 inner. A leg at 1.60
// is 3.6 lines and prints with a void down the middle of a spring.
clip_in_t = 1.74;
clip_out_t = 2.19;
// Tab height (mm). The pocket between the mid hook's top and the roll's
// underside is 4.27 mm; the tab has to enter it sideways, so it is shorter.
clip_tab_h = 3.54;
// How far the foot reaches over the top of the roll (mm), and how thick it is.
// HAIRPIN ONLY. The twin clip has no foot — nothing it carries touches the top
// face of anything inside the channel.
clip_foot = 1.80;
clip_foot_t = 1.74;
// How far the outer prong descends below the top of the rail (mm).
clip_out_drop = 6.00;
// Fence height above the top of the rail (mm), and the crossbar's thickness.
// It is a STRAIN parameter before it is a fence: it sets how long the legs
// are. 14 was enough for the hairpin, where the two legs shared the splay
// between them. The twin clip makes each leg travel the full engagement on its
// own, which doubles the strain, and 18 is what brings the deepest rung back
// under half of PETG's budget. It costs plate area, not print height.
clip_fence_h = 18.00;
clip_bridge_t = 2.19;

// How much further than its own engagement the clip is sprung for the
// insertion check (mm). Negative values are how you prove the check can fail:
// at -0.50 the tab overlaps the roll by 0.45 and clippath must report facets.
clip_path_slack = 0.05;

// Length of one printed segment (mm). Standing up, this is the print height,
// and it is why the part is segmented rather than one 200 mm extrusion.
//
// 219.82 IS THE PART, not a variant. Ziad, 2026-09-10: "do 220mm and we'll
// print it on its edge straight up." 219.82 rather than 220.00 because it
// lands on a layer boundary at every layer height from 0.12 to 0.30 — a
// 220.00 object tops out at 220.02 and Orca refuses it. It is the default
// here so that the insert and the key build at the real length with no -D
// and no second name: there is ONE insert and ONE key.
//
// ⚠️ 219.82 standing up is 4.82 past the reference's 215 mm derived-safe Z.
clip_seg_len = 219.82;

// Lead-in ramp on the underside of every tab, as a RISE PER UNIT OF RUN. 1.00
// is the 45 deg wedge this started as; higher is a gentler wedge that cams in
// more easily and costs height.
//
// It is capped, and the cap is not cosmetic. The space under the fin is only
// 4.76 mm and the ramp is subtracted from the tab, so at the deepest rung a
// 45 deg ramp already consumed the entire tab and left a knife edge with no
// bearing face at all. clip_bear_min is the flat that always survives.
clip_lead = 1.35;
// Flat bearing height every tab keeps, whatever the ramp wants (mm).
clip_bear_min = 0.80;
// Gap from a tab's bottom to whatever is below it — the channel floor under
// the fin, the mid hook's top under the roll (mm).
clip_tab_floor = 0.30;

// LEG SECTION — the part is optimised to be snapped in and squeezed out
// repeatedly, so the leg is a spring first and a structure second.
//
// A prismatic leg wastes itself: the bending moment is zero at the tab and
// maximum at the root, so a constant thickness is over-thick everywhere except
// the root and the peak strain sits exactly on the root corner, which is also
// the worst possible place for it. Thickness proportional to sqrt(distance
// from the load) is the constant-stress cantilever, and it buys twice the
// deflection at the same root thickness.
//
// Measured on the real section by utils/legcheck.py, not assumed:
//
//     prismatic 1.74 (before)   2.65 mm of travel at 1 % strain
//     prismatic 1.05            4.39 mm, but a limp leg at 0.11 N/mm
//     taper 1.74 -> 1.05        4.71 mm at 0.28 N/mm
//
// The taper also moves the peak strain about 10 mm off the root, away from the
// fillet, which is the second reason to prefer it over simply thinning.
clip_leg_root_t = 1.74;
clip_leg_tip_t  = 1.05;
// Fillet where the leg meets the crossbar (mm). The OUTBOARD one carries the
// tension when the leg is squeezed inward, so it is the crack site if it is
// left square — the cap's own fillet does not reach here, because the legs are
// deliberately not part of that shape.
clip_leg_fillet = 2.50;
// ...and the inboard one, which is a separate number because the key has to
// get past it.
//
// At 2.50 the two of them reached 5.00 mm into the middle of the channel right
// at the crossbar, which is the narrowest place the key has to pass and the
// one place it cannot be narrowed to suit — a key thin enough to clear them is
// 1.93 mm wide and gives back 3.39 mm of the 4.05 it is there to stop.
//
// It is the cheap one to give up. Squeezing a leg inward puts the OUTBOARD
// face in tension and this one in compression, and PETG cracks in tension, so
// the fillet that matters keeps its full 2.50. What is lost here is root
// section on the compression side. Set it back above zero and key_w follows
// automatically, at two millimetres of key for every one of fillet.
clip_leg_fillet_in = 0;

// Engagement of the FIN tab, per side (mm) — the primary catch.
//
// Straight-down insertion costs one millimetre of leg squeeze for every
// millimetre of reach past a feature's tip, so this number IS the squeeze, and
// what caps it is the two legs meeting in the middle of the channel. At the
// 1.05 mm leg tip they touch at 4.11 with a 0.40 mm margin, and 4.00 keeps a
// little of that back. utils/legcheck.py prices any other value; the strain at
// 4.00 is 0.85 %, against a 1.0 % repeated-use allowance.
//
// It was briefly 3.1813, derived to make the two barbs protrude equally from
// the leg face. That was the wrong invariant and it cost the roll most of its
// grip: what the design has to ration is SQUEEZE, and equal protrusion spends
// it unequally because the two features do not reach equally far inboard.
twin_hook = 4.00;

// Engagement of the ROLL bump, per side (mm), 0 for none.
//
// A second catch at a second height, so each wall is hooked twice: the tab
// under the fin at z 4.76 and this under the roll at 13.28. Both sit
// clip_tab_clr below their feature, so both bear at once.
//
// It is FREE. The bump rides the same legs through the same aperture on the
// same squeeze the fin tab has already paid for, so anything up to that squeeze
// costs nothing — which is why it is derived rather than chosen, and why 0.80
// sat here for four rounds giving away three quarters of the roll's 3.175 mm
// undercut for no reason at all.
//
// Two things limit it. The wall behind the roll, which is what actually binds:
// the tip stops twin_bump_gap short of it. And the squeeze, hook - 0.10, which
// is slack at any hook past 2.98 but still clamps and still says so.
twin_bump_gap = 0.30;
twin_bump = min(trk_hook_x - twin_bump_gap, twin_hook - 0.10);

/* [Key — the block that makes the snap one-way for a cat] */

// A separate strip that drops into the channel between the two legs after the
// insert is seated, so they physically cannot bend back in far enough to
// release. Ziad's call, and it is the right shape of answer: the legs give a
// human an easy push-on and an easy pull-off, and the key takes that same
// easiness away from anything without thumbs.
//
// It is also what fills the middle of the channel. Nothing attached to the
// legs ever could — that void is the flex space, and each leg needs 4.05 mm of
// it to get in at all.
twin_key = true;

// Clearance per side between the key and a leg (mm).
key_clr = 0.20;

// key_w, the width of the key, is derived beside key2d rather than here.
// It reads catch_reach, which is assigned further down the file, and a
// top-level assignment that reads a name defined BELOW it gets undef — not an
// error, and not a failed build: it produced a 12-triangle degenerate key that
// every check then declared clean. OpenSCAD's last-assignment-wins rule
// applies to later readers, not to earlier ones.
//
// What key_w leaves: with the key in, each leg can still retract by
//
//     (bore - 2 x (leg face + tip thickness) - key_w) / 2  =  0.89 mm
//
// against the 4.00 mm it needs to clear the fin. So the barbs stay 3.11 mm
// under their fins with the key home, and a cat is not the thing that gets it
// out. A thinner clip_leg_root_t would shrink that 0.89 — it opens the root
// gap and softens a spring whose retention job the key has taken over — but it
// is not free, because the legs are what holds the part if the key is lost.

// Where the key's bottom sits, above the channel floor (mm). It hangs from
// nothing: the stem bottoms out on the floor and the head stands clear above
// the cap, so the floor is the only datum and there is nothing coplanar to
// bear on.
key_z0 = 0;
// Gap between the cap's top face and the underside of the key's head (mm).
key_lift = 1.20;

// THE RING, WHICH IS A CAT FACE. A pull ring standing in the plane of the
// rail — its face runs ALONG the rail and its hole faces across the channel,
// so two fingers hook through it from the side and lift. The outline is a
// cat's head rather than a circle: Ziad's call, and the thing being kept out
// of the screen is a cat, so the handle may as well say so. It costs nothing
// mechanically — the band is the same constant 5 mm of section all the way
// round, the ears are solid where the hole erodes away, and the hole across
// the rail is still key_ring_id.
//
// It replaces a tube lying along the rail. That printed as a clean circle on
// every layer and could not be held: 2026-09-10, on the real rail with the
// key home, Ziad could not get a grip on a 14 mm cylinder and the edges hurt
// to pull on. The snugness was right; the handle was not.
//
// The ring is not a prism along the rail, so the key no longer prints
// standing up. It lies on its side instead, on the face of the stem — every
// part of it is then a slab of the same thickness sitting on the bed, the
// ring and the stem included, and the pull load runs in the plane of the
// layers rather than across them.
//
// THE FLANGE IS GONE — key_head_ext = 0, Ziad's call, 2026-09-11. It was a
// lip wider than the window, and it never had a job: key_z0 puts the stem on
// the channel floor, so the floor is what stops the key going down and the
// flange floated key_lift clear of the cap bearing nothing. Printing it lying
// down had already forced it one-sided, flush toward the front and reaching
// past the stem only toward the back, and a one-sided lip is a key with a
// wrong way round.
//
// WITHOUT IT THE KEY IS OMNIDIRECTIONAL. Stem, head band, and ring are all
// key_w wide and all centred on the same plane, so the key is a constant
// slab, mirror-symmetric across its faces and along its length: either face
// down on the bed, either way round in the window, either end leading. There
// is nothing left to get backwards. key_head_ext is kept as a parameter and
// now splits evenly on both sides, so a lip can come back two-sided if one
// is ever wanted — it cannot come back one-sided.
//
// Bore, radial width, and thickness (mm). The bore is measured ALONG the
// rail, across the widest part of the head: 32 there is two fingertips side
// by side. The head's overall width is key_ring_id + 2 x key_ring_w, and the
// ears carry it taller than that — the top stands well proud of the 20 mm
// back wall, which is the point. The thickness is the stem's, so the ring is
// the stem carried on up.
key_ring_id = 32.00;
key_ring_w  = 5.00;
key_ring_t  = 0;            // 0 = the stem's own width, key_w
// Round on the ring's edges (mm). Sharp edges were the other half of the
// complaint. Must be under half of both key_ring_w and the thickness.
key_ring_r  = 1.50;
// How far the ring's bottom sinks into the head band (mm) — the stem's top
// face, measured down to the cat's chin.
//
// IT IS key_ring_w, WHICH IS THE MOST IT CAN BE. The hole is the head inset
// by key_ring_w, so the hole's lowest point sits exactly key_ring_w above the
// chin: sink that much and the stem's top face lands tangent to the floor of
// the finger hole, which is as far up as the stem can go without eating the
// grip. Everything of the ring below the hole is then stem, so the two read
// as one piece rather than a head perched on a neck.
//
// It does not merge the OUTLINE. The stem is key_len - 2 x key_end_clr =
// 39.40 along the rail and the head is cat_w() = 42.00, but at the hole's
// floor the head is only 32.32 wide — so the cheeks still step out about
// 3.5 mm each side above the stem's top corners. Closing that gap too would
// need the stem 10.32 mm above the chin, which is 5.32 mm into the hole.
// Ziad's call, 2026-09-11: keep the hole.
//
// Never below the band's underside — the head hangs past the window along the
// rail, and anything of it under the band lands on the crossbar. key_head_t
// is held equal to this for exactly that reason.
key_ring_sink = key_ring_w;

// THE CAT, AS NUMBERS. Traced off the reference silhouette and normalised to
// a head ONE UNIT WIDE, origin at the head's centre, y up. Scale by cat_w()
// and everything follows. The head is a hull of four circles — a small radius
// at the top corners so the crown stays full out to the ear bases, a big one
// at the bottom so the chin is round — and each ear is a triangle overlapped
// into it, so the union needs no matching and cannot leave a seam.
//
// The crown is deliberately lower than the chin is deep (0.42 against 0.47).
// The reference domes slightly between the ears and the flat-topped hull
// cannot, so the notch would fill in and the ears would read as bumps; taking
// the crown down 0.05 gives the notch its depth back instead.
cat_head_top   =  0.42;
cat_head_bot   = -0.47;
cat_head_r_top =  0.20;
cat_head_r_bot =  0.40;
// One ear, left side: tip, then inner base, then outer base. Both bases are
// carried well inside the head — only the two edges above the crown are read.
cat_ear = [[-0.458, 0.620], [-0.073, 0.340], [-0.471, 0.180]];
// Corner rounding, as a fraction of the head width. Applied both ways, so it
// rounds the notch between the ears AND the ear tips — nothing on a handle
// wants a point. It trims about 1.7 mm off each tip at a 42 mm head, which is
// why the tips are traced long.
cat_round = 0.040;
// Step height for the ring's rounded edge (mm), which is built as a stack
// rather than swept — see key_ring().
cat_step = 0.10;
// How far the head band reaches past the stem (mm), SPLIT EVENLY between the
// two faces. 0 is the design: no lip, nothing protruding, the key symmetric
// across its faces. Anything above 0 is a two-sided lip and costs the key its
// flat-slab print — the window is only key_w + 2 x key_clr = 7.33 against a
// 6.93 stem, so there is 0.20 a side before it fouls the crossbar anyway.
key_head_ext = 0;
// Height of the head band: the plain stub of stem between the window and the
// ring, which is what key_ring_sink sinks the ring into (mm). Held equal to
// the sink, so the chin lands exactly on the band's underside and no part of
// the ring reaches down toward the crossbar. It was 2.19 when the sink was
// 1.50, which left the head standing on a visible neck.
key_head_t = key_ring_sink;
// Chamfer on the key's two bottom corners (mm), so it finds the gap rather
// than catching a leg on the way down.
key_lead = 1.20;

// SEVERAL SHORT WINDOWS, NOT ONE LONG SLOT — and this is not a detail.
//
// The channel between the two legs has exactly one opening, and it is upward
// through the crossbar. Everything else is closed: the rail on three sides,
// the legs and the skirts on the fourth. But that crossbar is ALSO the only
// thing joining the left half of the part to the right half — below it the two
// halves share nothing but the ends. Cut it away and the insert is two
// C-channels, which is not subtle and is not caught by any check here: the
// build said Genus -3 where -1 was expected, four shells on a plate meant to
// hold three, and nothing else complained.
//
// One window with a few millimetres of crossbar at each end has the same
// problem wearing a disguise. At 200 mm long — the real segment — it is two
// C-channels tied at the extreme ends and nothing in between.
//
// So the crossbar is interrupted rather than removed: key_bridge of it between
// every pair of windows and at both ends, and a separate key in each.
//
// WHAT SETS key_bridge is the leg, not the crossbar. A key holds the leg only
// where it is; between windows the leg can still bow inboard, and a cantilever
// plate spreads a point load over roughly its own free length — 26.63 mm here.
// A gap much past that is not supported at all, so 20 mm keeps every point of
// the leg within one cantilever length of a block, with room to spare.
//
// key_win is then free, and 40 mm is chosen for the hand: big enough to pinch
// and lift, few enough to keep track of. A 200 mm segment comes out at exactly
// three 40 mm keys with four 20 mm bridges, which is half the crossbar intact.
key_bridge = 20.00;
key_win    = 40.00;
// How many keys a segment gets. 0 = as many as the pitch fits, which is the
// scheme above. Ziad, 2026-09-10, after the coupon held: "We only need one key
// per section." So one, centred, with the crossbar intact everywhere else — a
// 220 mm segment is one 40 mm window between two 90 mm bridges.
//
// ⚠️ That holds the leg over 40 mm and leaves the other 180 to the cap: the
// 53 mm tall back wall and cap make a beam stiff enough along the rail that
// lifting one end while the key holds the middle means bending it, which is
// what is being relied on. First full-length print is where that gets looked
// at, not here.
key_count_fixed = 1;
// End clearance on each key, each end (mm).
key_end_clr = 0.30;

// How that divides into a given length. The count is fixed or picked by the
// pitch; each window is key_win, or less if the length cannot fit that many
// with bridges no shorter than a third of the share; the bridges take up
// whatever remains. A short coupon still cannot end up with a zero-length
// window, and a long segment with one key keeps the crossbar rather than the
// window.
function key_count(len) = key_count_fixed > 0 ? key_count_fixed
                        : max(1, round(len / (key_win + key_bridge)));
function key_gap_min(len) = min(key_bridge, len / (3 * key_count(len)));
function key_len(len)   = min(key_win, (len - (key_count(len) + 1) * key_gap_min(len))
                                       / key_count(len));
function key_gap(len)   = (len - key_count(len) * key_len(len))
                          / (key_count(len) + 1);

// Widen everything ABOVE the rail out to the rail's own outside width, so the
// part caps the whole extrusion instead of standing on it as a narrow U.
//
// It is a SKIRT, not a slab, and that is not a style choice. The legs are
// rooted at the crossbar and their length is the only thing keeping the strain
// down — filling the space above the rail with solid material would re-root
// them at the rail top, cut them from 26.3 mm to 10.6, and take the deepest
// rung from 1.3 % to about 8 %. So the two side walls come down inside the cap
// and the legs still hang free between them, with 4.3 mm of air on the side
// they flex toward.
//
// THE SKIRT IS THE DOWN-STOP. It used to float 0.15 mm clear because the feet
// on the fins were the datum and there can only be one; with the feet gone it
// lands on the rail's top face instead, ~2.19 mm of bearing each side across
// the wall top and the top of the roll beside it.
//
// That is the better datum by some distance. The fin's thickness and the
// height of its underside are both drawing-derived and unmeasurable with the
// rail screwed down; the rail's own top face is neither — it is the surface
// the part sits on and it can be seen. Nothing else in the part now depends
// on how thick the fin is.
twin_cap = true;
// Air between the skirt's bottom and the top of the rail (mm). Zero: it bears.
clip_cap_clr = 0;
// Close the bottom of the two side slots, so the cap reads as a closed box
// rather than an open frame. Thickness of that floor (mm).
clip_cap_floor = 2.19;
// ...and the slot left between that floor and the leg it passes (mm).
//
// THE FLOOR MUST NOT TOUCH THE LEG. It attaches to the skirt only. Joining the
// two would root the leg at the rail top instead of at the crossbar, which is
// the same 26.3 -> 10.6 mm collapse the skirt exists to avoid. 0.80 is two
// lines wide, so the slicer draws it rather than bridging it, and the leg
// flexes AWAY from this edge, so it is a print clearance and nothing more.
clip_relief = 0.80;

// Rounding on the cap's top corners (mm) — front generous, back barely. The
// back radius now lands on the top of the back wall rather than on the cap.
clip_cap_r_front = 6.00;
clip_cap_r_back  = 1.00;

// BACK WALL. The back does not stop at the cap: it carries on up as a wall,
// and that wall is the actual barrier — everything below it is just what
// holds the barrier to the rail.
//
// Printed standing, this wall's height runs across the bed, so a push on it
// bends it with the stress running WITHIN a layer rather than across the layer
// boundaries. That is the strong direction, and it is a consequence of the
// print orientation the fit already forced rather than a separate decision.
clip_back_h = 20.00;
clip_back_t = 2.19;
// Fillet on every INSIDE corner of the cap (mm).
//
// Not optional once the outside is rounded. An outside radius with a square
// corner behind it is a stress riser with a wedge of section feeding it, and
// it cracks at the corner. Default is the front radius less the wall, which
// puts the inside arc CONCENTRIC with the outside one — 1.396 + 3.81 = 5.206
// and 28.69 - 3.81 = 24.88, the same centre the outer arc is struck from — so
// the wall runs a constant 2.19 mm right around the bend.
//
// It is applied as a closing (dilate, then erode) on the cap alone. The legs
// are not part of that shape, so the 0.80 mm relief slot cannot be swallowed
// by the dilation — which it would be, permanently, if this were applied to
// the whole section.
clip_cap_fillet = clip_cap_r_front - clip_out_t;

// Which wall feature the twin clip catches.
//
//   roll  the top rolled lip. 1/8 in of undercut, in a pocket 4.27 mm tall
//         between the mid hook's top and the roll's underside.
//   fin   the lower ledge. 7/32 in of undercut, nearly twice as deep, and the
//         jaw closes on a 1/32 in flange instead of on a curl.
//
// The fin is the better catch and it is not close. It is deeper, it is flat on
// both faces where the roll is round on one, and reaching it makes the legs
// LONGER — root to tab goes 17.8 -> 24.1 mm, so the strain falls even as the
// engagement grows. What it costs is the squeeze: the aperture the tabs have
// to pass is the 7/16 in fin gap, 11.11 mm, not the 5/8 in mouth.
twin_catch = "fin";  // [roll, fin]

// Coupon: one slice per engagement, notched 1..n so they can be told apart.
// Engagement per side. The roll's ladder was 0.50-1.70 because a 3.175 mm
// feature and 17.8 mm legs would not carry more. The fin is 5.556 deep and the
// legs reaching it are 24.1 mm, so the whole ladder moves down and out.
clip_coupon_hook = [1.00, 1.80, 2.60, 3.40];
clip_coupon_len = 25;
clip_coupon_gap = 7;

/* [Test fixture — a printable stand-in for the real rail] */

// A length of the channel to print and keep on the bench, so insertion can be
// tried without going upstairs to the door.
//
// It is NOT a replica of the extrusion. Only the INTERNAL surfaces matter for
// testing whether a part goes in, so the outside is a solid block: it prints
// rigid, sits flat on any face, and gives a real first layer instead of the
// 0.77 mm ribbon the aluminium's own section would.
//
// PRINT IT STANDING UP — the channel axis vertical, which is how it is built
// here. That puts every internal face vertical, so the ledges' undersides and
// the rolled hooks come out as walls rather than overhangs, and the two
// apertures the insertion actually depends on are formed accurately. Printed
// lying down, the ledge undersides are 5.56 mm of unsupported horizontal
// overhang and the apertures would close up. Use it lying down once printed.
//
// It is NOT a replica in outside size either: 3 mm of solid wall around the
// cavity puts it about 4 mm wider than the rail's own 23.80. Only the cavity
// is meant to match, and only the cavity is worth measuring.
fixture_len  = 60;
// Solid wall around the cavity (mm).
fixture_wall = 3.0;
// TWO compensations, because the first printed fixture's two errors ran in
// OPPOSITE directions and one knob cannot correct both. Measured 2026-09-09 on
// the uncompensated print (designed / printed):
//
//     clear bore        22.04 / 21.75   -0.29   the cavity closed up, as bores do
//     top lip to lip    19.34 / 19.58   +0.24   the bead tips printed blunt, so
//                                               they reached less far inboard
//
// In the printed part's own frame that is 0.145 mm of bore lost per side, and
// 0.265 mm of reach lost per bead tip (0.145 of wall movement on top of the
// 0.12 the aperture itself opened). Both are grown here so the printed cavity
// comes out at the rail's numbers rather than the model's.
//
// Set both to 0 to build the fixture at nominal.
//
// ⚠️ The 0.265 is a tip-blunting figure taken from beads that reached 1.35 mm.
// The real ones reach 3.18 and 5.56. Blunting is a tip-radius effect and should
// not scale with reach, but that is an assumption — re-mike this print.
fixture_bore_comp = 0.145;
// Extra inboard reach given to every bead and fin tip (mm).
fixture_bead_comp = 0.265;
// Root fillet on every feature standing in the fixture's cavity (mm).
//
// The first printed fixture's fins broke off the moment the insert was tried,
// and one of them may never have been attached. They are a 0.79 mm PETG wall
// cantilevered 5.56 mm off a square corner, which is a stress riser feeding
// the thinnest section in the part — aluminium does not care and PETG does.
//
// Applied as a closing on the fixture's SOLID section, so it fills the concave
// corner at the root of every feature and touches no convex one: tip positions and the two
// apertures are untouched, and the tab still meets 4.56 mm of flat underside
// where it only needs the outer 3.18. It is capped well under half the 1.40 mm
// gap between the fin's top and the mid hook, or the closing would weld them.
//
// Only the FIXTURE gets this. track() stays the true section, so every fit and
// path check is still run against the rail as measured. Set to 0 to print a
// faithful-but-fragile fixture.
fixture_root_r = 0.50;

/* [Fit pair — one rail and one insert, to try against each other] */

// A short length of both halves on one plate, so the snap can be tried on the
// bench without a full segment or the whole ladder.
pair_len = 40;
// Air between them on the plate (mm).
pair_gap = 8;
// Put the keys on the pair's plate too, or leave them to their own file.
//
// Off, because the two are different prints of the same test: the pair is the
// fit, and it is worth reprinting on its own whenever a clearance moves; the
// key only changes when the key changes. They also divide differently — a
// 40 mm coupon carries one 12.73 mm key, a 200 mm segment three 40 mm ones —
// so keeping them apart means the key file can be built at whatever length is
// actually being made.
pair_key = false;
// Engagement for the insert in the pair. It follows twin_hook now rather than
// sitting mid-ladder: the pair is the thing that goes on the real rail, so it
// should carry the matched barbs the rail trial asked for, not a rung.
// utils/legcheck.py --hook to price a different one first.
pair_hook = twin_hook;

/* [Preview] */

// Length of track and fence drawn for "track" and "assembly" (mm). Short, so
// the section stays legible in a render.
preview_len = 60;

// Thickness of the mesh drawn in the slot (mm), and how far it stands above the
// top of the rail. Representative only — the mesh floats and is not modelled
// as anything but a flat strip.
mesh_t = 0.35;
mesh_rise = 10;

// Opacity of the track and the mesh in "assembly" — 0 invisible, 1 solid.
//
// The channel is a closed box in section, so an opaque rail hides the fence
// from every angle except looking straight down into it. Ghosting the track is
// what lets you see the tongue under the ledge and the fence at the same time.
// Transparency only works in Preview (F5); F6 discards it along with the
// colours. Set both to 1 if you want the view from outside, as installed.
// 0.25 was a mistake: silver that faint washes out to the background and the
// rail reads as missing. 0.55 is see-through and still obviously there.
track_alpha = 0.55;
mesh_alpha  = 0.70;

/* [Fit] */

// Clearance to every track surface (mm). Drives the tongue height and how
// close the part sits to the near ledge, so it is the one number the coupon
// tests. 0.25 is the 0.4-nozzle snug figure from the printer reference.
clr = 0.25;

// Clear slot left for the mesh, between the fence face and the far wall's
// hooks (mm). This also sets how far the part can shift before the far ledge
// tip stops it, so keep it well under the 2.84 mm the tongue engages.
mesh_slot = 2.10;

/* [Back grip — what actually holds the mesh down] */

// A free slot does not retain a flexible mesh: the cats pull it out and go
// under. So the back of the part carries a rib that reaches outboard into the
// recess between the far wall's mid hook and its top lip — 4.27 mm of clear
// height, the biggest feature on that wall. The mesh gets swept outboard as the
// part rotates home, drapes over the rib's top face and hangs down the slot
// outboard of it, and is then squeezed between that top face and the underside
// of the aluminium top lip. Pulling the mesh up only tightens it around the
// rib's corner. The rib's top face is also the back hold-down: it sits under
// the top lip with 0.85 mm of overlap.
back_grip = true;

// Gap between the rib's top face and the underside of the far top lip (mm).
// This is the pinch, so it wants to be a little LESS than the mesh is thick —
// the mesh is compressible and the faces either side of it are radiused. Too
// tight and the part will not rotate home; too loose and the mesh slides.
// The number to try first on the coupon.
back_pinch = 0.25;

// Slot left outboard of the rib for the mesh to hang down in (mm). Also caps
// how deep the rib goes at its lowest, where the swept arc is not the limit.
back_slot = 0.50;

// The front point the part rocks about, as (x, z) above the inner floor.
//
// The rib's back face is GENERATED from this — see rib_back() — so the shape
// cannot drift from the analysis that produced it. Rocking the part in sweeps
// every point of it round an arc centred here, and the arc has to be clear,
// not just the seated position. That is what limits how deep the back can go:
//
//     z 10 -> 21.58    z 11 -> 21.30    z 12 -> 20.96    z 13 -> 20.56
//
// The far wall's hook tips are at 20.69, so at the top lip's height the back
// can reach 20.62 and the tip is at 20.69. It cannot touch it, let alone get
// behind it. NO RIGID ROCK-IN CAN ENGAGE EITHER UNDERCUT ON THE FAR WALL: the
// arc moves inboard about 0.43 mm per mm of rise while the lip steps inboard
// 1.35 mm the instant you cross z 13.28. An earlier rib reached 21.54 and was
// 0.90 mm too deep, which is why it would not go in.
//
// Two pivots are plausible — the tongue tip, and the near ledge's edge, which
// is the truer model since rocking the back down presses the tongue's top face
// onto the ledge. They agree to 0.02 mm. These are the tongue-tip values, the
// more conservative of the two in the recess.
piv_x = 0.45;
piv_z = 4.50;

// Points sampled along the rib's curved back face.
rib_steps = 8;

/* [Front catch] */

// How far the tongue reaches inboard from the near wall's face (mm).
//
// THE HARD LIMIT. A configuration-space path search over every tilt from -100
// to +100 degrees and every translation says the deepest a RIGID part can hook
// under the near ledge and still be got into the channel is 0.54 mm — tongue
// at x 2.60 against a ledge tip at 3.14. The first design reached x 0.30, for
// 2.84 mm of hook, and that is why it would not go in no matter how it was
// rocked. Widening the tilt range to cover the face-first motion did not change
// the number.
//
// The useful discovery is that the two hooks were COMPETING. Give up the deep
// front tongue and the part becomes shallow enough to manoeuvre, which lets the
// back rib swing out to 21.54 — 0.85 mm under the far TOP LIP. So a rigid part
// can hook the front or the back, not both, and the back is the better one:
// 0.85 mm beats 0.49 mm, and it is the end the mesh pulls on.
//
// front = "flex" puts the tongue back to its deep 2.84 mm on a leg that bends
// out of the way going in, so both ends hook. See flex_tongue_L.
tongue_x = 2.65;
front    = "rigid";  // [rigid, flex]

// Deep reach for the flexing tongue (mm), and the free length of the leg that
// carries it. The leg must retract tongue_x - flex_tongue_x on the way in, so
// 2.35 mm at 1.29 mm thick needs at least 12.7 mm of leg to stay inside PETG's
// strain budget.
flex_tongue_x = 0.30;
flex_tongue_L = 14.0;

/* [Back grip variant — print both and compare] */

// "rigid" and "flex" are two answers to the same problem, and the arc analysis
// above is why there are two rather than one.
//
//   rigid  A continuous rib whose back face IS the swept-arc envelope, so it
//          goes exactly as deep as rocking the part in allows and no deeper —
//          20.6 at the top, 21.54 at the bottom. Nothing flexes, nothing can
//          fatigue. It does not get behind the hook tips, so the mesh is held
//          by the two folds it makes round them plus a squeeze where it
//          crosses the tip line. Shallow but continuous along the whole rail.
//
//   flex   Deep ribs, reaching 21.54 and properly behind the top lip's tip, on
//          cantilever fingers that deflect inboard about 0.9 mm to get past it
//          and spring back. Positive retention, but only at the stations —
//          which dimples the mesh along the rail rather than clamping it in a
//          line, and that zigzag is arguably the better hold. Costs a slot
//          through the fence at each station.
back = "rigid";  // [rigid, flex]

// Finger width along the rail, and spacing between stations (mm).
flex_w     = 12.0;
flex_pitch = 50.0;
// Finger thickness (mm). Thinner is a softer spring: strain goes as this, and
// at 1.29 with a 9.5 mm arm the 0.9 mm of deflection runs about 1.9 %, inside
// PETG's roughly 2.8 % working budget.
flex_t     = 1.29;
// Free arm from the anchor down to the rib's top corner, where the lip tip
// pushes it (mm). This is the strain lever — shortening it is what breaks it.
flex_L     = 9.50;
// How far the finger's free end hangs below the rib's underside, and the gap
// cut beneath it so it is genuinely free (mm).
flex_drop  = 2.40;
flex_free  = 1.20;

// Clearance between the rib's underside and the top of the far mid hook (mm).
back_clr = 0.50;

/* [Part] */

// Length of one segment along the rail (mm). 200 keeps the whole footprint
// inside the 205 mm safe envelope; butt them end to end to fill the opening.
seg_len = 200;

// How far the fence stands above the top of the rail (mm).
fence_h = 12;

// Angle of the ramp's top face off horizontal (degrees).
//
// This is a STRENGTH parameter, not a styling one. The fence is the handle —
// it is what you push on to rock the part in and pull on to get it out — and
// printed lying down, every one of those loads is bending across the layers,
// which is the weakest thing PETG does. The fence's unsupported length is
// whatever sticks up above the point the ramp meets it, and the root stress
// goes as that length, so steepening the ramp buys strength directly:
//
//     45 deg -> ramp meets the fence at z 16.2, 11.0 mm of free fin
//     55 deg -> ramp meets the fence at z 21.2,  6.0 mm of free fin
//
// With the doubled wall that is about 8x less root stress than the coupon that
// snapped. Steeper also prints better: the ramp's underside is the overhang,
// and 55 deg off horizontal is 35 deg off vertical, well inside the limit.
// Do not go past about 70 deg — the part turns into a solid block.
ramp_angle = 55;

// Wall thickness for the fence, the base plate and the ramp (mm).
//
// Was 1.74. Doubled on the strength of a printed part: Ziad called the first
// coupon "very fragile". 3.54 is the next rung up from 2 x 1.74 on the 0.4
// nozzle ladder (2 x 0.42 outer + 6 x 0.45 inner), and the fence is a 27 mm
// tall fin whose stiffness goes as the cube of this, so it gets 8x stiffer.
// Every rung: 0.84, 1.29, 1.74, 2.19, 2.64, 3.09, 3.54.
wall = 3.54;

// Height of the flat face at the tongue's tip (mm). Above this the tongue's
// underside is cut at 45 deg so it prints unsupported.
tip_face = 0.90;

// Solid gusset between the base plate and the ramp at the near-wall end (mm).
// The void behind the ramp starts this far inboard; without it the two plates
// would meet along a knife edge and hinge.
gusset = 2.60;

// Least height the void behind the ramp may have at its near end (mm).
//
// This is a guard, not a style choice. The void's ceiling is the ramp's
// underside, which sits wall x sqrt(2) below its top face — so at wall = 3.54
// that ceiling has dropped 5.01 mm and the void's near end would invert
// straight through the base plate. Rather than let the polygon self-intersect,
// the near end of the void is pushed inboard until it is at least this tall,
// and dropped altogether if it will not fit at all.
void_min = 1.00;

/* [Back relief — what lets it rock in] */

// Chamfer up the back face from the bottom (mm across, mm up).
//
// THIS IS WHY THE FIRST COUPON WOULD NOT GO IN. Rocking the back down swings
// the base plate's back bottom corner OUTBOARD on an arc, and at the far ledge
// tip's height that arc reaches about x 19.14 against a tip at 18.90 — so the
// corner jams on the ledge instead of passing under it. The whole back face
// below the ledge has to be cut back, not just the corner itself: with the
// pivot up at the tongue, every point on that face below z ~4 swings too wide.
//
// Losing that corner does not cost the lateral stop, because the back rib now
// provides it — 0.50 mm off the far wall against 2.82 mm of tongue engagement.
back_relief   = 1.20;
back_relief_h = 5.50;

// Radius rounded onto every convex corner (mm). Keep it small — the tongue's
// tip face is the thinnest feature and the rounding is cut out of it.
fillet = 0.30;

/* [Coupon] */

// Back pinches to try, one 30 mm slice each — notches on the fence top count
// the slice, tightest first.
//
// This tests back_pinch, not clr, because back_pinch is now the number the
// part lives or dies on and the one with no margin: it is a 0.25 mm gap set
// against a mesh whose thickness nobody has measured. The near-side clr has
// 2.82 mm of tongue engagement behind it and shrugs off a tenth either way.
// Want to ladder clr instead? Swap which one coupon_slice varies.
coupon_pinch = [0.20, 0.30, 0.40];
// Length of one coupon slice (mm).
coupon_len = 30;
// Gap between slices on the plate (mm).
coupon_gap = 8;
// Notch cut into the fence top to number a slice (mm).
coupon_notch_w = 2.0;
coupon_notch_d = 1.6;
coupon_notch_pitch = 5.0;

/* [Quality] */
$fn = 48;

// Overshoot on every subtracted solid so no cut face is coplanar with its
// parent's.
eps = 0.01;

// ---------------------------------------------------------------------------

// The cross-section, in the plane across the track: x measured inboard from the
// inner face of the NEAR wall, y measured up from the channel's inner floor.
// ---- derived, shared by the fence and the back-grip stations ----
x_fence_o  = trk_clear_w - trk_hook_x - mesh_slot;   // fence face, against the mesh
x_fence_i  = x_fence_o - wall;
x_tip_line = trk_clear_w - trk_hook_x;               // the far wall's hook tips
z_top      = trk_depth + fence_h;
rib_z0     = trk_hook_z1 + back_clr;
rib_deep   = trk_clear_w - back_slot;                // as deep as the mesh slot allows

// The swept-arc envelope, straight out of the rock-in analysis. See piv_x.
env_reach = pow(x_tip_line - clr - piv_x, 2) + pow(trk_lip_z0 - piv_z, 2);
env       = function (z) piv_x + sqrt(max(0, env_reach - pow(z - piv_z, 2)));
rib_back  = function (z) min(rib_deep, env(z));
rib_top   = function (pinch) trk_lip_z0 - pinch;

module profile(c = clr, pinch = back_pinch, ribmode = "auto") {
    mode      = ribmode != "auto" ? ribmode : (back == "flex" ? "none" : "env");
    x_tip     = (front == "flex") ? flex_tongue_x : tongue_x;   // tongue tip
    x_base    = trk_ledge_x + c;                           // ramp root / base plate, near end
    z_tongue  = trk_ledge_z0 - c;                          // tongue top, under the ledge
    z_tip     = z_tongue - tip_face;
    z_wedge   = z_tip - (x_base - x_tip);                  // 45 deg underside meets the base
    z_ramp    = z_tongue + (x_fence_i - x_base) * tan(ramp_angle);

    // Void behind the ramp. Bottom is the base plate's top face, ceiling is the
    // ramp's underside — 45 deg, so it needs no support. Its near end is the
    // gusset, or far enough inboard for the void to be void_min tall,
    // whichever is further in. See void_min.
    drop   = wall / cos(ramp_angle);   // vertical offset of a perpendicular wall
    hz     = function (x) z_tongue - drop + (x - x_base) * tan(ramp_angle);
    hx0    = max(x_base + gusset,
                 x_base + (wall + void_min - z_tongue + drop) / tan(ramp_angle));
    voided = hx0 < x_fence_i - void_min;

    if (z_ramp > z_top - wall)
        echo(str("WARNING: fence_h = ", fence_h, " is too short for the ramp; ",
                 "raise it above ", z_ramp + wall - trk_depth));

    // Back grip, walked up the far face in increasing z: the 45 deg underside,
    // which may only start sloping down INBOARD of the hook-tip line or it
    // fouls the mid hook; then out along the envelope. "none" leaves the face
    // flat — the flex variant carries its ribs separately, at the stations.
    rib_z1 = rib_top(pinch);
    rib = (!back_grip || mode == "none") ? [] : concat(
        [[x_fence_o,  rib_z0 - (x_tip_line - x_fence_o)],
         [x_tip_line, rib_z0]],
        [for (i = [0 : rib_steps])
            let (z = rib_z0 + (rib_z1 - rib_z0) * i / rib_steps)
            [rib_back(z), z]],
        [[x_fence_o,  rib_z1]]
    );

    offset(r = fillet) offset(delta = -fillet)
    difference() {
        polygon(concat(
            [[x_base,                 0            ],
             [x_fence_o - back_relief, 0           ],
             [x_fence_o,              back_relief_h]],
            rib,
            [[x_fence_o, z_top    ],
             [x_fence_i, z_top    ],
             [x_fence_i, z_ramp   ],
             [x_base,    z_tongue ],
             [x_tip,     z_tongue ],
             [x_tip,     z_tip    ],
             [x_base,    z_wedge  ]]
        ));

        if (voided)
            polygon([
                [hx0,       wall         ],
                [x_fence_i, wall         ],
                [x_fence_i, hz(x_fence_i)],
                [hx0,       hz(hx0)      ],
            ]);
    }
}

// Extrude a cross-section along the rail: y from y0, height ylen.
module along_y(y0, ylen) {
    translate([0, y0 + ylen, 0])
        rotate([90, 0, 0])
            linear_extrude(height = ylen, convexity = 10)
                children();
}

// The deep rib the flex variant carries at each station — reaching rib_deep,
// properly behind the top lip's tip, which the rigid variant cannot do. Runs
// 0.6 mm into the fence so the union is solid rather than face-to-face.
module rib_deep2d(pinch = back_pinch) {
    z1 = rib_top(pinch);
    offset(r = fillet) offset(delta = -fillet)
        polygon([
            [x_fence_o - 0.6, rib_z0 - (x_tip_line - x_fence_o)],
            [x_tip_line,      rib_z0],
            [rib_deep,        rib_z0],
            [rib_deep,        z1],
            [x_fence_o - 0.6, z1],
        ]);
}

// Centre of station i of n along a length.
function station_y(i, n, len) = len * (i + 0.5) / n;

// One length of fence, laid out for the plate: length along Y, height in Z.
module fence_length(len = seg_len, c = clr, pinch = back_pinch) {
    if (back == "flex") {
        za = rib_top(pinch) + flex_L;      // anchor: top of the relief slot
        zf = rib_z0 - flex_drop;           // free bottom end of the finger
        n  = max(1, floor(len / flex_pitch));

        union() {
            difference() {
                along_y(0, len) profile(c, pinch, "none");

                for (i = [0 : n - 1]) {
                    y0 = station_y(i, n, len) - flex_w / 2;
                    // relief behind the finger, so it has somewhere to flex to
                    translate([x_fence_i - eps, y0, zf])
                        cube([wall - flex_t + eps, flex_w, za - zf]);
                    // and a gap under its free end, or it is built in at both
                    // ends and will not flex at all
                    translate([x_fence_i - eps, y0, zf - flex_free])
                        cube([wall + 2 * eps, flex_w, flex_free]);
                }
            }
            for (i = [0 : n - 1])
                along_y(station_y(i, n, len) - flex_w / 2, flex_w)
                    rib_deep2d(pinch);
        }
    } else {
        along_y(0, len) profile(c, pinch, "env");
    }
}

module fence() {
    fence_length(seg_len, clr);
}

// ---------------------------------------------------------------------------
// The track, for looking at. Same origin as the fence: x inboard from the near
// wall's inner face, y up from the inner floor.
// ---------------------------------------------------------------------------

// A rolled edge — the mid hook and the top lip are both one of these. Sized to
// fill the measured envelope exactly: it spans z0..z1 and reaches x_reach
// inboard. solid = true gives a plain bead instead of the curl. Same envelope —
// the bead's innermost point is still x_reach at its mid height, which is the
// only thing an aperture depends on — but printable and properly attached.
//
// THE WEB IS NOT OPTIONAL. The bead is a circle centred x_reach - r, so it
// touches the wall only while x_reach <= 2r. It did, on the drawing's 1.35 mm
// reach against a 1.87 mm bead. The rail's real 3.12 mm reach leaves it
// floating — a loose rod down the middle of the fixture's channel, and a
// detached island in the preview. The web is also what the rail actually is:
// the wall's own skin folds inboard along the TOP of the band and the curl
// hangs down off its end, opening downward, which is how the drawing reads.
//
// The curl itself is only worth drawing in a picture. In a printed fixture it
// is unbuildable and unsafe: the wall between the void and the outside works
// out under two perimeters, and the slot that opens the void downward severs
// the bead from the wall over part of its height, leaving a lug the test part
// would snap off on its way past.
module rolled(x_reach, z0, z1, solid = false) {
    r = (z1 - z0) / 2;
    cx = x_reach - r;
    union() {
        translate([-eps, z1 - trk_skin])
            square([max(cx, 0) + eps, trk_skin]);              // web, off the wall
        if (solid)
            translate([cx, (z0 + z1) / 2]) circle(r = r);
        else
            difference() {
                translate([cx, (z0 + z1) / 2]) circle(r = r);
                translate([cx, (z0 + z1) / 2]) circle(d = trk_roll_void);
                translate([cx - trk_roll_void / 2, z0 - eps])
                    square([trk_roll_void, r + eps]);
            }
    }
}

// The three inward features carried by one wall, drawn at the near wall.
// dx pushes every tip further inboard — the fixture's bead compensation. It is
// a reach offset and NOT an isotropic offset(), deliberately: growing the ledge
// in every direction would thicken it and drop the underside the tongue datums
// against, which is a face, not a tip, and prints accurately as it is.
module track_features(solid = false, dx = 0) {
    // Ledge, with the rounded tip the drawing shows. Left at its measured
    // 0.88 mm: that is two perimeters printed as a vertical wall, and its top
    // and bottom faces are the real datums the tongue hooks under, so it is
    // not a thickness to round up for printability.
    // The root circle is pushed eps INTO the wall on purpose. Sitting exactly on
    // the wall face it is tangent, and a tangency is not a join: the fixture
    // built that way came out as three shells, the two fins loose in the
    // channel. Same reason the rolled web starts at -eps.
    t = trk_ledge_z1 - trk_ledge_z0;
    hull() for (x = [t / 2 - eps, trk_ledge_x + dx - t / 2])
        translate([x, trk_ledge_z0 + t / 2]) circle(d = t);

    rolled(trk_hook_x + dx, trk_hook_z0, trk_hook_z1, solid);
    rolled(trk_hook_x + dx, trk_lip_z0,  trk_depth,   solid);
}

module track_profile() {
    s  = trk_skin;
    wc = trk_outer_w - 2 * s;          // clear width implied by the outside
    fl = trk_outer_h - trk_depth;      // base skin

    union() {
        translate([-s, -fl]) square([wc + 2 * s, fl]);   // base
        translate([-s, -fl]) square([s, trk_depth + fl]);        // near wall
        translate([wc, -fl]) square([s, trk_depth + fl]);        // far wall

        for (m = [0, 1])
            translate([m * wc, 0]) mirror([m, 0]) track_features();
    }
}

// The channel's free space: the bore, less the features that intrude into it.
// The bore is widened by fixture_bore_comp per side and the walls move out with
// it, so every feature's reach stays measured from the face it hangs off.
module fixture_cavity2d() {
    b = fixture_bore_comp;
    w = trk_clear_w + 2 * b;
    difference() {
        translate([-b, 0]) square([w, trk_depth + 10]);   // bore, open at the top
        for (m = [0, 1])
            translate([-b + m * w, 0]) mirror([m, 0])
                track_features(solid = true, dx = fixture_bead_comp);
    }
}

module fixture(len = fixture_len) {
    fw = fixture_wall;
    b  = fixture_bore_comp;
    linear_extrude(height = len, convexity = 10)
        // Closing on the SOLID, which fills its concave corners — the root of
        // every feature — and leaves every convex one, so no tip moves. Note
        // the polarity: the same pair of offsets applied to the CAVITY is an
        // opening of the solid and deletes the fins outright.
        offset(r = -fixture_root_r) offset(r = fixture_root_r)
        difference() {
            translate([-fw - b, -fw])
                square([trk_clear_w + 2 * (fw + b), trk_depth + fw]);
            fixture_cavity2d();
        }
}

module track(len = preview_len) {
    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 10)
                track_profile();
}

// A strip of thickness t following a polyline — for drawing the mesh.
module strip2d(path, t) {
    for (i = [0 : len(path) - 2])
        hull() {
            translate(path[i])     circle(d = t);
            translate(path[i + 1]) circle(d = t);
        }
}

// The mesh, on the path the back grip puts it on: down the channel inboard of
// the far wall's hook tips, outboard over the rib's top face through the pinch,
// then down the slot behind the rib with its free edge resting on the mid hook.
// To escape it has to slide back through the pinch and round the rib's corner.
//
// It is drawn at its full thickness inside a gap deliberately thinner than
// that, so the strip overlaps the lip by mesh_t - back_pinch in the preview.
// That overlap IS the squeeze, not a modelling error.
module mesh(len = preview_len) {
    mx_out = trk_clear_w - back_slot / 2;
    mx_in  = trk_clear_w - trk_hook_x - mesh_t / 2 - 0.25;
    mz_pin = trk_lip_z0 - back_pinch / 2;
    path = back_grip
        ? [[mx_out,       trk_hook_z1 + 0.15],
           [mx_out,       mz_pin - 0.8      ],
           [mx_out - 0.4, mz_pin            ],
           [mx_in,        mz_pin            ],
           [mx_in,        trk_depth + mesh_rise]]
        : [[mx_in,        trk_ledge_z1      ],
           [mx_in,        trk_depth + mesh_rise]];

    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 4)
                strip2d(path, mesh_t);
}

// ---------------------------------------------------------------------------
// Concept studies. Envelopes and engagements are to the measured track; the
// detailing is not, so do not print these.
// ---------------------------------------------------------------------------

ap0 = trk_ledge_x;                       // ledge-tip aperture, near edge
ap1 = trk_clear_w - trk_ledge_x;         // and far edge
dx0 = ap0 + drop_clr;                    // drop-in body, near face
dx1 = ap1 - drop_clr;                    // and far face

// Barb that springs outboard under a ledge tip. dir -1 reaches toward the near
// wall, +1 toward the far wall. Drawn deployed, i.e. as seated.
module barb2d(xface, dir) {
    zt = trk_ledge_z0 - 0.20;            // top face, under the ledge
    polygon([[xface,                              zt - 2.2],
             [xface + dir * drop_barb,            zt - 0.9],
             [xface + dir * drop_barb,            zt],
             [xface,                              zt]]);
}

module concept_drop() {
    zr = trk_ledge_z1 + (dx1 - wall - dx0) * tan(ramp_angle);
    difference() {
        union() {
            polygon([[dx0, 0], [dx1, 0], [dx1, z_top], [dx1 - wall, z_top],
                     [dx1 - wall, zr], [dx0, trk_ledge_z1]]);
            barb2d(dx0, -1);
            barb2d(dx1, +1);
        }
        // relief behind each barb leg, so they have somewhere to flex to
        translate([dx0 + flex_t, 1.2]) square([1.5, trk_ledge_z0 + 1.0]);
        translate([dx1 - flex_t - 1.5, 1.2]) square([1.5, trk_ledge_z0 + 1.0]);
    }
}

// Body shown in its locked position: foot slid outboard under the far ledge.
module concept_key_body() {
    zf = trk_ledge_z0 - 0.22;            // foot top, under the ledge
    polygon([[dx0 + key_push, 0], [dx1 + key_push, 0],
             [dx1 + key_push, zf], [dx1 - wall, zf + 0.6],
             [dx1, zf + 0.6], [dx1, z_top], [dx1 - wall, z_top],
             [dx1 - wall, zf + 0.6 + (dx1 - wall - dx0 - key_push) * tan(ramp_angle)],
             [dx0 + key_push, zf]]);
}

// Key, slid the other way: its own foot goes under the near ledge.
module concept_key_key() {
    zf = trk_ledge_z0 - 0.22;
    polygon([[clr + 0.05, 0], [dx0 + key_push - 0.25, 0],
             [dx0 + key_push - 0.25, trk_depth - 1.0],
             [dx0 + key_push - 0.25 - wall, trk_depth - 1.0],
             [dx0 + key_push - 0.25 - wall, zf],
             [clr + 0.05, zf]]);
}

module concept_section(which) {
    if      (which == "drop") concept_drop();
    else if (which == "key")  { concept_key_body(); concept_key_key(); }
    else                      profile(clr, back_pinch, "env");
}

// The three concepts, each in its own length of rail.
module concepts(len = preview_len) {
    gap = trk_outer_w + 10;   // across, not along, so the FRONT view compares
                              // the three sections side by side
    names = ["slide", "drop", "key"];
    cols  = ["darkorange", "seagreen", "steelblue"];
    for (i = [0 : 2])
        translate([i * gap, 0, 0]) {
            color("silver",  track_alpha) track(len);
            color("dimgray", mesh_alpha)  mesh(len);
            color(cols[i]) along_y(0, len) concept_section(names[i]);
        }
}

// Both back-grip variants side by side in the rail, for looking at.
module compare(len = preview_len) {
    gap = len + 25;
    for (i = [0, 1]) {
        translate([0, i * gap, 0]) {
            color("silver",  track_alpha) track(len);
            color("dimgray", mesh_alpha)  mesh(len);
            color(i == 0 ? "darkorange" : "steelblue")
                fence_length(len, clr, back_pinch);
        }
    }
}

module assembly(len = preview_len) {
    color("silver",  track_alpha) track(len);
    color("dimgray", mesh_alpha)  mesh(len);
    color("darkorange")           fence_length(len, clr);
}

// Where the seated fence and the track overlap — which must be nowhere. Build
// it and read the summary: "top level object is empty" is the pass. Anything
// with facets is metal the part is trying to occupy, and the fence will not
// seat. This is the check that the scrapped design never had.
module fitcheck(len = preview_len) {
    intersection() {
        fence_length(len, clr);
        track(len);
    }
}

// A slice with n notches cut into the top of the fence, so the printed slices
// can be told apart once they are off the plate.
module coupon_slice(pinch, n) {
    z_top = trk_depth + fence_h;
    difference() {
        fence_length(coupon_len, clr, pinch);

        // Cut down from the fence top, not into it — a cube centred on
        // z_top - coupon_notch_d leaves the slot buried inside the fence as a
        // through-hole, which is both invisible and a genus the build reports.
        for (i = [0 : n - 1])
            translate([trk_clear_w - trk_hook_x - mesh_slot - wall - eps,
                       coupon_len / 2 + (i - (n - 1) / 2) * coupon_notch_pitch
                           - coupon_notch_w / 2,
                       z_top - coupon_notch_d])
                cube([wall + 2 * eps, coupon_notch_w, coupon_notch_d + eps]);
    }
}

module coupon() {
    n = len(coupon_pinch);
    for (i = [0 : n - 1])
        translate([0, i * (coupon_len + coupon_gap), 0])
            coupon_slice(coupon_pinch[i], i + 1);
}

// ---------------------------------------------------------------------------
// WALL CLIP
// ---------------------------------------------------------------------------

// The clip's cross-section. splay opens the slot by moving the whole inner
// group inboard, which is the elastic state it passes the roll in; splay = 0
// is the seated, relaxed shape.
module clip2d(hook = clip_hook, splay = 0) {
    xo1 = -trk_skin - clip_out_clr - clip_out_t;   // outer prong, outside face
    xo2 = -trk_skin - clip_out_clr;                // outer prong, against the wall
    xi1 = trk_hook_x + clip_clr + splay;           // inner leg, against the roll tip
    xi2 = xi1 + clip_in_t;
    ztop = trk_depth + clip_fence_h;
    zbar = ztop - clip_bridge_t;
    tz1  = trk_lip_z0 - clip_tab_clr;              // tab top, under the roll
    tz0  = tz1 - clip_tab_h;
    tipx = trk_hook_x - hook + splay;              // tab tip
    fx   = trk_hook_x - clip_foot + splay;         // foot, over the roll's top

    union() {
        polygon([[xo1, zbar], [xi2, zbar], [xi2, ztop], [xo1, ztop]]);
        polygon([[xo1, trk_depth - clip_out_drop], [xo2, trk_depth - clip_out_drop],
                 [xo2, zbar], [xo1, zbar]]);
        polygon([[xi1, tz0], [xi2, tz0], [xi2, zbar], [xi1, zbar]]);
        polygon([[fx, trk_depth], [xi1, trk_depth],
                 [xi1, trk_depth + clip_foot_t], [fx, trk_depth + clip_foot_t]]);
        // Tab, with a 45 deg lead-in on its underside so the roll's tip cams
        // the leg open on the way down. Its TOP is flat, and stays flat
        // because the part prints standing up.
        polygon([[xi1, tz0], [xi1, tz1], [tipx, tz1], [tipx, tz0 + (xi1 - tipx)]]);
    }
}

module clip_length(len = clip_seg_len, hook = clip_hook, splay = 0) {
    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 10) clip2d(hook, splay);
}

// Seated interference. Empty is the pass, exactly as fitcheck.
module clipfit(len = preview_len) {
    intersection() { clip_length(len); track(len); }
}

// The INSERTION check, and the one round 01f says is the only one that counts.
// The clip is sprung open by its own engagement plus a whisker, then walked
// down through every height from clear of the rail to seated. Any facet in the
// result is metal the clip cannot pass on its way in — not on its way out, and
// not once it is home.
//
// It is a legitimate stand-in for a path search here, and was not for the
// rotate-in: this motion has one degree of freedom, straight down, with the
// splay a known elastic state. There is no pose to search for.
module clippath(len = preview_len, hook = clip_hook, steps = 24, lift = 9) {
    for (i = [0 : steps])
        intersection() {
            translate([0, 0, i * lift / steps])
                clip_length(len, hook, hook + clip_path_slack);
            track(len);
        }
}

module clipassembly(len = preview_len) {
    color("silver", track_alpha) track(len);
    color("darkorange")          clip_length(len);
}

// PRINTING ORIENTATION. Everything above is built lying down so it can be
// intersected with track(), which is how the two checks read. Anything meant
// for the plate is built UPRIGHT instead — extruded along Z, exactly as the
// fixture is — so the STL already stands the way it must print and nothing
// depends on the slicer being told to rotate it.
module clip_upright(len = clip_seg_len, hook = clip_hook) {
    linear_extrude(height = len, convexity = 10) clip2d(hook);
}

// One coupon slice, notched n times down the outside of the outer prong.
module clip_slice(hook, n) {
    difference() {
        clip_upright(clip_coupon_len, hook);
        for (i = [0 : n - 1])
            translate([-trk_skin - clip_out_clr - clip_out_t - eps,
                       trk_depth + clip_fence_h - coupon_notch_d,
                       clip_coupon_len / 2 + (i - (n - 1) / 2) * coupon_notch_pitch
                           - coupon_notch_w / 2])
                cube([coupon_notch_d + eps, coupon_notch_d + eps, coupon_notch_w]);
    }
}

// Laid out ACROSS the section, not along the length: upright, the slices have
// to stand side by side on the plate rather than end to end 121 mm in the air.
module clipcoupon() {
    n = len(clip_coupon_hook);
    w = clip_in_t + trk_hook_x + clip_clr + trk_skin + clip_out_clr + clip_out_t;
    for (i = [0 : n - 1])
        translate([i * (w + clip_coupon_gap), 0, 0])
            clip_slice(clip_coupon_hook[i], i + 1);
}

// ---------------------------------------------------------------------------
// TWIN CLIP — both prongs inside the channel
// ---------------------------------------------------------------------------
//
// Ziad's call, and the corrected profile is what makes it possible. Round 01
// ruled a two-sided snap out on the grounds that a part cannot engage an
// undercut on both walls at once and still get in. True of a RIGID part. These
// legs flex, and the 1/8 in rolls the real rail turned out to have give both
// sides a pocket 3.175 mm deep and 4.27 mm tall to snap into — where the
// drawing had promised 1.35.
//
// It is the hairpin with the outer prong replaced by a mirror of the inner
// one. Everything else is the same and every parameter is shared, so the
// coupon ladders the same variable.
//
//   DOWN      the skirt, bearing on the rail's top face across both walls.
//   UP        two barbs per leg: the tab under the fin at z 4.76 and the bump
//             under the top roll at z 13.28.
//   SIDEWAYS  each leg against its own feature tip. Nothing can shift, because
//             shifting toward one wall drives the far tab deeper.
//
// NOTHING BEARS ON THE TOP FACE OF A FEATURE INSIDE THE CHANNEL. There was a
// foot on each leg sitting on the fin's top face, making a C-jaw with the tab
// 0.15 mm under the fin's underside — a jaw sized to a fin thickness taken off
// the discredited drawing and impossible to caliper on an installed rail. On
// the real rail the foot rested on the fin and the tab never got around it,
// which is exactly what a jaw does when it is too small. The foot is gone; the
// fin's thickness is now a number the part does not care about.
//
// Insertion is straight down with both legs squeezed INWARD by the engagement
// and released under the rolls, so the mouth it has to pass is 15.875 less
// twice the hook, and the legs are rooted at the crossbar 14 mm above the rail
// for the same reason as before — length is what keeps the strain down.
//
// ⚠️ THE MESH IS NOT SOLVED HERE. The crossbar spans the channel above the
// rail, and that is where the mesh comes up out of it. This is a clamp test:
// it answers whether a two-sided snap seats and holds, and nothing else. The
// mesh will move the crossbar or split the part.

// The feature being caught, resolved once: how far it reaches inboard, and the
// underside the tab hooks. There is deliberately no top face here — see the
// note above about the foot.
catch_reach = twin_catch == "fin" ? trk_ledge_x  : trk_hook_x;
catch_under = twin_catch == "fin" ? trk_ledge_z0 : trk_lip_z0;
// What sits below the tab: the channel floor under the fin, the mid hook's top
// under the roll.
catch_floor = twin_catch == "fin" ? 0            : trk_hook_z1;

// One side, drawn at the near wall. splay moves it toward the channel centre,
// which is the elastic state it passes the aperture in.
//
// A tab: flat on top where it bears, ramped underneath where it cams in.
// The ramp wants clip_lead x its own run and gets whatever height is left
// after clip_bear_min, so a deep tab in a shallow space degrades to a steeper
// wedge rather than to a knife edge.
module twin_tab(xface, tipx, z0, z1) {
    run   = xface - tipx;
    rise  = min(run * clip_lead, (z1 - z0) - clip_bear_min);
    polygon([[xface, z0], [xface, z1], [tipx, z1], [tipx, z0 + rise]]);
}

module twin_side(hook = twin_hook, splay = 0) {
    xo   = catch_reach + clip_clr + splay;   // leg, against the feature's tip
    tz1  = catch_under - clip_tab_clr;
    tz0  = catch_floor + clip_tab_floor;
    zbar = trk_depth + clip_fence_h - clip_bridge_t;

    // The bump can never out-reach the squeeze that has to carry it past the
    // roll, which is set by the tab.
    bump = min(twin_bump, hook - 0.10);
    bz1  = trk_lip_z0 - clip_tab_clr;
    bz0  = trk_hook_z1 + clip_tab_floor;

    // Tapered leg. Outboard face stays flat against the feature tips; the
    // inboard face carries the taper, thickening toward the root.
    aa   = zbar - tz1;                       // free length under load
    nseg = 24;
    // Built root-first so the polygon winds without needing a reverse().
    prof = [for (i = [0 : nseg])
                let (z = zbar - i * aa / nseg)
                [xo + max(clip_leg_tip_t, clip_leg_root_t * sqrt((z - tz1) / aa)), z]];

    union() {
        polygon(concat([[xo, tz0], [xo, zbar]], prof,
                       [[xo + clip_leg_tip_t, tz0]]));
        twin_tab(xo, catch_reach - hook + splay, tz0, tz1);
        if (bump > 0.05 && catch_under < trk_lip_z0)
            twin_tab(xo, trk_hook_x - bump + splay, bz0, bz1);

        // Root fillets, both faces. Outboard is the tension side.
        fillet_in(xo, zbar, -1, clip_leg_fillet);
        if (clip_leg_fillet_in > 0)
            fillet_in(xo + clip_leg_root_t, zbar, 1, clip_leg_fillet_in);
    }
}

// Fills the concave corner at (x, z) between a vertical face and the
// horizontal underside above it. dir -1 puts the fillet on the -x side.
module fillet_in(x, z, dir, r) {
    translate([x, z]) scale([dir, 1])
        difference() {
            translate([0, -r]) square([r, r]);
            translate([r, -r]) circle(r = r);
        }
}

module twin2d(hook = twin_hook, splay = 0) {
    w    = trk_clear_w;                     // mirror line is the channel centre
    xo   = catch_reach + clip_clr + splay;
    ztop = trk_depth + clip_fence_h;
    zbar = ztop - clip_bridge_t;
    cx0  = -trk_skin;                       // flush with the rail's outside
    cx1  = w + trk_skin;
    cz0  = trk_depth + clip_cap_clr;
    xo0  = catch_reach + clip_clr;          // leg face, unsplayed

    difference() {
    union() {
        twin_side(hook, splay);
        translate([w, 0]) mirror([1, 0]) twin_side(hook, splay);

        // Crossbar. Narrow and splay-following when uncapped; once capped it is
        // part of the cap and takes the cap's rounded corners with it, which
        // is why it has to be INSIDE the intersection below rather than
        // unioned alongside it.
        if (!twin_cap)
            polygon([[xo, zbar], [w - xo, zbar], [w - xo, ztop], [xo, ztop]]);

        if (twin_cap)
            intersection() {
                offset(r = -clip_cap_fillet) offset(r = clip_cap_fillet)
                union() {
                    polygon([[cx0, zbar], [cx1, zbar], [cx1, ztop], [cx0, ztop]]);
                    if (clip_back_h > 0)
                        polygon([[cx1 - clip_back_t, ztop], [cx1, ztop],
                                 [cx1, ztop + clip_back_h],
                                 [cx1 - clip_back_t, ztop + clip_back_h]]);
                    for (m = [0, 1])
                        translate([m * w, 0]) mirror([m, 0]) {
                            // skirt wall
                            polygon([[cx0, cz0], [cx0 + clip_out_t, cz0],
                                     [cx0 + clip_out_t, zbar], [cx0, zbar]]);
                            // floor closing the bottom of the side slot, held
                            // off the leg. Measured from the UNSPLAYED leg, so
                            // it stays put while the leg moves.
                            polygon([[cx0 + clip_out_t, cz0],
                                     [xo0 - clip_relief, cz0],
                                     [xo0 - clip_relief, cz0 + clip_cap_floor],
                                     [cx0 + clip_out_t, cz0 + clip_cap_floor]]);
                        }
                }
                cap_outline();
            }
    }
    }
}

// Width of the key (mm), and it is not a choice.
//
// The key drops in from the top, so its widest section has to pass the
// NARROWEST part of the gap between the legs, which is at their roots where
// the taper has them at clip_leg_root_t. Everything below is wider, and the
// key cannot be tapered to suit, because the wide end would be the leading
// one. So it is a straight strip sized to the root, and the surplus shows up
// as play down at the barbs.
key_w = trk_clear_w - 2 * (catch_reach + clip_clr + clip_leg_root_t
                           + clip_leg_fillet_in + key_clr);

// THE GUARD, and it has earned its place three times in one session.
//
// A top-level assignment that reads a name assigned BELOW it gets undef. It is
// a WARNING, the build still exits 0, and what comes out is a degenerate solid
// that every intersection check then calls clean — key_w did it once and
// key_knob_x did it again twenty minutes later. An assert turns that into a
// stop, which is what it always should have been.
assert(!is_undef(key_w) && key_w > 0,
       "key_w is undef or non-positive — a name it reads is assigned below it");
assert(!is_undef(twin_hook) && !is_undef(twin_bump),
       "twin_hook/twin_bump are undef — a name they read is assigned below them");

// The key's stem and flange, as a section across the rail. A straight strip
// with a one-sided flange that stands key_lift clear of the cap, chamfered at
// the bottom so it finds the gap between the legs. The ring is not in here —
// it is not a prism along the rail — see key_solid.
module key2d() {
    cx   = trk_clear_w / 2;
    ztop = trk_depth + clip_fence_h;
    k    = key_w / 2;
    L    = key_lead;
    hz   = ztop + key_lift;               // flange underside
    union() {
        polygon([[cx - k + L, key_z0], [cx + k - L, key_z0],
                 [cx + k, key_z0 + L], [cx + k, hz],
                 [cx - k, hz], [cx - k, key_z0 + L]]);
        // Centred on the stem, so key_head_ext splits evenly and the key has
        // no front and no back. At the design value of 0 this is the stem
        // carried straight on up to the ring.
        translate([cx - k - key_head_ext / 2, hz])
            square([key_w + key_head_ext, key_head_t]);
    }
}

// The head's width, which is the one length every cat number scales by. The
// hole runs key_ring_id across the widest part of the head, with a band of
// key_ring_w each side of it.
function cat_w() = key_ring_id + 2 * key_ring_w;

// The head alone, with no ears: a hull of four circles, in the cat's own
// coordinates — x across the face, y up, origin at the head's centre.
module cat_head_2d(w = undef) {
    cw = is_undef(w) ? cat_w() : w;
    hull()
        for (sx = [-1, 1]) {
            translate([sx * (0.5 - cat_head_r_top) * cw,
                       (cat_head_top - cat_head_r_top) * cw])
                circle(r = cat_head_r_top * cw, $fn = 64);
            translate([sx * (0.5 - cat_head_r_bot) * cw,
                       (cat_head_bot + cat_head_r_bot) * cw])
                circle(r = cat_head_r_bot * cw, $fn = 64);
        }
}

// The whole face, ears on: head, plus a triangle for each ear overlapped well
// into it, then offset(-k) offset(+2k) offset(-k) — erode, dilate, erode —
// which is the plain-OpenSCAD way to round EVERY corner rather than only the
// convex or only the concave ones. Order matters: the first erode is what
// rounds the notch between the ears.
module cat_face_2d(w = undef) {
    cw = is_undef(w) ? cat_w() : w;
    k  = cat_round * cw;
    offset(r = -k) offset(r = 2 * k) offset(r = -k)
        union() {
            cat_head_2d(cw);
            for (sx = [-1, 1])
                polygon([for (pt = cat_ear) [sx * pt[0] * cw, pt[1] * cw]]);
        }
}

// The hole the fingers go through: the HEAD eroded by the band width, not the
// whole face eroded by it. Erode the face and the hole runs up into the ears,
// which then read as two horns with a gap down the middle of each; taking the
// hole off the head leaves the ears solid, which is what the reference
// silhouette has. It comes out key_ring_id across and 27.4 tall, with a
// constant key_ring_w of band everywhere the two boundaries face.
module cat_hole_2d(w = undef) {
    offset(r = -key_ring_w) cat_head_2d(w);
}

// A 2D shape extruded t tall with both faces rolled over by r, built as a
// stack: a full-thickness core, and above and below it n slabs offset by
// r x (1 - cos a) reaching to the height r x sin a, sampled at equal angles
// along the true roundover arc. Each slab takes the offset of its OUTER
// edge, so for the body (sgn -1) the staircase sits inside the ideal surface
// and for a cutter (sgn +1) outside it — either way the error is never
// material left proud. The step is cat_step, half a layer, so the slicer
// sees a curve rather than a stair.
//
// EVERY SLAB RUNS FROM THE MIDDLE OF THE CORE, not from the core's face, and
// that is not tidiness. Slabs stacked exactly face to face touch over zero
// volume and the union comes out as a pile of SEPARATE SHELLS — a plain
// solid disc built that way reported genus -7, which is eight components
// rather than any hole count. Starting each slab at t/2 buries every join in
// solid material: one shell, and genus means what it says again. Starting
// them at the core's own face would be no better, because the two faces
// would then be coplanar.
//
// Not minkowski() with a sphere, which is the textbook answer and the wrong
// one here: these outlines are non-convex in a dozen places, so OpenSCAD
// would decompose them and the build would go from a quarter-second to a
// long wait.
module cat_slab(t, r, sgn = -1) {
    n = max(3, ceil(r / cat_step));
    translate([0, 0, r])
        linear_extrude(height = t - 2 * r, convexity = 10) children();
    for (i = [0 : n - 1]) {
        z  = r * sin(90 * (i + 1) / n);
        d  = sgn * r * (1 - cos(90 * (i + 1) / n));
        // The last slab of a cutter is the one that reaches the face, so it
        // is the one that gets the usual overshoot through it.
        ov = (sgn > 0 && i == n - 1) ? eps : 0;
        h  = t / 2 - r + z + ov;
        translate([0, 0, t / 2])
            linear_extrude(height = h, convexity = 10) offset(r = d) children();
        translate([0, 0, r - z - ov])
            linear_extrude(height = h, convexity = 10) offset(r = d) children();
    }
}

// The ring on its own: the cat standing in the y-z plane, thickness centred
// on x so its axis lies across the channel, origin at the head's centre.
//
// BODY MINUS CUTTER, NOT A STACK OF BANDS. Stacking the band — the face with
// the hole already taken out of it — builds the same solid and reports a
// genus of 7 on a part with one hole in it, rising with the slab count: each
// eroded annulus meets its neighbours in a way CGAL resolves into extra
// handles. Rolling the outside and the inside as two separate simply-
// connected stacks and differencing them once gives one tunnel and genus 1,
// which is the number that says the hole goes through.
module key_ring() {
    t  = key_ring_t > 0 ? key_ring_t : key_w;
    r  = key_ring_r;
    cw = cat_w();
    assert(r < key_ring_w / 2 && r < t / 2, "key_ring_r too large for the ring section");
    rotate([0, 90, 0]) translate([0, 0, -t / 2])
        difference() {
            cat_slab(t, r, -1) cat_face_2d(cw);
            cat_slab(t, r, +1) cat_hole_2d(cw);
        }
}

// One key, in rail coordinates: x across the channel, y up, z along the
// rail from 0 to len_k. The ring is centred on the key's length and sunk
// key_ring_sink into the flange, from the flange's TOP face down — two
// shapes meeting exactly on a plane are separate shells, which is how the
// key came off the plate as two objects once already.
module key_solid(len_k) {
    cx   = trk_clear_w / 2;
    ztop = trk_depth + clip_fence_h;
    hz   = ztop + key_lift;
    // The cat's origin is its head centre, so the sink is measured to the
    // chin: drop the flange's top face by key_ring_sink, then lift by however
    // far the chin hangs below that origin.
    yc   = hz + key_head_t - key_ring_sink - cat_head_bot * cat_w();
    union() {
        linear_extrude(height = len_k, convexity = 10) key2d();
        translate([cx, yc, len_k / 2]) key_ring();
    }
}

// The keys where they end up: one per window, sized to it. This is the pose
// keyfit and keyblock ask about.
module key_upright(len = clip_seg_len) {
    g = key_gap(len);
    for (i = [0 : key_count(len) - 1])
        translate([0, 0, g + key_end_clr + i * (key_len(len) + g)])
            key_solid(key_len(len) - 2 * key_end_clr);
}

// The keys on a plate: lying on a stem face, the ring flat on the bed. Not
// the insert's pose any more — the ring is not a prism along the rail, and
// stood up it would be a 42 mm arch printed on edge. Laid down, the key is a
// slab of one thickness end to end and nothing overhangs but the ring's
// rounded lower edge and the 1.2 mm lead chamfer. With the flange gone it no
// longer matters which face goes down; this picks one. Keys go side by side
// along what was the rail, ring to ring, pair_gap apart.
module key_plate(len = clip_seg_len) {
    cx    = trk_clear_w / 2;
    lk    = key_len(len) - 2 * key_end_clr;
    // Pitch is along what was the rail, which is the cat's width — the ears
    // run up in y and take no room beside the next key.
    od    = cat_w();
    pitch = max(lk, od) + pair_gap;
    for (i = [0 : key_count(len) - 1])
        translate([i * pitch + max(lk, od) / 2, 0, 0])
            rotate([0, -90, 0])
                translate([-(cx - key_w / 2), 0, -lk / 2])
                    key_solid(lk);
}

// The key seated: it must foul neither the rail nor the insert. Both are asked
// at once, because a key that clears one and not the other is no use.
module keyfit(len = preview_len) {
    intersection() {
        key_upright(len);
        union() { track(len); twin_upright(len); }
    }
}

// THE ONLY CHECK HERE THAT PASSES BY REPORTING FACETS. Every other one asks
// whether two solids stay out of each other's way; this one asks whether the
// key gets IN the way, so an empty result is the failure.
//
// The legs are splayed by exactly the travel that would release them — the
// engagement plus the insertion whisker — and intersected with the key. If the
// key is doing its job the two overlap, and the size of that overlap is how
// much of the release it eats.
module keyblock(len = preview_len) {
    intersection() {
        key_upright(len);
        twin_upright(len, twin_hook, twin_hook + clip_path_slack);
    }
}

// The cap's silhouette: square at the bottom, rounded at the top, and the two
// top corners are DIFFERENT — generous at the front, a break at the back. Hull
// of two circles and two points, so each side comes out tangent-vertical and
// the top tangent-horizontal without drawing any arcs by hand.
module cap_outline() {
    w   = trk_clear_w;
    cx0 = -trk_skin;
    cx1 = w + trk_skin;
    cz0 = trk_depth + clip_cap_clr;
    zt  = trk_depth + clip_fence_h;
    rf  = clip_cap_r_front;
    rb  = clip_cap_r_back;
    tb  = clip_back_t;
    h   = clip_back_h;
    union() {
        // The cap. Its back top corner is square, because the wall stands on
        // it and there is no corner there to break.
        hull() {
            translate([cx0 + rf, zt - rf]) circle(r = rf);
            translate([cx1, zt]) circle(r = 0.001);
            translate([cx0, cz0]) circle(r = 0.001);
            translate([cx1, cz0]) circle(r = 0.001);
        }
        // The wall, rounded at both of its own top corners.
        if (h > 0)
            hull() {
                translate([cx1 - tb + rb, zt + h - rb]) circle(r = rb);
                translate([cx1 - rb,      zt + h - rb]) circle(r = rb);
                translate([cx1 - tb, zt]) circle(r = 0.001);
                translate([cx1,      zt]) circle(r = 0.001);
            }
    }
}

// The same solid twin_upright builds, lying down. It is defined in terms of
// that one rather than re-extruding the section, because the section is no
// longer the whole story: the key windows are cut along the length, and a
// preview that re-extrudes twin2d shows an uncut crossbar with a full-length
// key running through it. That preview is what made the part look bisected.
module twin_length(len = clip_seg_len, hook = twin_hook, splay = 0) {
    translate([0, len, 0]) rotate([90, 0, 0]) twin_upright(len, hook, splay);
}

module twin_upright(len = clip_seg_len, hook = twin_hook, splay = 0) {
    zbar = trk_depth + clip_fence_h - clip_bridge_t;
    g = key_gap(len);
    difference() {
        linear_extrude(height = len, convexity = 10) twin2d(hook, splay);
        if (twin_key)
            for (i = [0 : key_count(len) - 1])
                translate([trk_clear_w / 2 - key_w / 2 - key_clr, zbar - eps,
                           g + i * (key_len(len) + g)])
                    cube([key_w + 2 * key_clr, clip_bridge_t + 2 * eps,
                          key_len(len)]);
    }
}

module twinfit(len = preview_len) {
    intersection() { twin_length(len); track(len); }
}

// Same insertion check as clippath, and the same reason it is sound: one
// degree of freedom, straight down, with the squeeze a known elastic state.
// Prove it can fail with -D clip_path_slack=-0.50 before believing a pass.
module twinpath(len = preview_len, hook = twin_hook, steps = 24, lift = 9) {
    for (i = [0 : steps])
        intersection() {
            translate([0, 0, i * lift / steps])
                twin_length(len, hook, hook + clip_path_slack);
            track(len);
        }
}

module twinassembly(len = preview_len) {
    color("silver", track_alpha) track(len);
    color("darkorange")          twin_length(len);
    if (twin_key)
        color("steelblue") translate([0, len, 0]) rotate([90, 0, 0])
            key_upright(len);
}

module twin_slice(hook, n) {
    ztop = trk_depth + clip_fence_h;
    difference() {
        twin_upright(clip_coupon_len, hook);
        for (i = [0 : n - 1])
            translate([trk_clear_w / 2 - coupon_notch_w / 2,
                       ztop - coupon_notch_d,
                       clip_coupon_len / 2 + (i - (n - 1) / 2) * coupon_notch_pitch
                           - coupon_notch_w / 2])
                cube([coupon_notch_w, coupon_notch_d + eps, coupon_notch_w]);
    }
}

// One rail and one insert, side by side, both standing as they must print.
// Deliberately NOT nested one inside the other: they have to be separate
// objects on the plate for the fit to mean anything, and an insert printed
// inside a rail would fuse to it at the first layer.
module pair(len = pair_len) {
    right = trk_clear_w + fixture_wall + fixture_bore_comp;   // fixture's edge
    left  = -trk_skin;                                        // insert's edge
    ins   = right + pair_gap - left;                    // insert's offset
    kleft = 0;                                           // key plate starts at 0
    fixture(len);
    translate([ins, 0, 0]) twin_upright(len, pair_hook);
    // The key, beside the insert rather than in it — same reason the insert is
    // beside the rail and not in it.
    if (twin_key && pair_key)
        translate([ins + trk_clear_w + trk_skin + pair_gap - kleft, 0, 0])
            key_plate(len);
}

// Seated interference against the FIXTURE rather than against track(), which
// is a different question and worth asking separately: twinfit says the insert
// fits the rail as measured, this says it fits the plastic rail it is about to
// be tried in — bore compensation, blunted bead tips, root fillets and all. A
// failure here is a fixture problem, not a design one.
// The insert is lifted by eps first, and that is not a fudge: the skirt now
// BEARS on the rail top, so those two faces are coplanar, and CGAL answers a
// coplanar intersection with zero-volume slivers rather than with nothing. All
// eight vertices of them came back at y = 15.0813 exactly. Lifting clear of the
// contact restores the pass/fail signal, at the cost of not seeing an overlap
// below 0.01 mm — which is a quarter of a layer and half a nozzle's rounding.
module pairfit(len = preview_len) {
    intersection() {
        translate([0, eps, 0]) twin_upright(len, pair_hook);   // +y is up
        fixture(len);
    }
}

module twincoupon() {
    n = len(clip_coupon_hook);
    w = trk_clear_w + clip_coupon_gap;
    for (i = [0 : n - 1])
        translate([i * w, 0, 0])
            twin_slice(clip_coupon_hook[i], i + 1);
}

if (trk_hook_x - twin_bump_gap > twin_hook - 0.10)
    echo(str("twin_bump clamped ", trk_hook_x - twin_bump_gap, " -> ", twin_hook - 0.10,
             ": it cannot out-reach the squeeze the tab provides."));

// The default is a preview. Say so on every run, so an accidental unnamed
// build is caught in the log rather than in the printer.
if (show == "track" || show == "assembly" || show == "compare" || show == "concepts"
    || show == "clipassembly" || show == "twinassembly")
    echo(str("PREVIEW ONLY (show=\"", show, "\") — NOT printable. ",
             "Build the part with -D 'show=\"fence\"'."));

if      (show == "coupon")     coupon();
else if (show == "clip")         clip_upright();
else if (show == "clipcoupon")   clipcoupon();
else if (show == "clipfit")      clipfit();
else if (show == "clippath")     clippath();
else if (show == "clipassembly") clipassembly();
else if (show == "twin")         twin_upright();
else if (show == "twincoupon")   twincoupon();
else if (show == "twinfit")      twinfit();
else if (show == "twinpath")     twinpath();
else if (show == "twinassembly") twinassembly();
else if (show == "pair")         pair();
else if (show == "pairfit")      pairfit();
else if (show == "key")          key_plate();
else if (show == "keyfit")       keyfit();
else if (show == "keyblock")     keyblock();
else if (show == "track")    track();
else if (show == "assembly") assembly();
else if (show == "fitcheck") fitcheck();
else if (show == "compare")  compare();
else if (show == "concepts") concepts();
else if (show == "fixture")  fixture();
else                         fence();
