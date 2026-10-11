// shelf-wire-clip.scad
//
// Taped-on clips that hold a 3.5 mm round wire up the side of a shelf whose
// edge is 21 mm wide (Ziad, 2026-10-11). Each clip is a flat base, taped to
// the shelf, with a snap channel standing on it: stick the clips down
// first, then press the wire into them.
//
// THE CHANNEL IS A SNAP. The bore is a little bigger than the wire and its
// mouth a little smaller, so the lips spread as the wire goes in and close
// behind it. The lead-in chamfer at the mouth is what lets a thumb do it.
// If the wire goes in too hard, open snap_open; if it falls out, close it.
//
// THE CLIP PRINTS STANDING ON ITS END. Lying on its base, the lips would
// flex across the layer lines and split there. On end, the whole section is
// one 2D profile extruded up, each lip bends inside its own layers, and
// nothing overhangs. The base's back is a vertical wall in that pose, so it
// comes out smooth for the tape.
//
// The base is clip_w wide, centred in shelf_w with a margin either side so
// it does not hang over the edge if placed a little off. Walls are on the
// slicing reference's ladder: 1.29 is three loops, 1.74 is four.
//
// Drawn as mounted: base on z = 0, wire along Y, channel opening up (+Z).

/* [Output] */
// set  — count clips standing on end, the way they print
// clip — one clip, as mounted
show = "set";  // [set, clip]

// Clips on the plate.
count = 8;

/* [Shelf] */
// Width of the shelf face the clip sits on, mm.
shelf_w = 21;

/* [Wire] */
// Wire diameter, mm.
wire_d = 3.5;
// Bore over the wire, diametral, mm.
bore_clear = 0.3;
// Width of the channel's mouth, mm. Below wire_d so the wire snaps in.
snap_open = 3.0;
// Lead-in chamfer at the mouth, per side, mm.
lead_in = 0.8;

/* [Clip] */
// Base width across the shelf face, mm.
clip_w = 18;
// Length along the wire, mm. Also the print height.
clip_len = 15;
// Base thickness, mm (four loops).
base_t = 1.74;
// Wall around the bore, mm (three loops).
lip_wall = 1.29;
// Fillet where the channel meets the base, mm.
fillet_r = 1.2;
// Round on outside edges, mm.
edge_r = 0.5;

/* [Plate] */
// Gap between clips on the plate, mm.
plate_gap = 4;
// Clips per row on the plate.
plate_cols = 4;

/* [Colors] */
clip_color = "SlateGray";

/* [Hidden] */
$fn = 96;
eps = 0.01;

bore_d = wire_d + bore_clear;
bore_z = base_t + bore_d / 2;            // bore centre above the base's back
boss_r = bore_d / 2 + lip_wall;
// Height where the boss circle is as wide as the mouth: top of the lips.
lip_top = bore_z + sqrt(boss_r * boss_r - (snap_open / 2 + lead_in) * (snap_open / 2 + lead_in));
clip_h = bore_z + boss_r;

assert(clip_w <= shelf_w, "clip_w is wider than the shelf");
assert(snap_open < wire_d, "snap_open must be under wire_d or nothing holds the wire");

// Section across the wire: x across the shelf, y out from the shelf.
module clip_profile() {
  difference() {
    // Round convex edges, then fill the concave corners at the boss.
    offset(r = edge_r) offset(delta = -edge_r)
      offset(r = -fillet_r) offset(delta = fillet_r)
        union() {
          translate([-clip_w / 2, 0]) square([clip_w, base_t]);
          translate([0, bore_z]) circle(r = boss_r);
        }
    // Bore, sized on its flats so the inscribed polygon still clears.
    translate([0, bore_z]) circle(d = bore_d / cos(180 / $fn));
    // Mouth, straight up out of the bore.
    translate([-snap_open / 2, bore_z]) square([snap_open, boss_r + eps]);
    // Lead-in chamfer at the mouth.
    polygon([
      [-snap_open / 2, lip_top - lead_in],
      [snap_open / 2, lip_top - lead_in],
      [snap_open / 2 + lead_in + 2 * eps, lip_top + eps],
      [snap_open / 2 + lead_in + 2 * eps, clip_h + eps],
      [-snap_open / 2 - lead_in - 2 * eps, clip_h + eps],
      [-snap_open / 2 - lead_in - 2 * eps, lip_top + eps],
    ]);
  }
}

// As mounted: base on z = 0, wire along Y.
module shelf_wire_clip() {
  color(clip_color)
    rotate([90, 0, 0])
      translate([0, 0, -clip_len / 2])
        linear_extrude(height = clip_len, convexity = 4) clip_profile();
}

// Standing on end, the section in XY and the wire along Z.
module clip_on_end() {
  color(clip_color)
    linear_extrude(height = clip_len, convexity = 4) clip_profile();
}

module print_set() {
  pitch_x = clip_w + plate_gap;
  pitch_y = clip_h + plate_gap;
  rows = ceil(count / plate_cols);
  for (i = [0 : count - 1])
    translate([
      (i % plate_cols - (plate_cols - 1) / 2) * pitch_x,
      (floor(i / plate_cols) - (rows - 1) / 2) * pitch_y,
      0,
    ])
      clip_on_end();
}

if (show == "clip") shelf_wire_clip();
else print_set();
