// chalk-holder.scad
//
// Both halves of the chalk holder on one plate: a slotted handle with a
// threaded spigot and a split collet, and the ring that screws onto it. Merged
// from chalk-holder-handle.scad and chalk-holder-tip.scad.
//
// HOW THE PAIR WORKS. The ring screws down onto the spigot until its top face
// meets the collar. As it goes it draws its own tapered bore over the collet,
// squeezing the four fingers onto the chalk — from touching at the collet's
// base to 0.33 mm of squeeze at its tip. The thread is the clamp, not just a
// fastening, which is why a thread that binds ruins the whole mechanism.
//
// NAMES ARE PREFIXED ON PURPOSE. OpenSCAD has no namespaces and no scoping for
// top-level assignments: the last one in the file wins, everywhere in the file,
// regardless of where it appears. The two source files each defined collar_d,
// collar_h, thread_depth, thread_major_d, thread_profile and a dozen other
// names with *different values* — collar_d alone was 14.50 in one and 18.20 in
// the other. Concatenating them would have silently built both parts wrong
// while compiling perfectly. Everything that is not genuinely shared therefore
// carries a handle_ or ring_ prefix. Do not remove one to tidy the file up.
//
// WHAT MERGING FIXED. The pair had three numbers that lived in both files and
// had to be kept in step by hand, each with a comment begging the next person
// to remember: the spigot's crest diameter, the crest's axial width, and the
// blunt-start flag. They are single values here, under [Thread], and the ring
// derives its groove from them. That class of mistake is now impossible.
//
// ORIENTATION. Both parts sit on z = 0 the right way up for printing, which is
// how they were already drawn — merging moved them apart on the plate, it did
// not turn them over.
//
//   Handle, butt down. Keeps the collet fingers off the bed, where a small
//   four-arc footprint would print badly and elephant's foot would deform the
//   surface that does the gripping. It also puts the collar's seat face upward,
//   so the face the ring lands on comes out flat. The cost is the butt's
//   bullnose: see the note over handle_butt_round.
//
//   Ring, nose down. Puts the seat face up for the same reason, and leaves the
//   outer flare and the coned bore at about 15 and 7 degrees off vertical,
//   which is nothing. Printed the other way up the seat would be squashed
//   against the bed and the coned bore would become a real overhang.
//
// Both parts are drawn in millimetres. Dimensions came off the legacy meshes in
// _incoming/, which are drawn in units of 0.1 mm — so a number here is as
// likely to be a faithfully copied mistake as a decision. Two already were.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Plate] */
// Which parts to emit. Build one at a time when you want a clean STL per part;
// leave it on "both" to slice the pair as one plate.
show = "both";  // [both, handle, ring]

// Clear air between the two parts, surface to surface, with the ring measured
// over its ribs rather than its barrel.
part_gap = 8.00;  // (mm)

/* [Thread] */
// Shared by both halves. These are the numbers that describe the joint itself
// rather than either part, and they were the ones duplicated across the two
// old files.
thread_pitch   = 5.500;  // single start, so pitch equals lead (mm)
thread_crest_d = 15.200; // the spigot's crest diameter (mm)
thread_crest_w = 2.700;  // axial width of that crest at mid-flank (mm)
thread_depth   = 0.900;  // the spigot's tooth height, radially (mm)
thread_flank   = 0.300;  // axial run of each flank; 0 would be truly square (mm)
thread_left    = false;  // the original is right handed

// Off, the thread runs off the end at full height and the leading thread is a
// knife edge — easy to cross, and it shaves swarf that packs the rest of the
// run. On, it stops short and leaves a plain pilot that squares the parts up
// before anything bites. Off reproduces the original; on is BOSL2's default and
// what it recommends for anything printed. One flag now, for both halves.
thread_blunt_start = true;

// How far the thread ramps to full height at each end. BOSL2's default is
// generous, and on a thread under two turns long that is expensive: this pair
// clamps through its thread, so turns lost here are clamp lost. Measured, the
// spigot carries 1.87 turns of full-height crest with blunt start off and 1.56
// with it on at this lead-in. undef hands the choice back to BOSL2.
thread_lead_in = 0.60;  // (mm)

// Radial air between the spigot's crest and the bottom of the ring's groove. It
// does no work — the thread mates on its flanks and its land — and all of it is
// subtracted from the ring's outer wall. Do not raise it to fix a tight thread;
// that is what the clearances below are for. The legacy mesh effectively had
// 0.596 here and paid for it with a 0.499 mm wall.
thread_root_gap = 0.200;  // (mm)

// Axial gap at each flank, and which half pays for it. The allowance is taken
// entirely on the ring: taking it in both places doubles it. Both knobs exist so
// it can be moved, or split, deliberately rather than by accident. 0 on both
// reproduces the legacy pair exactly, which is a line-to-line fit that will not
// turn once printed.
handle_thread_clearance = 0.000;  // (mm)
ring_thread_clearance   = 0.150;  // (mm)

/* [Handle: body] */
handle_body_d = 18.200;  // outside diameter of the tube (mm)
handle_bore_d =  9.637;  // through bore the chalk sits in (mm)
handle_body_h = 65.000;  // plain tube, up to the base of the collar (mm)

// handle_body_d was 15.000 on the legacy mesh, which made the tool a thin shaft
// with a fat head. It now matches the ring's barrel between its ribs, so the
// whole thing reads as one cylinder. The bore is untouched — it still has to
// hold the chalk. The wall goes from 2.68 mm to 4.28 mm and the body's solid
// volume roughly doubles, which at any sane infill is not worth worrying about.

/* [Handle: butt end] */
// Rounding on the outside of the open end. The default is the wall thickness,
// which is the largest value that means anything: the curve then runs all the
// way in and arrives tangent at the bore, leaving no flat face at all. The bore
// stays a sharp edge, which is deliberate — the end is open so a jammed stick
// can be driven out from behind, and that wants an edge, not a funnel.
//
// Printing cost, since the handle goes butt down: the first layer becomes a
// 1.3 mm ring instead of the full 4.28 mm annulus, and the surface is about 18
// degrees off horizontal for the first millimetre. It will droop there or want
// support. Back it off to around 3.3 to leave a 1 mm flat contact ring and it
// still reads as round.
//
// Anything smaller leaves a flat ring between the curve and the bore. Anything
// larger is not geometry, it eats the bore.
handle_butt_round = (handle_body_d - handle_bore_d) / 2;  // (mm)

/* [Handle: loading slot] */
handle_slot_w  =  2.000;  // width (mm)
handle_slot_z0 =  4.600;  // start, above the bottom face (mm)
handle_slot_h  = 60.000;  // length (mm)
handle_slot_az = 270;     // which way it faces (deg)

// Break on the two long edges where the slot comes out through the outside, so
// they do not feel sharp under the fingers. It widens what you see: the walls
// stay where they are but the mouth opens up by roughly this much either side,
// so 0.40 turns a 2.00 slot into 2.80 at the surface, measured. The two ends of
// the slot are left square — nothing rests on them.
handle_slot_round = 0.400;  // (mm)

/* [Handle: collar] */
// With handle_collar_d equal to handle_body_d this is no longer a flare — it is
// just the last stretch of body before the spigot, and the only thing still
// making it a collar is its top face, which is the seat the ring screws down
// onto. Set it back below handle_body_d to get a waist here instead.
handle_collar_d = 18.200;  // outside diameter at the top of the collar (mm)
handle_collar_h =  5.000;  // body up to collar, coned if the two differ (mm)

/* [Handle: threaded spigot] */
handle_spigot_h = 10.600;  // collar top to the base of the collet (mm)
handle_thread_h = 10.300;  // how much of the spigot carries thread (mm)

/* [Handle: collet] */
handle_collet_h         = 9.000;  // base of the collet to the top face (mm)
handle_collet_tip_d     = 12.000; // outside diameter at the very top (mm)
handle_collet_slots     = 4;      // fingers are the gaps between these
handle_collet_slot_w    = 2.000;  // (mm)
handle_collet_slot_ramp = 1.000;  // coned relief under each slot (mm)
handle_collet_slot_az   = 0;      // angle of the first slot (deg)

/* [Ring: body] */
ring_height    = 19.20;  // overall height (mm)
ring_collar_d  = 14.50;  // outside diameter at the bottom, between ribs (mm)
ring_collar_h  = 2.00;   // straight section at the bottom, before the flare (mm)
ring_barrel_d  = 18.20;  // outside diameter of the barrel, between ribs (mm)
ring_barrel_z0 = 9.00;   // height at which the flare reaches full diameter (mm)
ring_barrel_z1 = 15.50;  // where a top taper would start; inert while top = barrel (mm)
ring_top_d     = 18.20;  // outside diameter at the top face, between ribs (mm)

// ring_top_d was 17.39 on the legacy mesh, which put a step at the joint. It now
// matches the barrel and the handle's body, so the tool reads as one cylinder
// from the butt of the handle to the start of the nose taper. Two things fall
// out of that: the outer profile is straight from ring_barrel_z0 to ring_height,
// which is why ring_barrel_z1 no longer does anything, and the wall over the
// thread groove at the top rim goes from 0.895 mm to 1.300 mm — it was the
// thinnest section left in the part.
//
// ring_collar_d was 13.60. The collar is straight while the bore under it is
// already coning open, so the wall thinned as it climbed and hit 0.867 mm — the
// thinnest section anywhere in the part. A rib bead then sits on top of that,
// taking the section to 1.65 mm at each rib and back to 0.87 between, so the
// slicer changes its mind about how many wall loops fit twelve times a layer
// and every change leaves an unfilled pocket inside a rib. 14.50 puts the thin
// spot at 1.31 mm. It costs 0.9 mm of diameter and nothing else — the collar is
// a grip surface and mates with nothing.

/* [Ring: grip ribs] */
ring_rib_count    = 12;    // beads around the barrel
ring_rib_r_bottom = 0.78;  // bead radius at the base (mm)
ring_rib_r_top    = 0.94;  // bead radius from ring_barrel_z0 upwards (mm)

/* [Ring: bore] */
ring_mouth_d  = 11.40;  // bore at the bottom face (mm)
ring_throat_d = 13.52;  // bore just under the thread shoulder (mm)

/* [Ring: thread] */
ring_thread_z0      = 9.00;    // shoulder the thread starts from (mm)
ring_thread_minor_d = 14.592;  // land diameter — what the spigot's crest bites (mm)

// Only read when blunt start is on. The pilot is how much plain bore at the
// mouth the spigot enters before any thread bites; the bevel is the lead-in
// chamfer on the lip, which is about getting the spigot in coaxially and has
// nothing to do with how the thread turns once engaged.
//
// The pilot sits at the groove root, r 7.800, not at the land — it has to clear
// the spigot's crest at 7.600, so it guides on that with 0.200 of slack. A
// pilot at the land would simply refuse the spigot.
//
// Both come out of thread engagement, so neither is free. The chamfer also
// comes out of the seat: it is cut off the top face, which is what bears
// against the handle's collar, and at 0.40 that face is 0.90 mm wide between
// the bore and the outside. Do not run it much past 0.60 or there is very
// little seat left.
ring_thread_pilot       = 1.50;  // (mm)
ring_thread_mouth_bevel = 0.40;  // (mm)

/* [Quality] */
$fn         = 64;  // segments per full circle
ring_rib_fn  = 24;  // segments on the rib beads; they are only ~1 mm across

/* [Hidden] */

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces make zero-thickness walls.
eps = 0.01;

// Radial clearance is not the knob here — see [Thread].
$slop = 0;

// Where each part sits on the plate. The ring is measured over its ribs, so the
// air between the two really is part_gap.
handle_r = handle_body_d / 2;
ring_r    = ring_barrel_d / 2 + ring_rib_r_top;
handle_x = -(handle_r + part_gap / 2);
ring_x    =   ring_r + part_gap / 2;

// -- handle -----------------------------------------------------------------

handle_r_bore   = handle_bore_d / 2;
handle_r_root   = thread_crest_d / 2 - thread_depth;  // also the collet's base radius
handle_z_collar = handle_body_h + handle_collar_h;    // top of the collar
handle_z_collet = handle_z_collar + handle_spigot_h;  // base of the collet
handle_z_top    = handle_z_collet + handle_collet_h;

// Crest width as actually cut, with any allowance taken off both flanks.
handle_crest_w = thread_crest_w - 2 * handle_thread_clearance;

// One pitch of the tooth, in BOSL2's units: x is a fraction of the pitch and
// must stay inside [-1/2, 1/2]; y is depth in fractions of the pitch, with 0 at
// the crest. Flat crest, flat root, short flanks — a square thread with just
// enough draft to print. The ring's profile is the mirror of this.
handle_thread_profile = [
    [-0.5,                                                       -thread_depth / thread_pitch],
    [-(handle_crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [-(handle_crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (handle_crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (handle_crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [ 0.5,                                                       -thread_depth / thread_pitch],
];

// -- ring --------------------------------------------------------------------

ring_r_collar = ring_collar_d / 2;
ring_r_barrel = ring_barrel_d / 2;
ring_r_top    = ring_top_d / 2;
ring_r_mouth  = ring_mouth_d / 2;
ring_r_throat = ring_throat_d / 2;

ring_r_minor  = ring_thread_minor_d / 2;                  // the land
ring_r_major  = thread_crest_d / 2 + thread_root_gap;    // the bottom of the groove

// What BOSL2 actually wants: the mask rod's outside diameter, and how far its
// tooth stands off the core. Derived, so the land cannot drift when the groove
// depth changes — moving the land changes how the pair fits.
ring_thread_major_d = ring_r_major * 2;
ring_thread_depth   = ring_r_major - ring_r_minor;

// The threaded stretch of the bore is drawn undersize by this much so the
// thread mask always defines that surface itself, rather than the mask's core
// landing exactly on the bore — a subtracted face coplanar with its parent is
// what eps exists to avoid.
ring_bore_relief = 0.20;

// Half-section of the ring, walked up the outside and back down the bore.
ring_body_profile = [
    [ring_r_collar, 0],
    [ring_r_collar, ring_collar_h],
    [ring_r_barrel, ring_barrel_z0],
    [ring_r_barrel, ring_barrel_z1],
    [ring_r_top,    ring_height],
    [ring_r_minor - ring_bore_relief, ring_height],
    [ring_r_minor - ring_bore_relief, ring_thread_z0],
    [ring_r_throat, ring_thread_z0],
    [ring_r_mouth,  0],
];

// One rib, as [barrel radius, height, bead radius]. The bead sits centred on
// the barrel surface, so it stands its own radius proud of it — which is what
// the original does, including the bead thickening as it climbs.
ring_rib_path = [
    [ring_r_collar, 0,             ring_rib_r_bottom],
    [ring_r_collar, ring_collar_h,  ring_rib_r_bottom],
    [ring_r_barrel, ring_barrel_z0, ring_rib_r_top],
    [ring_r_barrel, ring_barrel_z1, ring_rib_r_top],
    [ring_r_top,    ring_height,    ring_rib_r_top],
];

// Groove width as actually cut: the male crest plus a flank gap either side.
ring_groove_w = thread_crest_w + 2 * ring_thread_clearance;

ring_thread_profile = [
    [-0.5,                                                          -ring_thread_depth / thread_pitch],
    [-(ring_groove_w / 2 + thread_flank / 2) / thread_pitch,          -ring_thread_depth / thread_pitch],
    [-(ring_groove_w / 2 - thread_flank / 2) / thread_pitch,           0],
    [ (ring_groove_w / 2 - thread_flank / 2) / thread_pitch,           0],
    [ (ring_groove_w / 2 + thread_flank / 2) / thread_pitch,          -ring_thread_depth / thread_pitch],
    [ 0.5,                                                          -ring_thread_depth / thread_pitch],
];

// ===========================================================================
// Handle
// ===========================================================================

// Everything solid, before anything is taken out of it.
module handle_blank() {
    // The bore is subtracted later, and it takes exactly the flat disc this
    // rounding leaves behind — which is what puts the fillet tangent to it.
    cyl(d = handle_body_d, h = handle_body_h,
        rounding1 = handle_butt_round, anchor = BOTTOM);

    translate([0, 0, handle_body_h])
        cylinder(d1 = handle_body_d, d2 = handle_collar_d, h = handle_collar_h);

    translate([0, 0, handle_z_collar])
        cylinder(d = handle_r_root * 2, h = handle_spigot_h);

    // the thread rides on that spigot; its own core is the same cylinder, so
    // the two share a surface, which is only ever a problem in a difference
    translate([0, 0, handle_z_collar])
        generic_threaded_rod(
            d           = thread_crest_d,
            l           = handle_thread_h,
            pitch       = thread_pitch,
            profile     = handle_thread_profile,
            internal    = false,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel       = false,
            anchor      = BOTTOM);

    translate([0, 0, handle_z_collet])
        cylinder(d1 = handle_r_root * 2, d2 = handle_collet_tip_d,
                 h = handle_collet_h);
}

// Cross-section of the slot, with its two outside corners rounded off.
//
// The rounding is worked on the body's section rather than on the cut, because
// a corner that pokes into a void is convex, and rounding a convex corner means
// taking material away. Erode by the radius and dilate back and that is exactly
// what happens — the same trick the painter's pyramid uses on its lug tips. The
// cut is then whatever the rounded section does not occupy.
//
// The strip runs from the axis outward, which is what keeps the slot through
// one wall only. reach is a reach, not a diameter: it just has to clear the
// outside. The corners it leaves at the axis end get rounded too, but they sit
// at r = 1 and the bore takes them regardless.
module handle_slot_profile() {
    reach = max(handle_body_d, handle_collar_d);

    difference() {
        circle(d = handle_body_d + 2 * eps);

        offset(r = handle_slot_round, $fn = 16)
        offset(r = -handle_slot_round, $fn = 16)
            difference() {
                circle(d = handle_body_d);

                translate([0, -handle_slot_w / 2])
                    square([reach, handle_slot_w]);
            }
    }
}

// The slot down the body, cut clean through one wall only.
module handle_loading_slot() {
    rotate([0, 0, handle_slot_az])
        translate([0, 0, handle_slot_z0])
            linear_extrude(handle_slot_h)
                handle_slot_profile();
}

// One collet slot. The box gives it a constant width rather than a constant
// angle; intersecting that with a cone standing on the bore puts a ramp under
// it instead of a square corner, which is what the original does and what keeps
// the finger roots from being a stress riser.
module handle_collet_slot() {
    ramp_slope = (handle_r_root - handle_r_bore) / handle_collet_slot_ramp;
    z_ramp     = handle_z_collet - handle_collet_slot_ramp;
    r_far      = handle_collar_d;

    intersection() {
        translate([0, -handle_collet_slot_w / 2, z_ramp - 1])
            cube([r_far, handle_collet_slot_w, handle_z_top - z_ramp + 2]);

        rotate_extrude(convexity = 4)
            polygon([
                [0,     z_ramp - handle_r_bore / ramp_slope],
                [r_far, z_ramp + (r_far - handle_r_bore) / ramp_slope],
                [r_far, handle_z_top + 1],
                [0,     handle_z_top + 1],
            ]);
    }
}

module chalk_holder_handle() {
    difference() {
        handle_blank();

        translate([0, 0, -eps])
            cylinder(d = handle_bore_d, h = handle_z_top + 2 * eps);

        handle_loading_slot();

        for (i = [0 : handle_collet_slots - 1])
            rotate([0, 0, handle_collet_slot_az + i * 360 / handle_collet_slots])
                handle_collet_slot();
    }
}

// ===========================================================================
// Ring
// ===========================================================================

module ring_rib() {
    for (i = [0 : len(ring_rib_path) - 2])
        hull() {
            translate([ring_rib_path[i][0], 0, ring_rib_path[i][1]])
                sphere(r = ring_rib_path[i][2], $fn = ring_rib_fn);
            translate([ring_rib_path[i + 1][0], 0, ring_rib_path[i + 1][1]])
                sphere(r = ring_rib_path[i + 1][2], $fn = ring_rib_fn);
        }
}

// The beads at the ends of the path overshoot the top and bottom faces by their
// own radius; the cylinder trims them back flush.
module ring_ribs() {
    intersection() {
        union() {
            for (i = [0 : ring_rib_count - 1])
                rotate([0, 0, i * 360 / ring_rib_count])
                    ring_rib();
        }

        cylinder(r = ring_r_barrel + ring_rib_r_top + 1, h = ring_height);
    }
}

// A thread-shaped rod to subtract. It starts eps below the shoulder so its end
// face is never coplanar with it.
//
// The mask always runs past the mouth, whichever entry you asked for. That is
// not cosmetic: the bore under it is drawn ring_bore_relief undersize on
// purpose, so if the mask stops level with the mouth then the relieved surface
// — not the thread's own minor diameter — becomes the visible bore. It does,
// measurably: stopping it flush puts r 7.088 on the top face and triples the
// count of degenerate facets there. The mask's core has to cover the mouth.
//
// So overrun is only ever about where the thread runs out, and the two entries
// get there differently. Blunt start off runs a full pitch past, and the thread
// walks off the face at full height as the original's does. Blunt start on
// clears the face by a hair and holds the thread back from it with end_len2
// instead, which is what leaves the plain pilot bore.
module ring_thread_mask() {
    overrun = thread_blunt_start ? eps : thread_pitch;

    translate([0, 0, ring_thread_z0 - eps])
        generic_threaded_rod(
            d           = ring_thread_major_d,
            l           = ring_height - ring_thread_z0 + overrun + eps,
            pitch       = thread_pitch,
            profile     = ring_thread_profile,
            internal    = true,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            end_len2    = thread_blunt_start ? ring_thread_pilot + overrun : undef,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel1      = false,
            bevel2      = thread_blunt_start ? ring_thread_mouth_bevel : false,
            anchor      = BOTTOM);
}

module chalk_holder_ring() {
    difference() {
        union() {
            rotate_extrude(convexity = 8)
                polygon(ring_body_profile);

            ring_ribs();
        }

        ring_thread_mask();
    }
}

// ===========================================================================
// The plate
// ===========================================================================

module chalk_holder() {
    if (show == "both" || show == "handle")
        translate([show == "handle" ? 0 : handle_x, 0, 0])
            chalk_holder_handle();

    if (show == "both" || show == "ring")
        translate([show == "ring" ? 0 : ring_x, 0, 0])
            chalk_holder_ring();
}

chalk_holder();
