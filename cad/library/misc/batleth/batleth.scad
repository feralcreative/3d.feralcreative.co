// Note 1.

/* [Overall] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

mesh_length = 99.625;  // Note 3.
length      = 77;      // Note 4.
shrink      = length / mesh_length;

// Note 5.

thickness = 2.20;      // Note 6.

/* [Edge treatment] */
// Note 7.

grind_run  = 1.55;  // Note 8.
grind_land = 0.4;   // Note 9.
back_round = 1.10;  // Note 10.

slot_round = 0.5;   // Note 11.

/* [Back edge - superellipse] */
// Note 12.

back_b  = 29.56;    // Note 13.
back_cy = 14.4915;  // Note 14.
back_n  = 1.938;    // Note 15.

/* [Front edge - superellipse] */
// Note 16.

front_a  = 30.46;   // Note 17.
front_b  = 17.90;   // Note 18.
front_cy = 16.96;   // Note 19.
front_n  = 3.0;     // Note 20.

/* [Notch - Bezier control points] */
// Note 21.

spike_face  = [[30.1371, 11.6014], [32.0424, 10.0233], [29.7623,  3.4137], [29.8704,  0.9334]];
notch_floor = [[29.8704,  0.9334], [30.1322, -1.6312], [35.1748, -0.5084], [36.7046,  0.3667]];
blade_edge  = [[36.7046,  0.3667], [42.7689,  3.1902], [46.7230,  9.2576], [49.5395, 15.0685]];

/* [Hand slots] */
// Note 22.

slot_span     = 11.582;   // Note 23.
slot_cap_x    = 2.754;    // Note 24.
slot_cap_y    = 3.1784;   // Note 25.
slot_mid_y    = -7.8116;  // Note 26.
slot_side_pos = [19.2341, -5.1521];  // Note 27.
slot_side_rot = 16.0;     // Note 28.

/* [Quality] */
arc_steps   = 240;  // Note 29.
bez_steps   = 48;   // Note 30.
grind_steps = 40;   // Note 31.
round_steps = 24;   // Note 32.
$fn         = 64;   // Note 33.

eps       = 0.01;
overshoot = 6;    // Note 34.

function se_point(a, b, n, cy, t) =
    [a * sign(cos(t)) * pow(abs(cos(t)), 2 / n),
     cy + b * sign(sin(t)) * pow(abs(sin(t)), 2 / n)];

function se_arc(a, b, n, cy, t0, t1, steps) =
    [for (i = [0:steps]) se_point(a, b, n, cy, t0 + (t1 - t0) * i / steps)];

function cubic_bezier(p, u) =
    pow(1 - u, 3) * p[0] + 3 * pow(1 - u, 2) * u * p[1]
    + 3 * (1 - u) * u * u * p[2] + pow(u, 3) * p[3];

// Note 35.

function bezier_points(p, steps, skip_first = false) =
    [for (i = [skip_first ? 1 : 0 : steps]) cubic_bezier(p, i / steps)];

function normalised(v) = v / norm(v);

// Note 36.

function front_cutter_path(top) = concat(
    se_arc(front_a, front_b, front_n, front_cy, 180, 360, arc_steps),
    [[front_a, top], [-front_a, top]]
);

// Note 37.

function grind_growth(dz) =
    grind_run * max(0, dz - grind_land / 2) / (thickness / 2 - grind_land / 2);

// Note 38.

function roll_off(r, theta) = r * (1 - cos(theta));

module notch_cutter() {
    top   = back_cy + back_b + overshoot;
    start = spike_face[0] + normalised(spike_face[0] - spike_face[1]) * overshoot;
    end   = blade_edge[3] + normalised(blade_edge[3] - blade_edge[2]) * overshoot;

    polygon(concat(
        [start],
        bezier_points(spike_face,  bez_steps),
        bezier_points(notch_floor, bez_steps, true),
        bezier_points(blade_edge,  bez_steps, true),
        [end, [mesh_length, top], [start.x, top]]
    ));
}

// Note 39.

module front_cutters() {
    scale([shrink, shrink]) {
        polygon(front_cutter_path(back_cy + back_b + overshoot));
        notch_cutter();
        mirror([1, 0, 0]) notch_cutter();
    }
}

module back_region() {
    scale([shrink, shrink])
        polygon(se_arc(mesh_length / 2, back_b, back_n, back_cy, 0, 360, arc_steps));
}

module hand_slots() {
    scale([shrink, shrink]) {
        translate([0, slot_mid_y]) hand_slot();
        for (s = [-1, 1])
            translate([s * slot_side_pos.x, slot_side_pos.y])
                rotate(s * slot_side_rot)
                    hand_slot();
    }
}

module hand_slot() {
    hull()
        for (s = [-1, 1])
            translate([s * slot_span / 2, 0])
                scale([slot_cap_x, slot_cap_y])
                    circle(r = 1);
}

// Note 40.

module rounded_body_half() {
    for (i = [0 : round_steps - 1]) {
        t0 = 90 * i / round_steps;
        t1 = 90 * (i + 1) / round_steps;
        z0 = back_round * sin(t0);
        z1 = back_round * sin(t1);

        translate([0, 0, thickness / 2 + z0 - eps])
            linear_extrude(height = z1 - z0 + eps, convexity = 10)
                offset(r = -roll_off(back_round, (t0 + t1) / 2))
                    back_region();
    }
}

module rounded_body() {
    rounded_body_half();
    translate([0, 0, thickness]) mirror([0, 0, 1]) rounded_body_half();
}

module grind_cutter_half() {
    span = thickness / 2 - grind_land / 2;

    for (i = [0 : grind_steps - 1]) {
        z0 = grind_land / 2 + span * i / grind_steps;
        z1 = grind_land / 2 + span * (i + 1) / grind_steps;

        translate([0, 0, thickness / 2 + z0 - eps])
            linear_extrude(height = z1 - z0 + 2 * eps, convexity = 10)
                offset(r = grind_growth((z0 + z1) / 2))
                    front_cutters();
    }
}

module slot_cutter_half() {
    for (i = [0 : round_steps - 1]) {
        t0 = 90 * i / round_steps;
        t1 = 90 * (i + 1) / round_steps;
        z0 = (thickness / 2 - slot_round) + slot_round * sin(t0);
        z1 = (thickness / 2 - slot_round) + slot_round * sin(t1);

        translate([0, 0, thickness / 2 + z0 - eps])
            linear_extrude(height = z1 - z0 + 2 * eps, convexity = 10)
                offset(r = roll_off(slot_round, (t0 + t1) / 2))
                    hand_slots();
    }
}

module grind_cutter() {
    // Note 41.

    translate([0, 0, -eps])
        linear_extrude(height = thickness + 2 * eps, convexity = 10)
            front_cutters();

    grind_cutter_half();
    translate([0, 0, thickness]) mirror([0, 0, 1]) grind_cutter_half();
}

module slot_cutter() {
    // Note 42.

    translate([0, 0, -eps])
        linear_extrude(height = thickness + 2 * eps, convexity = 10)
            hand_slots();

    slot_cutter_half();
    translate([0, 0, thickness]) mirror([0, 0, 1]) slot_cutter_half();
}

module batleth() {
    difference() {
        rounded_body();
        grind_cutter();
        slot_cutter();
    }
}

// Note 43.

module feral_default_output_9837034b8a94() {
batleth();
}

module feral_assembly_view_9837034b8a94(explode=false) {
feral_default_output_9837034b8a94();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_9837034b8a94();
else feral_assembly_view_9837034b8a94(view == "exploded");

// Notes

// Note 1. batleth.scad
//
// Klingon bat'leth. Rebuilt from stl/batleth-ORIGINAL.stl, which is a
// 776-triangle mesh with exactly two Z levels — a 2D outline pushed up 1.86 mm,
// with three hand slots through it.
//
// FRONT is +Y: the edge carrying the two outer blade tips and the two mid
// spikes. BACK is -Y: the single long sweep the hand slots are cut just inboard
// of. The front edge is ground to a blade here and the back edge is bullnosed;
// the source mesh has neither, and every profile number below is still measured
// off it. Any of those may be a faithfully copied mistake rather than a
// decision. The two edge treatments are the only authored geometry in the file.
//
// The two long edges are SUPERELLIPSES, not circles and not ellipses. A plain
// circular arc misses the original by up to 2.3 mm; the superellipses below sit
// within 0.26 mm (back) and 0.05 mm (front) of the mesh, i.e. well inside one
// extrusion width. That is the whole reason the exponents are parameters.
//
// A superellipse here is |x/a|^n + |y_off/b|^n = 1, centred on the Y axis at
// y = cy, so it is symmetric left-to-right by construction, as the part is.
// n = 2 is an ellipse; n > 2 squares it off, n < 2 pinches it toward a diamond.
//
// The four short edges between them — the face of each mid spike, the valley at
// the spike's root, and the front edge of each outer blade — are cubic Beziers,
// each fitted to the mesh within 0.05 mm. The mid spike tip and the blade tip
// are not modelled as points: they fall out of where the curves cross.
//
// EVERY COORDINATE BELOW IS AT MESH SCALE, i.e. on a part 99.625 mm tip to tip.
// The flat outline is emitted at that scale and shrunk to `length` on the way
// out, rather than rescaling ninety measured numbers and losing their
// provenance. The shrink is XY only. `thickness` and the two edge treatments —
// grind_run, grind_land, back_round — are authored at FINISHED size and are not
// touched by it, so a nozzle-width land stays a nozzle wide. That works because
// the 2D offsets that cut the grind and the bullnose are applied outside the
// scale, in final millimetres.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. source mesh, tip to tip — the scale every number is in (mm)

// Note 4. finished part, tip to tip (mm)

// Note 5. 11 x 0.20, printed on a 0.20 process. The fixed 0.30 first layer this file
// used to do its arithmetic around belongs to the 0.12 Fine chain alone, not to
// the machine: every 0.20 process on the AD5M resolves both layer_height and
// initial_layer_print_height to 0.20, so here a stack that lands exactly on a
// layer boundary is just a whole number of 0.20s. This plate was 1.50 back on
// 0.12 Fine; half again on that is 2.25, and 2.20 is the nearest boundary to it
// — 47% up, not 50. 2.40 is the boundary above.

// Note 6. plate: 11 layers at 0.20 (mm)

// Note 7. The grind is symmetric, both faces, and stops on a flat land rather than
// running out to nothing — a true knife edge prints ragged anyway, because the
// slicer drops material below about half a line width.
//
// grind_run is capped by the mid spikes, not by the long cutting edges. At this
// size a spike is 2.5 mm across at half its height and under 0.8 mm near its
// point, and the grind eats that from BOTH sides, so anything past about
// 1.25 mm takes the spikes down to the land over most of their length. 1.55 is
// deliberately past that already — it is the 2.0 the full-size part carried,
// shrunk by the same factor.
//
// It did NOT follow the plate from 1.50 to 2.20. Holding the included angle the
// thinner plate had would need 2.54, which is well past what the spikes can
// carry, so the run stays put and the long edges are blunter instead: the bevel
// rises (thickness - grind_land)/2 over grind_run, which is 60 degrees included
// here against 40 before. (The 50 this comment used to claim was never right for
// either plate.) grind_land does not scale either: it is one nozzle, not a
// proportion. back_round does, because "full" is a relationship, not a number.

// Note 8. how far back from the front edge the bevel starts (mm)

// Note 9. flat left at the very edge, one nozzle wide (mm)

// Note 10. bullnose radius on the back edge; = thickness/2, i.e. full (mm)
// The same roll-off on the hand slot walls, so the grip is not a pair of sharp
// arrises. It is NOT taken to thickness/2 like the back edge, because what caps
// it is the web between the mid slot and each side slot: that web is 1.87 mm at
// the mid plane and the roll-off eats it from both sides, so a full 1.10 would
// consume the web outright and the slots would break through into each other at
// both faces. 0.5 keeps 0.87 mm, two lines. It is pinned by that web, not by
// the plate, so it did not move with the thickness — it just leaves more
// vertical land in the middle of the wall now, 1.20 mm against 0.5.

// Note 11. roll-off radius on the hand slot walls (mm)

// Note 12. Half-width is mesh_length/2, so this curve alone sets the overall length. It
// dips to y = back_cy - back_b = -15.07 at the centre, the lowest point on the
// part — mesh scale, like everything else here; 77/99.625 of it when printed.

// Note 13. semi-axis, height (mm)

// Note 14. centre height (mm)

// Note 15. superellipse exponent

// Note 16. Runs from the centre out through both mid spike tips. Its half-width lands
// just inboard of the spikes, and its low point is y = front_cy - front_b.

// Note 17. semi-axis, half-width (mm)

// Note 18. semi-axis, height (mm)

// Note 19. centre height (mm)

// Note 20. superellipse exponent

// Note 21. The right-hand notch, cut as one open region. Read as a chain: the spike face
// falls from the mid spike tip to the notch root, the valley turns the corner,
// and the blade edge climbs to the outer blade tip. Each list is
// [start, handle, handle, end], and consecutive lists share a point. The left
// notch is this one mirrored.

// Note 22. Three identical slots: a stadium with elliptical caps, not circular ones —
// the mesh's caps are 2.75 across and 3.18 tall. The pair either side of centre
// are the same slot rotated to follow the front edge. Left square: they are the
// grip, and the back edge is what the hand actually bears on.

// Note 23. centre to centre of the two caps (mm)

// Note 24. cap semi-axis, along the slot (mm)

// Note 25. cap semi-axis, across the slot (mm)

// Note 26. centre slot, height (mm)

// Note 27. outboard slot centre (mm)

// Note 28. outboard slot tilt (deg)

// Note 29. segments per superellipse sweep

// Note 30. segments per Bezier edge

// Note 31. slices per half thickness through the grind

// Note 32. slices per half thickness through the bullnose

// Note 33. segments per full circle, for the slot caps
// Overshoot on every subtracted region, so no cut face is coplanar with its
// parent. The notch and front cutters are open-ended shapes, so theirs has to
// clear the part rather than just nudge past a face.

// Note 34. how far past a curve's end its cutter runs (mm)
// ---------------------------------------------------------------------------
// Standard superellipse parameterisation: raising |cos|,|sin| to 2/n is what
// makes the implicit exponent come out as n.

// Note 35. skip_first drops the shared knot where one Bezier hands off to the next, so
// the assembled path has no doubled vertex.

// Note 36. Everything above the front superellipse's lower half, closed off overhead.
// Subtracting the closed superellipse instead would leave the crescent's upper
// lobe behind as a second, unwanted arc of material.

// Note 37. How far the front cutters grow, and the back region shrinks, at height dz
// above or below the mid plane. Between them these functions are the whole edge
// treatment: everything else in the file is the flat outline.

// Note 38. One quarter-round, used twice. At the mid plane (theta = 0) it is nothing and
// the surface is vertical; at the face (theta = 90) it is the full radius and
// the surface is tangent to the face. The back edge subtracts it from the
// outline; the hand slots add it to theirs, which is the only difference
// between a bullnosed edge and a rolled-over hole.

// Note 39. Everything that makes the front edge, as one 2D region. Offsetting this
// outward is what grinds the blade, and Minkowski distributes over union, so
// offsetting the three pieces separately gives exactly the same result as
// offsetting their union.

// Note 40. ---------------------------------------------------------------------------
// Both treatments are stacks of thin prisms of a varying 2D offset. Lofting
// between offset outlines with hull() would be wrong here — these outlines are
// deeply concave, and a hull bridges every concavity — so the surfaces are
// stepped instead, fine enough that the steps land well under a layer height.
//
// The two stacks are sliced on different grids on purpose. The bullnose is
// sliced by ANGLE, because its surface is vertical where it meets the face and
// uniform Z slicing would put one enormous step there. The grind is sliced by
// Z, because its surface is a constant-slope plane.

// Note 41. The untreated cut, full thickness. This is the front edge itself; the
// flared stacks above and below it are only the bevel.

// Note 42. The slot at nominal size, full thickness. The flared stacks above and
// below it are only the roll-over; this is the waist they meet at.

// Note 43. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
