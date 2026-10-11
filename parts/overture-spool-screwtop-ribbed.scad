// overture-spool-screwtop-ribbed.scad
//
// The screw-top ring from "Reusable Spool for Overture Cardboard Spools"
// (_originals/printer-tools/reusable-spool-for-overture-cardboard-spools-
// model_files/), with its eight-petal flower outline swapped for a round,
// ribbed grip edge.
//
// THE THREAD IS NOT REDRAWN. The original is a flat 5 mm plate whose only
// working feature is the internal thread (55.0 mm major / 51.54 mm minor,
// measured off the mesh) that screws onto the main body. That thread is kept
// exactly as published: the original mesh is clipped to a cylinder of
// core_r, which removes every petal and keeps the threaded inner ring, and the
// new ribbed rim is unioned around it. The petals' valleys come in to r 35.7,
// so anything inside that radius was already solid all the way round and the
// clamping face the cardboard core sees is unchanged.
//
// The ribs are a sine profile rather than sharp teeth, so they print clean on
// the outer wall and do not chew fingers. Both rim edges are chamfered, which
// also trims the rib tips there and keeps the first layer free of elephant's
// foot on the grip.

/* [Source] */
src = "../_originals/printer-tools/reusable-spool-for-overture-cardboard-spools-model_files/cardboardspooladapterv2-assemblyscrewtop.stl";
src_h = 5;              // mm, plate thickness of the original

/* [Rim] */
core_r   = 34;          // mm, original mesh kept inside this radius (petal valleys are at 35.7)
rim_od   = 80;          // mm, diameter at the rib tips (original petal tips: 98, valleys: 71.4)
rib_n    = 48;          // number of ribs
rib_depth = 1.5;        // mm, tip-to-root
chamfer  = 0.6;         // mm, on both rim edges

/* [Colors] */
screwtop_color = "#d22bd8";

/* [Hidden] */
$fn = 180;
eps = 0.01;

rim_r_mid = rim_od / 2 - rib_depth / 2;

function rib_profile() = [
    for (i = [0 : rib_n * 12 - 1])
        let(a = 360 * i / (rib_n * 12),
            r = rim_r_mid + rib_depth / 2 * cos(rib_n * a))
        [r * cos(a), r * sin(a)]
];

module original_core() {
    intersection() {
        import(src, convexity = 10);
        translate([0, 0, -eps]) cylinder(r = core_r, h = src_h + 2 * eps);
    }
}

module ribbed_rim() {
    intersection() {
        difference() {
            linear_extrude(src_h, convexity = 4) polygon(rib_profile());
            translate([0, 0, -eps]) cylinder(r = core_r - 1, h = src_h + 2 * eps);
        }
        // Chamfer both edges: a solid of revolution that pulls in by `chamfer`
        // at the top and bottom faces.
        rotate_extrude(convexity = 4) polygon([
            [0, 0],
            [rim_od / 2 - chamfer, 0],
            [rim_od / 2 + eps, chamfer],
            [rim_od / 2 + eps, src_h - chamfer],
            [rim_od / 2 - chamfer, src_h],
            [0, src_h],
        ]);
    }
}

module screwtop() {
    color(screwtop_color) union() {
        original_core();
        ribbed_rim();
    }
}

screwtop();
