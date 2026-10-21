// Flat adhesive-label placard for fabric storage cubes.
// A 6 x 4 inch adhesive label sits in a shallow front recess. Three rivets above
// and three below the label keep the hardware clear of the label itself.
// Print flat, back on the bed, label face upward. Use metal backing washers
// on the fabric side and rivets whose grip range covers the complete stack.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/rounding.scad>

/* [Label] */
label_w = 152.4;         // mm, 6 inches
label_h = 101.6;         // mm, 4 inches
label_margin = 2;       // mm, clear space beyond each label edge
label_clearance = 0.5;  // mm, recess clearance on each side of the label
recess_depth = 0.6;     // mm, below the front face; leaves a 1.8 mm floor

/* [Plate] */
border_w = 11.1;        // mm, equal border from recess to back-face edge on all four sides
plate_t = 2.4;          // mm, uniform plate thickness
corner_r = 5;           // mm, rounded outside corners
front_edge_r = 2.4;     // mm, front perimeter rolls all the way down to the back
edge_steps = 24;        // segments in the quarter-circle edge profile

/* [Rivets] */
rivet_d = 3.2;          // mm, nominal shank; 1/8 inch by default
hole_clearance = 0.1;   // mm, diametral clearance; verify with the actual rivet
rivet_count = 6;        // [4, 6]
hole_edge = 6.4;        // mm, hole centre to straight back-face edge
head_style = "domed"; // [domed, countersunk]
head_d = 6.7;          // mm, assumed head envelope; verify actual rivets
head_clearance = 0.2;  // mm, diametral head-pocket clearance
head_recess_depth = 1.2; // mm, flat-bottom pocket for ordinary domed pop rivets
head_seat_angle = 120; // degrees, included angle for countersunk-head variant
head_web = 1.2;        // mm, minimum material between head recess and label recess

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
pocket_w = label_w + 2 * label_clearance;
pocket_h = label_h + 2 * label_clearance;
plate_w = pocket_w + 2 * border_w;
plate_h = pocket_h + 2 * border_w;
hole_x = plate_w / 2 - hole_edge;
hole_y = plate_h / 2 - hole_edge;
hole_columns = rivet_count == 6 ? [-hole_x, 0, hole_x] : [-hole_x, hole_x];
recess_floor_z = plate_t - recess_depth;
head_pocket_d = head_d + head_clearance;
head_pocket_r = head_pocket_d / (2 * cos(180 / $fn));
head_depth = head_style == "domed" ? head_recess_depth :
             (head_pocket_d - hole_d) / (2 * tan(head_seat_angle / 2));
head_floor_z = plate_t - head_depth;
// BOSL2 quantizes offset profiles to 1/1024 mm; round down so the full-height
// roundover cannot become numerically taller than the plate.
edge_profile_r = floor(front_edge_r * 1024) / 1024;

assert(plate_t > 0 && corner_r > 0 && 2 * corner_r < min(plate_w, plate_h));
assert(recess_depth > 0 && recess_depth < plate_t, "Recess must leave a solid floor");
assert(label_clearance > 0 && label_clearance <= label_margin);
assert(border_w > front_edge_r, "Border must extend beyond the perimeter roundover");
assert(front_edge_r > 0 && front_edge_r <= plate_t && front_edge_r < corner_r);
assert(head_style == "domed" || head_style == "countersunk");
assert(head_d > hole_d && head_clearance > 0 && head_web > 0);
assert(head_seat_angle > 0 && head_seat_angle < 180);
assert(head_depth > 0 && head_depth < plate_t, "Head recess must leave a solid seat");
assert(rivet_count == 4 || rivet_count == 6, "Choose four or six rivets");
assert(rivet_d > 0 && hole_clearance > 0);
assert(label_w + 2 * label_margin < plate_w, "Label needs clear space at the sides");
assert(hole_y - head_pocket_r >= pocket_h / 2 + head_web,
       "Keep a solid web between the head recess and label recess");
assert(hole_edge >= 2 * rivet_d && hole_edge >= front_edge_r + head_pocket_r,
       "Keep adequate edge distance and room for the rivet head");
assert(hole_edge >= corner_r, "Keep the holes away from the rounded corner cutouts");

module placard() {
    color(plate_color) difference() {
        offset_sweep(rect([plate_w, plate_h], rounding = corner_r),
                     height = plate_t,
                     top = os_circle(r = edge_profile_r, steps = edge_steps),
                     check_valid = false, convexity = 10);
        for (x = hole_columns)
            for (y = [-hole_y, hole_y]) {
                translate([x, y, -eps]) cylinder(r = hole_r, h = plate_t + 2 * eps);
                translate([x, y, head_floor_z])
                    if (head_style == "domed")
                        cylinder(r = head_pocket_r, h = head_depth + eps);
                    else
                        cylinder(r1 = hole_r,
                                 r2 = head_pocket_r + eps * tan(head_seat_angle / 2),
                                 h = head_depth + eps);
            }
        translate([-pocket_w / 2, -pocket_h / 2, recess_floor_z])
            cube([pocket_w, pocket_h, recess_depth + eps]);
    }
}

module label_reference() {
    // OpenSCAD's background modifier excludes this visual guide from STL exports.
    %color(label_color)
        translate([-label_w / 2, -label_h / 2, recess_floor_z + eps])
            cube([label_w, label_h, eps]);
}




// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_f3fe7ba9353a() {
placard();
if (show == "label-layout") label_reference();
}

module feral_assembly_view_f3fe7ba9353a(explode=false) {
feral_default_output_f3fe7ba9353a();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_f3fe7ba9353a();
else feral_assembly_view_f3fe7ba9353a(view == "exploded");
