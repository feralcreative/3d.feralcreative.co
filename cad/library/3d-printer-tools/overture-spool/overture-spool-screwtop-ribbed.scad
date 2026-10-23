// Note 1.

/* [Source] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

src = "originals/printer-tools/reusable-spool-for-overture-cardboard-spools-model_files/cardboardspooladapterv2-assemblyscrewtop.stl";
src_h = 5;              // Note 3.

/* [Rim] */
core_r   = 34;          // Note 4.
rim_od   = 80;          // Note 5.
rib_n    = 48;          // Note 6.
rib_depth = 1.5;        // Note 7.
chamfer  = 0.6;         // Note 8.

/* [Lettering] */
label_text   = "FERAL CREATIVE";
label_copies = 2;       // Note 9.
label_mark_scale = 0.75; // Note 10.
label_font   = "Helvetica Neue:style=Condensed Black"; // Note 11.
label_size   = 6;       // Note 12.
label_tracking_min = 0.4; // Note 13.
label_tracking_mix = 0.5; // Note 14.
label_mid    = (27.5 + 39.25) / 2; // Note 15.
label_depth  = 1;       // Note 16.
label_taper  = 70;      // Note 17.
label_steps  = 5;       // Note 18.
label_facets = 48;      // Note 19.

/* [Colors] */
screwtop_color = "#d22bd8";

/* [Hidden] */
include <../../../logos/marks.scad>

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

// Note 20.

module ribbed_rim(h = src_h, inner_r = core_r - 1) {
    intersection() {
        difference() {
            linear_extrude(h, convexity = 4) polygon(rib_profile());
            translate([0, 0, -eps]) cylinder(r = inner_r, h = h + 2 * eps);
        }
        // Note 21.

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

function label_adv(s) = textmetrics(s, size = label_size, font = label_font).advance[0];

label_cap_h  = textmetrics("E", size = label_size, font = label_font).size[1];
label_mark_w = label_mark_scale * label_cap_h * FERAL_FAVICON_BOX[1][0] / FERAL_FAVICON_BOX[1][1];
label_advs   = [for (c = label_text) label_adv(c)];
label_space  = label_adv(" ");
label_ink    = [for (i = 0, a = 0; i < len(label_advs); a = a + label_advs[i], i = i + 1) a];
label_adv_sum = label_ink[len(label_ink) - 1] + label_advs[len(label_advs) - 1];

// Note 22.

function label_fill_tracking(radius) =
    (2 * PI * radius / label_copies - label_adv_sum - label_mark_w - 2 * label_space)
    / (len(label_text) + 1);

function label_tracking(radius) =
    label_tracking_min + label_tracking_mix * (label_fill_tracking(radius) - label_tracking_min);

// Note 23.
function label_baseline(mid) = mid - label_cap_h / 2;

// Note 24.

module label_artwork(mid = label_mid) {
    radius = label_baseline(mid);
    deg = 180 / (PI * radius);          // Note 25.
    share = 360 / label_copies;
    t = label_tracking(radius);
    width = label_adv_sum + (len(label_text) - 1) * t;
    assert(label_fill_tracking(radius) >= t,
           "The lettering is longer than its baseline circle; shrink it or drop a copy");
    for (c = [0 : label_copies - 1]) {
        for (i = [0 : len(label_text) - 1])
            if (label_text[i] != " ")
                rotate([0, 0, -c * share
                              - (label_ink[i] + i * t + label_advs[i] / 2 - width / 2) * deg])
                    translate([0, radius])
                        text(label_text[i], size = label_size, font = label_font,
                             halign = "center", valign = "baseline", $fn = label_facets);
        rotate([0, 0, -c * share - share / 2])
            translate([0, radius + label_cap_h / 2]) feral_favicon(label_mark_w);
    }
}

// Note 26.

module label_cut(mirrored = false, mid = label_mid) {
    band = label_depth / label_steps;
    for (k = [0 : label_steps - 1])
        translate([0, 0, band * k - (k == 0 ? eps : 0)])
            linear_extrude(height = band + (k == 0 ? 2 : 1) * eps, convexity = 10)
                offset(delta = -band * k / tan(label_taper))
                    mirror([mirrored ? 1 : 0, 0, 0]) label_artwork(mid);
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

// Note 27.

module feral_default_output_c7e0e07445a4() {
screwtop();
}

module feral_assembly_view_c7e0e07445a4(explode=false) {
feral_default_output_c7e0e07445a4();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_c7e0e07445a4();
else feral_assembly_view_c7e0e07445a4(view == "exploded");

function overture_screwtop_height() = src_h;

// Note 28.

// 1.
// Note 29.

// 2.
// Note 30.

// 3.
// Note 31.

// 4.
// Note 32.

// 5.
// Note 33.

// 6.
// Note 34.

// 7.
// Note 35.

// 8.
// Note 36.

// 9.
// Note 37.

// 10.
// Note 38.

// 11.
// Note 39.

// 12.
// Note 40.

// 13.
// Note 41.

// 14.
// Note 42.

// 15.
// Note 43.

// 16.
// Note 44.

// 17.
// Note 45.

// 18.
// Note 46.

// 19.
// Note 47.

// 20.
// Note 48.

// 21.
// Note 49.

// 22.
// Note 50.

// 23.
// Note 51.

// 24.
// Note 52.

// 25.
// Note 53.

// 26.
// Note 54.

// 27.
// Note 55.

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

// Note 10. Note 10.

// Note 11. Note 11.

// Note 12. Note 12.

// Note 13. Note 13.

// Note 14. Note 14.

// Note 15. Note 15.

// Note 16. Note 16.

// Note 17. Note 17.

// Note 18. Note 18.

// Note 19. Note 19.

// Note 20. Note 20.

// Note 21. Note 21.

// Note 22. Note 22.

// Note 23. Note 23.

// Note 24. Note 24.

// Note 25. Note 25.

// Note 26. Note 26.

// Note 27. Note 27.

// Note 28. Notes

// Note 29. overture-spool-screwtop-ribbed.scad
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
// label_copies times, each copy centred on its own share of the circle, with
// the feral favicon centred in the gap between copies. Characters are placed
// by their own advance widths (textmetrics) plus tracking. The tracking is
// label_tracking_mix of the way from label_tracking_min to the value that
// would make the copies fill the circle exactly (one word space either side
// of each favicon); whatever circle is left over goes to the favicon gaps. It
// is solved per ring, so a smaller ring gets less. The
// favicon stands label_mark_scale of the capitals' height, centred on them.
// The ring is centred across the flat face between the thread and the rib
// roots. The main body uses the same module on its flange underside, mirrored
// so it reads from below.

// Note 30. default preserves the original part, coupon and print selectors.

// Note 31. mm, plate thickness of the original

// Note 32. mm, original mesh kept inside this radius (petal valleys are at 35.7)

// Note 33. mm, diameter at the rib tips (original petal tips: 98, valleys: 71.4)

// Note 34. number of ribs

// Note 35. mm, tip-to-root

// Note 36. mm, on both rim edges

// Note 37. a favicon sits centred between each pair

// Note 38. favicon height as a fraction of the capitals, centred on them

// Note 39. the house label face

// Note 40. mm, nominal text size; caps stand about 6.1 mm

// Note 41. mm between characters at mix 0

// Note 42. 0 = label_tracking_min, 1 = fill the circle

// Note 43. mm, ring centre line: midway from thread major to rib roots

// Note 44. mm

// Note 45. degrees from horizontal, widening toward the face

// Note 46. bands in the settled tapered-deboss construction

// Note 47. segments on curved glyph outlines

// Note 48. Also used by overture-spool-main-body-ribbed.scad, so both ends of the
// spool carry the same grip.

// Note 49. Chamfer both edges: a solid of revolution that pulls in by `chamfer`
// at the top and bottom faces.

// Note 50. Tracking that fills a baseline circle of `radius`: each copy's share of the
// circle holds the copy, its favicon, and two word spaces beside the favicon,
// with the tracking repeated in every gap — len - 1 inside the copy, two
// beside the favicon.

// Note 51. Baseline radius that centres the capitals on a given centre line.

// Note 52. Upright and reading clockwise from +Z, the first copy centred on +Y, the
// capitals centred on a circle of `mid`.

// Note 53. degrees per mm of baseline

// Note 54. The cut, mouth on Z=0 and narrowing toward +Z. Place it with a transform;
// `mirrored` flips the artwork so it reads from -Z, for a face on the bed.

// Note 55. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
