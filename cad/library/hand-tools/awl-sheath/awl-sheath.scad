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
// full sheath: the 10 mm mouth coupon tests insertion and grip.
//
// Axes: print orientation. Z=0 is the mouth, flat on the bed; the
// rounded end is at the top. The point of a fully inserted blade sits
// at Z = blade_l.
//
// COUPON-COMPONENTS: mouth=coupon-mouth
// COUPON-PLATE: coupon

/* [View] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "sheath"; // [sheath, section, coupon, coupon-mouth]

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
rib_interference = 0.45; // mm per side into the blade, allowing for bore_shrink
// Fit feedback, 2026-10-12: 0.20 was too loose; 0.50 was a little too snug.
// Ease each rib outward by 0.05 mm for the next coupon.
rib_start = 4; // mm above the mouth
rib_l = 20; // mm, along the bore

/* [Coupon] */
coupon_mouth_h = 10; // mm, mouth section only; includes 6 mm of the grip ribs

/* [Colors] */
sheath_color = "#d12b8a";

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
  // Shrink compensation is an estimate, not a measured rib allowance.
  // At defaults, CAD tips sit at 2.795 mm radius: 0.15 mm inside the shank.
  // The next printed coupon must confirm insertion and retention.
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



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_dc0f5878f138() {
if (show == "sheath") sheath();
else if (show == "section") difference() {
    sheath();
    translate([0, -outer_d, -1]) cube([outer_d, 2 * outer_d, top_z + 2]);
  }
else if (show == "coupon-mouth") coupon_mouth();
else if (show == "coupon") coupon_mouth();
}

module feral_assembly_view_dc0f5878f138(explode=false) {
feral_default_output_dc0f5878f138();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_dc0f5878f138();
else feral_assembly_view_dc0f5878f138(view == "exploded");
