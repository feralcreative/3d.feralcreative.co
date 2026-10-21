// ZR monogram stamp, 2026.
//
// A 2 in wide, 10 mm thick tile carrying the ZR monogram over "2026" as a
// stamp for fresh concrete: the artwork is MIRRORED so the impression reads
// the right way round, stands relief mm proud so the tile's face never reaches
// the surface and leaves no edge, and carries a small draft so it pulls out
// clean. The tile is as tall as the two marks and their margins need — it is
// computed, not set.
//
// THE MONOGRAM IS A HAIRLINE DESIGN — see the warning on zr_monogram in
// logos/marks.scad. As drawn, its thins are 1.4% of its height, 0.40 mm at
// this size, and that is nothing in concrete: a 0.4 mm blade 6 mm tall would
// snap off the print before it ever took an impression, and if it survived
// the aggregate would not follow it. So the whole mark is swollen by mono_swell
// before it is extruded and the thicks carry the extra. +1.0 takes the thins to
// 2.4 mm and the heavy diagonal from 4.2 to 6.2, which at reading distance is
// the same drawing. Push it back toward 0.25 (the deck door stop's number, for
// a 1 mm deboss in TPU) and the mark gets finer and more fragile in step.
//
// THE DRAFT IS A STAIRCASE, the same way the deck door stop cuts its pocket:
// the relief is built in draft_steps slices, each inset a little further than
// the one below. Every stroke loses relief * tan(draft) per side at the top,
// 0.31 mm at the defaults — cheap on the swollen thins, invisible on the year.
//
// THE YEAR'S BOX IS MEASURED, not computed: textmetrics() is still behind an
// --enable flag that none of the scripts pass, so the bounding box of "2026"
// at size 10 was read once with it and is pinned below, the same way
// marks.scad pins the SVG boxes. Change the string or the font and remeasure:
//
//   openscad --enable=textmetrics -o /dev/null <<< 'echo(textmetrics("2026", size = 10, font = "Arial:style=Bold"));'

/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

include <../../../logos/marks.scad>

/* [Tile] */

width       = 50.8;   // mm — 2 in
thickness   = 10;     // mm

// Radius on the tile's four vertical corners.
corner_r    = 5;      // mm

// Radius on the edges of the top and bottom faces.
edge_r      = 1.5;    // mm

// Border around the artwork on every side. 4.4 is what a 42 mm mark leaves on
// a 50.8 mm tile, so the top and bottom match the sides.
margin      = 4.4;    // mm

// Air between the bottom of the monogram and the top of the year.
gap         = 5;      // mm

/* [Stamp] */

// Mirror the artwork so the impression reads correctly. Off gives a plaque.
mirrored    = true;

// How far the artwork stands off the face — the deepest the stamp can go
// before the tile itself touches the concrete.
relief      = 6;      // mm

// Taper on every stroke's side wall so the stamp releases. 0 is straight.
draft       = 3;      // deg

// Slices the draft is built from. More is smoother and slower.
draft_steps = 6;

/* [Marks] */

// Width of both the monogram and the year across the face.
mark_width  = 42;     // mm

// Uniform outward swell of the monogram before extrusion. See the header.
mono_swell  = 1.0;    // mm

year        = "2026";
year_font   = "Arial:style=Bold";

// Preview only — colour() is ignored by the STL export, it is there so the
// raised work reads against the tile in OpenSCAD and the renders.
mark_color  = "SlateBlue";

/* [Hidden] */

$fn = 64;
eps = 0.01;

// [[min corner], [size]] of `year` in `year_font` at size 10, per textmetrics.
YEAR_BOX  = [[0.3456, -0.1728], [30.0593, 10.1568]];
YEAR_SIZE = 10;

year_h = mark_height(YEAR_BOX, mark_width);
mono_h = zr_monogram_height(mark_width);
height = margin + mono_h + gap + year_h + margin;

echo(str("tile ", width, " x ", height, " x ", thickness, " mm; monogram ",
         mono_h, " tall, year ", year_h, " tall; thins ",
         0.014 * mono_h + 2 * mono_swell, " mm at the base, ",
         0.014 * mono_h + 2 * (mono_swell - relief * tan(draft)), " at the top"));

// The year scaled to mark_width and centred on the origin, like place_mark.
module year_mark() {
    place_mark(YEAR_BOX, mark_width)
        text(year, size = YEAR_SIZE, font = year_font);
}

// The 2D child stood off the face as a drafted relief, mirrored if the part is
// a stamp. Each slice starts eps inside the one below (and the first inside
// the tile) so no two share a face.
module raised() {
    step  = relief / draft_steps;
    erode = step * tan(draft);
    color(mark_color)
        translate([0, 0, thickness])
            for (k = [0 : draft_steps - 1])
                translate([0, 0, k * step - eps])
                    linear_extrude(height = step + eps, convexity = 10)
                        offset(delta = -k * erode)
                            mirror([mirrored ? 1 : 0, 0, 0])
                                children();
}

// The rounded block: the outline with the vertical corners rounded, shrunk by
// edge_r all round and then grown back with a sphere, so every edge of the
// top and bottom faces carries edge_r and the vertical corners stay at
// corner_r. Convex, so the minkowski is cheap.
module tile() {
    minkowski() {
        translate([0, 0, edge_r])
            linear_extrude(height = thickness - 2 * edge_r)
                offset(r = corner_r - edge_r) offset(delta = -corner_r)
                    square([width, height]);
        sphere(r = edge_r);
    }
}

module zr_stamp() {
    union() {
        tile();
        translate([width / 2, height - margin - mono_h / 2, 0])
            raised() offset(delta = mono_swell) zr_monogram(mark_width);
        translate([width / 2, margin + year_h / 2, 0])
            raised() year_mark();
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_1bb8322b6e76() {
zr_stamp();
}

module feral_assembly_view_1bb8322b6e76(explode=false) {
feral_default_output_1bb8322b6e76();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_1bb8322b6e76();
else feral_assembly_view_1bb8322b6e76(view == "exploded");
