// Fish koozie, rebored for a 355 ml / 12 oz sleek can — the 12 oz Red Bull.
//
// WildRoseBuilds' "Fish Can Koozie" (Printables 1641365, a 3D scan of a
// vintage foam koozie: a fish head, mouth gaping upward, the can goes in the
// mouth, a lure hooked in the corner of it) is bored for a standard 12 oz can.
// Ziad wants it to hold a Red Bull, which is the same 355 ml in a sleek can:
// Ø57.40 instead of Ø66, and 156 tall instead of 122. Nothing about the fish
// changes. The old bore is filled solid and a new one is cut on the same
// axis, with the bore recipe every slim-can holder in this repo prints with.
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
// height the skin comes as close as r 34.93 to the axis — on the lure side,
// about 19 mm up — which is 0.5 mm outside a Ø68.80 fill. Measured on the
// built mesh: no ray out of the bore leaves the part through the fill
// anywhere, so nothing of the cylinder shows. (The head shell is thinner still
// in two places, 0.38 mm, but those are the sockets under the -x eye and the
// lure, and the shells that sit in them cover them.)
//
// ⚠️ The thinnest wall on the finished part is therefore 34.93 - 29.20, about
// 5.7 mm, and it is the fish's skin that sets it, not anything here.
//
// THE BORE is the repo's settled recipe, carried unchanged from
// slim-can-holder-12oz.scad: drawn 58.40 (can + 0.40 slop + 0.60 for this
// machine's bore shrinkage), six rounded ribs standing 0.30 into it so the
// can is held at 0.17 of clearance rather than rattling in 0.77. The arithmetic
// and the 2026-08-22 coupon it rests on are written up over there; nothing
// here is a new decision. The floor is raised from the scan's 2.35 to 5.40 and
// the drain is recut on the axis.
//
// THE MOUTH. Above z 76.5 the scan's own bore flares open, so the fill stops
// there and a 45-degree lead-in opens the new bore out to meet it: from
// Ø58.40 to the fill's edge over 5.20 of height, then 0.60 more into the
// scan's lip so there is no ledge where the two surfaces hand over. It widens
// going up, so printed floor-down it is an upward-facing slope and needs
// nothing under it.
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
mesh_scale  = 1.0;    // uniform, about the bore axis and the bottom. The can and its bore do not scale

// Measured off the mesh, in its own frame and its own millimetres. These
// place the fish so the bore axis is the z axis and the bottom is z = 0.
mesh_axis     = [-17.048, -17.022];   // centre of the scanned bore (mm)
mesh_bottom   = -9.53198;             // the flat bottom face (mm)
mesh_bore_top = 76.5;                 // where the scanned bore starts flaring into the mouth (mm)
mesh_top      = 107.38;               // tips of the lips (mm)
// The fill, in mesh millimetres (radius). Covers the old bore's r 34.39 and
// stands 0.25 proud of the skin in two gill grooves; see the header.
fill_r = 34.40;

/* [Floor] */

// Floor thickness (mm). The scan's is 2.35; the requirement is at least 5,
// and 5.40 is 27 layers at 0.20.
floor_t = 5.40;
// Drain through the floor, on the axis (mm). Condensation out, a finger in to
// push the can back out of an 80 mm bore. 0 for a closed floor.
drain_d = 12.0;

/* [Mouth] */

// How far past the top of the fill the lead-in keeps opening (mm), so the
// cone runs out into the scan's own flare rather than stopping at a ledge.
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

s        = mesh_scale;
bore_d   = can_d + can_slop + bore_comp;
bore_r   = bore_d / 2;
fill_R   = fill_r * s;
bore_top = (mesh_bore_top - mesh_bottom) * s;   // top of the fill, above the bed
total_h  = (mesh_top - mesh_bottom) * s;

nseg    = facets(fill_R);
r_bore  = r_hole(bore_r, nseg);
r_fill  = r_hole(fill_R, nseg);   // circumscribed, so its flats clear the scan's r 34.39
r_drain = drain_d > 0 ? r_hole(drain_d / 2, nseg) : 0;

// Lead-in: 45 degrees from the bore out to the fill's edge, then lead_over
// further into the scan's own flare.
lead_h  = fill_R - bore_r + lead_over;
lead_z0 = bore_top + lead_over - lead_h;

// Ribs: a circular arc rib_w wide at exactly rib_h proud of the bore.
rib_r  = rib_h > 0 ? (rib_w * rib_w / 4 + rib_h * rib_h) / (2 * rib_h) : 0;
rib_ax = bore_r + rib_r - rib_h;
rib_z0 = floor_t + 1.0;
rib_z1 = lead_z0 - 1.0;

assert(fill_R - bore_r >= 2.10,
       str("fill is only ", fill_R - bore_r, " outside the bore; mesh_scale under ",
           (bore_r + 2.10) / fill_r, " leaves no wall around the can"));
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

// The fish stood on the bed with its bore axis on z.
module fish()
    scale(s) translate([-mesh_axis[0], -mesh_axis[1], -mesh_bottom]) fish_raw();

// The fish with the old bore filled solid from the bottom to the mouth.
module body()
    union() {
        fish();
        cylinder(r = r_fill, h = bore_top, $fn = nseg);
    }

module new_bore() {
    translate([0, 0, floor_t])
        cylinder(r = r_bore, h = total_h, $fn = nseg);
    if (drain_d > 0)
        translate([0, 0, -eps])
            cylinder(r = r_drain, h = floor_t + 2 * eps, $fn = nseg);
    translate([0, 0, lead_z0])
        cylinder(r1 = r_bore, r2 = r_bore + lead_h, h = lead_h, $fn = nseg);
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

module fish_koozie()
    union() {
        difference() {
            body();
            new_bore();
        }
        if (rib_count > 0 && rib_h > 0) ribs();
    }

echo(str("bore ", bore_d, "  across ribs ", bore_d - 2 * rib_h,
         "  floor ", floor_t, "  bore depth ", bore_top - floor_t,
         "  lead-in ", lead_h, " from z ", lead_z0,
         "  fish ", total_h, " tall at scale ", s,
         "  fill ", 2 * fill_R, " (", fill_R - bore_r, " outside the bore)"));

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
