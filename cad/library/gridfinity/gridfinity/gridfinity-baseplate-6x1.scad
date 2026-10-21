// gridfinity-baseplate-6x1.scad — six sockets on a flat adhesive-strip floor.
// Footprint 252 x 42 mm. Rotate 45 degrees in the slicer for the AD5M Pro:
// rounded corners give a measured 204.8 x 204.8 mm mesh footprint, inside
// the documented 205 mm safe design envelope before any brim or skirt.

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <gridfinity-plate-modules.scad>

/* [Grid] */
xsize = 6;              // cells across
ysize = 1;              // cells deep

/* [Plate] */
floor_thickness = 3.0;  // mm; flat underside for adhesive strips

/* [Magnets] */
magnet_hole_d = 10.5;   // mm cavity for a 10 mm disc; four per cell
magnet_cav_h = 2.2;     // mm; 2 mm disc plus insertion clearance
magnet_skin = 0.4;      // mm above and below each enclosed cavity

$fn = 48;

module gridfinity_baseplate_6x1() {
  plate_blocks([[0, 0, xsize, ysize]], floor_ht = floor_thickness,
               magnet_hole_d = magnet_hole_d,
               magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_9085f37f7e2e() {
gridfinity_baseplate_6x1();
}

module feral_assembly_view_9085f37f7e2e(explode=false) {
feral_default_output_9085f37f7e2e();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_9085f37f7e2e();
else feral_assembly_view_9085f37f7e2e(view == "exploded");
