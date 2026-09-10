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
show = "twinassembly";  // [fence, coupon, twin, twincoupon, twinfit, twinpath, twinassembly, clip, clipcoupon, clipfit, clippath, clipassembly, track, assembly, fitcheck, compare, concepts, fixture]

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
// Clearance between the tab's top face and the roll's underside (mm). The foot
// is the down-stop, so this is what is left over.
clip_tab_clr = 0.15;
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
clip_seg_len = 60;

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

// Secondary bump on each leg, snapping into the pocket under the TOP ROLL.
// Engagement past the roll's tip, per side (mm), 0 for none.
//
// It is a second catch at a second height, so the part is hooked twice on each
// wall: the tab under the fin at z 4.76 and the bump under the roll at 13.28.
// Both are set 0.15 below their feature, so both bear at once.
//
// It cannot be deeper than the tab's own engagement. The legs squeeze by the
// tab's hook plus a whisker, and the bump has to clear the roll tip on that
// same squeeze, so it is clamped to hook - 0.10 and says so when it clamps.
twin_bump = 0.80;

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
//   DOWN      both feet, on the tops of both rolls.
//   UP        both tabs, under both rolls.
//   SIDEWAYS  each leg against its own roll tip. Nothing can shift, because
//             shifting toward one wall drives the far tab deeper.
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

// The feature being caught, resolved once: how far it reaches inboard, the
// underside the tab hooks, and the top face the foot lands on.
catch_reach = twin_catch == "fin" ? trk_ledge_x  : trk_hook_x;
catch_under = twin_catch == "fin" ? trk_ledge_z0 : trk_lip_z0;
catch_top   = twin_catch == "fin" ? trk_ledge_z1 : trk_depth;
// What sits below the tab: the channel floor under the fin, the mid hook's top
// under the roll.
catch_floor = twin_catch == "fin" ? 0            : trk_hook_z1;

// One side, drawn at the near wall. splay moves it toward the channel centre,
// which is the elastic state it passes the aperture in.
//
// Foot and tab together are a C-jaw closing on the feature: the foot lands on
// its top face, the tab hooks its underside, and the 0.15 between them is all
// the vertical play the part has. On the fin that jaw grips a flat 1/32 in
// flange, which is why it is the better of the two.
// A tab: flat on top where it bears, ramped underneath where it cams in.
// The ramp wants clip_lead x its own run and gets whatever height is left
// after clip_bear_min, so a deep tab in a shallow space degrades to a steeper
// wedge rather than to a knife edge.
module twin_tab(xface, tipx, z0, z1) {
    run   = xface - tipx;
    rise  = min(run * clip_lead, (z1 - z0) - clip_bear_min);
    polygon([[xface, z0], [xface, z1], [tipx, z1], [tipx, z0 + rise]]);
}

module twin_side(hook = clip_hook, splay = 0) {
    xo   = catch_reach + clip_clr + splay;   // leg, against the feature's tip
    xi   = xo + clip_in_t;
    tz1  = catch_under - clip_tab_clr;
    tz0  = catch_floor + clip_tab_floor;
    fx   = catch_reach - clip_foot + splay;
    zbar = trk_depth + clip_fence_h - clip_bridge_t;

    // The bump can never out-reach the squeeze that has to carry it past the
    // roll, which is set by the tab.
    bump = min(twin_bump, hook - 0.10);
    bz1  = trk_lip_z0 - clip_tab_clr;
    bz0  = trk_hook_z1 + clip_tab_floor;

    union() {
        polygon([[xo, tz0], [xi, tz0], [xi, zbar], [xo, zbar]]);
        polygon([[fx, catch_top], [xo, catch_top],
                 [xo, catch_top + clip_foot_t], [fx, catch_top + clip_foot_t]]);
        twin_tab(xo, catch_reach - hook + splay, tz0, tz1);
        if (bump > 0.05 && catch_under < trk_lip_z0)
            twin_tab(xo, trk_hook_x - bump + splay, bz0, bz1);
    }
}

module twin2d(hook = clip_hook, splay = 0) {
    w    = trk_clear_w;                     // mirror line is the channel centre
    xo   = catch_reach + clip_clr + splay;
    ztop = trk_depth + clip_fence_h;
    zbar = ztop - clip_bridge_t;

    union() {
        twin_side(hook, splay);
        translate([w, 0]) mirror([1, 0]) twin_side(hook, splay);
        polygon([[xo, zbar], [w - xo, zbar], [w - xo, ztop], [xo, ztop]]);
    }
}

module twin_length(len = clip_seg_len, hook = clip_hook, splay = 0) {
    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 10) twin2d(hook, splay);
}

module twin_upright(len = clip_seg_len, hook = clip_hook) {
    linear_extrude(height = len, convexity = 10) twin2d(hook);
}

module twinfit(len = preview_len) {
    intersection() { twin_length(len); track(len); }
}

// Same insertion check as clippath, and the same reason it is sound: one
// degree of freedom, straight down, with the squeeze a known elastic state.
// Prove it can fail with -D clip_path_slack=-0.50 before believing a pass.
module twinpath(len = preview_len, hook = clip_hook, steps = 24, lift = 9) {
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

module twincoupon() {
    n = len(clip_coupon_hook);
    w = trk_clear_w + clip_coupon_gap;
    for (i = [0 : n - 1])
        translate([i * w, 0, 0])
            twin_slice(clip_coupon_hook[i], i + 1);
}

if (twin_bump > clip_hook - 0.10)
    echo(str("twin_bump clamped ", twin_bump, " -> ", clip_hook - 0.10,
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
else if (show == "track")    track();
else if (show == "assembly") assembly();
else if (show == "fitcheck") fitcheck();
else if (show == "compare")  compare();
else if (show == "concepts") concepts();
else if (show == "fixture")  fixture();
else                         fence();
