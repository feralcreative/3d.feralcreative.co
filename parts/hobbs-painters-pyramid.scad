// hobbs-painters-pyramid.scad
//
// Parametric remake of _incoming/hobbs-painters-pyramid.stl: a hollow three-sided
// painter's pyramid with artwork cut through every face, a mounting lug on two
// of the three base edges, and a notched foot on the third.
//
// Every dimension was measured off the legacy mesh, which is drawn in units of
// 0.1 mm. Everything below is millimetres.
//
// The artwork is the one thing that cannot be described parametrically, so it
// comes in as SVG — see the notes over the artwork parameters below.

/* [Shell] */
base_side   = 60.00;  // length of each base edge (mm)
apex_height = 46.82;  // outer apex above the base plane (mm)
wall_t      = 1.60;   // wall thickness, perpendicular to the face (mm)

/* [Mounting lugs] */
lug_faces    = [0, 2];  // which faces carry a lug (0, 1, 2)
lug_t        = 2.05;    // plate thickness (mm)
lug_width    = 13.54;   // width where the lug meets the wall (mm)
lug_reach    = 14.70;   // projection past the base edge, before the tip is rounded (mm)
lug_bulge    = 1.10;    // outward bow of the side arcs; 0 gives straight sides (mm)
lug_tip_r    = 2.70;    // radius the tip is rounded to (mm)
lug_hole_d   = 5.00;    // through hole (mm)
lug_hole_out = 6.22;    // hole centre, measured out from the base edge (mm)
slot_w       = 7.00;    // slot length, along the base edge (mm)
slot_d       = 1.13;    // slot width, out from the base edge (mm)
slot_out     = 0.92;    // slot's inboard edge, out from the base edge (mm)

/* [Foot notches] */
notch_faces   = [1];    // which faces get a notched bottom edge
notch_count   = 2;      // notches per face
notch_w       = 7.00;   // (mm)
notch_h       = 2.00;   // measured vertically, not up the slope (mm)
notch_spacing = 14.00;  // centre to centre (mm)

/* [Artwork] */
// The maker's mark arrives in two pieces because it has to. The figure can be
// cut clean through the wall, but the wordmark cannot: the counters of the O
// and the two Bs are islands, and a through-cut would drop them on the floor.
// So the wordmark is raised instead — which is exactly what the original does.
//
// Both files are split out of _incoming/hobbs-makers-mark.svg and keep its
// viewBox, so they stay in register with each other and share one scale and
// one position.
//
// art_width and art_up are not guesses: the legacy wordmark measures 17.50 mm
// wide by 3.28 mm tall, and the SVG's wordmark divides into that at 0.04363
// either way, which pins the scale and then the position of the whole mark.
art_figure_file = "art/hobbs-mark-figure.svg";  // cut through; "" for none
art_word_file   = "art/hobbs-mark-word.svg";    // raised; "" for none
//
// The original sits at 30.78 wide, 18.47 up and 3.01 to the left, and at that
// placement the cut runs off the face and breaches the corner where two walls
// meet — 1.18 mm over on the outer surface, 2.30 mm on the inner. The thicker
// wall here would make that worse. The fix is a nudge the other way: the mark
// is not symmetric, the urn reaching left high up where the face has already
// narrowed while the cat's tail reaches right lower down where there is room.
// Moving it right and trimming 0.78 mm off the width leaves 1.07 mm of wall at
// the tightest point. Set art_across = -3.01 and art_width = 30.78 to put the
// original's breach back.
art_width       = 30.00;  // width of the whole mark on the face (mm)
art_up          = 18.47;  // centre of the mark, up the face slope (mm)
art_across      = 2.20;   // centre of the mark, across the face (mm)
art_relief      = 0.81;   // how far the wordmark stands off the face (mm)

/* [Quality] */
$fn = 64;             // segments per full circle

/* [Hidden] */

// Small overshoot on every subtracted solid so its faces are never coplanar
// with the parent's. Coplanar faces make zero-thickness walls.
eps = 0.01;

// The base is equilateral, so a 3-segment cylinder is exactly the outer solid:
// circumradius R_out, apothem a_out, vertices at 0/120/240 degrees and base
// edge midpoints — the faces — at 60/180/300.
R_out  = base_side / sqrt(3);
a_out  = R_out / 2;
face_a = atan(apex_height / a_out);   // face inclination from horizontal (deg)

// Moving a face plane inward by wall_t slides its trace on the base plane
// inward by wall_t / sin(face_a). The inner solid is therefore the outer one
// scaled about the apex axis, which keeps every face parallel to its outer
// twin — that is what makes the wall a constant thickness.
inset = wall_t / sin(face_a);
a_in  = a_out - inset;
R_in  = 2 * a_in;
h_in  = apex_height * a_in / a_out;

function face_az(i) = 60 + 120 * i;

// Bounding box of the two artwork layers taken together, in the millimetres
// OpenSCAD produces when it imports them. Remeasure both if the artwork is
// ever replaced — they are what art_width and art_up are reckoned against.
art_native = [705.551, 471.131];
art_centre = [352.776, 235.746];
art_k      = art_width / art_native[0];

// Centre of the circle through three points.
function circumcentre(p1, p2, p3) =
    let (d  = 2 * (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)),
         s1 = p1.x * p1.x + p1.y * p1.y,
         s2 = p2.x * p2.x + p2.y * p2.y,
         s3 = p3.x * p3.x + p3.y * p3.y)
    [ (s1 * (p2.y - p3.y) + s2 * (p3.y - p1.y) + s3 * (p1.y - p2.y)) / d,
      (s1 * (p3.x - p2.x) + s2 * (p1.x - p3.x) + s3 * (p2.x - p1.x)) / d ];

// Places children in the plane of face i: local X across the face, local Y up
// the slope, local Z along the outward normal, origin at the midpoint of the
// base edge on the outer surface.
module face_frame(i) {
    rotate([0, 0, face_az(i)])
        translate([a_out, 0, 0])
            rotate([0, face_a, 0])
                rotate([0, 0, 90])
                    children();
}

// Lug outline, axis along +X (outward), widest where it meets the wall at x=0.
// Two mirrored arcs meet in a cusp at x = lug_reach; the erode/dilate pair
// rounds that cusp off to lug_tip_r, which is what the original does.
module lug_outline() {
    p1    = [0, lug_width / 2];
    p3    = [lug_reach, 0];
    chord = p3 - p1;
    nrm   = [-chord.y, chord.x] / norm(chord);
    p2    = (p1 + p3) / 2 + lug_bulge * nrm;
    c     = circumcentre(p1, p2, p3);
    r     = norm(p1 - c);

    offset(r = lug_tip_r) offset(r = -lug_tip_r)
        intersection() {
            translate(c)             circle(r = r, $fn = 160);
            translate([c.x, -c.y])   circle(r = r, $fn = 160);
        }
}

// One lug, sitting in the base plane with +X pointing out from the wall. It
// runs back past the inner wall face so the shell's hollow trims it flush.
module lug() {
    difference() {
        linear_extrude(lug_t)
            intersection() {
                lug_outline();
                translate([-inset - eps, -lug_width])
                    square([inset + lug_reach + eps, 2 * lug_width]);
            }

        translate([lug_hole_out, 0, -eps])
            cylinder(d = lug_hole_d, h = lug_t + 2 * eps);

        translate([slot_out, -slot_w / 2, -eps])
            cube([slot_d, slot_w, lug_t + 2 * eps]);
    }
}

// Notches cut up from the bottom edge of one wall. The box is sized to span
// the wall over the whole notch height: the wall leans inward as it rises, so
// it needs notch_h / tan(face_a) of extra depth on top of the wall itself.
module foot_notches(i) {
    depth = inset + notch_h / tan(face_a);

    for (k = [0 : notch_count - 1]) {
        u = (k - (notch_count - 1) / 2) * notch_spacing;

        rotate([0, 0, face_az(i)])
            translate([a_out - depth - eps, u - notch_w / 2, -eps])
                cube([depth + 2 * eps, notch_w, notch_h + eps]);
    }
}

// One layer of the mark in the face's own 2D frame, centred on the origin.
// Both layers go through here, and that is what keeps them registered.
module art_layer(file) {
    scale(art_k)
        translate(-art_centre)
            import(file = file, center = false);
}

// The figure, cut clean through the wall from outside to inside.
module art_figure_cut() {
    translate([art_across, art_up, -wall_t - eps])
        linear_extrude(wall_t + 2 * eps)
            art_layer(art_figure_file);
}

// The wordmark, sunk eps into the face so it is never coplanar with it.
module art_word_relief() {
    translate([art_across, art_up, -eps])
        linear_extrude(art_relief + eps)
            art_layer(art_word_file);
}

module painters_pyramid() {
    difference() {
        union() {
            cylinder(r1 = R_out, r2 = 0, h = apex_height, $fn = 3);

            for (i = lug_faces)
                rotate([0, 0, face_az(i)])
                    translate([a_out, 0, 0])
                        lug();
        }

        // hollow, opened out through the base
        translate([0, 0, -eps])
            cylinder(r1 = R_in * (h_in + eps) / h_in, r2 = 0,
                     h = h_in + eps, $fn = 3);

        for (i = notch_faces)
            foot_notches(i);

        if (art_figure_file != "")
            for (i = [0 : 2])
                face_frame(i) art_figure_cut();
    }

    if (art_word_file != "")
        for (i = [0 : 2])
            face_frame(i) art_word_relief();
}

painters_pyramid();
