// Pumpkin body: a ribbed lamp shade over a Bambu Lab LED Lamp Kit-001 puck, with a
// socket for a separate stem. The puck presses up into a pocket in the floor.
// Remade from Sabre Design's "Halloween Pumpkin (tealight compatible)", Printables
// model 1003177, pumpkin-body.3mf (CC BY-NC-ND 4.0, personal use only). The original
// sits in 3mf/holiday/originals/holiday/halloween/
// halloween-pumpkin-tealight-compatible-model_files/.
//
// Measured, not authored. The surface was read back from the 1.27M-triangle mesh:
// a revolved meridian (column r, z), with every lobe notched toward its seam and
// a radial rib raised along the surface normal. The table below holds the measured
// values at 40 equal steps of arc length up that meridian; it matches the original
// to a few tenths of a millimetre over the body, worse right at the rim and socket.
// The original's ~0.5 mm fillets on the rib corners are not reproduced.
//
// The original was open underneath for a loose tealight. This one closes the rim with
// a floor holding the puck from below, lens up, its back flush with the table, and
// the cable leaving through a groove in the underside. Puck numbers are Bambu's own
// drawing and dummy model (3mf/lighting/originals/lighting/Dummy+LED+Lamp+Kit-001.3mf); Ziad's
// circular and twist lamp bases pocket the same puck at Ø60.0.
//
// Axes: Z up, floor on the bed at Z=0, a lobe seam centred on +X+20°, a lobe centred
// on +X. Print upright. The pocket roof is a 45° chamfer and needs no support; the
// dome still does, as the original's did.

/* [View] */
show = "body"; // [body, section, assembly]

/* [Size] */
size = 1.0; // uniform scale of the measured form; 0.75 still takes a tealight, per the designer
wall = 1.0; // mm, shell thickness; not scaled

/* [Lobes and ribs] */
lobes = 9; // count around
ribs_per_lobe = 6; // raised ribs per lobe; a groove sits on every lobe centre and seam
rib_fraction = 0.54; // rib arc / rib pitch, measured 3.6° of 6.67°
rib_depth_scale = 1.0; // multiplies the measured rib height (about 4.8 mm at the waist)
notch_scale = 1.0; // multiplies the measured seam notch (about 5 mm at the waist)

/* [LED puck] */
puck_d = 59.4; // mm, Bambu drawing
puck_h = 8.0; // mm, Bambu drawing
puck_fit = 0.15; // mm per side; snug enough to stay put when the pumpkin is lifted
puck_depth_extra = 0.1; // mm, so the puck's back never stands proud of the rim
puck_lens_d = 47.6; // mm, lit window on the puck's face; kept fully clear
puck_roof = 1.5; // mm, floor above the pocket; its 45° chamfer is the stop
puck_wall = 1.2; // mm, least shell outside the pocket; the seams are eased to keep it
cable_d = 2.8; // mm, Bambu dummy model
cable_clear = 0.3; // mm per side
cable_angle = 0; // degrees; 0 runs it out under a lobe centre, through a rib groove
puck_fn = 180;

/* [Stem socket] */
socket_bore_d = 23.2; // mm, stem plug is 23.0
socket_od = 28.2; // mm
ledge_id = 19.2; // mm, the stem plug rests on this ring
ledge_top_z = 63.5; // mm, the stem's underside sits here
ledge_t = 1.5; // mm

/* [Resolution] */
ring_step = 1.0; // mm of meridian arc between rings
groove_pts = 3; // samples across each half groove
rib_pts = 4; // samples across each rib top
socket_fn = 96;

/* [Colors] */
body_color = "#E9B489"; // the original's own colour
puck_color = "#C8C8C8"; // assembly view only; not printed

eps = 0.01;

// Measured meridian, uniform arc-length steps of MER_STEP mm from the rim up to the socket.
// [r, z, V seam notch depth, h rib height, groove notch exponent, rib notch gain, rib notch exponent]
// At a lobe-relative angle u (0 on the lobe centre, 1 on the seam) the groove floor
// sits at -V*u^pG and a rib top at h - V*aT*u^pT. Offsets run horizontally below the
// waist and along the meridian's outward normal above it (see off_dir).
MER_STEP = 2.9337;
MER_WAIST = 53.93; // mm of arc to the widest point, where the normal is horizontal
MER = [
    [36.33, 0.17, 8.62, 4.28, 1.41, 1.61, 2.34],
    [39.04, 1.19, 10.96, 4.28, 1.56, 1.29, 1.88],
    [41.29, 3.05, 11.79, 4.31, 1.88, 1.14, 1.81],
    [43.17, 5.29, 10.55, 4.40, 2.02, 1.18, 1.90],
    [44.81, 7.72, 9.20, 4.53, 2.17, 1.23, 2.03],
    [46.33, 10.23, 8.20, 4.67, 2.32, 1.28, 2.14],
    [47.78, 12.78, 7.53, 4.79, 2.45, 1.32, 2.20],
    [49.15, 15.38, 7.06, 4.89, 2.55, 1.34, 2.24],
    [50.42, 18.02, 6.70, 4.95, 2.65, 1.36, 2.26],
    [51.59, 20.71, 6.39, 4.99, 2.74, 1.38, 2.30],
    [52.66, 23.44, 6.12, 5.00, 2.84, 1.40, 2.35],
    [53.62, 26.21, 5.87, 4.99, 2.95, 1.42, 2.41],
    [54.50, 29.01, 5.66, 4.97, 3.06, 1.44, 2.47],
    [55.29, 31.83, 5.47, 4.93, 3.16, 1.46, 2.53],
    [55.98, 34.69, 5.32, 4.89, 3.24, 1.47, 2.58],
    [56.56, 37.56, 5.19, 4.86, 3.32, 1.49, 2.63],
    [57.02, 40.46, 5.09, 4.83, 3.38, 1.50, 2.67],
    [57.34, 43.37, 5.02, 4.82, 3.41, 1.51, 2.70],
    [57.50, 46.30, 4.98, 4.83, 3.43, 1.51, 2.72],
    [57.49, 49.23, 4.98, 4.87, 3.42, 1.51, 2.71],
    [57.26, 52.16, 4.99, 4.94, 3.40, 1.50, 2.70],
    [56.79, 55.05, 5.02, 5.03, 3.36, 1.50, 2.67],
    [56.04, 57.89, 5.04, 5.15, 3.31, 1.49, 2.62],
    [55.00, 60.63, 5.06, 5.25, 3.24, 1.48, 2.57],
    [53.62, 63.21, 5.06, 5.33, 3.18, 1.47, 2.52],
    [51.93, 65.60, 5.05, 5.36, 3.11, 1.45, 2.47],
    [49.93, 67.74, 5.02, 5.31, 3.02, 1.42, 2.42],
    [47.65, 69.57, 4.98, 5.19, 2.93, 1.40, 2.36],
    [45.15, 71.07, 4.93, 5.01, 2.84, 1.37, 2.31],
    [42.47, 72.26, 4.90, 4.80, 2.73, 1.34, 2.24],
    [39.67, 73.13, 4.89, 4.57, 2.59, 1.31, 2.16],
    [36.80, 73.68, 4.91, 4.35, 2.44, 1.28, 2.08],
    [33.88, 73.93, 4.94, 4.13, 2.30, 1.24, 2.02],
    [30.95, 73.89, 4.97, 3.95, 2.17, 1.21, 1.97],
    [28.03, 73.59, 4.97, 3.80, 2.06, 1.18, 1.92],
    [25.16, 73.01, 4.93, 3.68, 1.96, 1.15, 1.91],
    [22.35, 72.19, 4.42, 3.55, 1.66, 1.23, 1.95],
    [19.61, 71.13, 3.60, 3.39, 1.21, 1.41, 2.11],
    [16.97, 69.85, 2.67, 3.21, 1.00, 1.73, 2.40],
    [14.46, 68.34, 1.74, 2.97, 1.00, 2.22, 2.65],
];
MER_N = len(MER);
MER_LEN = (MER_N - 1) * MER_STEP;

// Rings run a little past both ends so the rim trim and the socket bore cut clean faces.
mer_start = -3; // mm of arc below the rim, trimmed at Z=0
mer_end = MER_LEN + 4.5; // mm of arc into the socket, removed by the bore

// ---------- meridian interpolation (uniform Catmull-Rom) ----------

function _row(i) = MER[max(0, min(MER_N - 1, i))];
function _cr(p0, p1, p2, p3, t) =
    0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t
           + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
function _crd(p0, p1, p2, p3, t) =
    0.5 * ((-p0 + p2) + 2 * (2 * p0 - 5 * p1 + 4 * p2 - p3) * t
           + 3 * (-p0 + 3 * p1 - 3 * p2 + p3) * t * t);

// Row values at arc length s, extrapolated along the end tangents beyond the table.
function mer_at(s) =
    let (sc = max(0, min(MER_LEN - eps, s)), i = floor(sc / MER_STEP), t = sc / MER_STEP - i,
         v = _cr(_row(i - 1), _row(i), _row(i + 1), _row(i + 2), t),
         d = _crd(_row(i - 1), _row(i), _row(i + 1), _row(i + 2), t) / MER_STEP,
         over = s - sc)
    [v[0] + d[0] * over, v[1] + d[1] * over, v[2], v[3], v[4], v[5], v[6]];

function mer_tan(s) =
    let (sc = max(0, min(MER_LEN - eps, s)), i = floor(sc / MER_STEP), t = sc / MER_STEP - i,
         d = _crd(_row(i - 1), _row(i), _row(i + 1), _row(i + 2), t), l = norm([d[0], d[1]]))
    [d[0] / l, d[1] / l];

// Direction the rib and notch offsets run in. Below the waist the meridian's normal
// tips toward the bed, so a normal offset there lifts the seams off it (each lobe's
// seam came out ~7 mm above Z=0 that way); horizontal keeps every angle on the rim.
function off_dir(s) = s < MER_WAIST ? [1, 0] : let (t = mer_tan(s)) [t[1], -t[0]];

// ---------- surface ----------

// Puck pocket, needed by the rings as well as the floor.
pocket_d = puck_d + 2 * puck_fit;
pocket_h = puck_h + puck_depth_extra;
floor_top = pocket_h + puck_roof;


rib_n = lobes * ribs_per_lobe;
rib_pitch = 360 / rib_n;
lobe_pitch = 360 / lobes;
rib_arc = rib_pitch * rib_fraction;

// 0 on a lobe centre, 1 on a seam.
function lobe_u(a) = abs(((a % lobe_pitch) + 1.5 * lobe_pitch) % lobe_pitch - lobe_pitch / 2) / (lobe_pitch / 2);

// Outward normal offset of the outer surface: groove floor or rib top.
function off_groove(m, a) = -notch_scale * m[2] * pow(lobe_u(a), m[4]);
function off_rib(m, a) = rib_depth_scale * m[3] - notch_scale * m[2] * m[5] * pow(lobe_u(a), m[6]);

// Wall measured normal to the surface, not to the meridian: the seam notch slopes
// steeply around the lobe, and a radial-only offset would thin the wall there.
function wall_k(m, a, rib) =
    let (da = 0.05, r = max(5, m[0]),
         f0 = rib ? off_rib(m, a - da) : off_groove(m, a - da),
         f1 = rib ? off_rib(m, a + da) : off_groove(m, a + da),
         slope = (f1 - f0) / (2 * da * PI / 180 * r))
    sqrt(1 + slope * slope);

function pt(m, n, a, o) =
    let (r = size * (m[0] + o * n[0]), z = size * (m[1] + o * n[1]))
    [r * cos(a), r * sin(a), z];

// One pitch cell of a ring: half groove, rib, half groove. Outer and inner rings have
// the same vertex count, so the shell stitches as a plain grid. On the inner ring the
// rib walls move in by the wall thickness; where a rib is too narrow to hollow (rim,
// socket) its inner pocket shrinks to a sliver and flattens toward the groove.
function ring(s, inner) =
    let (m = mer_at(s), n = off_dir(s), r = max(5, size * m[0]),
         tn = mer_tan(s),
         // a horizontal offset on a sloped wall is thinner than it looks
         wall_n = wall / max(0.25, n[0] * tn[1] - n[1] * tn[0]),
         wall_deg = wall / r * 180 / PI,
         pocket_mm = rib_arc * PI / 180 * r - 2 * wall,
         min_pocket = 0.3,
         ins = inner ? (pocket_mm >= min_pocket ? wall_deg : (rib_arc - min_pocket / r * 180 / PI) / 2) : 0,
         pocket_f = inner ? max(0, min(1, pocket_mm / 1.5)) : 1,
         // The seams dip to r~28 at the rim, inside the puck pocket, which then cut a
         // slot through each of them. Within the floor, hold the outer skin out to
         // the pocket plus puck_wall; offsets there are horizontal, so this is radial.
         o_min = (s < MER_WAIST && size * m[1] < floor_top)
             ? (pocket_d / 2 + puck_wall) / size - m[0] : -1e9)
    [for (k = [0:rib_n - 1])
        let (a0 = k * rib_pitch, ra = a0 + (rib_pitch - rib_arc) / 2, rb = ra + rib_arc,
             ia = ra + ins, ib = rb - ins, a1 = a0 + rib_pitch)
        each concat(
            // groove, cell start up to the rib's leading wall
            [for (j = [0:groove_pts - 1]) let (a = a0 + (ia - a0) * j / (groove_pts - 1))
                pt(m, n, a, inner ? off_groove(m, a) - wall_n * wall_k(m, a, false) : max(o_min, off_groove(m, a)))],
            // rib top
            [for (j = [0:rib_pts - 1]) let (a = ia + (ib - ia) * j / (rib_pts - 1),
                    g = off_groove(m, a) - (inner ? wall_n * wall_k(m, a, false) : 0),
                    o = off_rib(m, a) - (inner ? wall_n * wall_k(m, a, true) : 0))
                pt(m, n, a, inner ? g + max(0.05, (o - g) * pocket_f) : max(o_min, o))],
            // groove, trailing wall to the cell end (exclusive)
            [for (j = [0:groove_pts - 2]) let (a = ib + (a1 - ib) * j / (groove_pts - 1))
                pt(m, n, a, inner ? off_groove(m, a) - wall_n * wall_k(m, a, false) : max(o_min, off_groove(m, a)))]
        )];

ring_count = ceil((mer_end - mer_start) / ring_step) + 1;
function ring_s(i) = mer_start + (mer_end - mer_start) * i / (ring_count - 1);

OUTER = [for (i = [0:ring_count - 1]) ring(ring_s(i), false)];
INNER = [for (i = [0:ring_count - 1]) ring(ring_s(i), true)];
RING_W = len(OUTER[0]);

function _v(i, j) = i * RING_W + (j % RING_W);
function _skin(base, flip) =
    [for (i = [0:ring_count - 2], j = [0:RING_W - 1]) each flip
        ? [[base + _v(i, j), base + _v(i + 1, j + 1), base + _v(i + 1, j)], [base + _v(i, j), base + _v(i, j + 1), base + _v(i + 1, j + 1)]]
        : [[base + _v(i, j), base + _v(i + 1, j), base + _v(i + 1, j + 1)], [base + _v(i, j), base + _v(i + 1, j + 1), base + _v(i, j + 1)]]];

module shell() {
    io = ring_count * RING_W; // offset of the inner grid
    e = ring_count - 1;
    polyhedron(
        points = concat([for (rg = OUTER) each rg], [for (rg = INNER) each rg]),
        faces = concat(
            _skin(0, false),
            _skin(io, true),
            // rim end and socket end
            [for (j = [0:RING_W - 1]) each [
                [_v(0, j), _v(0, j + 1), io + _v(0, j + 1)], [_v(0, j), io + _v(0, j + 1), io + _v(0, j)]]],
            [for (j = [0:RING_W - 1]) each [
                [_v(e, j), io + _v(e, j + 1), _v(e, j + 1)], [_v(e, j), io + _v(e, j), io + _v(e, j + 1)]]]
        ),
        convexity = 10);
}

// Everything under the outer skin, capped at both ends. The socket tube is clipped
// to it so the tube rises until it meets the shell all the way round, as the
// original's does. A flat-topped tube touched the shell only under the nine seams
// and left a tunnel between each pair (genus 10 instead of 1).
module outer_solid() {
    e = ring_count - 1;
    n = ring_count * RING_W;
    polyhedron(
        points = concat([for (rg = OUTER) each rg],
                        // cap apexes off the ring planes: a rib wall seen from a centre in its own
                        // plane is a zero-area triangle, and Manifold rejects it
                        [[0, 0, OUTER[0][0][2] - 5], [0, 0, OUTER[e][0][2] + 5]]),
        faces = concat(
            _skin(0, false),
            [for (j = [0:RING_W - 1]) [n, _v(0, j), _v(0, j + 1)]],
            [for (j = [0:RING_W - 1]) [n + 1, _v(e, j + 1), _v(e, j)]]
        ),
        convexity = 10);
}

module socket() {
    // Tube from under the ledge up to the shell; the bore and through hole leave the ledge.
    intersection() {
        translate([0, 0, size * (ledge_top_z - ledge_t)])
            cylinder(d = size * socket_od, h = 40, $fn = socket_fn);
        outer_solid();
    }
}

assert(size * MER[0][0] - wall > pocket_d / 2 + 2,
       "size is too small for the LED puck: the rim no longer clears its pocket");

// A circle's polygon sits inside the circle; scale it out so the bore is full size.
function circumscribed(d, fn) = d / cos(180 / fn);

// Fills the shell from the bed to floor_top, ribs and all.
module puck_floor() {
    intersection() {
        outer_solid();
        translate([0, 0, -1]) cylinder(r = 200, h = floor_top + 1);
    }
}

module puck_cutouts() {
    pd = circumscribed(pocket_d, puck_fn);
    translate([0, 0, -eps]) cylinder(d = pd, h = pocket_h + eps, $fn = puck_fn);
    // 45° roof: from the pocket wall in toward the lens, ending well outside it
    translate([0, 0, pocket_h - eps])
        cylinder(d1 = pd, d2 = pd - 2 * (puck_roof + 2 * eps), h = puck_roof + 2 * eps, $fn = puck_fn);
    // cable groove under the floor, out through the rim
    cw = cable_d + 2 * cable_clear;
    rotate([0, 0, cable_angle]) translate([0, -cw / 2, -eps]) cube([100, cw, cw + eps]);
}

module puck_dummy() {
    color(puck_color) {
        difference() {
            cylinder(d = puck_d, h = puck_h, $fn = puck_fn);
            translate([0, 0, puck_h - 0.4]) cylinder(d = puck_lens_d, h = 1, $fn = puck_fn);
        }
        rotate([0, 0, cable_angle]) translate([puck_d / 2 - 2, 0, cable_d / 2])
            rotate([0, 90, 0]) cylinder(d = cable_d, h = 40, $fn = 24);
    }
}

module pumpkin_body() {
    color(body_color) difference() {
        union() {
            shell();
            socket();
            puck_floor();
        }
        // flat rim on the bed
        translate([0, 0, -50]) cube([300, 300, 100], center = true);
        puck_cutouts();
        // stem bore down to the ledge, then the through hole
        translate([0, 0, size * ledge_top_z]) cylinder(d = size * socket_bore_d, h = 50, $fn = socket_fn);
        translate([0, 0, size * ledge_top_z - 10]) cylinder(d = size * ledge_id, h = 20, $fn = socket_fn);
    }
}

if (show == "body") pumpkin_body();
else if (show == "section" || show == "assembly") difference() {
    union() {
        pumpkin_body();
        if (show == "assembly") puck_dummy();
    }
    // cut on the cable's plane so the groove shows
    rotate([0, 0, cable_angle]) translate([-150, 0, -1]) cube([300, 300, 200]);
}
