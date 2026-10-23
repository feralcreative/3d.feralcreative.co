// Note 1.
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

use <gridfinity_cup_modules.scad>

// Note 3.
width = 2; // [ 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ]
// Note 4.
depth = 1; // [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ]
// Note 5.
height = 12;
// Note 6.
magnet_diameter = 0;  // .1
// Note 7.
screw_depth = 0;
// Note 8.
hole_overhang_remedy = true;
// Note 9.
box_corner_attachments_only = false;
// Note 10.
filled_in = false;
// Note 11.
chambers = 1;
// Note 12.
withLabel = "disabled"; // ["disabled", "left", "right", "center", "leftchamber", "rightchamber", "centerchamber"]
// Note 13.
fingerslide = false;
// Note 14.
labelWidth = 0;  // .01
// Note 15.
floor_thickness = 0.7;
// Note 16.
wall_thickness = 0.95;  // .01
// Note 17.
efficient_floor = false;
// Note 18.
irregular_subdivisions = false;
// Note 19.
half_pitch = false;
// Note 20.
lip_style = "normal";  // [ "normal", "reduced", "none" ]

module end_of_customizer_opts() {}

// Note 21.
separator_positions = [ 0.25, 0.5, 1.4 ];

// Note 22.

module feral_default_output_ff9cebfaefbb() {
if (filled_in) {
  grid_block(width, depth, height, magnet_diameter=magnet_diameter,
    screw_depth=screw_depth, hole_overhang_remedy=hole_overhang_remedy,
    half_pitch=half_pitch, box_corner_attachments_only=box_corner_attachments_only);
}
else if (irregular_subdivisions) {
  irregular_cup(
    num_x=width,
    num_y=depth,
    num_z=height,
    withLabel=withLabel,
    labelWidth=labelWidth,
    fingerslide=fingerslide,
    magnet_diameter=magnet_diameter,
    screw_depth=screw_depth,
    floor_thickness=floor_thickness,
    wall_thickness=wall_thickness,
    hole_overhang_remedy=hole_overhang_remedy,
    separator_positions=separator_positions,
    half_pitch=half_pitch,
    lip_style=lip_style,
    box_corner_attachments_only=box_corner_attachments_only
  );
}
else {
  basic_cup(
    num_x=width,
    num_y=depth,
    num_z=height,
    chambers=chambers,
    withLabel=withLabel,
    labelWidth=labelWidth,
    fingerslide=fingerslide,
    magnet_diameter=magnet_diameter,
    screw_depth=screw_depth,
    floor_thickness=floor_thickness,
    wall_thickness=wall_thickness,
    hole_overhang_remedy=hole_overhang_remedy,
    efficient_floor=efficient_floor,
    half_pitch=half_pitch,
    lip_style=lip_style,
    box_corner_attachments_only=box_corner_attachments_only
  );
}
}

module feral_assembly_view_ff9cebfaefbb(explode=false) {
feral_default_output_ff9cebfaefbb();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_ff9cebfaefbb();
else feral_assembly_view_ff9cebfaefbb(view == "exploded");

// Notes

// Note 1. include <gridfinity_modules.scad>

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. X dimension in grid units

// Note 4. Y dimension in grid units

// Note 5. Z dimension (multiples of 7mm)

// Note 6. (Zack's design uses magnet diameter of 6.5)

// Note 7. (Zack's design uses depth of 6)

// Note 8. Hole overhang remedy is active only when both screws and magnets are nonzero (and this option is selected)

// Note 9. Only add attachments (magnets and screw) to box corners (prints faster).

// Note 10. Fill in solid block (overrides all following options)

// Note 11. X dimension subdivisions

// Note 12. Include overhang for labeling (and specify left/right/center justification)

// Note 13. Include larger corner fillet

// Note 14. Width of the label in number of units, or zero means full width

// Note 15. Minimum thickness above cutouts in base (Zack's design is effectively 1.2)

// Note 16. Wall thickness (Zack's design is 0.95)

// Note 17. Efficient floor option saves material and time, but the floor is not smooth (only applies if no magnets, screws, or finger-slide used)

// Note 18. When enabled, irregular subdivisions have to be defined in code

// Note 19. Enable to subdivide bottom pads to allow half-cell offsets

// Note 20. Remove some or all of lip

// Note 21. Separator positions are defined in terms of grid units from the left end

// Note 22. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
