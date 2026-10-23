// Note 1.

/* [View] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

show = "drinks-body"; // [assembled, exploded, coffee-body, coffee-lid, coffee-base, drinks-body, drinks-lid, drinks-base, base-fit, base-insertion, coffee-base-fit, coffee-base-insertion, drinks-base-fit, drinks-base-insertion, coffee-lid-fit, coffee-lid-insertion, drinks-lid-fit, drinks-lid-insertion]
explode_gap = 35; // Note 3.

/* [Coffee body] */
coffee_w = 136; // Note 4.
coffee_d = 155; // Note 5.
coffee_h = 110; // Note 6.
coffee_wall = 2; // Note 7.
coffee_floor = 2; // Note 8.
coffee_tray_d = 30; // Note 9.
coffee_tray_h = 22; // Note 10.
coffee_ramp_back_y = 143; // Note 11.
coffee_ramp_back_z = 22; // Note 12.
coffee_outlet_side = 4; // Note 13.
coffee_outlet_top = 32; // Note 14.
coffee_outlet_round = 5; // Note 15.
coffee_window_w = 60; // Note 16.
coffee_window_h = 32; // Note 17.
coffee_window_z = 56; // Note 18.
coffee_label_border = 4; // Note 19.
coffee_label_gap = 2; // Note 20.
coffee_label_wall = 2; // Note 21.

/* [Coffee lid] */
coffee_lid_plug_h = 4; // Note 22.
coffee_lid_slop = 0.2; // Note 23.
coffee_lid_cap_h = 4; // Note 24.
coffee_lid_round = 4; // Note 25.
coffee_stirrer_x = 42.132; // Note 26.
coffee_stirrer_y = 108.144; // Note 27.
coffee_stirrer_w = 64.263; // Note 28.
coffee_stirrer_d = 66.531; // Note 29.
coffee_stirrer_inner_w = 61.407; // Note 30.
coffee_stirrer_inner_d = 63.573; // Note 31.
coffee_stirrer_lean = 0.20612; // Note 32.
coffee_stirrer_h = 145.661; // Note 33.
coffee_filter_x = 76.263; // Note 34.
coffee_filter_w = 52; // Note 35.
coffee_filter_wall = 2; // Note 36.
coffee_filter_front_y = 16; // Note 37.
coffee_filter_back_y = 150; // Note 38.
coffee_filter_top_z = 108.191; // Note 39.
coffee_filter_curve_r = 155.402; // Note 40.
coffee_filter_floor_front_z = 10.691; // Note 41.
coffee_filter_floor_back_z = 75.691; // Note 42.

/* [Drink body] */
drinks_lanes = 6;
drinks_lane_w = 24; // Note 43.
drinks_span_w = 157.784; // Note 44.
drinks_wall = 2; // Note 45.
drinks_d = 155; // Note 46.
drinks_h = 150; // Note 47.
drinks_floor = 2.5; // Note 48.
drinks_front_y = 28; // Note 49.
drinks_front_thickness = 7; // Note 50.
drinks_tray_h = 20; // Note 51.
drinks_pickup_floor = 7.8; // Note 52.
drinks_outlet_shoulder = 32.12; // Note 53.
drinks_outlet_rise = 7; // Note 54.
drinks_window_side = 2.5; // Note 55.
drinks_window_z = 50.5; // Note 56.
drinks_window_rebate_y = 30.5; // Note 57.
drinks_window_rebate_d = 2.5; // Note 58.

/* [Drink lid] */
drinks_lid_slop = 0.5; // Note 59.
drinks_lid_w = 158; // Note 60.
drinks_lid_plug_h = 2; // Note 61.
drinks_lid_plug_d = 117; // Note 62.
drinks_lid_cap_h = 2; // Note 63.
drinks_lid_ring_r = 22; // Note 64.
drinks_lid_ring_wall = 2; // Note 65.
drinks_lid_ring_h = 9; // Note 66.
drinks_lid_ring_side = 23; // Note 67.
drinks_lid_ring_front_y = 38; // Note 68.
drinks_lid_ring_back_y = 95; // Note 69.

/* [Baseplates] */
base_d = 165; // Note 70.
base_h = 4; // Note 71.
base_floor = 2; // Note 72.
base_outer_margin = 4.8; // Note 73.
base_seam_rim = 0.2; // Note 74.
base_body_slop = 0.1; // Note 75.
base_corner_r = 5; // Note 76.
base_roof_round = 4; // Note 77.
base_seam_gap = 0.2; // Note 78.
base_tail_centres = [34.053, 82.5, 132.5]; // Note 79.
base_tail_mouth = 15; // Note 80.
base_tail_head = 25; // Note 81.
base_tail_depth = 5; // Note 82.
base_first_tail_mouth = 15.4; // Note 83.
base_first_tail_depth = 4.8; // Note 84.
base_socket_mouth = 16.366; // Note 85.
base_socket_head = 25.966; // Note 86.
base_socket_depth = 4.8; // Note 87.

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
eps = 0.01; // Note 88.

/* [Hidden] */
drinks_profile_scale = drinks_lane_w/24;
drinks_w = drinks_span_w * drinks_profile_scale;
// Note 89.

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
// Note 90.

drinks_lid_plug_y = drinks_front_y+drinks_front_thickness+drinks_lid_slop;
insertion_clear = 1; // Note 91.

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
        // Note 92.
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
        // Note 93.
        for (x = [0, coffee_w-coffee_wall])
            translate([x, 0, 0]) cube([coffee_wall, coffee_tray_d, coffee_tray_h]);
        extrude_y(coffee_wall)
            polygon([for (p = coffee_lip_profile) [p[0]*coffee_w/135.998, p[1]*coffee_tray_h/22]]);
        // Note 94.
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
    // Note 95.
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
        // Note 96.
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
                    // Note 97.
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
    // Note 98.
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
    // Note 99.

    hull() {
        children();
        translate([0, 0, distance]) children();
    }
}

module fit_check(which, insertion = false) {
    if (which == "base") intersection() {
        translate([drinks_base_x, 0, 0]) drinks_base();
        if (insertion) {
            // Note 100.

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
                // Note 101.

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
            // Note 102.

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

// Note 103.
module feral_default_output_0052e1c1606e() {
beverage_station();
}

module feral_assembly_view_0052e1c1606e(explode=false) {
station(explode);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_0052e1c1606e();
else feral_assembly_view_0052e1c1606e(view == "exploded");

// Notes

// Note 1. Rev-02 beverage station, reconstructed from sketchup/kitchen.
// Drink-body revision: level packet floors continuous with the pickup tray.
// Six independent pieces; the baseplate filenames in the archive are swapped.
// Coffee is on the left, drinks on the right; front is -Y and the bed is Z=0.
// Dimensions are mm. No archived mesh is needed to render or build this file.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, separation above each seated piece

// Note 4. mm

// Note 5. mm

// Note 6. mm

// Note 7. mm

// Note 8. mm

// Note 9. mm, front face of reservoir

// Note 10. mm

// Note 11. mm

// Note 12. mm

// Note 13. mm

// Note 14. mm

// Note 15. mm, upper corners only

// Note 16. mm

// Note 17. mm

// Note 18. mm

// Note 19. mm, frame around the viewing opening

// Note 20. mm, insert space behind the front wall

// Note 21. mm

// Note 22. mm

// Note 23. mm per face

// Note 24. mm

// Note 25. mm

// Note 26. mm, cup axis at cap height

// Note 27. mm

// Note 28. mm, outside ellipse in an XY section

// Note 29. mm

// Note 30. mm

// Note 31. mm

// Note 32. mm forward per mm of height

// Note 33. mm, highest rim point above plug bottom

// Note 34. mm

// Note 35. mm

// Note 36. mm

// Note 37. mm, top of curved front

// Note 38. mm

// Note 39. mm

// Note 40. mm, measured circular front contour

// Note 41. mm

// Note 42. mm

// Note 43. mm, nominal lane width; scales the measured lane grid

// Note 44. mm, measured body width at nominal lane width

// Note 45. mm

// Note 46. mm

// Note 47. mm

// Note 48. mm

// Note 49. mm, front face of reservoirs

// Note 50. mm

// Note 51. mm

// Note 52. mm, level floor through the tray and all six lanes

// Note 53. mm

// Note 54. mm, elliptical outlet crown

// Note 55. mm, lip within each lane

// Note 56. mm

// Note 57. mm

// Note 58. mm

// Note 59. mm per face

// Note 60. mm, measured cover width

// Note 61. mm

// Note 62. mm

// Note 63. mm

// Note 64. mm outside

// Note 65. mm

// Note 66. mm

// Note 67. mm

// Note 68. mm relative to cover front

// Note 69. mm relative to cover front

// Note 70. mm

// Note 71. mm

// Note 72. mm

// Note 73. mm

// Note 74. mm, coffee rim at the joint

// Note 75. mm per face

// Note 76. mm, two outside corners

// Note 77. mm, quarter-round outer edge

// Note 78. mm, assembled plate spacing

// Note 79. mm from plate front

// Note 80. mm

// Note 81. mm

// Note 82. mm

// Note 83. mm, measured first tooth

// Note 84. mm

// Note 85. mm

// Note 86. mm

// Note 87. mm

// Note 88. mm, Boolean cut overshoot

// Note 89. The archive's three middle partitions are 2.212..2.214 mm, and its
// middle chambers are 23.786..23.788 mm. Preserve that measured topology.

// Note 90. The archive plugs start at Y=30.5 and collide with the front wall.
// Y=35.5 places each 117 mm plug inside its 118 mm chamber.

// Note 91. mm beyond bounding-box separation
// Profile data below preserves the archive's rounded pickup lips and the
// stirrer cup's curved rim. Each contour is in mm; the remaining geometry
// is constructed from the dimensions above. These are contours, not meshes.

// Note 92. Sloping floor feeding the front pickup opening.

// Note 93. Tray sides and the original scooped front lip.

// Note 94. Open-top label pocket behind the viewing opening.

// Note 95. Straight sheared elliptical tube, trimmed to the measured curved rim.

// Note 96. One continuous plane avoids both the original slope and its front drop.

// Note 97. Open-top label channel, with the original 2 mm back.

// Note 98. Avoid a corner vertex coincident with the two roof fillets' seam.

// Note 99. All mates enter vertically. Union of the two endpoints' convex hull
// is exact for each convex component; sweep children after decomposition.

// Note 100. The tray body is to the left of the mating plate throughout;
// only the three convex teeth enter it.

// Note 101. Only lid plugs enter the body; everything above the cap
// starts and remains above the reservoir's top plane.

// Note 102. The convex outside envelope proves clearance of every body
// wall and floor throughout the whole drop into its tray.

// Note 103. Assembly display changes placement only; the original output remains the default.
