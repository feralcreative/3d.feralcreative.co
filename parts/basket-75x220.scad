// Upright, open-top basket. Default: continuous walls and floor, with infill
// supplied by the slicer. Print upright without supports.
// The optional lattice retains the original open cross-hatch design.
// Alternating half-cell offsets between diamond rows leave two families of
// connected diagonal ribs: a criss-cross lattice with no horizontal lintels.
// The upper sides of each diamond rise more steeply than 45 degrees, so
// closing layers rest on previous layers instead of spanning a flat bridge.
// The requested diameter is the MINIMUM clear inside diameter, including
// the floor gusset. The outside grows to preserve the reinforced walls.
// Intended contents: a roll of Kirkland tall kitchen garbage bags. The
// minimum inside clearance is 175 mm; the mouth is wider for easy loading.
// Split for printing into a bottom, identical middle rings, and a top, glued
// together with keyed annular lap joints. Solid seam collars tie the ribs
// together; an upward lip enters the next piece's downward-open socket.
// Three asymmetric keys locate the lattice. Each identical middle ring turns
// half a column relative to the previous ring when the keys engage.
// All pieces print upright: socket on the bed, insertion lip at the top.

/* [Show] */
show = "assembled"; // [assembled, exploded, bottom, ring, top, joint-section, joint-fit, joint-insertion, joint-wrong-angle]

/* [Envelope] */
shell_style = "solid"; // [solid, lattice]
clear_inner_d = 175;   // mm, minimum clear diameter, including floor gusset
total_h = 220;         // mm, underside to top of rim
wall_t = 3.54;         // mm, 2 x 0.42 outer + 6 x 0.45 inner extrusion widths
floor_t = 3.6;         // mm, floor thickness; slicer supplies skins and infill

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

/* [Glue joints] */
joint_h = 4;          // mm, axial overlap available for glue
joint_t = 1.29;       // mm, lip wall: two 0.42 outer lines + one 0.45 inner line
joint_clearance = 0.2; // mm per radial/tangential face; glue space, not a press fit
joint_axial_clearance = 0.3; // mm above lip; shoulder sets the assembled height
joint_lead = 0.3;     // mm, lip-tip and socket-entry chamfer
joint_lower_band = 4.5; // mm, continuous wall below the shoulder
joint_upper_band = 7; // mm, socket wall and sloping roof above the shoulder
joint_key_w = 5;      // mm, tangential key width
joint_key_depth = 0.55; // mm, radial projection beyond the insertion lip
joint_key_columns = [0, 12, 27]; // asymmetric indices around the window columns

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
floor_column_pitch = 2 * inner_r * sin(180 / window_columns); // mm, side lattice unrolled
floor_column_count = ceil(clear_inner_r / floor_column_pitch) + 1;
floor_row_count = ceil(clear_inner_r / window_pitch) + 1;
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
section_turn = 180 / window_columns;
joint_outer_r = inner_r + joint_t;
socket_outer_r = joint_outer_r + joint_clearance;
socket_h = joint_h + joint_axial_clearance;
key_socket_r = joint_outer_r + joint_key_depth + joint_clearance;
joint_probe_clear = joint_h + joint_upper_band; // mm, starts entirely above the lip
joint_probe_offset = 0; // mm, upward translation of the arriving piece in joint-fit

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
assert(joint_h > 2 * joint_lead && joint_t > 2 * joint_lead,
       "Lip must retain a straight glue land and a printable tip");
assert(joint_clearance > 0 && joint_axial_clearance > 0,
       "Glue joints need insertion clearance");
assert(outer_r - key_socket_r >= 1.29,
       "Retain at least three extrusion lines outside the key sockets");
assert(joint_upper_band > socket_h + key_socket_r - inner_r,
       "Solid collar must enclose the socket's 45-degree closing roof");
assert(joint_lower_band >= window_w / 2,
       "Give the lower collar enough height to close the lattice windows");
assert(joint_lower_band + joint_upper_band < ring_h,
       "Joint collars must leave lattice between adjacent seams");

// All collar additions stay in the existing wall envelope and preserve the bore.
module wall_band(z0, z1) {
    translate([0, 0, z0]) difference() {
        cylinder(r = outer_r, h = z1 - z0);
        translate([0, 0, -eps]) cylinder(r = inner_r, h = z1 - z0 + 2 * eps);
    }
}

module joint_keys(phase = 0) {
    for (column = joint_key_columns)
        rotate([0, 0, phase + column * 360 / window_columns]) children();
}

// Extrude a [radial X, height Z] profile tangentially, centered on its key.
module key_profile(width) {
    rotate([90, 0, 0]) linear_extrude(height = width, center = true, convexity = 10)
        children();
}

module joint_lip(z, phase = 0) {
    translate([0, 0, z]) union() {
        rotate_extrude(convexity = 10) polygon([
            [inner_r, -eps], [joint_outer_r, -eps],
            [joint_outer_r, joint_h - joint_lead],
            [joint_outer_r - joint_lead, joint_h],
            [inner_r + joint_lead, joint_h], [inner_r, joint_h - joint_lead]
        ]);
        joint_keys(phase) key_profile(joint_key_w) polygon([
            [joint_outer_r - joint_lead, -eps],
            [joint_outer_r + joint_key_depth, -eps],
            [joint_outer_r + joint_key_depth, joint_h - joint_lead],
            [joint_outer_r + joint_key_depth - joint_lead, joint_h],
            [joint_outer_r - joint_lead, joint_h]
        ]);
    }
}

module joint_socket(z, phase = 0) {
    translate([0, 0, z]) {
        // The open entry widens downward. Above the tip clearance, the bore
        // closes at 45 degrees rather than leaving an unsupported annular roof.
        rotate_extrude(convexity = 10) polygon([
            [0, -eps], [socket_outer_r + joint_lead, -eps],
            [socket_outer_r, joint_lead], [socket_outer_r, socket_h],
            [inner_r, socket_h + socket_outer_r - inner_r],
            [0, socket_h + socket_outer_r - inner_r]
        ]);
        joint_keys(phase) key_profile(joint_key_w + 2 * joint_clearance) polygon([
            [inner_r - eps, -eps], [key_socket_r, -eps],
            [key_socket_r, socket_h],
            [inner_r - eps, socket_h + key_socket_r - inner_r + eps]
        ]);
    }
}

// A conservative receiver cross-section used to certify continuous axial
// insertion. It is at least as obstructive as every socket section touched
// by the lip between the outside pose and its shoulder stop.
module socket_sweep_wall(z, phase = 0) {
    translate([0, 0, z]) difference() {
        cylinder(r = outer_r, h = joint_probe_clear + joint_h);
        translate([0, 0, -eps]) cylinder(r = socket_outer_r,
            h = joint_probe_clear + joint_h + 2 * eps);
        joint_keys(phase)
            translate([inner_r - eps, -joint_key_w / 2 - joint_clearance, -eps])
                cube([key_socket_r - inner_r + eps,
                      joint_key_w + 2 * joint_clearance,
                      joint_probe_clear + joint_h + 2 * eps]);
    }
}

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

module floor_window_cuts() {
    // Unroll the side lattice onto XY: same 9 x 23 mm diamonds, staggered
    // half a column, with the same rib spacing. Every opening cuts through
    // the floor. Clip at the gusset's inner edge to retain its solid seat.
    intersection() {
        translate([0, 0, -eps])
            cylinder(r = clear_inner_r, h = floor_t + 2 * eps);
        union() {
            for (row = [-floor_row_count : floor_row_count])
                for (column = [-floor_column_count : floor_column_count])
                    translate([(column + (row % 2) / 2) * floor_column_pitch,
                               row * window_pitch, -eps])
                        linear_extrude(height = floor_t + 2 * eps, convexity = 10)
                            translate([0, -window_h / 2]) window_profile();
        }
    }
}

module basket() {
    assert(shell_style == "solid" || shell_style == "lattice", "Unknown shell style");
    if (shell_style == "solid") basket_shell();
    else
        difference() {
            basket_shell();
            floor_window_cuts();
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
    color(bottom_color) union() {
        intersection() { basket(); slab(-eps, seam_z[0]); }
        wall_band(seam_z[0] - joint_lower_band, seam_z[0]);
        joint_lip(seam_z[0]);
    }
}

module ring_piece(k = 0) {
    // Generate one mesh, then pose copies. The half-column rotation carries
    // the alternating diamond pattern and both key patterns to the next seam.
    color(ring_color) translate([0, 0, k * ring_h]) rotate([0, 0, k * section_turn])
        difference() {
            union() {
                intersection() { basket(); slab(seam_z[0], seam_z[1]); }
                wall_band(seam_z[0], seam_z[0] + joint_upper_band);
                wall_band(seam_z[1] - joint_lower_band, seam_z[1]);
                joint_lip(seam_z[1], section_turn);
            }
            joint_socket(seam_z[0]);
        }
}

module top_piece() {
    color(top_color) difference() {
        union() {
            intersection() { basket(); slab(seam_z[ring_count], total_h + eps); }
            wall_band(seam_z[ring_count], seam_z[ring_count] + joint_upper_band);
        }
        joint_socket(seam_z[ring_count], ring_count * section_turn);
    }
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
else if (show == "joint-section") intersection() {
    assembly();
    // Close-up through key zero; the cut exposes both glue faces and the stop.
    translate([inner_r - joint_t, 0, seam_z[0] - joint_lower_band - eps])
        cube([wall_t + joint_t + eps, joint_key_w / 2 + joint_clearance + joint_lead,
              joint_lower_band + joint_upper_band + 2 * eps]);
}
else if (show == "joint-fit") {
    intersection() { bottom_piece(); translate([0, 0, joint_probe_offset]) ring_piece(0); }
    for (k = [0 : ring_count - 2]) intersection() {
        ring_piece(k); translate([0, 0, joint_probe_offset]) ring_piece(k + 1);
    }
    intersection() {
        ring_piece(ring_count - 1); translate([0, 0, joint_probe_offset]) top_piece();
    }
} else if (show == "joint-insertion") {
    for (k = [0 : ring_count]) intersection() {
        joint_lip(seam_z[k], k * section_turn);
        socket_sweep_wall(seam_z[k], k * section_turn);
    }
} else if (show == "joint-wrong-angle") intersection() {
    joint_lip(seam_z[0]);
    socket_sweep_wall(seam_z[0], section_turn);
}
