// patio-leg-spacer.scad
//
// Levelling feet for a patio set whose legs are rectangular tube raked off
// plumb. Three printed pieces that stack:
//
//   base      a flat pad, proud of the column, that sits on the patio
//   shim      a 5 mm plate — one per 5 mm of correction a given leg needs
//   receiver  a deep socket the leg drops into, tilted so the square-cut end
//             of the tube seats flat on the pocket floor
//
// Every joint is the same interface: a tongue ring standing on the top face, a
// matching groove in the bottom face. So base -> receiver, or base -> shim ->
// shim -> receiver, in any combination. All four legs get base + receiver; the
// short ones get shims.
//
// THE ANGLE LIVES IN THE RECEIVER, not the base. Gravity is vertical, so a
// vertical stack loads every joint below the receiver in pure compression
// rather than bending. It also means that if the rake turns out to be a
// different number, only the receiver is reprinted — base and shims are
// unaffected by it, and so is the whole set of already-printed shims.
//
// The joint carries its load through the full mating face, not through the
// tongue. The tongue only locates and retains, and it retains by crush ribs:
// the groove itself is cut at a slip fit, and four sets of tapered ribs on the
// tongue's outer face are the only interference. That is far more forgiving of
// printer variance than a full-perimeter press fit, which is the kind of thing
// that comes out either loose or impossible to seat.
//
// ORIENTATION. Everything prints as modelled, flat face down, no support. The
// receiver's lean is 8.5 degrees off vertical, which is nothing to an overhang.
// The receiver leans toward -y, so the "front" render looks into the lean.
//
// MATERIAL AND PLATE. PETG. Two consequences worth knowing before printing:
//
// PRINT THE WHOLE SET ON ONE PLATE TYPE, and note which. The groove's mouth is
// a first-layer feature, and §5.2 of the design reference measures a ~0.1 mm
// squish difference between the textured and smooth plates. The crush ribs only
// have rib_proud_bot - joint_clear = 0.20 mm of interference to work with, so a
// plate swap between printing a base and printing its shims moves half of it.
// A base off one plate and a shim off the other may not fit each other.
//
// The pocket is NOT first-layer-critical — it starts slab_h up, around 4 mm
// above the plate — so pocket_clear does not care about the plate. The fit
// coupon's bore does start at the plate, which is why both its mouths are
// flared; if anything the real receiver will read a hair looser than the coupon
// did.
//
// Elephant's foot is worst with PETG on the textured plate [FIELD], and PETG
// over-adheres to bare smooth PEI. Every bottom outside edge here carries a
// base_cham relief for the first, and the base is a ~2300 mm2 footprint, so use
// glue as a release layer for the second.
//
// DRAINAGE. This lives outdoors. The leg is an open tube, so water runs down
// the inside of it into the pocket. The pocket floor, every shim and the base
// pad are bored through with the same slot, biased to the low side of the
// tilted floor, so it reaches the ground instead of standing in the socket and
// rotting the leg.

/* [Output] */

// "plate" is the three parts laid out for one print. "stack" is an assembly
// preview — base + 2 shims + receiver — for checking the thing looks right.
// Not for printing; build a variant with --name if you ever want it as an STL.
show = "receiver";  // [receiver, shim, base, plate, stack, coupon]

// COUPON-COMPONENTS: receiver=receiver shim=shim base=base
// COUPON-PLATE: plate

/* [Leg — MEASURE THESE] */

// Tube section across the faces the leg does NOT lean over (mm) — the bar's
// LONG side. The rake's hinge line runs along this dimension, so the leg tips
// over its narrow edge, not its wide face.
//
// AS MEASURED, not rounded up. The fit allowance is pocket_clear's job and it
// is applied below; rounding a measurement up "to be sure it fits" and then
// adding clearance on top of that spends the allowance twice and the leg
// rattles.
leg_w = 50.5;
// Tube section across the faces the leg leans over (mm) — the narrow edge.
// As measured.
leg_d = 16.5;
// Corner radius of the tube (mm).
//
// ⚠️ Guessed. Nothing has measured this. Too small and the leg will not enter;
// too large and it rattles at the corners. Measure one before printing — on a
// 16.5 mm bar there is not much room to be wrong.
leg_r = 2.0;
// Rake of the leg off plumb, in the leg_d direction (degrees). Zero gives a
// straight receiver and the whole part degenerates gracefully.
lean = 8.5;

/* [Receiver] */

// Pocket clearance per side (mm).
//
// MEASURED, not taken from the table. The fit coupon went on the real legs at
// 0.10, 0.20 and 0.30 per side and 0.10 was both the tightest offered and the
// best of the three. That is the press/interference rung for a 0.4 nozzle, not
// the snug-sliding one — this receiver is meant to be pushed on and stay on,
// not to slip.
//
// ⚠️ The coupon rings are coupon_h tall and the pocket is pocket_h. Friction
// goes with engagement length, so the real receiver takes roughly pocket_h /
// coupon_h times the force the coupon did. If it turns out to need a mallet,
// the fix is a relief band through the middle of the pocket rather than more
// clearance everywhere — that keeps the mouth and the floor tight so the leg
// cannot rock.
pocket_clear = 0.10;
// Pocket depth measured along the leg axis, floor to mouth (mm). Needs that
// much STRAIGHT prismatic tube on the leg to slide over.
pocket_h = 30.0;
// Wall around the pocket (mm). 0.84 + 4 x 0.45 — two outer lines at 0.42 and
// four inner at 0.45, per the corrected wall ladder.
wall_t = 2.64;
// Floor left under the pocket's LOW corner (mm). The pocket floor is tilted,
// so its low corner is what sets how tall the receiver's bottom slab has to
// be; the high corner ends up with floor_t + floor_drop of material over it.
//
// This is measured from the receiver's BOTTOM FACE, not from the groove floor,
// because the groove ring is held outboard of the pocket — see joint_gap. That
// is what keeps joint_h out of the height budget.
floor_t = 3.0;
// Lead-in flare at the pocket mouth (mm). Kept well under wall_t so the rim
// does not thin to nothing.
mouth_cham = 1.2;

/* [Stack] */

// Smallest ledge the slab, shims and base stand proud of the leaning tube, per
// side (mm). The real figure is derived and may be larger — see stack_over.
stack_over_min = 1.0;
// Shim plate thickness — the adjustment step (mm). Has to stay comfortably
// above joint_h or the web between the groove's floor and the tongue's root
// gets too thin to be worth anything.
shim_h = 5.0;
// Base pad thickness (mm). It is a flat pad fully supported by the ground, so
// it works in pure compression and does not need much.
base_h = 3.0;
// How far the base pad stands proud of the stack, per side (mm). Sized so the
// top of the leaning receiver still lands inside the pad's outline.
base_over = 5.0;
// Relief on the bottom outside edge of every piece (mm), at 45 degrees. More
// reliable than the slicer's elephant-foot compensation, and it is what keeps
// a stacked joint from rocking on a squashed first layer.
base_cham = 0.5;

/* [Joint] */

// Tongue height and groove depth (mm).
joint_h = 2.5;
// Tongue thickness (mm). 0.84 + 0.45 — two outer lines and one inner.
//
// Thin on purpose. The tongue carries no load (the full mating faces do), and
// a slim joint keeps the whole groove ring narrow enough to sit outboard of
// the pocket, which is worth more in height than a fat tongue is in strength.
tongue_t = 1.29;
// Material outboard of the groove (mm) — the wall the crush ribs flex. Thin
// here is a feature: it flexes rather than resisting, so the ribs crush
// instead of the joint refusing to seat.
joint_wall = 1.29;
// Clearance kept between the groove's inner face and the pocket wall's outer
// face (mm). This is the whole trick: hold the groove ring outboard of the
// pocket and the pocket floor bears on solid slab from z = 0, so joint_h stops
// counting toward how far the chair goes up.
joint_gap = 0.8;
// Material left over the groove where the receiver's wall lands on it (mm).
groove_roof = 1.5;
// Groove clearance per side (mm), before the ribs. A slip fit on purpose.
joint_clear = 0.20;
// Chamfer on the tongue's top edges (mm).
tongue_cham = 0.6;
// Chamfer at the groove's mouth (mm). This is on the first layer, where it is
// wanted anyway, and it is the lead-in that makes the joint start square.
groove_cham = 0.5;

/* [Crush ribs] */

// Fillet radius of a rib (mm). Half-buried in the tongue face, so it has to be
// small enough not to break out through the tongue's far side and interfere
// with the groove's inner wall as well — asserted below.
rib_r = 0.6;
// How far a rib stands proud of the tongue face at its root (mm).
//
// ⚠️ THE NUMBER TO TUNE. Interference per rib is rib_proud_bot - joint_clear,
// so 0.40 against a 0.20 groove is 0.20 of crush. Too tight and the shim will
// not seat; too loose and the stack falls apart when the chair is lifted.
// Print a base and one shim first and try it before committing to a set.
rib_proud_bot = 0.40;
// How far it stands proud at its tip (mm). Under joint_clear, so the joint
// starts free and tightens as it seats.
rib_proud_top = 0.05;
// How far out along a face the outermost rib sits, as a fraction of the
// straight run available on it. Positions are derived rather than typed so
// they cannot walk off the end of a face when the leg section changes.
rib_spread = 0.80;
// Straight half-run a face needs before a third rib in the middle earns its
// place (mm).
rib_min_three = 10.0;

/* [Drain] */

// Width of the drain slot (mm).
drain_d = 6.0;
// How far the slot runs along its own axis, as a fraction of the room between
// the centre and the groove ring.
drain_reach = 0.75;
// How far the slot is pushed toward the low side of the tilted floor, as a
// fraction of the room across it. The floor falls toward -y, so that is the
// end worth reaching.
drain_low_bias = 1.00;
// Margin kept between the slot and the groove ring (mm).
drain_margin = 1.0;

/* [Fit coupon] */

// The coupon is a short open ring of the pocket section and nothing else — no
// tilt, no floor, no joint. Open at both ends on purpose: it slides right up
// the leg, so it answers "does it fit" and "is the section the same all the
// way up" in the same handling, and the leg's cut end never has to be square
// for the test to mean something.

// Height of a coupon ring (mm). Enough to feel the fit and sit square on the
// leg, not enough to spend plate time on.
coupon_h = 12.0;
// Per-side pocket clearances to try, TIGHTEST FIRST. Each gets a ring, marked
// with that many notches on one long face — one notch is the first value.
// Whichever ring is right, put its number in pocket_clear.
coupon_clears = [0.10, 0.20, 0.30];
// Gap between rings on the plate (mm).
coupon_gap = 8.0;
// Notch width and depth (mm), and the spacing between notches.
coupon_notch_w = 2.0;
coupon_notch_d = 0.8;
coupon_notch_pitch = 4.0;

/* [Layout] */

// Gap between parts on the print plate (mm).
plate_gap = 8.0;

/* [Quality] */

$fa = 4;
$fs = 0.4;

/* [Hidden] */

eps = 0.01;
big = 400;

// --- pocket and tube ---
pocket_w = leg_w + 2 * pocket_clear;
pocket_d = leg_d + 2 * pocket_clear;
pocket_r = leg_r + pocket_clear;

tube_w = pocket_w + 2 * wall_t;
tube_d = pocket_d + 2 * wall_t;
tube_r = pocket_r + wall_t;

// --- joint offsets, all measured inward from the stack outline ---
groove_out = joint_wall;
tongue_out = joint_wall + joint_clear;
tongue_in  = tongue_out + tongue_t;
groove_in  = tongue_in + joint_clear;

// --- the stack outline, shared by slab, shim and the base's tongue ---
// Depth is the tube's footprint where a horizontal plane cuts it, which is
// stretched by 1/cos(lean), plus the ledge. That way the slab is never
// narrower than the tube standing on it.
//
// The ledge is also what pushes the groove ring outboard of the pocket. Widen
// it until the groove's inner face clears the pocket wall's outer face by
// joint_gap, and the pocket floor then sits on solid slab all the way to z = 0
// instead of on the groove's roof — which is worth joint_h of ride height.
stack_over = max(stack_over_min, groove_in + joint_gap - wall_t);

stack_w = tube_w + 2 * stack_over;
stack_d = tube_d / cos(lean) + 2 * stack_over;
stack_r = tube_r + stack_over;

base_w = stack_w + 2 * base_over;
base_d = stack_d + 2 * base_over;
base_r = stack_r + base_over;

// --- receiver slab ---
// How far the tilted pocket floor drops below its centre at the pocket edge.
floor_drop = (pocket_d / 2) * tan(lean);
// Tall enough for two independent things: floor_t under the pocket's low
// corner, and groove_roof over the groove out where the wall lands on it.
// Whichever binds, wins.
slab_h = max(floor_t + floor_drop, joint_h + groove_roof);
// How far the tube has to be extended below the tilt origin so that, once it
// is cut flat at the slab top, no wedge of it is left hanging in the air.
tube_under = (tube_d / 2) * tan(lean) + 1;

// Half-dimensions of the tongue's outer face, where the ribs sit.
rib_face_x = stack_w / 2 - tongue_out;
rib_face_y = stack_d / 2 - tongue_out;
rib_h = joint_h - tongue_cham;

// A rib has to sit on the straight part of a face, clear of the corner arc and
// clear of its own fillet radius.
tongue_r  = stack_r - tongue_out;
rib_run_y = rib_face_y - tongue_r - rib_r;
rib_run_x = rib_face_x - tongue_r - rib_r;

// Three ribs on a face long enough to space them, two otherwise. Which pair of
// faces is the long one flips with the leg section and with which way the leg
// leans, so it is asked rather than assumed.
function rib_pos(run) =
    run > rib_min_three ? [-run * rib_spread, 0, run * rib_spread]
                        : [-run * rib_spread, run * rib_spread];

rib_y = rib_pos(rib_run_y);   // ribs on the +/-x faces, spaced along y
rib_x = rib_pos(rib_run_x);   // ribs on the +/-y faces, spaced along x

// Drain slot. Room left inside the groove ring on each axis...
drain_room_x = stack_w / 2 - groove_in - drain_d / 2 - drain_margin;
drain_room_y = stack_d / 2 - groove_in - drain_d / 2 - drain_margin;
// ...and the slot lies along whichever axis has more of it, pushed as far
// toward the low side of the tilted floor as the other axis allows. Which of
// the two that is depends on the leg section, so neither is hard-coded.
drain_in_x = drain_room_x > drain_room_y;
drain_half = (drain_in_x ? drain_room_x : drain_room_y) * drain_reach;
drain_bias = drain_low_bias * (drain_in_x ? -drain_room_y
                                          : -(drain_room_y - drain_half));

// Height of the pocket floor above the ground with no shims, at the leg's
// centreline. Not the same thing as how far the chair goes up.
min_lift = base_h + slab_h;

// How far the chair actually rises. A square-cut raked leg rests on ONE EDGE of
// its end face, not on the whole face, so the bare leg's contact with the patio
// is its low corner — and in the foot that corner sits on the low corner of the
// tilted pocket floor, which is lower than the centreline by the leg's own
// half-depth times the rake. That difference is why the useful number is not
// min_lift.
leg_lift = min_lift - (leg_d / 2) * tan(lean);

// Overall height of the foot with no shims. The mouth is a tilted plane, so the
// tallest point is its high edge.
receiver_h = slab_h + pocket_h * cos(lean) + (tube_d / 2) * sin(lean);
foot_h     = base_h + receiver_h;

echo(str("lifts the leg ", leg_lift, " mm, then ", shim_h, " mm a shim; ",
         "pocket floor at ", min_lift, " mm on the centreline"));
echo(str("base + receiver stands ", foot_h, " mm tall overall; ",
         "receiver ", receiver_h, ", slab ", slab_h));
echo(str("pocket ", pocket_w, " x ", pocket_d,
         "; stack ", stack_w, " x ", stack_d,
         "; base ", base_w, " x ", base_d));
// Guards on the two things that silently go wrong when the leg section moves:
// a rib walking off the end of its face, and the drain slot cutting into the
// groove ring or out through the pocket wall.
assert(rib_run_x > 0 && rib_run_y > 0,
       "no straight run left on a tongue face for a crush rib");
assert(2 * rib_r - rib_proud_bot < tongue_t,
       "crush rib breaks out through the back of the tongue");
assert(wall_t + stack_over - groove_in >= joint_gap - eps,
       "groove ring is under the pocket floor, so joint_h is back in the ride height");
assert(shim_h > joint_h + 1.0,
       "shim web between groove floor and tongue root is too thin");
assert(drain_room_x > 0 && drain_room_y > 0,
       "drain slot has no room inside the groove rings");
assert(abs(drain_in_x ? drain_half : 0) + drain_d / 2 < pocket_w / 2 &&
       abs(drain_bias) + (drain_in_x ? 0 : drain_half) + drain_d / 2 < pocket_d / 2,
       "drain slot runs out from under the pocket floor");

for (i = [0 : len(coupon_clears) - 1])
    echo(str("coupon ", i + 1, ": ", i + 1, " notch", i > 0 ? "es" : "",
             ", clearance ", coupon_clears[i], " per side, bore ",
             leg_w + 2 * coupon_clears[i], " x ", leg_d + 2 * coupon_clears[i]));

// ---------------------------------------------------------------- outlines --

// Rounded rectangle centred on the origin. Shrink then round out, so the
// radius is a true corner radius rather than a fillet added to the outside.
module rrect(w, d, r) {
    offset(r = r) offset(delta = -r) square([w, d], center = true);
}

module stack_outline()  rrect(stack_w, stack_d, stack_r);
module base_outline()   rrect(base_w, base_d, base_r);
module tube_outline()   rrect(tube_w, tube_d, tube_r);
module pocket_outline() rrect(pocket_w, pocket_d, pocket_r);

module drain_outline() {
    hull() {
        translate(drain_in_x ? [-drain_half, drain_bias]
                             : [0, drain_bias - drain_half]) circle(d = drain_d);
        translate(drain_in_x ? [ drain_half, drain_bias]
                             : [0, drain_bias + drain_half]) circle(d = drain_d);
    }
}

// ------------------------------------------------------------------ solids --

// A prism of the stack outline inset by `inset`, running z0 to z1, with a
// 45-degree flare at either end. A POSITIVE cham grows the shape at that end,
// a NEGATIVE one shrinks it — which is what lets the same module cut both the
// outer surface of a ring and the plug that hollows it, with the chamfers
// falling on opposite sides of the wall.
//
// The four slices hull into exactly the right shape because every offset of a
// rounded rectangle is convex, and "vertical then sloping" is convex in z.
module inset_prism(inset, z0, z1, cham_bot = 0, cham_top = 0) {
    hull() {
        translate([0, 0, z0]) linear_extrude(eps)
            offset(delta = -(inset - cham_bot)) stack_outline();
        translate([0, 0, z0 + abs(cham_bot)]) linear_extrude(eps)
            offset(delta = -inset) stack_outline();
        translate([0, 0, z1 - abs(cham_top) - eps]) linear_extrude(eps)
            offset(delta = -inset) stack_outline();
        translate([0, 0, z1 - eps]) linear_extrude(eps)
            offset(delta = -(inset - cham_top)) stack_outline();
    }
}

// One crush rib, drawn with its axis on the tongue face and +x pointing out of
// it. Only the part standing proud of the face does any work; the rest is
// buried in the tongue.
module crush_rib() {
    hull() {
        translate([rib_proud_bot - rib_r, 0, 0])
            cylinder(h = eps, r = rib_r);
        translate([rib_proud_top - rib_r, 0, rib_h - eps])
            cylinder(h = eps, r = rib_r);
    }
}

// The tongue ring standing on z = 0, ribs included. Ribs stop short of the top
// chamfer so the lead-in stays clean where the joint first meets.
module tongue() {
    difference() {
        inset_prism(tongue_out, 0, joint_h, 0, -tongue_cham);
        inset_prism(tongue_in, -eps, joint_h + eps, 0, tongue_cham);
    }

    for (y = rib_y) {
        translate([ rib_face_x, y, 0])                    crush_rib();
        translate([-rib_face_x, y, 0]) rotate([0, 0, 180]) crush_rib();
    }
    for (x = rib_x) {
        translate([x,  rib_face_y, 0]) rotate([0, 0,  90]) crush_rib();
        translate([x, -rib_face_y, 0]) rotate([0, 0, -90]) crush_rib();
    }
}

// The matching groove, as a solid to subtract, cut into the bottom face at
// z = 0. Flared at its mouth on both walls.
module groove() {
    difference() {
        inset_prism(groove_out, -eps, joint_h, groove_cham, 0);
        inset_prism(groove_in, -eps, joint_h + eps, -groove_cham, 0);
    }
}

// A plate of the stack outline with the bottom outside edge relieved.
module stack_plate(h) {
    hull() {
        linear_extrude(eps) offset(delta = -base_cham) stack_outline();
        translate([0, 0, base_cham]) linear_extrude(eps) stack_outline();
        translate([0, 0, h - eps]) linear_extrude(eps) stack_outline();
    }
}

module drain(h) {
    translate([0, 0, -eps]) linear_extrude(h + 2 * eps) drain_outline();
}

// The tilted frame the receiver's tube and pocket are drawn in. Its origin sits
// on the slab's top face at the part's centre, and its z axis is the leg axis.
module tilted() {
    translate([0, 0, slab_h]) rotate([lean, 0, 0]) children();
}

// ------------------------------------------------------------------- parts --

module base() {
    difference() {
        union() {
            hull() {
                linear_extrude(eps) offset(delta = -base_cham) base_outline();
                translate([0, 0, base_cham]) linear_extrude(eps) base_outline();
                translate([0, 0, base_h - eps]) linear_extrude(eps) base_outline();
            }
            translate([0, 0, base_h]) tongue();
        }
        drain(base_h + joint_h);
    }
}

module shim() {
    difference() {
        union() {
            stack_plate(shim_h);
            translate([0, 0, shim_h]) tongue();
        }
        groove();
        drain(shim_h + joint_h);
    }
}

module receiver() {
    difference() {
        union() {
            stack_plate(slab_h);

            // The leaning tube, sliced off flat where it meets the slab.
            intersection() {
                tilted()
                    translate([0, 0, -tube_under])
                        linear_extrude(tube_under + pocket_h) tube_outline();
                translate([-big / 2, -big / 2, slab_h]) cube([big, big, big]);
            }
        }

        tilted() {
            // Pocket. Its floor is the plane z = 0 of the tilted frame, so it
            // is square to the leg and the tube's cut end seats flat on it.
            translate([0, 0, -eps])
                linear_extrude(pocket_h + 2 * eps) pocket_outline();

            // Mouth flare.
            hull() {
                translate([0, 0, pocket_h - mouth_cham])
                    linear_extrude(eps) pocket_outline();
                translate([0, 0, pocket_h + eps])
                    linear_extrude(eps) offset(delta = mouth_cham) pocket_outline();
            }
        }

        groove();
        // Tall enough to break through the tilted floor at the slot's high end.
        drain(slab_h + floor_drop + 1);
    }
}

// ------------------------------------------------------------------ output --

module plate() {
    translate([-(base_w + plate_gap) / 2, -(base_d + plate_gap) / 2])  base();
    translate([ (stack_w + plate_gap) / 2, -(stack_d + plate_gap) / 2]) receiver();
    translate([ (stack_w + plate_gap) / 2,  (stack_d + plate_gap) / 2]) shim();
}

// One coupon ring at a given per-side clearance, carrying `marks` notches.
//
// Both mouths are flared, not just the top: the ring goes on either way up,
// and on the bottom the flare also cancels the first layer's squish, which
// would otherwise pinch the bore exactly where it is measured.
module coupon_ring(clear, marks) {
    pw = leg_w + 2 * clear;
    pd = leg_d + 2 * clear;
    pr = leg_r + clear;
    ow = pw + 2 * wall_t;
    od = pd + 2 * wall_t;
    orr = pr + wall_t;

    difference() {
        hull() {
            linear_extrude(eps)
                rrect(ow - 2 * base_cham, od - 2 * base_cham, orr - base_cham);
            translate([0, 0, base_cham]) linear_extrude(eps) rrect(ow, od, orr);
            translate([0, 0, coupon_h - eps]) linear_extrude(eps) rrect(ow, od, orr);
        }

        translate([0, 0, -eps]) linear_extrude(coupon_h + 2 * eps) rrect(pw, pd, pr);

        // The two flares have to be separate hulls. Hulling all four slices at
        // once would just give the straight prism of the wide ones, with the
        // narrow middle swallowed inside it.
        hull() {
            translate([0, 0, -eps]) linear_extrude(eps)
                rrect(pw + 2 * mouth_cham, pd + 2 * mouth_cham, pr + mouth_cham);
            translate([0, 0, mouth_cham]) linear_extrude(eps) rrect(pw, pd, pr);
        }
        hull() {
            translate([0, 0, coupon_h - mouth_cham]) linear_extrude(eps)
                rrect(pw, pd, pr);
            translate([0, 0, coupon_h + eps]) linear_extrude(eps)
                rrect(pw + 2 * mouth_cham, pd + 2 * mouth_cham, pr + mouth_cham);
        }

        for (i = [0 : marks - 1])
            translate([(i - (marks - 1) / 2) * coupon_notch_pitch,
                       od / 2 - coupon_notch_w / 2 + coupon_notch_d,
                       -eps])
                cylinder(d = coupon_notch_w, h = coupon_h + 2 * eps);
    }
}

module coupon() {
    n     = len(coupon_clears);
    pitch = leg_d + 2 * max(coupon_clears) + 2 * wall_t + coupon_gap;
    for (i = [0 : n - 1])
        translate([0, (i - (n - 1) / 2) * pitch, 0])
            coupon_ring(coupon_clears[i], i + 1);
}

module stack(n = 2) {
    base();
    for (i = [0 : n - 1])
        translate([0, 0, base_h + i * shim_h]) shim();
    translate([0, 0, base_h + n * shim_h]) receiver();
}

if      (show == "shim")   shim();
else if (show == "base")   base();
else if (show == "plate")  plate();
else if (show == "stack")  stack();
else if (show == "coupon") coupon();
else                       receiver();
