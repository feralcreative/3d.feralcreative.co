// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <gridfinity-plate-modules.scad>

/* [Grid] */
xsize = 5;              // Note 3.
ysize = 2;              // Note 4.

/* [Plate] */
floor_thickness = 3.0;  // Note 5.

/* [Magnets] */
magnet_hole_d = 10.5;   // Note 6.

magnet_cav_h = 2.2;     // Note 7.
magnet_skin = 0.4;      // Note 8.

$fn = 48;

// Note 9.

module feral_default_output_06ca06093732() {
plate_blocks([[0, 0, xsize, ysize]], floor_ht = floor_thickness,
             magnet_hole_d = magnet_hole_d,
             magnet_cav_h = magnet_cav_h, magnet_skin = magnet_skin);
}

module feral_assembly_view_06ca06093732(explode=false) {
feral_default_output_06ca06093732();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_06ca06093732();
else feral_assembly_view_06ca06093732(view == "exploded");

// Notes

// Note 1. gridfinity-baseplate-5x2.scad — 5 x 2 gridfinity baseplate on a flat floor,
// so it can be stuck down with adhesive strips. Footprint 210 x 84 mm.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. cells across

// Note 4. cells deep

// Note 5. mm of flat sheet under the frame; 0 leaves the
// sockets open. Skin, cavity, skin — see below.

// Note 6. mm cavity for a 10 mm disc — the same +0.5 the
// vendored bins allow on a 6 mm one. 0 for no magnets.

// Note 7. mm tall: a 2 mm disc and 0.2 to drop it in

// Note 8. mm over the cavity and under it — 2 layers at 0.2.
// The discs go in at a pause and the top skin bridges
// over them; nothing is glued and no face is broken.

// Note 9. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
