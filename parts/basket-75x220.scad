// Upright, open-top basket. Print on the solid floor, without supports.
// Alternating half-cell offsets between diamond rows leave two families of
// connected diagonal ribs: a criss-cross lattice with no horizontal lintels.
// The upper sides of each diamond rise more steeply than 45 degrees, so
// closing layers rest on previous layers instead of spanning a flat bridge.
// The requested diameter is the MINIMUM clear inside diameter, including
// the floor gusset. The outside grows to preserve the reinforced walls.
// Height uses the AD5M Pro's entire nominal Z envelope: no raft or pedestal.
// The stock 0.4 mm Z-hop goes to Z=220.4 on this part. Limit lift near the
// top before printing; an unmodified stock slice exceeds nominal travel.
// Intended contents: a roll of Kirkland tall kitchen garbage bags. The
// minimum inside clearance is 175 mm; the mouth is wider for easy loading.
// Split for printing into a bottom, identical middle rings, and a top, glued
// together. Every seam sits halfway up the overlap between two diamond rows,
// where the cut crosses the least window (about 71% of the wall is solid).
// An odd ring_rows makes each ring the next one turned half a column, so one
// mesh serves every middle ring: glue each so its ribs continue the lattice.

/* [Show] */
show = "assembled"; // [assembled, exploded, bottom, ring, top]

/* [Envelope] */
clear_inner_d = 175;   // mm, minimum clear diameter, including floor gusset
total_h = 220;         // mm, underside to top of rim
wall_t = 3.54;         // mm, 2 x 0.42 outer + 6 x 0.45 inner extrusion widths
floor_t = 3.6;         // mm, solid bottom

/* [Windows] */
window_columns = 40;  // diamonds around the circumference
window_rows = 11;     // interleaved rows; alternate rows offset half a cell
window_w = 9;         // mm, tangential clear width
window_h = 23;        // mm, diamond tip to tip
base_band_h = 10;     // mm, solid skirt above the floor
rim_band_h = 10;      // mm, uninterrupted upper collar

/* [Sections] */
first_seam_row = 1;   // window row whose lower overlap holds the first seam
ring_rows = 3;        // window pitches per middle ring; odd keeps rings identical
explode_gap = 25;     // mm, spacing between pieces in the exploded view

/* [Reinforcement] */
end_wall_t = 4.44;    // mm, thicker base and rim, all added inward
end_blend_h = 1.5;    // mm, transition from main wall to thicker ends
floor_gusset = 1.5;   // mm, 45-degree inside floor-to-wall reinforcement
edge_chamfer = 0.6;   // mm, bottom outer edge and both top rim edges

/* [Colors] */
bottom_color = "MediumPurple"; // preview only
ring_color = "Orchid";         // preview only
top_color = "SlateBlue";       // preview only

/* [Resolution] */
$fn = 144;            // about 0.022 mm chord error at the outside radius
eps = 0.01;           // mm, boolean overshoot

/* [Hidden] */
// Circumscribe the narrowest bore so even the polygon flats clear the roll.
clear_inner_r = clear_inner_d / (2 * cos(180 / $fn));
outer_r = clear_inner_r + end_wall_t + floor_gusset;
outer_d = 2 * outer_r;
inner_r = outer_r - wall_t;
end_inner_r = outer_r - end_wall_t;
window_pitch = (total_h - base_band_h - rim_band_h - window_h)
               / (window_rows - 1);
cut_depth = end_wall_t + floor_gusset + 2 * eps;
inner_rib_w = 2 * inner_r * sin(180 / window_columns) - window_w;
// Perpendicular separation between the diagonal sides of adjacent diamonds.
diagonal_rib_w = (inner_r * sin(180 / window_columns) / window_w
                  + window_pitch / window_h - 1)
                 / sqrt(1 / (window_w * window_w) + 1 / (window_h * window_h));

// Halfway up the band where row r-1's top tips overlap row r's bottom tips.
seam_phase = (window_h - window_pitch) / 2;
ring_count = floor((window_rows - 1 - first_seam_row) / ring_rows);
seam_z = [for (k = [0 : ring_count])
          base_band_h + (first_seam_row + k * ring_rows) * window_pitch + seam_phase];
ring_h = ring_rows * window_pitch;
slab_r = outer_r + 1;

assert(window_rows >= 2 && window_columns >= 3, "Need at least two rows and three columns");
assert(total_h <= 220, "Basket exceeds the target printer's nominal Z envelope");
assert(outer_d > 2 * (end_wall_t + floor_gusset), "No usable interior remains");
assert(end_wall_t >= wall_t && end_blend_h >= end_wall_t - wall_t,
       "End reinforcement would overhang by more than 45 degrees");
assert(window_h >= window_w, "Diamond sides must rise at least 45 degrees");
assert(window_pitch > window_h / 2 && window_pitch < window_h,
       "Diamond rows must overlap in height to form the criss-cross lattice");
assert(inner_rib_w >= wall_t, "Lattice crossings too narrow at the inside face");
assert(diagonal_rib_w >= wall_t, "Diagonal ribs too narrow at the inside face");
assert(base_band_h > floor_t + floor_gusset + end_blend_h, "Windows enter the reinforced floor");
assert(ring_rows % 2 == 1, "An even ring_rows makes alternate rings different meshes");
assert(first_seam_row >= 1 && ring_count >= 1, "Not enough window rows for a middle ring");
assert(seam_z[0] > base_band_h && seam_z[ring_count] < total_h - rim_band_h,
       "Seams must cross the plain wall, not the reinforced ends");
assert(rim_band_h > end_blend_h + edge_chamfer, "Windows enter the reinforced rim");

module basket_shell() {
    // Section is wound around Z. All underside slopes, including the inward
    // rim thickening, are <=45 degrees from vertical. The floor is flat.
    rotate_extrude(convexity = 10)
        polygon([
            [0, 0],
            [outer_r - edge_chamfer, 0],
            [outer_r, edge_chamfer],
            [outer_r, total_h - edge_chamfer],
            [outer_r - edge_chamfer, total_h],
            [end_inner_r + edge_chamfer, total_h],
            [end_inner_r, total_h - edge_chamfer],
            [end_inner_r, total_h - rim_band_h + end_blend_h],
            [inner_r, total_h - rim_band_h],
            [inner_r, base_band_h],
            [end_inner_r, base_band_h - end_blend_h],
            [end_inner_r, floor_t + floor_gusset],
            [end_inner_r - floor_gusset, floor_t],
            [0, floor_t]
        ]);
}

module window_profile() {
    // X is tangent to the basket, Y is height. Both tips are pointed; the
    // upper two edges close progressively without a horizontal bridge.
    polygon([
        [0, 0],
        [ window_w / 2, window_h / 2],
        [0, window_h],
        [-window_w / 2, window_h / 2]
    ]);
}

module window_cut() {
    // Rotation maps profile X to global Y, profile Y to Z and extrusion to X.
    translate([outer_r - cut_depth + eps, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = cut_depth, convexity = 10)
                window_profile();
}

module basket() {
        difference() {
            basket_shell();
            for (row = [0 : window_rows - 1])
                for (column = [0 : window_columns - 1])
                    rotate([0, 0, (column + (row % 2) / 2) * 360 / window_columns])
                        translate([0, 0, base_band_h + row * window_pitch])
                            window_cut();
        }
}

module slab(z0, z1) {
    translate([0, 0, z0]) cylinder(r = slab_r, h = z1 - z0);
}

// Each piece is returned in basket coordinates; print poses drop it to Z=0.
module bottom_piece() {
    color(bottom_color)
        intersection() { basket(); slab(-eps, seam_z[0]); }
}

module ring_piece(k = 0) {
    color(ring_color)
        intersection() { basket(); slab(seam_z[k], seam_z[k + 1]); }
}

module top_piece() {
    color(top_color)
        intersection() { basket(); slab(seam_z[ring_count], total_h + eps); }
}

module assembly(gap = 0) {
    bottom_piece();
    for (k = [0 : ring_count - 1])
        translate([0, 0, (k + 1) * gap]) ring_piece(k);
    translate([0, 0, (ring_count + 1) * gap]) top_piece();
}

if (show == "assembled") assembly();
else if (show == "exploded") assembly(explode_gap);
else if (show == "bottom") bottom_piece();
else if (show == "ring") translate([0, 0, -seam_z[0]]) ring_piece(0);
else if (show == "top") translate([0, 0, -seam_z[ring_count]]) top_piece();
