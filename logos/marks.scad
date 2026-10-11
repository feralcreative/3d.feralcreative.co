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
// WHAT CAN BE CUT THROUGH: the Hobbs figure, both ZR marks, and the feral
// favicon. Everything else carries counters that a through-cut drops on the
// floor — HOBBS has three, the feral logo has its entire wordmark floating inside the frame, and the
// Vampires rocker is knocked out of a solid banner, so every letter in it is a
// hole. Deboss or raise those. The two ZRs are safe because neither has a
// counter at all: extruded, they come out as three and four disjoint solids
// with nothing enclosed, so a through-cut leaves holes and nothing loose.
// The favicon is one solid silhouette with no counters at all.
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
FERAL_FAVICON_BOX = [[  5.293, 17.286], [342.193, 318.204]];
VMC_BOX        = [[  0.000, 3.845], [352.777, 256.928]];
ZR_BOX         = [[  0.000, 0.000], [333.309, 270.705]];
ZR_MONO_BOX    = [[  0.000, 0.000], [181.150, 123.472]];
// The Wagon Queen lockup: crest over lettering, in one file. All three boxes
// are measured off the same import, so the two halves share the lockup's
// registration exactly the way the Hobbs pair do.
WAGON_QUEEN_BOX       = [[  0.000,   0.349], [746.806, 1613.609]];
WAGON_QUEEN_CREST_BOX = [[ 86.405, 673.100], [606.804,  940.858]];
WAGON_QUEEN_WORD_BOX  = [[  0.000,   0.349], [746.806,  569.034]];

// What a mark stands to when it is placed `width` across.
//
// ⚠️ EACH ONE ANSWERS FOR ITS OWN BOX, which is not always the module of the
// same name. hobbs_word_height and wagon_queen_crest_height describe the
// `_alone` variants, because those are the ones registered to that box; the
// half-marks registered to a lockup's box come out smaller. Measured at
// width 40: wagon_queen_crest_height says 62.02, wagon_queen_crest_alone
// delivers exactly that, and wagon_queen_crest delivers 32.50 x 50.39 because
// it is still holding the lettering's place. wagon_queen_word is the harmless
// case — its box is the full lockup width, so both readings agree at 30.48.
function mark_height(box, width)   = width * box[1][1] / box[1][0];
function hobbs_mark_height(width)  = mark_height(HOBBS_BOX, width);
function hobbs_word_height(width)  = mark_height(HOBBS_WORD_BOX, width);
function feral_logo_height(width)  = mark_height(FERAL_BOX, width);
function feral_favicon_height(width) = mark_height(FERAL_FAVICON_BOX, width);
function vmc_rocker_height(width)  = mark_height(VMC_BOX, width);
function zr_mark_height(width)     = mark_height(ZR_BOX, width);
function zr_monogram_height(width) = mark_height(ZR_MONO_BOX, width);
function wagon_queen_height(width)       = mark_height(WAGON_QUEEN_BOX, width);
function wagon_queen_crest_height(width) = mark_height(WAGON_QUEEN_CREST_BOX, width);
function wagon_queen_word_height(width)  = mark_height(WAGON_QUEEN_WORD_BOX, width);

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

// The feral favicon: the logo's frame and notch as one solid silhouette, no
// lettering. Small enough marks lose the wordmark anyway; this is the one to
// use as an inline glyph or a bullet.
module feral_favicon(width = 30, $fn = 0) {
    place_mark(FERAL_FAVICON_BOX, width) import("favicon.svg");
}

module vmc_top_rocker(width = 30, $fn = 0) {
    place_mark(VMC_BOX, width) import("vmc-top-rocker.svg");
}

// The ZR mark: heavy, blocky, no counters. The one to reach for on a material
// that swallows fine detail, and — with the monogram below and the Hobbs figure
// — one of the three here that survives a through-cut.
module zr_mark(width = 30, $fn = 0) {
    place_mark(ZR_BOX, width) import("logo-zr.svg");
}

// The ZR monogram: the same two letters as a high-contrast serif, four disjoint
// pieces and no counters.
//
// ⚠️ IT IS A HAIRLINE DESIGN and the thins are what set its size. They are
// 1.4% of its height — 0.58 mm on a 60 mm mark, 0.70 on 50, and the artwork
// would have to stand 86 mm wide before they reached two 0.42 lines on their
// own. Below that, swell the whole mark with offset(delta = ) before cutting
// and let the thicks carry the extra: +0.25 takes a 50 mm mark's thins to
// 1.20 mm while the heavy diagonal only goes 4.2 to 4.7, which at reading
// distance is the same drawing. parts/deck-door-stop.scad does exactly that.
module zr_monogram(width = 30, $fn = 0) {
    place_mark(ZR_MONO_BOX, width) import("monogram-zr.svg");
}

// THE WAGON QUEEN LOCKUP — a three-balled crown over five bars and a rule,
// with "Wagon Queen" in script beneath it. Crown, bars and rule together are
// what the modules below call the crest. Tall: 2.16 times its own width, so
// `width` buys a lot less than it does on the other marks here. Ask for 40 and
// you get 86.4 mm of height.
//
// ONE FILE, SPLIT WITH A HALF-PLANE. The crest and the lettering are separate
// halves of one SVG rather than two files, because the artwork leaves a 103.7 mm
// band of empty space between the rule and the top of the W. Clipping there
// keeps one source of truth — a second file would be the same drawing twice and
// free to drift out of registration, which is the trap the Hobbs pair are
// carefully arranged to avoid rather than one to repeat.
//
// WHAT CAN BE CUT THROUGH: the crest, and only the crest. Extruded it comes out
// as SEVEN disjoint solids — the crown, the five bars, the rule — and every one
// of them is genus 0, so it has no counters at all and a through-cut leaves
// holes and nothing loose. That puts it with the ZR marks and the Hobbs figure.
//
// The lettering is the opposite and it is not close: three shells carrying
// EIGHT counters between them (genus 5, 2 and 1 — the a, the g's two, the o,
// the n's, the Q, and both e's). A through-cut drops all eight on the floor.
// Deboss it or raise it. The same goes for the full lockup, which is just the
// two halves together.
//
// Measured, not assumed: the boxes above and the counter counts come from
// extruding each half and reading the mesh back.
WAGON_QUEEN_SPLIT = 621.25;   // the empty band, in imported millimetres

// Either half of the lockup, clipped out of the one import. The band it cuts
// through is 103.7 mm of nothing, from 569.4 to 673.1, so this line has about
// 45 mm of slack in each direction — moving it anywhere inside the band gives
// a bit-identical result, which is what makes a hardcoded number safe here.
// Remeasure it along with the boxes if the SVG is ever replaced.
module wagon_queen_half(upper) intersection() {
    import("logo-wagon-queen.svg");
    translate([-1000, upper ? WAGON_QUEEN_SPLIT : WAGON_QUEEN_SPLIT - 3000])
        square([3000, 3000]);
}

// The whole lockup. Counters: deboss or raise, never cut through.
module wagon_queen(width = 30, $fn = 0) {
    place_mark(WAGON_QUEEN_BOX, width) import("logo-wagon-queen.svg");
}

// The two halves ON THE LOCKUP'S registration, so they can be mixed on one
// part — crest cut through a wall and lettering debossed below it, say — and
// still line up the way they do in the artwork.
module wagon_queen_crest(width = 30, $fn = 0) {
    place_mark(WAGON_QUEEN_BOX, width) wagon_queen_half(true);
}

module wagon_queen_word(width = 30, $fn = 0) {
    place_mark(WAGON_QUEEN_BOX, width) wagon_queen_half(false);
}

// The crest USED ON ITS OWN, registered to its own box, so `width` is the
// width of the crest rather than of the lockup it was cut from. Ask
// wagon_queen_crest for a 40 mm mark and you get 32.5 mm of crest, because it
// is still holding the lettering's place below it.
//
// There is deliberately no wagon_queen_word_alone. The lettering already runs
// the full width of the lockup — both boxes are 746.806 across — so registered
// and alone would differ only in where the origin sits, and wagon_queen_word
// is already the answer.
module wagon_queen_crest_alone(width = 30, $fn = 0) {
    place_mark(WAGON_QUEEN_CREST_BOX, width) wagon_queen_half(true);
}
