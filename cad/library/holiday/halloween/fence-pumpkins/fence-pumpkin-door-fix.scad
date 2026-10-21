// Accepted retrofit door fix for the five existing pumpkins.
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
// Print the sculpted door inner-face down; its raised rear rim needs supports.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <back-outline.scad>
include <back-crown.scad>
use <door-fix-crown-bridge.scad>
include <backing-inset.scad>
include <stem-base-selector.scad>
include <cork-collar-blend.scad>

/* [Seat] */
lid_grow = -0.15;          // mm, slight inward clearance from the original lid's nominal touching fit
lid_edge_r = 23;           // mm, radius of the lid's top edge, to turn lid_grow into a scale
cap_base_z = 29.04747;     // mm, original lid's flat underside; print this face on the bed

/* [Stem] */
stem_grow = 0.3;           // mm, preserve the already printed green stem's original XY scale
stem_cut_z = 30.72;        // mm, stem-to-dish junction; lobed selector removes the exposed orange base
stem_centre = [1.15, 2.36];// mm, stem's centroid at the cut
stem_round_z = 31.5;       // mm, above the lobed base, circular selection clears the dish
stem_select_r = [11.6, 13.2]; // mm, selector radius up to stem_step_z, then above; stem reaches 11.3, rim starts 11.9
stem_step_z = 32;          // mm, rim has fallen back to 13.7 by here; stem never reaches past 12.6
peg_d = 5;                 // mm, locating peg on the pumpkin
peg_h = 3;                 // mm
peg_clearance = 0.15;      // mm per side, glue fit
stem_base_clearance = 0.15; // mm, cap clears the already printed stem's lobed base

/* [Steel disc pocket] */
disc_d = 25;              // mm, nickel-plated steel disc; magnets stay on the fence
disc_t = 2;               // mm, steel thickness
disc_clearance = 0.2;     // mm per side, insertion and glue clearance
disc_glue = 0.2;          // mm adhesive allowance underneath the disc, inside the pumpkin
disc_floor = 2.10;        // mm, solid PETG below the pocket, between steel and fence magnet
disc_wall = 2.10;         // mm, minimum radial wall in the mounting pad
disc_centre = [0, 2];     // mm, centred under the pumpkin
disc_base_z = -26.93;     // mm, closed exterior bottom, just below the source mesh's -26.92879 minimum
disc_cover = true;       // pause-insert trial: enclose the steel disc while printing upright
disc_cover_t = 0.24;      // mm, two 0.12 mm layers above the existing pocket

/* [Walls] */
wall_add = 1.5;            // mm added inside the 1.7 mm wall at the widest point; must stay under 1.7
wall_step = 0.5;           // mm, overlapping inward copies avoid sealed voids within the thicker wall
face_skin = 0.9;           // mm nominal inner skin; curved regions vary, so verify the built mesh and slice
thicken_top_z = 28.5;      // mm, thickening stops below the lid; its rim met the lid's step in pinhead voids

/* [Face] */
face_angle = 7.83;         // degrees about +Z from -Y; nearest ridge crest at the nose's height

/* [Nose] */
nose_w = 9.8;              // mm, 70% of the previous 14 mm width
nose_h = 7.7;              // mm, 70% of the previous 11 mm height
nose_bottom_z = 1.3;       // mm, raised 3.3 mm to keep the upward apex at Z=9
nose_x = 0;                // mm, centred in the face's local coordinates before face_angle

/* [Back wall] */
back_cut_y = 25;           // mm, cut plane; the pumpkin's back is +Y, its face -Y. Must match back-outline.scad
back_wall_t = 4.8;         // mm, flat wall closing the cut, and the door's thickness

/* [Door] */
door_style = "sculpted";    // [sculpted, original]
rear_seam = 0.3;           // mm, restored shell stays behind the existing body's Y=25 rear plane
rear_cork_y = 37.5;        // mm, light axis; the preview head clears the existing stem
rear_cork_top_z = 24;      // mm, flat opening at the original rear shoulder
rear_gusset_inner_x = -22.2; // mm, rounded backing stays inside this original root boundary
rear_gusset_round = 2.1;   // mm, inward round-over; regenerate backing-inset.scad if changed
door_w = 40;               // mm, door width between its tongue roots
door_bottom_z = -17;       // mm, where the door comes to rest; low enough for the wire hole
tongue_depth = 1.8;        // mm, V tongue on each door edge, 45° flanks
door_clearance = 0.3;      // mm per face, sliding fit
crown_start_z = 20;        // mm, replace the flat outline above this height with the source surface
crown_half_w = 24;         // mm, measured crown data spans this strip

/* [Cork collar] */
cork_bore_d = 18.5;        // mm, printed/tested perfect with supplied silicone sheath; preserve
collar_depth = 22;         // mm, printed/tested snug cork-light retention; preserve
collar_wall = 3.5;         // mm, plastic around the bore
collar_blend_depth = 12;  // mm, rounded taper below the holder into the pumpkin
collar_floor = 2;          // mm, closes the bore's bottom
head_clear = 2;            // mm, head stands this far behind the back wall
head_top_z = 33.09;        // mm, head's top level with the pumpkin's, hidden from the front
wire_hole_d = 6;           // mm, light strand from the cork's tip into the pumpkin

/* [Solar light, preview only] */
head_w = 45;               // mm, square solar head (the listing's 1.77 in)
head_h = 20;               // mm, UNMEASURED
flange_d = 30;             // mm, UNMEASURED round flange under the head
flange_h = 6;              // mm, UNMEASURED

/* [Colors] */
pumpkin_color = "DarkOrange"; // preview only
door_color = "DarkOrange";
cap_color = "Orange";
stem_color = "ForestGreen";
light_color = "SaddleBrown";

/* [Output] */
show = "print-door"; // [assembled, exploded, body, door, cap, stem, print-body, print-door, print-cap, print-stem, section, pumpkin]
door_explode = 60;         // mm rearward displacement in the exploded view
stem_explode = 45;         // mm upward displacement, making the separate stem visible
cap_explode = 25;          // mm upward displacement for the optional open-roof cap
preview_light = true;      // show the solar-light stand-in in the assembled view
fused_roof = true;        // trial: restore the integral roof for plate-only support testing

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
shell_centre = [0, 2, 3];  // centre of the shell's bounding box; thickening scales toward it
face_r = 42;               // mm, rough distance from shell_centre to the face's inner surface
shell_r = 46;              // mm, the shell's widest radius from shell_centre
lid_xy_scale = 1 + lid_grow / lid_edge_r;
stem_xy_scale = 1 + stem_grow / lid_edge_r;
disc_pocket_d = disc_d + 2 * disc_clearance;
disc_pocket_depth = disc_t + disc_glue;
face_cut_depth = 100;      // mm, front half-space and facial cutter depth
face_outline_margin = 1;  // mm, omit silhouette-edge slivers from differing source tessellations

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

// Project the front half only: the back of a hollow shell would otherwise
// cover its facial openings. Eroding the blank's outer silhouette excludes
// tiny outline differences between the two meshes, well clear of the face.
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
    // This triangle contains the original nose opening (X=±2, Z=2..6).
    polygon([[nose_x - nose_w / 2, nose_bottom_z],
             [nose_x + nose_w / 2, nose_bottom_z],
             [nose_x, nose_bottom_z + nose_h]]);
}

// Move the feature cutters, not the pumpkin's ridges, lid, rear door or pocket.
module face_cut() translate([shell_centre[0], shell_centre[1], 0])
    rotate([0, 0, face_angle]) rotate([90, 0, 0])
        linear_extrude(height = face_cut_depth, convexity = 10) face_profile();

// Starting from the blank closes the old face before cutting the new position.
// Both the outer shell and its inward thickening use the same rotated face.
module shell() difference() {
    blank();
    face_cut();
}

// A continuous inner skin of the blank shell closes every face opening. The
// ordinary pumpkin walls absorb the rest of this skin. Do not trim it to a
// projected face mask: cleaning that mask removed a narrow mouth strip and
// left a real gap, and its clipped edges left non-manifold membrane joins.
module face_membrane() {
    difference() { blank(); about_centre(1 + face_skin / face_r) blank(); }
}

module lid(grow = lid_grow) scale([1 + grow / lid_edge_r, 1 + grow / lid_edge_r, 1])
    import(str(src, "stem-lid.stl"), convexity = 10);

// The lobed base cannot be separated from the dish with a cylinder. Measured
// outlines keep only the stem below stem_round_z; the upper selection is round.
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

// render() so the preview shows the real piece: OpenCSG draws this intersection
// with the lid's whole dish in green.
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

// The lower outline sits 0.05 mm inside the shell. The crown overlaps it by
// 0.1 mm and follows the actual source surface across the wall's full depth.
module outline_slab(t = back_wall_t) {
    difference() {
        translate([0, back_cut_y, 0]) rotate([90, 0, 0])
            linear_extrude(height = t, convexity = 4) offset(delta = -0.05) for (p = back_outline) polygon(p);
        translate([-crown_half_w, wall_in_y - eps, crown_start_z - eps])
            cube([2 * crown_half_w, back_wall_t + 2 * eps, 100]);
    }
    back_crown();
}

// V tongue along the door's right edge, running up Z. grow moves both 45° flanks
// out by grow along their normals, which turns the tongue into its groove.
module tongue(grow = 0) {
    d = tongue_depth + grow * sqrt(2);
    translate([door_w / 2, mid_y, door_bottom_z - grow])
        linear_extrude(height = 100, convexity = 2)
            polygon([[-eps, -d], [d, 0], [-eps, d]]);
}

// Teardrop pointing +Y, which is up when the door prints face down, with its
// point cut flat at cap above the axis so it stays inside the collar wall.
module teardrop2d(d, cap) intersection() {
    hull() {
        circle(d = d);
        polygon([[-d / (2 * sqrt(2)), d / (2 * sqrt(2))], [d / (2 * sqrt(2)), d / (2 * sqrt(2))], [0, d / sqrt(2)]]);
    }
    translate([-d, -d]) square([2 * d, d + cap]);
}

// Original rear shell, including its lobes and inward wall thickening. The
// entire added shell stays behind the old body, including during insertion.
// Its open cut edge surrounds the original sliding plate; it does not enlarge
// the tongues or require cutting the already printed body's rear wall.
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

// Close the slot within the moving door's own crown. Outside the door width,
// the shell still needs its original rear clearance from the printed body.
// The sampled solid crown fills underneath too, avoiding enclosed slits
// between the shell's separate inner thickening layers.
module rear_crown_bridge() intersection() {
    assert(back_cut_y == 25 && rear_seam == 0.3,
           "regenerate door-fix-crown-bridge.scad for a changed door seam");
    door_fix_crown_bridge();
    translate([-door_w / 2, back_cut_y - eps, crown_start_z])
        cube([door_w, rear_seam + 2 * eps, 100]);
}

// The backing is inset by the round-over radius before the sphere is added
// back. Its front-facing perimeter curls inward rather than growing into a
// visible flange outside the pumpkin. The generated convex inset preserves
// the filled interior and rounds the front, root, top and bottom together.
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

// Fill behind the original cut-edge material without enlarging its footprint.
// The inward round-over can otherwise leave a small space behind the native
// side sliver. This reaches only to the same rounded rear surface and uses
// the existing shell's front section, so it cannot recreate the visible rim.
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

module cork_bore() translate([0, collar_axis_y, collar_top_z - collar_depth])
    // Extend through the sculpted roof too; the floor and tested engagement
    // depth remain unchanged, and the strand still exits through the door.
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

module door() {
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
                rear_shell();
                rear_crown_bridge();
                rear_gusset();
            }
        }
        cork_bore();
        translate([0, wall_in_y - 1, wire_z]) rotate([-90, 0, 0])
            cylinder(d = wire_hole_d, h = collar_axis_y - wall_in_y + 1);
    }
}

module door_slot() {
    translate([-door_w / 2 - door_clearance, wall_in_y - door_clearance, door_bottom_z - door_clearance])
        cube([door_w + 2 * door_clearance, back_wall_t + door_clearance + 1, 100]);
    tongue(door_clearance);
    mirror([1, 0, 0]) tongue(door_clearance);
}

// A solid pad laps into the original curved floor. The pocket is cut after the
// union so no original shell material can remain across the disc's entry path.
// The optional thin cover captures the disc after a native insert pause. The
// floor and pocket dimensions stay unchanged in either configuration.
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

// Preserve the source lid's stepped seating plate. The rear edge gives the
// sliding door its full curved crown, so that edge is removed from the cap.
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



// Assembly display changes placement only; the original output remains the default.
module feral_default_output_36c8510442e2() {
if (show == "assembled") assembly();
else if (show == "exploded") assembly(door_explode, stem_explode, cap_explode);
else if (show == "body") body();
else if (show == "door") door();
else if (show == "cap") cap();
else if (show == "stem") stem();
else if (show == "print-stem") translate([0, 0, -stem_cut_z]) stem();
else if (show == "print-body") translate([0, 0, -disc_base_z]) body();
else if (show == "print-door") translate([0, 0, -wall_in_y]) rotate([90, 0, 0]) door();
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
