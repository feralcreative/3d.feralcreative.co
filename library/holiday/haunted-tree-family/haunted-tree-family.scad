// DIY Wizard's Cute Haunted Tree Family, adapted for the same LED puck pocket
// Ziad physically approved in pumpkin-body.scad. Original bark and faces remain
// imported geometry. Source meshes stay unchanged in originals/.
// Trees print upright. The default interior fills the unused candle cavity and
// leaves a cone-roofed light channel to the original face openings.

include <face-openings.scad>

/* [View] */
show = "grin"; // [grin, oh, sad, teeth, teeth-flat, diffuser, assembly, section, channel, fitcheck, insertioncheck]
tree = "grin"; // [grin, oh, sad, teeth, teeth-flat]
interior = "cone"; // [cone, hollow]

/* [Size] */
tree_scale = 1.6; // uniform scale of each original tree
floor_overlap = 0.4; // mm, floor extends into the existing tree wall
source_taper = 2; // degrees, measured taper of the original candle bore

/* [Light channel] */
channel_forward = 8; // mm, cone apex shifted toward the face to shorten the eye passages
channel_ridge_half = 26; // mm, ridge spans the eyes so the light path stays connected
channel_roof_angle = 45; // degrees from vertical, maximum inward roof slope
channel_cap_gap = 0.2; // mm, cone apex below the original interior ceiling
channel_fill_overlap = 0.25; // mm, joins the filler to the original ceiling
face_port_length = 80; // mm, face passages run along +X to the outside
face_port_clear = 0.6; // mm, clearance behind the source face openings

/* [LED puck—proven pumpkin pocket] */
puck_d = 59.4; // mm
puck_h = 8.0; // mm
puck_fit = 0.15; // mm per side—physically approved in the pumpkin
puck_depth_extra = 0.1; // mm
puck_lens_d = 47.6; // mm, lit lens kept clear
puck_roof = 1.5; // mm, same 45 degree pocket stop as pumpkin
cable_d = 2.8; // mm
cable_clear = 0.3; // mm per side
cable_angle = 180; // degrees, cable exits behind the face, along -X
cable_length = 120; // mm, exceeds the root footprint

/* [Diffuser] */
diffuser_xy_scale = 1.28; // radial scale; passes through the pocket roof
diffuser_z_scale = 1.4; // shortened to clear the lowest tree cavity roof
diffuser_collar_d = 55.8; // mm, passes through the 56.7 mm roof opening
diffuser_collar_h = 1.5; // mm, resting on the puck outside the lens
diffuser_source_bottom = -36.2; // mm, original cup bottom
diffuser_source_height = 50.4; // mm, original closed-cap cup height

/* [Verification] */
insertion_start = -90; // mm, puck's back fully outside the tree
diffuser_start = -100; // mm, diffuser fully outside the tree

/* [Colors] */
tree_color = "#805335";
diffuser_color = "#E9E5D4";
puck_color = "#C8C8C8";

/* [Resolution] */
$fn = 180;
eps = 0.01;

source_center = [-1.3, -1.2]; // mm, original candle bore axis
source_centers = [source_center, source_center, source_center, source_center, [-1.016, -0.911]]; // mm, sad's bore is shifted
source_files = ["haunted tree grin.stl", "haunted tree teeth.stl", "Teeth Tree flat snug fit.stl", "haunted-tree-oh.stl", "haunted-tree-sad.stl"];
// Sad has one root extending 0.332 mm below its main base plane; trim it flat.
source_bottoms = [-36.5, -36.703853607177734, -37.271156311035156, -36.70000076293945, -36.900001525878906]; // mm
source_bore_radii = [21.38, 22.49, 21.0, 21.39, 21.2]; // mm at each original base
source_ceiling_z = [14.666199684143066, 15.665849685668945, 13.822471618652344, 14.666199684143066, 13.787643432617188]; // mm, downward-facing cavity ceilings in source coordinates
pocket_d = puck_d + 2 * puck_fit;
pocket_h = puck_h + puck_depth_extra;
floor_top = pocket_h + puck_roof;
diffuser_height = diffuser_source_height * diffuser_z_scale;
clip_size = 400; // mm, exceeds the model envelope

function tree_index(t) = t == "grin" ? 0 : t == "teeth" ? 1 : t == "teeth-flat" ? 2 : t == "oh" ? 3 : 4;
function circumscribed(d) = d / cos(180 / $fn);

module original_tree(t) {
    i = tree_index(t);
    scale(tree_scale)
        translate([-source_centers[i][0], -source_centers[i][1], -source_bottoms[i]])
            import(str("originals/", source_files[i]), convexity = 10);
}

module puck_cutouts() {
    pd = circumscribed(pocket_d);
    translate([0, 0, -eps]) cylinder(d = pd, h = pocket_h + eps);
    translate([0, 0, pocket_h - eps])
        cylinder(d1 = pd, d2 = pd - 2 * (puck_roof + 2 * eps), h = puck_roof + 2 * eps);
    cw = cable_d + 2 * cable_clear;
    rotate([0, 0, cable_angle])
        translate([0, -cw / 2, -eps]) cube([cable_length, cw, cw + eps]);
}

// Enclosed holes were extracted from each original front-half projection. Warp
// their inner ends down by their distance from the bore axis, then shear the
// extrusion upward toward the face. Every passage roof rises 1:1 along X.
module face_ports(t) {
    i = tree_index(t);
    fr = source_bore_radii[i] * tree_scale + floor_overlap;
    multmatrix([[1, 0, 0, 0], [0, 1, 0, 0], [1, 0, 1, 0], [0, 0, 0, 1]])
        rotate([0, 90, 0]) linear_extrude(height = face_port_length, convexity = 10)
            for (loop = face_opening_contours[i])
                offset(r = face_port_clear)
                    polygon([for (p = loop)
                        let(z = -p[0] * tree_scale, y = p[1] * tree_scale,
                            r = fr - z * tan(source_taper), x = sqrt(max(0, r * r - y * y)))
                        [-(z - x), y]]);
}

module light_channel(t) {
    i = tree_index(t);
    cr = (circumscribed(pocket_d) - 2 * puck_roof) / 2;
    top = (source_ceiling_z[i] - source_bottoms[i]) * tree_scale - channel_cap_gap;
    cone_h = (cr + channel_forward) / tan(channel_roof_angle);
    cone_base = top - cone_h;
    assert(cone_base > floor_top, "Not enough height for a support-free light channel");
    assert(channel_forward < cr, "Cone apex must remain within the base circle");
    union() {
        translate([0, 0, floor_top - eps]) cylinder(r = cr, h = cone_base - floor_top + 2 * eps);
        hull() {
            translate([0, 0, cone_base]) cylinder(r = cr, h = eps);
            translate([channel_forward, -channel_ridge_half, top - eps])
                cube([eps, 2 * channel_ridge_half, eps]);
        }
        face_ports(t);
    }
}

module interior_fill(t) {
    i = tree_index(t);
    fr = source_bore_radii[i] * tree_scale + floor_overlap;
    top = (source_ceiling_z[i] - source_bottoms[i]) * tree_scale + channel_fill_overlap;
    translate([0, 0, floor_top])
        cylinder(r1 = fr - floor_top * tan(source_taper), r2 = fr - top * tan(source_taper), h = top - floor_top);
}

module tree_body(t) {
    i = tree_index(t);
    fr = source_bore_radii[i] * tree_scale + floor_overlap;
    assert(fr - floor_top * tan(source_taper) > pocket_d / 2 + 1.2,
           "Tree scale is too small for the proven puck pocket and surrounding wall");
    color(tree_color) difference() {
        union() {
            original_tree(t);
            cylinder(r1 = fr, r2 = fr - floor_top * tan(source_taper), h = floor_top);
            if (interior == "cone") difference() {
                interior_fill(t);
                light_channel(t);
            }
        }
        puck_cutouts();
        translate([-clip_size / 2, -clip_size / 2, -clip_size])
            cube([clip_size, clip_size, clip_size]);
    }
}

// Located at Z=0 for printing or path checks; assembled bottom is Z=pocket_h.
module diffuser_upright() {
    assert(diffuser_collar_d < pocket_d - 2 * puck_roof - 0.4,
           "Diffuser collar must pass through the pocket roof");
    color(diffuser_color) union() {
        scale([diffuser_xy_scale, diffuser_xy_scale, diffuser_z_scale])
            translate([-source_center[0], -source_center[1], -diffuser_source_bottom])
                import("originals/haunted tree candle diffusor.stl", convexity = 10);
        translate([0, 0, eps]) difference() {
            cylinder(d = diffuser_collar_d, h = diffuser_collar_h - eps);
            translate([0, 0, -eps]) cylinder(d = circumscribed(puck_lens_d), h = diffuser_collar_h + 2 * eps);
        }
    }
}

module diffuser_print() {
    translate([0, 0, diffuser_height]) rotate([180, 0, 0]) diffuser_upright();
}

module puck_dummy() {
    color(puck_color) union() {
        cylinder(d = puck_d, h = puck_h);
        rotate([0, 0, cable_angle]) translate([puck_d / 2 - 2, 0, cable_d / 2])
            rotate([0, 90, 0]) cylinder(d = cable_d, h = cable_length, $fn = 36);
    }
}

// Configuration-space search constrained to the direct bottom-entry translation:
// swept envelopes connect fully outside to seated and include every intermediate
// translation, without raster or step-size error.
module puck_insertion_envelope() {
    cylinder(d = puck_d, h = puck_h + puck_depth_extra - insertion_start);
    rotate([0, 0, cable_angle])
        translate([puck_d / 2 - 2, -cable_d / 2, 0])
            cube([cable_length, cable_d, cable_d + puck_depth_extra - insertion_start]);
}

module diffuser_insertion_envelope() {
    cylinder(d = diffuser_collar_d, h = diffuser_height + pocket_h - diffuser_start);
}

module fitcheck(t) {
    intersection() {
        tree_body(t);
        union() {
            translate([0, 0, puck_depth_extra]) puck_dummy();
            if (interior == "hollow") translate([0, 0, pocket_h]) diffuser_upright();
        }
    }
}

module insertioncheck(t) {
    intersection() {
        tree_body(t);
        union() {
            translate([0, 0, insertion_start]) puck_insertion_envelope();
            if (interior == "hollow") translate([0, 0, diffuser_start]) diffuser_insertion_envelope();
        }
    }
}

module assembly(t) {
    tree_body(t);
    translate([0, 0, puck_depth_extra]) puck_dummy();
    if (interior == "hollow") translate([0, 0, pocket_h]) diffuser_upright();
}

if (show == "grin" || show == "teeth" || show == "teeth-flat" || show == "oh" || show == "sad") tree_body(show);
else if (show == "diffuser") diffuser_print();
else if (show == "assembly") assembly(tree);
else if (show == "channel") intersection() {
    interior_fill(tree);
    light_channel(tree);
}
else if (show == "section") difference() {
    assembly(tree);
    translate([0, -clip_size / 2, -eps]) cube([clip_size, clip_size, clip_size]);
}
else if (show == "fitcheck") fitcheck(tree);
else if (show == "insertioncheck") insertioncheck(tree);
