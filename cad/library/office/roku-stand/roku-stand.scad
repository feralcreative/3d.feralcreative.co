// Roku stand.
//
// A parametric recreation of "_incoming/Roku Stand Universal.stl", a
// 4,122-triangle binary mesh with no editable history. Every number below was
// measured off that mesh — see "How it was measured" at the bottom of this
// header.
//
// FITTED TO the Roku Voice Remote Pro (RC-OS1): the pocket squeeze, the
// front scoop, and the slot are all sized against that remote.
//
// THE FORM. An egg-shaped slab with its narrow end cut off, and a D-section
// tube standing on the cut end, flush with it, leaning back 15 degrees. The
// tube is open at the top and its floor is the slab. The top 5 mm of its
// front wall is scooped away so the controls of whatever stands in it are not
// crowded against it, and a slot takes most of the floor so a charging cable
// has somewhere to go, stopping short of the back wall. A letter is debossed
// into the front wall and repeated in the slab's top face, turned to read from
// behind the stand. That is the whole part.
//
// TWO LETTERED BUILDS, and the name matters:
//
//     utils/build.sh parts/roku-stand.scad -D 'mark="Z"' --name roku-stand-z
//     utils/build.sh parts/roku-stand.scad -D 'mark="R"' --name roku-stand-r
//
// Without --name a variant shares the plain part's version series and
// overwrites its file.
//
// HOW IT IS BUILT. Five 2D outlines and one shear.
//
//   base_outline    an ellipse (54.73 x 68.24) whose front 12.8 mm is cut off
//                   by a very shallow arc (R125), the two corners rounded 3.3.
//   tube_outline    a circle (R27.7) clipped to 47 wide, the two clip corners
//                   rounded 11 — which is so large the round runs from the
//                   back arc all the way down to the front — then cut by the
//                   same front arc as the base, so the two stand flush.
//   pocket_outline  the tube outline eroded by wall_t.
//   slot_outline    the pocket narrowed to 23 wide. Its front comes from the
//                   pocket and its rear from the pocket eroded by slot_back,
//                   so the rear edge stays parallel to the back wall.
//   mark_letter     the debossed letter, centred on its measured ink box and
//                   placed twice: in the front elevation, and in plan on the
//                   slab, spun 180 so it reads from behind.
//   cut_profile     the front cutaway, drawn in elevation rather than plan —
//                   an opening 37 wide, floor 7 down from the rim, its bottom
//                   corners rounded 5, so the sides are quarter-rounds with
//                   2 mm of straight above them and it still reads as a scoop
//                   rather than a slot. Where it breaks the rim the wall is rounded
//                   2 as well, which is done on the wall's elevation rather
//                   than the cutter's — the note on the module says why.
//                   cut_reach bounds it in plan: the pocket swept forward,
//                   which is the front wall and open air and nothing else.
//
// The tube is a linear extrusion of its outline run through a Y-shear of
// tan(tilt): every horizontal section is the same D, the top stays flat, and
// the lean costs nothing. The reference is built the same way — the outline
// fits at z=10 and z=30 are identical to the hundredth, only translated.
//
// FIVE DEPARTURES FROM THE REFERENCE. The first is old; the rest are
// deliberate changes to the design, not corrections to the measurement. The
// mesh itself was re-measured on 2026-09-04 and the pocket matched it to 0.03
// in depth and 0.10 in width at every height before the squeeze below was
// applied — see round 03's notes.
//
//   Uniform wall. The reference's inner front arc is not an offset of its
//   outer one (R143 against R125), so its front wall thins from 2.00 at the
//   centre to about 1.6 at the corners. Here the pocket is offset(-wall_t) of
//   the tube outline and the wall is the same all round.
//
//   The pocket is squeezed for fit. wall_t is wall plus pocket_squeeze, so
//   the outside stays the reference's and the pocket loses 2 x pocket_squeeze
//   in both width and depth. It exists because the PETG original gripped the
//   remote and a PLA reprint did not: PETG shrinks a shade more, and its
//   surface is grippier. Set pocket_squeeze to 0 to get the reference's fit
//   back. On a 0.4 nozzle it is wall_t, not wall, that has to land on a
//   nozzle rung — the slicing reference's are 1.68 and 2.10, so with a 0.2
//   squeeze that means wall 1.48 or 1.90.
//
//   The front cutaway. The reference has none: its front wall runs the full
//   30 mm up to the rim. Keep it shallow. It was 5 deep and was lowered to
//   7 on 2026-09-12, the mark dropping 2 with it. The first attempt took the
//   top 10 mm across 43 of the 47 mm width, which opened the top of the pocket
//   into a U — the remote pivoted straight out of it when the stand was
//   lifted, because the closed rim is what stops that, not friction lower
//   down.
//
//   The slot is bigger and squarer. The reference's stops 13.54 from the front
//   face, its rear corners rounded 4.5, its rear edge ramped back from z 4.5
//   at 60 degrees so a plug had something to lean on. Here the pocket bounds
//   it: hard against the inside of the front wall, and slot_back short of the
//   inside of the back one. The ramp is gone with the edge it belonged to and
//   the rear face is vertical.
//
//   The marks. The reference has none. mark cuts a letter into the front wall,
//   and base_mark repeats it in the slab reading from the back. Both are cut
//   the way the chalk holder's wordmark is — see mark_cut for why the taper is
//   there and what it costs.
//
// THE CHAMFERS. Every edge on the reference is either sharp or a 45-degree
// chamfer, bar two 0.5 fillets on the slot rim, which are drawn here as
// chamfers. The base's top edge carries a 1 mm chamfer everywhere except
// along the front, where the tube stands on it — base() fills that strip, and
// the fill also closes the two small notches the reference shows where the
// chamfer ran under the tube's front corners. Inside the tube the floor meets
// the wall on a 1 mm chamfer and the rim carries a 0.5. The tube's outside is
// sharp top and bottom, and so is the cutaway: only its two bottom corners
// are rounded, and that round is in elevation, not plan. The slot's 0.5 rim
// chamfer is now on its two sides alone — its front and rear edges lie on the
// pocket wall, where a chamfer would undercut the tube.
//
// PRINT IT AS BUILT, flat on the slab. The back wall leans 15 degrees from
// vertical, which is nothing; neither the cutaway nor the deeper slot adds an
// overhang; the marks are tapered so no stroke has a roof over it; the only
// bridge is the slot's rim chamfer, half a millimetre.
//
// HOW IT WAS MEASURED. The mesh was sliced at a dozen heights and along both
// vertical axes, the section polygons chained into loops, and each loop cut
// into runs and fitted: least-squares circles, and for the base a
// least-squares ellipse. The base fits an ellipse to 0.002 mm. The tube's
// back is a circle to 0.015; the side runs are circles of r=11.0 (outer) and
// 8.85 (inner) centred 12.5 in from the middle, and 27.7 - 11 = 16.7 is the
// distance from the back arc's centre to theirs, which is what makes them a
// corner round rather than a separate feature. The front arcs fit to 0.04.
// Axis-aligned faces were binned by position to find the flats: the slot
// walls at x = +-11.5, its rear edge at 13.54 from the front, the floor at
// 8.5, the slot ramp starting at 4.5. The tilt is the slope of the back
// arc's fitted centre between z=10 and z=30: 0.2675, which is tan(15.0).
//
// A NOTE ON UNITS. Nothing here is a round number in millimetres or inches:
// 54.73, 68.24, 27.7, 47, 26.3. They are kept as measured.

/* [Base] */
/* [Assembly display] */
// default preserves the original part, coupon and print selectors.
view = "default"; // [default, together, exploded]

base_w         = 54.73;  // widest point of the base ellipse (mm)
base_ellipse_l = 68.24;  // full length of that ellipse before the front is cut off (mm)
base_d         = 55.40;  // front face to back, after the cut (mm)
base_h         = 8.5;    // slab thickness (mm)
base_corner_r  = 3.3;    // round on the two front corners (mm)
base_chamfer   = 1.0;    // 45-degree chamfer on the top edge (mm)
front_r        = 125;    // radius of the shallow arc that forms the front face (mm)

/* [Tube] */
tube_w         = 47;     // outside width (mm)
tube_d         = 26.3;   // outside, front face to back, measured at the floor (mm)
tube_back_r    = 27.7;   // radius of the back arc (mm)
tube_corner_r  = 11;     // round where the back arc meets the sides (mm)
tube_h         = 30;     // height above the slab (mm)
tilt           = 15;     // lean back, degrees from vertical
wall           = 2.0;    // the reference's wall thickness (mm)
pocket_squeeze = 0.3;    // taken off every pocket wall for fit (mm) — 0 is the reference
foot_chamfer   = 1.0;    // inside, where the wall meets the floor (mm)
lip_chamfer    = 0.5;    // inside top edge (mm)

/* [Cable slot] */
slot_w         = 23;     // width (mm)
slot_back      = 3.0;    // how far short of the back wall the slot stops (mm)
slot_corner_r  = 1.0;    // round on the corners (mm)
slot_rim       = 0.5;    // chamfer on the slot's top rim, sides and rear (mm)

/* [Front cutaway] */
cut_side       = 5.0;    // wall left standing each side of the cutaway (mm)
cut_depth      = 7;      // how far down from the rim the cutaway reaches (mm)
cut_corner_r   = 5.0;    // round on the cutaway's two bottom corners (mm)
cut_top_r      = 2.0;    // round where the cutaway breaks the rim (mm)

/* [Front mark] */
mark           = "none"; // [none, Z, R]
mark_h         = 14.0;   // cap height of the letter in the front elevation (mm)
mark_z         = 19.0;   // its centre above the build plate (mm)
mark_depth     = 0.70;   // deboss depth (mm)
mark_taper     = 70;     // deg from horizontal; 90 is a prismatic cut
mark_steps     = 5;      // bands the taper is built from
mark_font      = "Helvetica Neue:style=Bold";
base_mark      = true;   // repeat the letter in the slab's top face
base_mark_y    = 12.0;   // its centre behind the part's middle (mm)

/* [Output] */
show = "part";           // [part, cut]

/* [Quality] */
$fn = 128;               // segments per full circle; the front arc is R125, so keep this high

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's.
eps = 0.01;
big = 200;

// ---- derived ---------------------------------------------------------------

front_y   = -base_d / 2;                       // the front face, at x = 0
tube_cy   = front_y + tube_d - tube_back_r;    // centre of the tube's back arc
foot_h    = foot_chamfer * cos(tilt);          // the chamfers are equal-legged along the leaning wall,
lip_h     = lip_chamfer  * cos(tilt);          // so their vertical rise is a little less than their size
shear     = tan(tilt);                         // y per unit z
wall_t    = wall + pocket_squeeze;             // what actually prints — land THIS on a nozzle rung
cut_half  = tube_w / 2 - cut_side;             // half-width of the cutaway
cut_z     = tube_h - cut_depth;                // its floor, in the tube's own frame

// Ink boxes, measured once at size = 100 in mark_font, the same way
// slim-can-holder-3in.scad records its own: OpenSCAD cannot measure a string at
// render time unless it is run with --enable=textmetrics, which render.sh and
// build.sh do not pass and should not have to. [position, size], both in the
// units text() itself uses, so a letter set at size S has ink S/100 times these.
// position is needed as well as size because it is what centres the letter on
// its INK rather than on its advance width, which for an R is 14.8 wider.
// Re-measure with:
//
//     openscad --enable=textmetrics -o /dev/null --export-format asciistl f.scad
//
// where f.scad echoes textmetrics(s, size = 100, font = mark_font). Measure a
// face you know is missing at the same time — a name that does not resolve
// falls back silently, and the giveaway is metrics that match the fallback.
function mark_ink(s) =
    s == "Z" ? [[3.136, 0], [83.712, 99.136]] :
    s == "R" ? [[9.536, 0], [85.504, 99.200]] :
    undef;

// Set by cap height, so the two letters stand the same height rather than the
// same point size. Their widths then differ, which is correct.
mark_size = is_undef(mark_ink(mark)) ? 0 : mark_h * 100 / mark_ink(mark)[1][1];

assert(tube_w + 2 * base_chamfer < base_w, "tube is wider than the base");
assert(tube_d < base_d, "tube is deeper than the base");
assert(slot_w + 2 * slot_rim < tube_w - 2 * (wall_t + foot_chamfer), "slot is wider than the pocket floor");
assert(2 * (wall_t + foot_chamfer) < tube_d, "no floor left inside the tube");
assert(cut_side >= wall_t, "cutaway would undercut the tube's side wall");
assert(cut_corner_r <= cut_depth && cut_corner_r <= cut_half, "cutaway corner round does not fit");
assert(cut_top_r < cut_side, "cutaway's rim round eats the whole standing wall");
assert(mark == "none" || !is_undef(mark_ink(mark)), "no ink box recorded for this mark");
assert(mark == "none" || wall_t - mark_depth >= 1.20, "not enough wall left behind the mark");
assert(mark == "none" || mark_z + mark_h / 2 < base_h + cut_z, "the mark runs into the cutaway");
assert(mark == "none" || mark_z - mark_h / 2 > base_h, "the mark runs below the tube");
assert(mark == "none" || !base_mark || base_mark_y - mark_h / 2 > front_y + tube_d,
       "the slab's mark runs under the tube");
assert(mark == "none" || !base_mark || base_mark_y + mark_h / 2 < base_d / 2 - base_chamfer,
       "the slab's mark runs off the back of the slab");
assert(mark == "none" || !base_mark || mark_depth < base_h - slot_rim,
       "the slab's mark cuts through the slab");
assert(slot_back >= 0 && slot_back + slot_corner_r < tube_d - 2 * wall_t,
       "the slot has no depth left");
assert(cut_z > foot_h + lip_chamfer, "cutaway reaches into the pocket floor");

// ---- 2D -------------------------------------------------------------------

// Everything on the part's side of the front arc. `inset` moves the arc back
// into the material, which is how the mark's bands are held at a constant depth
// below a face that is curved.
module front_clip(inset = 0)
    translate([0, front_y + front_r]) circle(r = front_r - inset);

// The ellipse, cut by the front arc, front corners rounded.
module base_outline()
    offset(r = base_corner_r) offset(delta = -base_corner_r)
        intersection() {
            translate([0, base_d / 2 - base_ellipse_l / 2])
                scale([base_w / 2, base_ellipse_l / 2]) circle(r = 1);
            front_clip();
        }

// The circle, clipped to width, clip corners rounded, cut by the same front arc.
module tube_outline()
    intersection() {
        offset(r = tube_corner_r) offset(delta = -tube_corner_r)
            intersection() {
                translate([0, tube_cy]) circle(r = tube_back_r);
                square([tube_w, 2 * big], center = true);
            }
        front_clip();
    }

module pocket_outline()
    offset(delta = -wall_t) tube_outline();

// What bounds the slot front and rear: the pocket floor with its rear edge
// pulled forward by `back`. The front edge is left exactly where the pocket
// puts it — the hull is a forward sweep, so it reaches out past the pocket's
// own front and the un-eroded copy is what governs there. Eroding rather than
// cutting on a straight line keeps the rear edge parallel to the back wall.
module slot_clip(back = 0)
    translate([0, foot_h * shear])
        intersection() {
            pocket_outline();
            hull() {
                offset(delta = -back) pocket_outline();
                translate([0, -big]) offset(delta = -back) pocket_outline();
            }
        }

// The slot's footprint: the pocket floor narrowed to slot_w and stopped
// slot_back short of the back wall. `grow` widens the sides and the rear, which
// is where the rim chamfer belongs; the front edge lies on the pocket wall,
// where a chamfer would undercut the tube, and the un-grown clip holds it there.
module slot_outline(grow = 0)
    offset(r = slot_corner_r) offset(delta = -slot_corner_r)
        intersection() {
            square([slot_w + 2 * grow, 2 * big], center = true);
            slot_clip(slot_back - grow);
        }

// The scoop in front elevation: sides at ±cut_half, floor at cut_z, open
// upward. Its two bottom corners are convex on the cutter, so they come out
// as fillets in the finished wall; with cut_corner_r at the full depth the
// sides would be pure quarter-rounds, and at 5 of 7 a 2 mm straight is left
// above each.
module cut_scoop()
    offset(r = cut_corner_r) offset(delta = -cut_corner_r)
        translate([-cut_half, cut_z]) square([2 * cut_half, big]);

// Everything below the rim, wider than the tube: the stock the scoop is taken
// out of, and the shape whose corners are rounded below.
module cut_stock()
    translate([-big, tube_h - big]) square([2 * big, big]);

// The cutaway. Where the scoop breaks the rim it leaves the wall a sharp
// 90-degree corner, and that corner belongs to the wall rather than to the
// cutter — the cutter has no corner there at all, its side simply runs on up
// past the rim. So it is rounded on the wall's own elevation, by an opening
// (shrink sharp, grow round, which rounds convex corners), and the difference
// taken back. The scoop is unioned in again to carry the cutter above the rim.
module cut_profile()
    union() {
        difference() {
            cut_stock();
            offset(r = cut_top_r) offset(delta = -cut_top_r)
                difference() {
                    cut_stock();
                    cut_scoop();
                }
        }
        cut_scoop();
    }

// The letter, centred on its ink at the origin. Centred on the INK and not on
// the advance width, which for an R runs 14.8 wider to the right of the glyph
// and would throw it visibly off centre.
module mark_letter() {
    m = mark_ink(mark);
    k = mark_size / 100;
    translate([-(m[0][0] + m[1][0] / 2) * k, -(m[0][1] + m[1][1] / 2) * k])
        text(mark, size = mark_size, font = mark_font,
             halign = "left", valign = "baseline");
}

// On the front wall, in elevation. Drawn in the tube's own frame, so the 2D y
// is height above the slab.
module mark_glyph()
    translate([0, mark_z - base_h]) mark_letter();

// On the slab's top face, in plan, turned to read from behind the stand. To a
// reader standing at the back the surface's "up" runs -y and their right runs
// -x, so the letter is spun 180 degrees; drawn unspun it would read correctly
// only to someone leaning over the front, which is where the tube is.
module base_mark_glyph()
    translate([0, base_mark_y]) rotate([0, 0, 180]) mark_letter();

// What the cutaway is allowed to reach, in plan: the pocket and everything in
// front of it, narrowed to the opening plus the rim round, which reaches
// wider than the scoop itself. The hull is an exact forward sweep because the
// outline is convex. A fixed y limit instead of this would bite into the side
// walls where they curve inward.
module cut_reach()
    intersection() {
        hull() {
            pocket_outline();
            translate([0, -big]) pocket_outline();
        }
        square([2 * (cut_half + cut_top_r), 2 * big], center = true);
    }

// ---- 3D -------------------------------------------------------------------

// The lean. Shear, not rotate: sections stay horizontal and the top stays flat.
module lean()
    multmatrix([[1, 0, 0, 0], [0, 1, shear, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
        children();

module base() {
    hull() {
        linear_extrude(base_h - base_chamfer) base_outline();
        linear_extrude(base_h) offset(delta = -base_chamfer) base_outline();
    }
    // The tube stands flush with the front edge: put the chamfer back under it.
    translate([0, 0, base_h - base_chamfer])
        linear_extrude(base_chamfer) tube_outline();
}

module tube()
    translate([0, 0, base_h]) lean()
        linear_extrude(tube_h) tube_outline();

// The cavity, with the foot chamfer at the bottom and the lip chamfer at the top.
module pocket()
    translate([0, 0, base_h]) lean() {
        hull() {
            linear_extrude(eps) offset(delta = -foot_chamfer) pocket_outline();
            translate([0, 0, foot_h]) linear_extrude(eps) pocket_outline();
        }
        translate([0, 0, foot_h])
            linear_extrude(tube_h - foot_h - lip_h + eps) pocket_outline();
        hull() {
            translate([0, 0, tube_h - lip_h]) linear_extrude(eps) pocket_outline();
            translate([0, 0, tube_h]) linear_extrude(eps) offset(delta = lip_chamfer) pocket_outline();
        }
    }

// The slot: straight through the slab, its front and rear faces vertical and
// flush with the inside of the tube's walls, a chamfer on the rim, and the
// footprint carried on up through the foot chamfer so nothing overhangs the
// opening.
module slot() {
    rim_z = base_h - slot_rim;
    translate([0, 0, -eps]) linear_extrude(rim_z + eps) slot_outline();
    hull() {
        translate([0, 0, rim_z]) linear_extrude(eps) slot_outline();
        translate([0, 0, base_h]) linear_extrude(eps) slot_outline(grow = slot_rim);
    }
    translate([0, 0, base_h - eps]) linear_extrude(foot_h + eps)
        slot_outline(grow = slot_rim);
}

// The cutaway. The elevation gives it its sides and its rounded floor, the
// plan outline stops it at the front wall.
module front_cut()
    translate([0, 0, base_h]) lean()
        intersection() {
            translate([0, 0, -eps]) linear_extrude(tube_h + 2 * eps) cut_reach();
            translate([0, big / 2, 0]) rotate([90, 0, 0]) linear_extrude(big) cut_profile();
        }

// The mark, debossed into the front wall.
//
// A prismatic cut leaves a horizontal roof over the top of every stroke, and a
// slicer's answer to that is support material inside the lettering. Sloping
// every face removes the roof. The cost is stroke width, because the cut narrows
// as it deepens: the deepest section is the letter eroded by depth / tan(taper).
// 90 is prismatic. 45 is the classic self-supporting chamfer and costs 1.00 mm
// per mm of depth. 70 is still 20 degrees off vertical, well inside what prints
// unsupported, and costs 0.36 — 0.25 off each edge at this depth, against stems
// of about 2.5 mm on a 14 mm cap.
//
// The taper is a stack of prismatic bands, not a true draft, because
// linear_extrude cannot loft between two offsets of a 2D shape. Each band leaves
// a ledge as deep as itself: 5 over 0.70 is 0.14, under one layer.
//
// Erosion is taken from each band's OUTER face, so band 0 is the letter at full
// size and it reads its true width from outside; eroding by the inner figure
// would thin the visible outline and bury the widest part of the cut.
//
// The shell is what makes the depth constant. This face is an arc, not a plane —
// it falls away 0.20 mm over the half-width of a letter this size — so a cut
// bounded by a flat plane would come out that much shallower at the letter's
// edges than at its middle. Bounding each band between two insets of the same
// arc instead keeps it 0.14 deep everywhere. Both shells are faceted at the same
// $fn as the face itself, so their vertices line up with it and the band comes
// out exactly its nominal thickness rather than a sliver more or less.
module mark_cut() {
    if (mark != "none") {
        steps = mark_taper >= 90 ? 1 : max(1, mark_steps);
        band  = mark_depth / steps;
        translate([0, 0, base_h]) lean()
            for (k = [0 : steps - 1]) {
                d_out = band * k;
                d_in  = band * (k + 1);
                erode = mark_taper >= 90 ? 0 : d_out / tan(mark_taper);
                intersection() {
                    translate([0, big / 2, 0]) rotate([90, 0, 0])
                        linear_extrude(big) offset(delta = -erode) mark_glyph();
                    // Band 0 reaches eps out past the face; the rest reach into
                    // the band above, so no two meet on a shared plane.
                    translate([0, 0, -big / 2]) linear_extrude(big)
                        difference() {
                            front_clip(d_out - eps);
                            front_clip(d_in);
                        }
                }
            }
    }
}

// The same letter again, sunk into the slab's top face. No shell here: that face
// is flat, so a band is simply the letter extruded between two heights. Nor does
// the taper do any structural work on a face that points up — there is no roof
// to bridge either way — but it matches the front and it reads better than a
// prismatic cut catching the light on a horizontal surface.
module base_mark_cut() {
    if (mark != "none" && base_mark) {
        steps = mark_taper >= 90 ? 1 : max(1, mark_steps);
        band  = mark_depth / steps;
        for (k = [0 : steps - 1]) {
            d_in  = band * (k + 1);
            erode = mark_taper >= 90 ? 0 : (band * k) / tan(mark_taper);
            // Band 0 reaches eps above the face; the rest into the band above.
            translate([0, 0, base_h - d_in]) linear_extrude(band + eps)
                offset(delta = -erode) base_mark_glyph();
        }
    }
}

module roku_stand()
    difference() {
        union() {
            base();
            tube();
        }
        pocket();
        slot();
        front_cut();
        mark_cut();
        base_mark_cut();
    }



// Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.
module feral_default_output_58d65c8966f0() {
if (show == "cut")
    difference() {
        roku_stand();
        translate([-big, -big, -1]) cube([big, 2 * big, big]);
    }
else
    roku_stand();
}

module feral_assembly_view_58d65c8966f0(explode=false) {
feral_default_output_58d65c8966f0();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_58d65c8966f0();
else feral_assembly_view_58d65c8966f0(view == "exploded");
