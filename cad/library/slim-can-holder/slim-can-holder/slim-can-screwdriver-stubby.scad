// Note 1.

/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

$fa = 4;   // Note 3.
$fs = 0.4;
eps = 0.01;

/* [Output] */

// Note 4.
show = "part";   // [part, cut]

// Note 5.

variant = "stubby";   // [stubby, tall]

/* [Bore] */

// Note 6.

bore_d = 50.20;
// Note 7.
floor_t = 4.175;
// Note 8.
mouth_cham_r = 1.00;
// Note 9.
mouth_cham_h = 1.50;

/* [Base hole] */

// Note 10.

hole_ring_r = 21.672;
// Note 11.
hole_round = 2.589;

/* [Barrel] */

// Note 12.
peak_d = 78.20;
// Note 13.
valley_d = 63.90;
// Note 14.
flute_count = 6;
// Note 15.

flute_cut_r = 25.07;

/* [Base] */

// Note 16.
base_d = 58.34;
// Note 17.
barrel_full_z = 8.50;
// Note 18.

base_round = 2.65;

/* [Waist and cap] */

// Note 19.
total_h = 91.70;
// Note 20.
neck_min_d = 54.00;
// Note 21.
neck_z = 76.66;
// Note 22.
groove_r = 8.85;
// Note 23.

shoulder_r = 15.95;
// Note 24.

shoulder_cd = 56.70;

/* [Can grip ribs] */

// Note 25.

rib_count = 6;
// Note 26.
rib_h = 0.50;
// Note 27.

rib_w = 3.00;
// Note 28.

rib_ramp = 6.0;
// Note 29.

rib_foot = 2.0;

/* [Print correction] */

// Note 30.

print_scale = 1.0;

/* [Quality] */

// Note 31.
chord_err = 0.02;

/* [Hidden] */

// Note 32.
var_xy = (variant == "tall" ? 1.0780 : 1.0) * print_scale;
var_z  = (variant == "tall" ? 1.2720 : 1.0) * print_scale;

function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
function arc(cr, cz, r, a0, a1, n = 24) =
    [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n)
        [cr + r * cos(a), cz + r * sin(a)]];

peak_r    = peak_d / 2;
valley_r  = valley_d / 2;
base_r    = base_d / 2;
neck_r    = neck_min_d / 2;
nseg      = facets(peak_r);
circum    = 1 / cos(180 / nseg);   // Note 33.

flute_off = valley_r + flute_cut_r;

// Note 34.

gr_cr     = neck_r + groove_r;
sh_cr     = shoulder_cd / 2;
sh_dz     = sqrt(pow(groove_r + shoulder_r, 2) - pow(gr_cr - sh_cr, 2));
sh_zlo    = neck_z - sh_dz;
sh_zhi    = neck_z + sh_dz;
a_wall    = acos((peak_r - sh_cr) / shoulder_r);      // Note 35.
barrel_top_z = neck_z - sqrt(pow(groove_r + shoulder_r, 2)
                            - pow(neck_r + groove_r - sh_cr, 2))
               + shoulder_r * sin(a_wall);
a_tan     = atan2(sh_dz, gr_cr - sh_cr);              // Note 36.
b_lo      = atan2(sh_zlo - neck_z, sh_cr - gr_cr) + 360;
b_hi      = atan2(sh_zhi - neck_z, sh_cr - gr_cr);

// Note 37.
bf_cr     = peak_r - base_round;
bf_d      = norm([base_r - bf_cr, -barrel_full_z]);
bf_phi    = atan2(-barrel_full_z, base_r - bf_cr) + acos(base_round / bf_d);

// Note 38.
hole_face_r = hole_ring_r - sqrt(pow(hole_round, 2) - pow(floor_t / 2, 2));
h_lo        = atan2(-floor_t / 2, hole_face_r - hole_ring_r) + 360;
h_hi        = atan2( floor_t / 2, hole_face_r - hole_ring_r);

// Note 39.
module lobe_profile() {
    difference() {
        circle(r = peak_r, $fn = nseg);
        for (i = [0 : flute_count - 1])
            rotate([0, 0, i * 360 / flute_count])
                translate([flute_off, 0])
                    circle(r = flute_cut_r, $fn = facets(flute_cut_r));
    }
}

// Note 40.

function envelope_pts() = concat(
    [[0, 0], [base_r, 0]],
    arc(bf_cr, barrel_full_z, base_round, bf_phi, 0),
    [[peak_r, barrel_full_z]],
    arc(sh_cr, sh_zlo, shoulder_r, a_wall, a_tan),
    arc(gr_cr, neck_z,  groove_r,  b_lo,   b_hi, 40),
    arc(sh_cr, sh_zhi, shoulder_r, 360 - a_tan, 360 - a_wall),
    [[peak_r, total_h], [0, total_h]]
);

// Note 41.

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

// Note 42.

bore_rf     = bore_d / 2 * var_xy;
rib_r       = (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h);
rib_ax      = bore_rf + rib_r - rib_h;
rib_z0      = floor_t * var_z + 2;
rib_z1      = barrel_top_z * var_z - 1;
rib_back    = rib_ax + rib_r;                 // Note 43.
wall_avail  = valley_r * var_xy;              // Note 44.

assert(rib_count == 0 || rib_h <= 0 || rib_back <= wall_avail - 0.84,
       "grip rib is too big for the barrel wall: reduce rib_w or rib_h");

module ribs() {
    n = facets(rib_r);
    for (i = [0 : rib_count - 1])
        // Note 45.
        rotate([0, 0, 30 + i * 360 / rib_count])
            hull() {
                translate([bore_rf + rib_r, 0, rib_z0])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([rib_ax, 0, rib_z0 + rib_foot])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([rib_ax, 0, rib_z1 - rib_ramp])
                    cylinder(r = rib_r, h = eps, $fn = n);
                translate([bore_rf + rib_r, 0, rib_z1])
                    cylinder(r = rib_r, h = eps, $fn = n);
            }
}

// Note 46.

echo(str("variant=", variant, "  bore ", bore_d * var_xy,
         "  across ribs ", bore_d * var_xy - 2 * rib_h,
         "  across points ", peak_d * var_xy, "  height ", total_h * var_z));

// Note 47.

module can_holder() {
    union() {
        scale([var_xy, var_xy, var_z]) stubby_holder();
        if (rib_count > 0 && rib_h > 0) ribs();
    }
}

// Note 48.

module feral_default_output_9bde2929a1bf() {
if (show == "cut")
    difference() {
        can_holder();
        translate([-peak_d * var_xy, -peak_d * var_xy, -eps])
            cube([2 * peak_d * var_xy, peak_d * var_xy, total_h * var_z + 1]);
    }
else
    can_holder();
}

module feral_assembly_view_9bde2929a1bf(explode=false) {
feral_default_output_9bde2929a1bf();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_9bde2929a1bf();
else feral_assembly_view_9bde2929a1bf(view == "exploded");

// Notes

// Note 1. Slim can holder, stubby-screwdriver-handle style.
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
// TWO FILES, ONE DESIGN. `_incoming/slim-can-screwdriver.stl` is the same
// shape as the stubby, scaled 1.0780 across and 1.2720 up — resampling its
// silhouette against the stubby's at matching heights gives a deviation of
// exactly zero at every height checked, so this is a scale and not a redraw.
// `variant` switches between them. Every parameter in this file is a STUBBY
// dimension; the scale is applied last, to the finished solid.
//
// That is also the answer to which one holds a can. The stubby bore is Ø50.20
// and will not take a Ø53 slim can. The tall one is Ø54.12 as drawn and Ziad
// measured a printed one at Ø53.85, a loss of 0.27 on diameter — so the tall
// variant is the one that works, with about 0.85 mm of clearance in the hand.
//
// ⚠️ The underside of the cap overhangs at about 60 degrees from vertical at
// its worst, and turning the part over moves the problem to the base cone at
// about 54. A waist this deep cannot avoid it. Supports, or open out
// `neck_min_d`.
//
// HOW IT WAS MEASURED. Horizontal sections were cut through the mesh at 0.05 mm
// steps near features and 1 mm through the body, each section resolved into
// loops and expressed as radius against angle about the axis at (36.4135,
// 39.1000). The barrel and cap sections agree to within facet noise, so there
// is one lobe profile and not two. The waist, the two shoulders, and the round
// on the base hole were each fitted by least squares to a circle; the fits are
// quoted with their errors beside the parameters they produced.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. organic faceting per the 0.4-nozzle rule; no global high $fn

// Note 4. "cut" is a half-section for reading the wall and the ledge. Not for printing.

// Note 5. Which of the two reference files to produce. See the header — they are the
// same design at two scales, and only "tall" fits a 250 ml slim can.

// Note 6. Bore diameter (mm), before the variant scale. MEASURED 50.20 off the stubby;
// the tall variant carries this to 54.12, which is the one that fits a can.

// Note 7. Height of the ledge the can lands on, above the base (mm).

// Note 8. Chamfer at the mouth of the bore: how far it opens on radius (mm)...

// Note 9. ...over how much height (mm). Measured 1.0 over 1.5, very slightly curved.

// Note 10. The hole through the ledge is a plain bore with a fully rolled rim — the
// reference put a torus on the edge and trimmed it flush with both faces, so
// the rim bulges inward to its narrowest halfway up. Fit error 0.081 mm.
//
// Path radius of that torus (mm) — the ring the round is swept around.

// Note 11. Tube radius of the torus (mm).

// Note 12. Across the points of the six lobes (mm).

// Note 13. Across the flats — the bottom of a flute (mm).

// Note 14. Lobes. Six on the reference.

// Note 15. Radius of the circle that cuts each flute (mm). Fitted against every mesh
// vertex in the constant-section barrel, z 12–60: worst error 0.32 mm, at the
// shoulder where the flute runs out into the peak. The reference itself only
// carries about a dozen vertices across that flank, so the remaining error is
// the same size as its own faceting.

// Note 16. Diameter of the flat the part stands on (mm).

// Note 17. Height at which the barrel reaches full width (mm).

// Note 18. Round blending the base cone into the barrel (mm). The cone between the
// stand and this round is derived as the common tangent, which lands its slope
// at 1.390 mm of radius per mm of height against 1.427 measured.

// Note 19. Overall height (mm).

// Note 20. Narrowest diameter of the waist (mm).

// Note 21. Height of that narrowest point (mm).

// Note 22. Radius of the waist groove (mm).

// Note 23. Radius of the two shoulders either side of the waist (mm), one value for
// both — the reference is symmetric about neck_z to within 0.3 mm.

// Note 24. Diameter the shoulder arcs are centred on (mm). It has to leave
// shoulder_cd/2 + shoulder_r clear of peak_d/2, or the shoulder never reaches
// the barrel and there is no cap. Their height is derived from tangency with
// the groove, so this, groove_r and shoulder_r together set where the barrel
// ends and where the cap begins.
//
// These three were fitted together, not one at a time: the silhouette was
// sampled every 0.25 mm from z 60 to 92 and searched for the triple whose
// tangent-arc chain lands closest. Worst error 0.41 mm. Changing one of them
// alone will move the barrel and cap edges, because the tangency is derived.

// Note 25. Rounded vertical ribs inside the bore, so the can is held instead of
// rattling, without shrinking the bore itself. Set rib_count or rib_h to 0 to
// reproduce the reference exactly.
//
// WHY RIBS RATHER THAN A SMALLER BORE. Two reasons, and the second is the one
// that matters. A smaller bore has to be right the first time; six small
// rounded bumps can be sanded down in two minutes if the can will not go in,
// and nothing can be added back to a bore that came out loose. Erring tight is
// the recoverable direction here. And a rib bears on a rounded 3 mm patch with
// a lead-in above it, so a fit that is slightly over-tight slides in firmly
// rather than stopping dead.
//
// THE ARITHMETIC, on the printed tall variant Ziad measured at Ø53.85 against a
// Ø53.0 can. Two ribs sit across any diameter, so the working size is
// 53.85 - 2 x rib_h:
//
// rib_h 0.50  ->  52.85   0.15 interference   (this default)
// rib_h 0.425 ->  53.00   dead zero
// rib_h 0.35  ->  53.15   0.15 clearance
// rib_h 0.30  ->  53.25   0.25 clearance
//
// These are in FINAL coordinates, applied after the variant scale, unlike every
// other dimension in this file — a grip is an absolute size, not a proportion.

// Note 26. How far each rib stands into the bore (mm).

// Note 27. Chord width of the bump (mm). Sets the bearing area, and its radius is
// derived so the arc is exactly this wide at exactly rib_h proud.

// Note 28. Lead-in at the top, over which the rib fades to nothing (mm). This is what
// makes insertion progressive instead of a step.

// Note 29. Foot at the bottom, same idea (mm). This end is the one the printer sees as
// an overhang, and at 0.5 over 2 mm it is 14 degrees off vertical.

// Note 30. Model-to-print scale, applied last, on top of the variant scale.
//
// Ziad measured a printed tall variant: 83.98 across the points against a model
// 84.300, and 53.85 in the bore against a model 54.116. One uniform factor fits
// both — the part came out 0.41% small, which is thermal shrinkage.
//
// ⚠️ That does NOT agree with docs/flash-studio-slicing-reference.md, which
// records a bore loss of 0.55–0.65 mm on diameter measured on a 10 mm bore. A
// fixed loss of that size would have taken 0.6 off this 54 mm bore, and it took
// 0.27. A proportional loss would have taken 0.04 off the 10 mm bore. Both
// numbers can be right if the small-bore loss is first-layer squish and
// extrusion pull-in rather than shrinkage, but they are not the same effect and
// neither should be applied to the other's case. Two data points from one
// months-old print of unknown settings — worth knowing, not worth trusting.
//
// 1.0 reproduces the reference exactly. 1.00414 aims the printed part at the
// model's nominal dimensions.

// Note 31. Chord error target (mm). 0.02 is the 0.4-nozzle figure.

// Note 32. Measured off the two reference files, not chosen.

// Note 33. inscribed-polygon compensation for cuts
// Flute cutter: a circle of flute_cut_r whose nearest approach to the axis is
// the valley. Six of them, centred on the flats.

// Note 34. Waist. The groove is centred one groove_r outboard of the narrowest point;
// each shoulder is externally tangent to it, which fixes its height.

// Note 35. shoulder meets the barrel

// Note 36. shoulder meets the groove

// Note 37. Base round, and the cone that runs tangent from the stand up to it.

// Note 38. Base hole: the torus trimmed flush with both faces of the ledge.

// Note 39. The 2D six-lobe section. Flat-topped peaks on peak_r, flutes cut by circles.

// Note 40. Meridian of the solid of revolution, bottom left corner first, running
// counter-clockwise: stand, base cone, base round, barrel, shoulder, waist
// groove, shoulder, cap.

// Note 41. Meridian of everything cut away: base hole with its rolled rim, the ledge,
// the bore, and the chamfer at the mouth. Radii carry the circumscribe factor
// so the printed polygon's flats land on size rather than inside it.

// Note 42. Ribs live in final coordinates and stop short of the waist. They have to:
// on the tall variant the wall at the narrowest point of the waist is only
// 2.02 mm thick, which leaves no room for a bump behind it. Keeping them in the
// barrel is also where the can wants holding.

// Note 43. how far the rib reaches outward

// Note 44. thinnest point of the barrel

// Note 45. 30 degrees puts a rib behind each lobe peak, where the wall is thick.

// Note 46. Report what this actually builds, because every parameter above is a stubby
// dimension and the tall variant is 7.8% wider than the numbers you just read.

// Note 47. The variant scale goes on the body only, which is exactly how the tall
// reference was made — note that it turns every arc in the silhouette into an
// ellipse, which is a property of the reference and not a defect here. The ribs
// are added afterwards so their size does not scale with the variant.

// Note 48. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
