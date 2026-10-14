// Ten wings-out Halloween bats adapted for a fully enclosed cup magnet.
// Print the flat decorative face on the bed. Insert the magnet during a pause,
// before the rear roof starts, with the magnet's working face toward the roof.
// Original meshes are retained. Sample their solid plate below the old mounts.

/* [Bat] */
bat = "body22"; // [body14, body15, body16, body17, body19, body21, body22, body23, body25, body26]
plate_h = 2.1;             // mm, decorative wing plate and cavity floor
source_slice_z = 0.8;      // mm, inside the original 1.5 mm plate, below magnet bosses
outline_margin = 0.25;    // mm, plate extends beyond the widened rear housing
safe_xy = 205;             // mm, documented safe printer footprint

/* [Cup magnet] */
magnet_d = 51.7;           // mm, measured steel cup outside diameter
magnet_h = 10.75;          // mm, measured complete cup thickness
pocket_diameter_extra = 0.3; // mm, nominal 0.15 mm clearance per side
pocket_depth_extra = 0.29; // mm, extra depth above the seated magnet
housing_wall = 2.1;        // mm, radial plastic around the pocket
roof_h = 0.84;             // mm, solid rear cover over the magnet's working face
entry_travel = 30;         // mm, swept path starts completely above the open housing

/* [Colors] */
bat_color = "SlateGray";   // preview only; STL does not specify filament color
magnet_color = "Silver";

/* [Output] */
show = "bat"; // [bat, coupon, before-cap, section, magnet-fit, magnet-insertion, wall-fit]

/* [Hidden] */
$fn = 128;
eps = 0.01;
pocket_d = magnet_d + pocket_diameter_extra;
pocket_h = magnet_h + pocket_depth_extra;
roof_z = plate_h + pocket_h;
part_h = roof_z + roof_h;
housing_d = pocket_d + 2 * housing_wall;
bore_factor = 1 / cos(180 / $fn);
// Source file, measured centre, XY scale, print rotation, widen body.
bat_data = bat == "body14" ? ["originals/obj_6_Body14.stl", 389.7737300481852, -92.74608295291189, 1.798, 45.0, true] :
           bat == "body15" ? ["originals/obj_7_Body15.stl", 349.63140951774056, -139.55378075423604, 1.827, 82.5, true] :
           bat == "body16" ? ["originals/obj_8_Body16.stl", 475.67489286814134, -83.62892765119665, 1.989, 9.0, true] :
           bat == "body17" ? ["originals/obj_9_Body17.stl", 463.7468407022695, -280.4362310559776, 1.527, 53.0, true] :
           bat == "body19" ? ["originals/obj_11_Body19.stl", 797.9733649127863, -229.2743252694181, 2.276, 38.0, true] :
           bat == "body21" ? ["originals/obj_14_Body21.stl", 683.0583373088284, -253.4461300200991, 2.372, 70.0, true] :
           bat == "body22" ? ["originals/obj_15_Body22.stl", 697.1472965081787, -104.41749915344235, 1.698, 45.0, false] :
           bat == "body23" ? ["originals/obj_16_Body23.stl", 775.3828085974022, -158.66981256934974, 1.678, 45.0, true] :
           bat == "body25" ? ["originals/obj_18_Body25.stl", 341.7547967791832, -276.0171197406533, 1.886, 84.5, true] :
           bat == "body26" ? ["originals/obj_19_Body26.stl", 433.5264600365325, -192.4083944080569, 2.018, 86.5, true] : undef;

assert(!is_undef(bat_data), "choose one of the ten flying bat variants");
assert(pocket_diameter_extra > 0 && pocket_depth_extra > 0 &&
       plate_h > 0 && roof_h > 0 && housing_wall > 0,
       "the cup needs insertion clearance and a completely closed housing");
assert(pocket_d * bore_factor < housing_d,
       "the faceted compensated pocket must leave a continuous housing wall");

module original_outline() {
    rotate(bat_data[4]) scale([bat_data[3], bat_data[3]])
        translate([-bat_data[1], -bat_data[2]])
            projection(cut = true)
                translate([0, 0, -source_slice_z])
                    import(bat_data[0], convexity = 10);
}

// Grow only the torso around the cup; keep the imported wings and head intact.
// The three offset pocket centres preserve ears that a larger torso could hide.
module bat_outline() {
    union() {
        original_outline();
        if (bat_data[5]) circle(d = housing_d + 2 * outline_margin);
    }
}

module pocket_cut() {
    translate([0, 0, plate_h])
        cylinder(d = pocket_d * bore_factor, h = pocket_h);
}

module bat_part() {
    color(bat_color) difference() {
        union() {
            linear_extrude(height = plate_h, convexity = 10) bat_outline();
            cylinder(d = housing_d, h = part_h);
        }
        pocket_cut();
    }
}

module fit_coupon() {
    // Same floor, pocket and wall; open top permits a physical cup-fit check.
    color(bat_color) difference() {
        cylinder(d = housing_d, h = roof_z);
        translate([0, 0, plate_h])
            cylinder(d = pocket_d * bore_factor, h = pocket_h + eps);
    }
}

module before_cap() {
    intersection() {
        bat_part();
        translate([-safe_xy, -safe_xy, -eps])
            cube([2 * safe_xy, 2 * safe_xy, roof_z]);
    }
}

module magnet_dummy() {
    color(magnet_color) translate([0, 0, plate_h + eps])
        cylinder(d = magnet_d, h = magnet_h);
}

module magnet_entry_sweep() {
    // Exact continuous vertical translation through the open, paused housing.
    translate([0, 0, plate_h + eps])
        cylinder(d = magnet_d, h = magnet_h + part_h + entry_travel);
}

if (show == "bat") bat_part();
else if (show == "coupon") fit_coupon();
else if (show == "before-cap") before_cap();
else if (show == "section") {
    difference() {
        bat_part();
        translate([0, -safe_xy, -eps])
            cube([safe_xy, 2 * safe_xy, part_h + 2 * eps]);
    }
    magnet_dummy();
}
else if (show == "magnet-fit") intersection() { bat_part(); magnet_dummy(); }
else if (show == "magnet-insertion") intersection() { before_cap(); magnet_entry_sweep(); }
else if (show == "wall-fit") linear_extrude(height = eps) difference() {
    circle(d = housing_d);
    bat_outline();
}
else assert(false, str("unknown show: ", show));
