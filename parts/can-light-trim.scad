// can-light-trim.scad
//
// A replacement trim and lens for the recessed can light outside the
// bedroom, which has lost its own. Two printed pieces: a white PETG trim
// whose collar pushes into the 118 mm hole and whose flange covers the
// ceiling around it, and a clear PETG lens that drops into the collar from
// the back before the trim goes up.
//
// The lens rests on a ledge at the back of the flange, so in the ceiling
// gravity holds it against the ledge; six small nubs above it stop it
// rattling or falling out while the trim is in the hand.
//
// The trim holds itself in by friction: the collar is slotted into
// fingers, and a ridge on each finger stands proud of the hole so the
// fingers flex in as the collar goes up.
//
// ⚠️ ASSUMED: 118 mm is the hole the collar goes into (Ziad, 2026-10-11),
// and whatever it grips (drywall edge or can wall) is at least as deep as
// grip_z. Not yet confirmed which it is, or how deep it runs.
// ⚠️ ASSUMED: an LED lamp. PETG softens around 80 °C; an incandescent or
// halogen lamp this close to the lens and collar will warp them.
// ⚠️ ASSUMED: nothing in the can (lamp, socket) reaches down within
// collar_h of the ceiling.
//
// Axes: print orientation. Z=0 is the visible face, flat on the bed; +Z
// runs up into the ceiling. The flange's back (Z=flange_t) sits on the
// ceiling.
//
// Build each piece under its own name:
//   utils/build.sh parts/can-light-trim.scad -D 'show="trim"' --name can-light-trim
//   utils/build.sh parts/can-light-trim.scad -D 'show="lens"' --name can-light-lens

/* [View] */
show = "lens"; // [assembly, section, trim, lens]

/* [Measured] */
hole_d = 118; // mm, ceiling hole the collar goes into

/* [Flange] */
border = 20; // mm, flange width beyond the hole edge
flange_t = 3.0; // mm, face to ceiling
edge_chamfer = 1.2; // mm, 45° on the visible outer edge; also beats elephant's foot
aperture_chamfer = 1.0; // mm, 45° on the visible aperture edge

/* [Collar] */
collar_fit = 0.4; // mm per side, collar to hole, before the ridges
collar_wall = 2.10; // mm, 5 × 0.42 lines on a 0.4 nozzle
collar_h = 25; // mm, above the ceiling
collar_lead = 1.0; // mm, 45° outer chamfer at the top so it finds the hole
finger_count = 12;
finger_slot_w = 2.5; // mm, gap between fingers
finger_base_h = 8; // mm, solid ring above the flange before the slots start

/* [Grip ridge] */
grip_interference = 0.8; // mm per side beyond the hole wall
grip_z = 12; // mm above the ceiling, ridge centre
grip_flat = 1.0; // mm, flat crest height; flanks are 45°

/* [Lens] */
lens_t = 2.0; // mm, ten 0.20 layers
lens_fit = 0.3; // mm per side, lens to collar bore
lens_ledge = 3.0; // mm, how far the ledge reaches in under the lens
lens_chamfer = 0.4; // mm, both edges of the lens

/* [Retaining nubs] */
nub_count = 6;
nub_depth = 0.8; // mm, inward from the collar bore
nub_arc = 8; // degrees each
nub_gap = 0.15; // mm, lens top to nub underside

/* [Colors] */
trim_color = "WhiteSmoke";
lens_color = [0.75, 0.88, 1.0, 0.55];

/* [Resolution] */
$fa = 2;
$fs = 0.4;
eps = 0.01; // mm, overshoot on cuts

/* [Derived] */
hole_r = hole_d / 2;
collar_or = hole_r - collar_fit;
collar_ir = collar_or - collar_wall;
aperture_r = collar_ir - lens_ledge;
flange_r = hole_r + border;
collar_top = flange_t + collar_h;
lens_r = collar_ir - lens_fit;
grip_p = collar_fit + grip_interference; // ridge projection past the collar
grip_zc = flange_t + grip_z;
nub_z = flange_t + lens_t + nub_gap;

assert(lens_r > aperture_r + 1, "Lens must rest on the ledge");
assert(lens_r > collar_ir - nub_depth, "Nubs must overlap the lens");
assert(nub_z + 2*nub_depth < flange_t + finger_base_h, "Nubs belong on the solid ring");
assert(grip_zc - grip_flat/2 - grip_p > flange_t + finger_base_h, "Ridge must sit on the fingers");
assert(grip_zc + grip_flat/2 + grip_p < collar_top - collar_lead, "Ridge must clear the lead-in");
assert(2*flange_r <= 205, "Flange exceeds the safe build envelope");

module trim_profile() {
    polygon([
        [aperture_r + aperture_chamfer, 0],
        [flange_r - edge_chamfer, 0],
        [flange_r, edge_chamfer],
        [flange_r, flange_t],
        [collar_or, flange_t],
        [collar_or, collar_top - collar_lead],
        [collar_or - collar_lead, collar_top],
        [collar_ir, collar_top],
        [collar_ir, flange_t],
        [aperture_r, flange_t],
        [aperture_r, aperture_chamfer],
    ]);
}

module grip_profile() {
    z0 = grip_zc - grip_flat/2;
    z1 = grip_zc + grip_flat/2;
    polygon([
        [collar_or - eps, z0 - grip_p],
        [collar_or + grip_p, z0],
        [collar_or + grip_p, z1],
        [collar_or - eps, z1 + grip_p],
    ]);
}

module nub_profile() {
    polygon([
        [collar_ir + eps, nub_z],
        [collar_ir - nub_depth, nub_z + nub_depth],
        [collar_ir + eps, nub_z + 2*nub_depth],
    ]);
}

module finger_slots() {
    for (i = [0 : finger_count - 1])
        rotate(i * 360 / finger_count)
            translate([collar_ir - 1, -finger_slot_w/2, flange_t + finger_base_h])
                cube([collar_wall + grip_p + 2, finger_slot_w, collar_h]);
}

module trim() {
    color(trim_color)
        difference() {
            union() {
                rotate_extrude() trim_profile();
                rotate_extrude() grip_profile();
                for (i = [0 : nub_count - 1])
                    rotate(i * 360 / nub_count - nub_arc/2)
                        rotate_extrude(angle = nub_arc) nub_profile();
            }
            finger_slots();
        }
}

module lens() {
    color(lens_color)
        rotate_extrude()
            polygon([
                [0, 0],
                [lens_r - lens_chamfer, 0],
                [lens_r, lens_chamfer],
                [lens_r, lens_t - lens_chamfer],
                [lens_r - lens_chamfer, lens_t],
                [0, lens_t],
            ]);
}

module assembly() {
    trim();
    translate([0, 0, flange_t]) lens();
}

if (show == "trim") trim();
else if (show == "lens") lens();
else if (show == "section")
    difference() {
        assembly();
        translate([-flange_r - 1, -2*flange_r, -1]) cube([2*flange_r + 2, 2*flange_r, collar_top + 2]);
    }
else assembly();
