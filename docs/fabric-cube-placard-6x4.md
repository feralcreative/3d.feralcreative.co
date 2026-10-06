# Fabric-cube placard for a 6 x 4 inch label

A rounded plate for a 4 x 6 inch adhesive label, attached to a fabric storage cube with pop rivets. A shallow front recess accepts the label in landscape orientation. Sized to the user's stated 4 x 6 inch UPS label, number 0177400603; [UPS documents the 4 x 6 inch thermal-label format](https://www.campusship.ups.com/us/en/support/shipping-support/print-shipping-labels/thermal-printing-of-labels).

| Dimension | Default |
| --- | --- |
| Overall plate at back face | 164 x 125 x 2.4 mm |
| Border from recess to outside back edge | 5.3 mm at sides; 11.2 mm above and below |
| Border on flat front face | About 2.9 mm at sides; 8.8 mm above and below |
| Label area | 152.4 x 101.6 mm (6 x 4 inches) |
| Recess opening | 153.4 x 102.6 mm, square corners |
| Clearance around label | 0.5 mm per side |
| Recess depth | 0.6 mm |
| Floor beneath label | 1.8 mm |
| Corner radius | 5 mm |
| Front perimeter roundover | 2.4 mm, down to the back; 24 arc segments |
| Rivets | Six, three above and three below the label |
| Hole diameter across flats | 3.3 mm, for nominal 1/8 inch (3.2 mm) rivets |
| Hole centres | X = -75.6, 0, 75.6 mm; Y = -56.1, 56.1 mm |
| Default head seat | Flat-bottom counterbore for a domed pop-rivet head |
| Assumed head diameter | 6.7 mm; confirm actual hardware |
| Head pocket diameter across flats | 6.9 mm |
| Head pocket depth | 1.2 mm |
| Material beneath rivet head | 1.2 mm |

Coordinates are measured from the plate centre. The head pockets remain at least 1.34 mm clear of the label recess and entirely inside the flat front face. The STL contains the plate, label recess, six shank holes, and six head pockets; `show="label-layout"` adds a preview-only guide at the label-recess floor. The circular edge profile is rounded down to BOSL2's 1/1024 mm precision, leaving less than 0.001 mm of straight edge at the back.

The default assumes ordinary domed 1/8 inch pop rivets. A flat-bottom pocket supports their flat underside and recesses the head without a tapered seat. The representative 6.7 mm head envelope and 1.2 mm depth accommodate the manufacturer's listed 1/8 inch steel dome-head range of 6.05–6.66 mm diameter and 0.81–1.02 mm flange thickness; this is a sizing example, not identification of the user's hardware. [POP catalogue](https://www.stanleyengineeredfastening.com/-/media/Web/SEF/Resources/Docs/POP/POP-Rivet-Catalog.pdf)

Print flat with the back on the bed and label face up. This orientation needs no supports. The default holes assume 1/8 inch rivets; check an actual rivet in a hole before fastening the plate. Printed hole fit and the fabric attachment have not been physically tested.

Use metal backing washers on the inside of the cube to spread the load on the fabric. For the default flat-bottom pockets, choose a rivet grip range that covers the 1.2 mm material under its head, fabric, and any washers. Check that the rivet gun nose can reach the recessed head while it is fully seated. Keep the cube fabric accessible from both sides while riveting, and keep the rivet head clear of the label. Rivet grip and hole sizing guidance: [POP rivet catalogue](https://www.stanleyengineeredfastening.com/-/media/Web/SEF/Resources/Docs/POP/POP-Rivet-Catalog.pdf).

## Outputs and variants

Default printable mesh: `stl/fabric-cube-placard-6x4.stl`. Source: `parts/fabric-cube-placard-6x4.scad`.

```sh
utils/build.sh parts/fabric-cube-placard-6x4.scad
utils/build.sh parts/fabric-cube-placard-6x4.scad -D 'rivet_count=4' --name fabric-cube-placard-6x4-four-rivets
utils/render.sh parts/fabric-cube-placard-6x4.scad -D 'show="label-layout"'
```

The four-rivet variant omits the two centre holes. Larger rivets require updating head dimensions, edge distance, and potentially plate size; assertions guard against incompatible combinations. For actual countersunk-head rivets, `head_style="countersunk"` selects a tapered seat; `head_seat_angle` defaults to 120 degrees and must match the hardware. That optional tapered variant has not been exported or verified. Each named variant needs its own render inspection and mesh checks before use.

## Verification

Revision v03 tightens the border, adds head pockets, and rolls the front perimeter down to the back. The default geometry was inspected in all seven standard views, both plain and with the label guide. The binary STL measures 164 x 125 x 2.4 mm: 6,648 triangles, one connected shell, six through-holes (genus 6), no collapsed triangles, and no edge-incidence or winding errors. Its label recess measures 153.4 x 102.6 mm and its floor is at Z = 1.8 mm. Continuous axial insertion envelopes for the label, conservative 3.2 mm rivet shafts, and assumed 6.7 mm rivet heads have an empty intersection with the delivered binary STL, down to their respective floors with a 0.0001 mm numerical gap. These checks establish geometry and modelled insertion clearance for those envelopes; they do not establish actual hardware fit, gun access, or resistance to rivet-setting force.
