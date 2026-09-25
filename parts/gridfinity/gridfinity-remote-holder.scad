// gridfinity-remote-holder.scad — a gridfinity bin with one vertical slot per
// remote, plus two rounded hexagonal iron pockets and a round Blistex pocket.
//
// Slot sizes are Ziad's caliper readings (2026-09-22), width x thickness:
//   1, 2   40 x 7    rounded rectangles
//   3      40 x 14   oval
//   4      49 x 25   flat front, round back
//
// ⚠️ Remote 4's bottom face is cut on a slope — 121 mm tall at the front, 134
// at the back — so its slot floor is sloped to match and the remote stands
// square rather than teetering on its back edge. 13 mm of drop across 25 mm of
// depth is 27.5 degrees, not the 20 that was estimated by eye. The two heights
// are the more specific measurement so they win, but they are what to re-check
// if remote 4 sits crooked: `slot_slope` is the only number involved.
//
// Fronts all face -Y, which is the flat side of remote 4's D. Slots run
// thinnest at the front to thickest at the back, matching the order they were
// traced in, which also puts the heaviest remote over the back of the plate.
//
// show = "coupon" is a flat gauge of all seven openings, cut through a
// sheet a few layers thick, for trying the remotes against before committing
// to the full print. It tests the two in-plane dimensions and the spacing, and
// nothing else: a remote that passes a 1.2 mm sheet can still bind in a 38 mm
// pocket, because the walls have that much further to bulge inwards.

include <gridfinity_modules.scad>
include <gridfinity-magnets.scad>
include <../../lib/BOSL2/std.scad>

/* [Remotes] */
// One row per remote, front to back: [width, thickness, profile, [extra_w,
// extra_t]]. Width runs across the slot (X), thickness front to back (Y), both
// in mm as measured on the remote itself. slot_clearance is added to every
// slot; the extra pair is added on top of it, per slot and per axis.
//
// The extras are all from Ziad offering the remotes up to the printed coupon
// (2026-09-22): everything wanted a couple more mm across, the AC wanted it
// left and right only, and the two at the front carry velcro on their backs,
// which is what the extra millimetre beyond the asked-for couple is for — it
// was 2 until Ziad tried the 12 mm opening and took 1 mm back out.
remotes = [
  [40,  7, "rect", [2, 3]],   // 1 — slim, velcro on the back
  [40,  7, "rect", [2, 3]],   // 2 — same
  [40, 14, "oval", [2, 2]],   // 3 — oval
  [49, 25, "dee",  [2, 0]],   // 4 — AC, snug across only
];

// How much lower the back of remote 4's bottom face sits than the front, mm.
// 134 - 121. Zero makes the floor flat.
slot_slope = 13;
slot_x = -12.037445;    // mm, AC and iron outside clearances match, with 1 mm extra padding

/* [Soldering irons] */
// Inner contour sectioned from soldering-iron-stand.stl at source Z=150,
// scaled to 10% as confirmed by Ziad, with its original flat face toward -Y.
// Opening: 22.07644 mm across X, 19.69 mm in Y; original corner rounds retained.
// Source bore center [280,270] versus hex center approximately [280,280]
// puts the small bottom recess 1 mm toward that front flat face.
iron_count = 2;         // [1, 2]
iron_x = 27;            // mm, 3.712 mm to the outside wall
iron_y = [0, 26];       // mm, middle and rear; front position is now Blistex
iron_tip_d = 9;         // mm, minimum recess diameter across polygon flats
iron_tip_depth = 5;     // mm below each hexagonal pocket floor
iron_tip_offset = [0, -1]; // mm, forward of the hexagon center
iron_tip_facets = 64;
entry_r = 0.75;         // mm, roundover at every opening, including the tip recesses
entry_steps = 12;  // quarter-circle segments in the entry roundover
iron_profile = [
  [-10.752600, -1.065940], [-10.838480, -0.900970], [-10.905550, -0.739060],
  [-10.909650, -0.729150], [-10.965580, -0.551770], [-11.005840, -0.370200],
  [-11.030110, -0.185810], [-11.038220, -0.000000], [-11.030110, 0.185810],
  [-11.005840, 0.370200], [-10.965580, 0.551770], [-10.909650, 0.729150],
  [-10.842590, 0.891060], [-10.838480, 0.900970], [-10.752600, 1.065940],
  [-6.299440, 8.779060], [-6.199510, 8.935910], [-6.086290, 9.083470],
  [-5.960640, 9.220580], [-5.823520, 9.346230], [-5.675970, 9.459450],
  [-5.519110, 9.559380], [-5.354140, 9.645260], [-5.344230, 9.649370],
  [-5.182320, 9.716430], [-5.004940, 9.772360], [-4.823370, 9.812610],
  [-4.638970, 9.836890], [-4.453170, 9.845000], [4.453170, 9.845000],
  [4.638970, 9.836890], [4.823370, 9.812610], [5.004940, 9.772360],
  [5.182320, 9.716430], [5.189550, 9.713440], [5.354140, 9.645260],
  [5.519110, 9.559380], [5.675970, 9.459450], [5.684820, 9.452660],
  [5.823520, 9.346230], [5.960640, 9.220580], [6.086290, 9.083470],
  [6.093060, 9.074650], [6.199510, 8.935910], [6.299440, 8.779060],
  [10.752600, 1.065940], [10.838480, 0.900970], [10.909660, 0.729150],
  [10.965580, 0.551770], [11.003510, 0.380680], [11.005830, 0.370200],
  [11.030110, 0.185810], [11.038220, -0.000000], [11.030110, -0.185810],
  [11.005830, -0.370200], [10.965580, -0.551770], [10.909660, -0.729150],
  [10.838480, -0.900970], [10.752600, -1.065940], [6.299440, -8.779060],
  [6.199510, -8.935910], [6.086290, -9.083460], [5.960640, -9.220580],
  [5.823520, -9.346230], [5.675970, -9.459450], [5.519110, -9.559380],
  [5.354140, -9.645260], [5.182320, -9.716430], [5.004940, -9.772360],
  [4.823370, -9.812610], [4.638970, -9.836890], [4.453170, -9.845000],
  [-4.453170, -9.845000], [-4.638970, -9.836890], [-4.823370, -9.812610],
  [-5.004940, -9.772360], [-5.182320, -9.716430], [-5.233870, -9.695080],
  [-5.354140, -9.645260], [-5.519110, -9.559380], [-5.675970, -9.459450],
  [-5.823520, -9.346230], [-5.960640, -9.220580], [-6.086290, -9.083460],
  [-6.199510, -8.935910], [-6.299440, -8.779060]
];

/* [Blistex] */
blistex_d = 16;         // mm, measured tube OD; slot_clearance is added for drop-in fit
blistex_depth = 30;     // mm below the recessed deck, with a flat floor
blistex_pos = [27, -26]; // mm, aligned with the iron column
blistex_facets = 64;

/* [Output] */
show = "holder";        // [holder, coupon]
coupon_thickness = 1.2; // mm, 6 layers at 0.2 — every layer is solid,
                        // so this is most of the print time

/* [Bin] */
cells_x = 2;            // gridfinity cells across
cells_y = 2;            // gridfinity cells deep
units_z = 6;            // height in 7 mm units; 6 is 45.75 mm overall

/* [Fit] */
slot_clearance = 1.0;   // mm added to every width and thickness, 0.5 a side, on
                        // top of each remote's own extras above. Generous
                        // on purpose: these get dropped in one-handed, and a
                        // pocket on this machine comes out ~0.6 undersize
                        // anyway (see the bore note in the printer reference).
wall = 2.1;             // mm of outer wall around the slot array — 5 lines at 0.42

/* [Magnets] */
magnet_hole_d = 10.5;   // mm cavity for a 10 mm disc, four per cell in the base
                        // pads. 0 for no magnets.
magnet_cav_h = 2.2;     // mm tall: a 2 mm disc and 0.2 to drop it in
magnet_skin = 0.4;      // mm of plastic under the cavity — 2 layers at 0.2.
                        // grid_block's own magnet option is NOT used: it opens
                        // its pockets on the underside, for gluing in from
                        // below. These are closed cavities the discs drop into
                        // at a pause, and they sit at the same height above the
                        // plate as the trays' do, so one pause does both.
floor_thickness = 2.0;  // mm of solid above the base pads
slot_corner_r = 2.0;    // mm, corner radius on the rectangular slots
dee_setback = 2.0;      // mm the front corners of remote 4's slot pull back,
                        // measured at the ends; the middle of the front stays put
dee_corner_r = 4.0;     // mm, round on the junction between that front and the sides

$fn = 64;
eps = 0.01;

/* [Derived] */
pad_top = 5;            // the gridfinity pad profile occupies the bottom 5 mm
floor_z = pad_top + floor_thickness;
// Preserve the existing solid floor above the pads under every tip recess,
// including the middle one over the seam between pads. Only the hexagon
// floors rise; each tip recess bottoms at the same Z=7 as the remote slots.
iron_floor_z = floor_z + iron_tip_depth;
block_h = gridfinity_zpitch * units_z + 3.75;
deck_z = gridfinity_zpitch * units_z; // recessed top face below the stacking rim
blistex_hole_d = blistex_d + slot_clearance;
blistex_floor_z = deck_z - blistex_depth;
inner_y = gridfinity_pitch * cells_y - gridfinity_clearance - 2 * wall;

function tsum(v, n, i = 0) = i < n ? v[i] + tsum(v, n, i + 1) : 0;

slot_t = [for (r = remotes) r[1] + slot_clearance + r[3][1]];
slot_w = [for (r = remotes) r[0] + slot_clearance + r[3][0]];

// The leftover after the slots is split evenly into the gaps between them AND
// the two end margins, so the array sits centred and no divider ends up as a
// 7 mm slab of plastic.
gap = (inner_y - tsum(slot_t, len(slot_t))) / (len(remotes) + 1);

// Centre of each slot in Y, front to back.
slot_y = [for (i = [0:len(remotes) - 1])
  -inner_y / 2 + gap * (i + 1) + tsum(slot_t, i) + slot_t[i] / 2];

if (show == "coupon") {
  slot_coupon();
}
else {
  remote_holder();
}

module remote_holder() {
  assert(gap > 0, "the slots do not fit — more cells in Y, or less clearance");
  assert(iron_count >= 1 && iron_count <= len(iron_y), "choose one or two iron pockets");
  assert(blistex_floor_z >= floor_z, "Blistex pocket is too deep for the base floor");

  difference() {
    grid_block(cells_x, cells_y, units_z,
               magnet_diameter = 0, screw_depth = 0, center = true);

    if (magnet_hole_d > 0)
      magnet_cavities(cells_x, cells_y, magnet_hole_d, magnet_cav_h,
                      magnet_skin, center = true);

    for (i = [0:len(remotes) - 1])
      translate([slot_x, slot_y[i], 0])
      slot(slot_w[i], slot_t[i], remotes[i][2],
           remotes[i][2] == "dee" ? slot_slope : 0, remotes[i][1]);

    for (i = [0:iron_count - 1])
      translate([iron_x, iron_y[i], iron_floor_z])
      offset_sweep(ccw_polygon(iron_profile), height = deck_z - iron_floor_z,
                   top = os_circle(r = -entry_r,
                                   extra = block_h - deck_z + eps),
                   steps = entry_steps, check_valid = false);

    for (i = [0:iron_count - 1])
      translate([iron_x + iron_tip_offset[0], iron_y[i] + iron_tip_offset[1],
                 iron_floor_z - iron_tip_depth])
      offset_sweep(circle(d = iron_tip_d / cos(180 / iron_tip_facets),
                          $fn = iron_tip_facets), height = iron_tip_depth,
                   top = os_circle(r = -entry_r, extra = eps),
                   steps = entry_steps, check_valid = false);

    translate([blistex_pos[0], blistex_pos[1], blistex_floor_z])
    offset_sweep(circle(d = blistex_hole_d / cos(180 / blistex_facets),
                        $fn = blistex_facets), height = blistex_depth,
                 top = os_circle(r = -entry_r,
                                 extra = block_h - deck_z + eps),
                 steps = entry_steps, check_valid = false);
  }
}

module iron_profiles() {
  for (i = [0:iron_count - 1])
    translate([iron_x, iron_y[i]])
    polygon(iron_profile);
}

// One pocket, from the floor up through the top of the block. drop is how much
// deeper the back of the floor sits than the front, and raw_t is the remote's
// own thickness — the slope belongs to the remote, not to the clearance.
module slot(w, t, shape, drop, raw_t) {
  if (drop > 0) {
    intersection() {
      slot_prism(w, t, shape);
      above_slope(t, drop, raw_t);
    }
  }
  else {
    slot_prism(w, t, shape);
  }
}

module slot_prism(w, t, shape) {
  translate([0, 0, floor_z])
  linear_extrude(height = block_h - floor_z + eps, convexity = 10)
  slot_profile(w, t, shape);

  rounded_entry(deck_z, block_h + eps)
  slot_profile(w, t, shape);
}

// A circular flare around an existing convex 2D profile. Using the original
// child preserves even the AC slot's custom arc and corner geometry below
// the roundover. Adjacent slices are hulled into a continuous swept cutter.
module rounded_entry(surface_z, end_z) {
  for (j = [0:entry_steps - 1])
    hull() {
      for (k = [j, j + 1])
        let(a = 90 * k / entry_steps)
        translate([0, 0, surface_z - entry_r + entry_r * sin(a)])
        linear_extrude(height = eps, convexity = 10)
        offset(r = entry_r * (1 - cos(a))) children();
    }
  translate([0, 0, surface_z])
  linear_extrude(height = end_z - surface_z, convexity = 10)
  offset(r = entry_r) children();
}

// Everything above the plane hinged on the back-bottom edge of the pocket and
// rising towards the front. A rotated half-space rather than a wedge built to
// the pocket's shape: the pocket is what bounds it, so the plane only has to be
// bigger than the part.
module above_slope(t, drop, raw_t) {
  big = 400;
  translate([0, t / 2, floor_z])
  rotate([-atan(drop / raw_t), 0, 0])
  translate([-big / 2, -big, 0])
  cube([big, big + 1, big]);
}

// A flat sheet with the same seven openings, for offering the tools up to.
module slot_coupon() {
  linear_extrude(height = coupon_thickness, convexity = 10)
  difference() {
    coupon_outline();
    for (i = [0:len(remotes) - 1])
      translate([slot_x, slot_y[i]])
      slot_profile(slot_w[i], slot_t[i], remotes[i][2]);
    iron_profiles();
    translate(blistex_pos)
    circle(d = blistex_hole_d / cos(180 / blistex_facets), $fn = blistex_facets);
  }
}

// The bin's own footprint, so the coupon also tests the full opening layout.
module coupon_outline() {
  r = 3.75;
  offset(r = r)
  square([gridfinity_pitch * cells_x - gridfinity_clearance - 2 * r,
          gridfinity_pitch * cells_y - gridfinity_clearance - 2 * r], center = true);
}

// Every profile is centred on the origin and spans t in Y, so the front face is
// always at -t/2 whatever the shape.
module slot_profile(w, t, shape) {
  if (shape == "rect") {
    offset(r = slot_corner_r)
    square([w - 2 * slot_corner_r, t - 2 * slot_corner_r], center = true);
  }
  else if (shape == "oval") {
    resize([w, t]) circle(d = 10);
  }
  else if (shape == "dee") {
    // The back half of an ellipse twice as deep as the slot, cut off at the
    // front by a very shallow arc instead of a straight line: it touches the
    // old flat front at the middle and has pulled back dee_setback by the
    // ends. The arc's radius comes from chord and sagitta — 50 mm across and
    // 2 mm deep wants a 157 mm circle.
    //
    // The opening (erode, then dilate) is what rounds the two junctions where
    // that arc runs into the sides. It only bites where the boundary turns
    // tighter than dee_corner_r, so the ellipse itself comes through it
    // unchanged. resize afterwards because both steps cost a few tenths of
    // width, and the slot has to end up the size it says it is.
    r_front = (w * w / 4 + dee_setback * dee_setback) / (2 * dee_setback);
    translate([0, -t / 2])
    resize([w, t])
    offset(r = dee_corner_r) offset(r = -dee_corner_r)
    intersection() {
      resize([w, 2 * t]) circle(d = 10, $fn = 128);
      translate([0, r_front]) circle(r = r_front, $fn = 256);
    }
  }
  else {
    assert(false, str("unknown slot profile: ", shape));
  }
}
