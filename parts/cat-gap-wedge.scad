// Cat gap wedge — holds the laundry/litter room door open a cat's width.
//
// This file is the WEDGE BODY ONLY. The hook is the ring, and it is part of
// this file; nothing else is needed to hang it.
//
// HOW IT INSTALLS. The ring drops over the TOP HINGE PIN, on the inside of the
// jamb, and the wedge hangs down from it into the gap between the door's hinge
// stile and the jamb. The door closes onto the taper and cannot go past, which
// leaves the latch edge cracked open for the cats. Ziad, 2026-09-11.
//
// SO THE RING END IS THE BACK, as you install it: the ring is at the hinge and
// the 11 mm face points out into the opening. It does not bear on anything; it
// is simply the far end.
//
// THE FORM. A triangular prism standing on end: 100 mm tall, an 11 mm flat
// face at the far end, two facets running from it to a POINT on the pin, and a
// 15 mm bored ring around that point for the top 5 mm.
//
//   depth        51.333 mm   11 mm face to the pin
//   facet        51.627 mm   each, derived from the depth
//   taper angle  12.231 deg  2 * asin(5.5 / 51.627)
//   overall      58.833 mm   depth + knob_r
//
// THE TAPER ANGLE IS THE WHOLE ANSWER. The door stops at roughly t/r radians,
// where t is the wedge's thickness where it pinches and r is that point's
// distance from the pin, and the crack at the latch is that angle times the
// door's width. Because the facets run to a point ON the pin, t/r is the same
// number everywhere along them — it IS the taper — so it does not matter where
// the door happens to catch.
//
//   door 30 in wide, 1-3/8 thick; 6-7 in at the latch wants 11.48-13.40 deg
//   taper 12.231 deg  ->  2 * 30 * sin(6.116 deg)  =  6.39 in
//
// IT WAS 18 mm ON A 5 mm NOSE AND THAT WAS WRONG. With 5 mm of wedge sitting
// on the pivot, t/r blew up near the pin — 7.5 mm at r = 10 is 43 degrees,
// which is 22 inches at the latch — so the door jammed on the inner end and
// the 18 mm face never touched anything. The far face only sets how long the
// part is before it runs out of taper. Ziad: "Call it 11mm and fix it."
//
// ⚠️ This assumes the wedge bears on the door's hinge-stile face at radius r
// from the pin. The real stop also depends on the hinge's pin offset and the
// closed-door clearance, neither of which has been measured.
//
// THE BORE IS THE MOUNT, and it is vertical in use. Modelled ring-up, the bore
// runs down the part's height, so hanging on the door it is a vertical hole
// that drops straight over the pin from above. The ring then rests on the top
// of the hinge barrel, which on a typical residential hinge is wider than
// 12 mm and so is what carries the weight. ⚠️ Neither the pin head nor the
// barrel has been measured — if the head is over 12 mm it will not go on.
//
// THE RING EXISTS ONLY IN THE TOP 5 mm; BELOW IT, THE BORE CARRIES ON. Above
// z = 95 the 15 mm knob is added and bored 12. Below, the knob is simply gone
// — not subtracted, absent — and the 12 mm bore continues down as a cut, so
// the groove wall is the very same cylinder as the inside of the ring and runs
// flush with it. Ziad: "delete the ring but leave the overlap."
//
//   groove floor   45.333 mm from the 11 mm face
//   groove mouth   45.367 mm, where the arc meets each facet
//   mouth tips     0.643 mm off the axis
//
// ⚠️ WITH THE NOSE A POINT, THAT CUT LEAVES A 1.286 mm NOSE. The bore crosses
// the facets 6 mm from the pin, where a 12.231 degree V is only 1.286 mm
// across — three extrusion widths, running the full 95 mm. It thickens fast,
// 3 mm by 7 mm further back, and it is not what the door bears on, but it is
// the thinnest thing in the part. Look at it on the coupon.
//
// EVERY VERTICAL EDGE IS ROUNDED at edge_r = 1.5 mm EXCEPT THE NOSE. An
// opening of 1.5 replaces a 12.231 degree point with a 1.5 round and pulls the
// apex back by edge_r/sin(6.116) = 14.08 mm — which put the nose at x = 38.75
// while the ring starts at 43.83, SEVERING THE TWO. It still built clean, and
// genus stayed 1 because a wedge is genus 0 and a ring is genus 1, so the
// number said nothing. Counting connected components in the mesh is what
// caught it, and that is the check to run after any change to the nose.
//
// So nose_protect holds the rounding off within 17.08 mm of the pin. The
// facets are flats and rounding does not move them, so the protected region
// rejoins the rounded one along the same two lines with nothing to match up.
// What stays sharp is the apex — buried inside the ring in the top course —
// and the two 0.643 mm tips the bore leaves below it.
//
// THE BORE IS DRAWN NOMINAL. This machine loses 0.55-0.65 mm on a small bore
// by measurement, so put that back with bore_comp before trusting the fit on
// a real pin.
//
// ⚠️ THE RING WALL IS 1.5 mm, which is 3.57 passes of a 0.42 line and off the
// wall ladder. 1.26 (3 passes) and 1.68 (4) are the neighbours: knob_d 15.36
// holds the 12 mm bore, bore_d 11.64 holds the 15 mm knob. Ziad's call, so it
// builds 12-in-15 as asked.
//
// ORIENTATION. Modelled ring-up, which is how it hangs. It is BUILT ring-down
// — flip = true rotates it 180 about X before output — and that is how to
// print it: the groove is a vertical slot, the bore a vertical hole, and the
// ring's flat underside sits on the plate instead of bridging open air at
// z = 95. Going up from the ring the section only loses material, which is a
// ledge, not an overhang. It is a 100 mm tower on a 58.8 x 11 footprint, so
// run a brim.

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
// Distance from the 11 mm face to the ring's axis, which is the pin (mm).
// THIS is the input —
// facet_len is derived from it. 51.3329 is the original 31.3329 plus the 20
// Ziad asked for on 2026-09-11. With front_thick at 0 it does NOT affect the
// door angle — only the taper does — but it does set the 11 mm face's width.
wedge_depth = 51.3329;
// Thickness of the far face, the end away from the hinge (mm). The stretch
// does not change it.
back_thick = 11.0;
// Thickness of the face the knob sits on (mm). 0 brings the facets to a point
// ON the pin, which is what makes t/r constant along them — see WHAT SETS THE
// GAP. Do not raise it without redoing that arithmetic.
front_thick = 0.0;
// Radius on every vertical edge (mm). Rounds convex and concave corners alike.
// 0 leaves them all sharp.
edge_r = 1.5;

/* [Knob] */

// Diameter of the cylinder running down the front edge (mm).
knob_d = 15.0;
// Position of the knob's axis, measured forward from the facets' apex (mm).
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

// How far back from the pin the rounding is held off. An opening of edge_r
// replaces a 2 * half-taper point with an edge_r round and pulls the apex back
// by edge_r/sin(half-taper) — 14.08 mm at 12.231 degrees, which severed the
// nose from the ring outright and left the part as two shells. Everything
// within this radius of the pin keeps its drawn outline.
nose_protect = edge_r / sin(taper_angle / 2) + 2 * edge_r;

module wedge_trapezoid() {
  polygon([
    [0, -half_back],                // 11 mm face, right side
    [wedge_depth, -half_front],     // the apex, on the pin
    [wedge_depth, half_front],      // (a second point only if front_thick > 0)
    [0, half_back],                 // 11 mm face, left side
  ]);
}

// The trapezoid with every corner rounded EXCEPT the nose, which is restored
// inside nose_protect. The facets are flats and the rounding does not move
// them, so the restored region joins the rounded one along the same two lines
// with nothing to match up.
module wedge_rounded() {
  union() {
    round_all(edge_r) wedge_trapezoid();
    intersection() {
      wedge_trapezoid();
      translate([knob_x, 0]) circle(r = nose_protect);
    }
  }
}

// Below the ring: the wedge with the channel scooped out of its nose. The cut
// is the BORE, not the knob — below the top course the ring itself is simply
// not there, and what continues down is the hole through it. So the channel
// wall is the same cylinder as the inside of the ring and runs flush with it,
// rather than standing knob_r - bore_r = 1.5 mm proud of it.
module lower_profile() {
  difference() {
    wedge_rounded();
    translate([knob_x, 0]) circle(r = bore_r);
  }
}

// The ring course. Rounded BEFORE the bore is cut, because the ring wall is
// only 1.5 mm and an erode of edge_r would delete it outright.
module upper_profile() {
  difference() {
    union() {
      wedge_rounded();
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

echo(str("depth, 11 mm face to the pin = ", wedge_depth, " mm"));
echo(str("facet length = ", facet_len, " mm"));
echo(str("overall depth = ", wedge_depth + knob_offset + knob_r, " mm"));
echo(str("taper angle = ", taper_angle, " deg"));
echo(str("channel floor = ", knob_x - bore_r, " mm from the 11 mm face"));
echo(str("predicted crack on a 30 in door = ", 2*30*sin(taper_angle/2), " in"));
echo(str("wall around the bore = ", knob_r - bore_r, " mm"));
echo(str("nose kept sharp within ", nose_protect, " mm of the pin"));
echo(str("nose width where the bore cuts it = ", 2 * bore_r * tan(taper_angle / 2), " mm"));
echo(str("ring from z = ", wedge_height - ring_h, " to ", wedge_height, " mm"));
