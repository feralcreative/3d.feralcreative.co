// Note 1.

/* [Display] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

show = "assembled"; // [assembled, exploded]
door_explode = 60; // Note 3.
stem_explode = 45; // Note 4.

/* [LED cork placeholder] */
preview_light = true; // Note 5.
light_cork_d = 18.5; // Note 6.
light_insert_depth = 22; // Note 7.
light_axis_y = 37.5; // Note 8.
light_seat_z = 24; // Note 9.
light_flange_d = 30; // Note 10.
light_flange_h = 6; // Note 11.
light_head_w = 45; // Note 12.
light_head_h = 20; // Note 13.
light_panel_inset = 3; // Note 14.
light_panel_t = 0.3; // Note 15.

/* [Colors] */
body_color = "DarkOrange";
door_color = "DarkOrange";
stem_color = "ForestGreen";

/* [Hidden] */
// Note 16.
file_prefix = "fence-pumpkins--";
body_z = -26.93;
door_z = -17;
stem_z = 30.72;

module body() color(body_color)
    translate([0, 0, body_z]) import(str(file_prefix, "fence-pumpkin-body.stl"), convexity = 10);
module door() color(door_color)
    translate([0, 0, door_z])
        import(str(file_prefix, "fence-pumpkin-door.stl"), convexity = 10);
module stem() color(stem_color)
    translate([0, 0, stem_z]) import(str(file_prefix, "fence-pumpkin-stem.stl"), convexity = 10);

// Note 17.
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

// Note 18.
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

// Notes

// Note 1. Matching complete fence-post pumpkin assembly, adapted from artwells, Printables 1835966.
// CC BY 4.0: https://creativecommons.org/licenses/by/4.0/
// Keep this SCAD beside the three downloaded final STLs, with their filenames unchanged.
// Each STL stays in its print orientation; transforms below restore the assembled position.
// The closed door prints upright on its flat underside as one piece.
// Authoring geometry and retained source assets remain in fence-pumpkin.scad in the repository.
// This is the new matching body/door set. The separate door-fix STL is for existing pumpkins.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm rearward along +Y

// Note 4. mm upward along +Z

// Note 5. F5 display only; excluded from F6 renders and mesh exports

// Note 6. mm, existing sheathed-cork socket diameter

// Note 7. mm, existing socket engagement

// Note 8. mm, holder centre behind the pumpkin

// Note 9. mm, top of the holder

// Note 10. mm, illustrative flange; unmeasured

// Note 11. mm, illustrative flange; unmeasured

// Note 12. mm, square solar head from the existing stand-in

// Note 13. mm, illustrative head height; unmeasured

// Note 14. mm, illustrative border around the solar panel

// Note 15. mm, illustrative panel surface

// Note 16. Website downloads use a project prefix to avoid collisions in the flat model library.

// Note 17. Display accessory only: $preview keeps it out of F6/STL geometry.

// Note 18. Assembly display changes placement only; the original output remains the default.
