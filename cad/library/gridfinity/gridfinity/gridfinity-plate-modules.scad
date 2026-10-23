// Note 1.

include <gridfinity_modules.scad>
include <gridfinity-magnets.scad>

// Note 2.

module plate_blocks(blocks, floor_ht = 3.0, magnet_hole_d = 10.5,
                    magnet_cav_h = 2.2, magnet_skin = 0.4) {
  ht = 5;                                            // Note 3.
  corner_radius = 3.75;                              // Note 4.

  difference() {
    translate([0, 0, -floor_ht])
    linear_extrude(height = ht + floor_ht, convexity = 10)
    plate_outline_2d(blocks, corner_radius);

    // Note 5.

    render()
    for (b = blocks)
      translate([b[0] * gridfinity_pitch, b[1] * gridfinity_pitch, 0])
      gridcopy(b[2], b[3]) pad_oversize(margins = 1);

    if (magnet_hole_d > 0) {
      assert(floor_ht >= magnet_cav_h + 2 * magnet_skin,
             "the floor is too thin to bury a magnet in — skin + cavity + skin");
      for (b = blocks)
        translate([b[0] * gridfinity_pitch, b[1] * gridfinity_pitch, 0])
        magnet_cavities(b[2], b[3], magnet_hole_d, magnet_cav_h,
                        -magnet_skin - magnet_cav_h);
    }
  }
}

// Note 6.

module plate_outline_2d(blocks, corner_radius = 3.75) {
  offset(r = corner_radius) offset(r = -corner_radius)
  union() {
    for (b = blocks)
      translate([(b[0] - 0.5) * gridfinity_pitch, (b[1] - 0.5) * gridfinity_pitch])
      square([b[2] * gridfinity_pitch, b[3] * gridfinity_pitch]);
  }
}

// Notes

// Note 1. gridfinity-plate-modules.scad — Feral's, not upstream.
//
// A gridfinity baseplate whose footprint is an arbitrary set of rectangular
// cell blocks, standing on a flat floor so it can be stuck down with adhesive
// strips. The vendored gridfinity_baseplate.scad covers the single-rectangle
// case; this covers L-shapes, doglegs, and anything else that is a union of
// whole-cell rectangles.
//
// The outline is built in 2D and opened (erode then dilate) rather than hulled
// from corner cylinders the way the vendored frame is. A hull cannot describe a
// non-convex footprint, and unioning two hulled blocks leaves a 3.75 mm notch
// pinched into the outside wall wherever their rounded corners meet. Opening
// the 2D union rounds the convex corners to the same 3.75 mm the vendored plate
// uses and leaves the inside corner of an L sharp.

// Note 2. MAGNETS are fully enclosed cavities for the print-pause workflow, not
// pockets open on a face — see gridfinity-magnets.scad. On a tray the cavity
// sits one skin BELOW the socket floor, so the discs go in with the print all
// but finished and the last two layers close over them, and the underside the
// adhesive strips stick to is never broken at all.
//
// The floor is therefore exactly skin + cavity + skin thick, which is also what
// puts the cavity at the same height above the build plate as a bin's — one
// pause serves every part in the set.
//
// blocks: list of [first_x, first_y, num_x, num_y], whole cells, zero-indexed.
// Blocks may touch or overlap; the union is what gets built.
// floor_ht: mm of flat sheet under the frame. 0 leaves the sockets open, which
// is the stock gridfinity baseplate.
// magnet_hole_d: cavity diameter, 0 for no magnets.
// magnet_cav_h: cavity height — the disc plus a little.
// magnet_skin: mm of plastic above the cavity, and below it. floor_ht must be
// at least the three added together.

// Note 3. frame height, gridfinity standard

// Note 4. matches the vendored baseplate

// Note 5. The sockets stop at z=0, so the underside stays one unbroken sheet. The
// vendored frame drops this negative by 0.01 to guarantee break-through,
// which is exactly what a floor must not do.

// Note 6. The footprint. Each block is its exact cell rectangle — a cell spans half a
// pitch either side of its center — and the opening rounds only what ends up
// convex once they are unioned.
