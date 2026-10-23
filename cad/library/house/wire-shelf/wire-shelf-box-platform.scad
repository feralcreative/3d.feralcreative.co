// Note 1.

// COUPON-COMPONENTS: box-fit=coupon
// COUPON-PLATE: coupon
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

use <wire-shelf-dovetail.scad>

/* [Box] */
box_w = 128;             // Note 3.
box_d = 99;              // Note 4.
box_clearance = 1;       // Note 5.

/* [Platform] */
floor_t = 4.5;           // Note 6.
wall_t = 3.54;           // Note 7.
lip_h = 6;               // Note 8.
rear_t = 4.44;           // Note 9.
brace_run = 34;          // Note 10.
corner_r = 8;            // Note 11.

/* [Underside channel] */
channel_length = 128;    // Note 12.
channel_height = 34;     // Note 13.
channel_depth = 12;      // Note 14.
hook_scale = 0.1;        // Note 15.
rib_spacing = 90;        // Note 16.

/* [Shelf floor wires] */
// Note 17.

floor_wire_d = 3.5;      // Note 18.

floor_wire_pitch = 20;   // Note 19.
floor_wire_clearance = 0.5; // Note 20.
floor_wire_offset = 0;   // Note 21.
min_end_web = 3;         // Note 22.
support_wire_gap = 114;  // Note 23.

/* [Box fit coupon] */
coupon_ledge = 5;        // Note 24.

/* [Display] */
show = "print-set";      // [print-set, platform, deck, rail, set-rail, split, coupon, mount-coupon, assembly, box-fit, box-insertion, floor-wire-fit, floor-wire-insertion, joint-fit, joint-insertion, channel, section]

/* [Print set] */
set_gap = 8;             // Note 25.

/* [Colors] */
deck_color = "SteelBlue";
rail_color = "DarkOrange";

/* [Hidden] */
$fn = 64;
eps = 0.01;              // Note 26.
hook_origin = [294.9891052246094, 1100, 0]; // Note 27.
hook_bounds = [27, 34, 5];                // Note 28.

void_left = 17.5;        // Note 29.
void_right = 24.5;       // Note 30.
void_bottom = 2.5;       // Note 31.
inner_w = box_w + 2 * box_clearance;
inner_d = box_d + 2 * box_clearance;
outer_w = inner_w + 2 * wall_t;
outer_d = rear_t + inner_d + wall_t;
rail_d = 5;             // Note 32.
lower_rail_z = 11;       // Note 33.
upper_rail_z = hook_bounds.y - 6; // Note 34.
rail_y = hook_bounds.x - (void_left + void_right) / 2; // Note 35.
deck_z = 38.7;           // Note 36.
floor_top = deck_z + floor_t;
lip_top = floor_top + lip_h;
box_probe_h = channel_height + floor_t; // Note 37.
insertion_travel = lip_top + box_probe_h;

// Note 38.
assert(corner_r - (corner_r - wall_t) * sqrt(2) >= 0.84,
       "Corner radius leaves the corner wall too thin");
assert(channel_length <= outer_w, "Channel must lie within the platform width");
assert(channel_depth + brace_run < outer_d, "Underside ribs must end within the platform");
assert(channel_height == hook_bounds.y && channel_depth == 12,
       "Retain the supplied attachment dimensions; do not distort its wire fit");
assert(floor_t - shelf_dovetail_depth() >= 1.2, "Retain a solid roof above the groove");

module original_midsection() {
    // Note 39.
    projection(cut = true)
        translate([0, 0, -hook_bounds.z / 2])
            scale(hook_scale)
                translate(-hook_origin)
                    import("originals/repo/wire-tower-hook.stl", convexity = 10);
}

module channel_profile() {
    // Note 40.

    translate([hook_bounds.x, hook_bounds.y]) rotate(180)
        difference() {
            translate([void_left, void_bottom])
                square([void_right - void_left, hook_bounds.y - void_bottom + eps]);
            original_midsection();
        }
}

module channel_cut(length = channel_length) {
    translate([-length / 2 - eps, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = length + 2 * eps, convexity = 10)
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

// Note 41.
function floor_wire_z(wire_d = floor_wire_d) = lower_rail_z + rail_d / 2 + wire_d / 2;
// Note 42.
function floor_wire_end() = rail_y + rail_d / 2;

// Note 43.

function wire_xs(width, wire_d, pitch, offset, margin) = concat(
    [for (i = [ceil((-width / 2 - margin - offset) / pitch)
               : floor((width / 2 + margin - offset) / pitch)]) offset + i * pitch],
    [for (x = [-1, 1] * (support_wire_gap + wire_d) / 2)
         if (abs(x) <= width / 2 + margin) x]);

module floor_wire_reliefs(width, wire_d = floor_wire_d,
                          pitch = floor_wire_pitch,
                          clearance = floor_wire_clearance,
                          offset = floor_wire_offset) {
    // Note 44.

    slot_w = wire_d + 2 * clearance;
    slot_top = floor_wire_z(wire_d) + wire_d / 2 + clearance;
    slot_end = floor_wire_end() + clearance;
    assert(slot_top < upper_rail_z - rail_d / 2, "Floor-wire slots must stay below the upper seat");
    assert(wire_d > 0 && pitch > slot_w && clearance > 0);
    assert(abs(offset) <= pitch / 2, "Use a floor-wire offset within half a pitch");
    // Note 45.
    for (x = wire_xs(width, wire_d, pitch, offset, slot_w / 2)) {
        x0 = x - slot_w / 2 < -width / 2 + min_end_web ? -width / 2 - eps : x - slot_w / 2;
        x1 = x + slot_w / 2 > width / 2 - min_end_web ? width / 2 + eps : x + slot_w / 2;
        translate([x0, -eps, -eps])
            cube([x1 - x0, slot_end + eps, slot_top + eps]);
    }
}

module platform_body() {
    translate([-outer_w / 2, 0, deck_z]) cube([outer_w, outer_d, floor_t]);
    translate([-outer_w / 2, 0, deck_z])
        cube([outer_w, rear_t, floor_t + lip_h]);
    for (x = [-outer_w / 2, inner_w / 2])
        translate([x, 0, deck_z]) cube([wall_t, outer_d, floor_t + lip_h]);
    translate([-outer_w / 2, rear_t + inner_d, deck_z])
        cube([outer_w, wall_t, floor_t + lip_h]);
    platform_mount_body();
}

module platform_mount_body() {
    translate([-channel_length / 2, 0, 0])
        cube([channel_length, channel_depth, deck_z]);
    underside_ribs();
}

module rounded_footprint() {
    // Note 46.
    translate([-outer_w / 2, 0, deck_z - eps])
        linear_extrude(height = floor_t + lip_h + 2 * eps, convexity = 10)
            hull() {
                translate([0, -eps]) square([outer_w, eps]);
                for (x = [corner_r, outer_w - corner_r])
                    translate([x, outer_d - corner_r]) circle(r = corner_r);
            }
    translate([-outer_w, -eps, -eps]) cube([2 * outer_w, outer_d + 2 * eps, deck_z]);
}

module platform_unsplit() {
    difference() {
        intersection() { platform_body(); rounded_footprint(); }
        channel_cut();
        floor_wire_reliefs(channel_length);
    }
}

module box_deck() {
    color(deck_color) difference() {
        intersection() {
            platform_unsplit();
            translate([-outer_w / 2 - eps, -eps, deck_z])
                cube([outer_w + 2 * eps, outer_d + 2 * eps, floor_t + lip_h + eps]);
        }
        // Note 47.
        shelf_dovetail_groove(outer_w, deck_z, channel_depth);
    }
}

module box_rail() {
    color(rail_color) union() {
        difference() {
            intersection() {
                platform_mount_body();
                translate([-outer_w / 2 - eps, -eps, -eps])
                    cube([outer_w + 2 * eps, outer_d + 2 * eps, deck_z + eps]);
            }
            channel_cut();
            floor_wire_reliefs(channel_length);
        }
        shelf_dovetail_tail(channel_length, deck_z, channel_depth);
    }
}

module box_platform() { box_deck(); box_rail(); }

module box_deck_pose() { translate([0, 0, -deck_z]) children(); }
module box_set_rail_pose() {
    translate([0, -channel_depth - brace_run - set_gap, 0]) children();
}

module mount_fit_coupon() {
    // Note 48.

    coupon_w = 3 * floor_wire_pitch;
    intersection() {
        platform_unsplit();
        translate([-coupon_w / 2, -eps, -eps])
            cube([coupon_w, channel_depth + eps, floor_top + 2 * eps]);
    }
}

module box_envelope(extra_h = 0) {
    translate([-box_w / 2, rear_t + box_clearance, floor_top + eps])
        cube([box_w, box_d, box_probe_h + extra_h]);
}

module box_fit_coupon() {
    // Note 49.

    assert(coupon_ledge > box_clearance && 2 * coupon_ledge < min(inner_w, inner_d),
           "Coupon ledge must support the box and leave an open middle");
    translate([0, 0, -deck_z])
        difference() {
            intersection() {
                platform_unsplit();
                translate([-outer_w / 2 - eps, -eps, deck_z])
                    cube([outer_w + 2 * eps, outer_d + 2 * eps, floor_t + lip_h + eps]);
            }
            translate([-inner_w / 2 + coupon_ledge, rear_t + coupon_ledge, deck_z - eps])
                cube([inner_w - 2 * coupon_ledge, inner_d - 2 * coupon_ledge,
                      floor_t + lip_h + 2 * eps]);
        }
}

module floor_wire_envelope(width = channel_length,
                           wire_d = floor_wire_d, pitch = floor_wire_pitch,
                           offset = floor_wire_offset) {
    wire_z = floor_wire_z(wire_d);
    probe_length = floor_wire_end() + wire_d;
    for (x = wire_xs(width, wire_d, pitch, offset, 0))
        translate([x, -wire_d, wire_z])
            rotate([-90, 0, 0])
                cylinder(h = probe_length,
                         r = wire_d / 2 / cos(180 / $fn));
}

module floor_wire_sweep(width = channel_length,
                        wire_d = floor_wire_d, pitch = floor_wire_pitch,
                        offset = floor_wire_offset) {
    // Note 50.

    wire_z = floor_wire_z(wire_d);
    for (x = wire_xs(width, wire_d, pitch, offset, 0))
        hull() {
            for (z = [wire_z, -wire_d])
                translate([x, -wire_d, z])
                    rotate([-90, 0, 0])
                        cylinder(h = floor_wire_end() + wire_d,
                                 r = wire_d / 2 / cos(180 / $fn));
        }
}

// Note 51.
module feral_default_output_48d471b6e899() {
if (show == "print-set") { box_deck_pose() box_deck(); box_set_rail_pose() box_rail(); }
else if (show == "platform") box_platform();
else if (show == "deck") box_deck_pose() box_deck();
else if (show == "rail") box_rail();
else if (show == "set-rail") box_set_rail_pose() box_rail();
else if (show == "split") { translate([0, 0, 15]) box_deck(); box_rail(); }
else if (show == "coupon") box_fit_coupon();
else if (show == "mount-coupon") mount_fit_coupon();
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
    %floor_wire_envelope();
} else if (show == "box-fit") {
    intersection() { box_platform(); box_envelope(); }
} else if (show == "box-insertion") {
    // Note 52.
    intersection() { box_platform(); box_envelope(insertion_travel); }
} else if (show == "floor-wire-fit") {
    intersection() { box_platform(); floor_wire_envelope(); }
} else if (show == "floor-wire-insertion") {
    intersection() { box_platform(); floor_wire_sweep(); }
} else if (show == "joint-fit") {
    intersection() { box_rail(); box_deck(); }
} else if (show == "joint-insertion") {
    // Note 53.
    intersection() {
        box_deck();
        hull() {
            shelf_dovetail_tail(channel_length, deck_z, channel_depth);
            translate([outer_w + channel_length, 0, 0])
                shelf_dovetail_tail(channel_length, deck_z, channel_depth);
        }
    }
}
}

module feral_assembly_view_48d471b6e899(explode=false) {
color("SteelBlue") translate([0,0,explode ? 35 : 0]) box_deck(); color("DarkOrange") box_rail();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_48d471b6e899();
else feral_assembly_view_48d471b6e899(view == "exploded");

// Notes

// Note 1. Platform for a 128 x 99 mm wooden box; the long edge faces the shelf.
// Cut the tested hook's inside profile into a continuous rear underside channel.
// +X runs along the shelf, +Y points away from it, +Z is up in use.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, rear edge along the shelf

// Note 4. mm, projection away from the shelf

// Note 5. mm per side; footprint was measured approximately

// Note 6. mm

// Note 7. mm, two 0.42 mm outer lines plus six 0.45 mm inner lines

// Note 8. mm above the floor

// Note 9. mm

// Note 10. mm, underside rib projection forward of the mounting beam

// Note 11. mm, the two front (+Y) outer corners; the rear sits
// against the shelf, and the pocket stays square for the box

// Note 12. mm, one continuous hook along the rear edge

// Note 13. mm, full original hook height below the platform

// Note 14. mm, original rear attachment's outer width

// Note 15. original 3MF build transform

// Note 16. mm between underside braces; these are not shelf clips

// Note 17. PROVEN 2026-10-03: the printed rail coupon fit the shelf perfectly. Every wire
// shelf part uses floor_wire_reliefs() with these values; do not change them.

// Note 18. mm, the thicker of the two: 3.5 front-to-back, 2.25 left-right,
// so the same slots fit a shelf's front edge or its side

// Note 19. mm centre to centre, measured on the 2.25 mm wires

// Note 20. mm per side and above the wires

// Note 21. mm along X; align the slot pattern with the shelf

// Note 22. mm; a slot nearer a beam end than this runs out through it

// Note 23. mm, measured clear gap between the front edge's support wires;
// parts centre on that gap, so those wires sit at +/-58.75

// Note 24. mm of the original floor retained inside each lip

// Note 25. mm between the two separately printed pieces

// Note 26. mm boolean overshoot

// Note 27. original STL coordinates

// Note 28. mm after normalization/scaling
// This mask encloses the internal void and stays within solid at the closed end.
// Its open end extends beyond the original free tips, opening the cut downward.

// Note 29. mm in the normalized source profile

// Note 30. mm

// Note 31. mm

// Note 32. mm, circular seat diameter in the supplied hook profile

// Note 33. mm, original lower seat center after flipping the profile

// Note 34. mm, original lower seat becomes upper after flipping

// Note 35. mm, seat centre; measured span 3.5-8.5

// Note 36. mm, the printed and physically fitted deck elevation

// Note 37. envelope only, not measured box height

// Note 38. Square pocket corner to the outer arc: keep at least two perimeter lines there.

// Note 39. Slice the middle of the original 5 mm thickness, avoiding its outer rounding.

// Note 40. Profile axes are [Y,Z]. Flip the original so its mouth opens DOWN.
// Source (u,v) -> mounted (27-u,34-v); both original wire-seat outlines survive.

// Note 41. Wire centre: resting on the lower rail, so tangent to the top of its seat.

// Note 42. Wire ends: at most the far tangent of the rail they are welded to.

// Note 43. Slot centres: the 20 mm side-edge pattern plus the front edge's two support
// wires either side of the part's centre, each kept only if it reaches the part.

// Note 44. Thin wires are welded on TOP of the lower rail, the bottom circular seat.
// Open-bottom slots admit them during snap-on; no enclosed drilled holes.
// Each slot rises through the lower seat to clear the wire above it.
// The wires run from the rail back into the shelf (-Y) and end on the rail,
// so slots stop past its far side and the outer jaw stays solid.

// Note 45. A slot that would leave a thin stub at a beam end takes the stub with it.

// Note 46. Round only the deck and lip; the beam and ribs below keep their shapes.

// Note 47. Open the groove through both wider deck ends so the rail can slide in.

// Note 48. A literal slice of the production rail spanning three wire slots, with
// the deck strip above it that ties the beam together.

// Note 49. Cut the actual platform edge, preserving all four corners, the full lip,
// and a narrow seating ledge. Remove the middle and every mounting feature.

// Note 50. Each wire has one connected straight approach from wholly below.
// Hull each wire separately: hulling the complete array would fill gaps.

// Note 51. Assembly display changes placement only; the original output remains the default.

// Note 52. Continuous vertical swept volume, from wholly above the platform to seated.

// Note 53. One connected axial path, from wholly outside the deck to seated.
