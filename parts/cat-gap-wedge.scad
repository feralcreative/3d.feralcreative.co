// Cat gap wedge — holds the laundry/litter room door open a cat's width.
//
// This file is the WEDGE BODY ONLY. It hangs on the hinge side of the door so
// the door cannot close past it, leaving a permanent gap at the latch edge.
// The hook that carries it off the hinge is a separate, later job — model it
// against the numbers echoed at the bottom of this file rather than guessing.
//
// THE FORM. A triangular prism standing on end: 100 mm tall, an 18 mm back
// face, and two 32 mm facets running forward from that back face to a point.
// The back sits against the hinge-side jamb, the point aims out into the
// swing. Those three numbers are given, not derived; everything else here
// falls out of them.
//
//   depth       30.708 mm   sqrt(32^2 - 9^2)
//   apex angle  32.671 deg  2 * asin(9 / 32)
//
// The taper is what makes it work. A hinge gap is a wedge itself — it closes
// as the door swings — so a matching taper seats on two faces and jams rather
// than sitting on a point and squirting out. The 18 mm back is the stop: that
// is the gap it will hold, less whatever the door's own hinge-side clearance
// already gives away.
//
// ORIENTATION. Modelled as the user described it — profile in XY, extruded up
// Z, standing on end. DO NOT PRINT IT THIS WAY. On end it is a 100 mm tower on
// a 31 x 18 footprint with a 100 mm knife edge up one side, and every layer is
// a thin triangle. Lay it on a 32 mm facet instead: a 100 x 32 face on the
// plate, ~26 mm tall, layers running across the wedge so the taper is in the
// plane of the layers and not a stack of shrinking outlines. The slicer does
// that; nothing here needs to change.
//
// tip_r rounds all three corners of the profile without moving the flats
// (erode, then dilate). Left at 0 the point is geometrically sharp, which the
// slicer truncates to about a nozzle width anyway. Give it 1-2 mm if you want
// the tip to survive being kicked.

/* [Output] */

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Wedge] */

// Height standing on end (mm). The dimension along the door's edge.
wedge_height = 100.0;
// Length of each of the two facets, back face to point (mm).
facet_len = 32.0;
// Thickness of the back face (mm). This is the gap the door is held to.
back_thick = 18.0;
// Corner radius on the profile (mm). 0 leaves a sharp point.
tip_r = 0.0;

/* [Derived — do not edit] */

half_back = back_thick / 2;
wedge_depth = sqrt(facet_len * facet_len - half_back * half_back);
apex_angle = 2 * asin(half_back / facet_len);

module cat_gap_wedge() {
  linear_extrude(height = wedge_height, convexity = 4)
    offset(r = tip_r)
      offset(r = -tip_r)
        polygon([
          [0, -half_back],      // back face, right side
          [wedge_depth, 0],     // the point
          [0, half_back],       // back face, left side
        ]);
}

cat_gap_wedge();

echo(str("depth = ", wedge_depth, " mm"));
echo(str("apex angle = ", apex_angle, " deg"));
echo(str("facet angle off the back face = ", 90 - apex_angle / 2, " deg"));
