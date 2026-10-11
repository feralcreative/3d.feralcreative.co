// overture-spool-main-body-ribbed.scad
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
// the flange's own 2 mm thickness. The rim's diameter, rib count, depth and
// chamfer all come from the screwtop file, so changing them there changes
// both parts.

use <overture-spool-screwtop-ribbed.scad>

/* [Source] */
body_src = "../_originals/printer-tools/reusable-spool-for-overture-cardboard-spools-model_files/cardboardspooladapterv2-assemblymain-body.stl";
body_h   = 76;          // mm, overall height of the original
flange_h = 2;           // mm, flange thickness of the original

/* [Rim] */
body_core_r = 34;       // mm, original mesh kept inside this radius (barrel is r 27.5)

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
    color(body_color) union() {
        original_body_core();
        ribbed_rim(h = flange_h, inner_r = body_core_r - 1);
    }
}

main_body();
