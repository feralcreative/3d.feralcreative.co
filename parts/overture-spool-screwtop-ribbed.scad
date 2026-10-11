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
//
// FERAL CREATIVE rings the outward face (+Z: the thread's plain lead-in is at
// Z=0, so that face meets the body and this one faces out). It is the house
// deboss recorded in docs/STATUS.md: 1 mm deep, cut as five bands that narrow
// at 70 degrees, so the mouth is full size and nothing in the cut needs a
// bridge or a support whichever face is on the bed. The phrase goes round
// label_copies times with the feral favicon after each, set tight: every character is
// placed by its own advance width (textmetrics), and the whole ring is spread
// evenly over the full circle so the last favicon closes it. The favicon
// stands label_mark_scale of the capitals' height, centred on them, and takes
// the bullet's place in label_sep: "•" there is a placeholder for it, never cut as a dot. The main body
// uses the same module on its flange underside, mirrored so it reads from
// below.

/* [Source] */
src = "../_originals/printer-tools/reusable-spool-for-overture-cardboard-spools-model_files/cardboardspooladapterv2-assemblyscrewtop.stl";
src_h = 5;              // mm, plate thickness of the original

/* [Rim] */
core_r   = 34;          // mm, original mesh kept inside this radius (petal valleys are at 35.7)
rim_od   = 80;          // mm, diameter at the rib tips (original petal tips: 98, valleys: 71.4)
rib_n    = 48;          // number of ribs
rib_depth = 1.5;        // mm, tip-to-root
chamfer  = 0.6;         // mm, on both rim edges

/* [Lettering] */
label_text   = "FERAL CREATIVE";
label_sep    = " • ";   // follows every copy; "•" is drawn as the feral favicon
label_mark_scale = 0.75; // favicon height as a fraction of the capitals, centred on them
label_copies = 2;
label_font   = "Helvetica Neue:style=Condensed Black"; // the house label face
label_size   = 8;       // mm, nominal text size; caps stand about 8 mm
label_radius = 29.25;   // mm, baseline radius (thread major is 27.5, rib roots 39.25)
label_depth  = 1;       // mm
label_taper  = 70;      // degrees from horizontal, widening toward the face
label_steps  = 5;       // bands in the settled tapered-deboss construction
label_facets = 48;      // segments on curved glyph outlines

/* [Colors] */
screwtop_color = "#d22bd8";

/* [Hidden] */
include <../logos/marks.scad>

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

// Also used by overture-spool-main-body-ribbed.scad, so both ends of the
// spool carry the same grip.
module ribbed_rim(h = src_h, inner_r = core_r - 1) {
    intersection() {
        difference() {
            linear_extrude(h, convexity = 4) polygon(rib_profile());
            translate([0, 0, -eps]) cylinder(r = inner_r, h = h + 2 * eps);
        }
        // Chamfer both edges: a solid of revolution that pulls in by `chamfer`
        // at the top and bottom faces.
        rotate_extrude(convexity = 4) polygon([
            [0, 0],
            [rim_od / 2 - chamfer, 0],
            [rim_od / 2 + eps, chamfer],
            [rim_od / 2 + eps, h - chamfer],
            [rim_od / 2 - chamfer, h],
            [0, h],
        ]);
    }
}

function repeat_str(s, n) = n <= 0 ? "" : str(s, repeat_str(s, n - 1));
function label_adv(s) = textmetrics(s, size = label_size, font = label_font).advance[0];

label_mark  = "•";
label_cap_h = textmetrics("E", size = label_size, font = label_font).size[1];
label_mark_w = label_mark_scale * label_cap_h * FERAL_FAVICON_BOX[1][0] / FERAL_FAVICON_BOX[1][1];

// For parts that `use` this file and need to place the ring themselves.
function label_cap_height() = label_cap_h;

label_ring  = repeat_str(str(label_text, label_sep), label_copies);
label_advs  = [for (c = label_ring) c == label_mark ? label_mark_w : label_adv(c)];
label_cum   = [for (i = 0, a = 0; i < len(label_advs); a = a + label_advs[i], i = i + 1) a];
label_total = label_cum[len(label_cum) - 1] + label_advs[len(label_advs) - 1];

// Upright and reading clockwise from +Z, the first copy centred on +Y, its
// baseline on a circle of `radius`.
module label_artwork(radius = label_radius) {
    assert(label_total <= 2 * PI * radius,
           "The lettering is longer than its baseline circle; shrink it or drop a copy");
    for (i = [0 : len(label_ring) - 1])
        if (label_ring[i] != " ")
            rotate([0, 0, (label_adv(label_text) / 2 - label_cum[i] - label_advs[i] / 2)
                          * 360 / label_total])
                translate([0, radius])
                    if (label_ring[i] == label_mark)
                        translate([0, label_cap_h / 2]) feral_favicon(label_mark_w);
                    else
                        text(label_ring[i], size = label_size, font = label_font,
                             halign = "center", valign = "baseline", $fn = label_facets);
}

// The cut, mouth on Z=0 and narrowing toward +Z. Place it with a transform;
// `mirrored` flips the artwork so it reads from -Z, for a face on the bed.
module label_cut(mirrored = false, radius = label_radius) {
    band = label_depth / label_steps;
    for (k = [0 : label_steps - 1])
        translate([0, 0, band * k - (k == 0 ? eps : 0)])
            linear_extrude(height = band + (k == 0 ? 2 : 1) * eps, convexity = 10)
                offset(delta = -band * k / tan(label_taper))
                    mirror([mirrored ? 1 : 0, 0, 0]) label_artwork(radius);
}

module screwtop() {
    color(screwtop_color) difference() {
        union() {
            original_core();
            ribbed_rim();
        }
        translate([0, 0, src_h]) mirror([0, 0, 1]) label_cut();
    }
}

screwtop();
