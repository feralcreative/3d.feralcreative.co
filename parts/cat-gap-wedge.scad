// Cat gap wedge — holds the laundry/litter room door open a cat's width.
//
// This file is the WEDGE BODY ONLY. It hangs on the hinge side of the door so
// the door cannot close past it, leaving a permanent gap at the latch edge.
// The hook that carries it off the hinge is a separate, later job — model it
// against the numbers echoed at the bottom of this file rather than guessing.
//
// THE FORM. A trapezoidal prism standing on end: 100 mm tall, an 18 mm back
// face, two 32 mm facets running forward from it, and a 5 mm front face where
// they would otherwise have met. A 15 mm cylinder runs the full height of that
// front face as a knob, bored 12 mm down its axis — but only for the top 5 mm.
// Below that the knob's own 15 mm cylinder is subtracted instead, so what runs
// down the front of the wedge is a concave channel and what is left at the top
// is a ring. The back sits against the hinge-side jamb, the ring aims out into
// the swing.
//
//   depth        31.333 mm   sqrt(32^2 - 6.5^2), to the front face
//   taper angle  23.440 deg  2 * asin(6.5 / 32)
//   overall      38.833 mm   depth + knob_r
//
// THE KNOB IS ADDED, NOT BLENDED. It is centred on the front face and simply
// unioned on, which is what keeps the wedge angle exactly what it was. It is
// 15 mm across a 5 mm face, so it stands 5 mm proud on each side and crosses
// the facets rather than meeting them: there is a shallow notch where the
// circle cuts each facet, 6.444 mm back from the front face. That notch is
// deliberate — the alternative is a tangent knob, and a tangent circle between
// two converging lines is an inscribed circle, so holding both the taper and
// the 32 mm facets would have forced the back face out from 18 to 27.687. The
// angle was the thing worth keeping.
//
// THE RING AND THE CHANNEL ARE THE SAME CYLINDER, used twice. Above
// z = 95 it is added and bored; below, the same 15 mm circle on the same axis
// is cut away, which takes the nose of the trapezoid with it:
//
//   channel floor   23.833 mm from the back face — 7.5 mm deep on the axis
//   channel mouth   24.889 mm, where the arc meets each facet
//   mouth tips      3.837 mm off the axis, a 70.95 deg included angle
//
// So below the ring the wedge is 24.889 mm deep at two blunt tips rather than
// 38.833 at a knob, and the 5 mm front face is gone entirely — the channel
// swallowed it. The tips are not feather edges; 70.95 degrees prints, and
// edge_r takes them back another millimetre on top of that.
//
// THE RING'S UNDERSIDE IS A FLAT ANNULAR CEILING at z = 95 over open air.
// Standing on end that is a bridge; on a facet, which is how this prints, it
// is a side wall and the channel is a groove running along the plate. One
// more reason not to print it upright.
//
// THE BORE IS CONCENTRIC WITH THE KNOB, so the wall around it is a constant
// 1.5 mm — 12 in 15 — the whole way round, for the 5 mm it exists. It never
// breaks out: the bore's
// rearmost point lands 6.0 mm inside the wedge at x = 25.333, and everything
// within r = 7.5 of the axis is knob. Behind that the trapezoid piles more
// material on, so only the front arc is actually 1.5 mm thick.
//
// ⚠️ 1.5 mm IS OFF THE WALL LADDER. On a 0.4 nozzle it is 3.57 passes of a
// 0.42 line, which prints as gaps or over-extrusion; the neighbouring good
// numbers are 1.26 (3 passes) and 1.68 (4). Holding the 12 mm bore, a
// knob_d of 15.36 gives 1.68. Holding the 15 mm knob, a bore_d of 11.64 does.
// Both of those are Ziad's call, so the file builds 12-in-15 as asked.
//
// The bore is drawn at its nominal diameter. This machine loses 0.55-0.65 mm
// on a small bore by measurement, so if something has to pass through this
// hole rather than it just being a hole, put that back with bore_comp.
//
// The taper is what makes it work. A hinge gap is a wedge itself — it closes
// as the door swings — so a matching taper seats on two faces and jams rather
// than sitting on a point and squirting out. The 18 mm back is the stop: that
// is the gap it will hold, less whatever the door's own hinge-side clearance
// already gives away.
//
// ORIENTATION. Modelled standing on end: profile in XY, extruded up Z. DO NOT
// PRINT IT THIS WAY — on end it is a 100 mm tower on a 39 x 18 footprint and
// the knob is a 100 mm column of unsupported curve. Lay it on a facet instead:
// a 100 x 32 face on the plate, layers running across the wedge, the knob a
// bead along one edge. The slicer does that; nothing here needs to change.
//
// EVERY VERTICAL EDGE IS ROUNDED at edge_r = 1.5 mm, convex and concave alike:
// the two back corners, the two mouth tips, and the two notches where the ring
// crosses the facets. A 70.95 degree tip pulls back by rr/sin(35.48) - rr when
// it is rounded, so the mouth tips land about 1.084 mm shy of the 24.889 mm
// quoted above. The flats and the arcs themselves do not move.

/* [Output] */

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Wedge] */

// Height standing on end (mm). The dimension along the door's edge.
wedge_height = 100.0;
// Length of each of the two facets, back face to front face (mm).
facet_len = 32.0;
// Thickness of the back face (mm). This is the gap the door is held to.
back_thick = 18.0;
// Thickness of the front face (mm). 0 brings the facets to a point.
front_thick = 5.0;
// Radius on every vertical edge (mm). Rounds convex and concave corners alike
// — the back corners, the two mouth tips, and the notches where the ring meets
// the facets. 0 leaves them all sharp.
edge_r = 1.5;

/* [Knob] */

// Diameter of the cylinder running down the front edge (mm).
knob_d = 15.0;
// Position of the knob's axis, measured forward from the front face (mm).
// 0 centres it on the face. Positive pushes it out and leaves less of it
// buried in the wedge.
knob_offset = 0.0;
// Diameter of the bore down the knob's axis (mm). 0 leaves it solid.
bore_d = 12.0;
// Added to bore_d to cover this machine's bore shrinkage (mm). Left at 0 the
// hole is drawn at its nominal size. See the note in the header before
// putting anything through it that has to fit.
bore_comp = 0.0;
// Height of cylinder kept at the very top as a ring (mm). The rest of it is
// subtracted from the wedge and becomes the channel.
ring_h = 5.0;

/* [Derived — do not edit] */

half_back = back_thick / 2;
half_front = front_thick / 2;
knob_r = knob_d / 2;
bore_r = (bore_d + bore_comp) / 2;
wedge_depth = sqrt(facet_len * facet_len - pow(half_back - half_front, 2));
knob_x = wedge_depth + knob_offset;
taper_angle = 2 * asin((half_back - half_front) / facet_len);

// Round every corner of a 2D profile by rr without moving the flats: open by
// rr (erode, dilate — rounds the convex corners), then close by rr (dilate,
// erode — rounds the concave ones). The two dilations merge into one, which is
// why the middle offset is 2 * rr. Arcs already larger than rr come through
// untouched, so the channel and the bore are unaffected.
module round_all(rr) {
  if (rr > 0) offset(r = -rr) offset(r = 2 * rr) offset(r = -rr) children();
  else children();
}

module wedge_trapezoid() {
  polygon([
    [0, -half_back],                // back face, right side
    [wedge_depth, -half_front],     // front face, right side
    [wedge_depth, half_front],      // front face, left side
    [0, half_back],                 // back face, left side
  ]);
}

// Below the ring: the wedge with the channel scooped out of its nose.
module lower_profile() {
  round_all(edge_r)
    difference() {
      wedge_trapezoid();
      translate([knob_x, 0]) circle(r = knob_r);
    }
}

// The ring course. Rounded BEFORE the bore is cut, because the ring wall is
// only 1.5 mm and an erode of edge_r would delete it outright.
module upper_profile() {
  difference() {
    round_all(edge_r)
      union() {
        wedge_trapezoid();
        translate([knob_x, 0]) circle(r = knob_r);
      }
    translate([knob_x, 0]) circle(r = bore_r);
  }
}

// Two constant sections stacked, rather than one extrude cut by a cylinder.
// Each course is a plain 2D profile, so the rounding is a 2D offset and the
// knob's r = 7.5 surface is never both added and subtracted over the same z.
module cat_gap_wedge() {
  linear_extrude(height = wedge_height - ring_h, convexity = 6)
    lower_profile();
  translate([0, 0, wedge_height - ring_h])
    linear_extrude(height = ring_h, convexity = 6)
      upper_profile();
}

cat_gap_wedge();

echo(str("depth to the front face = ", wedge_depth, " mm"));
echo(str("overall depth = ", wedge_depth + knob_offset + knob_r, " mm"));
echo(str("taper angle = ", taper_angle, " deg"));
echo(str("knob stands proud of the front face by = ", knob_offset + knob_r, " mm"));
echo(str("knob stands proud of each facet by = ", knob_r - half_front, " mm at its widest"));
echo(str("wall around the bore = ", knob_r - bore_r, " mm"));
echo(str("ring from z = ", wedge_height - ring_h, " to ", wedge_height, " mm"));
echo(str("channel floor = ", knob_x - knob_r, " mm from the back face"));
