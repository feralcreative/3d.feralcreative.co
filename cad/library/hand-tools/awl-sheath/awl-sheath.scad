// Note 1.

// COUPON-COMPONENTS: mouth=coupon-mouth
// COUPON-PLATE: coupon

/* [View] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

show = "sheath"; // [sheath, section, coupon, coupon-mouth]

/* [Blade, measured] */
blade_l = 151; // Note 3.
blade_d = 5.89; // Note 4.
taper_l = 30; // Note 5.
neck_d = 1.75; // Note 6.
neck_l = 2.5; // Note 7.

/* [Sheath] */
outer_d = 17; // Note 8.
bore_shrink = 0.6; // Note 9.
bore_fit = 0.4; // Note 10.
tip_gap = 1.5; // Note 11.
end_wall = 3.0; // Note 12.
mouth_chamfer = 0.8; // Note 13.
outer_chamfer = 0.5; // Note 14.

/* [Crush ribs] */
rib_count = 3;
rib_w = 1.2; // Note 15.
rib_interference = 0.45; // Note 16.

rib_start = 4; // Note 17.
rib_l = 20; // Note 18.

/* [Coupon] */
coupon_mouth_h = 10; // Note 19.

/* [Colors] */
sheath_color = "#d12b8a";

/* [Hidden] */
$fn = 96;
eps = 0.01;

bore_extra = bore_shrink + bore_fit; // Note 20.
point_z = blade_l; // Note 21.
pocket_z = point_z + tip_gap; // Note 22.
top_z = pocket_z + end_wall; // Note 23.
cyl_h = top_z - outer_d / 2; // Note 24.

function blade_r(s) =
  s <= 0 ? 0
  : s <= neck_l ? (neck_d / 2) * s / neck_l
  : s <= taper_l ? neck_d / 2 + (blade_d - neck_d) / 2 * (s - neck_l) / (taper_l - neck_l)
  : blade_d / 2;

// Note 25.

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
  // Note 26.

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

// Note 27.
module coupon_mouth() {
  intersection() {
    sheath();
    translate([-outer_d, -outer_d, -eps]) cube([2 * outer_d, 2 * outer_d, coupon_mouth_h + eps]);
  }
}

// Note 28.

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

// Notes

// Note 1. awl-sheath.scad
//
// A sheath for Ziad's awl: a 17 mm tube with a rounded closed end, bored
// to the blade's own profile so the point sits centred in a pocket that
// follows its taper and never touches the bottom.
//
// The blade, measured by Ziad 2026-10-11, from the point back:
// 0 → 2.5 mm     cone from the point out to 1.75 mm
// 2.5 → 30 mm    taper from 1.75 mm out to the full 5.89 mm
// 30 → 151 mm    parallel shank, 5.89 mm
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

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, handle face to point

// Note 4. mm, shank diameter

// Note 5. mm, point to where the taper starts

// Note 6. mm, diameter where the final cone starts

// Note 7. mm, point to the neck

// Note 8. mm

// Note 9. mm on diameter, what a printed bore loses (slicing reference)

// Note 10. mm on diameter, running clearance after the shrink

// Note 11. mm, point to the bottom of its pocket

// Note 12. mm, solid beyond the pocket, along the axis

// Note 13. mm, 45° lead-in; also beats elephant's foot

// Note 14. mm, 45° on the outer bed edge

// Note 15. mm, across the rib

// Note 16. mm per side into the blade, allowing for bore_shrink
// Fit feedback, 2026-10-12: 0.20 was too loose; 0.50 was a little too snug.
// Ease each rib outward by 0.05 mm for the next coupon.

// Note 17. mm above the mouth

// Note 18. mm, along the bore

// Note 19. mm, mouth section only; includes 6 mm of the grip ribs

// Note 20. mm on diameter, added to the blade everywhere

// Note 21. mouth to point

// Note 22. bottom of the point's pocket

// Note 23. apex of the dome

// Note 24. where the dome starts
// The blade's radius at a distance s from the point.

// Note 25. Bore profile in (r, z), mouth to pocket bottom. The point's cone keeps
// the same allowance as the rest, then closes on the pocket bottom.

// Note 26. Shrink compensation is an estimate, not a measured rib allowance.
// At defaults, CAD tips sit at 2.795 mm radius: 0.15 mm inside the shank.
// The next printed coupon must confirm insertion and retention.

// Note 27. The first coupon_mouth_h of the sheath: tests the slide and the ribs.

// Note 28. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
