// Slim can koozie — 250 ml Red Bull can in a 2023 Chevy Silverado cup holder.
//
// A cup with a floor. The can drops in and sits on the bottom; you lift the
// koozie and the can goes with it, because it is resting inside rather than
// gripped. Nothing here holds onto the car — the outside is a clear slip fit,
// and the rim lip is both the stop that keeps it out of the holder's floor and
// the thing you get a fingernail under.
//
// The wall has to bridge 53 mm of can to ~90 mm of cup holder, which is 18 mm
// of radius. Drawn solid that is roughly 280 cm3 of envelope for the slicer to
// fill, so it is drawn as a double shell instead: an inner tube around the can,
// an outer cone following the holder, a sealed annular cavity between them, and
// radial webs tying the two together. Same shape to look at, a fraction of the
// plastic, and the dead-air gap is the part that makes it a koozie rather than
// a spacer.
//
// ORIENTATION. Printed floor-down, exactly as it sits in the car. z = 0 is the
// underside of the floor, +z is up. The outer cone widens going up, so it is an
// overhang of about 2.5 degrees and nothing needs support. The one bridge is
// the roof over the annular cavity, ~11 mm span, broken up by the webs.

/* [Output] */

// "cut" is a half-section for checking the double wall. Not for printing —
// build it with --name if you ever want it as its own STL.
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

show = "part";   // [part, cut]

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a 250 ml slim can (mm). Red Bull's 250 ml sleek can.
can_d = 53.0;
// Clearance on diameter (mm). Snug — the can should not rattle, but it has to
// drop in one-handed without being aimed.
can_slop = 0.40;
// Extra diameter added to the bore to cover this machine's bore shrinkage (mm).
//
// ⚠️ Contested. The design reference predicts +0.15 is enough; the slicing
// reference REFUTES that by measurement — a bore drawn at 10.15 miked 9.5–9.6,
// a loss of 0.55–0.65 on diameter. That was PETG at 0.12 layers on a small
// bore, and this is a 53 mm bore where the loss is likely smaller. Erring high
// costs a slightly loose can; erring low costs a koozie the can will not enter.
bore_comp = 0.60;

/* [Cup holder — MEASURE THESE] */

// Diameter of the holder at the console surface (mm).
holder_top_d = 90.0;
// Diameter of the holder at its floor (mm). Equal to holder_top_d if straight.
holder_bot_d = 84.0;
// Depth from the console surface to the holder floor (mm).
holder_depth = 70.0;
// Clearance on diameter against the holder wall (mm). A clearance, not an
// interference — nothing about this part should want to stay in the car.
holder_clear = 0.80;
// Gap left under the floor so the lip, not the base, sets the seating height (mm).
floor_gap = 1.5;

/* [Cup] */

// Shell wall (mm). 2.10 is 5 walls at a 0.42 line width — a ladder rung.
shell_w = 2.10;
// Floor thickness (mm). Carries the can and is the part you set down on things.
floor_t = 3.0;
// Hole through the floor (mm). Drains condensation and lets a finger push the
// can back out. Set to 0 for a closed floor.
drain_d = 12.0;
// 45-degree chamfer on the bottom outside edge (mm), per the fit rules — more
// reliable than the slicer's 0.15 mm elephant-foot compensation.
base_cham = 0.5;

/* [Rim] */

// How far the lip overhangs the mouth of the holder, per side (mm).
rim_over = 2.5;
// Lip thickness (mm). 12 layers at 0.20.
lip_t = 2.40;

/* [Webs] */

// Radial webs tying the inner tube to the outer cone across the cavity.
web_count = 8;
// Web thickness (mm). 1.29 is 2 walls at the real 0.45 inner line width.
web_t = 1.29;

/* [Quality] */

// Chord error target (mm). 0.02 is the 0.4-nozzle figure.
chord_err = 0.02;

/* [Hidden] */

// Facets for a target chord error on a given radius.
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Radius that makes the INSCRIBED polygon's inner radius equal r.
function r_hole(r, n) = r / cos(180 / n);

bore_d     = can_d + can_slop + bore_comp;
out_top_d  = holder_top_d - holder_clear;
out_bot_d  = holder_bot_d - holder_clear;
lip_od     = holder_top_d + 2 * rim_over;

cup_h      = holder_depth - floor_gap;          // floor underside to the lip
flare_h    = (lip_od - out_top_d) / 2;          // 45 degrees under the lip
cone_h     = cup_h - flare_h;                   // the plain tapered barrel
total_h    = cup_h + lip_t;

nseg       = facets(lip_od / 2);
r_bore     = r_hole(bore_d / 2, nseg);
r_drain    = drain_d > 0 ? r_hole(drain_d / 2, nseg) : 0;

// Outer radius of the barrel at height z, over the plain tapered section.
function r_out(z) = (out_bot_d + (out_top_d - out_bot_d) * z / cone_h) / 2;

// Solid section of the cup, before the wall is hollowed out.
module cup_solid() {
    pts = concat(
        drain_d > 0 ? [[r_drain, 0]] : [[0, 0]],
        [
            [out_bot_d / 2 - base_cham, 0],
            [out_bot_d / 2,             base_cham],
            [r_out(cone_h),             cone_h],
            [lip_od / 2,                cup_h],
            [lip_od / 2,                total_h],
            [r_bore,                    total_h],
            [r_bore,                    floor_t]
        ],
        drain_d > 0 ? [[r_drain, floor_t]] : []
    );
    rotate_extrude($fn = nseg) polygon(pts);
}

// The annular void between the two shells. Stops short of the flare, so the
// roof under the lip is flare_h + lip_t thick and never thins to nothing.
module cavity() {
    z0 = floor_t;
    z1 = cone_h;
    rotate_extrude($fn = nseg)
        polygon([
            [r_bore + shell_w,      z0],
            [r_out(z0) - shell_w,   z0],
            [r_out(z1) - shell_w,   z1],
            [r_bore + shell_w,      z1]
        ]);
}

module webs() {
    // Half-pitch offset keeps a web off the y = 0 plane, so the "cut" view
    // shows the cavity rather than a web edge-on.
    for (i = [0 : web_count - 1])
        rotate([0, 0, (i + 0.5) * 360 / web_count])
            translate([0, -web_t / 2, 0])
                cube([lip_od / 2, web_t, total_h]);
}

module slim_can_koozie() {
    difference() {
        cup_solid();
        // The cavity less the webs is the set of pockets to hollow out. Doing
        // it in one subtraction beats hollowing and then unioning the webs back
        // in: that version dropped three of the eight webs to a boolean
        // robustness failure and left five merged pockets behind.
        difference() {
            cavity();
            webs();
        }
    }
}



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_03380fa81a84() {
if (show == "cut")
    difference() {
        slim_can_koozie();
        translate([-lip_od, -lip_od, -eps]) cube([2 * lip_od, lip_od, total_h + 1]);
    }
else
    slim_can_koozie();
}

module feral_assembly_view_03380fa81a84(explode=false) {
feral_default_output_03380fa81a84();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_03380fa81a84();
else feral_assembly_view_03380fa81a84(view == "exploded");
