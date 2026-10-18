// A leaping cat that chases the cup-magnet bats: three times their span, 800 mm
// nose to tail, so it prints as seven flat pieces glued with hidden dovetails.
// Each piece prints decorative face down. Only the belly carries a magnet, at the
// whole cat's centre of mass, enclosed exactly as on the bats (pause and insert).
//
// At a seam the front band butts on a straight line, so the front shows only that
// line. Above it each tab rides a 45° ramp that climbs into the neighbouring piece:
// the ramp hides the dovetail, adds sloped glue face, and is the steepest overhang
// either piece has face down, so nothing needs support. Every joint assembles
// straight down onto the face-down neighbour, so pieces can be glued in any order.
//
// The outline comes from bat-cat.svg via utils/svg2bez.py --width 800. The seams,
// tab roots, selection regions and print rotations below were placed for that size
// and checked outside OpenSCAD (pieces cover the cat exactly, every tab sits 2.5 mm
// inside the outline, every printed piece fits 200 mm square). Do not rescale.

include <../../../../lib/BOSL2/std.scad>
include <../../../../lib/BOSL2/beziers.scad>

/* [Cat] */
plate_h = 2.1;             // mm, decorative plate, same as the bats
land_h = 6.6;              // mm, rear land over each seam; 8.7 mm total there
land_half_w = 18;          // mm, land either side of a seam
land_inset = 2;            // mm, land stays this far inside the silhouette

/* [Dovetail] */
tab_root = 14;             // mm, tab width at the seam
tab_tip = 20;              // mm, tab width at its end
tab_depth = 6;             // mm, how far a tab reaches into its neighbour
seam_front_h = 1.2;        // mm, front band that butts on the straight visible seam
tab_tip_min = 1.5;         // mm, least tab thickness, at its end above the ramp
tab_clearance = 0.2;       // mm per face, glue room; the proven wire-shelf dovetail value

/* [Cup magnet] */
magnet_d = 51.7;           // mm, measured steel cup outside diameter
magnet_h = 10.75;          // mm, measured complete cup thickness
pocket_diameter_extra = 0.3; // mm, nominal 0.15 mm clearance per side
pocket_depth_extra = 0.29; // mm, extra depth above the seated magnet
housing_wall = 2.1;        // mm, radial plastic around the pocket
roof_h = 0.84;             // mm, solid rear cover over the magnet's working face

/* [Colors] */
tail_color = "Goldenrod";     // preview only; STLs carry no colour
hind_leg_color = "DarkOliveGreen";
rump_color = "SteelBlue";
belly_color = "SlateGray";
chest_color = "Sienna";
head_color = "IndianRed";
forelegs_color = "Teal";
magnet_color = "Silver";

/* [Output] */
show = "assembled"; // [assembled, exploded, piece, coupon, joint-section, section, before-cap]
piece = "belly"; // [tail, hind-leg, rump, belly, chest, head, forelegs]
explode = 30;              // mm, gap added between pieces in the exploded view

/* [Hidden] */
$fn = 128;
eps = 0.01;
pocket_d = magnet_d + pocket_diameter_extra;
pocket_h = magnet_h + pocket_depth_extra;
roof_z = plate_h + pocket_h;
part_h = roof_z + roof_h;
housing_d = pocket_d + 2 * housing_wall;
bore_factor = 1 / cos(180 / $fn);

// bat-cat.svg: 166 points, 55 cubics, 800.000 x 519.863 mm, y up. bezpath_curve(BEZ, splinesteps = 24)
CAT_BEZ = [
    [787.985, 298.038],
    [764.733, 296.351], [737.301, 297.896], [711.283, 301.740],
    [735.762, 326.940], [779.378, 302.239], [783.114, 325.450],
    [784.187, 332.122], [774.091, 344.645], [767.541, 344.447],
    [752.248, 343.985], [736.954, 343.522], [721.661, 343.059],
    [698.249, 336.113], [674.836, 329.167], [651.424, 322.220],
    [649.203, 331.402], [646.982, 340.584], [644.761, 349.767],
    [643.517, 354.907], [646.033, 363.552], [650.593, 368.109],
    [650.531, 368.180], [650.481, 368.260], [650.421, 368.332],
    [663.659, 386.747], [678.927, 403.763], [697.468, 416.811],
    [702.721, 421.665], [707.975, 426.519], [713.228, 431.373],
    [715.365, 433.347], [716.775, 434.536], [717.070, 437.242],
    [718.556, 450.833], [716.206, 465.920], [701.986, 467.813],
    [695.788, 468.638], [686.262, 470.358], [684.554, 476.236],
    [683.290, 480.587], [680.360, 483.283], [676.646, 485.496],
    [657.365, 496.988], [645.027, 484.237], [632.256, 493.038],
    [630.826, 498.161], [629.396, 503.284], [627.966, 508.407],
    [626.890, 512.260], [624.791, 518.490], [621.148, 519.829],
    [616.565, 520.351], [615.191, 514.637], [614.762, 511.466],
    [614.048, 506.186], [613.334, 500.905], [612.620, 495.625],
    [611.340, 486.157], [606.608, 477.673], [601.152, 469.862],
    [596.833, 463.678], [592.514, 457.495], [588.195, 451.311],
    [585.749, 447.810], [583.655, 443.931], [581.851, 439.787],
    [573.006, 433.260], [564.160, 426.732], [555.315, 420.205],
    [530.793, 403.766], [506.271, 387.326], [481.748, 370.887],
    [420.319, 329.705], [305.795, 320.752], [210.309, 264.931],
    [190.011, 248.234], [169.459, 231.791], [149.526, 214.670],
    [141.619, 207.879], [132.134, 203.280], [122.825, 198.758],
    [104.351, 189.784], [ 85.410, 180.736], [ 64.478, 181.715],
    [ 42.960, 182.721], [ 21.132, 189.515], [  0.083, 181.695],
    [ -1.046, 181.276], [  9.701, 168.530], [ 10.786, 167.586],
    [ 15.698, 163.310], [ 21.404, 160.180], [ 27.414, 157.725],
    [ 40.220, 152.493], [ 54.195, 150.624], [ 67.952, 150.479],
    [100.974, 150.131], [133.205, 158.593], [159.364, 179.623],
    [181.698, 196.347], [204.032, 213.071], [226.367, 229.794],
    [225.266, 217.261], [224.165, 204.729], [223.064, 192.196],
    [219.470, 151.276], [179.227, 148.100], [171.982, 133.247],
    [171.982, 133.247], [130.547,  48.291], [130.521,  48.237],
    [128.803,  44.715], [129.345,  37.048], [131.682,  33.854],
    [134.604,  29.859], [148.133,  33.316], [152.669,  33.681],
    [152.669,  33.681], [146.588,  16.993], [146.588,  16.993],
    [144.890,  12.330], [151.303,   4.789], [153.678,   1.194],
    [153.967,   0.757], [154.286,   0.295], [154.773,   0.102],
    [155.260,  -0.091], [155.808,   0.027], [156.316,   0.155],
    [171.425,   3.977], [179.270,  14.562], [184.485,  28.584],
    [187.283,  36.107], [189.508,  43.829], [192.454,  51.299],
    [194.739,  57.096], [199.491,  72.193], [205.273,  75.207],
    [238.396,  92.473], [270.710, 103.399], [302.471, 123.417],
    [324.331, 137.194], [337.558, 178.473], [387.337, 188.169],
    [412.758, 193.121], [438.178, 198.072], [463.599, 203.024],
    [482.272, 211.161], [500.945, 219.298], [519.619, 227.436],
    [542.768, 237.523], [563.186, 260.193], [590.174, 260.918],
    [604.556, 261.305], [624.645, 251.731], [639.769, 253.603],
    [672.828, 257.697], [705.887, 261.791], [738.947, 265.885],
    [749.835, 267.233], [795.244, 262.467], [799.952, 286.442],
    [800.721, 290.358], [792.159, 298.341], [787.985, 298.038],
];

// [name, print rotation, print centre after that rotation, region that selects the piece from the outline]
cat_pieces = [
    ["tail", 27, [7.3, 242.59],
        [[125.27, 155.86], [101.25, 149.27], [66.15, 146.51], [50.2, 147.71], [34.43, 151.04], [21.23, 156.1], [10.89, 162.35], [-3.85, 180.29], [-2.44, 185.06], [12.84, 188.83], [29.65, 189.19], [71.97, 185.79], [86.26, 188.18], [102.6, 193.83], [142.09, 213.96], [210.39, 270.18], [211.95, 266.97], [208.4, 265.25], [208.87, 264.27], [208.76, 264.15], [208.71, 264.05], [208.69, 263.9], [208.72, 263.79], [208.74, 263.74], [209.05, 263.9], [225.81, 229.38], [225.5, 229.23], [225.65, 229.07], [225.76, 229.02], [225.9, 229.01], [225.47, 224.17], [147.87, 166.71]]],
    ["hind-leg", 73.5, [-27.1, 206.69],
        [[129.4, 30.42], [125.77, 39], [126.89, 49.92], [169.77, 137.35], [177.93, 144.77], [201.98, 160.22], [213.15, 172.53], [215.26, 169.61], [214.86, 168.98], [212.22, 167.08], [212.86, 166.2], [212.74, 165.96], [212.74, 165.85], [212.79, 165.7], [212.82, 165.65], [213.1, 165.86], [260.07, 100.9], [259.79, 100.7], [259.88, 100.6], [260.02, 100.54], [260.17, 100.53], [260.31, 100.57], [260.95, 99.69], [264.15, 102], [266.11, 99.3], [206.03, 70.77], [200.18, 60.3], [184.38, 18.44], [177.05, 7.83], [168.4, 0.8], [156.32, -3.93], [150.9, -1.79], [144.68, 7.52], [142.38, 13.97], [146.45, 28.72], [136.16, 28.01]]],
    ["rump", 69.5, [-92.07, 346.42],
        [[336.61, 318.27], [336.93, 317.22], [336.81, 317.13], [336.73, 317], [336.7, 316.85], [336.71, 316.74], [337.05, 316.84], [376.85, 185.48], [376.52, 185.38], [376.57, 185.28], [376.68, 185.17], [376.82, 185.11], [376.97, 185.1], [377.29, 184.05], [381.07, 185.19], [381.8, 182.77], [367.01, 177.35], [350.56, 167], [307.56, 122.07], [288.46, 110.58], [258.81, 95.9], [257.75, 97.37], [260.95, 99.69], [260.3, 100.59], [260.39, 100.71], [260.42, 100.82], [260.41, 100.97], [260.35, 101.11], [260.07, 100.9], [213.1, 165.86], [213.38, 166.06], [213.37, 166.08], [213.28, 166.16], [213.13, 166.21], [213.02, 166.21], [212.88, 166.17], [212.22, 167.08], [209.02, 164.76], [208.15, 165.96], [213.21, 173.09], [217.57, 183.74], [222.01, 225.86], [226.47, 228.03], [225.99, 229.01], [226.1, 229.11], [226.16, 229.26], [226.17, 229.41], [226.13, 229.53], [225.81, 229.38], [209.05, 263.9], [209.36, 264.05], [209.35, 264.07], [209.24, 264.19], [209.14, 264.24], [209.02, 264.26], [208.88, 264.24], [208.4, 265.25], [204.84, 263.52], [204.11, 265.02], [220.44, 275.19], [270.34, 298.15], [339.67, 321.82], [340.39, 319.42]]],
    ["belly", 59, [-12.26, 505.18],
        [[374.23, 180.54], [373.51, 182.9], [377.29, 184.05], [376.97, 185.1], [377.09, 185.19], [377.17, 185.32], [377.2, 185.43], [377.19, 185.59], [376.85, 185.48], [337.05, 316.84], [337.38, 316.94], [337.31, 317.08], [337.22, 317.15], [337.08, 317.21], [336.93, 317.22], [336.61, 318.27], [332.83, 317.13], [332.11, 319.51], [425.49, 348.57], [454.67, 360.42], [472.22, 369.6], [473.44, 367.6], [470.06, 365.55], [470.63, 364.6], [470.54, 364.5], [470.49, 364.35], [470.49, 364.23], [470.54, 364.08], [470.84, 364.26], [544.88, 242.19], [544.58, 242.01], [544.69, 241.9], [544.8, 241.84], [544.96, 241.82], [545.09, 241.86], [545.66, 240.91], [549.04, 242.96], [550.26, 240.94], [524.24, 225.16], [464.79, 199.18]]],
    ["chest", 75.5, [-166.98, 630.51],
        [[566.78, 250.56], [543.65, 236.61], [542.28, 238.86], [545.66, 240.91], [545.09, 241.85], [545.17, 241.94], [545.23, 242.08], [545.24, 242.23], [545.18, 242.37], [544.88, 242.19], [470.84, 364.26], [471.14, 364.45], [471.04, 364.56], [470.9, 364.63], [470.75, 364.64], [470.63, 364.61], [470.06, 365.55], [466.68, 363.5], [465.3, 365.77], [515.94, 398.63], [515.1, 394.72], [516.17, 394.32], [516.16, 394.18], [516.19, 394.06], [516.28, 393.93], [516.38, 393.86], [516.51, 394.19], [645.9, 345.04], [645.78, 344.71], [645.9, 344.7], [646.06, 344.73], [646.16, 344.79], [646.24, 344.91], [647.31, 344.5], [649.31, 347.97], [654.32, 327.25], [659.17, 328.69], [659.7, 325.77], [655.81, 325.08], [656, 323.99], [655.87, 323.92], [655.77, 323.81], [655.73, 323.7], [655.73, 323.54], [656.07, 323.6], [667.98, 257.1], [667.64, 257.04], [667.65, 256.99], [667.7, 256.88], [667.81, 256.77], [667.92, 256.72], [668.05, 256.7], [668.25, 255.62], [672.14, 256.32], [672.61, 253.64], [633.73, 249.4], [597.22, 256.42], [584.19, 256.35]]],
    ["head", 24, [394.56, 644.56],
        [[604.35, 482.84], [608.08, 493.01], [611.8, 516.44], [614.74, 521.45], [618.66, 523.65], [624.13, 522.8], [628.38, 518.17], [635.69, 495.61], [642.15, 493.76], [663.92, 494.25], [676.09, 490.37], [684.05, 484.82], [690.54, 475.04], [706.54, 470.88], [713.16, 467.18], [717.66, 461.58], [720.23, 454.93], [721.35, 440.43], [719.05, 431.65], [676.78, 393.82], [651.44, 362.71], [648.45, 352.62], [651.56, 338.66], [647.48, 340.21], [646.78, 343.12], [647.31, 344.5], [646.36, 344.86], [646.26, 345.18], [646.16, 345.29], [646.06, 345.35], [646.03, 345.36], [645.9, 345.04], [516.51, 394.19], [516.63, 394.51], [516.6, 394.53], [516.45, 394.55], [516.33, 394.54], [516.05, 394.36], [515.1, 394.72], [514.6, 393.39], [512.02, 391.66], [507.9, 393.23], [578.62, 442.38]]],
    ["forelegs", 42.5, [332, 707.88],
        [[789.91, 301.87], [800.03, 295.23], [803.35, 290.15], [803.9, 285.71], [801.47, 279.06], [797.32, 273.79], [789, 268.3], [779.24, 265.03], [765.44, 262.92], [739.37, 261.91], [664.76, 252.67], [664.36, 254.92], [668.25, 255.62], [668.05, 256.71], [668.16, 256.76], [668.27, 256.87], [668.32, 257.01], [668.33, 257.16], [667.98, 257.1], [656.07, 323.6], [656.42, 323.66], [656.41, 323.69], [656.34, 323.83], [656.25, 323.91], [656.14, 323.97], [656, 323.98], [655.81, 325.08], [651.92, 324.38], [651.55, 326.43], [721.02, 347.04], [770.22, 348.13], [778.37, 343.2], [785.74, 332.82], [787.15, 327.58], [786.22, 321.42], [782.81, 315.96], [777.7, 312.61], [768.64, 310.6], [736.7, 309.52], [721.59, 304.38], [757.28, 301.54]]]
];
// [name, male piece, female piece, rotation turning local +Y toward the female piece, chord across the outline, tab roots]
cat_seams = [
    ["tail", "tail", "rump", -64.09, [[225.81, 229.38], [209.05, 263.9]], [[217.43, 246.64]]],  // 38.4 mm
    ["hip", "hind-leg", "rump", -54.13, [[213.1, 165.86], [260.07, 100.9]], [[236.59, 133.38]]],  // 80.2 mm
    ["waist", "rump", "belly", -73.14, [[376.85, 185.48], [337.05, 316.84]], [[366.9, 218.32], [347, 284]]],  // 137.3 mm
    ["ribs", "chest", "belly", 121.24, [[544.88, 242.19], [470.84, 364.26]], [[526.37, 272.71], [489.35, 333.75]]],  // 142.8 mm
    ["neck", "head", "chest", 159.2, [[516.51, 394.19], [645.9, 345.04]], [[548.86, 381.9], [613.56, 357.32]]],  // 138.4 mm
    ["shoulder", "forelegs", "chest", 100.15, [[667.98, 257.1], [656.07, 323.6]], [[662.03, 290.35]]]  // 67.6 mm
];
magnet_xy = [434.22, 269.62];  // mm, centre of mass of the whole cat

piece_names = [for (p = cat_pieces) p[0]];
assert(len([for (n = piece_names) if (n == piece) n]) == 1, str("unknown piece: ", piece));
joint_h = plate_h + land_h;
assert(tab_depth + tab_clearance < land_half_w, "the land must cover every tab and socket");
assert(joint_h - seam_front_h - tab_depth > tab_tip_min - eps,
       "the 45° ramp leaves the tab too thin at its end; deepen the land or shorten the tab");
assert(pocket_d * bore_factor < housing_d,
       "the faceted compensated pocket must leave a continuous housing wall");

function piece_row(name) = [for (p = cat_pieces) if (p[0] == name) p][0];
function piece_color(name) =
    name == "tail" ? tail_color : name == "hind-leg" ? hind_leg_color :
    name == "rump" ? rump_color : name == "belly" ? belly_color :
    name == "chest" ? chest_color : name == "head" ? head_color : forelegs_color;

module cat_outline() polygon(bezpath_curve(CAT_BEZ, splinesteps = 24));

module tab2d() polygon([[-tab_root / 2, -eps], [tab_root / 2, -eps],
                        [tab_tip / 2, tab_depth], [-tab_tip / 2, tab_depth]]);

// Seam-local: x along the seam, +y into the female piece, front face at z = 0.
// Everything above the 45° ramp that leaves the front band on the seam line and
// climbs into the female piece; drop lowers it, which is how the socket gets clearance.
module above_ramp(drop = 0) {
    a = tab_clearance + 1;
    b = tab_depth + tab_clearance + 1;
    rotate([90, 0, 90]) linear_extrude(height = 2 * tab_tip, center = true)
        polygon([[-a, seam_front_h - drop - a], [b, seam_front_h - drop + b],
                 [b, joint_h + 1], [-a, joint_h + 1]]);
}

module tab3d() intersection() {
    linear_extrude(height = joint_h, convexity = 4) tab2d();
    above_ramp();
}

module socket3d() intersection() {
    translate([0, 0, -eps]) linear_extrude(height = joint_h + 1, convexity = 4)
        offset(delta = tab_clearance) tab2d();
    above_ramp(tab_clearance * sqrt(2));
}

module at_tabs(seam) for (o = seam[5]) translate(o) rotate(seam[3]) children();

module seam_strip(seam) hull() for (p = seam[4])
    translate(p) rotate(seam[3]) square([eps, 2 * land_half_w], center = true);

module piece2d(name) intersection() { cat_outline(); polygon(piece_row(name)[3]); }

module land2d(name) {
    intersection() {
        piece2d(name);
        offset(delta = -land_inset) cat_outline();
        union() for (s = cat_seams) if (s[1] == name || s[2] == name) seam_strip(s);
    }
}

module pocket_cut() {
    translate([0, 0, plate_h])
        cylinder(d = pocket_d * bore_factor, h = pocket_h);
}

module piece3d(name) {
    color(piece_color(name)) difference() {
        union() {
            linear_extrude(height = plate_h, convexity = 10) piece2d(name);
            linear_extrude(height = joint_h, convexity = 10) land2d(name);
            for (s = cat_seams) if (s[1] == name) at_tabs(s) tab3d();
            if (name == "belly") translate(magnet_xy) cylinder(d = housing_d, h = part_h);
        }
        for (s = cat_seams) if (s[2] == name) at_tabs(s) socket3d();
        if (name == "belly") translate(magnet_xy) pocket_cut();
    }
}

// Rotated and centred to fit the bed, as exported.
module print_piece(name) {
    row = piece_row(name);
    translate([-row[2][0], -row[2][1], 0]) rotate(row[1]) piece3d(name);
}

module magnet_dummy() {
    color(magnet_color) translate([magnet_xy[0], magnet_xy[1], plate_h + eps])
        cylinder(d = magnet_d, h = magnet_h);
}

// One tab and its socket at production section and clearance. gap = 0 seats them.
module joint_coupon(gap = 2 * tab_depth) {
    w = 2 * tab_tip;
    color(rump_color) union() {
        translate([-w / 2, -land_half_w, 0]) cube([w, land_half_w, joint_h]);
        tab3d();
    }
    color(belly_color) translate([0, gap, 0]) difference() {
        translate([-w / 2, 0, 0]) cube([w, land_half_w, joint_h]);
        socket3d();
    }
}

function mean(pts) = [for (i = [0, 1]) sum([for (p = pts) p[i]]) / len(pts)];

if (show == "assembled") for (n = piece_names) piece3d(n);
else if (show == "exploded") for (n = piece_names) {
    d = mean(piece_row(n)[3]) - magnet_xy;
    translate(n == "belly" ? [0, 0] : explode * d / norm(d)) piece3d(n);
}
else if (show == "piece") print_piece(piece);
else if (show == "coupon") joint_coupon();
else if (show == "joint-section") difference() {
    joint_coupon(0);
    translate([0, -50, -1]) cube([50, 100, joint_h + 2]);
}
else if (show == "section") {
    difference() {
        piece3d("belly");
        translate([magnet_xy[0], magnet_xy[1] - 150, -eps]) cube([150, 300, part_h + 2 * eps]);
    }
    magnet_dummy();
}
else if (show == "before-cap") intersection() {
    piece3d("belly");
    translate([-100, -100, -eps]) cube([1000, 1000, roof_z]);
}
else assert(false, str("unknown show: ", show));
