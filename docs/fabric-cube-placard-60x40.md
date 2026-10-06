# Fabric-cube placard for a 60 x 40 mm label

A separate smaller version of the [6 x 4 inch placard](fabric-cube-placard-6x4.md), using the same equal border, rounded front perimeter, label clearance, and recessed rivet-head geometry. The source is a copy with only the label dimensions changed; the larger placard remains a separate output.

| Dimension | Default |
| --- | --- |
| Overall plate at back face | 83.2 x 63.2 x 2.4 mm |
| Label | 60 x 40 mm, landscape |
| Label recess | 61 x 41 mm; 0.6 mm deep |
| Label clearance | 0.5 mm per side |
| Floor beneath label | 1.8 mm |
| Border from recess to back-face edge | 11.1 mm on every side |
| Flat front border | About 8.7 mm on every side |
| Front perimeter roundover | 2.4 mm, down to the back |
| Outside corner radius | 5 mm |
| Rivets | Six, three above and three below |
| Shank holes | 3.3 mm across flats, for assumed 1/8 inch rivets |
| Head pockets | 6.9 mm across flats; 1.2 mm deep; flat-bottom seats |
| Assumed domed head envelope | 6.7 mm diameter |
| Material beneath rivet head | 1.2 mm |
| Hole centres, from plate centre | X = -35.2, 0, 35.2 mm; Y = -25.2, 25.2 mm |

Print back down and label face up; this orientation needs no supports. The default hardware assumption is an ordinary domed 1/8 inch pop rivet. See the larger placard's [mounting notes](fabric-cube-placard-6x4.md) for backing washers, grip range, and rivet-gun access. Printed fit, actual head dimensions, gun access, and resistance to rivet-setting force remain untested.

## Outputs

Printable mesh: `stl/fabric-cube-placard-60x40.stl`. Source: `parts/fabric-cube-placard-60x40.scad`.

```sh
utils/build.sh parts/fabric-cube-placard-60x40.scad
utils/render.sh parts/fabric-cube-placard-60x40.scad
utils/render.sh parts/fabric-cube-placard-60x40.scad -D 'show="label-layout"'
```

## Verification

Revision v01 was inspected in all seven standard views and a front label-layout preview. The binary STL has 6,646 triangles, one connected shell, genus 6, and no collapsed triangles, edge-incidence errors, or winding errors. Independent mesh measurements confirm the overall dimensions, 61 x 41 mm recess at Z = 1.8 mm, and equal 11.1 mm borders. Continuous axial insertion envelopes for the 60 x 40 mm label, conservative 3.2 mm rivet shafts, and assumed 6.7 mm heads have an empty intersection with the delivered mesh down to their respective floors, with a 0.0001 mm numerical gap. These are geometry checks, not physical hardware or load validation.
