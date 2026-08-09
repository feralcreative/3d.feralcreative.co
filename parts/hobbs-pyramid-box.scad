// hobbs-pyramid-box.scad
//
// A case for a nested stack of hobbs-painters-pyramid parts, built like a
// wooden domino box: floor, roof and two of the three walls are permanent, and
// the third wall is a flat door that slides the length of the box in a channel
// down either edge. Open it and the whole stack is in view at once, which is
// the point — these get printed in different colours and you have to be able to
// pick one.
//
// PRINTS STANDING UP, on its bottom, with the door flat on the bed beside it.
// The channels run vertically, which is the only direction they can run without
// support on a part in this orientation, and it is also the direction a domino
// box's lid runs: along the length, out through the top.
//
// THE CAVITY IS THE PYRAMID'S CONVEX HULL, and that is the load-bearing idea in
// this file rather than a detail. Draw the cavity as the pyramid's silhouette —
// base triangle plus a slot out to each lug — and nothing can be loaded through
// the side. Push a pyramid in through the flat face and its lug corner reaches
// the side of its own slot after 0.69 mm of travel, because the lug points at
// 60 degrees and the motion is along 0. Every slot is a trap for the thing it
// was cut for. That is worth saying plainly: the earlier revisions of this box
// had a full-length side opening described as the way in, and it never was one.
// It was a window.
//
// Fill the two notches and the problem disappears. A convex cavity with its
// back face open admits the whole nested column in one straight slide — the
// same geometry that lets a wedge lid work, and for the same reason: at every
// row the shape's leading edge only ever moves into space the shape already
// occupied. The hull costs nothing. The outer envelope is identical, since the
// hull adds nothing beyond the triangle's vertices and the lug tips, and its
// perimeter is shorter than the star's, so the box uses less plastic and loses
// its two fragile points.
//
// It also still holds the stack square. The pyramid's back face lies flat
// against the cavity's back face over its full 60 mm, so rotation is bounded by
// the clearance over that span — about a degree. The lug slots were never what
// was keeping the column straight.
//
// THE OPENING STOPS roof_band SHORT OF THE RIM. The roof has to spring from
// walls on all three sides, and a full-height opening leaves its back edge
// hanging over nothing. Four millimetres of back wall above the opening fixes
// that, and it is inside the headroom over the stack, so it hides nothing — the
// door still reveals every pyramid in the box.
//
// THE TOP IS A PYRAMID, and not only for looks. It is the one surface that can
// say which way the parts inside go, which a blunt convex box cannot. It springs
// from the three flat faces at the rim, so the two lug bumps stop short and
// finish as small flat shoulders beside it.
//
// IT SITS ABOVE THE STACK RATHER THAN OVER IT, and that is forced rather than
// chosen. A cap that wrapped the last pyramid's tip would be worth 13 mm — the
// roof would sit beside the apex instead of above it — but its back face would
// have to be inclined at the same 69.7 degrees the pyramids are, and the door
// slides vertically. An inclined face cannot be slid into an inclined seat by a
// vertical motion; it separates the instant it moves. So either the roof's back
// is vertical or the door never comes out. The roof goes above.
//
// FORTY-FIVE DEGREES IS THE FLOOR on the angle. Steeper matches the parts more
// closely, but a cap's height is its apothem times the tangent of its angle, so
// the pyramids' own 69.7 costs 55 mm where 45 costs 20. Shallower than 45 wants
// support. Nothing in the cap bridges at any angle, which is the other thing it
// buys: the flat roof it replaces needed a 45 degree lead-in for no reason
// except to shorten a 62 mm bridge, and all of that is gone.
//
// THE BOX GOES TRIANGULAR FOR ITS TOP THIRD. Above the highest lug there is
// nothing in the cavity but the last pyramid tapering away, so the lug channels
// stop there and both the cavity and the shell draw in to a plain triangle over
// 12.87 mm — the lug's own reach past the base face, taken at 45 degrees so that
// neither the channel roofs nor the step on the outside needs support. It saves
// plastic, it gives the cap something square to spring from, and it puts a
// triangle back on the part.
//
// HOW THE STACK LENGTH WAS ARRIVED AT. Nested pyramids measured 67 mm at four,
// 75 at five, 100 at eight and 125 at twelve. Those four do not fall on one
// line. Fit the first three alone and you get height = 42.08 + 8.269 * (n - 1)
// with residuals under 0.15 mm, which is what this file used to run on — but
// that line puts twelve at 137.8 mm, and twelve measures 125. Three points in a
// short span will fit almost anything.
//
// Read it the other way instead: hold the single pyramid at the 46.82 the model
// and the STL both give, and ask what pitch each measurement implies. Four says
// 6.73, five says 7.05, eight says 7.60, twelve says 7.11. Scattered by half a
// millimetre, but every one of them well under 8.269.
//
// THE PYRAMID'S OWN GEOMETRY SETTLES IT. A stack stops closing where the raised
// wordmark on the lower pyramid's face meets the upper one's inner face, so the
// pitch is apex_height * (wall_t + art_relief) / (a_out * sin(face_a)), which is
// 6.946 mm. Bare walls alone would nest at 4.61 — the 0.81 mm of relief is what
// sets the spacing, and dropping it is the only lever that would tighten a
// stack. 6.946 is a hard floor: seated, undeformed parts cannot do better.
//
// So the pitch is bracketed. 6.95 from the geometry at the bottom, 7.60 from the
// worst measurement at the top. stack_pitch is set to the top of that bracket:
// it is an upper bound on all four measurements at once. If someone measures a
// long stack cleanly and the pitch comes down to 6.95, the box gets 12 mm
// shorter for free.
//
// NINETEEN IS THE CEILING NOW. The cap costs about 10 mm more than the flat roof
// it replaces, and 10 mm is one pyramid: at nineteen the box comes to 213.4 mm
// against a 215 mm safe height and the door to 195.6 against a 205 mm plate, and
// at twenty the box is 221.0 and simply does not fit. That is what it costs to
// have the top tell you what is inside — and it is a cost that disappears the
// moment the box is printed in more than one piece.
//
// Two things worth knowing before committing to a 20: the box is 3:1 tall to
// wide, which is where ringing and layer shifts start to show on a bed-slinger,
// and a 191 mm nested column wedges harder than a 100 mm one. Pull eight apart
// before trusting twenty. The side door does at least mean a wedged column can
// be pushed out sideways rather than shaken out of a deep tube, which is the one
// thing a top-loading box could never offer.

include <../logos/marks.scad>

/* [Plate] */
show      = "plate"; // [plate, all, box, door, test]
plate_gap = 10.00;   // clear air between box and door on the bed (mm)

/* [Test coupon] */
// "test" is the bottom of the box cut off at test_h, with a short door to match.
// It exists to answer the two questions that would waste a 200 mm print: whether
// a pyramid really does slide in through the side, and whether the door runs in
// its channels at door_slop. The default leaves an opening comfortably taller
// than a pyramid, because a coupon that cannot swallow one proves nothing.
//
// It carries the mark too, at the same size and depth, so the deboss gets read
// before it is committed to.
//
// What it does NOT cover: the draw-in, the lug channels' 45 degree roofs, the
// roof band and the cap are all above the cut. Those are overhang claims rather
// than fit ones. A second coupon off the top would settle them.
test_h = 60.00;  // how much of the box to keep, from the floor up (mm)

/* [Capacity] */
pyramid_count = 19;     // how many nest inside; 20 no longer fits, see the header
pyramid_h     = 46.82;  // one pyramid, apex above base (mm)
stack_pitch   = 7.600;  // each additional pyramid adds this; see the header (mm)
stack_slack   = 6.00;   // headroom between the stack and the roof (mm)

/* [Fit] */
// From the 0.4 mm nozzle column of the clearance ladder in
// docs/flashforge-ad5m-pro-scad-reference.md: free fit 0.30, snug 0.20.
// The door gets the free fit — a door that binds is worse than one that rattles.
// The cavity gets much more than that: it is a container, not a fit, and a
// 191 mm column has to slide in without fighting.
cavity_clear = 0.60;  // all round the pyramid's silhouette (mm)
door_slop    = 0.30;  // door to channel, every face (mm)

/* [Shell] */
// Every thickness here is an integer number of 0.42 mm extrusions, off the wall
// ladder in the printer reference. Numbers between rungs print with gaps or
// over-extrusion, so reach for the next rung rather than a round number:
// 4 = 1.68, 5 = 2.10, 6 = 2.52, 7 = 2.94, 8 = 3.36.
wall    = 2.52;  // side walls, six perimeters (mm)
floor_t = 3.36;  // eight; it carries the whole stack and is free on the bed (mm)

/* [Roof] */
// The cap's wall is the side wall foreshortened by its own slope — wall times
// sin(roof_angle), so 1.78 mm at 45 degrees. It carries nothing but itself.
roof_angle = 45;     // from horizontal; 45 is the shallowest that self-supports
roof_band  = 4.20;   // back wall left above the opening, to spring the cap (mm)
lug_clear  = 4.00;   // clear height above the highest lug before the cavity may
                     // draw in; the lug plate itself is 2.05 thick (mm)

/* [Door] */
// Eight perimeters rather than six, because the mark is sunk into the outer
// face: 3.36 less art_depth still leaves 2.56 mm under the deepest cut, which is
// more than the panel used to carry anywhere.
door_t     = 3.36;  // flat panel thickness, eight perimeters (mm)
door_engage = 4.00; // how far each edge sits inside its channel (mm)
door_lip   = 2.52;  // material outboard of the door, holding it in (mm)
rail_wall  = 3.36;  // material outboard of the channel (mm)
door_tab   = 6.00;  // how far the door stands proud of the rim, to pull on (mm)
post_fillet = 3.00; // fillet joining the channel posts to the body (mm)

/* [Artwork] */
// The maker's mark, sunk into the door's outer face. Registration, scale and
// tessellation all come from ../logos/marks.scad — see that file before
// reaching for import() here.
//
// The pyramid has to cut the figure through and raise the wordmark, because the
// counters of the O and the two Bs are islands that a through-cut drops on the
// floor. A deboss has no such problem — the islands stand on the floor of the
// recess — so both layers go in together.
art_mark   = true;   // set false for a blank door
art_width  = 48.00;  // width of the whole mark across the door (mm)
art_down   = 50.00;  // mark's centre, down from the top of the door (mm)
art_depth  = 0.80;   // how far it is sunk into the face (mm)

/* [Pyramid, as measured] */
// Taken off hobbs-painters-pyramid.scad and its STL. The lug reach is measured
// rather than derived: nominally the tips make 32.02, but lug_tip_r rounds the
// cusp back to 30.19. If that part changes, re-measure all three.
pyr_apothem = 17.3205;  // base triangle, edge to axis (mm)
pyr_lug_r   = 30.19;    // lug tip, from the axis (mm)
pyr_lug_w   = 13.54;    // lug width where it meets the wall (mm)

/* [Quality] */
$fn = 64;

/* [Hidden] */

eps = 0.01;

// Which faces carry lugs. The third face, 180, is the flat one the door is on —
// the only one of the three that is clear.
lug_az = [60, 300];

pyr_R      = 2 * pyr_apothem;   // circumradius of the base triangle
pyr_half_y = pyr_R * sin(120);  // half the pyramid's Y extent — sizes the opening

stack_h    = pyramid_h + (pyramid_count - 1) * stack_pitch;
cavity_len = stack_h + stack_slack;

cav_apothem = pyr_apothem + cavity_clear;
out_apothem = cav_apothem + wall;

// Heights, bottom to top. The lug channels run out at z_lug; the section has
// drawn in to a plain triangle by z_tri; the cap springs from the rim. draw_in
// is the lug's own reach past the base face, and taking it at 45 degrees is what
// makes both the channel roofs and the step outside self-supporting.
z_lug    = floor_t + (pyramid_count - 1) * stack_pitch + lug_clear;
draw_in  = pyr_lug_r - pyr_apothem;
z_tri    = z_lug + draw_in;
z_rim    = floor_t + cavity_len;             // top of the straight cavity
cap_h    = out_apothem * tan(roof_angle);
cap_in_h = cav_apothem * tan(roof_angle);
box_h    = z_rim + cap_h;
open_h   = cavity_len - roof_band;           // height of the way in

// Back face of the shell, and the half-width of the opening in it. The opening
// is taken to the cavity's own back edge so the wall there is gone outright
// rather than left as a sliver.
x_back    = -(pyr_apothem + cavity_clear + wall);
open_half = pyr_half_y + cavity_clear;

// Channel and slab, reckoned outboard from the back face. The door rides
// directly against the shell, held by the slab's lip.
door_half = open_half + door_engage;
slab_half = door_half + door_slop + rail_wall;
slab_t    = door_lip + door_t + door_slop;
x_door    = x_back - door_t - door_slop;
x_slab    = x_back - slab_t;

// The slab runs a wall's worth PAST the back face, not up to it. Stopping at
// x_back leaves it merely tangent to the shell — no material shared, so once the
// opening is cut the two channel posts hang off the box over their whole height,
// and there is nothing inboard of the door to stop it dropping into the cavity.
// Both faults come from the same missing wall.
slab_depth = slab_t + wall;
x_cav_back = -(pyr_apothem + cavity_clear);

door_len = cavity_len + door_tab;

// The coupon's door lands on the same ledge and stands the same tab proud, so
// the fit it proves is the fit the real one gets. Its mark goes in the middle
// rather than art_down from the top, which on a panel this short would hang off
// the end.
test_door_len = test_h - floor_t + door_tab;


// Plan extents. offset(r=) is a dilation by a disk, so an offset shape reaches
// exactly r past the original in every direction, corners included.
box_min_x  = x_slab;
box_max_x  = pyr_R + cavity_clear + wall;
box_half_y = slab_half;   // the slab is the widest thing on the part

// The pyramid's silhouette, made convex: base triangle plus a tab out to each
// lug, hulled. See the header — the hull is what makes side loading possible,
// and it is also why every offset below can be a single call.
module pyr_2d() {
    hull() {
        circle(r = pyr_R, $fn = 3);

        for (az = lug_az)
            rotate(az)
                translate([0, -pyr_lug_w / 2])
                    square([pyr_lug_r, pyr_lug_w]);
    }
}

// The same silhouette without the lug tabs, for everything above the last lug.
module pyr_tri_2d() { circle(r = pyr_R, $fn = 3); }

module cavity_2d()     { offset(r = cavity_clear)        pyr_2d();     }
module shell_2d()      { offset(r = cavity_clear + wall) pyr_2d();     }
module cavity_tri_2d() { offset(r = cavity_clear)        pyr_tri_2d(); }
module shell_tri_2d()  { offset(r = cavity_clear + wall) pyr_tri_2d(); }

// The slab on the back face that the door channels are cut into. It supplies the
// channel's outer lip, its inner wall, and the posts either side of the opening.
module slab_2d() {
    translate([x_slab, -slab_half])
        square([slab_depth, 2 * slab_half]);
}

// Shell and slab together, with the two concave junctions filleted. Only ~2.5 mm
// of shell survives outboard of the opening — the opening is 61 mm and the box is
// 66 mm across the back — so the posts are joined to the body by not much. The
// fillet is a closing operation: dilate then erode, which fills concave corners
// up to its radius and leaves every convex edge where it was.
module box_2d() {
    offset(r = -post_fillet) offset(r = post_fillet) {
        shell_2d();
        slab_2d();
    }
}

// The whole void: full silhouette while there are lugs, drawing in to a triangle
// once there are none, then the inside of the cap. Every hull() here is exact
// because each outline is convex — which they are only because pyr_2d() is
// hulled in the first place.
module cavity_solid() {
    translate([0, 0, floor_t])
        linear_extrude(z_lug - floor_t)
            cavity_2d();

    // the lug channels' roof, at 45 degrees rather than a bridge
    hull() {
        translate([0, 0, z_lug]) linear_extrude(eps) cavity_2d();
        translate([0, 0, z_tri]) linear_extrude(eps) cavity_tri_2d();
    }

    translate([0, 0, z_tri])
        linear_extrude(z_rim - z_tri)
            cavity_tri_2d();

    // inside of the cap
    hull() {
        translate([0, 0, z_rim])            linear_extrude(eps) cavity_tri_2d();
        translate([0, 0, z_rim + cap_in_h]) sphere(r = eps);
    }
}

// Shell, drawing in to match the cavity, capped with the pyramid. The slab runs
// straight the whole way — the channels have to stay parallel — and the fillet
// only matters below z_lug, where the shell is at its narrowest beside the
// opening; above the draw-in the triangle's back edge is wider than the
// heptagon's and the posts pick up 4.8 mm of shell on their own.
module box_solid() {
    linear_extrude(z_rim) slab_2d();
    linear_extrude(z_lug) box_2d();

    hull() {
        translate([0, 0, z_lug]) linear_extrude(eps) shell_2d();
        translate([0, 0, z_tri]) linear_extrude(eps) shell_tri_2d();
    }

    translate([0, 0, z_tri])
        linear_extrude(z_rim - z_tri)
            shell_tri_2d();

    hull() {
        translate([0, 0, z_rim]) linear_extrude(eps) shell_tri_2d();
        translate([0, 0, box_h]) sphere(r = eps);
    }
}

module box() {
    difference() {
        box_solid();

        cavity_solid();

        // the way in: straight through the back wall and the slab, stopping
        // roof_band short of the rim so the roof has a back edge to grow from
        translate([x_slab - eps, -open_half, floor_t])
            cube([slab_depth + 2 * eps, 2 * open_half, open_h]);

        // the channels, open at the top so the door draws out that way and
        // closed at the bottom so it lands on a ledge
        translate([x_door - eps, -(door_half + door_slop), floor_t])
            cube([door_t + door_slop + eps,
                  2 * (door_half + door_slop),
                  z_rim - floor_t + eps]);
    }
}

// Drawn flat on the bed, as it prints: width along X, length along Y, and the
// marked face upward, so the deboss is a pocket in the top surface rather than
// detail laid against the build plate.
module door(len = door_len, mark_y = door_len - art_down) {
    difference() {
        translate([-door_half, 0, 0])
            cube([2 * door_half, len, door_t]);

        if (art_mark)
            translate([0, mark_y, door_t - art_depth])
                linear_extrude(art_depth + eps)
                    hobbs_mark(art_width);
    }
}

// The same panel stood up in its channels, seated on the floor ledge. Tipped up
// about its width and then swung round to face out, which is a plain rotation —
// tempting to reach for mirror() here, and wrong, because that would flip the
// artwork with it. Turn it the other way (rotate 0,0,90) and the panel still
// seats perfectly well, with the mark facing into the box.
module door_seated() {
    translate([x_door + door_t, 0, floor_t])
        rotate([0, 0, -90]) rotate([90, 0, 0])
            door();
}

// The bottom of the box, cut off flat. Everything fit-critical is below the cut:
// the floor ledge the door lands on, the full-width opening, both channels, both
// posts and their fillets.
module test_box() {
    intersection() {
        box();
        translate([box_min_x - 1, -box_half_y - 1, -eps])
            cube([box_len + 2, 2 * box_half_y + 2, test_h + eps]);
    }
}

// "plate" is the pair as they print. "all" seats the door, for looking at.
module hobbs_pyramid_box() {
    if (show == "all" || show == "plate" || show == "box")
        box();

    if (show == "all")
        door_seated();

    if (show == "plate")
        translate([box_max_x + plate_gap + door_half, -door_len / 2, 0])
            door();

    if (show == "door")
        door();

    if (show == "test") {
        test_box();

        translate([box_max_x + plate_gap + door_half, -test_door_len / 2, 0])
            door(test_door_len, test_door_len / 2);
    }
}

// What this actually needs off the machine, echoed on every build. The safe
// figures come from the build envelope section of the printer reference: the
// outer 5 mm of bed is extrapolated rather than probed, and the purge and wipe
// strips eat the front and back. Anything past 205 wants the bed diagonal, which
// buys 290 mm of length as long as length plus width stays under it.
box_len  = box_max_x - box_min_x;
door_wide = 2 * door_half;

plate_x = show == "box"  ? box_len
        : show == "door" ? door_wide
        : show == "all"  ? box_len
        :                  box_len + plate_gap + door_wide;
plate_y = show == "box"  ? 2 * box_half_y
        : show == "door" ? door_len
        : show == "all"  ? 2 * box_half_y
        : show == "test" ? max(2 * box_half_y, test_door_len)
        :                  max(2 * box_half_y, door_len);

// Square on the safe envelope is best. The diagonal is next, and is genuinely
// preferable to squaring up on the full bed: a part longer than 205 axis-aligned
// runs into the unprobed border at both ends and, on Y, the purge and wipe
// strips as well — which a long flat door can least afford.
plate_verdict =
      max(plate_x, plate_y) <= 205 ? "fits square on the safe envelope"
    : plate_x + plate_y <= 290     ? "over 205 — lay it on the diagonal"
    : max(plate_x, plate_y) <= 220 ? "only fits square on the full bed, into the unprobed border and the purge strips"
    : plate_x + plate_y <= 311     ? "only fits diagonally, on the full bed"
    :                                "WILL NOT FIT";

echo(str("hobbs-pyramid-box: ", pyramid_count, " pyramids, stack ", stack_h,
         " mm, box ", box_h, " mm tall, door ", door_wide, " x ", door_len,
         " mm, opening ", open_h, " mm for a ", stack_h, " mm stack"));
echo(str("  cap ", cap_h, " mm at ", roof_angle, " deg, triangular above ",
         z_tri, " mm — that is the top ", box_h - z_tri, " mm of the part"));

if (show == "test")
    echo(str("  TEST COUPON: box section ", test_h, " mm tall, door ",
             test_door_len, " mm, opening ", test_h - floor_t,
             " mm for a ", pyramid_h, " mm pyramid",
             test_h - floor_t < pyramid_h
                 ? " — TOO SHORT, a pyramid will not go in" : ""));
echo(str("  plate ", plate_x, " x ", plate_y, " mm — ", plate_verdict,
         box_h > 215 ? "; BOX IS TALLER THAN THE 215 mm SAFE HEIGHT" : "",
         open_h < stack_h ? "; OPENING IS SHORTER THAN THE STACK" : ""));

hobbs_pyramid_box();
