// awl-sheath.scad
//
// A sheath for Ziad's awl: a 17 mm tube with a rounded closed end, bored
// to the blade's own profile so the point sits centred in a pocket that
// follows its taper and never touches the bottom.
//
// The blade, measured by Ziad 2026-10-11, from the point back:
//   0 → 2.5 mm     cone from the point out to 1.75 mm
//   2.5 → 30 mm    taper from 1.75 mm out to the full 5.89 mm
//   30 → 151 mm    parallel shank, 5.89 mm
// ⚠️ ASSUMED: 151 mm is exposed blade, handle face to point, and the
// sheath runs the whole of it so its mouth meets the handle.
//
// Retention is three crush ribs just inside the mouth; the rest of the
// bore runs free so the blade slides in without dragging the point.
// ⚠️ The bore allowance is from the slicing reference, where a PETG bore
// came out 0.55–0.65 under on diameter. Print the coupon before the
// full sheath: it is the mouth and the tip pocket, the two places that
// fit.
//
// Axes: print orientation. Z=0 is the mouth, flat on the bed; the
// rounded end is at the top. The point of a fully inserted blade sits
// at Z = blade_l.
//
// COUPON-COMPONENTS: mouth=coupon-mouth tip=coupon-tip
// COUPON-PLATE: coupon

/* [View] */
show = "sheath"; // [sheath, section, coupon, coupon-mouth, coupon-tip]

/* [Blade, measured] */
blade_l = 151; // mm, handle face to point
blade_d = 5.89; // mm, shank diameter
taper_l = 30; // mm, point to where the taper starts
neck_d = 1.75; // mm, diameter where the final cone starts
neck_l = 2.5; // mm, point to the neck

/* [Sheath] */
outer_d = 17; // mm
bore_shrink = 0.6; // mm on diameter, what a printed bore loses (slicing reference)
bore_fit = 0.4; // mm on diameter, running clearance after the shrink
tip_gap = 1.5; // mm, point to the bottom of its pocket
end_wall = 3.0; // mm, solid beyond the pocket, along the axis
mouth_chamfer = 0.8; // mm, 45° lead-in; also beats elephant's foot
outer_chamfer = 0.5; // mm, 45° on the outer bed edge

/* [Crush ribs] */
rib_count = 3;
rib_w = 1.2; // mm, across the rib
rib_interference = 0.2; // mm per side into the blade
rib_start = 4; // mm above the mouth
rib_l = 20; // mm, along the bore

/* [Coupon] */
coupon_mouth_h = rib_start + rib_l + 4; // mm
coupon_tip_h = taper_l + 12; // mm of blade inside the tip coupon

/* [Colors] */
sheath_color = "#d12b8a";
tip_coupon_color = "#3a8fd1";

/* [Hidden] */
$fn = 96;
eps = 0.01;

bore_extra = bore_shrink + bore_fit; // mm on diameter, added to the blade everywhere
point_z = blade_l; // mouth to point
pocket_z = point_z + tip_gap; // bottom of the point's pocket
top_z = pocket_z + end_wall; // apex of the dome
cyl_h = top_z - outer_d / 2; // where the dome starts

// The blade's radius at a distance s from the point.
function blade_r(s) =
  s <= 0 ? 0
  : s <= neck_l ? (neck_d / 2) * s / neck_l
  : s <= taper_l ? neck_d / 2 + (blade_d - neck_d) / 2 * (s - neck_l) / (taper_l - neck_l)
  : blade_d / 2;

// Bore profile in (r, z), mouth to pocket bottom. The point's cone keeps
// the same allowance as the rest, then closes on the pocket bottom.
function bore_pts() = [
  [0, -eps],
  [blade_d / 2 + bore_extra / 2 + mouth_chamfer, -eps],
  [blade_d / 2 + bore_extra / 2, mouth_chamfer],
  [blade_r(taper_l) + bore_extra / 2, point_z - taper_l],
  [blade_r(neck_l) + bore_extra / 2, point_z - neck_l],
  [bore_extra / 2, point_z],
  [0, pocket_z],
];

module bore() {
  rotate_extrude() polygon(bore_pts());
}

module ribs() {
  bore_r = blade_d / 2 + bore_extra / 2;
  // Each rib reaches in to blade_r - rib_interference, before shrink; it
  // is a thin wall-bonded feature, so assume it loses the same as the bore.
  inner_r = blade_d / 2 - rib_interference + bore_shrink / 2;
  for (i = [0:rib_count - 1])
    rotate(i * 360 / rib_count)
      translate([inner_r, -rib_w / 2, rib_start])
        cube([bore_r - inner_r + 0.5, rib_w, rib_l]);
}

module body() {
  rotate_extrude()
    polygon(
      concat(
        [
          [0, 0],
          [outer_d / 2 - outer_chamfer, 0],
          [outer_d / 2, outer_chamfer],
          [outer_d / 2, cyl_h],
        ],
        [for (a = [5:5:90]) [outer_d / 2 * cos(a), cyl_h + outer_d / 2 * sin(a)]]
      )
    );
}

module sheath() {
  color(sheath_color)
    difference() {
      body();
      difference() {
        bore();
        ribs();
      }
    }
}

// The first coupon_mouth_h of the sheath: tests the slide and the ribs.
module coupon_mouth() {
  intersection() {
    sheath();
    translate([-outer_d, -outer_d, -eps]) cube([2 * outer_d, 2 * outer_d, coupon_mouth_h + eps]);
  }
}

// The closed end, cut face on the bed as in the full sheath: tests that
// the point seats on the taper with tip_gap to spare.
module coupon_tip() {
  cut_z = point_z - coupon_tip_h;
  color(tip_coupon_color)
    translate([0, 0, -cut_z])
          intersection() {
            difference() {
              body();
              bore();
            }
            translate([-outer_d, -outer_d, cut_z]) cube([2 * outer_d, 2 * outer_d, top_z - cut_z + eps]);
          }
}

if (show == "sheath") sheath();
else if (show == "section") difference() {
    sheath();
    translate([0, -outer_d, -1]) cube([outer_d, 2 * outer_d, top_z + 2]);
  }
else if (show == "coupon-mouth") coupon_mouth();
else if (show == "coupon-tip") coupon_tip();
else if (show == "coupon") {
  coupon_mouth();
  translate([outer_d + 8, 0, 0]) coupon_tip();
}
