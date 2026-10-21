// Adapted from The Magic Magnet Polarity Tool v2 by tjdesign.
// https://www.printables.com/model/461166-the-magic-magnet-polarity-tool-v2
// Original meshes: CC BY-NC 4.0. Retain attribution with redistributed remixes.
// Preserve the four original grips and keyed pin fit. Enlarge only the head
// and matching covers in XY; retain thread pitch and all axial dimensions.
// Print one shaft, one head, one pin and one cover per completed tool.
// Glue the pin/head/shaft and the magnet; leave the threaded cover removable.

/* [Output] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "plate"; // [plate, shaft-a, shaft-b, shaft-c, shaft-d, cover-smooth, cover-b, cover-c, cover-d, head, pin, assembly, section]
shaft_style = "A"; // [A, B, C, D]
cover_style = "Smooth"; // [Smooth, B, C, D]

/* [Magnet] */
magnet_d = 10;             // mm, nominal magnet diameter
magnet_h = 2;              // mm, nominal magnet thickness
magnet_d_clearance = 0.5;  // mm, diametral glue/fit allowance
magnet_h_clearance = 0.2;  // mm, recess below head rim
head_nominal_wall = 1.5;   // mm, radial wall at nominal cylindrical tip

/* [Measured original dimensions] */
original_tip_d = 10;       // mm, tip outside diameter before enlargement
original_pocket_d = 8;     // mm, original pocket diameter
original_head_h = 11;      // mm, original head from glue face to magnet face
original_pocket_floor = 8.5; // mm, original pocket floor above glue face
original_socket_h = 5;    // mm, keyed socket depth in both mating pieces
original_socket_envelope_r = 4.1; // mm, contains the entire keyed socket
shaft_base_z = 5;         // mm, original shaft's glue face
cover_base_z = -6.4;      // mm, original outside working face
pin_base_z = 0.5;         // mm, original pin bottom
pin_h = 9;                // mm, original keyed pin length
thread_pitch = 1.75;      // mm/revolution, measured from original mesh
cover_seated_angle = 315; // degrees, collision-free assembled thread phase

/* [Hidden] */
pocket_facets = 96;       // Keep bore compensation stable under external use<>.
$fn = pocket_facets;
eps = 0.01;
source_root = "originals/the-magic-magnet-polarity-tool-v2-model_files/";
head_source = str(source_root, "magnet-tool-threads.stl");
pocket_d = magnet_d + magnet_d_clearance;
pocket_h = magnet_h + magnet_h_clearance;
head_scale = (pocket_d + 2*head_nominal_wall) / original_tip_d;
socket_fill_r = original_socket_envelope_r * head_scale;
pocket_fill_r = original_pocket_d/2 * head_scale + eps;
plate_pitch = 26;         // mm, layout spacing, not a mating dimension

assert(pocket_h < original_head_h-original_socket_h,
       "Magnet pocket must leave solid material above the pin socket");
assert(head_scale >= 1, "This adaptation enlarges the original head");

module original_head() {
    import(head_source, convexity=10);
}

// Extract the original non-round key instead of approximating it as a bore.
module socket_profile() {
    difference() {
        circle(r=original_socket_envelope_r);
        projection(cut=true)
            translate([0,0,-original_socket_h/2]) original_head();
    }
}

module head() {
    difference() {
        union() {
            scale([head_scale,head_scale,1]) original_head();
            // Restore the original pin socket after enlarging the outside.
            cylinder(r=socket_fill_r, h=original_socket_h+eps);
            // Close the old magnet recess, then cut the new independent size.
            translate([0,0,original_pocket_floor-eps])
                cylinder(r=pocket_fill_r,
                         h=original_head_h-original_pocket_floor+eps);
        }
        translate([0,0,-eps])
            linear_extrude(height=original_socket_h+eps, convexity=10)
                socket_profile();
        translate([0,0,original_head_h-pocket_h])
            cylinder(d=pocket_d/cos(180/pocket_facets), h=pocket_h+eps,
                     $fn=pocket_facets);
    }
}

module shaft(style="A") {
    translate([0,0,-shaft_base_z])
        import(str(source_root,"Shafts/Magnet Tool Shaft ",style,".stl"),
               convexity=10);
}

module cover_original_pose(style="Smooth") {
    filename = style == "Smooth" ? "Magnet Tool Cover Smooth.stl"
                               : str("Magnet Tool Cover Texture ",style,".stl");
    scale([head_scale,head_scale,1])
        import(str(source_root,"Tool Covers/",filename), convexity=10);
}

module cover(style="Smooth") {
    translate([0,0,-cover_base_z]) cover_original_pose(style);
}

module pin() {
    translate([0,0,-pin_base_z])
        import(str(source_root,"Magnet Tool Pin.stl"),convexity=10);
}

// Assembly uses the originals' shaft glue plane at Z=5. The head flips about
// X: its socket key is at -Y in print pose, while the shaft/pin key is at +Y.
module assembly(style=shaft_style, cap=cover_style) {
    color("silver") translate([0,0,shaft_base_z]) shaft(style);
    color("orange") translate([0,0,shaft_base_z]) rotate([180,0,0]) head();
    color("gray") translate([0,0,pin_base_z]) pin();
    color("red",0.5) rotate([0,0,cover_seated_angle]) cover_original_pose(cap);
    color("black") translate([0,0,shaft_base_z-original_head_h+magnet_h_clearance])
        cylinder(d=magnet_d,h=magnet_h);
}

module plate() {
    for (i=[0:3]) {
        translate([plate_pitch*i,0,0]) shaft(["A","B","C","D"][i]);
        translate([plate_pitch*i,-plate_pitch,0])
            cover(["Smooth","B","C","D"][i]);
    }
    translate([plate_pitch*4,-plate_pitch,0]) head();
    translate([plate_pitch*5,-plate_pitch,0]) pin();
}



// Assembly display changes placement only; the original output remains the default.
module feral_default_output_9d5b72060754() {
if (show == "plate") plate();
else if (show == "head") head();
else if (show == "pin") pin();
else if (show == "shaft-a") shaft("A");
else if (show == "shaft-b") shaft("B");
else if (show == "shaft-c") shaft("C");
else if (show == "shaft-d") shaft("D");
else if (show == "cover-smooth") cover("Smooth");
else if (show == "cover-b") cover("B");
else if (show == "cover-c") cover("C");
else if (show == "cover-d") cover("D");
else if (show == "assembly") assembly();
else if (show == "section") intersection() {
    assembly();
    translate([-plate_pitch,0,-plate_pitch])
        cube([plate_pitch*2,plate_pitch,plate_pitch*6]);
}
else assert(false,str("Unknown output: ",show));
}

module feral_assembly_view_9d5b72060754(explode=false) {
color("silver") translate([0,0,shaft_base_z]) shaft(shaft_style);
color("orange") translate([0,0,shaft_base_z-(explode ? 25 : 0)]) rotate([180,0,0]) head();
color("gray") translate([explode ? 20 : 0,0,pin_base_z]) pin();
color("red",0.7) translate([0,0,explode ? -55 : 0]) rotate([0,0,cover_seated_angle]) cover_original_pose(cover_style);
color("black") translate([explode ? -20 : 0,0,shaft_base_z-original_head_h+magnet_h_clearance]) cylinder(d=magnet_d,h=magnet_h);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_9d5b72060754();
else feral_assembly_view_9d5b72060754(view == "exploded");
