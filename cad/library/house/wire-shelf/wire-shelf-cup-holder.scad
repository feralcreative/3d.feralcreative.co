// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

use <wire-shelf-box-platform.scad>
use <wire-shelf-dovetail.scad>

/* [Cup] */
inside_d = 69;           // Note 3.
probe_clearance = 0.5;   // Note 4.
cup_depth = 25;          // Note 5.

/* [Body] */
wall_t = 3.54;           // Note 6.
floor_t = 4.5;           // Note 7.
brace_run = 34;          // Note 8.
rib_spacing = 36;        // Note 9.

/* [Mount] */
mount_depth = 12;        // Note 10.
deck_z = 38.7;           // Note 11.

/* [Shelf floor wires] */
floor_wire_d = 3.5;      // Note 12.
floor_wire_pitch = 20;   // Note 13.
floor_wire_clearance = 0.5; // Note 14.
floor_wire_offset = 0;   // Note 15.

/* [Display] */
show = "print-set";      // [print-set, holder, body, rail, set-rail, split, assembly, cup-fit, cup-insertion, floor-wire-fit, floor-wire-insertion, joint-fit, joint-insertion, mount, section]

/* [Print set] */
set_gap = 8;             // Note 16.

/* [Colors] */
body_color = "SteelBlue";
rail_color = "DarkOrange";

/* [Hidden] */
$fn = 64;
eps = 0.01;              // Note 17.
chord_error = 0.02;      // Note 18.
inner_r = inside_d / 2;
cup_facets = 4 * ceil(180 / acos(1 - chord_error / (inner_r + wall_t)) / 4);
bore_r = inner_r / cos(180 / cup_facets); // Note 19.
outer_r = (inner_r + wall_t) / cos(180 / cup_facets);
mount_w = 2 * outer_r;
cup_y = mount_depth + outer_r;
floor_top = deck_z + floor_t;
rim_z = floor_top + cup_depth;
probe_h = cup_depth + floor_t; // Note 20.
insertion_travel = rim_z + probe_h;

assert(inside_d > 0 && probe_clearance > 0 && cup_depth > 0);
assert(mount_depth == 12 && deck_z == 38.7,
       "Keep the proven channel surround and deck elevation unchanged");
assert(mount_w <= 128, "The source channel cutter is 128 mm long");
assert(rib_spacing / 2 + wall_t / 2 < outer_r);
assert(brace_run < outer_r, "Keep braces beneath the circular floor");
assert(floor_t - shelf_dovetail_depth() >= 1.2, "Retain a solid roof above the groove");

module floor_outline() {
    hull() {
        translate([-mount_w / 2, 0]) square([mount_w, mount_depth]);
        translate([0, cup_y]) circle(r = outer_r, $fn = cup_facets);
    }
}

module mounting_beam() {
    difference() {
        translate([-mount_w / 2, 0, 0])
            cube([mount_w, mount_depth, deck_z + eps]);
        channel_cut();
        floor_wire_reliefs(mount_w, floor_wire_d,
                           floor_wire_pitch, floor_wire_clearance, floor_wire_offset);
    }
}

module cup_braces() {
    for (x = [-rib_spacing / 2, rib_spacing / 2])
        translate([x - wall_t / 2, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = wall_t, convexity = 10)
                    polygon([[mount_depth - eps, 0],
                             [mount_depth + brace_run, deck_z + eps],
                             [mount_depth - eps, deck_z + eps]]);
}

module holder_unsplit() {
    difference() {
        union() {
            mounting_beam();
            cup_braces();
            translate([0, 0, deck_z])
                linear_extrude(height = floor_t, convexity = 10) floor_outline();
            translate([0, cup_y, deck_z])
                cylinder(h = floor_t + cup_depth, r = outer_r, $fn = cup_facets);
        }
        translate([0, cup_y, floor_top])
            cylinder(h = cup_depth + eps, r = bore_r, $fn = cup_facets);
    }
}

module holder_body() {
    color(body_color) difference() {
        intersection() {
            holder_unsplit();
            translate([-mount_w / 2 - eps, -eps, deck_z])
                cube([mount_w + 2 * eps, cup_y + outer_r + 2 * eps, floor_t + cup_depth + eps]);
        }
        shelf_dovetail_groove(mount_w, deck_z, mount_depth);
    }
}

module holder_rail() {
    color(rail_color) union() {
        intersection() {
            union() { mounting_beam(); cup_braces(); }
            translate([-mount_w / 2 - eps, -eps, -eps])
                cube([mount_w + 2 * eps, mount_depth + brace_run + 2 * eps, deck_z + eps]);
        }
        shelf_dovetail_tail(mount_w, deck_z, mount_depth);
    }
}

module cup_holder() { holder_body(); holder_rail(); }
module holder_body_pose() { translate([0, 0, -deck_z]) children(); }
module holder_set_rail_pose() {
    translate([0, -mount_depth - brace_run - set_gap, 0]) children();
}

module cup_envelope(extra_h = 0) {
    translate([0, cup_y, floor_top + eps])
        cylinder(h = probe_h + extra_h,
                 r = (inner_r - probe_clearance) / cos(180 / cup_facets), $fn = cup_facets);
}

// Note 21.
module feral_default_output_93f430a32545() {
if (show == "print-set") { holder_body_pose() holder_body(); holder_set_rail_pose() holder_rail(); }
else if (show == "holder") cup_holder();
else if (show == "body") holder_body_pose() holder_body();
else if (show == "rail") holder_rail();
else if (show == "set-rail") holder_set_rail_pose() holder_rail();
else if (show == "split") { translate([0, 0, 15]) holder_body(); holder_rail(); }
else if (show == "mount") mounting_beam();
else if (show == "assembly") {
    cup_holder();
    %cup_envelope();
    %floor_wire_envelope(mount_w, floor_wire_d,
                         floor_wire_pitch, floor_wire_offset);
} else if (show == "cup-fit") {
    intersection() { cup_holder(); cup_envelope(); }
} else if (show == "cup-insertion") {
    // Note 22.
    intersection() { cup_holder(); cup_envelope(insertion_travel); }
} else if (show == "floor-wire-fit") {
    intersection() {
        cup_holder();
        floor_wire_envelope(mount_w, floor_wire_d,
                            floor_wire_pitch, floor_wire_offset);
    }
} else if (show == "floor-wire-insertion") {
    intersection() {
        cup_holder();
        floor_wire_sweep(mount_w, floor_wire_d,
                        floor_wire_pitch, floor_wire_offset);
    }
} else if (show == "joint-fit") {
    intersection() { holder_rail(); holder_body(); }
} else if (show == "joint-insertion") {
    intersection() {
        holder_body();
        hull() {
            shelf_dovetail_tail(mount_w, deck_z, mount_depth);
            translate([2 * mount_w, 0, 0])
                shelf_dovetail_tail(mount_w, deck_z, mount_depth);
        }
    }
} else if (show == "section") {
    intersection() {
        cup_holder();
        translate([-wall_t / 2, -eps, -eps])
            cube([wall_t, cup_y + outer_r + 2 * eps, rim_z + 2 * eps]);
    }
}
}

module feral_assembly_view_93f430a32545(explode=false) {
color("SteelBlue") translate([0,0,explode ? 35 : 0]) holder_body(); color("DarkOrange") holder_rail();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_93f430a32545();
else feral_assembly_view_93f430a32545(view == "exploded");

// Notes

// Note 1. Cup holder using the physically proven box-platform mounting channel.
// +X runs along the shelf, +Y points away from it, +Z is up in use.
// Reuse the exact channel cutter; do not redraw or rescale the wire seats.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, exact clear inside diameter across the polygon flats

// Note 4. mm per side for the removable test envelope only

// Note 5. mm above the inside floor

// Note 6. mm, two 0.42 mm outer lines plus six 0.45 mm inner lines

// Note 7. mm, same as the tested platform

// Note 8. mm forward of the mounting beam

// Note 9. mm between underside braces

// Note 10. mm, retain the tested attachment's outer depth

// Note 11. mm, retain the tested deck underside elevation

// Note 12. mm, fits either edge: 3.5 front-to-back, 2.25 left-right wires

// Note 13. mm centre to centre

// Note 14. mm per side and above the wires

// Note 15. mm along X; align the slot pattern with the shelf

// Note 16. mm between the two separately printed pieces

// Note 17. mm boolean overshoot

// Note 18. mm, circular facet budget for the 0.4 mm nozzle

// Note 19. circumscribed: never undersize the opening

// Note 20. mm, cylindrical cup envelope only

// Note 21. Assembly display changes placement only; the original output remains the default.

// Note 22. Exact continuous vertical swept envelope, from wholly above to seated.
