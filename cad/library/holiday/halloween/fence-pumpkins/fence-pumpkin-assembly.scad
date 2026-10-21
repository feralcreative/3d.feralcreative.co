// Matching complete fence-post pumpkin assembly, adapted from artwells, Printables 1835966.
// CC BY 4.0: https://creativecommons.org/licenses/by/4.0/
// Keep this SCAD beside the three downloaded final STLs, with their filenames unchanged.
// Each STL stays in its print orientation; transforms below restore the assembled position.
// Authoring geometry and retained source assets remain in fence-pumpkin.scad in the repository.
// This is the new matching body/door set. The separate door-fix STL is for existing pumpkins.

/* [Display] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "assembled"; // [assembled, exploded]
door_explode = 60; // mm rearward along +Y
stem_explode = 45; // mm upward along +Z

/* [LED cork placeholder] */
preview_light = true; // F5 display only; excluded from F6 renders and mesh exports
light_cork_d = 18.5; // mm, existing sheathed-cork socket diameter
light_insert_depth = 22; // mm, existing socket engagement
light_axis_y = 37.5; // mm, holder centre behind the pumpkin
light_seat_z = 24; // mm, top of the holder
light_flange_d = 30; // mm, illustrative flange; unmeasured
light_flange_h = 6; // mm, illustrative flange; unmeasured
light_head_w = 45; // mm, square solar head from the existing stand-in
light_head_h = 20; // mm, illustrative head height; unmeasured
light_panel_inset = 3; // mm, illustrative border around the solar panel
light_panel_t = 0.3; // mm, illustrative panel surface

/* [Colors] */
body_color = "DarkOrange";
door_color = "DarkOrange";
stem_color = "ForestGreen";

/* [Hidden] */
// Website downloads use a project prefix to avoid collisions in the flat model library.
file_prefix = "fence-pumpkins--";
body_z = -26.93;
door_y = 15.2;
stem_z = 30.72;

module body() color(body_color)
    translate([0, 0, body_z]) import(str(file_prefix, "fence-pumpkin-body.stl"), convexity = 10);
module door() color(door_color)
    rotate([-90, 0, 0]) translate([0, 0, door_y])
        import(str(file_prefix, "fence-pumpkin-door.stl"), convexity = 10);
module stem() color(stem_color)
    translate([0, 0, stem_z]) import(str(file_prefix, "fence-pumpkin-stem.stl"), convexity = 10);

// Display accessory only: $preview keeps it out of F6/STL geometry.
module led_cork_placeholder() translate([0, light_axis_y, light_seat_z]) {
    color("Wheat", 0.65) translate([0, 0, -light_insert_depth])
        cylinder(d = light_cork_d, h = light_insert_depth, $fn = 64);
    color("DimGray") cylinder(d = light_flange_d, h = light_flange_h, $fn = 64);
    color("DimGray") translate([-light_head_w / 2, -light_head_w / 2, light_flange_h])
        cube([light_head_w, light_head_w, light_head_h]);
    color("MidnightBlue")
        translate([-light_head_w / 2 + light_panel_inset, -light_head_w / 2 + light_panel_inset,
                   light_flange_h + light_head_h])
            cube([light_head_w - 2 * light_panel_inset, light_head_w - 2 * light_panel_inset, light_panel_t]);
}

module door_with_light() {
    door();
    if (preview_light && $preview) led_cork_placeholder();
}

assert(show == "assembled" || show == "exploded", "Choose assembled or exploded");




// Assembly display changes placement only; the original output remains the default.
module feral_default_output_e4c9a7891833() {
body();
translate([0, show == "exploded" ? door_explode : 0, 0]) door_with_light();
translate([0, 0, show == "exploded" ? stem_explode : 0]) stem();
}

module feral_assembly_view_e4c9a7891833(explode=false) {
body();
translate([0,explode ? door_explode : 0,0]) door_with_light();
translate([0,0,explode ? stem_explode : 0]) stem();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_e4c9a7891833();
else feral_assembly_view_e4c9a7891833(view == "exploded");
