// Flat adhesive-label placard for fabric storage cubes.
// A 6 x 4 inch label sits on the uninterrupted front face. Three rivets above
// and three below the label keep the hardware clear of the label itself.
// Print flat, back on the bed, label face upward. Use metal backing washers
// on the fabric side and rivets whose grip range covers the complete stack.

/* [Label] */
label_w = 152.4;         // mm, 6 inches
label_h = 101.6;         // mm, 4 inches
label_margin = 2;       // mm, clear space beyond each label edge

/* [Plate] */
plate_w = 175;          // mm, overall width
plate_h = 135;          // mm, overall height
plate_t = 2.4;          // mm, uniform plate thickness
corner_r = 5;           // mm, rounded outside corners

/* [Rivets] */
rivet_d = 3.2;          // mm, nominal shank; 1/8 inch by default
hole_clearance = 0.1;   // mm, diametral clearance; verify with the actual rivet
rivet_count = 6;        // [4, 6]
hole_edge = 8;          // mm, hole centre to straight plate edge
head_clear_d = 12;      // mm, reserved diameter for a head or washer

/* [Display] */
show = "placard";      // [placard, label-layout]

/* [Colors] */
plate_color = "SteelBlue";
label_color = "White"; // reference only, never part of the placard STL

/* [Hidden] */
$fn = 64;
eps = 0.01;            // mm, overshoot for every through-cut
hole_d = rivet_d + hole_clearance;
hole_r = hole_d / (2 * cos(180 / $fn)); // circumscribed bore clears across flats
hole_x = plate_w / 2 - hole_edge;
hole_y = plate_h / 2 - hole_edge;
hole_columns = rivet_count == 6 ? [-hole_x, 0, hole_x] : [-hole_x, hole_x];

assert(plate_t > 0 && corner_r > 0 && 2 * corner_r < min(plate_w, plate_h));
assert(rivet_count == 4 || rivet_count == 6, "Choose four or six rivets");
assert(rivet_d > 0 && hole_clearance > 0 && head_clear_d >= hole_d);
assert(label_w + 2 * label_margin < plate_w, "Label needs clear space at the sides");
assert(hole_y - head_clear_d / 2 >= label_h / 2 + label_margin,
       "Rivet heads or washers would overlap the reserved label area");
assert(hole_edge >= 2 * rivet_d && hole_edge >= head_clear_d / 2,
       "Keep adequate edge distance and room for the rivet head");
assert(hole_edge >= corner_r, "Keep the holes away from the rounded corner cutouts");

module placard() {
    color(plate_color) difference() {
        linear_extrude(height = plate_t, convexity = 10)
            offset(r = corner_r)
                square([plate_w - 2 * corner_r, plate_h - 2 * corner_r], center = true);
        for (x = hole_columns)
            for (y = [-hole_y, hole_y])
                translate([x, y, -eps]) cylinder(r = hole_r, h = plate_t + 2 * eps);
    }
}

module label_reference() {
    // OpenSCAD's background modifier excludes this visual guide from STL exports.
    %color(label_color)
        translate([-label_w / 2, -label_h / 2, plate_t + eps])
            cube([label_w, label_h, eps]);
}

placard();
if (show == "label-layout") label_reference();
