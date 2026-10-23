// Note 1.
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity_modules.scad>
include <gridfinity-magnets.scad>

xsize = 5;
ysize = 3;
weighted = false;
lid = false;
floor_thickness = 3.0;  // Note 3.

magnet_hole_d = 10.5;   // Note 4.
magnet_cav_h = 2.2;     // Note 5.
magnet_skin = 0.4;      // Note 6.

module base_lid(num_x, num_y) {
  magnet_od = 6.5;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_od/2);
  magnet_thickness = 2.4;
  eps = 0.1;

  translate([0, 0, 7]) frame_plain(xsize, ysize, trim=0.25);
  difference() {
    grid_block(xsize, ysize, 1, magnet_diameter=0, screw_depth=0);
    gridcopy(num_x, num_y) {
      cornercopy(magnet_position) {
        translate([0, 0, 7-magnet_thickness])
        cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=48);
      }
    }
  }
}

module weighted_baseplate(num_x, num_y) {
  magnet_od = 6.5;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_od/2);
  magnet_thickness = 2.4;
  eps = 0.1;

  difference() {
    frame_plain(num_x, num_y, 6.4);

    gridcopy(num_x, num_y) {
      cornercopy(magnet_position) {
        translate([0, 0, -magnet_thickness])
        cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=48);

        translate([0, 0, -6.4]) cylinder(d=3.5, h=6.4, $fn=24);

        // Note 7.
        translate([0, 0, -6.41]) cylinder(d1=8.5, d2=3.5, h=2.5, $fn=24);
      }

      translate([-10.7, -10.7, -6.41]) cube([21.4, 21.4, 4.01]);

      for (a2=[0,90]) rotate([0, 0, a2])
      hull() for (a=[0, 180]) rotate([0, 0, a])
      translate([-14.9519, 0, -6.41]) cylinder(d=8.5, h=2.01, $fn=24);
    }
  }
}

// Note 8.

module frame_plain(num_x, num_y, extra_down=0, trim=0, floor_ht=0,
                   magnet_hole_d=0, magnet_cav_h=2.2, magnet_skin=0.4) {
  ht = extra_down > 0 ? 4.4 : 5;
  corner_radius = 3.75;
  corner_position = gridfinity_pitch/2-corner_radius-trim;
  difference() {
    hull() cornercopy(corner_position, num_x, num_y)
    translate([0, 0, -extra_down-floor_ht]) cylinder(r=corner_radius, h=ht+extra_down+floor_ht, $fn=44);
    translate([0, 0, (trim || floor_ht) ? 0 : -0.01])
    render() gridcopy(num_x, num_y) pad_oversize(margins=1);

    // Note 9.

    if (magnet_hole_d > 0) {
      assert(floor_ht >= magnet_cav_h + 2*magnet_skin,
             "the floor is too thin to bury a magnet in");
      magnet_cavities(num_x, num_y, magnet_hole_d, magnet_cav_h,
                      -magnet_skin - magnet_cav_h);
    }
  }
}
// Note 10.

module feral_default_output_43a1dacb67a5() {
if (lid) {
  base_lid(xsize, ysize);
}
else if (weighted) {
  weighted_baseplate(xsize, ysize);
}
else {
  frame_plain(xsize, ysize, floor_ht=floor_thickness,
              magnet_hole_d=magnet_hole_d, magnet_cav_h=magnet_cav_h,
              magnet_skin=magnet_skin);
}
}

module feral_assembly_view_43a1dacb67a5(explode=false) {
feral_default_output_43a1dacb67a5();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_43a1dacb67a5();
else feral_assembly_view_43a1dacb67a5(view == "exploded");

// Notes

// Note 1. include instead of use, so we get the pitch

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, flat sheet under the frame for adhesive strips; 0 = open
// frame. 2.4 of it is the magnet pocket, 0.6 the cap under it.

// Note 4. mm cavity for a 10 mm disc, four per cell. 0 for none.

// Note 5. mm tall: a 2 mm disc and 0.2 to drop it in

// Note 6. mm over the cavity and under it — the discs go in at
// a print pause and get bridged over

// Note 7. counter-sunk holes in the bottom

// Note 8. floor_ht adds a flat sheet below the frame, so the plate has an unbroken
// underside to stick adhesive strips to. The sockets then stop at z=0 instead
// of breaking through the bottom, which is why the negative is not dropped by
// the usual 0.01 in that case.
// magnet_hole_d/magnet_pocket_h default to 0 so the lid and weighted variants,
// which have magnet provisions of their own, are untouched.

// Note 9. Buried one skin below the socket floor: dropped in at a pause, bridged
// over, and the adhesive face underneath is never broken.

// Note 10. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
