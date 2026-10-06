# Fabric-cube placard for a 6 x 4 inch label

A rounded plate for a 4 x 6 inch adhesive label, attached to a fabric storage cube with pop rivets. A shallow front recess accepts the label in landscape orientation. Sized to the user's stated 4 x 6 inch UPS label, number 0177400603; [UPS documents the 4 x 6 inch thermal-label format](https://www.campusship.ups.com/us/en/support/shipping-support/print-shipping-labels/thermal-printing-of-labels).

| Dimension | Default |
| --- | --- |
| Overall plate | 175 x 135 x 2.4 mm |
| Label area | 152.4 x 101.6 mm (6 x 4 inches) |
| Recess opening | 153.4 x 102.6 mm, square corners |
| Clearance around label | 0.5 mm per side |
| Recess depth | 0.6 mm |
| Floor beneath label | 1.8 mm |
| Corner radius | 5 mm |
| Rivets | Six, three above and three below the label |
| Hole diameter across flats | 3.3 mm, for nominal 1/8 inch (3.2 mm) rivets |
| Hole centres | X = -79.5, 0, 79.5 mm; Y = -59.5, 59.5 mm |
| Reserved head or washer diameter | 12 mm |

Coordinates are measured from the plate centre. A 12 mm head or washer remains 2.7 mm clear of the label and 2.2 mm clear of the recess. The STL contains the plate, recess, and holes; `show="label-layout"` adds a preview-only guide at the recess floor.

Print flat with the back on the bed and label face up. This orientation needs no supports. The default holes assume 1/8 inch rivets; check an actual rivet in a hole before fastening the plate. Printed hole fit and the fabric attachment have not been physically tested.

Use metal backing washers on the inside of the cube to spread the load on the fabric. Choose a rivet grip range that covers the 2.4 mm plate, fabric, and any washers. Keep the cube fabric accessible from both sides while riveting, and keep the rivet head clear of the label. Rivet grip and hole sizing guidance: [POP rivet catalogue](https://www.stanleyengineeredfastening.com/-/media/Web/SEF/Resources/Docs/POP/POP-Rivet-Catalog.pdf).

## Outputs and variants

Default printable mesh: `stl/fabric-cube-placard-6x4.stl`. Source: `parts/fabric-cube-placard-6x4.scad`.

```sh
utils/build.sh parts/fabric-cube-placard-6x4.scad
utils/build.sh parts/fabric-cube-placard-6x4.scad -D 'rivet_count=4' --name fabric-cube-placard-6x4-four-rivets
utils/build.sh parts/fabric-cube-placard-6x4.scad -D 'rivet_d=4' --name fabric-cube-placard-6x4-4mm-rivets
utils/render.sh parts/fabric-cube-placard-6x4.scad -D 'show="label-layout"'
```

The four-rivet variant omits the two centre holes. The 4 mm rivet variant has 4.1 mm holes. Each named variant needs its own render inspection and mesh checks before use.

## Verification

Revision v02 adds the recess. The default geometry was inspected in all seven standard views, both plain and with the label guide. The binary STL measures 175 x 135 x 2.4 mm: one connected shell, six through-holes (genus 6), no collapsed triangles, and no edge-incidence or winding errors. Its recess opening measures 153.4 x 102.6 mm and its floor is at Z = 1.8 mm. Continuous axial insertion envelopes for the 152.4 x 101.6 mm label down to the floor (with a 0.0001 mm numerical gap) and conservative 3.2 mm rivet shafts have an empty intersection with the delivered binary STL. These checks establish geometry and modelled insertion clearance; they do not establish printed fit or resistance to rivet-setting force.
