// Slim can holder, stubby-screwdriver-handle style.
//
// A parametric recreation of _incoming/slim-can-screwdriver-stubby.stl, which
// is a SketchUp 2026 export (16,396 triangles, one shell) with no editable
// history. Every number below was measured off that mesh — see "How it was
// measured" at the bottom of this header — so treat them as recorded
// observations, not decisions. Where the reference is a hand-drawn blend the
// numbers here are the best-fit arc through it, not a bit-for-bit copy.
//
// THE FORM. A six-lobed barrel, a round waist, and a six-point star cap: the
// silhouette of a stubby screwdriver handle. The can drops through the top and
// lands on an annular ledge 4.175 mm up, which has a big rounded hole in it
// that drains and lets a finger push the can back out.
//
// HOW IT IS BUILT. Two solids intersected. A prism of the six-lobe 2D profile
// sets the flutes; a solid of revolution sets the silhouette. Where the
// revolution is wider than the lobes you see flutes (barrel, cap); where it is
// narrower you see a plain circle (the waist). That is exactly how the
// reference behaves — its waist is round and its barrel is not — and it is one
// boolean rather than a lofted blend.
//
// ⚠️ TWO THINGS TO KNOW BEFORE PRINTING THIS.
//
// 1. The bore is Ø50.20 as drawn, and a Red Bull 250 ml slim can is Ø53. The
//    reference will not accept one. `bore_d` is the only thing to change.
// 2. The underside of the cap overhangs at about 60 degrees from vertical at
//    its worst, and turning the part over moves the problem to the base cone
//    at about 54. A waist this deep cannot avoid it. Supports, or open out
//    `neck_min_d`.
//
// HOW IT WAS MEASURED. Horizontal sections were cut through the mesh at 0.05 mm
// steps near features and 1 mm through the body, each section resolved into
// loops and expressed as radius against angle about the axis at (36.4135,
// 39.1000). The barrel and cap sections agree to within facet noise, so there
// is one lobe profile and not two. The waist, the two shoulders, and the round
// on the base hole were each fitted by least squares to a circle; the fits are
// quoted with their errors beside the parameters they produced.

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Output] */

// "cut" is a half-section for reading the wall and the ledge. Not for printing.
show = "part";   // [part, cut]

/* [Bore] */

// Bore diameter (mm). MEASURED 50.20 off the reference. A 250 ml slim can is
// 53.0 across and needs roughly 53.6 here; see the warning in the header.
bore_d = 50.20;
// Height of the ledge the can lands on, above the base (mm).
floor_t = 4.175;
// Chamfer at the mouth of the bore: how far it opens on radius (mm)...
mouth_cham_r = 1.00;
// ...over how much height (mm). Measured 1.0 over 1.5, very slightly curved.
mouth_cham_h = 1.50;

/* [Base hole] */

// The hole through the ledge is a plain bore with a fully rolled rim — the
// reference put a torus on the edge and trimmed it flush with both faces, so
// the rim bulges inward to its narrowest halfway up. Fit error 0.081 mm.
//
// Path radius of that torus (mm) — the ring the round is swept around.
hole_ring_r = 21.672;
// Tube radius of the torus (mm).
hole_round = 2.589;

/* [Barrel] */

// Across the points of the six lobes (mm).
peak_d = 78.20;
// Across the flats — the bottom of a flute (mm).
valley_d = 63.90;
// Lobes. Six on the reference.
flute_count = 6;
// Radius of the circle that cuts each flute (mm). Fitted against every mesh
// vertex in the constant-section barrel, z 12–60: worst error 0.32 mm, at the
// shoulder where the flute runs out into the peak. The reference itself only
// carries about a dozen vertices across that flank, so the remaining error is
// the same size as its own faceting.
flute_cut_r = 25.07;

/* [Base] */

// Diameter of the flat the part stands on (mm).
base_d = 58.34;
// Height at which the barrel reaches full width (mm).
barrel_full_z = 8.50;
// Round blending the base cone into the barrel (mm). The cone between the
// stand and this round is derived as the common tangent, which lands its slope
// at 1.390 mm of radius per mm of height against 1.427 measured.
base_round = 2.65;

/* [Waist and cap] */

// Overall height (mm).
total_h = 91.70;
// Narrowest diameter of the waist (mm).
neck_min_d = 54.00;
// Height of that narrowest point (mm).
neck_z = 76.66;
// Radius of the waist groove (mm).
groove_r = 8.85;
// Radius of the two shoulders either side of the waist (mm), one value for
// both — the reference is symmetric about neck_z to within 0.3 mm.
shoulder_r = 15.95;
// Diameter the shoulder arcs are centred on (mm). It has to leave
// shoulder_cd/2 + shoulder_r clear of peak_d/2, or the shoulder never reaches
// the barrel and there is no cap. Their height is derived from tangency with
// the groove, so this, groove_r and shoulder_r together set where the barrel
// ends and where the cap begins.
//
// These three were fitted together, not one at a time: the silhouette was
// sampled every 0.25 mm from z 60 to 92 and searched for the triple whose
// tangent-arc chain lands closest. Worst error 0.41 mm. Changing one of them
// alone will move the barrel and cap edges, because the tangency is derived.
shoulder_cd = 56.70;

/* [Quality] */

// Chord error target (mm). 0.02 is the 0.4-nozzle figure.
chord_err = 0.02;

/* [Hidden] */

function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
function arc(cr, cz, r, a0, a1, n = 24) =
    [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n)
        [cr + r * cos(a), cz + r * sin(a)]];

peak_r    = peak_d / 2;
valley_r  = valley_d / 2;
base_r    = base_d / 2;
neck_r    = neck_min_d / 2;
nseg      = facets(peak_r);
circum    = 1 / cos(180 / nseg);   // inscribed-polygon compensation for cuts

// Flute cutter: a circle of flute_cut_r whose nearest approach to the axis is
// the valley. Six of them, centred on the flats.
flute_off = valley_r + flute_cut_r;

// Waist. The groove is centred one groove_r outboard of the narrowest point;
// each shoulder is externally tangent to it, which fixes its height.
gr_cr     = neck_r + groove_r;
sh_cr     = shoulder_cd / 2;
sh_dz     = sqrt(pow(groove_r + shoulder_r, 2) - pow(gr_cr - sh_cr, 2));
sh_zlo    = neck_z - sh_dz;
sh_zhi    = neck_z + sh_dz;
a_wall    = acos((peak_r - sh_cr) / shoulder_r);      // shoulder meets the barrel
a_tan     = atan2(sh_dz, gr_cr - sh_cr);              // shoulder meets the groove
b_lo      = atan2(sh_zlo - neck_z, sh_cr - gr_cr) + 360;
b_hi      = atan2(sh_zhi - neck_z, sh_cr - gr_cr);

// Base round, and the cone that runs tangent from the stand up to it.
bf_cr     = peak_r - base_round;
bf_d      = norm([base_r - bf_cr, -barrel_full_z]);
bf_phi    = atan2(-barrel_full_z, base_r - bf_cr) + acos(base_round / bf_d);

// Base hole: the torus trimmed flush with both faces of the ledge.
hole_face_r = hole_ring_r - sqrt(pow(hole_round, 2) - pow(floor_t / 2, 2));
h_lo        = atan2(-floor_t / 2, hole_face_r - hole_ring_r) + 360;
h_hi        = atan2( floor_t / 2, hole_face_r - hole_ring_r);

// The 2D six-lobe section. Flat-topped peaks on peak_r, flutes cut by circles.
module lobe_profile() {
    difference() {
        circle(r = peak_r, $fn = nseg);
        for (i = [0 : flute_count - 1])
            rotate([0, 0, i * 360 / flute_count])
                translate([flute_off, 0])
                    circle(r = flute_cut_r, $fn = facets(flute_cut_r));
    }
}

// Meridian of the solid of revolution, bottom left corner first, running
// counter-clockwise: stand, base cone, base round, barrel, shoulder, waist
// groove, shoulder, cap.
function envelope_pts() = concat(
    [[0, 0], [base_r, 0]],
    arc(bf_cr, barrel_full_z, base_round, bf_phi, 0),
    [[peak_r, barrel_full_z]],
    arc(sh_cr, sh_zlo, shoulder_r, a_wall, a_tan),
    arc(gr_cr, neck_z,  groove_r,  b_lo,   b_hi, 40),
    arc(sh_cr, sh_zhi, shoulder_r, 360 - a_tan, 360 - a_wall),
    [[peak_r, total_h], [0, total_h]]
);

// Meridian of everything cut away: base hole with its rolled rim, the ledge,
// the bore, and the chamfer at the mouth. Radii carry the circumscribe factor
// so the printed polygon's flats land on size rather than inside it.
function void_pts() = concat(
    [[0, -eps], [hole_face_r * circum, -eps]],
    arc(hole_ring_r * circum, floor_t / 2, hole_round * circum, h_lo, h_hi, 32),
    [[bore_d / 2 * circum, floor_t],
     [bore_d / 2 * circum, total_h - mouth_cham_h],
     [(bore_d / 2 + mouth_cham_r) * circum, total_h + eps],
     [0, total_h + eps]]
);

module stubby_holder() {
    difference() {
        intersection() {
            linear_extrude(height = total_h) lobe_profile();
            rotate_extrude($fn = nseg) polygon(envelope_pts());
        }
        rotate_extrude($fn = nseg) polygon(void_pts());
    }
}

if (show == "cut")
    difference() {
        stubby_holder();
        translate([-peak_d, -peak_d, -eps]) cube([2 * peak_d, peak_d, total_h + 1]);
    }
else
    stubby_holder();
