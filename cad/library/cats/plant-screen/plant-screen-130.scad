// Plant screen, Ø130 — the plant-screen.scad lattice at a smaller diameter,
// for a smaller pot. Ziad asked for a second version at 130 mm (2026-09-20).
//
// Everything is plant-screen.scad: the struts, the forks under the rim, the
// spigot-and-seat joint, the coupon, the same 215 height. Only outer_d
// changes, and the lattice re-derives itself from it — N drops to 10 struts
// per hand at the same 36 mm opening, so a layer is 20 islands instead of 34
// and the print is correspondingly shorter. The joint is the same section at
// a smaller radius, so a Ø130 unit stacks on a Ø130 unit and on nothing else.
//
// include splices the base file in, top-level geometry and all, and the
// assignment below wins over the base's outer_d because the last assignment
// in a scope wins file-wide. Keep it a single override: anything else that
// differs belongs in the base file as a parameter.
//
// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

include <plant-screen.scad>

/* [Envelope] */

// Outside diameter (mm).
outer_d = 130.00;
