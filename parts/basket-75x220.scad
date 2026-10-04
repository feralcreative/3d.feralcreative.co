// Upright, open-top basket. Print on the solid floor, without supports.
// Continuous axial ribs carry the load; seven rows of pointed windows leave
// hoop bands between them. Roofs rise more steeply than 45 degrees, so every
// closing layer rests on the previous one instead of bridging a flat lintel.
// The outside remains within the requested diameter, including the rim.
// Height uses the AD5M Pro's entire nominal Z envelope: no raft or pedestal.

/* [Envelope] */
outer_d = 75;          // mm, maximum outside diameter
total_h = 220;         // mm, underside to top of rim
wall_t = 3.54;         // mm, 2 x 0.42 outer + 6 x 0.45 inner extrusion widths
floor_t = 3.6;         // mm, solid bottom

/* [Windows] */
window_columns = 16;  // continuous ribs around the circumference
window_rows = 7;      // rows separated by uninterrupted hoop bands
window_w = 9;         // mm, tangential clear width
window_h = 23;        // mm, including the pointed roof
roof_rise = 6;        // mm, roof pitch: 36.9 degrees from vertical
corner_chamfer = 1.2; // mm, soften each lower window corner
base_band_h = 10;     // mm, solid skirt above the floor
rim_band_h = 10;      // mm, uninterrupted upper collar

/* [Reinforcement] */
end_wall_t = 4.44;    // mm, thicker base and rim, all added inward
end_blend_h = 1.5;    // mm, transition from main wall to thicker ends
floor_gusset = 1.5;   // mm, 45-degree inside floor-to-wall reinforcement
edge_chamfer = 0.6;   // mm, bottom outer edge and both top rim edges

/* [Colors] */
basket_color = "MediumPurple"; // single printed piece, preview only

/* [Resolution] */
$fn = 96;             // 0.020 mm chord error at the outside radius
eps = 0.01;           // mm, boolean overshoot

/* [Hidden] */
outer_r = outer_d / 2;
inner_r = outer_r - wall_t;
end_inner_r = outer_r - end_wall_t;
window_pitch = (total_h - base_band_h - rim_band_h - window_h)
               / (window_rows - 1);
cut_depth = end_wall_t + floor_gusset + 2 * eps;
inner_rib_w = 2 * inner_r * sin(180 / window_columns) - window_w;

assert(window_rows >= 2 && window_columns >= 3, "Need at least two rows and three columns");
assert(total_h <= 220, "Basket exceeds the target printer's nominal Z envelope");
assert(outer_d > 2 * (end_wall_t + floor_gusset), "No usable interior remains");
assert(end_wall_t >= wall_t && end_blend_h >= end_wall_t - wall_t,
       "End reinforcement would overhang by more than 45 degrees");
assert(roof_rise >= window_w / 2, "Window roofs must rise at least 45 degrees");
assert(window_h > roof_rise + corner_chamfer, "Window has no vertical opening");
assert(window_pitch - window_h >= wall_t, "Hoop bands too thin");
assert(inner_rib_w >= wall_t, "Axial ribs too narrow at the inside face");
assert(base_band_h > floor_t + floor_gusset + end_blend_h, "Windows enter the reinforced floor");
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
    // X is tangent to the basket, Y is height. The lower chamfers remove
    // sharp right-angle corners; the apex has no horizontal bridge.
    polygon([
        [-window_w / 2 + corner_chamfer, 0],
        [ window_w / 2 - corner_chamfer, 0],
        [ window_w / 2, corner_chamfer],
        [ window_w / 2, window_h - roof_rise],
        [0, window_h],
        [-window_w / 2, window_h - roof_rise],
        [-window_w / 2, corner_chamfer]
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
    color(basket_color)
        difference() {
            basket_shell();
            for (column = [0 : window_columns - 1])
                rotate([0, 0, column * 360 / window_columns])
                    for (row = [0 : window_rows - 1])
                        translate([0, 0, base_band_h + row * window_pitch])
                            window_cut();
        }
}

basket();
