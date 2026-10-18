// One-piece jack-o'-lantern: artwells' "LED tea light jack-o-lantern pumpkins"
// (Printables 1835966, CC BY 4.0) traditional shell and stem lid, fused, with
// the back quarter cut off and closed by a flat wall carrying a sliding door.
// The door holds a solar cork light: its cork plugs into a collar on the door
// like a bottle neck, the panel faces the sky from behind the pumpkin, its top
// level with the pumpkin's so it hides from the front, and the light strand runs
// from the cork's tip through a hole in the door into the pumpkin.
//
// The walls are thickened inward by a copy of the shell scaled toward its centre,
// which adds wall_add at the widest point and less toward the top and bottom.
// The face is not thickened: the eyes, nose and mouth stay carved recesses from
// outside, closed only by a face_skin membrane on the inside so they glow
// brighter than the rest. The membrane comes from artwells' blank shell, which
// matches the traditional one everywhere but the face.
//
// The lid drops into the shell's top opening on a stepped plate and rests on the
// rim. The clearance ring around the plate is closed above by that contact and
// open below, so it is simply part of the pumpkin's hollow inside and needs no
// filling; the lid's top is a dish, and anything filling the opening would raise
// its floor. The lid's top edge sits flush with the rim, so the lid is not moved
// down: lowering it left a visible step. Instead it is grown outward by lid_grow
// at its edge, so it laps onto the rim at the same height; where they only
// touched, a union left non-manifold edges and loose specks.
//
// back-outline.scad is the pumpkin's filled outline on the cut plane; OpenSCAD
// can section the hollow shell but not fill the section. Regenerate it whenever
// back_cut_y changes:
//   utils/section-outline.py led-tea-light-jack-o-lantern-pumpkins-model_files/traditional-shell.stl --axis y --at 25 --name back_outline -o back-outline.scad

include <back-outline.scad>

/* [Seat] */
lid_grow = 0.3;            // mm, lid edge pushed outward onto the rim so contact becomes overlap
lid_edge_r = 23;           // mm, radius of the lid's top edge, to turn lid_grow into a scale

/* [Walls] */
wall_add = 1.0;            // mm added inside the 1.7 mm wall at the widest point; must stay under 1.7
face_skin = 0.55;          // mm nominal membrane over the eyes, nose and mouth; measures 0.43-0.62, about one extrusion line
thicken_top_z = 28.5;      // mm, thickening stops below the lid; its rim met the lid's step in pinhead voids

/* [Back wall] */
back_cut_y = 25;           // mm, cut plane; the pumpkin's back is +Y, its face -Y. Must match back-outline.scad
back_wall_t = 4.8;         // mm, flat wall closing the cut, and the door's thickness

/* [Door] */
door_w = 40;               // mm, door width between its tongue roots
door_bottom_z = -17;       // mm, where the door comes to rest; low enough for the wire hole
tongue_depth = 1.8;        // mm, V tongue on each door edge, 45° flanks
door_clearance = 0.3;      // mm per face, sliding fit

/* [Cork collar] */
cork_bore_d = 18.5;        // mm, UNMEASURED: a standard wine-bottle neck bore
collar_depth = 22;         // mm, UNMEASURED: bore depth the cork plugs into
collar_wall = 3.5;         // mm, plastic around the bore
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
door_color = "Peru";
light_color = "SaddleBrown";

/* [Output] */
show = "assembled"; // [assembled, body, door, print-body, print-door, section, pumpkin]

/* [Hidden] */
$fn = 96;
eps = 0.01;
src = "led-tea-light-jack-o-lantern-pumpkins-model_files/";
wall_in_y = back_cut_y - back_wall_t;
mid_y = back_cut_y - back_wall_t / 2;
collar_r = cork_bore_d / 2 + collar_wall;
collar_axis_y = back_cut_y + head_w / 2 + head_clear;
collar_top_z = head_top_z - head_h - flange_h;
collar_z0 = collar_top_z - collar_depth - collar_floor;
wire_z = collar_top_z - collar_depth + wire_hole_d / 2 + 0.5;
shell_centre = [0, 2, 3];  // centre of the shell's bounding box; thickening scales toward it
face_r = 42;               // mm, rough distance from shell_centre to the face's inner surface
shell_r = 46;              // mm, the shell's widest radius from shell_centre

assert(2 * tongue_depth < back_wall_t, "the V tongue must fit inside the wall's thickness");
assert(collar_r < door_w / 2, "the collar must sit within the door's width");
assert(wall_add < 1.7, "the thickening copy must overlap the 1.7 mm wall, or it floats free inside");
assert(wire_z - wire_hole_d / 2 > door_bottom_z + 1, "the wire hole must pass through the door, not under it");

module about_centre(k) translate(shell_centre) scale(k) translate(-shell_centre) children();

module shell() import(str(src, "traditional-shell.stl"), convexity = 10);
module blank() import(str(src, "blank-shell.stl"), convexity = 10);

// The face cut-outs seen from the front, as a prism through the front half. The
// blank and traditional meshes are tessellated differently, so their difference
// also carries hairline slivers along every edge; opening the silhouette by
// 0.3 mm drops those before they become loose flakes. The last 0.35 mm laps the
// membrane into the cut-out walls, which it would otherwise only touch.
module face_prism() rotate([90, 0, 0]) linear_extrude(height = 60, convexity = 6)
    offset(delta = 0.35) offset(r = 0.3) offset(r = -0.3)
        projection() rotate([-90, 0, 0]) difference() { blank(); shell(); }

// The innermost face_skin of the blank shell, kept only behind the face cut-outs.
module face_membrane() intersection() {
    difference() { blank(); about_centre(1 + face_skin / face_r) blank(); }
    face_prism();
}

module pumpkin() {
    union() {
        shell();
        intersection() {
            about_centre(1 - wall_add / shell_r) shell();
            translate([-100, -100, -100]) cube([200, 200, 100 + thicken_top_z]);
        }
        face_membrane();
        scale([1 + lid_grow / lid_edge_r, 1 + lid_grow / lid_edge_r, 1])
            import(str(src, "stem-lid.stl"), convexity = 10);
    }
}

// The cut plane's outline, given thickness back into the pumpkin. Pulled in 0.05 mm
// so its rim sits inside the shell wall instead of exactly on its outer surface.
module outline_slab(t = back_wall_t) {
    translate([0, back_cut_y, 0]) rotate([90, 0, 0])
        linear_extrude(height = t, convexity = 4) offset(delta = -0.05) for (p = back_outline) polygon(p);
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

module cork_collar() {
    difference() {
        hull() {
            translate([0, collar_axis_y, collar_z0]) cylinder(r = collar_r, h = collar_top_z - collar_z0);
            translate([-collar_r, back_cut_y - eps, collar_z0]) cube([2 * collar_r, eps, collar_top_z - collar_z0]);
        }
        translate([0, collar_axis_y, collar_top_z - collar_depth])
            linear_extrude(height = collar_depth + 1) teardrop2d(cork_bore_d, cork_bore_d / 2 + 1.5);
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
        }
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

module body() {
    color(pumpkin_color) difference() {
        union() {
            intersection() {
                pumpkin();
                translate([-100, -100 + back_cut_y, -100]) cube(100 * [2, 1, 2]);
            }
            outline_slab();
        }
        door_slot();
    }
}

module solar_light() {
    color(light_color, 0.5) translate([0, collar_axis_y, collar_top_z]) {
        cylinder(d = flange_d, h = flange_h);
        translate([-head_w / 2, -head_w / 2, flange_h]) cube([head_w, head_w, head_h]);
    }
}

if (show == "assembled") { body(); door(); solar_light(); }
else if (show == "body") body();
else if (show == "door") door();
else if (show == "print-body") translate([0, 0, back_cut_y]) rotate([-90, 0, 0]) body();
else if (show == "print-door") translate([0, 0, -wall_in_y]) rotate([90, 0, 0]) door();
else if (show == "section") difference() {
    union() { body(); door(); }
    translate([0, -100, -100]) cube(200);
}
else if (show == "pumpkin") color(pumpkin_color) pumpkin();
else assert(false, str("unknown show: ", show));
