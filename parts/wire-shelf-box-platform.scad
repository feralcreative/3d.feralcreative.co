// Platform for a 128 x 99 mm wooden box; the long edge faces the shelf.
// Cut the tested hook's inside profile into a continuous rear underside channel.
// +X runs along the shelf, +Y points away from it, +Z is up in use.
// COUPON-COMPONENTS: box-fit=coupon
// COUPON-PLATE: coupon

/* [Box] */
box_w = 128;             // mm, rear edge along the shelf
box_d = 99;              // mm, projection away from the shelf
box_clearance = 1;       // mm per side; footprint was measured approximately

/* [Platform] */
floor_t = 4.5;           // mm
wall_t = 3.54;           // mm, two 0.42 mm outer lines plus six 0.45 mm inner lines
lip_h = 6;               // mm above the floor
rear_t = 4.44;           // mm
brace_run = 34;          // mm, underside rib projection forward of the mounting beam

/* [Underside channel] */
channel_length = 128;    // mm, one continuous hook along the rear edge
channel_height = 34;     // mm, full original hook height below the platform
channel_depth = 12;      // mm, original rear attachment's outer width
hook_scale = 0.1;        // original 3MF build transform
rib_spacing = 90;        // mm between underside braces; these are not shelf clips

/* [Cross wires] */
cross_wire_d = 7.7;      // mm, wires running front-to-back under the platform
cross_wire_gap = 114;    // mm, measured clear gap between facing wire surfaces
cross_wire_clearance = 0.5; // mm on each side and above the wires

/* [Box fit coupon] */
coupon_ledge = 5;        // mm of the original floor retained inside each lip

/* [Display] */
show = "platform";       // [platform, coupon, assembly, box-fit, box-insertion, wire-fit, wire-insertion, channel, section]

/* [Hidden] */
$fn = 64;
eps = 0.01;              // mm boolean overshoot
hook_origin = [294.9891052246094, 1100, 0]; // original STL coordinates
hook_bounds = [27, 34, 5];                // mm after normalization/scaling
// This mask encloses the internal void and stays within solid at the closed end.
// Its open end extends beyond the original free tips, opening the cut downward.
void_left = 17.5;        // mm in the normalized source profile
void_right = 24.5;       // mm
void_bottom = 2.5;       // mm
inner_w = box_w + 2 * box_clearance;
inner_d = box_d + 2 * box_clearance;
outer_w = inner_w + 2 * wall_t;
outer_d = rear_t + inner_d + wall_t;
cross_wire_pitch = cross_wire_gap + cross_wire_d;
cross_slot_w = cross_wire_d + 2 * cross_wire_clearance;
rail_d = 5;             // mm, circular seat diameter in the supplied hook profile
upper_rail_z = hook_bounds.y - 6; // mm, original lower seat becomes upper after flipping
// Conservative height: the perpendicular wire can sit on top of the upper rail.
// Open-bottom cuts also clear wires crossing lower down; no narrow vertical seat.
cross_wire_z = upper_rail_z + rail_d / 2 + cross_wire_d / 2;
deck_z = max(channel_height, cross_wire_z + cross_wire_d / 2 + cross_wire_clearance);
floor_top = deck_z + floor_t;
lip_top = floor_top + lip_h;
box_probe_h = channel_height + floor_t; // envelope only, not measured box height
insertion_travel = lip_top + box_probe_h;

assert(channel_length <= outer_w, "Channel must lie within the platform width");
assert(channel_depth + brace_run < outer_d, "Underside ribs must end within the platform");
assert(channel_height == hook_bounds.y && channel_depth == 12,
       "Retain the supplied attachment dimensions; do not distort its wire fit");
assert(cross_wire_gap > 2 * cross_wire_clearance, "Cross-wire reliefs must remain separate");

module original_midsection() {
    // Slice the middle of the original 5 mm thickness, avoiding its outer rounding.
    projection(cut = true)
        translate([0, 0, -hook_bounds.z / 2])
            scale(hook_scale)
                translate(-hook_origin)
                    import("../wire-tower-hook.stl", convexity = 10);
}

module channel_profile() {
    // Profile axes are [Y,Z]. Flip the original so its mouth opens DOWN.
    // Source (u,v) -> mounted (27-u,34-v); both original wire-seat outlines survive.
    translate([hook_bounds.x, hook_bounds.y]) rotate(180)
        difference() {
            translate([void_left, void_bottom])
                square([void_right - void_left, hook_bounds.y - void_bottom + eps]);
            original_midsection();
        }
}

module channel_cut() {
    translate([-channel_length / 2 - eps, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = channel_length + 2 * eps, convexity = 10)
                channel_profile();
}

module underside_ribs() {
    for (x = [-rib_spacing / 2, rib_spacing / 2])
        translate([x - wall_t / 2, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = wall_t, convexity = 10)
                    polygon([[channel_depth - eps, 0],
                             [channel_depth + brace_run, deck_z + eps],
                             [channel_depth - eps, deck_z + eps]]);
}

module cross_wire_reliefs() {
    // Cut all material under the deck along each front-to-back wire path.
    // At this width the reliefs reach the ends of the nominal 128 mm beam,
    // leaving a continuous 113 mm grip between them without loose end slivers.
    for (x = [-cross_wire_pitch / 2, cross_wire_pitch / 2])
        translate([x - cross_slot_w / 2, -eps, -eps])
            cube([cross_slot_w, outer_d + 2 * eps, deck_z + eps]);
}

module platform_body() {
    translate([-outer_w / 2, 0, deck_z]) cube([outer_w, outer_d, floor_t]);
    translate([-outer_w / 2, 0, deck_z])
        cube([outer_w, rear_t, floor_t + lip_h]);
    for (x = [-outer_w / 2, inner_w / 2])
        translate([x, 0, deck_z]) cube([wall_t, outer_d, floor_t + lip_h]);
    translate([-outer_w / 2, rear_t + inner_d, deck_z])
        cube([outer_w, wall_t, floor_t + lip_h]);
    translate([-channel_length / 2, 0, 0])
        cube([channel_length, channel_depth, deck_z + eps]);
    underside_ribs();
}

module box_platform() {
    difference() {
        union() { platform_body(); }
        channel_cut();
        cross_wire_reliefs();
    }
}

module box_envelope(extra_h = 0) {
    translate([-box_w / 2, rear_t + box_clearance, floor_top + eps])
        cube([box_w, box_d, box_probe_h + extra_h]);
}

module box_fit_coupon() {
    // Cut the actual platform edge, preserving all four corners, the full lip,
    // and a narrow seating ledge. Remove the middle and every mounting feature.
    assert(coupon_ledge > box_clearance && 2 * coupon_ledge < min(inner_w, inner_d),
           "Coupon ledge must support the box and leave an open middle");
    translate([0, 0, -deck_z])
        difference() {
            intersection() {
                box_platform();
                translate([-outer_w / 2 - eps, -eps, deck_z])
                    cube([outer_w + 2 * eps, outer_d + 2 * eps, floor_t + lip_h + eps]);
            }
            translate([-inner_w / 2 + coupon_ledge, rear_t + coupon_ledge, deck_z - eps])
                cube([inner_w - 2 * coupon_ledge, inner_d - 2 * coupon_ledge,
                      floor_t + lip_h + 2 * eps]);
        }
}

module cross_wire_at(x, drop = 0) {
    // Circumscribed polygons conservatively contain the measured round wires.
    probe_extra = cross_wire_d;
    translate([x, -probe_extra, cross_wire_z - drop])
        rotate([-90, 0, 0])
            cylinder(h = outer_d + 2 * probe_extra,
                     r = cross_wire_d / 2 / cos(180 / $fn));
}

module cross_wire_envelope() {
    for (x = [-cross_wire_pitch / 2, cross_wire_pitch / 2]) cross_wire_at(x);
}

module cross_wire_sweep() {
    // A continuous approach from wholly below the platform to the seated level.
    for (x = [-cross_wire_pitch / 2, cross_wire_pitch / 2])
        hull() {
            cross_wire_at(x);
            cross_wire_at(x, cross_wire_z + cross_wire_d);
        }
}

if (show == "platform") box_platform();
else if (show == "coupon") box_fit_coupon();
else if (show == "channel") channel_cut();
else if (show == "section") {
    intersection() {
        box_platform();
        translate([-wall_t / 2, -eps, -eps]) cube([wall_t, outer_d + 2 * eps, lip_top + 2 * eps]);
    }
}
else if (show == "assembly") {
    box_platform();
    %box_envelope();
    %cross_wire_envelope();
} else if (show == "box-fit") {
    intersection() { box_platform(); box_envelope(); }
} else if (show == "box-insertion") {
    // Continuous vertical swept volume, from wholly above the platform to seated.
    intersection() { box_platform(); box_envelope(insertion_travel); }
} else if (show == "wire-fit") {
    intersection() { box_platform(); cross_wire_envelope(); }
} else if (show == "wire-insertion") {
    intersection() { box_platform(); cross_wire_sweep(); }
}
