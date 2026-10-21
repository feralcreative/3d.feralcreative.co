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
// the far face points out into the opening. It does not bear on anything; it
// is simply the far end.
//
// THE HINGE, measured by Ziad 2026-09-12. The barrel is about 12 mm across and
// stands outside the door face; the stack is 90 mm tall. On top of it sits a
// two-sided hinge-pin door stop 7 mm tall, then a 1 mm rubber grommet and a
// 1 mm pin head. The ring loops those last 2 mm and rests on the door stop, so
// its top 3 mm have nothing but air inside. Below the ring the channel runs
// down beside the door stop and then the barrel.
//
// THE FORM. A truncated wedge standing on end: 100 mm tall, a 15.4 mm flat
// face at the far end tapering to a 3 mm nose ON the pin, and a 15 mm bored
// ring around the pin for the top 5 mm.
//
//   depth        51.333 mm   far face to the pin
//   taper angle  13.77 deg   2 * atan(6.2 / 51.333)
//   overall      58.833 mm   depth + knob_r
//
// WHAT SETS THE GAP. The door binds where the wedge is widest along the door's
// edge — the door's inside corner, about 43 mm from the pin (a 12 mm barrel
// outside the face, a 35 mm door) — and only by however much the wedge is
// wider there than the slot already is with the door closed:
//
//   crack  ~  W * (width at the corner - closed slot) / 43
//
// with W the door's width. The slot has not been measured; it is FITTED. The
// first coupon, an 11 mm face on a point nose, stopped a 30 in door at just
// over 3 in, which puts the slot at about 4.8 mm. On that fit 1 mm more on
// the far face is about 0.6 in more at the latch, and 15.4 predicts 6 in.
// Treat the prediction as a first cut and the 0.6 in/mm as the correction,
// and if it lands far off, measure the slot instead of fitting it again.
//
// THE FIRST TWO GUESSES WERE WRONG THE SAME WAY. An 18 mm face on a 5 mm nose
// jammed on the nose. The fix, "call it 11 mm" on a point nose so that t/r
// was constant along the facets, assumed the closed slot was zero and that
// the door touched the wedge all the way in to the pin. Neither is true: the
// slot is ~5 mm and the door's edge starts ~8 mm out from the pin, so the
// point nose never touched anything, the far corner did all the work, and a
// predicted 6.39 in came out as 3.
//
// THE NOSE IS 3 mm FOR THE RING JOINT, not for the door. In TPU the point
// nose met the ring across 1.8 mm, which is a live hinge. 3 mm at the pin is
// 4.8 mm where the wedge meets the ring's outside, and at 8 mm out — the
// door's face corner — the wedge is 4.9 mm against a slot of 4.8 plus whatever
// the door has opened, so it clears there and binds at the far corner as
// intended. Do not raise it past 4 without measuring the slot; that is the
// 18 mm mistake again.
//
// THE BORE IS THE MOUNT, and it is vertical in use. Modelled ring-up, the bore
// runs down the part's height, so hanging on the door it is a vertical hole
// that drops straight over the pin head from above and rests on the door stop.
//
// THE RING EXISTS ONLY IN THE TOP 5 mm; BELOW IT, THE BORE CARRIES ON. Above
// z = 95 the 15 mm knob is added and bored 12. Below, the knob is simply gone
// — not subtracted, absent — and the 12 mm bore continues down as a cut, so
// the channel wall is the very same cylinder as the inside of the ring and
// runs flush with it. Ziad: "delete the ring but leave the overlap."
//
//   channel floor  45.333 mm from the far face
//   channel mouth  45.741 mm, where the arc meets each facet
//   mouth tips     2.175 mm off the axis, so a 4.35 mm nose at the mouth
//
// The channel is drawn at the barrel's 12 mm. The coupon went on, so it
// clears, but it is not a measured clearance.
//
// EVERY VERTICAL EDGE IS ROUNDED at edge_r = 1.5 mm. With a 3 mm nose the
// opening rounds its two corners into nearly a full round and pulls nothing
// back. The point nose it replaced lost 14 mm to the same opening and was
// SEVERED from the ring, which genus did not catch: a wedge is genus 0 and a
// ring is genus 1, so the sum read 1 either way. Count connected components
// in the mesh after any change to the nose; that is the check that caught it.
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
// print it: the channel is a vertical slot, the bore a vertical hole, and the
// ring's flat underside sits on the plate instead of bridging open air at
// z = 95. Going up from the ring the section only loses material, which is a
// ledge, not an overhang. It is a 100 mm tower on a 58.8 x 15.4 footprint, so
// run a brim.

/* [Output] */

// "coupon" is the bottom coupon_h of the printed orientation — the ring and
// the start of the channel — for checking the fit, the bore, and the door
// angle without printing 100 mm. Build it with --name cat-gap-wedge-coupon.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

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
// Distance from the far face to the ring's axis, which is the pin (mm).
// 51.3329 is the original 31.3329 plus the 20 Ziad asked for on 2026-09-11.
wedge_depth = 51.3329;
// Thickness of the far face, the end away from the hinge (mm). THIS is the
// lever for the door angle: about 0.6 in at the latch per mm, see WHAT SETS
// THE GAP. 11 gave 3 in; 15.4 is the 6 in prediction.
back_thick = 15.4;
// Thickness of the nose, on the pin (mm). Set for the ring joint, bounded by
// the closed slot — see THE NOSE IS 3 mm. 0 makes it a point.
front_thick = 3.0;
// Radius on every vertical edge (mm). Rounds convex and concave corners alike.
// 0 leaves them all sharp.
edge_r = 1.5;

/* [Door — measured and fitted] */

// Width of the door (in). Only used for the predicted crack.
door_width_in = 30;
// Distance from the pin to the door's inside corner, where it binds (mm).
// 12 mm barrel outside the face plus a 1-3/8 in door. Estimated, not measured.
door_corner = 43.0;
// Gap between the door's hinge edge and the jamb with the door closed (mm).
// FITTED from the 3 in coupon result, not measured.
slot_closed = 4.8;

/* [Knob] */

// Diameter of the cylinder running down the front edge (mm).
knob_d = 15.0;
// Position of the knob's axis, measured forward from the nose (mm). 0 centres
// it on the nose.
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
taper_angle = 2 * atan((half_back - half_front) / wedge_depth);
// Half-width of the wedge at s mm from the pin, towards the far face.
function half_width(s) = half_front + (half_back - half_front) * s / wedge_depth;
// Where the bore's arc meets each facet, as a distance from the pin: solve
// s^2 + half_width(s)^2 = bore_r^2 for s.
slope = (half_back - half_front) / wedge_depth;
mouth_s = (-2 * half_front * slope
           + sqrt(pow(2 * half_front * slope, 2)
                  - 4 * (1 + slope * slope) * (half_front * half_front - bore_r * bore_r)))
          / (2 * (1 + slope * slope));
// The door stops where the wedge outgrows the slot by the most per mm of
// reach. That is the far corner unless the nose is fatter than the slot.
stop_rad = max([for (s = [8 : 1 : door_corner]) (2 * half_width(s) - slot_closed) / s]);

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
    [0, -half_back],                // far face, right side
    [wedge_depth, -half_front],     // the nose, on the pin
    [wedge_depth, half_front],
    [0, half_back],                 // far face, left side
  ]);
}

module wedge_rounded() {
  round_all(edge_r) wedge_trapezoid();
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



echo(str("depth, far face to the pin = ", wedge_depth, " mm"));
echo(str("overall depth = ", wedge_depth + knob_offset + knob_r, " mm"));
echo(str("taper angle = ", taper_angle, " deg"));
echo(str("width at the door's corner (", door_corner, " mm) = ", 2 * half_width(door_corner), " mm"));
echo(str("predicted crack on a ", door_width_in, " in door = ", door_width_in * stop_rad, " in"));
echo(str("  ... and per extra mm on the far face = ", door_width_in * (door_corner / wedge_depth) / door_corner, " in"));
echo(str("neck where the wedge meets the ring's outside = ", 2 * half_width(knob_r), " mm"));
echo(str("channel floor = ", knob_x - bore_r, " mm from the far face"));
echo(str("channel mouth = ", knob_x - mouth_s, " mm from the far face, tips ", half_width(mouth_s), " mm off axis"));
echo(str("wall around the bore = ", knob_r - bore_r, " mm"));
echo(str("ring from z = ", wedge_height - ring_h, " to ", wedge_height, " mm"));

// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_ed66b086102d() {
if (show == "coupon") {
  intersection() {
    cat_gap_wedge_oriented();
    translate([-80, -80, 0]) cube([300, 160, coupon_h]);
  }
} else {
  cat_gap_wedge_oriented();
}
}

module feral_assembly_view_ed66b086102d(explode=false) {
feral_default_output_ed66b086102d();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_ed66b086102d();
else feral_assembly_view_ed66b086102d(view == "exploded");
