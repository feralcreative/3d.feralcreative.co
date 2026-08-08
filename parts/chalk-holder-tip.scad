// chalk-holder-tip.scad
//
// Parametric remake of _incoming/chalk-holder-tip.stl: the screw-on tip of a chalk
// holder. A ribbed barrel, a conical bore that grips the chalk, and a coarse
// square internal thread that takes the handle.
//
// Every dimension was measured off the legacy mesh, which is drawn in units of
// 0.1 mm. Everything below is millimetres.
//
// The thread was read off the old mesh and then checked against the handle in
// _incoming/chalk-holder-handle.stl. Both are single start, right hand, 5.5 mm
// pitch, 0.9 mm deep, with a 2.70 mm crest against a 2.80 mm root.
//
// The pair is drawn nominal, and lopsidedly so. Axially there is no slack at
// all, crest width exactly equalling groove width, so the knob that matters for
// fit is thread_clearance, which opens the groove axially. Do not reach for
// radial clearance instead: the teeth only interlock by 0.304 mm as it is (male
// crest 7.600 against female land 7.296), and anything radial comes straight
// out of that.
//
// The groove's depth is not a fit knob either, and reading it off the legacy
// mesh was a mistake. That mesh bottoms the groove at r 8.196 — 0.596 mm past
// the handle's crest at 7.600 — and that dead air is subtracted from the outer
// wall, which left 0.904 mm of wall at the barrel and 0.499 mm at the top face:
// one extrusion width. The groove now bottoms at 7.800. Nothing that mates has
// moved; the wall is 1.300 mm and 0.895 mm.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Body] */
height    = 19.20;  // overall height (mm)
collar_d  = 13.60;  // outside diameter at the bottom, between ribs (mm)
collar_h  = 2.00;   // straight section at the bottom, before the flare (mm)
barrel_d  = 18.20;  // outside diameter of the barrel, between ribs (mm)
barrel_z0 = 9.00;   // height at which the flare reaches full diameter (mm)
barrel_z1 = 15.50;  // height at which the top taper starts (mm)
top_d     = 17.39;  // outside diameter at the top face, between ribs (mm)

/* [Grip ribs] */
rib_count    = 12;    // beads around the barrel
rib_r_bottom = 0.78;  // bead radius at the base (mm)
rib_r_top    = 0.94;  // bead radius from barrel_z0 upwards (mm)

/* [Bore] */
mouth_d  = 11.40;  // bore at the bottom face (mm)
throat_d = 13.52;  // bore just under the thread shoulder (mm)

/* [Thread] */
thread_z0       = 9.00;    // shoulder the thread starts from (mm)
thread_minor_d  = 14.592;  // land diameter — the surface the handle's crest bites (mm)
thread_pitch    = 5.500;   // single start, so pitch equals lead (mm)
thread_groove_w = 2.700;   // axial width of the male crest this has to swallow (mm)
thread_flank    = 0.300;   // axial run of each flank; 0 would be truly square (mm)
thread_left     = false;   // the original is right handed

// Repeated from chalk-holder-handle.scad's thread_major_d, so the groove can be
// cut just deep enough to clear the handle's crest and no deeper. Change it
// there and it has to change here.
handle_crest_d = 15.200;  // (mm)

// Radial air between the handle's crest and the bottom of this groove. It does
// no work — the thread mates on its flanks and its land — and all of it is
// subtracted from the outer wall. Do not raise it to fix a tight thread; that
// is what thread_clearance is for.
thread_root_gap = 0.200;  // (mm)

// With this off the thread runs off the mouth at full height, so the first
// thing the spigot meets is a knife-edged partial thread — easy to cross, and
// it shaves swarf that then packs the rest of the run. On, the thread stops
// short and leaves a plain pilot bore at the mouth that squares the spigot up
// before any thread engages. Off reproduces the original.
thread_blunt_start = false;

// Axial gap at each thread flank. 0 reproduces the legacy pair exactly, which
// is a line-to-line fit that will not turn once printed. 0.15 is a sane
// starting point; raise it if a test print binds.
thread_clearance = 0.150;  // (mm)

/* [Quality] */
$fn    = 64;  // segments per full circle
rib_fn = 24;  // segments on the rib beads; they are only ~1 mm across

/* [Hidden] */

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces make zero-thickness walls.
eps = 0.01;

// Radial clearance is deliberately left alone — see the note at the top.
$slop = 0;

r_collar = collar_d / 2;
r_barrel = barrel_d / 2;
r_top    = top_d / 2;
r_mouth  = mouth_d / 2;
r_throat = throat_d / 2;

r_minor  = thread_minor_d / 2;                    // the land
r_major  = handle_crest_d / 2 + thread_root_gap;  // the bottom of the groove

// What BOSL2 actually wants: the mask rod's outside diameter, and how far its
// tooth stands off the core. Derived, so the land cannot drift when the groove
// depth is changed — moving the land changes how the pair fits.
thread_major_d = r_major * 2;
thread_depth   = r_major - r_minor;

// The threaded stretch of the bore is drawn undersize by this much so the
// thread mask always defines that surface itself, rather than the mask's core
// landing exactly on the bore — a subtracted face coplanar with its parent is
// what eps exists to avoid.
bore_relief = 0.20;

// Half-section of the body, walked up the outside and back down the bore.
body_profile = [
    [r_collar, 0],
    [r_collar, collar_h],
    [r_barrel, barrel_z0],
    [r_barrel, barrel_z1],
    [r_top,    height],
    [r_minor - bore_relief, height],
    [r_minor - bore_relief, thread_z0],
    [r_throat, thread_z0],
    [r_mouth,  0],
];

// One rib, as [barrel radius, height, bead radius]. The bead sits centred on
// the barrel surface, so it stands its own radius proud of it — which is what
// the original does, including the bead thickening as it climbs.
rib_path = [
    [r_collar, 0,         rib_r_bottom],
    [r_collar, collar_h,  rib_r_bottom],
    [r_barrel, barrel_z0, rib_r_top],
    [r_barrel, barrel_z1, rib_r_top],
    [r_top,    height,    rib_r_top],
];

// Groove width as actually cut: the male crest plus a flank gap either side.
groove_w = thread_groove_w + 2 * thread_clearance;

// One pitch of the tooth, in BOSL2's units: x is a fraction of the pitch and
// must stay inside [-1/2, 1/2]; y is depth in fractions of the pitch, with 0 at
// the crest. Flat crest, flat root, short flanks — a square thread with just
// enough draft to print.
thread_profile = [
    [-0.5,                                                 -thread_depth / thread_pitch],
    [-(groove_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [-(groove_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (groove_w / 2 - thread_flank / 2) / thread_pitch,      0],
    [ (groove_w / 2 + thread_flank / 2) / thread_pitch,     -thread_depth / thread_pitch],
    [ 0.5,                                                 -thread_depth / thread_pitch],
];

module rib() {
    for (i = [0 : len(rib_path) - 2])
        hull() {
            translate([rib_path[i][0], 0, rib_path[i][1]])
                sphere(r = rib_path[i][2], $fn = rib_fn);
            translate([rib_path[i + 1][0], 0, rib_path[i + 1][1]])
                sphere(r = rib_path[i + 1][2], $fn = rib_fn);
        }
}

// The beads at the ends of the path overshoot the top and bottom faces by their
// own radius; the cylinder trims them back flush.
module ribs() {
    intersection() {
        union() {
            for (i = [0 : rib_count - 1])
                rotate([0, 0, i * 360 / rib_count])
                    rib();
        }

        cylinder(r = r_barrel + rib_r_top + 1, h = height);
    }
}

// A thread-shaped rod to subtract. It starts eps below the shoulder so its end
// face is never coplanar with it. Where it stops at the top depends on which
// entry you asked for: run it a full pitch past the mouth and the thread walks
// off the end as the original's does; stop it level with the mouth and blunt
// start puts its run-out inside the part, leaving the pilot bore.
module thread_mask() {
    overrun = thread_blunt_start ? 0 : thread_pitch;

    translate([0, 0, thread_z0 - eps])
        generic_threaded_rod(
            d           = thread_major_d,
            l           = height - thread_z0 + overrun + eps,
            pitch       = thread_pitch,
            profile     = thread_profile,
            internal    = true,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            bevel       = false,
            anchor      = BOTTOM);
}

module chalk_holder_tip() {
    difference() {
        union() {
            rotate_extrude(convexity = 8)
                polygon(body_profile);

            ribs();
        }

        thread_mask();
    }
}

chalk_holder_tip();
