// 4 x 2 Gridfinity plate that hangs off the wire shelf on the proven mount.
// +X runs along the shelf, +Y points away from it, +Z is up in use.
// Reuse the exact channel and wire cutters; do not redraw the wire seats.
use <../wire-shelf-box-platform.scad>
include <gridfinity-plate-modules.scad>

/* [Grid] */
xsize = 4;               // cells along the shelf
ysize = 2;               // cells projecting away from the shelf

/* [Plate] */
floor_thickness = 3.2;   // mm of flat sheet under the sockets; it is the deck

/* [Magnets] */
// Printed upside down, socket rim on the bed, so the cavities sit 5 mm up,
// above the bridged socket floors. Skin and cavity land on 0.30/0.12 layer
// boundaries there (5.46 to 7.62), so slice.sh --magnet-pause pauses cleanly.
magnet_hole_d = 10.5;    // mm cavity for a 10 x 2 mm disc; 0 for none
magnet_cav_h = 2.16;     // mm, a 2 mm disc plus 0.16, eighteen 0.12 layers
magnet_skin = 0.46;      // mm between cavity and socket floor; same again below

/* [Print] */
flip = true;             // print orientation: socket rim on the bed; false shows it as mounted

/* [Mount] */
mount_depth = 12;        // mm, retain the tested attachment's outer depth
deck_z = 38.7;           // mm, retain the tested deck underside elevation
mount_wall_t = 3.54;     // mm, brace thickness; two outer plus six inner lines
brace_run = 34;          // mm forward of the mounting beam
brace_x = [-80, -30, 30, 80]; // mm, brace centres

/* [Display] */
show = "plate";          // [plate, mount, section]

/* [Hidden] */
$fn = 48;
mount_eps = 0.01;        // mm boolean overshoot
plate_w = xsize * gridfinity_pitch;
plate_d = ysize * gridfinity_pitch;

assert(mount_depth == 12 && deck_z == 38.7,
       "Keep the proven channel surround and deck elevation unchanged");
assert(mount_depth + brace_run < plate_d, "Braces must end beneath the plate");

module gf_plate() {
    // plate_blocks centres cell 0 on the origin and puts its floor at Z=-floor.
    translate([-plate_w / 2 + gridfinity_pitch / 2, gridfinity_pitch / 2,
               deck_z + floor_thickness])
        plate_blocks([[0, 0, xsize, ysize]], floor_ht = floor_thickness,
                     magnet_hole_d = magnet_hole_d,
                     magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
}

module mount_braces() {
    for (x = brace_x)
        translate([x - mount_wall_t / 2, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = mount_wall_t, convexity = 10)
                    polygon([[mount_depth - mount_eps, 0],
                             [mount_depth + brace_run, deck_z + mount_eps],
                             [mount_depth - mount_eps, deck_z + mount_eps]]);
}

module mount() {
    // Trim the beam's square ends to the plate's rounded corners.
    intersection() {
        translate([-plate_w / 2 + gridfinity_pitch / 2, gridfinity_pitch / 2, -mount_eps])
            linear_extrude(height = deck_z + 2 * mount_eps, convexity = 10)
                plate_outline_2d([[0, 0, xsize, ysize]]);
        mount_body();
    }
}

module mount_body() {
    difference() {
        union() {
            translate([-plate_w / 2, 0, 0])
                cube([plate_w, mount_depth, deck_z + mount_eps]);
            mount_braces();
        }
        channel_cut(plate_w);
        floor_wire_reliefs(plate_w);
    }
}

module shelf_plate() {
    mount();
    gf_plate();
}

module print_pose() {
    // Turn over about X and stand the socket rim on the bed.
    if (flip) translate([0, plate_d, deck_z + floor_thickness + 5]) rotate([180, 0, 0]) children();
    else children();
}

if (show == "plate") print_pose() shelf_plate();
else if (show == "mount") mount();
else if (show == "section") {
    intersection() {
        shelf_plate();
        translate([-mount_wall_t / 2, -mount_eps, -mount_eps])
            cube([mount_wall_t, plate_d + 2 * mount_eps, deck_z + 20]);
    }
}
