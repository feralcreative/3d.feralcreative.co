// 4K camera window mount — 100 mm long, 20 mm diameter, with one channel down its side.
//
// A round bar with a rectangular channel cut the full length of it. The channel
// is 4.5 mm wide and 10 mm deep, and since the bar is 20 mm across, 10 mm of
// depth lands the channel floor exactly on the axis — the cut is flush with the
// center line and the section left behind is a half-disc with two horns.
//
// EVERY EDGE IS ROUNDED 1 MM. Nothing on this part is a hard edge:
//
//   * the two inside corners where the channel floor meets its walls,
//   * the two convex mouth edges at the horn tips, running the full length,
//   * both end rims, all the way around the outside and around the channel.
//
// The first two live in the cross-section, so they are drawn into the profile
// as true tangent arcs rather than offset out of a sharp corner — the mouth
// fillet is the circle that is tangent to both the bore wall and the outside
// diameter, which is where mouth_cx comes from. The end rims are the sweep's
// business: offset_sweep() takes the finished profile and rolls a 1 mm
// round-over onto each end, following the channel as well as the outside.
//
// The horn tips are acute, so their 1 mm fillet wraps about 113 degrees rather
// than the 90 you would get on a square corner, and the end round-over takes
// each tip down to a point in its last layer. That is correct, not a defect.
//
// ORIENTATION. Printed standing on one end, axis on +z, so the channel runs
// vertically and prints as two flat walls with no overhang and no bridge. The
// end round-over makes the first layer a disc 1 mm smaller than the body, which
// is worth an extra brim line if adhesion is marginal.

include <../../../lib/BOSL2/std.scad>

/* [Cylinder] */

// Length of the bar along its axis (mm).
cyl_len = 100.0;
// Outside diameter (mm).
cyl_d = 20.0;

/* [Channel] */

// Width of the channel across the bar (mm).
chan_w = 4.5;
// Depth of the channel measured in from the outside surface (mm). At 10 on a
// 20 mm bar the floor sits on the axis; more than that cuts past center.
chan_d = 10.0;

/* [Rounding] */

// Radius on every edge of the part (mm) — the channel's inside corners, its
// mouth edges, and both end rims.
edge_r = 1.0;

/* [Quality] */

$fa = 4;    // organic faceting per the 0.4-nozzle rule
$fs = 0.4;
eps = 0.01; // overshoot on subtracted solids, so no cut face is coplanar

r_out = cyl_d / 2;          // outside radius
chan_hw = chan_w / 2;       // half the channel width
chan_fx = r_out - chan_d;   // x of the channel floor, measured from the axis

assert(edge_r <= chan_hw, "edge_r cannot exceed half the channel width");
assert(edge_r <= chan_d / 2, "edge_r cannot exceed half the channel depth");
assert(2 * edge_r < cyl_len, "the two end round-overs would meet");

// Center of the mouth fillet: distance r_out - edge_r from the axis so it sits
// tangent inside the outside diameter, and chan_hw + edge_r off the center line
// so it sits tangent to the channel wall.
mouth_cp = [sqrt((r_out - edge_r) ^ 2 - (chan_hw + edge_r) ^ 2), chan_hw + edge_r];
// Where that fillet meets the outside diameter — on the ray through its center.
mouth_a = atan2(mouth_cp.y, mouth_cp.x);

// Cross-section of the bar, counter-clockwise from the channel floor. Straight
// runs are implied between the arcs: floor, floor fillet, channel wall, mouth
// fillet, the long way round the outside, and the mirror of all of it.
function mount_profile() = deduplicate(
    concat(
        [[chan_fx, -(chan_hw - edge_r)], [chan_fx, chan_hw - edge_r]],
        arc(r = edge_r, cp = [chan_fx + edge_r, chan_hw - edge_r], start = 180, angle = -90),
        arc(r = edge_r, cp = mouth_cp, start = 270, angle = mouth_a + 90),
        arc(r = r_out, cp = [0, 0], start = mouth_a, angle = 360 - 2 * mouth_a),
        arc(r = edge_r, cp = [mouth_cp.x, -mouth_cp.y], start = -mouth_a, angle = mouth_a + 90),
        arc(r = edge_r, cp = [chan_fx + edge_r, -(chan_hw - edge_r)], start = -90, angle = -90)
    ),
    closed = true
);

module camera_window_mount() {
    offset_sweep(
        mount_profile(),
        height = cyl_len,
        bottom = os_circle(r = edge_r),
        top = os_circle(r = edge_r)
    );
}

camera_window_mount();
