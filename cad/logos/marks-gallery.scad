// marks-gallery.scad — open THIS in OpenSCAD to look at the marks.
//
// marks.scad is a library: it defines modules and calls none of them, so its
// own preview is empty and always will be. That is not a bug to fix there.
// Parts reach it with `include <../logos/marks.scad>`, and include splices a
// file's TOP-LEVEL GEOMETRY into the including file — so a gallery living in
// marks.scad would draw itself inside every part that includes it. Hence a
// separate file with the geometry, and a library with none.
//
// Every mark is drawn at the same `width`, which is the point: `width` is the
// bounding box the mark is scaled to, not the size the ink comes out, and the
// difference is obvious here. hobbs_mark_word and wagon_queen_crest both look
// undersized because they are holding their partner's place in a shared
// registration; their `_alone` neighbours are the same artwork on its own box.
//
// "cut-safe" marks the ones with no counters, which are the only ones that can
// be cut through a wall. Everything else has to be debossed or raised — a
// through-cut drops its counters on the floor.

include <marks.scad>

/* [Gallery] */
width = 40;      // every mark scaled to this bounding-box width (mm)
col   = 62;      // column pitch (mm)
row   = 115;     // row pitch (mm)
label = 4.2;     // label type size (mm)
label_drop = 54; // label baseline below each mark's centre (mm)

$fn = 64;

module cell(c, r, name, tint) {
    translate([c * col, -r * row]) {
        color(tint) linear_extrude(1) children();
        color("black") translate([0, -label_drop]) linear_extrude(0.2)
            text(name, size = label, halign = "center");
    }
}

cell(0, 0, "hobbs_mark",        "crimson")    hobbs_mark(width);
cell(1, 0, "hobbs_mark_figure · cut-safe", "crimson") hobbs_mark_figure(width);
cell(2, 0, "hobbs_mark_word",   "crimson")    hobbs_mark_word(width);
cell(3, 0, "hobbs_word_alone",  "crimson")    hobbs_word_alone(width);
cell(4, 0, "feral_logo",        "steelblue")  feral_logo(width);
cell(5, 0, "vmc_top_rocker",    "seagreen")   vmc_top_rocker(width);
cell(6, 0, "feral_favicon · cut-safe", "steelblue") feral_favicon(width);

cell(0, 1, "zr_mark · cut-safe",     "darkorange") zr_mark(width);
cell(1, 1, "zr_monogram · cut-safe", "darkorange") zr_monogram(width);
cell(2, 1, "wagon_queen",            "purple")     wagon_queen(width);
cell(3, 1, "wagon_queen_crest · cut-safe", "purple") wagon_queen_crest(width);
cell(4, 1, "wagon_queen_word",       "purple")     wagon_queen_word(width);
cell(5, 1, "wagon_queen_crest_alone · cut-safe", "purple")
    wagon_queen_crest_alone(width);
