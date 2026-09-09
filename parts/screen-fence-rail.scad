// screen-fence-rail.scad
//
// Snap-in fence for the bottom track of the roll-up screen doors. It drops into
// the track from the room side, hooks under the near wall's internal ledge, and
// stands as a low fence whose far face pins the screen mesh against the outer
// wall — so a cat can no longer push the mesh inboard and climb under it.
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
//     z 4.77 - 5.65   LEDGE      reaches 3.14 mm inboard   (gap 15.76 mm)
//     z 6.96 - 9.01   MID HOOK   reaches 1.35 mm inboard   (gap 19.34 mm)
//     z 13.28 - 15.15 TOP LIP    reaches 1.35 mm inboard   (gap 19.34 mm)
//
// ⚠️ These are read off a drawing, not off the rail. The outline is drawn with
// a 0.26 mm line and the readings take its inner edge, so the real clear space
// is up to ~0.13 mm larger than assumed here — i.e. the part errs small, which
// is the safe direction. The one figure worth a caliper before printing 200 mm
// is the 22.04 mm clear width; print show="coupon" and try the three fits.
//
// ---------------------------------------------------------------------------
// WHY THIS SHAPE
// ---------------------------------------------------------------------------
// The mesh floats free in the channel and has to stay free — it runs the length
// of the track and slides as the screen retracts. So nothing may cross the plane
// the mesh hangs in, which rules out any part that spans wall to wall above the
// ledges, and with it every symmetric two-sided snap. The grip has to come off
// the near wall alone.
//
// Of the three features on that wall the LEDGE is the one worth having: 3.14 mm
// of positive undercut against 1.35 mm at either hook, and the chamber beneath
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
//
// Rotating the far side up is the removal motion, and the only way out. A cat
// is on the wrong side of the fence to do it.
//
// MESH SAFETY. The mesh sits in a 2.10 mm slot bounded by the fence face and
// the far wall's hooks — ten times narrower than the 22 mm it wanders in now,
// and still loose enough that nothing rubs. Every corner is rounded, the fence
// face is printed as a vertical wall so its layer lines run along the direction
// the mesh travels, and its bottom corner is rounded so the mesh is swept up
// onto the far ledge instead of into the 0.31 mm gap behind it.
//
// PRINT. Lying down, cross-section in the bed's XZ, length along Y — as built.
// The base plate gives a 15.2 x seg_len first layer and the fence face is a
// vertical wall. The only overhang is the tongue's underside, cut at 45 deg.
// Fence and mesh face are both 1.74 mm, four lines at the 0.4 nozzle's real
// inner width. PETG.

/* [Output] */

// "fence" is the printable part. "coupon" is three 30 mm slices at different
// clearances — print it and find which one seats on the real rail before
// committing to a full segment.
//
// "track" is the aluminium extrusion itself, drawn from the measured profile,
// and "assembly" shows the fence hooked into it with the mesh in the slot.
// Both are previews for checking the interlock by eye — NOT for printing. If
// you ever want one as an STL, build it with --name so it does not overwrite
// the fence's own version series.
// "fitcheck" is the interference test — see the module.
show = "fence";  // [fence, coupon, track, assembly, fitcheck]

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Track — MEASURED, see header. Do not change without re-measuring] */

// Clear width of the channel, inner wall face to inner wall face (mm).
trk_clear_w  = 22.04;
// Inner floor to the top of the walls (mm).
trk_depth    = 15.15;
// How far the mid hooks and the top lips reach inboard of the wall face (mm).
trk_hook_x   = 1.35;
// How far the lower ledge reaches inboard of the wall face (mm).
trk_ledge_x  = 3.14;
// Underside of the lower ledge, above the inner floor (mm).
trk_ledge_z0 = 4.77;
// Top face of the lower ledge, above the inner floor (mm).
trk_ledge_z1 = 5.65;
// Underside and top of the mid hook, above the inner floor (mm).
trk_hook_z0  = 6.96;
trk_hook_z1  = 9.01;
// Underside of the top rolled lip, above the inner floor (mm).
trk_lip_z0   = 13.28;

/* [Track shell — drawing only, nothing is designed against these] */

// Outside of the extrusion (mm) — the two figures the drawing dimensions
// directly, and the two that fixed its scale.
trk_outer_w = 23.80;
trk_outer_h = 15.90;

// Wall and base skin (mm), from the centre-to-centre spacing of the drawn wall
// lines.
//
// NOTE the deliberate inconsistency: 23.80 - 2 x 0.77 is 22.26, but
// trk_clear_w above is 22.04. That is not an error. 22.04 is the reading taken
// from the INNER edges of those same lines, and the fence is designed against
// it precisely because it is the pessimistic one — the part comes out up to
// 0.22 mm narrower than it needs to be, which is the safe direction. So the
// preview shows about 0.11 mm more room per side than the fence assumes. Below
// the drawing's resolution, and it errs the right way.
trk_skin = 0.77;

// Diameter of the void inside the rolled hook and the rolled top lip (mm).
// Cosmetic — it is what makes them read as curls rather than plain beads.
trk_roll_void = 0.55;

/* [Preview] */

// Length of track and fence drawn for "track" and "assembly" (mm). Short, so
// the section stays legible in a render.
preview_len = 60;

// Thickness of the mesh drawn in the slot (mm), and how far it stands above the
// top of the rail. Representative only — the mesh floats and is not modelled
// as anything but a flat strip.
mesh_t = 0.35;
mesh_rise = 10;

/* [Fit] */

// Clearance to every track surface (mm). Drives the tongue height and how
// close the part sits to the near ledge, so it is the one number the coupon
// tests. 0.25 is the 0.4-nozzle snug figure from the printer reference.
clr = 0.25;

// Clear slot left for the mesh, between the fence face and the far wall's
// hooks (mm). This also sets how far the part can shift before the far ledge
// tip stops it, so keep it well under the 2.84 mm the tongue engages.
mesh_slot = 2.10;

/* [Part] */

// Length of one segment along the rail (mm). 200 keeps the whole footprint
// inside the 205 mm safe envelope; butt them end to end to fill the opening.
seg_len = 200;

// How far the fence stands above the top of the rail (mm).
fence_h = 12;

// Wall thickness for the fence, the base plate and the ramp (mm). 1.74 is four
// lines at the 0.4 nozzle's real inner width of 0.45.
wall = 1.74;

// Height of the flat face at the tongue's tip (mm). Above this the tongue's
// underside is cut at 45 deg so it prints unsupported.
tip_face = 0.90;

// Solid gusset between the base plate and the ramp at the near-wall end (mm).
// The void behind the ramp starts this far inboard; without it the two plates
// would meet along a knife edge and hinge.
gusset = 2.60;

// Radius rounded onto every convex corner (mm). Keep it small — the tongue's
// tip face is the thinnest feature and the rounding is cut out of it.
fillet = 0.30;

/* [Coupon] */

// Clearances to try, one 30 mm slice each. Notches on the fence top count the
// slice, low clearance first.
coupon_clears = [0.15, 0.25, 0.35];
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
module profile(c = clr) {
    x_tip     = c + 0.05;                                  // tongue tip
    x_base    = trk_ledge_x + c;                           // ramp root / base plate, near end
    x_fence_o = trk_clear_w - trk_hook_x - mesh_slot;       // fence face, against the mesh
    x_fence_i = x_fence_o - wall;
    z_tongue  = trk_ledge_z0 - c;                          // tongue top, under the ledge
    z_tip     = z_tongue - tip_face;
    z_wedge   = z_tip - (x_base - x_tip);                  // 45 deg underside meets the base
    z_ramp    = z_tongue + (x_fence_i - x_base);           // ramp meets the fence
    z_top     = trk_depth + fence_h;

    // Void behind the ramp. Bottom is the base plate's top face, ceiling is the
    // ramp's underside — 45 deg, so it needs no support.
    hx0    = x_base + gusset;
    hz     = function (x) z_tongue - wall * sqrt(2) + (x - x_base);

    if (z_ramp > z_top - wall)
        echo(str("WARNING: fence_h = ", fence_h, " is too short for the ramp; ",
                 "raise it above ", z_ramp + wall - trk_depth));

    offset(r = fillet) offset(delta = -fillet)
    difference() {
        polygon([
            [x_base,    0        ],
            [x_fence_o, 0        ],
            [x_fence_o, z_top    ],
            [x_fence_i, z_top    ],
            [x_fence_i, z_ramp   ],
            [x_base,    z_tongue ],
            [x_tip,     z_tongue ],
            [x_tip,     z_tip    ],
            [x_base,    z_wedge  ],
        ]);

        polygon([
            [hx0,       wall     ],
            [x_fence_i, wall     ],
            [x_fence_i, hz(x_fence_i)],
            [hx0,       hz(hx0)  ],
        ]);
    }
}

// One length of fence, laid out for the plate: length along Y, height in Z.
module fence_length(len = seg_len, c = clr) {
    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 10)
                profile(c);
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
// inboard, and its far side runs back into the wall, which is what joins it on.
module rolled(x_reach, z0, z1) {
    r = (z1 - z0) / 2;
    difference() {
        translate([x_reach - r, (z0 + z1) / 2]) circle(r = r);
        translate([x_reach - r, (z0 + z1) / 2]) circle(d = trk_roll_void);
        // Open the roll downward, so it reads as a curl rather than a bead.
        translate([x_reach - r - trk_roll_void / 2, z0 - eps])
            square([trk_roll_void, r + eps]);
    }
}

// The three inward features carried by one wall, drawn at the near wall.
module track_features() {
    // Ledge, with the rounded tip the drawing shows.
    t = trk_ledge_z1 - trk_ledge_z0;
    hull() for (x = [t / 2, trk_ledge_x - t / 2])
        translate([x, trk_ledge_z0 + t / 2]) circle(d = t);

    rolled(trk_hook_x, trk_hook_z0, trk_hook_z1);
    rolled(trk_hook_x, trk_lip_z0,  trk_depth);
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

module track(len = preview_len) {
    translate([0, len, 0])
        rotate([90, 0, 0])
            linear_extrude(height = len, convexity = 10)
                track_profile();
}

// The mesh, where the fence holds it: flat against the far wall's hooks,
// standing on the far ledge and rising out of the rail.
module mesh(len = preview_len) {
    x0 = trk_clear_w - trk_hook_x - mesh_t;
    translate([x0, 0, trk_ledge_z1])
        cube([mesh_t, len, trk_depth - trk_ledge_z1 + mesh_rise]);
}

module assembly(len = preview_len) {
    color("silver")     track(len);
    color("dimgray")    mesh(len);
    color("darkorange") fence_length(len, clr);
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
module coupon_slice(c, n) {
    z_top = trk_depth + fence_h;
    difference() {
        fence_length(coupon_len, c);

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
    n = len(coupon_clears);
    for (i = [0 : n - 1])
        translate([0, i * (coupon_len + coupon_gap), 0])
            coupon_slice(coupon_clears[i], i + 1);
}

if      (show == "coupon")   coupon();
else if (show == "track")    track();
else if (show == "assembly") assembly();
else if (show == "fitcheck") fitcheck();
else                         fence();
