// Beaded-chain shade drive: bead sprocket plus a first-pass housing for sizing.
// Requirements: _PLANS/shade-drive-design-brief-2026-10-15.md (local only).
// Bought parts and decisions: ~/www/ezzat/home.ezzat.com/docs/shade-drive-plan.md.
// Architecture, route assumption, and open decisions: docs/architecture.md.
//
// The chain values are measured (2026-10-16). The motor and hub come from the
// Pololu dimension drawings. Everything about the route, wall standoff, pivot,
// latch, keeper, carrier, and cover is a SIZING pass: it shows how big the unit
// is, not that it fits a window.
//
// Assembly frame: +X along the wall, +Y out from the wall into the room, +Z up,
// wall face at Y=0. The sprocket axis runs along Y, centred on X=0, Z=0, with
// the chain wrapped under it and both strands rising to the shade's clutch.
// Sprocket print frame: axis on Z, each half outer face on the bed.

/* [Chain: measured 2026-10-16] */
chain_bead_d = 4.5;        // mm, #10 plastic bead chain
chain_pitch = 6.0;         // mm bead centre to bead centre
chain_cord_d = 1.5;        // mm, cord between beads
chain_joiner_d = 7.6;      // mm, one per loop; cannot seat in a pocket
chain_joiner_l = 13.25;    // mm
chain_wrap = 180;          // deg; ASSUMED route, see docs/architecture.md

/* [Motor: Pololu 37D 131:1 64 CPR #4756, from Pololu drawing 0J1735] */
mtr_gear_d = 36.8;         // mm gearbox diameter
mtr_gear_l = 26.5;         // mm gearbox length, 100:1 to 150:1
mtr_can_d = 34.8;          // mm motor can diameter
mtr_can_l = 30.7;          // mm
mtr_enc_d = 34.0;          // mm encoder cap diameter
mtr_enc_l = 15.4;          // mm
mtr_shaft_offset = 7.0;    // mm, output shaft off the body axis
mtr_boss_d = 12.0;         // mm, bearing boss around the shaft
mtr_boss_l = 6.0;          // mm
mtr_shaft_d = 6.0;         // mm D-shaft
mtr_shaft_flat = 5.4;      // mm across the flat
mtr_shaft_l = 16.0;        // mm beyond the boss
mtr_hole_r = 15.5;         // mm, 6x M3 on a regular hexagon of 15.5 mm sides
mtr_screw_max = 3.0;       // mm, deepest a screw may go into the gearbox face
mtr_lead_keepout = [8, 8, 12];  // mm, X x Y x Z: motor clocked so the leads leave toward +X; ASSUMED

/* [Hub: Pololu 6 mm hub #1999, from Pololu drawing 0J667] */
hub_flange_d = 25.4;       // mm
hub_flange_t = 5.0;        // mm, M3 holes threaded through it
hub_boss_d = 12.0;         // mm, set-screw boss, faces the motor
hub_boss_t = 4.2;          // mm
hub_bolt_r = 9.5;          // mm, 6x M3
hub_recess = 1.0;          // mm the flange sits into the sprocket for centring
hub_recess_clear = 0.8;    // mm on DIAMETER of the centring recess; verify by coupon

/* [Outboard bearing: 625ZZ on an M5-shoulder bolt, optional per plan P5] */
brg_od = 16;               // mm
brg_id = 5;                // mm
brg_w = 5;                 // mm
brg_show = true;           // reserve and draw the outboard yoke
brg_insert_d = 5.6;        // mm, M4 heat-set insert hole in the sprocket centre; PLACEHOLDER
brg_leg_t = 7;             // mm yoke leg thickness along Y around the bearing
brg_leg_gap = 3;           // mm, sprocket outboard face to yoke leg: button heads stand 1.65
brg_bolt_head = [8.5, 3];  // mm, shoulder bolt head diameter and height; PLACEHOLDER

/* [Sprocket: design choices] */
spr_pockets = 15;          // integer; 15 puts three hub screws midway between pockets
spr_rim_above = 1.2;       // mm the rim stands radially beyond the bead centres
spr_side_wall = 1.5;       // mm of wheel beyond the pocket on each face
spr_mouth_flare = 0.3;     // mm per side the pocket widens toward its mouth
spr_screw_n = 3;           // M3 button-head screws through both halves into the hub
spr_shaft_clear_d = 7;     // mm, shaft clearance through the motor-side half
spr_min_web = 0.84;        // mm, thinnest web allowed between pockets; two lines

/* [Fit allowances: verify with the coupon] */
// Each is a separate number on purpose; do not widen them together.
// The printer reference measured bores 0.55-0.65 mm small on diameter in PETG.
spr_pocket_clear = 0.5;    // mm on DIAMETER of each bead pocket
spr_groove_clear = 0.3;    // mm PER FACE of the cord groove, and below the cord
screw_d = 3.0;             // mm, M3
screw_hole_clear = 0.7;    // mm on DIAMETER of M3 clearance holes
foot_chamfer = 0.5;        // mm, 45 deg on edges that print on the bed

/* [Pocket coupon] */
// Complete sprocket pairs that differ ONLY in pocket clearance. Identify each
// pair by the dimples on its bed faces: one dimple is the first value.
cpn_pocket_clears = [0.2, 0.35, 0.5, 0.65]; // mm on diameter; 0.65 is the most a 6 mm pitch allows
cpn_gap = 6;               // mm between parts on the plate

/* [Route and mounting: ASSUMED, unmeasured] */
asm_chain_y = 30;          // mm, chain plane off the wall; UNMEASURED
asm_release_deg = 20;      // deg the cartridge swings to lift the sprocket clear
asm_pivot = [-22, 7];      // mm, X and Z of the cartridge pivot; PLACEHOLDER
asm_latch = [22, 22];      // mm, X and Z of the release latch; PLACEHOLDER. Above the
                           // keeper arm's release arc, which crosses Z 4 to 15 at this X
asm_pin_d = 4;             // mm, pivot and latch pins; PLACEHOLDER
asm_pillar_d = 7;          // mm, base pillars carrying the pins
asm_strand_beads = 12;     // beads drawn on each straight strand
asm_show_wall = false;     // translucent wall slab; it hides the iso view

/* [Structure: sizing pass] */
base_t = 5;                // mm wall plate
base_slot = [5, 20];       // mm, width and length of the vertical adjustment slots
cart_t = 4;                // mm cartridge face plate; M3 x 6 gives 2 mm into the gearbox
cart_bottom_z = -12.5;     // mm, lowest the cartridge plate reaches
keeper_clear = 1.5;        // mm, bead outer edge to keeper
keeper_t = 2;              // mm
cov_wall = 2.5;            // mm
cov_clear = 1.5;           // mm between the cover and anything inside it
cov_r = 4;                 // mm outer corner radius
cov_slot_w = 10;           // mm strand notches: joiner 7.6 plus clearance

/* [Electronics: sizing pass] */
ele_board = [30, 60, 1.6]; // mm protoboard X x Y x Z; PLACEHOLDER cut size
ele_board_x = -6;          // mm, board centre X; puts the XIAO's USB-C near the -X side
ele_board_y0 = 38;         // mm, board's wall-side edge; clear of the keeper
ele_socket_h = 8.5;        // mm female header sockets
ele_pin_h = 3;             // mm of pins below the board
ele_top_gap = 2;           // mm, tallest module to the cartridge plate
xiao = [21, 17.5, 4.7];    // mm, XIAO ESP32-S3: long side along X, USB-C on the -X end
drv = [15.24, 17.78, 3.5]; // mm, Pololu DRV8874 carrier #4035, 0.6 x 0.7 in
reg = [13, 10, 3];         // mm, Pololu D36V6F5 #3792
ant_keepout = [8, 40, 10]; // mm, U.FL FPC antenna on the cover's -X wall; PLACEHOLDER

/* [Controls: sizing pass] */
btn_d = 12;                // mm panel hole
btn_bezel = [15, 2];       // mm bezel diameter and proud height; PLACEHOLDER
btn_body = [13, 20];       // mm body diameter and depth behind the panel; PLACEHOLDER
btn_pitch = 16;            // mm
btn_z = -22;               // mm, button row height on the front face
jack_hole_d = 11;          // mm, 5.5 x 2.1 panel jack; PLACEHOLDER
jack_body = [13, 16];      // mm body diameter and depth inside; PLACEHOLDER
jack_xy = [15, 15];        // mm, jack position on the bottom face

/* [Display] */
show = "print-set";        // [print-set, half-a, half-b, pocket-coupon, section, assembly, assembly-open, release]

/* [Colors] */
// Preview only; STLs carry no colour. Each printed piece gets its own.
half_a_color = "SteelBlue";
half_b_color = "DarkOrange";
base_color = "SeaGreen";
cart_color = "MediumPurple";
keeper_color = "Gold";
yoke_color = "Tomato";
carrier_color = "Teal";
cover_color = [0.85, 0.85, 0.9, 1];
bought_color = "DimGray";
board_color = "DarkGreen";
chain_color = "WhiteSmoke";
placeholder_color = [1, 0.15, 0.15, 0.35]; // translucent red: assumed, not a real part
wall_color = [0.6, 0.55, 0.5, 0.25];

/* [Hidden] */
eps = 0.01;                // mm boolean overshoot
chord_err = 0.02;          // mm, 0.4 nozzle faceting target
function facets(r) = min(128, max(8, ceil(180 / acos(1 - min(chord_err / r, 0.5)))));
function r_hole(r) = r / cos(180 / facets(r)); // circumscribe: polygons are inscribed

// ---- Sprocket, derived. Radii are named for what they measure.
spr_pitch_ang = 360 / spr_pockets;
spr_pitch_r = chain_pitch / (2 * sin(180 / spr_pockets)); // bead-centre radius
spr_rim_r = spr_pitch_r + spr_rim_above;                  // outer radius of the wheel
spr_bead_out_r = spr_pitch_r + chain_bead_d / 2;          // seated bead's outer edge
function spr_pocket_d(pc) = chain_bead_d + pc;
function spr_half_w(pc) = spr_pocket_d(pc) / 2 + spr_side_wall; // mid-plane to outer face
// The cord runs as a chord between seated beads; its midpoint sits closest to the axis.
spr_cord_min_r = spr_pitch_r * cos(180 / spr_pockets);
spr_groove_root_r = spr_cord_min_r - chain_cord_d / 2 - spr_groove_clear;
spr_groove_w = chain_cord_d + 2 * spr_groove_clear;
spr_flare_len = spr_rim_above + 1;                        // pocket channel runs past the rim
function spr_web_pitch(pc) = chain_pitch - spr_pocket_d(pc);
function spr_web_rim(pc) = 2 * spr_rim_r * sin(180 / spr_pockets)
    - (spr_pocket_d(pc) + 2 * spr_mouth_flare * spr_rim_above / spr_flare_len);
// Screws sit midway between pockets, 120 deg apart.
spr_screw_ang0 = spr_pitch_ang / 2;
spr_screw_hole_r = (screw_d + screw_hole_clear) / 2;
// Wall left between a screw hole and its nearest pocket, both at the mid-plane.
spr_screw_pocket_gap = sqrt(pow(hub_bolt_r, 2) + pow(spr_pitch_r, 2)
    - 2 * hub_bolt_r * spr_pitch_r * cos(spr_pitch_ang / 2))
    - spr_pocket_d(spr_pocket_clear) / 2 - spr_screw_hole_r;
spr_hw = spr_half_w(spr_pocket_clear);
joiner_wrap_deg = 2 * asin(chain_joiner_l / 2 / spr_pitch_r);

assert(spr_pockets == round(spr_pockets) && spr_pockets >= 6, "Pocket count must be an integer >= 6");
assert((360 / spr_screw_n) % spr_pitch_ang == 0, "Screws must land midway between pockets at every position");
assert(spr_web_pitch(spr_pocket_clear) >= spr_min_web,
       str("Web between pockets is ", spr_web_pitch(spr_pocket_clear), " mm; raise the pitch or pocket count"));
assert(spr_screw_pocket_gap >= 0.8, str("Hub screws leave ", spr_screw_pocket_gap, " mm to a pocket"));
assert(spr_groove_root_r - (hub_bolt_r + spr_screw_hole_r) >= 1.5, "Cord groove runs into the hub screws");
assert(hub_recess <= spr_side_wall - 0.4, "Hub recess reaches the pockets");

// ---- Assembly, derived. Y stations from the wall out.
y_spr = asm_chain_y;                                   // chain and sprocket mid-plane
y_hub_face = y_spr + spr_hw - hub_recess;              // hub flange face; the shaft ends here
y_boss_face = y_hub_face + mtr_shaft_l;                // gearbox boss face
y_gear_face = y_boss_face + mtr_boss_l;                // gearbox face, cartridge plate's front
y_mtr_back = y_gear_face + mtr_gear_l + mtr_can_l + mtr_enc_l;
y_leg1 = y_spr - spr_hw - brg_leg_gap;                 // yoke leg, sprocket side
y_leg0 = y_leg1 - brg_leg_t;
mtr_axis = [0, mtr_shaft_offset];                      // X, Z of the motor body axis
mtr_r = mtr_gear_d / 2;
cart_r = mtr_hole_r + 4.5;                             // plate radius around the motor axis
keeper_r = spr_bead_out_r + keeper_clear;
yoke_w = 2 * (spr_pitch_r - chain_bead_d / 2 - 1.5);   // between the strands
yoke_z0 = spr_rim_r + 2;
yoke_t = 5;

// Release: a point (x, z) swung about the pivot by asm_release_deg.
function swing(p) = let (v = p - asm_pivot, a = -asm_release_deg)
    asm_pivot + [v[0] * cos(a) + v[1] * sin(a), -v[0] * sin(a) + v[1] * cos(a)];
spr_lift = swing([0, 0])[1];
swing_top = max(swing(mtr_axis)[1] + mtr_r, swing(mtr_axis)[1] + cart_r,
                swing([yoke_w / 2, yoke_z0 + yoke_t])[1], swing([-yoke_w / 2, yoke_z0 + yoke_t])[1],
                swing(asm_latch)[1] + asm_pillar_d / 2 + 1);

// Electronics stack, from the cartridge plate down.
ele_stack_top = cart_bottom_z - ele_top_gap;
ele_board_top = ele_stack_top - ele_socket_h - max(xiao[2], drv[2], reg[2]);
ele_floor_z = ele_board_top - ele_board[2] - ele_pin_h - 2;  // carrier floor top
// Cover interior: everything above plus clearance, then the wall.
cov_in_x0 = min(asm_pivot[0] - asm_pillar_d / 2, ele_board_x - ele_board[0] / 2,
                -btn_pitch - btn_bezel[0] / 2, -mtr_r) - cov_clear;
cov_in_x1 = max(asm_latch[0] + asm_pillar_d / 2, btn_pitch + btn_bezel[0] / 2, mtr_r,
                mtr_enc_d / 2 - 1 + mtr_lead_keepout[0],
                spr_pitch_r + cov_slot_w / 2) + cov_clear;
cov_in_z0 = ele_floor_z - 2 - cov_clear;               // carrier floor is 2 thick
cov_in_z1 = swing_top + cov_clear;                     // tallest part with the cartridge released
cov_in_y1 = y_mtr_back + cov_clear + 2;                // 2 mm of lead bend room behind the encoder
cov_box = [cov_in_x1 - cov_in_x0 + 2 * cov_wall, cov_in_y1 + cov_wall,
           cov_in_z1 - cov_in_z0 + 2 * cov_wall];

echo(str("SPROCKET: ", spr_pockets, " pockets, bead-centre radius ", spr_pitch_r,
         " mm, rim radius ", spr_rim_r, " mm, cord groove root radius ", spr_groove_root_r, " mm"));
echo(str("SPROCKET: web between pockets ", spr_web_pitch(spr_pocket_clear), " mm at bead centres, ",
         spr_web_rim(spr_pocket_clear), " mm at the rim; hub screw holes ", spr_screw_pocket_gap,
         " mm from a pocket"));
echo(str("SPROCKET: ", chain_wrap, " deg of wrap seats ", floor(chain_wrap / spr_pitch_ang), " to ",
         floor(chain_wrap / spr_pitch_ang) + 1, " beads by geometry alone; load sharing is unproven"));
echo(str("SPROCKET: ", spr_pockets * chain_pitch, " mm of chain per revolution; ",
         29.4 * spr_pitch_r / 1000, " N*m at the measured 3 kg worst-case pull"));
echo(str("SPROCKET: the joiner spans ", joiner_wrap_deg, " deg of wheel, about ",
         round(joiner_wrap_deg / spr_pitch_ang * 10) / 10, " pockets"));
echo(str("SPROCKET: hub screws M3 x ", 2 * spr_hw - hub_recess + hub_flange_t,
         " button head end flush with the hub flange's motor side"));
echo(str("RELEASE: ", asm_release_deg, " deg about the pivot lifts the sprocket ", spr_lift, " mm"));
echo(str("ENVELOPE: housing ", cov_box[0], " W x ", cov_box[2], " H x ", cov_box[1],
         " D mm; ", cov_box[1] + btn_bezel[1], " mm off the wall to the button bezels"));
echo(str("ENVELOPE: chain plane ", asm_chain_y, " mm off the wall (ASSUMED); strands leave the top ",
         2 * spr_pitch_r, " mm apart; housing spans Z ", cov_in_z0 - cov_wall, " to ",
         cov_in_z1 + cov_wall, " mm about the sprocket axis"));

// ================================================================ sprocket

// One bead pocket, bead centre at the origin, radial along +X, axis along +Z.
// A seat sphere swept straight out past the rim, widening toward the mouth, so
// the tangential walls bear on the bead and the chain can articulate in.
module spr_pocket(pc) {
    d = spr_pocket_d(pc);
    hull() {
        sphere(d = d, $fn = facets(d / 2));
        translate([spr_flare_len, 0, 0])
            sphere(d = d + 2 * spr_mouth_flare, $fn = facets(d / 2));
    }
}

// The complete wheel, chain mid-plane at Z=0, motor side (half A) toward -Z.
module spr_wheel(pc) {
    hw = spr_half_w(pc);
    difference() {
        cylinder(r = spr_rim_r, h = 2 * hw, center = true, $fn = facets(spr_rim_r));
        for (i = [0 : spr_pockets - 1])
            rotate([0, 0, i * spr_pitch_ang])
                translate([spr_pitch_r, 0, 0]) spr_pocket(pc);
        rotate_extrude(angle = 360, $fn = facets(spr_rim_r))
            translate([spr_groove_root_r, -spr_groove_w / 2])
                square([spr_rim_r - spr_groove_root_r + 1, spr_groove_w]);
        for (i = [0 : spr_screw_n - 1])
            rotate([0, 0, spr_screw_ang0 + i * 360 / spr_screw_n])
                translate([hub_bolt_r, 0, 0])
                    cylinder(r = r_hole(spr_screw_hole_r), h = 2 * hw + 1, center = true,
                             $fn = facets(spr_screw_hole_r));
        // Motor side: hub flange centring recess and shaft clearance.
        translate([0, 0, -hw - eps])
            cylinder(r = r_hole((hub_flange_d + hub_recess_clear) / 2), h = hub_recess + eps,
                     $fn = facets(hub_flange_d / 2));
        translate([0, 0, -hw - 1])
            cylinder(r = r_hole(spr_shaft_clear_d / 2), h = hw + 1 + eps, $fn = facets(spr_shaft_clear_d / 2));
        // Outboard side: M4 heat-set insert for the bearing's shoulder bolt.
        translate([0, 0, -eps]) cylinder(r = r_hole(brg_insert_d / 2), h = hw + 2 * eps, $fn = facets(brg_insert_d / 2));
    }
}

// Chamfer the bed edges that mate or rub: the rim, and the recess or insert mouth.
module spr_foot_chamfers(which) {
    c = foot_chamfer;
    translate([0, 0, -eps])
        difference() {
            cylinder(r = spr_rim_r + 1, h = c + eps, $fn = facets(spr_rim_r));
            cylinder(r1 = spr_rim_r - c, r2 = spr_rim_r + eps, h = c + eps, $fn = facets(spr_rim_r));
        }
    rr = which == "a" ? r_hole((hub_flange_d + hub_recess_clear) / 2) : r_hole(brg_insert_d / 2);
    translate([0, 0, -eps]) cylinder(r1 = rr + c, r2 = rr - eps, h = c + eps, $fn = facets(rr));
}

// A half in print orientation: outer face on Z=0, mid-plane face up.
module spr_half(pc, which, id_dimples = 0) {
    hw = spr_half_w(pc);
    difference() {
        translate([0, 0, hw])
            intersection() {
                rotate([which == "a" ? 0 : 180, 0, 0]) spr_wheel(pc);
                translate([-spr_rim_r - 1, -spr_rim_r - 1, -hw - 1])
                    cube([2 * spr_rim_r + 2, 2 * spr_rim_r + 2, hw + 1]);
            }
        spr_foot_chamfers(which);
        // Coupon identity: N dimples on the bed face, on a pocket's radial line,
        // clear of the recess, the insert, and the screws.
        if (id_dimples > 0)
            for (j = [0 : id_dimples - 1])
                rotate([0, 0, (j - (id_dimples - 1) / 2) * 9])
                    translate([which == "a" ? (hub_flange_d + hub_recess_clear) / 2 + 0.9
                                            : brg_insert_d / 2 + 1.6, 0, -eps])
                        cylinder(d = 1.2, h = 0.6 + eps, $fn = 12);
    }
}

module spr_half_colored(pc, which, id_dimples = 0) {
    color(which == "a" ? half_a_color : half_b_color) spr_half(pc, which, id_dimples);
}

module print_set(pc = spr_pocket_clear, id_dimples = 0) {
    pitch = 2 * spr_rim_r + cpn_gap;
    translate([-pitch / 2, 0, 0]) spr_half_colored(pc, "a", id_dimples);
    translate([pitch / 2, 0, 0]) spr_half_colored(pc, "b", id_dimples);
}

module pocket_coupon() {
    n = len(cpn_pocket_clears);
    pitch = 2 * spr_rim_r + cpn_gap;
    for (i = [0 : n - 1]) {
        pc = cpn_pocket_clears[i];
        if (spr_web_pitch(pc) < spr_min_web)
            echo(str("COUPON WARNING: pocket clearance ", pc, " leaves a ", spr_web_pitch(pc), " mm web"));
        translate([(i - (n - 1) / 2) * pitch, 0, 0]) {
            translate([0, pitch / 2, 0]) spr_half_colored(pc, "a", i + 1);
            translate([0, -pitch / 2, 0]) spr_half_colored(pc, "b", i + 1);
        }
    }
}

// The halves stacked in the wheel frame, mid-plane at Z=0, half A toward -Z.
module spr_assembled(pc = spr_pocket_clear) {
    hw = spr_half_w(pc);
    translate([0, 0, -hw]) spr_half_colored(pc, "a");
    translate([0, 0, hw]) rotate([180, 0, 0]) spr_half_colored(pc, "b");
}

// Wheel frame into the assembly frame: wheel -Z (motor side) becomes +Y, and a
// pocket at wheel angle a sits at angle a in the XZ plane.
module wheel_to_asm() { translate([0, y_spr, 0]) rotate([90, 0, 0]) children(); }

// ================================================================ bought parts
// Reference geometry only. Dimensions from the Pololu drawings cited above.

// Along +Y from the gearbox face at Y=0, output shaft on the Y axis.
module motor_37d() {
    color(bought_color) {
        translate([mtr_axis[0], 0, mtr_axis[1]]) rotate([-90, 0, 0]) {
            cylinder(d = mtr_gear_d, h = mtr_gear_l, $fn = 64);
            translate([0, 0, mtr_gear_l]) cylinder(d = mtr_can_d, h = mtr_can_l, $fn = 64);
            translate([0, 0, mtr_gear_l + mtr_can_l]) cylinder(d = mtr_enc_d, h = mtr_enc_l, $fn = 64);
        }
        rotate([90, 0, 0]) {
            cylinder(d = mtr_boss_d, h = mtr_boss_l, $fn = 32);
            translate([0, 0, mtr_boss_l])
                intersection() {
                    cylinder(d = mtr_shaft_d, h = mtr_shaft_l, $fn = 24);
                    translate([mtr_shaft_flat - mtr_shaft_d / 2 - mtr_shaft_d, -mtr_shaft_d / 2, 0])
                        cube([mtr_shaft_d, mtr_shaft_d, mtr_shaft_l]);
                }
        }
    }
    // Encoder leads and their bend, leaving toward +X: direction ASSUMED.
    color(placeholder_color)
        translate([mtr_axis[0] + mtr_enc_d / 2 - 1, mtr_gear_l + mtr_can_l + 2,
                   mtr_axis[1] - mtr_lead_keepout[2] / 2])
            cube(mtr_lead_keepout);
}

// Hub on the shaft, flange face at Y=0, boss toward +Y (the motor).
module hub_1999() {
    color("Silver") rotate([-90, 0, 0]) difference() {
        union() {
            cylinder(d = hub_flange_d, h = hub_flange_t, $fn = 48);
            cylinder(d = hub_boss_d, h = hub_flange_t + hub_boss_t, $fn = 32);
        }
        translate([0, 0, -1]) cylinder(d = mtr_shaft_d, h = 20, $fn = 24);
        for (i = [0 : 5]) rotate([0, 0, i * 60])
            translate([hub_bolt_r, 0, -1]) cylinder(d = screw_d, h = hub_flange_t + 2, $fn = 12);
    }
}

// 625ZZ and its shoulder bolt, bearing's sprocket-side face at Y=0, toward -Y.
module bearing_625() {
    color("Silver") rotate([90, 0, 0]) {
        difference() {
            cylinder(d = brg_od, h = brg_w, $fn = 48);
            translate([0, 0, -1]) cylinder(d = brg_id, h = brg_w + 2, $fn = 24);
        }
        translate([0, 0, -brg_leg_gap - 3]) cylinder(d = brg_id - 1, h = brg_leg_gap + 3 + brg_w, $fn = 16);
        translate([0, 0, brg_w + (brg_leg_t - brg_w) / 2])
            cylinder(d = brg_bolt_head[0], h = brg_bolt_head[1], $fn = 32);
    }
}

// Protoboard with the three socketed modules, board top at Z=0, wall-side edge at Y=0.
module electronics() {
    b = ele_board;
    color(board_color) translate([-b[0] / 2, 0, -b[2]]) cube(b);
    color(placeholder_color) translate([-b[0] / 2 + 1, 1, -b[2] - ele_pin_h]) cube([b[0] - 2, b[1] - 2, ele_pin_h]);
    module mod(size, x, y) {
        color("Black") translate([x, y, 0]) cube([size[0], size[1], ele_socket_h]);
        color(bought_color) translate([x, y, ele_socket_h]) cube(size);
    }
    mod(xiao, -b[0] / 2, 2);                                 // USB-C on the -X end
    mod(drv, -b[0] / 2 + 2, 2 + xiao[1] + 4);
    mod(reg, -b[0] / 2 + 2, 2 + xiao[1] + drv[1] + 8);
    // Motor and encoder connectors at the front end, under the encoder.
    color("White") translate([-b[0] / 2 + 4, b[1] - 8, 0]) cube([20, 6, 7]);
}

// Panel button, front face of the panel at Y=0, bezel outward along +Y.
module button() {
    color("Silver") rotate([90, 0, 0]) {
        translate([0, 0, -btn_bezel[1]]) cylinder(d = btn_bezel[0], h = btn_bezel[1], $fn = 32);
        translate([0, 0, cov_wall]) cylinder(d = btn_body[0], h = btn_body[1], $fn = 32);
    }
}

// PLACEHOLDER chain in the chain plane: beads seated in the pockets across the
// bottom of the wheel, strands rising from the tangent points to the clutch.
module chain_placeholder() {
    R = spr_pitch_r;
    wrap = [for (i = [0 : spr_pockets]) let (a = i * spr_pitch_ang)
        if (a >= 180 && a <= 180 + chain_wrap) [R * cos(a), R * sin(a)]];
    first = wrap[0];
    last = wrap[len(wrap) - 1];
    z_left = first[1] + sqrt(pow(chain_pitch, 2) - pow(first[0] + R, 2));
    z_right = last[1] + sqrt(pow(chain_pitch, 2) - pow(R - last[0], 2));
    left = [for (k = [asm_strand_beads - 1 : -1 : 0]) [-R, z_left + k * chain_pitch]];
    right = [for (k = [0 : asm_strand_beads - 1]) [R, z_right + k * chain_pitch]];
    pts = concat(left, wrap, right);
    color(chain_color) translate([0, y_spr, 0]) {
        for (p = pts) translate([p[0], 0, p[1]]) sphere(d = chain_bead_d, $fn = 12);
        for (i = [0 : len(pts) - 2])
            hull() {
                translate([pts[i][0], 0, pts[i][1]]) sphere(d = chain_cord_d, $fn = 8);
                translate([pts[i + 1][0], 0, pts[i + 1][1]]) sphere(d = chain_cord_d, $fn = 8);
            }
    }
}

// ================================================================ housing (sizing pass)

module rounded_box(size, r) {
    hull() for (x = [r, size[0] - r], z = [r, size[2] - r])
        translate([x, 0, z]) rotate([-90, 0, 0]) cylinder(r = r, h = size[1], $fn = 24);
}

// P3 wall base: the only thing on the wall. Vertical slots set chain tension.
module base_plate() {
    w = cov_in_x1 - cov_in_x0; h = cov_in_z1 - cov_in_z0;
    color(base_color) {
        difference() {
            translate([cov_in_x0, 0, cov_in_z0]) rounded_box([w, base_t, h], 2);
            for (x = [cov_in_x0 + 8, cov_in_x1 - 8], z = [cov_in_z0 + 14, cov_in_z1 - 14])
                hull() for (dz = [-1, 1] * (base_slot[1] - base_slot[0]) / 2)
                    translate([x, -1, z + dz]) rotate([-90, 0, 0])
                        cylinder(d = base_slot[0], h = base_t + 2, $fn = 16);
        }
        // Pillars carrying the pivot and latch pins out to the cartridge plate.
        for (p = [asm_pivot, asm_latch])
            translate([p[0], base_t - eps, p[1]]) rotate([-90, 0, 0])
                difference() {
                    cylinder(d = asm_pillar_d, h = y_gear_face - cart_t - 0.5 - base_t, $fn = 32);
                    translate([0, 0, -1]) cylinder(d = asm_pin_d, h = 100, $fn = 16);
                }
    }
}

// P2 motor cartridge: face plate on the gearbox's six M3 holes, swinging on the
// pivot pin, held by the latch pin. Reaction torque goes through both pins.
module cartridge() {
    color(cart_color) translate([0, y_gear_face, 0]) rotate([90, 0, 0])
        difference() {
            linear_extrude(cart_t) hull() {
                translate(mtr_axis) circle(r = cart_r, $fn = 48);
                for (p = [asm_pivot, asm_latch]) translate(p) circle(d = asm_pillar_d + 2, $fn = 24);
                for (x = [-1, 1] * (keeper_r + keeper_t)) translate([x, cart_bottom_z + 3]) circle(r = 3, $fn = 16);
            }
            translate([0, 0, -1]) cylinder(d = mtr_boss_d + 1, h = cart_t + 2, $fn = 32);
            for (i = [0 : 5]) translate(mtr_axis) rotate([0, 0, 30 + i * 60])
                translate([mtr_hole_r, 0, -1]) cylinder(d = screw_d + screw_hole_clear, h = cart_t + 2, $fn = 12);
            for (p = [asm_pivot, asm_latch])
                translate([p[0], p[1], -1]) cylinder(d = asm_pin_d + 0.6, h = cart_t + 2, $fn = 16);
        }
    // Pins: pivot and latch, PLACEHOLDER mechanism.
    color(placeholder_color) for (p = [asm_pivot, asm_latch])
        translate([p[0], base_t, p[1]]) rotate([-90, 0, 0])
            cylinder(d = asm_pin_d, h = y_gear_face + 3 - base_t, $fn = 16);
}

// P4 keeper: a band under the wrapped chain, carried on arms from the cartridge
// so it swings with the sprocket.
module keeper() {
    w = 2 * spr_hw;
    color(keeper_color) {
        translate([0, y_spr + w / 2, 0]) rotate([90, 0, 0])
            linear_extrude(w) difference() {
                circle(r = keeper_r + keeper_t, $fn = 64);
                circle(r = keeper_r, $fn = 64);
                translate([-50, 0]) square([100, 50]);
            }
        for (s = [-1, 1])
            translate([s * (keeper_r + keeper_t / 2) - keeper_t / 2, y_spr - w / 2, cart_bottom_z + 1])
                cube([keeper_t, y_gear_face - cart_t - y_spr + w / 2 + eps, -cart_bottom_z - 1]);
    }
}

// P5 outboard yoke, optional: from the cartridge plate over the top of the
// sprocket, between the strands, down the wall side to the 625ZZ. It has to come
// off to load an intact loop over the sprocket's free end.
module yoke() {
    color(yoke_color) difference() {
        union() {
            translate([-yoke_w / 2, y_leg0, yoke_z0]) cube([yoke_w, y_gear_face - cart_t - y_leg0 + eps, yoke_t]);
            translate([-yoke_w / 2, y_leg0, -brg_od / 2 - 3]) cube([yoke_w, brg_leg_t, yoke_z0 + yoke_t + brg_od / 2 + 3]);
        }
        translate([0, y_leg1 + eps, 0]) rotate([90, 0, 0]) cylinder(d = brg_od + 0.2, h = brg_w + 1, $fn = 48);
        translate([0, y_leg1 + 1, 0]) rotate([90, 0, 0]) cylinder(d = brg_od - 3, h = 20, $fn = 32);
    }
}

// P7 electronics carrier: an L-bracket off the wall base, board on standoffs.
module carrier() {
    y1 = ele_board_y0 + ele_board[1] + 2;
    x0 = cov_in_x0 + cov_clear; w = cov_in_x1 - cov_in_x0 - 2 * cov_clear;
    color(carrier_color) {
        difference() {
            translate([x0, base_t, ele_floor_z - 2]) cube([w, y1 - base_t, 2]);
            translate([jack_xy[0], jack_xy[1], ele_floor_z - 3]) cylinder(d = jack_body[0] + 1, h = 4, $fn = 32);
        }
        translate([x0, base_t, ele_floor_z - 2]) cube([w, 3, 12]);
        for (x = [-1, 1] * (ele_board[0] / 2 - 2.5), y = [3, ele_board[1] - 3])
            translate([ele_board_x + x, ele_board_y0 + y, ele_floor_z - eps])
                cylinder(d = 5, h = ele_board_top - ele_board[2] - ele_floor_z + eps, $fn = 16);
    }
}

// P8 cover: open-backed shell pushed on toward the wall. Notches open to its back
// edge let it pass the strands; the buttons sit on the front face, the jack on
// the bottom, and a slot on the -X side reaches the XIAO's USB-C.
module cover() {
    x0 = cov_in_x0 - cov_wall; z0 = cov_in_z0 - cov_wall;
    y_usb = ele_board_y0 + 2 + xiao[1] / 2;
    z_usb = ele_board_top + ele_socket_h + 1.6;
    color(cover_color) difference() {
        translate([x0, 0, z0]) rounded_box(cov_box, cov_r);
        translate([cov_in_x0, -1, cov_in_z0]) cube([cov_in_x1 - cov_in_x0, cov_in_y1 + 1, cov_in_z1 - cov_in_z0]);
        for (s = [-1, 1])
            translate([s * spr_pitch_r - cov_slot_w / 2, -1, cov_in_z1 - 1])
                cube([cov_slot_w, y_spr + cov_slot_w / 2 + 1, cov_wall + 2]);
        for (i = [-1 : 1])
            translate([i * btn_pitch, cov_in_y1 - 1, btn_z]) rotate([-90, 0, 0])
                cylinder(d = btn_d, h = cov_wall + 2, $fn = 32);
        translate([jack_xy[0], jack_xy[1], z0 - 1]) cylinder(d = jack_hole_d, h = cov_wall + 2, $fn = 32);
        translate([x0 - 1, y_usb - 6, z_usb - 2]) cube([cov_wall + 2, 12, 7]);
        // Vents on the +X side beside the motor can.
        for (k = [0 : 4])
            translate([cov_in_x1 - 1, y_gear_face + mtr_gear_l + 4 + k * 5, mtr_axis[1] - 8])
                cube([cov_wall + 2, 2.5, 16]);
    }
}

module controls() {
    for (i = [-1 : 1]) translate([i * btn_pitch, cov_in_y1 + cov_wall, btn_z]) button();
    color(bought_color) translate([jack_xy[0], jack_xy[1], cov_in_z0 - cov_wall])
        cylinder(d = jack_body[0], h = jack_body[1] + cov_wall, $fn = 32);
    color(placeholder_color)
        translate([cov_in_x0, ele_board_y0 + ele_board[1] - ant_keepout[1], cov_in_z1 - ant_keepout[2]])
            cube(ant_keepout);
}

module wall() {
    color(wall_color) translate([cov_in_x0 - 40, -10, cov_in_z0 - 40])
        cube([cov_in_x1 - cov_in_x0 + 80, 10, cov_in_z1 - cov_in_z0 + 80 + asm_strand_beads * chain_pitch]);
}

// Everything the cartridge carries; it moves together on release.
module swinging() {
    wheel_to_asm() spr_assembled();
    translate([0, y_hub_face, 0]) hub_1999();
    translate([0, y_gear_face, 0]) motor_37d();
    cartridge();
    keeper();
    if (brg_show) {
        yoke();
        translate([0, y_leg1 - (brg_leg_t - brg_w) / 2, 0]) bearing_625();
    }
}

module released() {
    translate([asm_pivot[0], 0, asm_pivot[1]]) rotate([0, -asm_release_deg, 0])
        translate([-asm_pivot[0], 0, -asm_pivot[1]]) children();
}

module fixed_parts() {
    base_plate();
    carrier();
    translate([ele_board_x, ele_board_y0, ele_board_top]) electronics();
}

module assembly(cover_on, release = false) {
    if (asm_show_wall) wall();
    fixed_parts();
    if (release) released() swinging(); else swinging();
    if (!release) chain_placeholder();
    if (cover_on) { cover(); controls(); }
}

if (show == "print-set") print_set();
else if (show == "half-a") spr_half_colored(spr_pocket_clear, "a");
else if (show == "half-b") spr_half_colored(spr_pocket_clear, "b");
else if (show == "pocket-coupon") pocket_coupon();
else if (show == "section")
    // Horizontal cut through the axis, keeping the lower half with the wrapped chain.
    difference() {
        union() { wheel_to_asm() spr_assembled(); chain_placeholder();
                  translate([0, y_hub_face, 0]) hub_1999(); }
        translate([-100, -100, 0]) cube([200, 300, 200]);
    }
else if (show == "assembly") assembly(true);
else if (show == "assembly-open") assembly(false);
else if (show == "release") assembly(false, true);
