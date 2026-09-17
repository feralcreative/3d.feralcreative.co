// De'Longhi panel heater stand.
//
// The heater normally stands on its bottom; this stands it on its side. Ziad
// traced the edge that goes into the stand, in section, in
// "_incoming/Asset 1.svg": a flat line 63 wide where the trace stops, two
// curved sides — one straight then curling in, one long slope — meeting at a
// 15 mm flat, 80 mm below. That trace is the whole reason the part exists,
// and it is the only measurement here that came off the heater.
//
// THE FORM. A block with that trace cut down into it from the top, so the
// heater's edge drops into a V: 63 across at the mouth, 15 at the floor, 80
// deep. It is a 2D drawing — the block's outline with the trace taken out of
// it — extruded along the heater's edge, and that is all it is. The V is the
// trace grown by a clearance and carried on above the flat edge along the
// outline's end tangents, since the heater continues past where the trace
// stops and its front is still opening out there (about 4 degrees), so a
// vertical mouth would bind on it. A short chamfer widens the mouth further
// so the heater finds its way in.
//
// THE FRONT IS BENT IN, and that is the one correction the coupon made. Held
// against the heater, the first coupon (v06, 2026-09-16) was right everywhere
// but along the front: the trace has that side as one long, nearly straight
// slope, and on the heater the upper half of it curls in toward the back.
// So the front is left as traced up to a knee, front_knee of the way up,
// and from there bent toward the back on a circular arc, tangent at the
// knee, so that the tip — where the front meets the flat edge — lands
// front_tip_in to the left of where the trace had it. Ziad's words, over two
// coupons: the apex at the middle and the tip 5 mm in (v09), then a few mm
// more with the apex about 30% up from the bottom. The shift is horizontal,
// so the tip stays on the flat edge.
// The back, the floor and the corners are as traced. The mouth's tangent on
// the front is taken off the bent curve, which now leans INWARD about 11
// degrees at the tip, so the short run above the trace narrows rather than
// opens — that is what the arc says the heater does, and the block stops at
// the trace anyway; only the chamfer sees it.
//
// ⚠️ THE MOUTH IS NOW NARROWER THAN THE V JUST BELOW IT, on the front, by the
// amount the echo reports (1.73 mm at 8 in from a 30% knee). The heater has
// the same shape, so it is not a rigid drop-in from directly above: it goes
// in with a lean, or slides in along the edge. The clearance and the chamfer
// cover a re-entry this small; if front_tip_in grows, watch that number.
//
// ⚠️ THIS WAS GOT WRONG TWICE, both times from the words "bend the front
// toward the back by 5 mm, apex at the middle". v07 bowed the whole front
// into the V as a fixed-ended arc; v08 bowed it outward. Neither was printed:
// each was caught in a labelled render. What he meant was the tip moving,
// with the bend centred on the middle. Anything that bends here gets a
// labelled render with the old line overlaid before a build.
//
// The block is a trapezoid, wide at the floor and narrower at the mouth,
// because the heater on edge is the best part of a metre tall and the V is
// only 63 wide: the base width is the stability, and a trapezoid gets it
// without printing a slab. Along the heater's edge it runs 210, the whole of
// the bed that the mesh actually probes (the outer 5 mm is extrapolated — see
// the printer reference, §2); longer than that means printing it on the
// diagonal. Printed as drawn, floor down, the V opening up, nothing overhangs
// — every face either stands or leans back.
//
// THE PROFILE is the SVG's one path as an absolute cubic Bezier path, made
// with utils/svg2bez.py and flipped so y is up. The file is in PostScript
// points (72/in) at 1:1 — 226.77 pt is exactly 80 mm — so the conversion is
// a scale and nothing else; the straight runs are degenerate cubics so the
// whole outline is one bezpath. It is drawn here rather than imported: see
// logos/marks.scad for what goes wrong when a part calls import() on an SVG.
//
// TWO BUILDS:
//
//     utils/build.sh parts/delonghi-heater-stand.scad
//     utils/build.sh parts/delonghi-heater-stand.scad -D 'show="coupon"' --name delonghi-heater-stand-coupon
//
// The coupon is a slice of the section with the outside trimmed away: the V,
// its chamfer and its floor exactly as the stand has them, in a band of
// material just wide enough to hold, to press against the heater's edge and
// see where the trace and the clearance are wrong before printing a litre
// and a half of block around them. It is modelled lying on its face, so the
// outline prints in the plane of the bed and comes out as drawn rather than
// as layer steps. The trace was done by eye; expect to move `clearance`
// after the coupon, not before. A V forgives a lot: if the trace is off the
// heater simply seats a little higher.
//
// Axes: X across the heater's thickness, Z up, Y along the heater's edge.

include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/beziers.scad>

/* [Build] */

show = "stand";     // [stand, coupon]

/* [Fit] */

clearance = 0.5;    // gap between the traced outline and the V, all round (mm); the trace is by eye, so start loose
front_tip_in = 8;   // how far left (toward the back) the front's tip moves, on an arc that starts at the knee (mm). 5 off the v06 coupon, then "a few mm more" off v09; 0 is the trace as traced
front_knee   = 0.30; // where the bend starts, as a fraction of the front's length up from the floor corner. Was 0.5; Ziad moved it to 0.3 after v09
lead_in   = 2;      // 45-degree chamfer on both lips of the mouth (mm)

/* [Block] */

length   = 210;     // along the heater's edge — as long as the bed's probed mesh goes (mm)
base_w   = 150;     // across the floor — this is the stability across the heater (mm)
top_w    = 100;     // across the top, either side of the 63 mm mouth (mm)
floor_t  = 6;       // under the V's floor (mm)
top_r    = 6;       // rounding on the top corners (mm)
foot_chamfer = 0.5; // chamfer on the bottom edges, against elephant foot (mm)

/* [Coupon] */

coupon_length = 10; // the slice's thickness, along the heater's edge (mm)
coupon_band   = 6;  // material kept around the V; the floor under it is floor_t regardless (mm)

/* [Hidden] */

$fn = 64;
eps = 0.01;

// The traced edge, "_incoming/Asset 1.svg", as an absolute cubic bezpath in
// mm: point, control, control, point, ... Origin is the SVG's left edge and
// the 15 mm flat; y is up, so the flat edge where the trace stops is at
// y = 80 and the narrow flat at y = 0. If the trace is ever redone:
//
//     utils/svg2bez.py "_incoming/Asset 1.svg" --height 80
HEATER_BEZ = [
    [62.912, 80.000],
    [41.941, 80.000], [20.971, 80.000], [ 0.000, 80.000],   // the flat edge where the trace stops
    [ 0.000, 58.397], [ 7.994, 40.757], [ 9.088, 37.472],   // one side: straight, then curling in
    [10.183, 34.187], [16.909, 16.825], [18.630, 11.976],
    [19.795,  8.694], [20.028,  4.368], [20.057,  1.915],
    [20.069,  0.853], [20.933,  0.000], [21.995,  0.000],   // corner
    [27.036,  0.000], [32.077,  0.000], [37.118,  0.000],   // the 15 mm flat
    [37.872,  0.000], [38.561,  0.422], [38.902,  1.095],   // corner
    [42.335,  7.867], [60.380, 44.907], [62.912, 80.000],   // the other side: one long slope
];
HEATER_W = 62.912;  // the trace's width at the flat edge (mm)
HEATER_H = 80;      // the trace's height, narrow flat to flat edge (mm)

// The front is the last cubic, from the floor corner's exit at index 21 to
// the tip. It is sampled and bent: below the knee — front_knee of the way
// up its chord — nothing moves; above it, each point moves left — straight
// along -x, so the tip stays on the flat edge — by the rise of a circular
// arc that is tangent to the chord at the knee and front_tip_in off it at
// the tip.
FRONT_I   = 21;
front_bez = select(HEATER_BEZ, FRONT_I, FRONT_I + 3);
front_A   = front_bez[0];
front_B   = front_bez[3];
front_L   = norm(front_B - front_A);                 // the chord (mm)
front_u   = (front_B - front_A) / front_L;           // along it, upward
front_arm = (1 - front_knee) * front_L;              // the chord above the knee (mm)
front_R   = front_tip_in > 0
          ? (front_arm * front_arm + front_tip_in * front_tip_in) / (2 * front_tip_in)
          : 0;
function front_bent(p) =
    let (s = (p - front_A) * front_u - front_knee * front_L)   // distance past the knee, along the chord
    front_tip_in <= 0 || s <= 0 ? p
    : p - [front_R - sqrt(front_R * front_R - s * s), 0];
front_pts = [for (p = bezier_curve(front_bez, 48)) front_bent(p)];
front_tip = last(front_pts);                         // where the front now meets the flat edge

// The whole outline as points, starting at the flat edge's far end and going
// round: down the back, along the floor, up the bent front to the tip. The
// flat edge itself is the polygon's closing side, tip back to [0, 80], so it
// runs to wherever the tip has moved to. The front's first point is the
// trace's last, so it is dropped rather than doubled.
heater_pts = concat(bezpath_curve(select(HEATER_BEZ, 3, FRONT_I), splinesteps = 24),
                    list_tail(front_pts, 1));

// Where each side is heading as it leaves the trace, x per mm of y. The left
// is vertical; the right leans in once bent — the arc turns the tip's tangent
// about 16 degrees toward the back. The mouth follows these, and the run
// above the trace is kept short (ext) because an inward lean carried far
// enough would cross the back and fold the polygon.
left_dxdy  = (HEATER_BEZ[3][0] - HEATER_BEZ[4][0]) / (HEATER_BEZ[3][1] - HEATER_BEZ[4][1]);
right_dxdy = (front_tip[0] - front_pts[len(front_pts) - 2][0])
           / (front_tip[1] - front_pts[len(front_pts) - 2][1]);
function left_x(y)  = 0            + left_dxdy  * (y - HEATER_H);   // in the trace's own frame
function right_x(y) = front_tip[0] + right_dxdy * (y - HEATER_H);
ext = 30;   // how far the heater is carried on above the trace (mm); past the block top is all that matters

// How much narrower the mouth is than the widest point of the V below it,
// on the front (mm). Zero when the tip is the widest point, as traced.
front_reentry = max([for (p = front_pts) p[0]]) - front_tip[0];

// ---- derived ---------------------------------------------------------------

x_off   = -HEATER_W / 2;             // centres the trace on x = 0
block_h = floor_t + HEATER_H;        // the mouth is exactly where the trace stops

// ---- 2D, in the section: x across, y up --------------------------------------

// The traced edge, centred on x = 0, sitting on y = floor_t.
module heater_trace() {
    translate([x_off, floor_t]) polygon(heater_pts);
}

// The trace plus the heater above it, along the end tangents, out past the
// top of the block.
module heater_section() {
    union() {
        heater_trace();
        translate([x_off, floor_t]) polygon([
            [left_x(HEATER_H),        HEATER_H - eps],
            [right_x(HEATER_H),       HEATER_H - eps],
            [right_x(HEATER_H + ext), HEATER_H + ext],
            [left_x(HEATER_H + ext),  HEATER_H + ext],
        ]);
    }
}

// The V: the heater grown by the clearance, with the mouth chamfered.
module v_cut() {
    y0 = HEATER_H - lead_in;         // where the chamfer starts, in the trace's frame
    union() {
        offset(r = clearance) heater_section();
        translate([x_off, floor_t]) polygon([
            [left_x(y0)       - clearance,           y0],
            [right_x(y0)      + clearance,           y0],
            [right_x(HEATER_H) + clearance + lead_in, HEATER_H + eps],
            [left_x(HEATER_H)  - clearance - lead_in, HEATER_H + eps],
        ]);
    }
}

// The block's outline: a trapezoid on the floor, top corners rounded, bottom
// corners chamfered. BOSL2's corner order is [X+Y+, X-Y+, X-Y-, X+Y-].
module block_outline() {
    trapezoid(h = block_h, w1 = base_w, w2 = top_w,
              rounding = [top_r, top_r, 0, 0],
              chamfer  = [0, 0, foot_chamfer, foot_chamfer],
              anchor = FRONT);
}

module section() {
    difference() {
        block_outline();
        v_cut();
    }
}

// ---- 3D -------------------------------------------------------------------

// Stand a section up: its y becomes Z, and it runs along Y.
module upright(len) {
    rotate([90, 0, 0]) linear_extrude(len, center = true, convexity = 4) children();
}

module stand() { upright(length) section(); }

// The section, its outside trimmed to a band around the V, lying flat.
module coupon() {
    linear_extrude(coupon_length, convexity = 4) difference() {
        intersection() {
            block_outline();
            offset(r = clearance + coupon_band) heater_section();
        }
        v_cut();
    }
}

echo(str("front tip ", front_tip_in, " in: tip at x ", front_tip[0] + x_off,
         " (was ", HEATER_W + x_off, "), mouth ", front_tip[0], " wide at the trace, ",
         "tangent at the tip ", atan(right_dxdy), " deg from vertical (negative leans in), ",
         "mouth narrower than the V below it by ", front_reentry));

if (show == "coupon") coupon();
else stand();
