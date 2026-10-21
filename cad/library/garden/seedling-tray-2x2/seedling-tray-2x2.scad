// 2 x 2 seedling tray matching the commercial 4" deep square-cell tray:
// 5 1/8" square overall, 4 1/4" tall, 2 3/8" square cells.
// walls="separate": each cell is its own tapered pot; the pots share a wall at
// the rim and open into a V-gap below it, as on the original.
// walls="shared": one tapered block split by straight common walls, no air gaps.
// Prints upright, floor on the bed.
// +Z is up in use and in print.

/* [Show] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "tray"; // [tray, section]
walls = "separate"; // [separate, shared]

/* [Overall] */
inch = 25.4;
overall_h = 4.25 * inch;    // mm bed to rim top, 107.95

/* [Cells] */
cells_x = 2;                // cells along X
cells_y = 2;                // cells along Y
cell_top = 2.375 * inch;    // mm inside the cell at the rim, 60.33
cell_bottom = 54;           // mm inside the cell at the floor; sets the taper
cell_r = 4;                 // mm inside corner radius at the rim

/* [Walls] */
// 1.29 is three lines on the 0.4 nozzle (0.42 outer + 0.45 inner rungs).
wall = 1.29;                // mm pot wall, measured horizontally
floor_t = 1.2;              // mm floor, six 0.20 layers

/* [Rim] */
rim_t = 2.4;                // mm flat deck at the top
// How far the rim overhangs the pot block. 2.8275 makes the 2 x 2 rim exactly
// 5 1/8" (130.18 mm), the original; other grids keep the same overhang.
rim_flange = 2.8275;        // mm
// The flange reaches past the pots to outer_size; its underside is a 45 deg
// chamfer so it prints without supports.

/* [Drainage] */
drain_d = 18;               // mm centre hole in each floor
slot_w = 2.5;               // mm radial floor slot width
slot_l = 9;                 // mm radial floor slot length
slot_r = 19;                // mm from cell centre to slot centre
slot_n = 8;                 // slots per floor
arch_w = 20;                // mm side arch width at the bed
arch_h = 6;                 // mm straight part of the side arch; a 45 deg point sits above

/* [Colors] */
tray_color = "#3a3a3a";

/* [Hidden] */
$fn = 48;
eps = 0.01;

pitch = cell_top + wall;                    // pots share one wall at the rim
body_x = cells_x * pitch + wall;            // pot block across X at the rim
body_y = cells_y * pitch + wall;
flange = rim_flange;
outer_size = max(body_x, body_y) + 2 * flange;   // mm across the rim
assert(walls != "shared" || cells_x == cells_y, "shared walls assume a square grid");

function cell_xy(i, j) = [(i - (cells_x - 1) / 2) * pitch, (j - (cells_y - 1) / 2) * pitch];

module rsquare(size, r) {
    offset(r = r) square(size - 2 * r, center = true);
}

// Tapered rounded-square prism, bottom size s0 at z=0, top size s1 at z=h.
module taper(s0, s1, r1, h) {
    linear_extrude(height = h, scale = s1 / s0)
        rsquare(s0, r1 * s0 / s1);
}

module pot_outer() {
    taper(cell_bottom + 2 * wall, cell_top + 2 * wall, cell_r + wall, overall_h);
}

module pot_inner() {
    // Same taper as the outer wall, carried past the rim for a clean cut.
    k = (cell_top - cell_bottom) / (overall_h - floor_t);
    translate([0, 0, floor_t])
        taper(cell_bottom, cell_top + k * eps * 2, cell_r, overall_h - floor_t + eps * 2);
}

module floor_drains() {
    translate([0, 0, -eps]) {
        cylinder(d = drain_d, h = floor_t + 2 * eps);
        for (a = [0 : 360 / slot_n : 359])
            rotate(a) translate([slot_r, 0, 0])
                hull() for (dx = [-1, 1] * (slot_l - slot_w) / 2)
                    translate([dx, 0, 0]) cylinder(d = slot_w, h = floor_t + 2 * eps);
    }
}

// Pointed arch through one wall, centred on the face whose outward normal is +X.
module side_arch() {
    half = cell_bottom / 2;
    translate([half - wall, 0, -eps])
        rotate([90, 0, 90])
            linear_extrude(height = 4 * wall)
                polygon([
                    [-arch_w / 2, 0], [arch_w / 2, 0],
                    [arch_w / 2, arch_h], [0, arch_h + arch_w / 2],
                    [-arch_w / 2, arch_h]
                ]);
}

// Faces of cell (i, j) that sit on the outside of the block, as outward angles.
function outer_faces(i, j) = [
    if (i == cells_x - 1) 0,
    if (j == cells_y - 1) 90,
    if (i == 0) 180,
    if (j == 0) 270
];

module rim() {
    z0 = overall_h - rim_t;
    translate([0, 0, z0]) linear_extrude(rim_t) rsquare(outer_size, cell_r + wall + flange);
    // 45 deg chamfer from the flange edge back to the pot block; the cell cuts
    // clear its inside, and it only closes the top few mm of the V-gaps.
    translate([0, 0, z0 - flange])
        hull() {
            linear_extrude(eps) rsquare(max(body_x, body_y), cell_r + wall);
            translate([0, 0, flange - eps])
                linear_extrude(eps) rsquare(outer_size, cell_r + wall + flange);
        }
}

// ---- Shared-wall variant ----
// The outer faces keep the same per-side taper as a separate pot; the common
// walls stay vertical and one wall thick, so each cell slopes on its outer
// faces only.
taper_side = (cell_top - cell_bottom) / 2;
block_top = max(body_x, body_y);
block_bot = block_top - 2 * taper_side;
cav_bot = block_bot - 2 * wall;             // cavity across at the bed
function divider_x(k) = -block_top / 2 + k * pitch + wall / 2;
function cell_lo(i) = i == 0 ? -cav_bot / 2 : divider_x(i) + wall / 2;
function cell_hi(i) = i == cells_x - 1 ? cav_bot / 2 : divider_x(i + 1) - wall / 2;
function cell_mid(i) = (cell_lo(i) + cell_hi(i)) / 2;   // floor centre, either axis

module arch_cut() {
    // Pointed arch through the outer wall whose outward normal is +X.
    translate([block_bot / 2 - wall - 0.5, 0, -eps])
        rotate([90, 0, 90])
            linear_extrude(height = 4 * wall)
                polygon([
                    [-arch_w / 2, 0], [arch_w / 2, 0],
                    [arch_w / 2, arch_h], [0, arch_h + arch_w / 2],
                    [-arch_w / 2, arch_h]
                ]);
}

module tray_shared() {
    color(tray_color) difference() {
        union() {
            taper(block_bot, block_top, cell_r + wall, overall_h);
            rim();
        }
        difference() {
            // Cavity carried 1 mm past the rim on the same taper.
            k = 2 * taper_side / overall_h;
            intersection() {
                taper(cav_bot, cav_bot + k * (overall_h + 1), cell_r, overall_h + 1);
                translate([-outer_size, -outer_size, floor_t]) cube([2 * outer_size, 2 * outer_size, overall_h]);
            }
            for (k = [1 : cells_x - 1])
                translate([divider_x(k) - wall / 2, -outer_size, -1]) cube([wall, 2 * outer_size, overall_h + 2]);
            for (k = [1 : cells_y - 1])
                translate([-outer_size, divider_x(k) - wall / 2, -1]) cube([2 * outer_size, wall, overall_h + 2]);
        }
        for (i = [0 : cells_x - 1], j = [0 : cells_y - 1])
            translate([cell_mid(i), cell_mid(j), 0]) floor_drains();
        for (i = [0 : cells_x - 1]) {
            rotate(90) translate([0, -cell_mid(i), 0]) arch_cut();
            rotate(270) translate([0, cell_mid(i), 0]) arch_cut();
        }
        for (j = [0 : cells_y - 1]) {
            translate([0, cell_mid(j), 0]) arch_cut();
            rotate(180) translate([0, -cell_mid(j), 0]) arch_cut();
        }
    }
}

module tray() {
    if (walls == "shared") tray_shared();
    else tray_separate();
}

module tray_separate() {
    color(tray_color) difference() {
        union() {
            for (i = [0 : cells_x - 1], j = [0 : cells_y - 1])
                translate(cell_xy(i, j)) pot_outer();
            // Deck fills the gaps where rounded corners and V-gaps meet the rim.
            translate([0, 0, overall_h - rim_t])
                linear_extrude(rim_t) rsquare(max(body_x, body_y), cell_r + wall);
            rim();
        }
        for (i = [0 : cells_x - 1], j = [0 : cells_y - 1])
            translate(cell_xy(i, j)) {
                pot_inner();
                floor_drains();
                for (a = outer_faces(i, j)) rotate(a) side_arch();
            }
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_b268c18bd7bb() {
if (show == "section")
    difference() {
        tray();
        // Cut through the +X cell centres, not the shared wall.
        translate([(walls == "shared" ? cell_mid(cells_x - 1) : cell_xy(cells_x - 1, 0)[0]) - outer_size, -outer_size, -1]) cube([outer_size, 2 * outer_size, overall_h + 2]);
    }
else
    tray();
}

module feral_assembly_view_b268c18bd7bb(explode=false) {
feral_default_output_b268c18bd7bb();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_b268c18bd7bb();
else feral_assembly_view_b268c18bd7bb(view == "exploded");
