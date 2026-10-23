// Note 1.

/* [Show] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

show = "tray"; // [tray, section]
walls = "separate"; // [separate, shared]

/* [Overall] */
inch = 25.4;
overall_h = 4.25 * inch;    // Note 3.

/* [Cells] */
cells_x = 2;                // Note 4.
cells_y = 2;                // Note 5.
cell_top = 2.375 * inch;    // Note 6.
cell_bottom = 54;           // Note 7.
cell_r = 4;                 // Note 8.

/* [Walls] */
// Note 9.
wall = 1.29;                // Note 10.
floor_t = 1.2;              // Note 11.

/* [Rim] */
rim_t = 2.4;                // Note 12.

rim_flange = 2.8275;        // Note 13.

/* [Drainage] */
drain_d = 18;               // Note 14.
slot_w = 2.5;               // Note 15.
slot_l = 9;                 // Note 16.
slot_r = 19;                // Note 17.
slot_n = 8;                 // Note 18.
arch_w = 20;                // Note 19.
arch_h = 6;                 // Note 20.

/* [Colors] */
tray_color = "#3a3a3a";

/* [Hidden] */
$fn = 48;
eps = 0.01;

pitch = cell_top + wall;                    // Note 21.
body_x = cells_x * pitch + wall;            // Note 22.
body_y = cells_y * pitch + wall;
flange = rim_flange;
outer_size = max(body_x, body_y) + 2 * flange;   // Note 23.
assert(walls != "shared" || cells_x == cells_y, "shared walls assume a square grid");

function cell_xy(i, j) = [(i - (cells_x - 1) / 2) * pitch, (j - (cells_y - 1) / 2) * pitch];

module rsquare(size, r) {
    offset(r = r) square(size - 2 * r, center = true);
}

// Note 24.
module taper(s0, s1, r1, h) {
    linear_extrude(height = h, scale = s1 / s0)
        rsquare(s0, r1 * s0 / s1);
}

module pot_outer() {
    taper(cell_bottom + 2 * wall, cell_top + 2 * wall, cell_r + wall, overall_h);
}

module pot_inner() {
    // Note 25.
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

// Note 26.
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

// Note 27.
function outer_faces(i, j) = [
    if (i == cells_x - 1) 0,
    if (j == cells_y - 1) 90,
    if (i == 0) 180,
    if (j == 0) 270
];

module rim() {
    z0 = overall_h - rim_t;
    translate([0, 0, z0]) linear_extrude(rim_t) rsquare(outer_size, cell_r + wall + flange);
    // Note 28.

    translate([0, 0, z0 - flange])
        hull() {
            linear_extrude(eps) rsquare(max(body_x, body_y), cell_r + wall);
            translate([0, 0, flange - eps])
                linear_extrude(eps) rsquare(outer_size, cell_r + wall + flange);
        }
}

// Note 29.

taper_side = (cell_top - cell_bottom) / 2;
block_top = max(body_x, body_y);
block_bot = block_top - 2 * taper_side;
cav_bot = block_bot - 2 * wall;             // Note 30.
function divider_x(k) = -block_top / 2 + k * pitch + wall / 2;
function cell_lo(i) = i == 0 ? -cav_bot / 2 : divider_x(i) + wall / 2;
function cell_hi(i) = i == cells_x - 1 ? cav_bot / 2 : divider_x(i + 1) - wall / 2;
function cell_mid(i) = (cell_lo(i) + cell_hi(i)) / 2;   // Note 31.

module arch_cut() {
    // Note 32.
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
            // Note 33.
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
            // Note 34.
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

// Note 35.

module feral_default_output_b268c18bd7bb() {
if (show == "section")
    difference() {
        tray();
        // Note 36.
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

// Notes

// Note 1. 2 x 2 seedling tray matching the commercial 4" deep square-cell tray:
// 5 1/8" square overall, 4 1/4" tall, 2 3/8" square cells.
// walls="separate": each cell is its own tapered pot; the pots share a wall at
// the rim and open into a V-gap below it, as on the original.
// walls="shared": one tapered block split by straight common walls, no air gaps.
// Prints upright, floor on the bed.
// +Z is up in use and in print.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm bed to rim top, 107.95

// Note 4. cells along X

// Note 5. cells along Y

// Note 6. mm inside the cell at the rim, 60.33

// Note 7. mm inside the cell at the floor; sets the taper

// Note 8. mm inside corner radius at the rim

// Note 9. 1.29 is three lines on the 0.4 nozzle (0.42 outer + 0.45 inner rungs).

// Note 10. mm pot wall, measured horizontally

// Note 11. mm floor, six 0.20 layers

// Note 12. mm flat deck at the top
// How far the rim overhangs the pot block. 2.8275 makes the 2 x 2 rim exactly
// 5 1/8" (130.18 mm), the original; other grids keep the same overhang.

// Note 13. mm
// The flange reaches past the pots to outer_size; its underside is a 45 deg
// chamfer so it prints without supports.

// Note 14. mm centre hole in each floor

// Note 15. mm radial floor slot width

// Note 16. mm radial floor slot length

// Note 17. mm from cell centre to slot centre

// Note 18. slots per floor

// Note 19. mm side arch width at the bed

// Note 20. mm straight part of the side arch; a 45 deg point sits above

// Note 21. pots share one wall at the rim

// Note 22. pot block across X at the rim

// Note 23. mm across the rim

// Note 24. Tapered rounded-square prism, bottom size s0 at z=0, top size s1 at z=h.

// Note 25. Same taper as the outer wall, carried past the rim for a clean cut.

// Note 26. Pointed arch through one wall, centred on the face whose outward normal is +X.

// Note 27. Faces of cell (i, j) that sit on the outside of the block, as outward angles.

// Note 28. 45 deg chamfer from the flange edge back to the pot block; the cell cuts
// clear its inside, and it only closes the top few mm of the V-gaps.

// Note 29. ---- Shared-wall variant ----
// The outer faces keep the same per-side taper as a separate pot; the common
// walls stay vertical and one wall thick, so each cell slopes on its outer
// faces only.

// Note 30. cavity across at the bed

// Note 31. floor centre, either axis

// Note 32. Pointed arch through the outer wall whose outward normal is +X.

// Note 33. Cavity carried 1 mm past the rim on the same taper.

// Note 34. Deck fills the gaps where rounded corners and V-gaps meet the rim.

// Note 35. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.

// Note 36. Cut through the +X cell centres, not the shared wall.
