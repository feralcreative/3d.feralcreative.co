# Fabric-cube placard for a 6 x 4 inch label

A flat, rounded plate for an adhesive label, attached to a fabric storage cube with pop rivets. The label sits on the front face; there is no raised border or label pocket.

| Dimension | Default |
| --- | --- |
| Overall plate | 175 x 135 x 2.4 mm |
| Label area | 152.4 x 101.6 mm (6 x 4 inches) |
| Corner radius | 5 mm |
| Rivets | Six, three above and three below the label |
| Hole diameter across flats | 3.3 mm, for nominal 1/8 inch (3.2 mm) rivets |
| Hole centres | X = -79.5, 0, 79.5 mm; Y = -59.5, 59.5 mm |
| Reserved head or washer diameter | 12 mm |

Coordinates are measured from the plate centre. A 12 mm head or washer remains 2.7 mm clear of the label. The STL contains just the plate and holes; `show="label-layout"` adds a preview-only guide for the label.

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

The default geometry was inspected in all seven standard views, both plain and with the label guide. The binary STL measures 175 x 135 x 2.4 mm: one connected shell, six through-holes (genus 6), no collapsed triangles, and no edge-incidence or winding errors. A conservative 3.2 mm shaft envelope swept continuously through each hole has an empty intersection with the plate. These checks establish geometry and modelled insertion clearance; they do not establish printed fit or resistance to rivet-setting force.
