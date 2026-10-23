// Note 1.

/* [Which part] */

// Note 2.

/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

show = "base";   // [base, spinner, fin, post, assembly, exploded]

// Note 4.

spinner_angle = 0;   // Note 5.

explode = 30;   // Note 6.

/* [Base] */

// Note 7.
base_w        = 70;    // Note 8.

post_gap      = 49.5;  // Note 9.

base_h        = 50;    // Note 10.

base_top_r    = 15;    // Note 11.

shoulder_h    = 15;    // Note 12.

base_relief_d = 20;    // Note 13.

/* [Post] */

post_d        = 30.5;  // Note 14.
post_h        = 100;   // Note 15.

post_top_r    = 5;     // Note 16.

/* [Spinner] */

// Note 17.

spinner_flange_d = 50;    // Note 18.
spinner_flange_h = 11.8;  // Note 19.

spinner_boss_d   = 29.6;  // Note 20.
spinner_h        = 37;    // Note 21.

spinner_socket_depth = 26.8;  // Note 22.

/* [Fin] */

fin_t        = 6;     // Note 23.

fin_blade_w  = 70;    // Note 24.
fin_blade_h  = 20;    // Note 25.

fin_mid_w    = 40;    // Note 26.
fin_mid_h    = 7.5;   // Note 27.

fin_tongue_w = 20;    // Note 28.
fin_tongue_h = 19.5;  // Note 29.

fin_bottom_r = 2;     // Note 30.

/* [Fits] */

// Note 31.
post_fit           = 0.25;  // Note 32.
spinner_flange_fit = 0.4;   // Note 33.
spinner_boss_fit   = 0.2;   // Note 34.
fin_fit            = 0.2;   // Note 35.

/* [Quality] */

$fn = 100;   // Note 36.

eps = 0.01;

// Note 37.

arc_n = max(4, ceil($fn / 4));

base_r       = base_w / 2;
bore_spacing = post_gap + post_d;
base_len     = bore_spacing + base_w;
bore_x       = [base_r, base_r + bore_spacing];
spin_x       = base_r + bore_spacing / 2;

// Note 38.
bore_d      = post_d + 2 * post_fit;
pocket_d    = spinner_flange_d + 2 * spinner_flange_fit;
pocket_h    = spinner_flange_h + spinner_flange_fit;
spin_bore_d = spinner_boss_d + 2 * spinner_boss_fit;
cavity_h    = spinner_h + spinner_boss_fit;

fin_h       = fin_blade_h + fin_mid_h + fin_tongue_h;

// Note 39.

fin_tower_h = fin_mid_h + fin_tongue_h;

socket_t    = fin_t + 2 * fin_fit;

// Note 40.

function top_round(r, h, tr) =
    [for (i = [0:arc_n])
        let (a = i * 90 / arc_n)
        [r - tr + tr * cos(a), h - tr + tr * sin(a)]];

// Note 41.

module round_top_solid(d, h, tr) {
    rotate_extrude()
        polygon(concat([[0, 0], [d / 2, 0]],
                       top_round(d / 2, h, tr),
                       [[0, h]]));
}

// Note 42.
module bottom_round_rect(w, h, r) {
    union() {
        hull() {
            translate([-w / 2 + r, r]) circle(r = r);
            translate([ w / 2 - r, r]) circle(r = r);
        }
        translate([-w / 2, r]) square([w, h - r]);
    }
}

// Note 43.
module fin_step(w, y0, h) {
    translate([-w / 2, y0]) square([w, h]);
}

// Note 44.
module socket_step(w, h) {
    translate([-socket_t / 2, -(w + 2 * fin_fit) / 2, 0])
        cube([socket_t, w + 2 * fin_fit, h]);
}

module base() {
    difference() {
        // Note 45.

        hull()
            for (x = bore_x)
                translate([x, base_r, 0])
                    round_top_solid(base_w, base_h, base_top_r);

        // Note 46.
        for (x = bore_x) translate([x, base_r, 0]) {
            translate([0, 0, shoulder_h])
                cylinder(d = bore_d, h = base_h - shoulder_h + eps);
            translate([0, 0, -eps])
                cylinder(d = base_relief_d, h = shoulder_h + 2 * eps);
        }

        // Note 47.
        translate([spin_x, base_r, 0]) {
            translate([0, 0, -eps])
                cylinder(d = pocket_d, h = pocket_h + eps);
            cylinder(d = spin_bore_d, h = cavity_h);
        }
    }
}

module post() {
    round_top_solid(post_d, post_h, post_top_r);
}

module spinner() {
    difference() {
        union() {
            cylinder(d = spinner_flange_d, h = spinner_flange_h);
            cylinder(d = spinner_boss_d,   h = spinner_h);
        }

        // Note 48.

        translate([0, 0, -eps]) {
            socket_step(fin_mid_w,    fin_mid_h + eps);
            socket_step(fin_tongue_w, spinner_socket_depth + eps);
        }
    }
}

// Note 49.

module fin_upright() {
    // Note 50.

    intersection() {
        // Note 51.

        translate([-fin_t / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(height = fin_t)
                union() {
                    bottom_round_rect(fin_blade_w, fin_blade_h, fin_bottom_r);
                    fin_step(fin_mid_w,    fin_blade_h,              fin_mid_h);
                    fin_step(fin_tongue_w, fin_blade_h + fin_mid_h,  fin_tongue_h);
                }

        // Note 52.
        translate([0, fin_blade_w / 2 + eps, 0]) rotate([90, 0, 0])
            linear_extrude(height = fin_blade_w + 2 * eps)
                bottom_round_rect(fin_t, fin_h + eps, fin_bottom_r);
    }
}

module fin() {
    translate([0, 0, fin_t / 2]) rotate([0, 90, 0]) fin_upright();
}

module assembly() {
    base();

    translate([spin_x, base_r, 0]) rotate([0, 0, spinner_angle]) {
        spinner();
        translate([0, 0, -fin_blade_h]) fin_upright();
    }

    for (x = bore_x) translate([x, base_r, shoulder_h]) post();
}

// Note 53.

module exploded() {
    base();

    for (x = bore_x)
        translate([x, base_r, base_h + explode]) post();

    spinner_z = -(spinner_h + explode);

    translate([spin_x, base_r, spinner_z]) rotate([0, 0, spinner_angle])
        spinner();

    translate([spin_x, base_r, spinner_z - explode - fin_tower_h])
        rotate([0, 0, spinner_angle]) fin_upright();
}

// Note 54.

module feral_default_output_aad5f076cea8() {
if      (show == "base")     base();
else if (show == "post")     post();
else if (show == "spinner")  spinner();
else if (show == "fin")      fin();
else if (show == "assembly") assembly();
else if (show == "exploded") exploded();
else assert(false,
    "show must be one of: base, spinner, fin, post, assembly, exploded");
}

module feral_assembly_view_aad5f076cea8(explode=false) {
if(explode) exploded(); else assembly();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_aad5f076cea8();
else feral_assembly_view_aad5f076cea8(view == "exploded");

// Notes

// Note 1. door-stop.scad
//
// A four-part deck door stop, recreated parametrically from the five SketchUp
// meshes in _incoming/door-stop/. Every number below was measured off those
// meshes — see "How it was measured" at the bottom of this header.
//
// THE MECHANISM. A stadium-shaped base lies flat on the deck. A round spinner
// drops into a pocket in its underside and is captured there by its own flange:
// the flange is wider than the bore above it, so once the base is on the ground
// the spinner cannot come out, and it turns freely. A fin plugs up into a
// socket in the spinner from below and hangs 20 mm proud of the base's bottom.
// That fin drops into the gap between two deck boards and is what stops the
// whole thing sliding. Because the fin is carried on the spinner and not on the
// base, the base can face any direction you like while the fin still lines up
// with the gap. Two posts drop into two bores through the base and stand 65 mm
// proud. The door closes into the gap between them and is held there — the
// posts capture it rather than blocking it from one side, which is why the
// stop holds a door that is being pushed either way.
//
// THE PARTS. Four printed pieces, no fasteners, no glue:
//
// base      150 x 70 x 50, one per stop
// spinner   50 dia x 37, one per stop
// fin       6 x 70 x 47, one per stop
// post      30.5 dia x 100, two per stop
//
// THE GAP BETWEEN THE POSTS IS THE DESIGN. post_gap is the clear distance
// between the two post walls — the door's thickness plus enough slop to
// swallow the angle it arrives at. Everything else on the base follows from
// it: bore_spacing is post_gap + post_d, and the overall length is that plus
// base_w. Measure the door, change post_gap, and the base resizes around it.
// The spinner sits midway between the bores, so the fin's anchor point stays
// under the middle of the door however wide the gap gets.
//
// Each bore is a counterbore: post_d + fit down to a shoulder 15 mm off the
// floor, then 20 mm the rest of the way through. The post lands on that
// shoulder, and the 20 mm hole below it is both a finger hole to push the post
// back out and a place for grit to fall through rather than pack up under it.
//
// EVERY FIT IS DERIVED, NOT MEASURED TWICE. The base's pocket and bores are
// computed from the spinner's and post's own diameters plus a named clearance,
// so a change to one moves the other. The reference's numbers all fall out:
// post 30.5 in a 31.0 bore is post_fit = 0.25 a side; spinner flange 50.0 in a
// 50.8 pocket is 0.4 a side; spinner boss 29.6 in a 30.0 bore is 0.2 a side;
// fin 6.0 x 20.0 in a 6.4 x 20.4 socket is 0.2 a side.
//
// THE SOCKET IS 0.2 SHORT OF THE TONGUE, AND THAT IS FINE. The fin's tower
// above its blade shoulder is fin_mid_h + fin_tongue_h = 27.00 mm; the socket
// is 26.80 deep, so the tongue tips out on the ceiling and the blade shoulder
// stops 0.2 mm short of the spinner's face. [FIELD] Two sets printed and in
// use: the fin is a snug friction fit that needed no glue. Nothing bears on
// that shoulder — the fin is loaded sideways, against the deck gap — so the
// 0.2 has nowhere to show up. Recorded because it is a real asymmetry in the
// clearances and someone will otherwise re-derive it; not a defect, and not
// something to "fix". spinner_socket_depth = 27.2 would close it, at the cost
// of a fit that is already right.
//
// [FIELD] EVERY OTHER FIT IS CONFIRMED IN THE HAND, not just in the mesh. The
// spinner turns freely in the base. The posts go in comfortably without being
// tight. The gap between them takes the door with room for it to arrive at an
// angle. Treat the numbers in [Fits] as measured results, not as guesses to be
// tuned.
//
// ⚠️ THE PLATED FIN IS NOT THIS FIN. door-stop-complete.stl is a print plate,
// not an assembly — base, four posts, spinner and fin laid out flat on Z = 0.
// Its fin is 40 mm wide with no third step: a 40 x 27.5 blade under the same
// 20 x 19.5 tongue. door-stop-fin.stl, the individual part file, is 70 mm wide
// and splits that 27.5 into a 70 x 20 blade and a 40 x 7.5 shoulder. This file
// follows the individual part file, which is what was asked for. For the plated
// version set fin_blade_w = 40 and fin_mid_h = 27.5, and fin_blade_h drops out
// of the silhouette on its own.
//
// PRINT ORIENTATION. base, spinner and post all print in the orientation they
// are modelled in, standing as they sit in the assembly, flat face down, no
// support. The fin does not: upright it is a 6 mm wall 47 mm tall, and every
// layer line would run across the direction it is loaded in. show = "fin" lays
// it on its 6 mm face, which is how the reference plate has it, and how the
// stepped silhouette prints with no overhang.
//
// HOW IT WAS MEASURED. Each mesh is a single closed shell and all four share
// one coordinate frame, so the fits were read straight off the overlaps rather
// than inferred. Horizontal sections were taken at every distinct Z and the
// resulting loops fitted for centre, radius and angular step: the outer
// stadium is two 360-gons of radius exactly 35.0000 at (35,35) and (115,35);
// the bores, the spinner and the post are 100-gons; the spinner pocket is a
// 200-gon of radius 25.4000 (1 inch). Both roundings are true circular arcs at
// constant angular step — 5 degrees over 15 mm on the base's top edge, 3.75
// degrees over 5 mm on the post's — and this file rebuilds them from $fn
// rather than copying the reference's segment counts, which are cosmetic.
//
// THE FIN'S BOTTOM ROUNDING is the one place the reference's construction
// shows through. Its bottom edge is rounded 2 mm in both directions, but the
// corners carry no spherical patch: the corner vertices lie on both fillet
// cylinders at once, which is a mitre, not a ball. That is what you get from
// intersecting two prisms each rounded in one direction only, and that is how
// it is built below. A minkowski with a sphere would have been the obvious
// guess and would have cut 0.8 mm off each corner.

// Note 2. One part per build. "assembly" is a check view for eyeballing the fits, not
// something to print.

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. Assembly and exploded views only: turn the spinner to show that the fin is
// not keyed to the base. Any angle is a real position of the real part.

// Note 5. deg
// Exploded view only: gap opened between neighbouring parts along the axis
// each one assembles on. Purely a viewing aid, it changes no geometry.

// Note 6. mm

// Note 7. Width across the stadium, and twice the radius of each rounded end.

// Note 8. mm
// Clear gap between the two posts, wall to wall. The functional dimension:
// the door closes into it. 49.5 on the reference, which takes a 1-3/4 in door
// with 5 mm to spare for the angle. Measure the door and change this one
// number — bore_spacing and base_len both follow.

// Note 9. mm
// Overall height.

// Note 10. mm
// Rounding on the whole top edge. Tangent to the side wall base_h - base_top_r
// off the floor and to the top face at the top, so it is a true quarter round.

// Note 11. mm
// Height of the shoulder each post lands on, measured off the floor.

// Note 12. mm
// The hole below that shoulder. Small enough to hold the post up, big enough
// to get a finger into.

// Note 13. mm

// Note 14. mm

// Note 15. mm
// Rounding on the top edge. Leaves a flat of post_d - 2 * post_top_r.

// Note 16. mm

// Note 17. The captured flange, below the base's bore. Wider than spinner_boss_d is
// what keeps the spinner in.

// Note 18. mm

// Note 19. mm
// The boss that rides in the base's bore, and the whole part's height.

// Note 20. mm

// Note 21. mm
// ⚠️ Depth of the fin socket. The fin's tower is fin_mid_h + fin_tongue_h =
// 27.00, so the reference's 26.8 interferes by 0.2. 27.2 is the value that
// clears. See the header.

// Note 22. mm

// Note 23. mm, thickness
// The blade: the part that hangs below the base and into the deck gap.

// Note 24. mm

// Note 25. mm
// The shoulder step, which is what bears on the spinner's face.

// Note 26. mm

// Note 27. mm
// The tongue, which is what the spinner's socket grips.

// Note 28. mm

// Note 29. mm
// Rounding on the bottom edge, all the way round. Mitred at the corners, not
// balled — see the header.

// Note 30. mm

// Note 31. All radial, per side. The reference's own numbers.

// Note 32. mm, post in its bore

// Note 33. mm, flange in its pocket

// Note 34. mm, boss in its bore

// Note 35. mm, fin in its socket

// Note 36. segments per full circle
// Small overshoot on every subtracted solid so no cut face is coplanar with
// its parent.

// Note 37. ---------------------------------------------------------------------------
// Segments in a 90 degree rounding arc. Derived so there is one quality knob.

// Note 38. Derived from the parts they have to swallow, never measured separately.

// Note 39. The part of the fin that goes up inside the spinner, measured from the blade
// shoulder that bears on the spinner's face.

// Note 40. A quarter-round arc from a vertical wall at radius r up onto a flat top at
// height h. Returned as points for a rotate_extrude profile.

// Note 41. A solid of revolution: flat bottom, straight side, rounded top edge. Hulled
// in pairs this gives the base; alone it gives the post.

// Note 42. A 2D rectangle w x h with only its two bottom corners rounded.

// Note 43. One step of the fin's silhouette: w wide, centred, spanning y0 to y0 + h.

// Note 44. One step of the spinner's fin socket: centred on the axis, rising from Z = 0.

// Note 45. Stadium prism with a rounded top edge, as the hull of two rounded-top
// cylinders. The horizontal section at any height is the hull of two
// circles of that height's radius, which is the stadium the reference
// draws — its ends are arcs of radius exactly base_r, not a fillet.

// Note 46. Post bores: full diameter down to the shoulder, relief hole through.

// Note 47. Spinner cavity: flange pocket open to the floor, blind bore above it.

// Note 48. Fin socket, open at the bottom and blind at the top. Two steps, to
// match the fin's shoulder and tongue.

// Note 49. The fin as it stands in the assembly: thickness on X, width on Y, blade
// bottom at Z = 0. show = "fin" lays this down to print.

// Note 50. The bottom edge is rounded in both directions with a mitre where the two
// roundings meet. Intersecting two prisms, each rounded in one direction,
// is exactly that mitre. See the header.

// Note 51. The stepped silhouette, extruded through the thickness. rotate
// [90,0,90] is the cyclic map (u,v,w) -> (w,u,v): the profile's width
// lands on Y, its height on Z, and the extrusion runs along X.

// Note 52. The thickness, rounded at the bottom and extruded through the width.

// Note 53. Every part at once, pulled apart along the axis it assembles on: posts up out
// of their bores, spinner down out of its pocket, fin down out of the spinner.
// A viewing aid, not a print plate — parts overlap the build volume and each
// other's footprints.

// Note 54. ---------------------------------------------------------------------------
// Assembly display changes placement only; the original output remains the default.
