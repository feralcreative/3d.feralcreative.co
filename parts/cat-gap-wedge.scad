// Cat gap wedge — holds the laundry/litter room door open a cat's width.
//
// This file is the WEDGE BODY ONLY. It hangs on the hinge side of the door so
// the door cannot close past it, leaving a permanent gap at the latch edge.
// The hook that carries it off the hinge is a separate, later job — model it
// against the numbers echoed at the bottom of this file rather than guessing.
//
// THE FORM. A trapezoidal prism standing on end: 100 mm tall, an 18 mm back
// face, two 32 mm facets running forward from it, and a 5 mm front face where
// they would otherwise have met. The back sits against the hinge-side jamb,
// the front aims out into the swing. Those four numbers are given, not
// derived; everything else here falls out of them.
//
//   depth        31.333 mm   sqrt(32^2 - 6.5^2)
//   taper angle  23.440 deg  2 * asin(6.5 / 32)
//
// THE FRONT FACE IS A TRUNCATION, NOT A SHORTENING. The facets stay 32 mm and
// the back stays 18, so blunting the point pushed the depth OUT from 30.708 to
// 31.333 and closed the taper from 32.671 degrees to 23.440. If what you want
// instead is the original triangle with its nose cut off, that is a shallower
// part — 22.178 mm deep on 23.111 mm facets — so set facet_len to 23.111.
//
// The taper is what makes it work. A hinge gap is a wedge itself — it closes
// as the door swings — so a matching taper seats on two faces and jams rather
// than sitting on a point and squirting out. The 18 mm back is the stop: that
// is the gap it will hold, less whatever the door's own hinge-side clearance
// already gives away. The 5 mm front is what the door's edge actually lands
// on, so it is also the part that stops the wedge burying itself.
//
// ORIENTATION. Modelled as the user described it — profile in XY, extruded up
// Z, standing on end. DO NOT PRINT IT THIS WAY. On end it is a 100 mm tower on
// a 31 x 18 footprint and every layer is a thin trapezoid. Lay it on a 32 mm
// facet instead: a 100 x 32 face on the plate, ~26 mm tall, layers running
// across the wedge so the taper is in the plane of the layers and not a stack
// of shrinking outlines. The slicer does that; nothing here needs to change.
//
// tip_r rounds all four corners of the profile without moving the flats
// (erode, then dilate). Give it 1-2 mm if you want the front edges softened
// where the door bears on them.

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
// Corner radius on the profile (mm). 0 leaves the corners sharp.
tip_r = 0.0;

/* [Derived — do not edit] */

half_back = back_thick / 2;
half_front = front_thick / 2;
wedge_depth = sqrt(facet_len * facet_len - pow(half_back - half_front, 2));
taper_angle = 2 * asin((half_back - half_front) / facet_len);

module cat_gap_wedge() {
  linear_extrude(height = wedge_height, convexity = 4)
    offset(r = tip_r)
      offset(r = -tip_r)
        polygon([
          [0, -half_back],                // back face, right side
          [wedge_depth, -half_front],     // front face, right side
          [wedge_depth, half_front],      // front face, left side
          [0, half_back],                 // back face, left side
        ]);
}

cat_gap_wedge();

echo(str("depth = ", wedge_depth, " mm"));
echo(str("taper angle = ", taper_angle, " deg"));
echo(str("facet angle off the back face = ", 90 - taper_angle / 2, " deg"));
