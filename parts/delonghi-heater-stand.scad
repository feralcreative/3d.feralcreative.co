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
// THE FRONT IS BENT, and that is the one correction the coupon made. Held
// against the heater, the first coupon (v06, 2026-09-16) was right everywhere
// but along the front, which stood off the heater in the middle: the trace
// has that side as one long, nearly straight slope, and the heater's front is
// really an arc. So the front is bent toward the back by front_bow — a
// circular arc through the trace's two ends, with its apex at the midpoint,
// which is exactly the shape Ziad described. The back, the floor and the
// corners are as traced. The mouth's tangent on that side is taken off the
// bent curve, so the chamfer starts where the wall actually is.
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
front_bow = 5;      // the front bent toward the back: sagitta of the arc, apex at half height, zero at both ends (mm). Off the v06 coupon; 0 is the trace as traced
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
big = 500;

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
// the top. It is sampled and bent: each point moved perpendicular to the
// chord, toward the back, by the height of a circular arc of sagitta
// front_bow over that chord — nothing at either end, front_bow at the middle.
FRONT_I   = 21;
front_bez = select(HEATER_BEZ, FRONT_I, FRONT_I + 3);
front_A   = front_bez[0];
front_B   = front_bez[3];
front_L   = norm(front_B - front_A);                 // the chord (mm)
front_u   = (front_B - front_A) / front_L;           // along it, upward
front_n   = [-front_u.y, front_u.x];                 // across it, toward the back
front_R   = front_bow > 0 ? (front_L * front_L / 4 + front_bow * front_bow) / (2 * front_bow) : 0;
function front_bowed(p) =
    front_bow <= 0 ? p
    : let (s = (p - front_A) * front_u - front_L / 2)   // distance from the chord's midpoint
      p + front_n * (sqrt(front_R * front_R - s * s) - (front_R - front_bow));
front_pts = [for (p = bezier_curve(front_bez, 48)) front_bowed(p)];

// The whole outline as points: the trace up to where the front begins, then
// the bent front. The front's first point is the trace's last, so it is
// dropped rather than doubled.
heater_pts = concat(bezpath_curve(select(HEATER_BEZ, 0, FRONT_I), splinesteps = 24),
                    list_tail(front_pts, 1));

// Where each side is heading as it leaves the trace, x per mm of y. The left
// is vertical; the right is still opening out — more so once bent, since an
// arc leaves its chord at an angle. The mouth follows these.
left_dxdy  = (HEATER_BEZ[3][0] - HEATER_BEZ[4][0]) / (HEATER_BEZ[3][1] - HEATER_BEZ[4][1]);
right_dxdy = (last(front_pts)[0] - front_pts[len(front_pts) - 2][0])
           / (last(front_pts)[1] - front_pts[len(front_pts) - 2][1]);
function left_x(y)  = 0        + left_dxdy  * (y - HEATER_H);   // in the trace's own frame
function right_x(y) = HEATER_W + right_dxdy * (y - HEATER_H);

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
            [left_x(HEATER_H),  HEATER_H - eps],
            [right_x(HEATER_H), HEATER_H - eps],
            [right_x(big),      big],
            [left_x(big),       big],
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

if (show == "coupon") coupon();
else stand();
