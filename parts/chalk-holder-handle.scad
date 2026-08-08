// chalk-holder-handle.scad
//
// Parametric remake of _incoming/chalk-holder-handle.stl: the body of the chalk
// holder. A slotted tube you hold, a collar, a threaded spigot, and a split
// collet on the nose.
//
// Every dimension was measured off the legacy mesh, which is drawn in units of
// 0.1 mm. Everything below is millimetres.
//
// HOW THE PAIR WORKS. The tip screws down onto the spigot until its top face
// meets the collar. As it goes it draws its own tapered bore over this collet,
// squeezing the four fingers onto the chalk — from touching at the collet's
// base to 0.33 mm of squeeze at its tip. The thread is the clamp, not just a
// fastening, which is why a thread that binds ruins the whole mechanism.
//
// The thread here is drawn nominal: 2.70 mm crest against a 2.80 mm root, no
// axial clearance whatsoever. The mating clearance lives on the tip, in
// chalk-holder-tip.scad's thread_clearance. Anything changed here has to be
// changed there to match, or the two stop mating.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Body] */
body_d = 18.200;  // outside diameter of the tube (mm)
bore_d =  9.637;  // through bore the chalk sits in (mm)
body_h = 65.000;  // plain tube, up to the base of the collar (mm)

// body_d was 15.000 on the legacy mesh, which made the tool a thin shaft with a
// fat head. It now matches the tip's barrel between its ribs, so the whole thing
// reads as one cylinder. The bore is untouched — it still has to hold the chalk.
// The wall goes from 2.68 mm to 4.28 mm and the body's solid volume roughly
// doubles, which at any sane infill is not worth worrying about.

/* [Butt end] */
// Rounding on the outside of the open end. The default is the wall thickness,
// which is the largest value that means anything: the curve then runs all the
// way in and arrives tangent at the bore, leaving no flat face at all. The bore
// stays a sharp edge, which is deliberate — the end is open so a jammed stick
// can be driven out from behind, and that wants an edge, not a funnel.
//
// Anything smaller leaves a flat ring between the curve and the bore. Anything
// larger is not geometry, it eats the bore.
butt_round = (body_d - bore_d) / 2;  // (mm)

/* [Loading slot] */
slot_w  =  2.000;  // width (mm)
slot_z0 =  4.600;  // start, above the bottom face (mm)
slot_h  = 60.000;  // length (mm)
slot_az = 270;     // which way it faces (deg)

/* [Collar] */
// With collar_d equal to body_d this is no longer a flare — it is just the last
// stretch of body before the spigot, and the only thing still making it a collar
// is its top face, which is the seat the tip screws down onto. Set collar_d back
// below body_d to get a waist here instead.
collar_d = 18.200;  // outside diameter at the top of the collar (mm)
collar_h =  5.000;  // body_d up to collar_d, coned if they differ (mm)

/* [Threaded spigot] */
spigot_h        = 10.600;  // collar top to the base of the collet (mm)
thread_h        = 10.300;  // how much of the spigot carries thread (mm)
thread_major_d  = 15.200;  // crest diameter (mm)
thread_depth    =  0.900;  // radial depth (mm)
thread_pitch    =  5.500;  // single start, so pitch equals lead (mm)
thread_crest_w  =  2.700;  // axial width of the crest at mid-flank (mm)
thread_flank    =  0.300;  // axial run of each flank; 0 would be truly square (mm)
thread_left     = false;   // the original is right handed

// Off, the thread runs off the top of the spigot at full height and the
// leading thread is a knife edge. On, it stops short and leaves a plain pilot
// at the spigot's tip that enters the tip's bore square before any thread
// bites. Off reproduces the original. Set it to match the tip.
thread_blunt_start = true;

// How far the thread ramps up to full height at each end. BOSL2's default is
// generous, and on a thread under two turns long that is expensive: this pair
// clamps through its thread, so turns lost here are clamp lost. Held short
// deliberately, and kept the same as the tip's. undef hands it back to BOSL2.
thread_lead_in = 0.60;  // (mm)

// Axial gap taken off this thread's crest. Leave it at 0: the tip already
// carries the pair's clearance in its own thread_clearance, and taking it in
// both places doubles it. This exists so the allowance can be moved here, or
// split, deliberately rather than by accident.
thread_clearance = 0.000;  // (mm)

/* [Collet] */
collet_h         = 9.000;  // base of the collet to the top face (mm)
collet_tip_d     = 12.000; // outside diameter at the very top (mm)
collet_slots     = 4;      // fingers are the gaps between these
collet_slot_w    = 2.000;  // (mm)
collet_slot_ramp = 1.000;  // coned relief under each slot (mm)
collet_slot_az   = 0;      // angle of the first slot (deg)

/* [Wordmark] */
// The wordmark half of the Hobbs maker's mark, sunk into the side of the body.
// Same SVG the painter's pyramid uses, and it comes in the same way: scaled
// against a measured bounding box rather than to any absolute size.
//
// It is turned 90 degrees so it reads along the handle rather than around it.
// That is not only a look — cylindrical_extrude() wraps the child's X around
// the circumference and runs its Y along the axis, so a mark this long has to
// be turned to fit at all.
mark_file  = "art/hobbs-mark-word.svg";  // "" for none
mark_len   = 40.00;  // length along the handle axis (mm)
mark_z     = 32.50;  // centre, above the bottom face (mm)
mark_depth =  0.40;  // how far it is cut into the wall (mm)

// Which way it faces. The loading slot is at 270, and cylindrical_extrude()
// puts its children at 270 by default, so this is doing real work, not just
// choosing a nice side. Keep it a multiple of 360/$fn or the wrap's facets stop
// lining up with the body's.
mark_az = 90;  // (deg)

/* [Quality] */
$fn = 64;  // segments per full circle

/* [Hidden] */

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces make zero-thickness walls.
eps = 0.01;

// Radial clearance is not the knob here — see chalk-holder-tip.scad.
$slop = 0;

r_bore   = bore_d / 2;
r_root   = thread_major_d / 2 - thread_depth;   // also the collet's base radius
z_collar = body_h + collar_h;                   // top of the collar
z_collet = z_collar + spigot_h;                 // base of the collet
z_top    = z_collet + collet_h;

// Crest width as actually cut, with any allowance taken off both flanks.
crest_w = thread_crest_w - 2 * thread_clearance;

// Bounding box and centre of the wordmark in the millimetres OpenSCAD produces
// when it imports it, measured by extruding the bare SVG and reading the mesh.
// Remeasure both if the artwork is ever replaced.
mark_native = [401.015, 75.219];
mark_centre = [321.745,  37.790];
mark_k      = mark_len / mark_native[0];

// How far past the surface the cut reaches. Deliberately larger than eps: the
// wrap approximates the cylinder with its own polygon, and where that polygon
// disagrees with the body's the two surfaces part company by about 0.011 mm,
// which eps alone would not clear.
mark_over = 0.05;

// One pitch of the tooth, in BOSL2's units: x is a fraction of the pitch and
// must stay inside [-1/2, 1/2]; y is depth in fractions of the pitch, with 0 at
// the crest. Flat crest, flat root, short flanks — a square thread with just
// enough draft to print. This is the mirror of the tip's profile.
thread_profile = [
    [-0.5,                                                -thread_depth / thread_pitch],
    [-(crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [-(crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (crest_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (crest_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [ 0.5,                                                -thread_depth / thread_pitch],
];

// Everything solid, before anything is taken out of it.
module blank() {
    // The bore is subtracted later, and it takes exactly the flat disc this
    // rounding leaves behind — which is what puts the fillet tangent to it.
    cyl(d = body_d, h = body_h, rounding1 = butt_round, anchor = BOTTOM);

    translate([0, 0, body_h])
        cylinder(d1 = body_d, d2 = collar_d, h = collar_h);

    translate([0, 0, z_collar])
        cylinder(d = r_root * 2, h = spigot_h);

    // the thread rides on that spigot; its own core is the same cylinder, so
    // the two share a surface, which is only ever a problem in a difference
    translate([0, 0, z_collar])
        generic_threaded_rod(
            d           = thread_major_d,
            l           = thread_h,
            pitch       = thread_pitch,
            profile     = thread_profile,
            internal    = false,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel       = false,
            anchor      = BOTTOM);

    translate([0, 0, z_collet])
        cylinder(d1 = r_root * 2, d2 = collet_tip_d, h = collet_h);
}

// The slot down the body, cut clean through one wall only. The cube's first
// dimension is a reach, not a diameter — it only has to run from the axis out
// past the outside, so it is tied to the part's widest.
module loading_slot() {
    rotate([0, 0, slot_az])
        translate([0, -slot_w / 2, slot_z0])
            cube([max(body_d, collar_d), slot_w, slot_h]);
}

// One collet slot. The box gives it a constant width rather than a constant
// angle; intersecting that with a cone standing on the bore puts a ramp under
// it instead of a square corner, which is what the original does and what
// keeps the finger roots from being a stress riser.
module collet_slot() {
    ramp_slope = (r_root - r_bore) / collet_slot_ramp;
    z_ramp     = z_collet - collet_slot_ramp;
    r_far      = collar_d;

    intersection() {
        translate([0, -collet_slot_w / 2, z_ramp - 1])
            cube([r_far, collet_slot_w, z_top - z_ramp + 2]);

        rotate_extrude(convexity = 4)
            polygon([
                [0,     z_ramp - r_bore / ramp_slope],
                [r_far, z_ramp + (r_far - r_bore) / ramp_slope],
                [r_far, z_top + 1],
                [0,     z_top + 1],
            ]);
    }
}

// The wordmark as a flat outline, scaled to mark_len and centred on the origin,
// then turned so it runs along the handle. The rotate has to come last: the
// centring is done in the artwork's own frame.
// The $fn = 0 is not decoration. Left to inherit the part's $fn of 64 this one
// cut takes the mesh from 2,550 facets to 613,536; turning it off halves that to
// 280,326. Do not expect to tune it further — $fa and $fs were measured to make
// no difference at all here, and neither does any non-zero $fn, so whatever the
// SVG importer does with them it is not what the manual implies. 280k facets
// slice fine but write a 96 MB ASCII STL; export binstl for this part.
module mark_2d() {
    rotate(90)
        scale(mark_k)
            translate(-mark_centre)
                import(file = mark_file, center = false, $fn = 0);
}

// The same outline wrapped onto the body and turned into a solid to subtract.
// Wrapping matters at this size: 40 mm of mark stands 7.5 mm around an 18.2 mm
// barrel, and a flat cut would come out 0.43 mm shallower at its edges than at
// its centre — most of a 0.40 mm deboss.
//
// size is given so the wrap only builds facets over the mark. Left to itself it
// assumes the child goes right round the cylinder; set it too small and it
// quietly clips the artwork instead.
module mark_cut() {
    translate([0, 0, mark_z])
        cylindrical_extrude(
            ir   = body_d / 2 - mark_depth,
            or   = body_d / 2 + mark_over,
            size = [mark_native[1] * mark_k * 1.05, mark_len * 1.05],
            spin = mark_az - 270)
                mark_2d();
}

module chalk_holder_handle() {
    difference() {
        blank();

        translate([0, 0, -eps])
            cylinder(d = bore_d, h = z_top + 2 * eps);

        loading_slot();

        for (i = [0 : collet_slots - 1])
            rotate([0, 0, collet_slot_az + i * 360 / collet_slots])
                collet_slot();

        if (mark_file != "")
            mark_cut();
    }
}

chalk_holder_handle();
