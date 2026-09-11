// Cat gap wedge — holds the laundry/litter room door open a cat's width.
//
// HOW IT INSTALLS. The ring drops over the TOP HINGE PIN, on the inside of the
// jamb, and the wedge hangs down from it into the gap between the door's hinge
// stile and the jamb. The door closes onto the taper until it pinches, and
// cannot go past — which leaves a 6-7 inch gap at the latch edge for the cats.
// Ziad, 2026-09-11.
//
// SO THE RING END IS THE BACK, as you install it: the ring is at the hinge and
// the 18 mm face points out into the opening. Earlier revisions of this header
// had that backwards and described the 18 mm face as bearing on the jamb. It
// does not bear on anything; it is the far end.
//
// THE BORE IS THE MOUNT, and it is vertical in use. Modelled ring-up, the bore
// runs down the part's height, so hanging on the door it is a vertical hole
// that drops straight over the pin from above. The 12 mm bore has to clear the
// pin's head; the ring then rests on the top of the hinge barrel, which on a
// typical residential hinge is wider than 12 mm and so is the thing that
// actually carries the weight. ⚠️ Neither the pin head nor the barrel has been
// measured — if the head is over 12 mm the part will not go on at all.
//
// WHAT SETS THE GAP is leverage, not the wedge's thickness on its own. The
// door stops at roughly t/r radians, where t is the wedge's thickness where it
// pinches and r is that point's distance from the pin; the latch-edge gap is
// that angle times the door's width. Being a wedge, it self-seats — the door
// closes until the local thickness matches the local gap — so the achieved
// number depends on the jamb as much as on this part. At the 18 mm face,
// r = 51.333, which is about 20 degrees and roughly 11 inches on a 32 inch
// door. That is MORE than the 6-7 asked for, so expect it to seat short of
// the 18 mm face rather than on it. Print the coupon and try it.
//
// THE FORM. A trapezoidal prism standing on end: 100 mm tall, an 18 mm flat
// face at one end, two facets running from it to a 5 mm face at the other, and
// a 15 mm cylinder on that 5 mm face. The cylinder is kept for only the top
// 5 mm, as a bored ring; everywhere below it the same cylinder is subtracted
// instead, which leaves a concave channel down the nose. The ring end hangs at
// the hinge; the 18 mm face is the far end, out in the opening.
//
//   depth        51.333 mm   18 mm face to the 5 mm face
//   facet        51.743 mm   each, derived from the depth
//   taper angle  14.433 deg  2 * asin(6.5 / 51.743)
//   overall      58.833 mm   depth + knob_r
//
// IT IS DRIVEN BY THE DEPTH, NOT THE FACETS. The facets were the given number
// to begin with — 32 mm, which put the 18 mm face 31.333 mm from the ring.
// Ziad, 2026-09-11: the 18 mm face wants to be 20 mm further out, at the same
// 18 mm width. That stretches the part rather than reshaping it, and it is the
// depth that is now the input: wedge_depth = 51.333, facet_len falls out of it
// at 51.743, and the taper closes from 23.440 degrees to 14.433. A more acute
// wedge reaches further into a closing gap before it jams, which is the whole
// point of moving it.
//
// THE KNOB IS ADDED, NOT BLENDED. It is centred on the 5 mm face and simply
// unioned on, which keeps the wedge angle exactly what it was asked to be. It
// is 15 mm across a 5 mm face, so it stands 5 mm proud on each side and
// crosses the facets rather than meeting them: there is a shallow notch where
// the circle cuts each facet, 6.710 mm back from the 5 mm face. The
// alternative is a tangent knob, and a tangent circle between two converging
// lines is an inscribed circle — holding both the taper and the facets would
// force the 18 mm face wider. The angle was the thing worth keeping.
//
// THE RING AND THE CHANNEL ARE THE SAME CYLINDER, used twice. Above z = 95 it
// is added and bored; below, the same 15 mm circle on the same axis is cut
// away, which takes the nose of the trapezoid with it:
//
//   channel floor   43.833 mm from the 18 mm face — 7.5 mm deep on the axis
//   channel mouth   44.623 mm, where the arc meets each facet
//   mouth tips      3.350 mm off the axis, a 70.689 deg included angle
//
// So below the ring the wedge is 44.623 mm deep at two blunt tips rather than
// 58.833 at a knob, and the 5 mm face is gone entirely — the channel swallowed
// it. The tips are not feather edges; 70.689 degrees prints, and edge_r takes
// them back another 1.093 mm on top of that.
//
// THE RING'S UNDERSIDE IS A FLAT ANNULAR CEILING at z = 95 over open air.
// Ring-down, which is how it prints, that face is on the plate instead.
//
// THE BORE IS CONCENTRIC WITH THE KNOB, so the wall around it is a constant
// 1.5 mm — 12 in 15 — the whole way round, for the 5 mm it exists. It never
// breaks out: everything within r = 7.5 of the axis is knob, and behind that
// the trapezoid piles more material on, so only the front arc is 1.5 mm thick.
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
// The taper is what makes it work. The gap it hangs in closes as the door
// swings, so a matching taper seats on two faces and jams rather than sitting
// on a point and squirting out. The 18 mm face is the far limit, not the
// working thickness — see WHAT SETS THE GAP above.
//
// ORIENTATION. Modelled ring-up, which is how it hangs — the ring is at the
// top, on the pin. Every number above is quoted from the 18 mm face, with z
// running up the door's edge. It is BUILT ring-down — flip = true rotates it 180 about X
// before output — and that is the orientation to print.
//
// Ring-down there is not a single overhang in the part. The channel is a
// vertical groove, the bore is a vertical hole, and the ring's flat underside
// is on the plate instead of bridging 15 mm of open air at z = 95. Going up
// from the top of the ring the section only ever loses material, which is a
// ledge, not an overhang.
//
// The cost is a 100 mm tower on a 58.8 x 18 footprint. The stretch helps here:
// it is 20 mm longer in the one direction that was short, so it is less tippy
// than it was. Run a brim anyway.
//
// EVERY VERTICAL EDGE IS ROUNDED at edge_r = 1.5 mm, convex and concave alike:
// the two corners of the 18 mm face, the two mouth tips, and the two notches
// where the ring crosses the facets. A 70.689 degree tip pulls back by
// rr/sin(35.34) - rr when it is rounded, so the mouth tips land about 1.093 mm
// shy of the 44.623 quoted above. The flats and the arcs do not move.

/* [Output] */

// "coupon" is the bottom coupon_h of the printed orientation — the ring and
// the start of the channel — for checking the fit and the bore without
// printing 100 mm. Build it with --name cat-gap-wedge-coupon.
show = "part";   // [part, coupon]
// Print the part ring-down. The ring is modelled at the top because that is
// where it belongs on the door; it is printed at the bottom because that is
// the only way the ring's underside is not a bridge.
flip = true;
// Height of the coupon, measured from the bottom of the printed orientation.
coupon_h = 20.0;

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Wedge] */

// Height standing on end (mm). The dimension along the door's edge.
wedge_height = 100.0;
// Distance from the 18 mm face to the ring's axis, which is the pin (mm).
// THIS is the input —
// facet_len is derived from it. 51.3329 is the original 31.3329 plus the 20
// Ziad asked for on 2026-09-11.
wedge_depth = 51.3329;
// Thickness of the far face, the end away from the hinge (mm). The stretch
// does not change it.
back_thick = 18.0;
// Thickness of the face the knob sits on (mm). 0 brings the facets to a point.
front_thick = 5.0;
// Radius on every vertical edge (mm). Rounds convex and concave corners alike.
// 0 leaves them all sharp.
edge_r = 1.5;

/* [Knob] */

// Diameter of the cylinder running down the front edge (mm).
knob_d = 15.0;
// Position of the knob's axis, measured forward from the 5 mm face (mm).
// 0 centres it on the face.
knob_offset = 0.0;
// Diameter of the bore down the knob's axis (mm). 0 leaves it solid.
bore_d = 12.0;
// Added to bore_d to cover this machine's bore shrinkage (mm). Left at 0 the
// hole is drawn at its nominal size.
bore_comp = 0.0;
// Height of cylinder kept at the very top as a ring (mm). The rest of it is
// subtracted from the wedge and becomes the channel.
ring_h = 5.0;

/* [Derived — do not edit] */

half_back = back_thick / 2;
half_front = front_thick / 2;
knob_r = knob_d / 2;
bore_r = (bore_d + bore_comp) / 2;
knob_x = wedge_depth + knob_offset;
facet_len = sqrt(wedge_depth * wedge_depth + pow(half_back - half_front, 2));
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
    [0, -half_back],                // 18 mm face, right side
    [wedge_depth, -half_front],     // 5 mm face, right side
    [wedge_depth, half_front],      // 5 mm face, left side
    [0, half_back],                 // 18 mm face, left side
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

// Printed orientation. The flip is a rotate, not a mirror — the part is
// symmetric about y = 0, so nothing is handed either way.
module cat_gap_wedge_oriented() {
  if (flip) translate([0, 0, wedge_height]) rotate([180, 0, 0]) cat_gap_wedge();
  else cat_gap_wedge();
}

if (show == "coupon") {
  intersection() {
    cat_gap_wedge_oriented();
    translate([-80, -80, 0]) cube([300, 160, coupon_h]);
  }
} else {
  cat_gap_wedge_oriented();
}

echo(str("depth, 18 mm face to 5 mm face = ", wedge_depth, " mm"));
echo(str("facet length = ", facet_len, " mm"));
echo(str("overall depth = ", wedge_depth + knob_offset + knob_r, " mm"));
echo(str("taper angle = ", taper_angle, " deg"));
echo(str("channel floor = ", knob_x - knob_r, " mm from the 18 mm face"));
echo(str("18 mm face sits ", wedge_depth, " mm from the hinge pin"));
echo(str("wall around the bore = ", knob_r - bore_r, " mm"));
echo(str("ring from z = ", wedge_height - ring_h, " to ", wedge_height, " mm"));
