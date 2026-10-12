// gridfinity-magnets.scad — Feral's, not upstream.
//
// Fully enclosed magnet cavities, for the print-pause workflow: the printer
// lays a couple of layers, builds the cavity walls, stops at the top of them
// for the discs to be dropped in by hand, then bridges over and buries them.
// No glue, no open hole on any face, nothing to fall out later.
//
// This is NOT what the vendored modules do. `grid_block(magnet_diameter=…)`
// opens its pockets on the underside of the bin, which only works if you glue
// the magnets in from below afterwards. Pass 0 there and use these instead.
//
// ONE PAUSE HEIGHT FOR EVERY PART IN THE SET, by construction. A bin's cavity
// sits `skin` above its own bottom face; a tray's sits `skin` below its socket
// floor, and its floor is exactly skin + cavity + skin thick. Both therefore
// run from z = skin to z = skin + cavity measured off the build plate, so one
// pause serves the whole set — see magnet_pause_z().
//
// ⚠️ The cavity ceiling is a bridge over the full bore. On a tray that bridged
// skin is the socket floor, which is what the bins land on, and it is two
// layers over a 10.5 mm hole. The magnet underneath is holding it up.

include <gridfinity_modules.scad>

// Where a cavity sits in its cell. Lifted verbatim from gridfinity_modules.scad
// so the bins and the trays agree to the millimetre: they have to, or the
// magnets end up beside each other instead of on top of each other.
function magnet_cell_pos(bore) =
  min(gridfinity_pitch / 2 - 8, gridfinity_pitch / 2 - 4 - bore / 2);

// The height to pause at, measured from the build plate — the top of the
// cavities, where the discs go in.
function magnet_pause_z(skin, cav_h) = skin + cav_h;

// Four cavities per cell, bottoms at z0. Put it inside a difference().
// center matches grid_block's own flag: true puts the middle of the grid on
// the origin rather than the middle of cell (0,0).
module magnet_cavities(num_x, num_y, bore, cav_h, z0, center = false) {
  translate(center ? [-(num_x - 1) * gridfinity_pitch / 2,
                      -(num_y - 1) * gridfinity_pitch / 2, 0]
                   : [0, 0, 0])
  gridcopy(num_x, num_y)
  cornercopy(magnet_cell_pos(bore))
  translate([0, 0, z0])
  cylinder(d = bore, h = cav_h, $fn = 64);
}
