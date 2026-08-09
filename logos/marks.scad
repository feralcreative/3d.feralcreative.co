// marks.scad — the logo library.
//
// Every mark in here is a 2D shape, centred on the origin and scaled so its
// bounding box comes out `width` millimetres across. What you extrude it into
// decides what it becomes: sink it and it is a deboss, stand it proud and it is
// a relief, run it through a wall and it is a stencil. The library has no
// opinion about which.
//
//   include <../logos/marks.scad>
//   linear_extrude(0.8) hobbs_mark(48);
//
// USE THIS RATHER THAN import(). Three things go wrong when a part imports the
// SVG itself, and every one of them had already gone wrong at least once before
// this file existed.
//
// TESSELLATION. OpenSCAD's SVG importer honours $fn and ignores $fa and $fs
// outright — setting them changes nothing at all. So artwork silently inherits
// whatever resolution the part happens to be working at, and the parts here work
// at $fn = 64. That costs the Hobbs mark 39,808 triangles against the importer's
// own floor of 12,532, for an outline that lands around 0.03 mm at print size
// either way. Every module below pins $fn = 0 over its own import, so the mark
// gets no vote on the part's curves and the part gets none on the mark's.
//
// PATHS. A relative path inside import() resolves against the file the statement
// is written in, not the file you ran. Keeping the imports in here, next to the
// SVGs, is what makes them resolve from anywhere. It matters more than it
// sounds, because of how OpenSCAD fails: a missing import prints an ERROR and
// then *exits 0*, so the render finishes, build.sh sees success, and you get an
// STL of a part with no artwork on it. Nothing downstream will catch that.
//
// REGISTRATION. The Hobbs figure and wordmark are separate files because the
// pyramid cuts one through the wall and raises the other. They stay aligned only
// because both are scaled and centred against the bounding box of the pair
// rather than their own. Easy to get wrong by hand; impossible to get wrong from
// here, which is the whole reason the split layers share one box below.
//
// WHAT CAN BE CUT THROUGH: the Hobbs figure, and nothing else. Everything else
// carries counters that a through-cut drops on the floor — HOBBS has three, the
// feral logo has its entire wordmark floating inside the frame, and the Vampires
// rocker is knocked out of a solid banner, so every letter in it is a hole.
// Deboss or raise those.
//
// NATIVE SIZES are measured off OpenSCAD's own import rather than read off the
// viewBox, because the two do not agree — the importer works in millimetres at
// 96 dpi and the artwork carries its own whitespace. Remeasure if a file is ever
// replaced; a wrong box here shows up as a mark that is off-centre everywhere at
// once.

/* [Hidden] */

// [[min corner], [size]], in the millimetres OpenSCAD produces on import.
HOBBS_BOX      = [[  0.000, 0.180], [705.551, 471.131]];  // figure and word together
HOBBS_WORD_BOX = [[121.237, 0.180], [401.015,  75.219]];  // the wordmark on its own
FERAL_BOX      = [[  0.000, 0.000], [292.453, 342.019]];
VMC_BOX        = [[  0.000, 3.845], [352.777, 256.928]];

// What a mark stands to when it is placed `width` across.
function mark_height(box, width)   = width * box[1][1] / box[1][0];
function hobbs_mark_height(width)  = mark_height(HOBBS_BOX, width);
function hobbs_word_height(width)  = mark_height(HOBBS_WORD_BOX, width);
function feral_logo_height(width)  = mark_height(FERAL_BOX, width);
function vmc_rocker_height(width)  = mark_height(VMC_BOX, width);

// Scale to width, centre on the origin.
module place_mark(box, width) {
    scale(width / box[1][0])
        translate(-(box[0] + box[1] / 2))
            children();
}

// The Hobbs maker's mark: both layers, or either alone. All three share one
// registration, so they can be mixed on the same part and still line up.
module hobbs_mark(width = 30, $fn = 0) {
    place_mark(HOBBS_BOX, width) {
        import("hobbs-mark-figure.svg");
        import("hobbs-mark-word.svg");
    }
}

module hobbs_mark_figure(width = 30, $fn = 0) {
    place_mark(HOBBS_BOX, width) import("hobbs-mark-figure.svg");
}

module hobbs_mark_word(width = 30, $fn = 0) {
    place_mark(HOBBS_BOX, width) import("hobbs-mark-word.svg");
}

// The wordmark used ON ITS OWN, registered to its own bounding box, so `width`
// is the width of the lettering rather than of the pair it was cut from. Reach
// for this one whenever the figure is not on the part as well — ask
// hobbs_mark_word for a 40 mm mark and you get 22.7 mm of lettering, because it
// is still holding the figure's place beside it.
module hobbs_word_alone(width = 30, $fn = 0) {
    place_mark(HOBBS_WORD_BOX, width) import("hobbs-mark-word.svg");
}

module feral_logo(width = 30, $fn = 0) {
    place_mark(FERAL_BOX, width) import("feral-creative-logo.svg");
}

module vmc_top_rocker(width = 30, $fn = 0) {
    place_mark(VMC_BOX, width) import("vmc-top-rocker.svg");
}
