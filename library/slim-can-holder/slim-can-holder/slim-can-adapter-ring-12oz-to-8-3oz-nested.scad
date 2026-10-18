// Adapter ring — nests inside slim-can-adapter-ring-12oz-standard-to-slim.scad
// and holds a 250 ml / 8.3 oz slim can. The third piece of the stack:
//
//     can-holder-12oz-standard.scad                      standard 12 oz
//     slim-can-adapter-ring-12oz-standard-to-slim.scad   + slim 12 oz
//     this                                               + 8.3 oz
//
// IT IS slim-can-adapter-ring-12oz-to-8-3oz.scad, with only the host moved.
// That ring drops into the 3 in slim 12 oz holder, whose bore is Ø58.40 with
// six 0.30 ribs — and the standard-to-slim ring's bore is the same Ø58.40
// with the same six 0.30 ribs, on purpose. So the sleeve, both fits, the lip
// thickness and the coupon are that file's, untouched, and this one only
// overrides what the host does differently:
//
//   the lip it sits on is the outer ring's, Ø84.84 with a 1.00 chamfer, so
//   this lip is Ø84.84 too and the stack reads as three lips, one rim;
//
//   the depth is from the outer ring's top to the holder's floor, 96.90,
//   because the can still stands on the holder's floor through both open
//   bottoms — which puts this sleeve's foot level with the outer ring's.
//
// OpenSCAD takes the last assignment of a variable file-wide, including over
// an include, so the values below win over the included file's and every
// expression there that reads them (lip_od, lip_cham, sleeve_h) follows.
// Change a fit in the included file, not here.

include <slim-can-adapter-ring-12oz-to-8-3oz.scad>

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Host — the outer ring this drops into] */

// The outer ring's lip top to the holder's floor (mm): the outer ring's
// under_gap 0.60 + its total_h 96.30 (sleeve 94.00 + lip 2.30).
host_depth = 96.90;
// The outer ring's lip flat runs out to its chamfer at this radius (mm):
// 42.42 - 1.00.
host_rim_flat_r = 41.42;
// The outer ring's lip, which is the holder's outside (mm).
host_od = 84.84;

/* [Colors] */

ring_color = "Coral";
