// Rev-02 beverage station, reconstructed from sketchup/kitchen.
// Drink-body revision: level packet floors continuous with the pickup tray.
// Six independent pieces; the baseplate filenames in the archive are swapped.
// Coffee is on the left, drinks on the right; front is -Y and the bed is Z=0.
// Dimensions are mm. No archived mesh is needed to render or build this file.

/* [View] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "drinks-body"; // [assembled, exploded, coffee-body, coffee-lid, coffee-base, drinks-body, drinks-lid, drinks-base, base-fit, base-insertion, coffee-base-fit, coffee-base-insertion, drinks-base-fit, drinks-base-insertion, coffee-lid-fit, coffee-lid-insertion, drinks-lid-fit, drinks-lid-insertion]
explode_gap = 35; // mm, separation above each seated piece

/* [Coffee body] */
coffee_w = 136; // mm
coffee_d = 155; // mm
coffee_h = 110; // mm
coffee_wall = 2; // mm
coffee_floor = 2; // mm
coffee_tray_d = 30; // mm, front face of reservoir
coffee_tray_h = 22; // mm
coffee_ramp_back_y = 143; // mm
coffee_ramp_back_z = 22; // mm
coffee_outlet_side = 4; // mm
coffee_outlet_top = 32; // mm
coffee_outlet_round = 5; // mm, upper corners only
coffee_window_w = 60; // mm
coffee_window_h = 32; // mm
coffee_window_z = 56; // mm
coffee_label_border = 4; // mm, frame around the viewing opening
coffee_label_gap = 2; // mm, insert space behind the front wall
coffee_label_wall = 2; // mm

/* [Coffee lid] */
coffee_lid_plug_h = 4; // mm
coffee_lid_slop = 0.2; // mm per face
coffee_lid_cap_h = 4; // mm
coffee_lid_round = 4; // mm
coffee_stirrer_x = 42.132; // mm, cup axis at cap height
coffee_stirrer_y = 108.144; // mm
coffee_stirrer_w = 64.263; // mm, outside ellipse in an XY section
coffee_stirrer_d = 66.531; // mm
coffee_stirrer_inner_w = 61.407; // mm
coffee_stirrer_inner_d = 63.573; // mm
coffee_stirrer_lean = 0.20612; // mm forward per mm of height
coffee_stirrer_h = 145.661; // mm, highest rim point above plug bottom
coffee_filter_x = 76.263; // mm
coffee_filter_w = 52; // mm
coffee_filter_wall = 2; // mm
coffee_filter_front_y = 16; // mm, top of curved front
coffee_filter_back_y = 150; // mm
coffee_filter_top_z = 108.191; // mm
coffee_filter_curve_r = 155.402; // mm, measured circular front contour
coffee_filter_floor_front_z = 10.691; // mm
coffee_filter_floor_back_z = 75.691; // mm

/* [Drink body] */
drinks_lanes = 6;
drinks_lane_w = 24; // mm, nominal lane width; scales the measured lane grid
drinks_span_w = 157.784; // mm, measured body width at nominal lane width
drinks_wall = 2; // mm
drinks_d = 155; // mm
drinks_h = 150; // mm
drinks_floor = 2.5; // mm
drinks_front_y = 28; // mm, front face of reservoirs
drinks_front_thickness = 7; // mm
drinks_tray_h = 20; // mm
drinks_pickup_floor = 7.8; // mm, level floor through the tray and all six lanes
drinks_outlet_shoulder = 32.12; // mm
drinks_outlet_rise = 7; // mm, elliptical outlet crown
drinks_window_side = 2.5; // mm, lip within each lane
drinks_window_z = 50.5; // mm
drinks_window_rebate_y = 30.5; // mm
drinks_window_rebate_d = 2.5; // mm

/* [Drink lid] */
drinks_lid_slop = 0.5; // mm per face
drinks_lid_w = 158; // mm, measured cover width
drinks_lid_plug_h = 2; // mm
drinks_lid_plug_d = 117; // mm
drinks_lid_cap_h = 2; // mm
drinks_lid_ring_r = 22; // mm outside
drinks_lid_ring_wall = 2; // mm
drinks_lid_ring_h = 9; // mm
drinks_lid_ring_side = 23; // mm
drinks_lid_ring_front_y = 38; // mm relative to cover front
drinks_lid_ring_back_y = 95; // mm relative to cover front

/* [Baseplates] */
base_d = 165; // mm
base_h = 4; // mm
base_floor = 2; // mm
base_outer_margin = 4.8; // mm
base_seam_rim = 0.2; // mm, coffee rim at the joint
base_body_slop = 0.1; // mm per face
base_corner_r = 5; // mm, two outside corners
base_roof_round = 4; // mm, quarter-round outer edge
base_seam_gap = 0.2; // mm, assembled plate spacing
base_tail_centres = [34.053, 82.5, 132.5]; // mm from plate front
base_tail_mouth = 15; // mm
base_tail_head = 25; // mm
base_tail_depth = 5; // mm
base_first_tail_mouth = 15.4; // mm, measured first tooth
base_first_tail_depth = 4.8; // mm
base_socket_mouth = 16.366; // mm
base_socket_head = 25.966; // mm
base_socket_depth = 4.8; // mm

/* [Colors] */
coffee_body_color = "DarkOrange";
coffee_lid_color = "Gold";
coffee_base_color = "SteelBlue";
drinks_body_color = "MediumSeaGreen";
drinks_lid_color = "PaleGreen";
drinks_base_color = "MediumPurple";

/* [Resolution] */
$fn = 96;
curve_steps = 48;
eps = 0.01; // mm, Boolean cut overshoot

/* [Hidden] */
drinks_profile_scale = drinks_lane_w/24;
drinks_w = drinks_span_w * drinks_profile_scale;
// The archive's three middle partitions are 2.212..2.214 mm, and its
// middle chambers are 23.786..23.788 mm. Preserve that measured topology.
drinks_lane_starts = [1.996, 27.998, 53.998, 80, 105.998, 131.786];
drinks_lane_ends = [26, 51.786, 77.786, 103.786, 129.786, 155.788];
drinks_pitch = drinks_lane_w + drinks_wall;
coffee_base_w = coffee_w + 2 * base_body_slop + base_outer_margin + base_seam_rim;
drinks_base_w = drinks_lid_w + 2 * base_body_slop + 2 * base_outer_margin;
drinks_base_x = coffee_base_w + base_seam_gap;
body_y = (base_d - coffee_d) / 2;
body_x = base_outer_margin + base_body_slop;
drinks_body_x = body_x+(drinks_lid_w-drinks_w)/2;
coffee_cap_z = coffee_lid_plug_h + coffee_lid_cap_h;
drinks_cap_z = drinks_lid_plug_h + drinks_lid_cap_h;
// The archive plugs start at Y=30.5 and collide with the front wall.
// Y=35.5 places each 117 mm plug inside its 118 mm chamber.
drinks_lid_plug_y = drinks_front_y+drinks_front_thickness+drinks_lid_slop;
insertion_clear = 1; // mm beyond bounding-box separation

// Profile data below preserves the archive's rounded pickup lips and the
// stirrer cup's curved rim. Each contour is in mm; the remaining geometry
// is constructed from the dimensions above. These are contours, not meshes.

coffee_lip_profile = [
    [1.933, 22.0], [2.0, 22.0], [2.25, 21.986], [2.496, 21.943],
    [2.735, 21.872], [2.965, 21.775], [3.183, 21.652], [3.385, 21.505],
    [3.568, 21.335], [3.731, 21.146], [3.872, 20.94], [3.988, 20.718],
    [4.078, 20.485], [4.141, 20.243], [4.409, 18.894], [4.913, 17.408],
    [5.608, 16.0], [6.48, 14.695], [7.515, 13.515], [8.695, 12.48],
    [10.0, 11.608], [11.408, 10.913], [12.894, 10.409], [14.434, 10.103],
    [16.0, 10.0], [119.998, 10.0], [121.564, 10.103], [123.104, 10.409],
    [124.59, 10.913], [125.998, 11.608], [127.303, 12.48], [128.483, 13.515],
    [129.518, 14.695], [130.39, 16.0], [131.085, 17.408], [131.589, 18.894],
    [131.895, 20.434], [131.974, 20.654], [132.076, 20.865], [132.2, 21.063],
    [132.344, 21.248], [132.507, 21.416], [132.687, 21.565], [132.882, 21.695],
    [133.09, 21.803], [133.307, 21.889], [133.533, 21.95], [133.764, 21.988],
    [133.998, 22.0], [135.998, 22.0], [135.998, 0.0], [0.0, 0.0],
    [0.0, 22.0]
];
drinks_lip_profile = [
    [13.223, 12.192], [13.976, 12.169], [144.586, 12.169], [144.587, 12.192],
    [145.337, 12.263], [146.082, 12.381], [146.818, 12.546], [147.541, 12.756],
    [148.251, 13.011], [148.943, 13.311], [149.614, 13.653], [150.263, 14.037],
    [150.887, 14.46], [151.482, 14.922], [152.048, 15.421], [152.581, 15.954],
    [153.079, 16.519], [153.541, 17.115], [153.965, 17.739], [154.349, 18.387],
    [154.598, 18.876], [154.691, 19.04], [154.799, 19.195], [154.92, 19.339],
    [155.055, 19.471], [155.2, 19.591], [155.356, 19.697], [155.522, 19.788],
    [155.694, 19.863], [155.873, 19.923], [156.057, 19.966], [156.244, 19.991],
    [156.432, 20.0], [157.784, 20.0], [157.784, 0.0], [0.0, 0.0],
    [0.0, 20.0], [1.365, 20.0], [1.555, 19.991], [1.744, 19.965],
    [1.929, 19.922], [2.11, 19.862], [2.284, 19.786], [2.451, 19.694],
    [2.609, 19.587], [2.756, 19.466], [2.892, 19.332], [3.014, 19.186],
    [3.123, 19.03], [3.218, 18.865], [3.461, 18.387], [3.844, 17.739],
    [4.268, 17.115], [4.73, 16.519], [5.229, 15.954], [5.762, 15.421],
    [6.327, 14.922], [6.923, 14.46], [7.546, 14.037], [8.195, 13.653],
    [8.867, 13.311], [9.559, 13.011], [10.268, 12.756], [10.992, 12.546],
    [11.728, 12.381], [12.472, 12.263]
];
coffee_stirrer_rim = [
    [55.9, 100.08], [56.673, 101.501], [57.996, 103.806], [59.366, 106.064],
    [60.78, 108.275], [62.239, 110.437], [63.74, 112.549], [65.284, 114.609],
    [66.927, 116.686], [68.523, 118.601], [70.156, 120.464], [71.857, 122.303],
    [73.594, 124.083], [75.367, 125.804], [77.174, 127.464], [79.013, 129.062],
    [80.884, 130.596], [82.785, 132.067], [84.715, 133.472], [86.673, 134.811],
    [88.85, 136.198], [90.666, 137.287], [92.698, 138.422], [94.753, 139.487],
    [96.907, 140.518], [98.923, 141.407], [101.036, 142.26], [103.165, 143.041],
    [105.364, 143.765], [107.623, 144.424], [109.869, 144.996], [111.817, 145.431],
    [113.035, 145.661]
];

module extrude_y(depth) {
    translate([0, depth, 0]) rotate([90, 0, 0])
        linear_extrude(height = depth, convexity = 10) children();
}

module extrude_x(width) {
    multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
        linear_extrude(height = width, convexity = 10) children();
}

function arc(cx, cy, r, a, b, steps = curve_steps) = [for (i = [0:steps])
    [cx + r * cos(a + (b-a)*i/steps),
     cy + r * sin(a + (b-a)*i/steps)]];

module top_round_profile(w, h, r, left = true, right = true) {
    polygon(concat([[0, 0], [w, 0]],
        right ? arc(w-r, h-r, r, 0, 90) : [[w, h]],
        left ? arc(r, h-r, r, 90, 180) : [[0, h]]));
}

module top_round_box(w, d, h, r, left = true, right = true) {
    intersection() {
        extrude_y(d) top_round_profile(w, h, r, left, right);
        extrude_x(w) top_round_profile(d, h, r);
    }
}

module coffee_body() {
    color(coffee_body_color) union() {
        cube([coffee_w, coffee_d, coffee_floor]);
        // Sloping floor feeding the front pickup opening.
        extrude_x(coffee_w) polygon([
            [coffee_tray_d + coffee_wall, 0], [coffee_d, 0],
            [coffee_d, coffee_ramp_back_z],
            [coffee_ramp_back_y, coffee_ramp_back_z],
            [coffee_tray_d + coffee_wall, coffee_floor]]);
        difference() {
            translate([0, coffee_tray_d, 0])
                cube([coffee_w, coffee_d-coffee_tray_d, coffee_h]);
            translate([coffee_wall, coffee_tray_d+coffee_wall, -eps])
                cube([coffee_w-2*coffee_wall,
                    coffee_d-coffee_tray_d-2*coffee_wall, coffee_h+2*eps]);
            translate([coffee_outlet_side, coffee_tray_d-eps, coffee_floor])
                extrude_y(coffee_wall+2*eps)
                    top_round_profile(coffee_w-2*coffee_outlet_side,
                        coffee_outlet_top-coffee_floor, coffee_outlet_round);
            translate([(coffee_w-coffee_window_w)/2, coffee_tray_d-eps, coffee_window_z])
                cube([coffee_window_w, coffee_wall+2*eps, coffee_window_h]);
        }
        // Tray sides and the original scooped front lip.
        for (x = [0, coffee_w-coffee_wall])
            translate([x, 0, 0]) cube([coffee_wall, coffee_tray_d, coffee_tray_h]);
        extrude_y(coffee_wall)
            polygon([for (p = coffee_lip_profile) [p[0]*coffee_w/135.998, p[1]*coffee_tray_h/22]]);
        // Open-top label pocket behind the viewing opening.
        translate([(coffee_w-coffee_window_w)/2-coffee_label_border,
                coffee_tray_d+coffee_wall, coffee_window_z-coffee_label_border])
            difference() {
                cube([coffee_window_w+2*coffee_label_border,
                    coffee_label_gap+coffee_label_wall,
                    coffee_window_h+2*coffee_label_border]);
                translate([coffee_label_wall, -eps, coffee_label_wall])
                    cube([coffee_window_w+2*(coffee_label_border-coffee_label_wall),
                        coffee_label_gap+eps,
                        coffee_window_h+2*coffee_label_border]);
            }
    }
}

module coffee_filter_holder() {
    function front(z, radius) = [coffee_filter_front_y+coffee_filter_curve_r-
        sqrt(radius*radius-pow(coffee_filter_top_z-z, 2)), z];
    outer = concat([[coffee_filter_back_y, coffee_cap_z]],
        [for (i = [0:curve_steps]) front(coffee_cap_z+
            (coffee_filter_top_z-coffee_cap_z)*i/curve_steps, coffee_filter_curve_r)],
        [[coffee_filter_back_y, coffee_filter_top_z]]);
    inner = concat([for (i = [0:curve_steps]) front(coffee_filter_floor_front_z+
        (coffee_filter_top_z-coffee_filter_floor_front_z)*i/curve_steps,
        coffee_filter_curve_r-coffee_filter_wall)],
        [[coffee_filter_front_y+coffee_filter_wall, coffee_filter_top_z+eps],
         [coffee_filter_back_y-coffee_filter_wall, coffee_filter_top_z+eps],
         [coffee_filter_back_y-coffee_filter_wall, coffee_filter_floor_back_z]]);
    translate([coffee_filter_x, 0, 0]) difference() {
        extrude_x(coffee_filter_w) polygon(outer);
        translate([coffee_filter_wall, 0, 0])
            extrude_x(coffee_filter_w-2*coffee_filter_wall) polygon(inner);
    }
}

module coffee_stirrer_cup() {
    // Straight sheared elliptical tube, trimmed to the measured curved rim.
    intersection() {
        translate([coffee_stirrer_x, coffee_stirrer_y, coffee_cap_z-eps])
            multmatrix([[1, 0, 0, 0], [0, 1, -coffee_stirrer_lean, 0],
                [0, 0, 1, 0], [0, 0, 0, 1]])
                linear_extrude(height = coffee_stirrer_h, convexity = 10)
                    difference() {
                        scale([coffee_stirrer_w/2, coffee_stirrer_d/2]) circle(r = 1);
                        scale([coffee_stirrer_inner_w/2, coffee_stirrer_inner_d/2]) circle(r = 1);
                    }
        extrude_x(coffee_w) polygon(concat(
            [[-coffee_stirrer_h, -coffee_stirrer_h], [2*coffee_d, -coffee_stirrer_h],
             [2*coffee_d, coffee_stirrer_h]],
            [for (i = [len(coffee_stirrer_rim)-1:-1:0])
                [coffee_stirrer_rim[i][0], coffee_stirrer_rim[i][1]*coffee_stirrer_h/145.661]],
            [[-coffee_stirrer_h, -coffee_stirrer_h+eps]]));
    }
}

module coffee_lid() {
    color(coffee_lid_color) union() {
        translate([coffee_wall+coffee_lid_slop,
                coffee_tray_d+coffee_wall+coffee_lid_slop, 0])
            cube([coffee_w-2*(coffee_wall+coffee_lid_slop),
                coffee_d-coffee_tray_d-2*(coffee_wall+coffee_lid_slop), coffee_lid_plug_h+eps]);
        translate([0, coffee_tray_d, coffee_lid_plug_h])
            top_round_box(coffee_w, coffee_d-coffee_tray_d, coffee_lid_cap_h, coffee_lid_round);
        coffee_stirrer_cup();
        coffee_filter_holder();
    }
}

module drinks_outlet_profile(width) {
    polygon(concat([[-eps, drinks_floor], [width+eps, drinks_floor]],
        [for (i = [0:curve_steps])
            [width/2+(width/2+eps)*cos(180*i/curve_steps),
             drinks_outlet_shoulder+drinks_outlet_rise*sin(180*i/curve_steps)]]));
}

module drinks_body() {
    color(drinks_body_color) union() {
        cube([drinks_w, drinks_d, drinks_floor]);
        // One continuous plane avoids both the original slope and its front drop.
        translate([0, drinks_wall, 0])
            cube([drinks_w, drinks_d-drinks_wall, drinks_pickup_floor]);
        difference() {
            translate([0, drinks_front_y, 0])
                cube([drinks_w, drinks_d-drinks_front_y, drinks_h]);
            for (i = [0:drinks_lanes-1]) {
                x = drinks_lane_starts[i]*drinks_profile_scale;
                width = (drinks_lane_ends[i]-drinks_lane_starts[i])*drinks_profile_scale;
                translate([x, drinks_front_y+drinks_front_thickness, -eps])
                    cube([width, drinks_d-drinks_wall-drinks_front_y-drinks_front_thickness,
                        drinks_h+2*eps]);
                translate([x, drinks_front_y-eps, 0])
                    extrude_y(drinks_front_thickness+2*eps) drinks_outlet_profile(width);
                translate([x+drinks_window_side, drinks_front_y-eps, drinks_window_z])
                    // Open-top label channel, with the original 2 mm back.
                    cube([width-2*drinks_window_side,
                        drinks_window_rebate_y-drinks_front_y+eps,
                        drinks_h-drinks_window_z+eps]);
                translate([x, drinks_window_rebate_y, drinks_window_z])
                    cube([width, drinks_window_rebate_d, drinks_h-drinks_window_z+eps]);
            }
        }
        for (x = [0, drinks_w-drinks_wall])
            translate([x, 0, 0]) cube([drinks_wall, drinks_front_y, drinks_tray_h]);
        extrude_y(drinks_wall)
            polygon([for (p = drinks_lip_profile) [p[0]*drinks_profile_scale, p[1]*(drinks_tray_h/20)]]);
    }
}

module drinks_ring_quarter(cx, cy, sx, sy) {
    translate([cx, cy, drinks_cap_z-eps])
        linear_extrude(height = drinks_lid_ring_h+eps, convexity = 10)
            intersection() {
                difference() {
                    circle(r = drinks_lid_ring_r);
                    circle(r = drinks_lid_ring_r-drinks_lid_ring_wall);
                }
                translate([sx < 0 ? -drinks_lid_ring_r : 0,
                    sy < 0 ? -drinks_lid_ring_r : 0])
                    square([drinks_lid_ring_r, drinks_lid_ring_r]);
            }
}

module drinks_lid() {
    color(drinks_lid_color) union() {
        translate([0, drinks_front_y, drinks_lid_plug_h])
            cube([drinks_lid_w, drinks_d-drinks_front_y, drinks_lid_cap_h]);
        for (i = [0:drinks_lanes-1])
            translate([drinks_wall+i*drinks_pitch+drinks_lid_slop,
                drinks_lid_plug_y, 0])
                cube([drinks_lane_w-2*drinks_lid_slop, drinks_lid_plug_d, drinks_lid_plug_h+eps]);
        for (side = [-1, 1], end = [-1, 1])
            drinks_ring_quarter(side < 0 ? drinks_lid_ring_side : drinks_lid_w-drinks_lid_ring_side,
                drinks_front_y+(end < 0 ? drinks_lid_ring_front_y : drinks_lid_ring_back_y), side, end);
    }
}

module base_outer_plan(w, outside_right) {
    r = base_corner_r;
    // Avoid a corner vertex coincident with the two roof fillets' seam.
    steps = curve_steps+1;
    polygon(outside_right ? concat([[0, 0], [w-r, 0]],
        arc(w-r, r, r, -90, 0, steps), arc(w-r, base_d-r, r, 0, 90, steps), [[0, base_d]]) :
        concat([[w, 0], [w, base_d]], arc(r, base_d-r, r, 90, 180, steps), arc(r, r, r, 180, 270, steps)));
}

module base_tray(w, outside_right, well_right) {
    difference() {
        intersection() {
            linear_extrude(height = base_h, convexity = 10) base_outer_plan(w, outside_right);
            top_round_box(w, base_d, base_h, base_roof_round,
                left = !outside_right, right = outside_right);
        }
        translate([base_outer_margin, base_outer_margin, base_floor])
            cube([well_right-base_outer_margin, base_d-2*base_outer_margin, base_h-base_floor+eps]);
    }
}

module coffee_base() {
    color(coffee_base_color) union() {
        base_tray(coffee_base_w, false, coffee_base_w-base_seam_rim);
        for (i = [0:len(base_tail_centres)-1]) {
            mouth = i == 0 ? base_first_tail_mouth : base_tail_mouth;
            depth = i == 0 ? base_first_tail_depth : base_tail_depth;
            translate([coffee_base_w-eps, base_tail_centres[i], 0])
                linear_extrude(height = base_h, convexity = 10)
                    polygon([[0, -mouth/2], [depth+eps, -base_tail_head/2],
                        [depth+eps, base_tail_head/2], [0, mouth/2]]);
        }
    }
}

module drinks_base() {
    color(drinks_base_color) difference() {
        base_tray(drinks_base_w, true, drinks_base_w-base_outer_margin);
        for (y = base_tail_centres)
            translate([0, y, -eps]) linear_extrude(height = base_h+2*eps, convexity = 10)
                polygon([[-eps, -base_socket_mouth/2-eps],
                    [base_socket_depth+eps, -base_socket_head/2],
                    [base_socket_depth+eps, base_socket_head/2], [-eps, base_socket_mouth/2+eps]]);
    }
}

module positioned_body(which) {
    translate([which == "coffee" ? body_x : drinks_body_x+drinks_base_x, body_y, base_floor])
        if (which == "coffee") coffee_body(); else drinks_body();
}

module positioned_lid(which) {
    translate([body_x+(which == "coffee" ? 0 : drinks_base_x), body_y,
        base_floor+(which == "coffee" ? coffee_h-coffee_lid_plug_h : drinks_h-drinks_lid_plug_h)])
        if (which == "coffee") coffee_lid(); else drinks_lid();
}

module base_pair() {
    coffee_base();
    translate([drinks_base_x, 0, 0]) drinks_base();
}

module station(exploded = false) {
    base_pair();
    for (which = ["coffee", "drinks"]) {
        translate([0, 0, exploded ? explode_gap : 0]) positioned_body(which);
        translate([0, 0, exploded ? 2*explode_gap : 0]) positioned_lid(which);
    }
}

module vertical_sweep(distance) {
    // All mates enter vertically. Union of the two endpoints' convex hull
    // is exact for each convex component; sweep children after decomposition.
    hull() {
        children();
        translate([0, 0, distance]) children();
    }
}

module fit_check(which, insertion = false) {
    if (which == "base") intersection() {
        translate([drinks_base_x, 0, 0]) drinks_base();
        if (insertion) {
            // The tray body is to the left of the mating plate throughout;
            // only the three convex teeth enter it.
            for (i = [0:len(base_tail_centres)-1]) {
                mouth = i == 0 ? base_first_tail_mouth : base_tail_mouth;
                depth = i == 0 ? base_first_tail_depth : base_tail_depth;
                vertical_sweep(base_h+insertion_clear)
                    translate([coffee_base_w-eps, base_tail_centres[i], 0])
                        linear_extrude(height = base_h)
                            polygon([[0, -mouth/2], [depth+eps, -base_tail_head/2],
                                [depth+eps, base_tail_head/2], [0, mouth/2]]);
            }
        } else coffee_base();
    }
    else {
        coffee = which == "coffee";
        lid = which == "coffee-lid" || which == "drinks-lid";
        side = which == "coffee-lid" || coffee ? "coffee" : "drinks";
        if (lid) intersection() {
            positioned_body(side);
            if (insertion) {
                // Only lid plugs enter the body; everything above the cap
                // starts and remains above the reservoir's top plane.
                translate([body_x+(side == "coffee" ? 0 : drinks_base_x), body_y,
                    base_floor+(side == "coffee" ? coffee_h-coffee_lid_plug_h : drinks_h-drinks_lid_plug_h)])
                    if (side == "coffee")
                        vertical_sweep(coffee_lid_plug_h+insertion_clear)
                            translate([coffee_wall+coffee_lid_slop, coffee_tray_d+coffee_wall+coffee_lid_slop, 0])
                                cube([coffee_w-2*(coffee_wall+coffee_lid_slop),
                                    coffee_d-coffee_tray_d-2*(coffee_wall+coffee_lid_slop), coffee_lid_plug_h]);
                    else for (i = [0:drinks_lanes-1])
                        vertical_sweep(drinks_lid_plug_h+insertion_clear)
                            translate([drinks_wall+i*drinks_pitch+drinks_lid_slop, drinks_lid_plug_y, 0])
                                cube([drinks_lane_w-2*drinks_lid_slop, drinks_lid_plug_d, drinks_lid_plug_h]);
            } else positioned_lid(side);
        }
        else intersection() {
            if (side == "coffee") coffee_base();
            else translate([drinks_base_x, 0, 0]) drinks_base();
            // The convex outside envelope proves clearance of every body
            // wall and floor throughout the whole drop into its tray.
            translate([side == "coffee" ? body_x : drinks_body_x+drinks_base_x, body_y, base_floor])
                cube([side == "coffee" ? coffee_w : drinks_w,
                    side == "coffee" ? coffee_d : drinks_d,
                    (side == "coffee" ? coffee_h : drinks_h)+(insertion ? base_h+insertion_clear : 0)]);
        }
    }
}

module beverage_station() {
    assert(drinks_lanes == len(base_tail_centres)*2, "Rev-02 uses six drink lanes and three base teeth");
    if (show == "assembled") station();
    else if (show == "exploded") station(true);
    else if (show == "coffee-body") coffee_body();
    else if (show == "coffee-lid") coffee_lid();
    else if (show == "coffee-base") coffee_base();
    else if (show == "drinks-body") drinks_body();
    else if (show == "drinks-lid") drinks_lid();
    else if (show == "drinks-base") drinks_base();
    else if (show == "base-fit") fit_check("base");
    else if (show == "base-insertion") fit_check("base", true);
    else if (show == "coffee-base-fit") fit_check("coffee");
    else if (show == "coffee-base-insertion") fit_check("coffee", true);
    else if (show == "drinks-base-fit") fit_check("drinks");
    else if (show == "drinks-base-insertion") fit_check("drinks", true);
    else if (show == "coffee-lid-fit") fit_check("coffee-lid");
    else if (show == "coffee-lid-insertion") fit_check("coffee-lid", true);
    else if (show == "drinks-lid-fit") fit_check("drinks-lid");
    else if (show == "drinks-lid-insertion") fit_check("drinks-lid", true);
    else assert(false, str("Unknown show: ", show));
}



// Assembly display changes placement only; the original output remains the default.
module feral_default_output_0052e1c1606e() {
beverage_station();
}

module feral_assembly_view_0052e1c1606e(explode=false) {
station(explode);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_0052e1c1606e();
else feral_assembly_view_0052e1c1606e(view == "exploded");
