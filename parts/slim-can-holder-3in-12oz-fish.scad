// Fish koozie, rebored for a 355 ml / 12 oz sleek can — the 12 oz Red Bull.
//
// WildRoseBuilds' "Fish Can Koozie" (Printables 1641365, a 3D scan of a
// vintage foam koozie: a fish head, mouth gaping upward, the can goes in the
// mouth, a lure hooked in the corner of it) is bored for a standard 12 oz can.
// Ziad wants it to hold a Red Bull, which is the same 355 ml in a sleek can:
// Ø57.40 instead of Ø66, and 156 tall instead of 122 — and he wants it inside
// 3 inches, like every other can holder here. The old bore is filled solid
// and a new one is cut, with the bore recipe every slim-can holder in this
// repo prints with; the skin is pulled in around it to fit the envelope.
//
// THREE INCHES, AND HOW THE FISH GETS THERE. As scanned the head is 82.6 x
// 96.2 in plan, and the wall is where the size is: the skin sits 35 to 47 mm
// off the bore axis, 6 to 18 mm of solid around a can that needs 2. A straight
// scale cannot fix that, because it shrinks the bore too — mesh_scale under
// 0.91 left no wall — so instead (Ziad, 2026-09-19) the skin is brought in
// and the bore is left alone: the fish is scaled in X and Y only, about an
// axis moved 3.2 mm toward the head's centre, and the Ø58.40 bore is cut
// afterwards at full size on that axis. Z is not scaled, so the height, the
// bore depth and how much can shows are all as before.
//
// The numbers came out of a search over the built mesh, not a guess. The
// bore sits off-centre in the head — the thinnest skin is on the lure side,
// the fin is on the other — so the axis shift is what buys the wall, and
// squashing Y a little more than X (the fin's direction) buys a little more:
//
//     even 0.846, axis on the scan's         thinnest wall  -0.89  (breaks out)
//     even 0.846, axis shifted 3.8           thinnest wall   1.98
//     X 0.88, Y 0.85, axis shifted 3.2       thinnest wall   2.79  <- this file
//
// That 2.79 is one spot, 20 to 30 mm up on the side away from the lure; the
// wall is 3.0 to 3.5 for the rest of the bore's height and 5 to 15 mm on the
// fin side. It is measured on the built mesh — nothing in this file can see
// the skin — so re-measure if any number in [Mesh] moves.
//
// THE FIN DOES NOT FIT AND IS SHAVED. It stands 45 mm off the axis after the
// scale, and no scale keeps it inside 3 inches: by the time it is in, the
// skin opposite has gone inside the bore (X 0.87, Y 0.72 was the best the
// search found, and it left -1.0 of wall). So the whole part is clipped to a
// Ø76.20 cylinder on the bore axis and the fin gets a flat face 6.9 mm in,
// over its bottom 40 mm. One other spot touches the cylinder: the outside of
// the lip at 70 to 90 mm up crosses it by 0.5 mm and comes out flat there.
//
// ⚠️ LICENCE. CC BY-NC-ND 4.0 — NoDerivatives. This part is a derivative,
// which the licence permits for private use and forbids sharing. It does not
// go on Printables, the NAS viewer, or anywhere else. The mesh lives in
// _incoming/, which is not committed, so this file builds only on a machine
// that has it.
//
// THE MESH, MEASURED. 82.64 x 96.17 x 116.91 mm, in millimetres, standing on a
// flat bottom at z = -9.532 (5,970 vertices on that plane; a Meshmixer plane
// cut). The bore is a clean cylinder — a least-squares fit over z 10..50
// gives Ø67.95 on an axis at (-17.048, -17.022), and the surface sits between
// r 33.53 and 34.39 of it: slightly oval, long axis at about 15 degrees. It
// runs from the floor's top at z -7.18 up to z 76.5, above which it flares
// into the open mouth; the lips carry on up to z 107.38. The floor is 2.35
// thick with a Ø14 hole in it, 5.4 mm off the axis. All of it is measured,
// none of it is a decision of this file; change the mesh and re-measure.
//
// IT ARRIVES AS SEVEN SHELLS, not one: the head, the two eyes as spheres
// dropped onto it (the -x one meshed differently from the +x one), a pupil,
// and three pieces of lure — body, feathers, hook. They overlap and are not
// unioned. import() keeps them that way, and a boolean on that import keeps
// the overlaps too: the first build reported Genus -3 and 246 cm3 for a
// 159 cm3 mesh. Unioning the file with itself makes it worse (genus 980;
// coincident faces are degenerate for an exact boolean). So the mesh is split
// first, utils/stl-shells.py, and this file imports the seven pieces and
// unions them as separate operands, which Manifold resolves cleanly: one
// shell, Genus 2. That is the drain, plus one through-hole the scan itself
// carries: on the lure side of the mouth, 88 mm up, where the fishing line
// stands clear of the lip for a millimetre. The head shell alone reports
// genus 2 as well — its floor hole and that loop — so it is real geometry
// and not a defect of the boolean.
//
// ⚠️ mesh_shells has to match what the split produced. import() of a missing
// file prints a warning and exits 0, so one shell too many is silent and one
// too few builds a fish with no eye. The split prints the count.
//
// THE FILL, AND WHY IT IS 34.40 AND NOT MORE. The old bore has to disappear
// under a solid cylinder before the new one is cut, and that cylinder has to
// cover the whole scanned surface — r 34.39 at the worst — or slivers of the
// old bore survive as sealed voids inside the wall. It cannot be much bigger
// either, because the fish's own wall is thinner than it looks: a foam koozie,
// scanned and scaled down, with the scale lines cut into it. Over the fill's
// height the skin comes as close as r 34.93 to the scan's axis — on the lure
// side, about 19 mm up — which is 0.5 mm outside a Ø68.80 fill. Measured on
// the built mesh: no ray out of the bore leaves the part through the fill
// anywhere, so nothing of the cylinder shows. (The head shell is thinner still
// in two places, 0.38 mm, but those are the sockets under the -x eye and the
// lure, and the shells that sit in them cover them.)
//
// The fill lives in the scan's frame and goes through the same scale and
// shift as the fish, so on the part it is an ellipse, 30.3 x 29.2 on radius,
// centred 3.2 mm off the bore. On the near side the bore cuts clean through
// it and on into the fish's own wall; on the far side its edge stands 2.6 mm
// outside the bore, and the lead-in below takes care of that.
//
// THE BORE is the repo's settled recipe, carried unchanged from
// slim-can-holder-12oz.scad: drawn 58.40 (can + 0.40 slop + 0.60 for this
// machine's bore shrinkage), six rounded ribs standing 0.30 into it so the
// can is held at 0.17 of clearance rather than rattling in 0.77. The arithmetic
// and the 2026-08-22 coupon it rests on are written up over there; nothing
// here is a new decision. The floor is raised from the scan's 2.35 to 5.40 and
// the drain is recut on the axis.
//
// THE MOUTH. The fill stops at z 76.5 (mesh), the top of the scanned bore,
// and a lead-in opens the new bore out to meet the scan's own cavity above
// it: the hull of the bore at the bottom and the fill's outline, grown by
// lead_over, at the top — a skewed cone, 45 degrees on the far side of the
// fill, inside the bore on the near side. The cone reaches past the scan's
// cavity on purpose, so that nothing of the fill's top is left as a shelf,
// and it is cut WITH THE SCAN SUBTRACTED FROM IT, so it removes fill and air
// and never the fish's own wall. Measured on the raw scan, the old bore does
// not flare in the mouth at all: it runs straight up through both jaws at
// the same r 31.5 on the far side (2.3 outside the new bore) until the jaws
// end. Round 02 cut the cone into that wall and the wall stepped back in
// above it — a 1.2 mm ledge, overhanging, at z 86.6, which Ziad saw at once
// (2026-09-19). Now the cone runs from the bore to where it meets the old
// cavity's wall, about 2.3 mm up, and the wall carries on smoothly from
// there. It widens going up, so printed floor-down it is an upward-facing
// slope and needs nothing under it.
//
// HOW MUCH CAN SHOWS. The bore is 80.6 deep from the floor's top, so 75 mm of
// a 156 mm can stands above the throat and 44 mm above the tips of the lips.
// The can this was scanned around stood 37 mm above the throat. mesh_scale
// is the knob if that reads wrong: at 1.20 the fish swallows what the
// original did, and takes 1.7x the plastic to do it.
//
// PRINTED AS MODELLED, flat bottom on the bed, the way the original prints.

/* [Output] */

// "cut" is a half-section for reading the fill, the floor, the lead-in, and
// the ribs. Not for printing. "coupon" is the fit test; see [Fit coupon].
show = "part";   // [part, cut, coupon]

$fa = 4;   // organic faceting per the 0.4-nozzle rule; no global high $fn
$fs = 0.4;
eps = 0.01;

/* [Can] */

// Body diameter of a 355 ml sleek can (mm). Three sources agree on 57.40;
// the 58 mm that Crown publishes is the 204.5 end seam, not the body. The
// long note in slim-can-holder-12oz.scad has the receipts.
can_d = 57.40;
// Clearance on diameter at the bore itself (mm). The ribs set the grip; this
// only has to let the can pass.
can_slop = 0.40;
// Extra diameter for this machine's bore shrinkage (mm). Settled 2026-08-22
// on a printed coupon and matched to rib_h — change both or neither.
bore_comp = 0.60;

/* [Mesh] */

// The split shells, from utils/stl-shells.py, beside the original download.
mesh_dir    = "../_incoming/fish-can-koozie-model_files/fish_koozie-shells/";
mesh_shells = 7;      // what the split reported. See the warning above
// Scale on x, y and z, about the bore axis and the bottom. The can and its
// bore do not scale. [0.88, 0.85, 1] is what puts the head inside 3 inches
// with the most wall left: see THREE INCHES in the header, and re-measure
// the wall on the built mesh if this moves.
mesh_scale  = [0.88, 0.85, 1.0];
// Where the new bore's axis sits relative to the scanned bore's centre, in
// mesh mm, before the scale. Toward the head's centre and away from the
// thin skin on the lure side; it is worth 2.9 mm of wall.
axis_shift  = [1.0, 3.0];

// Measured off the mesh, in its own frame and its own millimetres. These
// place the fish so the bore axis is the z axis and the bottom is z = 0.
mesh_axis     = [-17.048, -17.022];   // centre of the scanned bore (mm)
mesh_bottom   = -9.53198;             // the flat bottom face (mm)
mesh_bore_top = 76.5;                 // where the scanned bore starts flaring into the mouth (mm)
mesh_top      = 107.38;               // tips of the lips (mm)
// The fill, in mesh millimetres (radius). Covers the old bore's r 34.39 and
// stands 0.25 proud of the skin in two gill grooves; see the header.
fill_r = 34.40;

/* [Envelope] */

// The cylinder the finished part is clipped to, on the bore axis (mm). 76.20
// is 3 inches, the family's number. What crosses it is shaved flat — the
// dorsal fin, mostly. 0 for no clip.
envelope_d = 76.20;

/* [Floor] */

// Floor thickness (mm). The scan's is 2.35; the requirement is at least 5,
// and 5.40 is 27 layers at 0.20.
floor_t = 5.40;
// Drain through the floor, on the axis (mm). Condensation out, a finger in to
// push the can back out of an 80 mm bore. 0 for a closed floor.
drain_d = 12.0;

/* [Mouth] */

// How far past the top of the fill the lead-in keeps opening (mm). The cone
// has to reach the scan's cavity wall everywhere before the fill's top, or a
// shelf of fill is left; it cannot reach too far, because the scan is
// subtracted from the cut. See THE MOUTH.
lead_over = 0.60;

/* [Grip ribs] */

// Rounded vertical ribs in the bore. Same six as every slim-can holder here;
// the ladder for rib_h is in slim-can-holder-12oz.scad. 0 for none.
rib_count = 6;
rib_h     = 0.30;   // how far each rib stands into the bore (mm)
rib_w     = 3.00;   // chord width of the bump (mm)
rib_ramp  = 8.0;    // lead-in at the top, over which the rib fades to nothing (mm)
rib_foot  = 2.0;    // the same at the bottom, where the printer sees it as an overhang (mm)

/* [Fit coupon] */

// Height of the coupon (mm): the top of the bore, from where the lead-in
// begins, down. 18 is the 8 mm rib ramp and 10 mm of full-proud rib.
coupon_h = 18.00;
// Wall around the bore on the coupon (mm). The fish's outside is of no
// consequence to the fit, so the coupon is a plain tube: 2.10 is 5 walls.
coupon_wall = 2.10;
// Relief on the bore at the cut face (mm), at 45 degrees, taking the rib tips
// off the first layer.
coupon_relief = 0.60;

/* [Hidden] */

// Faceting: chord error on the biggest circle, so every arc is smooth to the
// same tolerance. Same rule and same functions as slim-can-holder-12oz.scad.
chord_err = 0.02;
function facets(r, e = chord_err) = ceil(180 / acos(1 - e / r));
// Radius that makes the INSCRIBED polygon's inner radius equal r.
function r_hole(r, n) = r / cos(180 / n);

sx = mesh_scale[0];
sy = mesh_scale[1];
sz = mesh_scale[2];
bore_d   = can_d + can_slop + bore_comp;
bore_r   = bore_d / 2;
bore_top = (mesh_bore_top - mesh_bottom) * sz;   // top of the fill, above the bed
total_h  = (mesh_top - mesh_bottom) * sz;

nseg    = facets(fill_r);
r_bore  = r_hole(bore_r, nseg);
r_fill  = r_hole(fill_r, nseg);   // circumscribed, so its flats clear the scan's r 34.39; mesh mm
r_drain = drain_d > 0 ? r_hole(drain_d / 2, nseg) : 0;

// The fill on the part: an ellipse about the scan's axis, which sits at
// old_axis once the shift and the scale have been applied.
old_axis   = [-axis_shift[0] * sx, -axis_shift[1] * sy];
fill_rx    = fill_r * sx;
fill_ry    = fill_r * sy;
// How far the fill's edge gets from the bore axis, at the worst. This is
// what the lead-in has to reach.
fill_reach = max([for (t = [0 : 1 : 359])
                  norm([old_axis[0] + fill_rx * cos(t),
                        old_axis[1] + fill_ry * sin(t)])]);

// Lead-in: from the bore up and out to the fill's edge plus lead_over, at
// 45 degrees where the reach is greatest.
lead_h  = fill_reach + lead_over - bore_r;
lead_z0 = bore_top + lead_over - lead_h;

// Ribs: a circular arc rib_w wide at exactly rib_h proud of the bore.
rib_r  = rib_h > 0 ? (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h) : 0;
rib_ax = bore_r + rib_r - rib_h;
rib_z0 = floor_t + 1.0;
rib_z1 = lead_z0 - 1.0;

assert(lead_h > lead_over,
       "the fill is entirely inside the bore: the scale has gone too far");
assert(envelope_d == 0 || envelope_d / 2 > bore_r + 2.10,
       "the envelope leaves under 5 walls around the bore");
assert(rib_z1 - rib_z0 > rib_ramp + rib_foot + 5,
       "no full-proud rib left between the floor and the lead-in");
assert(coupon_h > rib_ramp + 2,
       "the coupon is all ramp; nothing full-proud to feel");

// The scan, as downloaded: seven shells, unioned as separate operands. See
// the header for why they cannot come in as one file.
module fish_raw()
    union()
        for (i = [0 : mesh_shells - 1])
            import(str(mesh_dir, "shell-", i < 10 ? "0" : "", i, ".stl"),
                   convexity = 10);

// Mesh frame to part frame: the new axis on z, the bottom on the bed, then
// the scale. Everything drawn in the scan's millimetres goes through this.
module placed()
    scale(mesh_scale)
        translate([-(mesh_axis[0] + axis_shift[0]),
                   -(mesh_axis[1] + axis_shift[1]), -mesh_bottom])
            children();

module fish() placed() fish_raw();

// The fill, drawn on the scan's own axis so it lands exactly on the old bore
// whatever the scale and shift do.
module fill()
    placed()
        translate([mesh_axis[0], mesh_axis[1], mesh_bottom])
            cylinder(r = r_fill, h = mesh_bore_top - mesh_bottom, $fn = nseg);

// The fish with the old bore filled solid from the bottom to the mouth.
module body()
    union() {
        fish();
        fill();
    }

// The lead-in: see THE MOUTH in the header.
module lead_in()
    hull() {
        translate([0, 0, lead_z0])
            cylinder(r = r_bore, h = eps, $fn = nseg);
        translate([0, 0, bore_top + lead_over - eps])
            linear_extrude(height = eps)
                offset(r = lead_over) projection() fill();
    }

// The lead-in as it is actually cut: the cone less the scan, so it takes
// fill and air and leaves the fish's own wall alone. See THE MOUTH.
module lead_in_cut()
    difference() {
        lead_in();
        fish();
    }

module new_bore() {
    translate([0, 0, floor_t])
        cylinder(r = r_bore, h = total_h, $fn = nseg);
    if (drain_d > 0)
        translate([0, 0, -eps])
            cylinder(r = r_drain, h = floor_t + 2 * eps, $fn = nseg);
    lead_in_cut();
}

// Each rib is a 3.90 mm arc of which only 0.30 is wanted; the rest would run
// 7 mm out into the wall — and out through the skin where the gill grooves
// thin it. Clipped to the bore's edge before it goes anywhere near the fish.
module ribs() {
    n = facets(rib_r);
    intersection() {
        cylinder(r = bore_r + 0.5, h = total_h, $fn = nseg);
        for (i = [0 : rib_count - 1])
            rotate([0, 0, 30 + i * 360 / rib_count])
                hull() {
                    translate([bore_r + rib_r, 0, rib_z0])
                        cylinder(r = rib_r, h = eps, $fn = n);
                    translate([rib_ax, 0, rib_z0 + rib_foot])
                        cylinder(r = rib_r, h = eps, $fn = n);
                    translate([rib_ax, 0, rib_z1 - rib_ramp])
                        cylinder(r = rib_r, h = eps, $fn = n);
                    translate([bore_r + rib_r, 0, rib_z1])
                        cylinder(r = rib_r, h = eps, $fn = n);
                }
    }
}

// Everything outside envelope_d goes; the fin, mostly.
module clipped()
    if (envelope_d > 0)
        intersection() {
            children();
            translate([0, 0, -1])
                cylinder(r = envelope_d / 2, h = total_h + 2,
                         $fn = facets(envelope_d / 2));
        }
    else children();

module fish_koozie()
    union() {
        difference() {
            clipped() body();
            new_bore();
        }
        if (rib_count > 0 && rib_h > 0) ribs();
    }

echo(str("bore ", bore_d, "  across ribs ", bore_d - 2 * rib_h,
         "  floor ", floor_t, "  bore depth ", bore_top - floor_t,
         "  lead-in ", lead_h, " from z ", lead_z0,
         "  fish ", total_h, " tall at scale ", mesh_scale,
         "  axis ", norm(axis_shift), " off the scan's",
         "  fill ", 2 * fill_rx, " x ", 2 * fill_ry,
         " reaching ", fill_reach - bore_r, " outside the bore",
         "  clipped to ", envelope_d));

// The fit coupon: the top coupon_h of the bore, from where the lead-in
// begins, as a plain tube dropped onto the bed the same way up as the part.
// Cut from the real thing rather than drawn again, so every number that could
// move the bore is the number the part prints with.
module fit_coupon() {
    z0 = lead_z0 - coupon_h;
    c  = coupon_relief + rib_h;   // 45 degrees, clearing the rib tips
    difference() {
        translate([0, 0, -z0])
            intersection() {
                fish_koozie();
                translate([0, 0, z0])
                    cylinder(r = bore_r + coupon_wall, h = coupon_h, $fn = nseg);
            }
        translate([0, 0, -eps])
            cylinder(h = c + eps, r1 = bore_r + coupon_relief + eps,
                     r2 = bore_r + coupon_relief - c, $fn = nseg);
    }
}

if (show == "coupon")
    fit_coupon();
else if (show == "cut")
    difference() {
        fish_koozie();
        translate([0, -total_h, -eps]) cube([total_h, 2 * total_h, 2 * total_h]);
    }
else
    fish_koozie();

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon
