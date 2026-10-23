// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <back-outline.scad>
include <back-crown.scad>
use <door-fix-crown-bridge.scad>
include <backing-inset.scad>
include <stem-base-selector.scad>
include <cork-collar-blend.scad>
include <pumpkin-outer-solid.scad>

/* [Seat] */
lid_grow = -0.15;          // Note 3.
lid_edge_r = 23;           // Note 4.
cap_base_z = 29.04747;     // Note 5.

/* [Stem] */
stem_grow = 0.3;           // Note 6.
stem_cut_z = 30.72;        // Note 7.
stem_centre = [1.15, 2.36];// Note 8.
stem_round_z = 31.5;       // Note 9.
stem_select_r = [11.6, 13.2]; // Note 10.
stem_step_z = 32;          // Note 11.
peg_d = 5;                 // Note 12.
peg_h = 3;                 // Note 13.
peg_clearance = 0.15;      // Note 14.
stem_base_clearance = 0.15; // Note 15.

/* [Steel disc pocket] */
disc_d = 25;              // Note 16.
disc_t = 2;               // Note 17.
disc_clearance = 0.2;     // Note 18.
disc_glue = 0.2;          // Note 19.
disc_floor = 2.10;        // Note 20.
disc_wall = 2.10;         // Note 21.
disc_centre = [0, 2];     // Note 22.
disc_base_z = -26.93;     // Note 23.
disc_cover = true;       // Note 24.
disc_cover_t = 0.24;      // Note 25.

/* [Walls] */
wall_add = 1.5;            // Note 26.
wall_step = 0.5;           // Note 27.
face_skin = 0.9;           // Note 28.
thicken_top_z = 28.5;      // Note 29.

/* [Face] */
face_angle = 7.83;         // Note 30.

/* [Nose] */
nose_w = 9.8;              // Note 31.
nose_h = 7.7;              // Note 32.
nose_bottom_z = 1.3;       // Note 33.
nose_x = 0;                // Note 34.

/* [Back wall] */
back_cut_y = 25;           // Note 35.
back_wall_t = 4.8;         // Note 36.

/* [Door] */
rear_interior = "closed"; // [closed, hollow]
flat_underside = true; // Note 37.
rear_fill_overlap = 0.1; // Note 38.
door_style = "sculpted";    // [sculpted, original]
rear_seam = 0.3;           // Note 39.
rear_cork_y = 37.5;        // Note 40.
rear_cork_top_z = 24;      // Note 41.
rear_gusset_inner_x = -22.2; // Note 42.
rear_gusset_round = 2.1;   // Note 43.
door_w = 40;               // Note 44.
door_bottom_z = -17;       // Note 45.
tongue_depth = 1.8;        // Note 46.
door_clearance = 0.3;      // Note 47.
crown_start_z = 20;        // Note 48.
crown_half_w = 24;         // Note 49.

/* [Cork collar] */
cork_bore_d = 18.5;        // Note 50.
collar_depth = 22;         // Note 51.
collar_wall = 3.5;         // Note 52.
collar_blend_depth = 12;  // Note 53.
collar_floor = 2;          // Note 54.
head_clear = 2;            // Note 55.
head_top_z = 33.09;        // Note 56.
wire_hole_d = 6;           // Note 57.

/* [Solar light, preview only] */
head_w = 45;               // Note 58.
head_h = 20;               // Note 59.
flange_d = 30;             // Note 60.
flange_h = 6;              // Note 61.

/* [Colors] */
pumpkin_color = "DarkOrange"; // Note 62.
door_color = "DarkOrange";
cap_color = "Orange";
stem_color = "ForestGreen";
light_color = "SaddleBrown";

/* [Output] */
show = "print-door"; // [assembled, exploded, body, door, cap, stem, print-body, print-door, print-cap, print-stem, section, pumpkin]
door_explode = 60;         // Note 63.
stem_explode = 45;         // Note 64.
cap_explode = 25;          // Note 65.
preview_light = true;      // Note 66.
fused_roof = true;        // Note 67.

/* [Hidden] */
$fn = 96;
eps = 0.01;
src = "led-tea-light-jack-o-lantern-pumpkins-model_files/";
wall_in_y = back_cut_y - back_wall_t;
mid_y = back_cut_y - back_wall_t / 2;
collar_r = cork_bore_d / 2 + collar_wall;
collar_axis_y = door_style == "sculpted" ? rear_cork_y : back_cut_y + head_w / 2 + head_clear;
collar_top_z = door_style == "sculpted" ? rear_cork_top_z : head_top_z - head_h - flange_h;
collar_z0 = collar_top_z - collar_depth - collar_floor;
wire_z = collar_top_z - collar_depth + wire_hole_d / 2 + 0.5;
shell_centre = [0, 2, 3];  // Note 68.
face_r = 42;               // Note 69.
shell_r = 46;              // Note 70.
lid_xy_scale = 1 + lid_grow / lid_edge_r;
stem_xy_scale = 1 + stem_grow / lid_edge_r;
disc_pocket_d = disc_d + 2 * disc_clearance;
disc_pocket_depth = disc_t + disc_glue;
face_cut_depth = 100;      // Note 71.
face_outline_margin = 1;  // Note 72.

assert(rear_interior == "closed" || rear_interior == "hollow", "unknown rear interior");
assert(2 * tongue_depth < back_wall_t, "the V tongue must fit inside the wall's thickness");
assert(collar_r < door_w / 2, "the collar must sit within the door's width");
assert(wall_add < 1.7, "the thickening copy must overlap the 1.7 mm wall, or it floats free inside");
assert(wire_z - wire_hole_d / 2 > door_bottom_z + 1, "the wire hole must pass through the door, not under it");
assert(back_cut_y == 25 && back_wall_t == 4.8 && crown_half_w == 24 && crown_start_z == 20,
    "regenerate back-crown.scad for a different back wall");
assert(door_w / 2 + tongue_depth + door_clearance * sqrt(2) < crown_half_w,
    "door and groove must stay within the measured crown");
assert(door_style == "sculpted" || door_style == "original", "unknown door style");
assert(rear_seam >= door_clearance, "rear shell must clear the existing rear wall");

module about_centre(k) translate(shell_centre) scale(k) translate(-shell_centre) children();

module blank() import(str(src, "blank-shell.stl"), convexity = 10);

// Note 73.

module front_profile(file) projection(cut = false) rotate([-90, 0, 0]) intersection() {
    import(str(src, file), convexity = 10);
    translate([-face_cut_depth, -face_cut_depth, -face_cut_depth])
        cube([2 * face_cut_depth, face_cut_depth, 2 * face_cut_depth]);
}

module face_profile() union() {
    difference() {
        offset(delta = -face_outline_margin) front_profile("blank-shell.stl");
        front_profile("traditional-shell.stl");
    }
    // Note 74.
    polygon([[nose_x - nose_w / 2, nose_bottom_z],
             [nose_x + nose_w / 2, nose_bottom_z],
             [nose_x, nose_bottom_z + nose_h]]);
}

// Note 75.
module face_cut() translate([shell_centre[0], shell_centre[1], 0])
    rotate([0, 0, face_angle]) rotate([90, 0, 0])
        linear_extrude(height = face_cut_depth, convexity = 10) face_profile();

// Note 76.

module shell() difference() {
    blank();
    face_cut();
}

// Note 77.

module face_membrane() {
    difference() { blank(); about_centre(1 + face_skin / face_r) blank(); }
}

module lid(grow = lid_grow) scale([1 + grow / lid_edge_r, 1 + grow / lid_edge_r, 1])
    import(str(src, "stem-lid.stl"), convexity = 10);

// Note 78.

module stem_selector(xy_scale = lid_xy_scale, clearance = 0) {
    scale([xy_scale, xy_scale, 1]) for (band = stem_base_bands)
        translate([0, 0, stem_cut_z + band[0]])
            linear_extrude(height = band[1] - band[0] + eps, convexity = 10)
                offset(delta = clearance) polygon(band[2]);
    translate([stem_centre[0], stem_centre[1], stem_round_z])
        cylinder(r = stem_select_r[0] + clearance, h = stem_step_z - stem_round_z + eps);
    translate([stem_centre[0], stem_centre[1], stem_step_z])
        cylinder(r = stem_select_r[1] + clearance, h = 40);
}

module peg() translate([stem_centre[0], stem_centre[1], stem_cut_z - eps]) cylinder(d = peg_d, h = peg_h + eps);

// Note 79.

module stem() color(stem_color) render(convexity = 10) difference() {
    intersection() {
        scale([stem_xy_scale, stem_xy_scale, 1]) import(str(src, "stem-lid.stl"), convexity = 10);
        stem_selector(stem_xy_scale);
    }
    translate([stem_centre[0], stem_centre[1], stem_cut_z - eps])
        cylinder(d = peg_d + 2 * peg_clearance, h = peg_h + peg_clearance + eps);
}

module pumpkin(with_stem = true, with_cap = true) {
    union() {
        shell();
        for (i = [1 : ceil(wall_add / wall_step)]) intersection() {
            about_centre(1 - i * wall_add / (ceil(wall_add / wall_step) * shell_r)) shell();
            translate([-100, -100, -100]) cube([200, 200, 100 + thicken_top_z]);
        }
        face_membrane();
        if (with_cap) {
            if (with_stem) lid(grow = stem_grow);
            else { difference() { lid(grow = stem_grow); stem_selector(stem_xy_scale); } peg(); }
        }
    }
}

// Note 80.

module outline_slab(t = back_wall_t) {
    difference() {
        translate([0, back_cut_y, 0]) rotate([90, 0, 0])
            linear_extrude(height = t, convexity = 4) offset(delta = -0.05) for (p = back_outline) polygon(p);
        translate([-crown_half_w, wall_in_y - eps, crown_start_z - eps])
            cube([2 * crown_half_w, back_wall_t + 2 * eps, 100]);
    }
    back_crown();
}

// Note 81.

module tongue(grow = 0) {
    d = tongue_depth + grow * sqrt(2);
    translate([door_w / 2, mid_y, door_bottom_z - grow])
        linear_extrude(height = 100, convexity = 2)
            polygon([[-eps, -d], [d, 0], [-eps, d]]);
}

// Note 82.

module teardrop2d(d, cap) intersection() {
    hull() {
        circle(d = d);
        polygon([[-d / (2 * sqrt(2)), d / (2 * sqrt(2))], [d / (2 * sqrt(2)), d / (2 * sqrt(2))], [0, d / sqrt(2)]]);
    }
    translate([-d, -d]) square([2 * d, d + cap]);
}

// Note 83.

module rear_shell() intersection() {
    union() {
        blank();
        for (i = [1 : ceil(wall_add / wall_step)]) intersection() {
            about_centre(1 - i * wall_add / (ceil(wall_add / wall_step) * shell_r)) blank();
            translate([-100, -100, -100]) cube([200, 200, 100 + thicken_top_z]);
        }
    }
    translate([-100, back_cut_y + rear_seam, -100]) cube([200, 100, 200]);
}

// Note 84.

module rear_crown_bridge() intersection() {
    assert(back_cut_y == 25 && rear_seam == 0.3,
           "regenerate door-fix-crown-bridge.scad for a changed door seam");
    door_fix_crown_bridge();
    translate([-door_w / 2, back_cut_y - eps, crown_start_z])
        cube([door_w, rear_seam + 2 * eps, 100]);
}

// Note 85.

module rear_gusset_rounded() intersection() {
    assert(abs(rear_gusset_round - backing_inset_radius) < 0.000001 &&
           abs(rear_seam - backing_inset_seam) < 0.000001 &&
           abs(rear_gusset_inner_x - backing_inset_inner_x) < 0.000001,
           "regenerate backing-inset.scad with utils/pumpkin-backing.py for changed backing dimensions");
    minkowski() {
        rear_backing_inset();
        sphere(r = rear_gusset_round, $fn = 48);
    }
    translate([-100, back_cut_y + rear_seam, -100])
        cube([200, 100, 200]);
}

// Note 86.

module rear_gusset() union() {
    rear_gusset_rounded();
    intersection() {
        hull() {
            rear_gusset_rounded();
            translate([0, -face_cut_depth, 0]) rear_gusset_rounded();
        }
        translate([0, back_cut_y + rear_seam, 0]) rotate([-90, 0, 0])
            linear_extrude(height = face_cut_depth, convexity = 10)
                intersection() {
                    offset(delta = -eps) projection(cut = true) rotate([90, 0, 0])
                        translate([0, -back_cut_y - rear_seam - eps / 10, 0]) rear_shell();
                    translate([-100, -100]) square([100 + rear_gusset_inner_x, 200]);
                }
    }
}

// Note 87.

module rear_fill() intersection() {
    pumpkin_outer_solid();
    union() {
        translate([-100, back_cut_y + rear_seam, -100]) cube([200, 100, 200]);
        // Note 88.

        translate([-door_w / 2 + eps, back_cut_y - rear_fill_overlap, door_bottom_z])
            cube([door_w - 2 * eps, rear_seam + rear_fill_overlap + eps, 100]);
    }
}

module cork_bore() translate([0, collar_axis_y, collar_top_z - collar_depth])
    // Note 89.

    linear_extrude(height = 100, convexity = 10)
        teardrop2d(cork_bore_d, cork_bore_d / 2 + 1.5);

module cork_collar() {
    difference() {
        union() {
            hull() {
                translate([0, collar_axis_y, collar_z0]) cylinder(r = collar_r, h = collar_top_z - collar_z0);
                translate([-collar_r, back_cut_y - eps, collar_z0]) cube([2 * collar_r, eps, collar_top_z - collar_z0]);
            }
            cork_collar_blend(collar_r, collar_axis_y, back_cut_y + rear_seam,
                              collar_z0, collar_blend_depth, eps);
        }
        cork_bore();
    }
}

module door_volume() {
    color(door_color) difference() {
        union() {
            intersection() {
                outline_slab();
                union() {
                    translate([-door_w / 2, wall_in_y - 1, door_bottom_z]) cube([door_w, back_wall_t + 2, 100]);
                    tongue();
                    mirror([1, 0, 0]) tongue();
                }
            }
            cork_collar();
            if (door_style == "sculpted") {
                if (rear_interior == "closed") rear_fill();
                else rear_shell();
                rear_crown_bridge();
                rear_gusset();
            }
        }
        cork_bore();
        translate([0, wall_in_y - 1, wire_z]) rotate([-90, 0, 0])
            cylinder(d = wire_hole_d, h = collar_axis_y - wall_in_y + 1);
    }
}

// Note 90.

module door() intersection() {
    door_volume();
    if (flat_underside)
        translate([-100, -100, door_bottom_z]) cube([200, 200, 200]);
}

module door_slot() {
    translate([-door_w / 2 - door_clearance, wall_in_y - door_clearance, door_bottom_z - door_clearance])
        cube([door_w + 2 * door_clearance, back_wall_t + door_clearance + 1, 100]);
    tongue(door_clearance);
    mirror([1, 0, 0]) tongue(door_clearance);
}

// Note 91.

module disc_pad() translate([disc_centre[0], disc_centre[1], disc_base_z])
    cylinder(d = disc_pocket_d + 2 * disc_wall,
             h = disc_pocket_depth + disc_floor + (disc_cover ? disc_cover_t : 0));

module disc_pocket() translate([disc_centre[0], disc_centre[1], disc_base_z + disc_floor])
    cylinder(d = disc_pocket_d, h = disc_pocket_depth + (disc_cover ? 0 : eps));

module body() {
    color(pumpkin_color) difference() {
        union() {
            intersection() {
                pumpkin(with_stem = false, with_cap = fused_roof);
                translate([-100, -100 + back_cut_y, -100]) cube(100 * [2, 1, 2]);
            }
            outline_slab();
            disc_pad();
        }
        door_slot();
        disc_pocket();
    }
}

// Note 92.

module cap() color(cap_color) difference() {
    union() { difference() { lid(); stem_selector(stem_xy_scale, stem_base_clearance); } peg(); }
    door_slot();
}

module solar_light() {
    color(light_color, 0.5) translate([0, collar_axis_y, collar_top_z]) {
        cylinder(d = flange_d, h = flange_h);
        translate([-head_w / 2, -head_w / 2, flange_h]) cube([head_w, head_w, head_h]);
    }
}

module assembly(door_out = 0, stem_up = 0, cap_up = 0) {
    body();
    translate([0, door_out, 0]) {
        door();
        if (preview_light) solar_light();
    }
    if (!fused_roof) translate([0, 0, cap_up]) cap();
    translate([0, 0, stem_up]) stem();
}

// Note 93.
module feral_default_output_36c8510442e2() {
if (show == "assembled") assembly();
else if (show == "exploded") assembly(door_explode, stem_explode, cap_explode);
else if (show == "body") body();
else if (show == "door") door();
else if (show == "cap") cap();
else if (show == "stem") stem();
else if (show == "print-stem") translate([0, 0, -stem_cut_z]) stem();
else if (show == "print-body") translate([0, 0, -disc_base_z]) body();
else if (show == "print-door") {
    if (flat_underside) translate([0, 0, -door_bottom_z]) door();
    else translate([0, 0, -wall_in_y]) rotate([90, 0, 0]) door();
}
else if (show == "print-cap") translate([0, 0, -cap_base_z]) cap();
else if (show == "section") difference() {
    union() { body(); door(); if (!fused_roof) cap(); stem(); }
    translate([stem_centre[0], -100, -100]) cube(200);
}
else if (show == "pumpkin") color(pumpkin_color) pumpkin();
else assert(false, str("unknown show: ", show));
}

module feral_assembly_view_36c8510442e2(explode=false) {
assembly(explode ? door_explode : 0,explode ? stem_explode : 0,explode ? cap_explode : 0);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_36c8510442e2();
else feral_assembly_view_36c8510442e2(view == "exploded");

// Notes

// Note 1. Accepted retrofit door fix for the five existing pumpkins.
// Frozen interface: Y=25 rear wall; use fence-pumpkin.scad for the new complete set.
// Fence-post jack-o'-lantern, adapted from artwells' Printables 1835966
// (CC BY 4.0). Original meshes are retained unchanged beside this source.
// Four printed pieces: upright open body, face-down sliding door with cork
// collar, flat-bottomed orange cap, and green stem glued onto the cap's peg.
// The separate cap eliminates the inaccessible internal roof supports. Local
// rim supports remain necessary and can be reached through the open top.
// Walls grow inward in overlapping steps; the face retains its thin membrane.
// The face rotates about the shell's vertical axis to centre the nose on a
// ridge. Its local nose is reduced 30% about its fixed top point at Z=9.
// The eyes and mouth retain their original projected contours.
// back-outline.scad closes the rear at Y=25. back-crown.scad preserves the
// changing top surface across Y=20.2..25 instead of extruding one flat section.
// Regenerate the crown with utils/pumpkin-crown.py when source contours change.
// The default sculpted door restores the original rear lobes around the same
// sliding plate, with the tested cork bore opening at the rear shoulder.
// door_style="original" retains the preceding exposed-collar door. The body,
// cap, stem, guide dimensions and printed mounting interfaces are unchanged.
// Closed rear volume uses slicer infill; hollow retains the earlier support-dependent cavity.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, slight inward clearance from the original lid's nominal touching fit

// Note 4. mm, radius of the lid's top edge, to turn lid_grow into a scale

// Note 5. mm, original lid's flat underside; print this face on the bed

// Note 6. mm, preserve the already printed green stem's original XY scale

// Note 7. mm, stem-to-dish junction; lobed selector removes the exposed orange base

// Note 8. mm, stem's centroid at the cut

// Note 9. mm, above the lobed base, circular selection clears the dish

// Note 10. mm, selector radius up to stem_step_z, then above; stem reaches 11.3, rim starts 11.9

// Note 11. mm, rim has fallen back to 13.7 by here; stem never reaches past 12.6

// Note 12. mm, locating peg on the pumpkin

// Note 13. mm

// Note 14. mm per side, glue fit

// Note 15. mm, cap clears the already printed stem's lobed base

// Note 16. mm, nickel-plated steel disc; magnets stay on the fence

// Note 17. mm, steel thickness

// Note 18. mm per side, insertion and glue clearance

// Note 19. mm adhesive allowance underneath the disc, inside the pumpkin

// Note 20. mm, solid PETG below the pocket, between steel and fence magnet

// Note 21. mm, minimum radial wall in the mounting pad

// Note 22. mm, centred under the pumpkin

// Note 23. mm, closed exterior bottom, just below the source mesh's -26.92879 minimum

// Note 24. pause-insert trial: enclose the steel disc while printing upright

// Note 25. mm, two 0.12 mm layers above the existing pocket

// Note 26. mm added inside the 1.7 mm wall at the widest point; must stay under 1.7

// Note 27. mm, overlapping inward copies avoid sealed voids within the thicker wall

// Note 28. mm nominal inner skin; curved regions vary, so verify the built mesh and slice

// Note 29. mm, thickening stops below the lid; its rim met the lid's step in pinhead voids

// Note 30. degrees about +Z from -Y; nearest ridge crest at the nose's height

// Note 31. mm, 70% of the previous 14 mm width

// Note 32. mm, 70% of the previous 11 mm height

// Note 33. mm, raised 3.3 mm to keep the upward apex at Z=9

// Note 34. mm, centred in the face's local coordinates before face_angle

// Note 35. mm, cut plane; the pumpkin's back is +Y, its face -Y. Must match back-outline.scad

// Note 36. mm, flat wall closing the cut, and the door's thickness

// Note 37. flatten at the guide stop for upright, one-piece printing

// Note 38. mm, overlap inside the existing plate; avoids a coincident crown seam

// Note 39. mm, restored shell stays behind the existing body's Y=25 rear plane

// Note 40. mm, light axis; the preview head clears the existing stem

// Note 41. mm, flat opening at the original rear shoulder

// Note 42. mm, rounded backing stays inside this original root boundary

// Note 43. mm, inward round-over; regenerate backing-inset.scad if changed

// Note 44. mm, door width between its tongue roots

// Note 45. mm, where the door comes to rest; low enough for the wire hole

// Note 46. mm, V tongue on each door edge, 45° flanks

// Note 47. mm per face, sliding fit

// Note 48. mm, replace the flat outline above this height with the source surface

// Note 49. mm, measured crown data spans this strip

// Note 50. mm, printed/tested perfect with supplied silicone sheath; preserve

// Note 51. mm, printed/tested snug cork-light retention; preserve

// Note 52. mm, plastic around the bore

// Note 53. mm, rounded taper below the holder into the pumpkin

// Note 54. mm, closes the bore's bottom

// Note 55. mm, head stands this far behind the back wall

// Note 56. mm, head's top level with the pumpkin's, hidden from the front

// Note 57. mm, light strand from the cork's tip into the pumpkin

// Note 58. mm, square solar head (the listing's 1.77 in)

// Note 59. mm, UNMEASURED

// Note 60. mm, UNMEASURED round flange under the head

// Note 61. mm, UNMEASURED

// Note 62. preview only

// Note 63. mm rearward displacement in the exploded view

// Note 64. mm upward displacement, making the separate stem visible

// Note 65. mm upward displacement for the optional open-roof cap

// Note 66. show the solar-light stand-in in the assembled view

// Note 67. trial: restore the integral roof for plate-only support testing

// Note 68. centre of the shell's bounding box; thickening scales toward it

// Note 69. mm, rough distance from shell_centre to the face's inner surface

// Note 70. mm, the shell's widest radius from shell_centre

// Note 71. mm, front half-space and facial cutter depth

// Note 72. mm, omit silhouette-edge slivers from differing source tessellations

// Note 73. Project the front half only: the back of a hollow shell would otherwise
// cover its facial openings. Eroding the blank's outer silhouette excludes
// tiny outline differences between the two meshes, well clear of the face.

// Note 74. This triangle contains the original nose opening (X=±2, Z=2..6).

// Note 75. Move the feature cutters, not the pumpkin's ridges, lid, rear door or pocket.

// Note 76. Starting from the blank closes the old face before cutting the new position.
// Both the outer shell and its inward thickening use the same rotated face.

// Note 77. A continuous inner skin of the blank shell closes every face opening. The
// ordinary pumpkin walls absorb the rest of this skin. Do not trim it to a
// projected face mask: cleaning that mask removed a narrow mouth strip and
// left a real gap, and its clipped edges left non-manifold membrane joins.

// Note 78. The lobed base cannot be separated from the dish with a cylinder. Measured
// outlines keep only the stem below stem_round_z; the upper selection is round.

// Note 79. render() so the preview shows the real piece: OpenCSG draws this intersection
// with the lid's whole dish in green.

// Note 80. The lower outline sits 0.05 mm inside the shell. The crown overlaps it by
// 0.1 mm and follows the actual source surface across the wall's full depth.

// Note 81. V tongue along the door's right edge, running up Z. grow moves both 45° flanks
// out by grow along their normals, which turns the tongue into its groove.

// Note 82. Teardrop pointing +Y, which is up when the door prints face down, with its
// point cut flat at cap above the axis so it stays inside the collar wall.

// Note 83. Original rear shell, including its lobes and inward wall thickening. The
// entire added shell stays behind the old body, including during insertion.
// Its open cut edge surrounds the original sliding plate; it does not enlarge
// the tongues or require cutting the already printed body's rear wall.

// Note 84. Close the slot within the moving door's own crown. Outside the door width,
// the shell still needs its original rear clearance from the printed body.
// The sampled solid crown fills underneath too, avoiding enclosed slits
// between the shell's separate inner thickening layers.

// Note 85. The backing is inset by the round-over radius before the sphere is added
// back. Its front-facing perimeter curls inward rather than growing into a
// visible flange outside the pumpkin. The generated convex inset preserves
// the filled interior and rounds the front, root, top and bottom together.

// Note 86. Fill behind the original cut-edge material without enlarging its footprint.
// The inward round-over can otherwise leave a small space behind the native
// side sliver. This reaches only to the same rounded rear surface and uses
// the existing shell's front section, so it cannot recreate the visible rim.

// Note 87. A closed CAD volume lets the slicer fill the former cavity with ordinary
// infill. Outside the door width, preserve the body clearance plane.
// The original rear lobes and the final cork/wire cuts remain authoritative.

// Note 88. Fill the moving plate's own rear seam too. Outside its width the
// original body clearance remains open and unchanged.

// Note 89. Extend through the sculpted roof too; the floor and tested engagement
// depth remain unchanged, and the strand still exits through the door.

// Note 90. The existing guide stop is the lowest safe common bed plane. Trimming the
// lobes below it changes only the underside, without adding material below the
// stop or into the mating body. The cork opening faces upward during printing.

// Note 91. A solid pad laps into the original curved floor. The pocket is cut after the
// union so no original shell material can remain across the disc's entry path.
// The optional thin cover captures the disc after a native insert pause. The
// floor and pocket dimensions stay unchanged in either configuration.

// Note 92. Preserve the source lid's stepped seating plate. The rear edge gives the
// sliding door its full curved crown, so that edge is removed from the cap.

// Note 93. Assembly display changes placement only; the original output remains the default.
