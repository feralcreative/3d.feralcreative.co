// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

use <overture-spool-screwtop-ribbed.scad>

/* [Source] */
body_src = "originals/printer-tools/reusable-spool-for-overture-cardboard-spools-model_files/cardboardspooladapterv2-assemblymain-body.stl";
body_h   = 76;          // Note 3.
flange_h = 2;           // Note 4.
bore_r   = 24.5;        // Note 5.
flange_extra = 3;       // Note 6.

/* [Rim] */
body_core_r = 34;       // Note 7.

/* [Lettering] */
body_label_mid = (24.5 + 39.25) / 2; // Note 8.

/* [Colors] */
body_color = "#2bb5d8";

/* [Hidden] */
$fn = 180;
eps = 0.01;

module original_body_core() {
    intersection() {
        import(body_src, convexity = 10);
        translate([0, 0, -eps]) cylinder(r = body_core_r, h = body_h + 2 * eps);
    }
}

module main_body() {
    color(body_color) difference() {
        union() {
            translate([0, 0, flange_extra]) original_body_core();
            ribbed_rim(h = flange_h + flange_extra, inner_r = body_core_r - 1);
            difference() {
                cylinder(r = body_core_r, h = flange_extra + eps);
                translate([0, 0, -eps]) cylinder(r = bore_r, h = flange_extra + 3 * eps);
            }
        }
        label_cut(mirrored = true, mid = body_label_mid);
    }
}

// Note 9.
module feral_default_output_6036a5c929f6() {
main_body();
}

module feral_assembly_view_6036a5c929f6(explode=false) {
main_body();
translate([0,0,body_h+flange_extra-overture_screwtop_height()+(explode ? 35 : 0)]) screwtop();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_6036a5c929f6();
else feral_assembly_view_6036a5c929f6(view == "exploded");

// Note 10.

// 1.
// Note 11.

// 2.
// Note 12.

// 3.
// Note 13.

// 4.
// Note 14.

// 5.
// Note 15.

// 6.
// Note 16.

// 7.
// Note 17.

// 8.
// Note 18.

// 9.
// Note 19.

// Notes

// Note 1. Note 1.

// Note 2. Note 2.

// Note 3. Note 3.

// Note 4. Note 4.

// Note 5. Note 5.

// Note 6. Note 6.

// Note 7. Note 7.

// Note 8. Note 8.

// Note 9. Note 9.

// Note 10. Notes

// Note 11. overture-spool-main-body-ribbed.scad
//
// The main body from "Reusable Spool for Overture Cardboard Spools"
// (_originals/printer-tools/reusable-spool-for-overture-cardboard-spools-
// model_files/), with its plain 80 mm flange given the same ribbed grip edge
// as overture-spool-screwtop-ribbed.scad, so the two ends of the spool match
// and there is something to hold on to while the screw-top goes on.
//
// THE BODY IS NOT REDRAWN. Above the flange the body never leaves r 27.5
// (measured off the mesh), so the original is clipped to a cylinder of
// body_core_r: that keeps the barrel, its windows and the external thread at
// the top exactly as published, plus the inner part of the flange, and drops
// only the flange's square outer edge. The ribbed rim is unioned back in at
// flange_total_h. The rim's diameter, rib count, depth and
// chamfer all come from the screwtop file, so changing them there changes
// both parts.
//
// THE FLANGE IS THICKENED DOWNWARD. The original flange is 2 mm; the screwtop
// is 5 mm because its thread runs its full thickness. To make the two ends
// match, flange_extra is added BELOW the original flange: the whole original
// is lifted by that much and a plain tube at the bore's own radius fills the
// gap. The face the cardboard core sits against, and everything above it,
// keeps its height relative to the flange top, so the gap for the core is
// unchanged. The part is flange_extra taller overall.
//
// FERAL CREATIVE is debossed into the flange underside with the screwtop's
// label_cut(), mirrored so it reads from below. That face prints on the bed,
// so the cut opens on the first layer and narrows upward at 70 degrees. The
// flange face runs from the 24.5 bore to the rib roots, wider than the
// screwtop's, so the ring is centred on this face's own centre line rather
// than the screwtop's.

// Note 12. default preserves the original part, coupon and print selectors.

// Note 13. mm, overall height of the original

// Note 14. mm, flange thickness of the original

// Note 15. mm, bore radius at the original's base

// Note 16. mm, added below the flange so it matches the 5 mm screwtop

// Note 17. mm, original mesh kept inside this radius (barrel is r 27.5)

// Note 18. mm, midway between the bore and the rib roots

// Note 19. Assembly display changes placement only; the original output remains the default.
