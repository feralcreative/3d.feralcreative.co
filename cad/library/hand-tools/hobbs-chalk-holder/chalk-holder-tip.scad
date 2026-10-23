// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/threading.scad>

/* [Body] */
height    = 19.20;  // Note 3.
collar_d  = 14.50;  // Note 4.
collar_h  = 2.00;   // Note 5.
barrel_d  = 18.20;  // Note 6.
barrel_z0 = 9.00;   // Note 7.
barrel_z1 = 15.50;  // Note 8.
top_d     = 18.20;  // Note 9.

/* [Grip ribs] */
rib_count    = 12;    // Note 10.
rib_r_bottom = 0.78;  // Note 11.
rib_r_top    = 0.94;  // Note 12.

/* [Bore] */
mouth_d  = 11.40;  // Note 13.
throat_d = 13.52;  // Note 14.

/* [Thread] */
thread_z0       = 9.00;    // Note 15.
thread_minor_d  = 14.592;  // Note 16.
thread_pitch    = 5.500;   // Note 17.
thread_groove_w = 2.700;   // Note 18.
thread_flank    = 0.300;   // Note 19.
thread_left     = false;   // Note 20.

handle_crest_d = 15.200;  // Note 21.

thread_root_gap = 0.200;  // Note 22.

thread_blunt_start = true;

// Note 23.

thread_pilot       = 1.50;  // Note 24.
thread_mouth_bevel = 0.40;  // Note 25.

thread_lead_in = 0.60;  // Note 26.

thread_clearance = 0.150;  // Note 27.

/* [Quality] */
$fn    = 64;  // Note 28.
rib_fn = 24;  // Note 29.

/* [Hidden] */

// Note 30.

eps = 0.01;

// Note 31.
$slop = 0;

r_collar = collar_d / 2;
r_barrel = barrel_d / 2;
r_top    = top_d / 2;
r_mouth  = mouth_d / 2;
r_throat = throat_d / 2;

r_minor  = thread_minor_d / 2;                    // Note 32.
r_major  = handle_crest_d / 2 + thread_root_gap;  // Note 33.

thread_major_d = r_major * 2;
thread_depth   = r_major - r_minor;

// Note 34.

bore_relief = 0.20;

// Note 35.
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

// Note 36.

rib_path = [
    [r_collar, 0,         rib_r_bottom],
    [r_collar, collar_h,  rib_r_bottom],
    [r_barrel, barrel_z0, rib_r_top],
    [r_barrel, barrel_z1, rib_r_top],
    [r_top,    height,    rib_r_top],
];

// Note 37.
groove_w = thread_groove_w + 2 * thread_clearance;

// Note 38.

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

// Note 39.

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

// Note 40.

module thread_mask() {
    overrun = thread_blunt_start ? eps : thread_pitch;

    translate([0, 0, thread_z0 - eps])
        generic_threaded_rod(
            d           = thread_major_d,
            l           = height - thread_z0 + overrun + eps,
            pitch       = thread_pitch,
            profile     = thread_profile,
            internal    = true,
            left_handed = thread_left,
            blunt_start = thread_blunt_start,
            end_len2    = thread_blunt_start ? thread_pilot + overrun : undef,
            lead_in     = thread_blunt_start ? thread_lead_in : undef,
            bevel1      = false,
            bevel2      = thread_blunt_start ? thread_mouth_bevel : false,
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

// Note 41.

module feral_default_output_1d7741384ea8() {
chalk_holder_tip();
}

module feral_assembly_view_1d7741384ea8(explode=false) {
feral_default_output_1d7741384ea8();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_1d7741384ea8();
else feral_assembly_view_1d7741384ea8(view == "exploded");

// Notes

// Note 1. chalk-holder-tip.scad
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

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. overall height (mm)

// Note 4. outside diameter at the bottom, between ribs (mm)

// Note 5. straight section at the bottom, before the flare (mm)

// Note 6. outside diameter of the barrel, between ribs (mm)

// Note 7. height at which the flare reaches full diameter (mm)

// Note 8. where a top taper would start; inert while top_d = barrel_d (mm)

// Note 9. outside diameter at the top face, between ribs (mm)
// top_d was 17.39 on the legacy mesh, which put a step at the joint. It now
// matches barrel_d and the handle's body, so the tool reads as one cylinder
// from the butt of the handle to the start of this part's nose taper. Two
// things fall out of that: the outer profile is straight from barrel_z0 to
// height, which is why barrel_z1 no longer does anything, and the wall over the
// thread groove at the top rim goes from 0.895 mm to 1.300 mm — it was the
// thinnest section left in the part.
//
// collar_d was 13.60 on the legacy mesh. The collar is straight while the bore
// under it is already coning open, so the wall thinned as it climbed and hit
// 0.867 mm at the top of the collar — the thinnest section anywhere in the part,
// thinner than the thread wall. A rib bead then sits on top of that, taking the
// section to 1.65 mm at each rib and back to 0.87 between: the slicer changes
// its mind about how many wall loops fit twelve times a layer, and every change
// leaves an unfilled pocket inside a rib. 14.50 puts the thin spot at 1.31 mm,
// level with the thinnest section elsewhere. It costs 0.9 mm of diameter at the
// bottom and nothing else — the collar is a grip surface and mates with nothing.

// Note 10. beads around the barrel

// Note 11. bead radius at the base (mm)

// Note 12. bead radius from barrel_z0 upwards (mm)

// Note 13. bore at the bottom face (mm)

// Note 14. bore just under the thread shoulder (mm)

// Note 15. shoulder the thread starts from (mm)

// Note 16. land diameter — the surface the handle's crest bites (mm)

// Note 17. single start, so pitch equals lead (mm)

// Note 18. axial width of the male crest this has to swallow (mm)

// Note 19. axial run of each flank; 0 would be truly square (mm)

// Note 20. the original is right handed
// Repeated from chalk-holder-handle.scad's thread_major_d, so the groove can be
// cut just deep enough to clear the handle's crest and no deeper. Change it
// there and it has to change here.

// Note 21. (mm)
// Radial air between the handle's crest and the bottom of this groove. It does
// no work — the thread mates on its flanks and its land — and all of it is
// subtracted from the outer wall. Do not raise it to fix a tight thread; that
// is what thread_clearance is for.

// Note 22. (mm)
// With this off the thread runs off the mouth at full height, so the first
// thing the spigot meets is a knife-edged partial thread — easy to cross, and
// it shaves swarf that then packs the rest of the run. On, the thread stops
// short and leaves a plain pilot bore at the mouth that squares the spigot up
// before any thread engages. Off reproduces the original; on is what BOSL2
// defaults to, and what it recommends for anything printed. Must match the
// handle's flag of the same name.

// Note 23. Only read when blunt start is on. thread_pilot is how much plain bore at the
// mouth the spigot enters before any thread bites; thread_mouth_bevel is the
// lead-in chamfer on the lip, which is about getting the spigot in coaxially
// and has nothing to do with how the thread turns once engaged.
//
// The pilot sits at the groove root, r 7.800, not at the land — it has to clear
// the handle's crest at 7.600, so it guides on that with 0.200 of slack. A
// pilot at the land would simply refuse the spigot.
//
// Both come out of thread engagement, so they are not free — see the note over
// thread_lead_in. The chamfer also comes out of the seat: it is cut off the top
// face, which is what bears against the handle's collar, and at 0.40 that face
// is 0.90 mm wide between the bore and the outside. Do not run it much past
// 0.60 or there is very little seat left.

// Note 24. (mm)

// Note 25. (mm)
// How far the thread ramps up to full height at each end. BOSL2's default is
// generous, and on a thread only 1.85 turns long that is expensive: this pair
// clamps through its thread, so turns lost here are clamp lost. Held short
// deliberately. undef hands the choice back to BOSL2.

// Note 26. (mm)
// Axial gap at each thread flank. 0 reproduces the legacy pair exactly, which
// is a line-to-line fit that will not turn once printed. 0.15 is a sane
// starting point; raise it if a test print binds.

// Note 27. (mm)

// Note 28. segments per full circle

// Note 29. segments on the rib beads; they are only ~1 mm across

// Note 30. Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's. Coplanar faces make zero-thickness walls.

// Note 31. Radial clearance is deliberately left alone — see the note at the top.

// Note 32. the land

// Note 33. the bottom of the groove
// What BOSL2 actually wants: the mask rod's outside diameter, and how far its
// tooth stands off the core. Derived, so the land cannot drift when the groove
// depth is changed — moving the land changes how the pair fits.

// Note 34. The threaded stretch of the bore is drawn undersize by this much so the
// thread mask always defines that surface itself, rather than the mask's core
// landing exactly on the bore — a subtracted face coplanar with its parent is
// what eps exists to avoid.

// Note 35. Half-section of the body, walked up the outside and back down the bore.

// Note 36. One rib, as [barrel radius, height, bead radius]. The bead sits centred on
// the barrel surface, so it stands its own radius proud of it — which is what
// the original does, including the bead thickening as it climbs.

// Note 37. Groove width as actually cut: the male crest plus a flank gap either side.

// Note 38. One pitch of the tooth, in BOSL2's units: x is a fraction of the pitch and
// must stay inside [-1/2, 1/2]; y is depth in fractions of the pitch, with 0 at
// the crest. Flat crest, flat root, short flanks — a square thread with just
// enough draft to print.

// Note 39. The beads at the ends of the path overshoot the top and bottom faces by their
// own radius; the cylinder trims them back flush.

// Note 40. A thread-shaped rod to subtract. It starts eps below the shoulder so its end
// face is never coplanar with it.
//
// The mask always runs past the mouth, whichever entry you asked for. That is
// not cosmetic: the bore under it is drawn bore_relief undersize on purpose, so
// if the mask stops level with the mouth then the relieved surface — not the
// thread's own minor diameter — becomes the visible bore. It does, measurably:
// stopping it flush puts r 7.088 on the top face and triples the count of
// degenerate facets there. The mask's core has to cover the mouth.
//
// So overrun is only ever about where the thread runs out, and the two entries
// get there differently. Blunt start off runs a full pitch past, and the thread
// walks off the face at full height as the original's does. Blunt start on
// clears the face by a hair and holds the thread back from it with end_len2
// instead, which is what leaves the plain pilot bore.

// Note 41. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
