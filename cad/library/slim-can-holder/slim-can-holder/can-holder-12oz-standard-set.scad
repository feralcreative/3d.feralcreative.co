// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

use <can-holder-12oz-standard.scad>
use <slim-can-adapter-ring-12oz-standard-to-slim.scad>
use <slim-can-adapter-ring-12oz-to-8-3oz-nested.scad>

/* [View] */

// Note 3.

config = "lineup";   // [standard, slim-12oz, 8-3oz, lineup]
// Note 4.
exploded = false;
// Note 5.
explode_gap = 40;
// Note 6.
cut = false;
show_cans  = true;
show_tiles = true;
// Note 7.
tile_logo = "wagon-queen";   // [none, wagon-queen]
// Note 8.
lineup_gap = 30;

/* [Colors] */

// Note 9.

can_color = "Silver";
can_alpha = 0.85;

/* [Hidden] */

$fa = 4;
$fs = 0.4;
eps = 0.01;

// Note 10.

can_std  = [66.04, 122.2, 54.0];   // Note 11.
can_slim = [57.40, 155.7, 54.0];   // Note 12.
can_8oz  = [53.00, 134.6, 50.0];   // Note 13.

floor_z = holder_floor_z();
r1_z    = holder_top_z() - ring_standard_to_slim_sleeve_h();
r1_top  = r1_z + ring_standard_to_slim_h();
r2_z    = r1_top - ring_to_8_3oz_sleeve_h();

// Note 14.

module can(spec) {
    R  = spec[0] / 2;
    H  = spec[1];
    Re = spec[2] / 2;
    neck = (R - Re) * 1.6 + 4;     // Note 15.
    Rb = R * 0.80;                 // Note 16.
    color(can_color, can_alpha)
        rotate_extrude()
            polygon([
                [0,        5],
                [Rb - 1.5, 0.6],
                [Rb,       0],
                [Rb + 1,   0],
                [R,        6],
                [R,        H - neck],
                [Re + 1.2, H - 2],
                [Re + 1.2, H],
                [Re,       H],
                [Re - 0.8, H - 6],
                [0,        H - 6]
            ]);
}

// Note 17.

module stack(cfg, g) {
    rings = cfg == "standard" ? 0 : cfg == "slim-12oz" ? 1 : 2;
    lift1 = g > 0 ? holder_top_z() + g - r1_z : 0;
    lift2 = g > 0 ? lift1 + ring_standard_to_slim_h() + g - (r2_z - r1_z) : 0;
    top   = rings == 0 ? holder_top_z()
          : rings == 1 ? r1_top + lift1
          : r2_z + lift2 + ring_to_8_3oz_h();
    spec  = rings == 0 ? can_std : rings == 1 ? can_slim : can_8oz;

    holder_part();
    if (show_tiles) holder_tiles(g / 2, tile_logo);
    if (rings >= 1) translate([0, 0, r1_z + lift1]) ring_standard_to_slim();
    if (rings >= 2) translate([0, 0, r2_z + lift2]) ring_to_8_3oz();
    if (show_cans)
        translate([0, 0, g > 0 ? top + g : floor_z]) can(spec);
}

module scene() {
    g = exploded ? explode_gap : 0;
    if (config == "lineup")
        for (i = [0 : 2])
            translate([(i - 1) * (holder_od() + lineup_gap), 0, 0])
                stack(["standard", "slim-12oz", "8-3oz"][i], g);
    else
        stack(config, g);
}

// Note 18.
module feral_default_output_2ec6c96763f6() {
if (cut)
    difference() {
        scene();
        translate([-1000, -2000, -1]) cube([2000, 2000, 2000]);
    }
else
    scene();
}

module feral_assembly_view_2ec6c96763f6(explode=false) {
g=explode ? explode_gap : 0;
if(config == "lineup") for(i=[0:2]) translate([(i-1)*(holder_od()+lineup_gap),0,0]) stack(["standard","slim-12oz","8-3oz"][i],g);
else stack(config,g);
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_2ec6c96763f6();
else feral_assembly_view_2ec6c96763f6(view == "exploded");

// Notes

// Note 1. The standard 12 oz can holder set, all in one place, with cans.
//
// A viewer, not a part: nothing here is printed and it is never built to an
// STL. It pulls the real geometry out of the three part files, so what you
// see is what they print:
//
// can-holder-12oz-standard.scad                      holder + logo tiles
// slim-can-adapter-ring-12oz-standard-to-slim.scad   ring 1, standard -> slim 12 oz
// slim-can-adapter-ring-12oz-to-8-3oz-nested.scad    ring 2, slim 12 oz -> 8.3 oz
//
// They come in through `use`, not `include`. Each of them defines ribs(),
// fit_coupon(), total_h and the rest, and an include would splice those
// together with the last assignment winning. `use` keeps each file's
// variables to itself, and the viewer calls only the uniquely named entry
// points at the bottom of each file.
//
// The cans are simulated: a body, a neck, a seamed end and a domed base at
// the published sizes. They are there to show what holds what, not to check
// a fit — the fits are the part files' business.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. Which can the holder is set up for: the holder alone, with ring 1, or with
// both rings. "lineup" puts all three side by side.

// Note 4. Seated, or pulled apart along the axis.

// Note 5. Gap between parts when exploded (mm). Tiles move out radially by half this.

// Note 6. Half-section, for seeing the rings nest and the cans stand on the floor.

// Note 7. Logo on the tiles; the choices are the holder's.

// Note 8. Gap between stacks in the lineup (mm).

// Note 9. The parts carry their own colours from their files; the cans are the only
// thing coloured here. Alpha under 1 so the rings show through.

// Note 10. Body diameter, height, end diameter (mm) of each can. The bodies are the
// numbers the parts are cut to; heights and ends are the published sizes and
// only matter to the picture.

// Note 11. standard 355 ml, 211 body, 202 end

// Note 12. sleek 355 ml, 202 end

// Note 13. 250 ml slim, 200 end
// Where everything sits when seated. Each ring hangs from its lip on the top
// of whatever it drops into, so its bottom is that top less its sleeve.

// Note 14. A can as a turned profile: domed base inside a standing ring, a short
// chamfer up to the body, the body, a neck in to the seam, and the end sunk
// inside the seam.

// Note 15. squat cans neck in further and taller

// Note 16. standing ring

// Note 17. One stack: the holder, the rings that config calls for, and its can. g is
// the explode gap, 0 when seated. Exploded, each part steps up by g past the
// top of the one before it, so nothing overlaps whatever the heights.

// Note 18. Assembly display changes placement only; the original output remains the default.
