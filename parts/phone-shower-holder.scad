// phone-shower-holder.scad
//
// One piece. A slotted pocket that holds a phone in the shower, hanging flat
// against the front face of a half-inch glass panel, with a hook at the top
// that caps the glass's edge and reaches back down behind it.
//
// HOW IT HANGS. The geometry below is authored in the tray's own frame, which
// is the frame the v02 mesh was measured in, and that frame is laid on its back
// relative to the way the part is used. Read every tray_* name through this:
//
//     tray +x  ->  DOWN when hung. The "back wall" end is the phone's ledge.
//     tray -x  ->  UP. The "drain end" is the top, and carries the hook.
//     tray z=0 ->  the glass's front face. The flat underside bears on it.
//     tray z<0 ->  behind the glass, which is where the hook has to reach.
//
// Three measured features only make sense this way round, which is the reason
// to trust it. The 2 degree bed slope stands the bed 10.75 mm off the glass at
// the ledge and 3.2 mm at the top, so the phone leans BACK into the pocket. The
// pocket is ~18 mm deep at the ledge and ~4 mm at the top, so a thumb gets
// behind the phone to lift it. And the 40 mm notch in the back wall is a
// charging-cable pass-through at the bottom.
//
// The tray was rebuilt from the v02 mesh in _incoming/. Every tray number was
// MEASURED off that mesh rather than authored, so any of them may be a
// faithfully copied mistake rather than a decision. Two things were
// deliberately not copied: the slits in v02's separate clip, and the 2 degree
// inward lean on the outside of the tray wall.
//
// The hook is authored, not measured. v02 had a dovetail groove across the
// drain-end deck for a separate C-section clip whose mouth opened AWAY from the
// underside - which only works if there is nothing behind the part. There is:
// the glass. The groove and the clip are both gone, and the hook that replaces
// them is integral and points backward.

include <BOSL2/std.scad>

/* [Which output] */
// "fitcheck" adds a slab of glass seated in the hook. Not for printing - it is
// the only view that proves the channel straddles the underside plane.
show = "part";  // [part, fitcheck]

/* [Tray - envelope] */
tray_len      = 216.3;  // overall, drain end to back; the mounted HEIGHT (mm)
tray_width    = 93.0;   // overall (mm)
tray_corner_r = 16.5;   // corner radius, back end only; the drain end is square (mm)
tray_wall     = 2.0;    // rail and back wall (mm)

/* [Tray - bed] */
tray_bed_slope = 2.0;   // deg; hung, this leans the phone back into the pocket
tray_bed_z     = 6.98;  // bed height at mid length (mm)

/* [Tray - drain slots] */
// Hung, these run vertically and drain down the glass.
tray_slot_count  = 5;
tray_slot_w      = 6.0;     // width at the underside (mm)
tray_slot_pitch  = 13.5;    // centre to centre, so the ribs come out 7.5 (mm)
tray_slot_x_lo   = -80.85;  // slot end nearest the drain (mm)
tray_slot_x_hi   = 68.15;   // slot end nearest the back (mm)
tray_rib_round_r = 3.5;     // round-over on the rib tops (mm)
tray_rib_fn      = 16;      // segments in that round-over

/* [Tray - rail sweep] */
tray_rail_r  = 270.9;    // radius of the arc the rail tops follow (mm)
tray_rail_cx = 90.0;     // arc centre, along the length (mm)
tray_rail_cz = -242.61;  // arc centre, height (mm)

/* [Tray - back wall] */
// Hung, this is the ledge the phone stands on, and the notch is the cable
// pass-through.
tray_notch_w   = 40.0;  // gap in the back wall, centred (mm)
tray_flange_t  = 2.0;   // gusset thickness, measured down from the top (mm)
tray_flange_x  = 81.1;  // where the gusset starts (mm)
tray_flange_r  = 11.8;  // fillet from the gusset's edge into the notch line (mm)

/* [Tray - drain end] */
// Hung, this is the top edge, and the deck is the flat the hook's cap grows
// from. v02 cut a dovetail groove across it for a separate clip; that groove is
// gone, and its four numbers with it.
tray_lip_x = -85.351;  // where the deck steps down to the drain lip (mm)
tray_lip_z = 2.8;      // deck height beyond that step (mm)

/* [Hook - over the glass] */
// MEASURE THIS. Nominal half-inch is 12.7, but half-inch tempered is commonly
// supplied at 11.9-12.0 - the reference model in _incoming/ cuts its channel at
// a flat 12.0. Nothing else in the file depends on it, so it is a one-line edit
// and a rebuild, but a slot 0.8 too wide rattles and one too narrow will not go
// on at all.
hook_glass_t   = 12.7;  // panel thickness, provisional (mm)
// Between snug sliding (0.20) and free (0.30) on a 0.4 nozzle, per the
// clearance ladder in docs/flashforge-ad5m-pro-scad-reference.md, opened a
// little because it goes on and off wet.
hook_glass_fit = 0.40;  // total slack across the channel (mm)
// Both faces of the leg are exposed, so the real rungs are 0.84, 1.29, 1.74,
// 2.19 - the corrected ladder in the machine reference, not the one that
// assumes a single line width. The reference model's 2.0 is off the ladder.
hook_leg_t     = 2.19;  // the leg that drops behind the glass (mm)
hook_cap_t     = 5.0;   // material over the glass's top edge (mm)
hook_wrap      = 15.0;  // how far the leg reaches down the back face (mm)
// 45 deg, and it eats into the leg, so it is held to 1.0 rather than the 1.5 it
// wants: any more and the flat left on the leg's end face drops under the
// 0.84 mm the machine reference gives as the floor for a load-bearing feature.
hook_lead_in   = 1.0;   // guide at the channel's mouth (mm)
// The cap's outer face is the first layer when the part prints hook end down,
// where elephant foot swells it. Eased rather than trusting the slicer's
// compensation, which the same reference distrusts.
hook_chamfer   = 0.50;

/* [Quality] */
$fn = 64;          // segments per full circle
tray_cap_steps = 400;  // samples along the swept rail top

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's.
eps = 0.01;

// Tall enough to pass through anything here, short enough to stay cheap.
tall = 80;

// ---------------------------------------------------------------- tray

// Square at the drain end, radiused at the back. Written as a hull so the
// inner face can be had with a single offset() and stays concentric.
module tray_footprint() {
    hull() {
        translate([-tray_len / 2, -tray_width / 2])
            square([tray_len - tray_corner_r, tray_width]);

        for (s = [-1, 1])
            translate([tray_len / 2 - tray_corner_r,
                       s * (tray_width / 2 - tray_corner_r)])
                circle(r = tray_corner_r);
    }
}

// The bed is one tilted plane. Everything that has to sit on it or follow it -
// the slot flares, the interior, the back notch - is built as a child of this
// rather than having the slope re-derived feature by feature.
module on_bed() {
    translate([0, 0, tray_bed_z])
        rotate([0, -tray_bed_slope, 0])
            children();
}

function tray_bed_z_at(x) = tray_bed_z + x * tan(tray_bed_slope);

function tray_arc_z(x) =
    tray_rail_cz + sqrt(max(0, tray_rail_r * tray_rail_r - pow(x - tray_rail_cx, 2)));

// Where the rail arc has climbed to the bed's own slope. Past that point the
// top runs straight on as the arc's tangent, so the sweep and the back cap meet
// without a crease - which is how the measured mesh does it, and the reason the
// arc alone stops fitting past x 80.
tray_rail_blend_x = tray_rail_cx - tray_rail_r * sin(tray_bed_slope);

function tray_top_z(x) =
    x >= tray_rail_blend_x
        ? tray_arc_z(tray_rail_blend_x) + (x - tray_rail_blend_x) * tan(tray_bed_slope)
        : max(tray_arc_z(x), tray_bed_z_at(x));

// The whole upper surface as one silhouette swept across the full width. Where
// the arc is below the bed - the drain half - the bed wins, so this caps the
// floor there and the rails everywhere else.
module tray_top_cap() {
    span = tray_len / 2 + 1;
    pts = concat(
        [[-span, -1], [span, -1]],
        [for (i = [0 : tray_cap_steps])
            let (x = span - i * 2 * span / tray_cap_steps)
                [x, tray_top_z(x)]]
    );

    translate([0, tray_width / 2 + 1, 0])
        rotate([90, 0, 0])
            linear_extrude(height = tray_width + 2)
                polygon(pts);
}

// Half of a slot cut's cross-section: parallel sided below, then an arc that is
// tangent to the slot wall where it leaves it and tangent to the bed where it
// arrives. That tangency is what puts the crown of each rib exactly on the bed
// plane, and it is how the measured mesh reads - the vertical part of the slot
// end face is bed height less this radius, everywhere along the tray.
function slot_arc(h, r, n) =
    [for (i = [0 : n]) let (a = i * 90 / n) [h + r - r * cos(a), -r + r * sin(a)]];

function slot_profile(h, r, n) =
    let (arc = slot_arc(h, r, n))
    concat(
        [[h, -tall]],
        arc,
        [[h + r, tall], [-(h + r), tall]],
        [for (i = [n : -1 : 0]) [-arc[i].x, arc[i].y]],
        [[-h, -tall]]
    );

// One slot, swept twice and intersected: once across the slot so the fillet
// runs along its sides, once along it so the same fillet closes off its ends.
// Away from the ends the second sweep is wider than the tray, so it contributes
// nothing there and the cross-section is exactly the first profile.
module tray_slot_cut(slot_len) {
    intersection() {
        rotate([0, 0, 90])
            rotate([90, 0, 0])
                linear_extrude(height = slot_len + 4 * tray_rib_round_r, center = true)
                    polygon(slot_profile(tray_slot_w / 2, tray_rib_round_r, tray_rib_fn));

        rotate([90, 0, 0])
            linear_extrude(height = tray_width + 2 * tall, center = true)
                polygon(slot_profile(slot_len / 2, tray_rib_round_r, tray_rib_fn));
    }
}

module tray_slots() {
    for (i = [0 : tray_slot_count - 1])
        on_bed()
            translate([(tray_slot_x_lo + tray_slot_x_hi) / 2,
                       (i - (tray_slot_count - 1) / 2) * tray_slot_pitch,
                       0])
                tray_slot_cut(tray_slot_x_hi - tray_slot_x_lo);
}

// What makes it a tray rather than a slab: everything inside the walls and
// above the bed comes out.
module tray_interior() {
    on_bed()
        linear_extrude(height = tall)
            offset(r = -tray_wall)
                tray_footprint();
}

// The back wall is absent across the middle. Its floor is the bed, so this is
// cut in the bed's frame like everything else.
module tray_notch() {
    on_bed()
        translate([tray_len / 2, 0, tall / 2])
            cube([tall, tray_notch_w, tall], center = true);
}

// Beyond the step the deck drops to a flat lip - flat, not on the bed plane,
// which is how the mesh has it.
module tray_drain_lip() {
    translate([-tray_len / 2 - 1, -tray_width / 2 - 1, tray_lip_z])
        cube([tray_lip_x + tray_len / 2 + 1, tray_width + 2, tall]);
}

// Each back corner is closed over by a gusset at the top of the wall - a shelf
// that reaches in from the rail and stops on the same line the back notch does,
// with a generous fillet between the two. It is the only part of the tray that
// is not either wall or floor, and it is what the two squares in the back
// corners of the plan view are.
module tray_flange_plan() {
    for (s = [-1, 1])
        scale([1, s])
            intersection() {
                tray_footprint();

                // shrink then grow, which rounds the corner where the gusset
                // meets the notch line without having to place the arc by hand
                offset(r = tray_flange_r)
                    offset(r = -tray_flange_r)
                        translate([tray_flange_x, tray_notch_w / 2])
                            square([tray_len, tray_width]);
            }
}

// Cut against the top surface lowered by its own thickness, so the gusset comes
// out parallel to the swept top rather than flat - which is how it measures.
module tray_back_flange() {
    difference() {
        linear_extrude(height = tall)
            tray_flange_plan();

        translate([0, 0, -tray_flange_t])
            tray_top_cap();
    }
}

module phone_tray() {
    intersection() {
        union() {
            difference() {
                linear_extrude(height = tall)
                    tray_footprint();

                tray_interior();
                tray_slots();
                tray_notch();
                tray_drain_lip();
            }

            tray_back_flange();
        }

        tray_top_cap();
    }
}

// ---------------------------------------------------------------- hook

// Everything behind the underside plane. The tray's own flat underside is the
// front wall of the channel, so the hook has only to supply the cap over the
// glass's top edge and the leg down its back face - a C in the x-z section,
// swept across the full 93 mm width and open at both ends.
//
// Full width rather than the reference model's inset channel with closed ends.
// Simpler, stronger, better to print, and it lets the holder slide along the
// panel; the cost is that it cannot be hung where the top edge is obstructed
// within 93 mm.

hook_channel_w = hook_glass_t + hook_glass_fit;           // the glass sits in this
hook_back_z    = -(hook_channel_w + hook_leg_t);          // outermost face of the leg
hook_mouth_x   = -tray_len / 2 + hook_cap_t + hook_wrap;  // where the glass goes in

// Drawn in (x, z) and swept along y, the same way the rail sweep is. The cap's
// inner face runs all the way up to the deck rather than stopping at z 0, so it
// overlaps the tray's lip instead of meeting it on a coplanar face.
module hook_section() {
    x0 = -tray_len / 2;

    prof = [
        [x0,                          hook_back_z],
        [hook_mouth_x,                hook_back_z],
        [hook_mouth_x,                -hook_channel_w - hook_lead_in],
        [hook_mouth_x - hook_lead_in, -hook_channel_w],
        [x0 + hook_cap_t,             -hook_channel_w],
        [x0 + hook_cap_t,             tray_lip_z],
        [x0,                          tray_lip_z],
    ];

    // Exactly the tray's width, not over it: the two sets of side faces are
    // meant to come out flush and merge.
    translate([0, tray_width / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = tray_width)
                polygon(prof);
}

// The cap's outer face is the entire first layer when the part prints hook end
// down, and it is a plain rectangle - the tray's drain end is square and the
// hook is full width. Taper the last half millimetre of it rather than letting
// elephant foot swell what is, hung, the top edge of the part.
module hook_end_chamfer() {
    x0 = -tray_len / 2;
    c  = hook_chamfer;
    h  = tray_lip_z - hook_back_z;

    union() {
        hull() {
            translate([x0, -(tray_width / 2 - c), hook_back_z + c])
                cube([eps, tray_width - 2 * c, h - 2 * c]);

            translate([x0 + c, -tray_width / 2, hook_back_z])
                cube([eps, tray_width, h]);
        }

        // Everything past the taper, generous on every side so it clips nothing.
        translate([x0 + c, -tray_width / 2 - 1, hook_back_z - 1])
            cube([tray_len + 2, tray_width + 2, tall]);
    }
}

module phone_holder() {
    intersection() {
        union() {
            phone_tray();
            hook_section();
        }

        hook_end_chamfer();
    }
}

// ---------------------------------------------------------------- output

phone_holder();

if (show == "fitcheck") {
    // Not for printing. A slab of glass seated in the hook: the only view that
    // shows the channel straddling the underside plane, the panel bearing on
    // the cap, and the tray standing clear of the glass down its whole length.
    color("PaleTurquoise", 0.35)
        translate([-tray_len / 2 + hook_cap_t,
                   -(tray_width / 2 + 20),
                   -hook_channel_w + hook_glass_fit / 2])
            cube([tray_len, tray_width + 40, hook_glass_t]);
}
