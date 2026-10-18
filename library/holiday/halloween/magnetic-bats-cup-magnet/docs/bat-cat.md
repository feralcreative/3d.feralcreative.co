# Leaping cat for the cup-magnet bats

Source: [bat-cat.scad](../bat-cat.scad), outline from [bat-cat.svg](../bat-cat.svg). The cat chases the [cup-magnet bats](magnetic-bats-cup-magnet.md) and is three times their span: 800 × 520 mm, against bats of 230–283 mm tip to tip. It prints as seven flat pieces joined by glued in-plane dovetails, with one enclosed cup magnet in the belly.

## Pieces

| Piece | STL | Print footprint | Joints |
| --- | --- | --- | --- |
| Tail | [halloween-cat-tail](../halloween-cat-tail.stl) | 179.5 × 177.3 × 8.7 mm | one tab into the rump |
| Hind leg | [halloween-cat-hind-leg](../halloween-cat-hind-leg.stl) | 142.8 × 142.6 × 8.7 mm | one tab into the rump |
| Rump | [halloween-cat-rump](../halloween-cat-rump.stl) | 177.3 × 173.4 × 8.7 mm | two tabs into the belly; sockets for tail and hind leg |
| Belly | [halloween-cat-belly](../halloween-cat-belly.stl) | 171.4 × 173.2 × 13.98 mm | sockets only; holds the magnet |
| Chest | [halloween-cat-chest](../halloween-cat-chest.stl) | 170.6 × 169.1 × 8.7 mm | two tabs into the belly; sockets for head and forelegs |
| Head | [halloween-cat-head](../halloween-cat-head.stl) | 166.1 × 162.0 × 8.7 mm | two tabs into the chest |
| Forelegs | [halloween-cat-forelegs](../halloween-cat-forelegs.stl) | 133.8 × 134.1 × 8.7 mm | one tab into the chest |

Every STL is already rotated to its smallest square on the bed and centred; print it as exported, decorative face down. All seven fit the 200 mm target inside the 205 mm safe envelope. About 364 cm³ of plastic in total, roughly 460 g in PETG.

The seams cross the cat at its natural necks: tail base, hip, waist, behind the ribs, neck, and shoulder. The tail runs diagonally across its bed, which is why it fits at all.

## Joints

The front shows only a straight line at every seam; the dovetails are hidden in the back. Through the thickness each joint has two parts. The front 1.2 mm of both pieces butts on the seam line. Above that, each tab rides a 45° ramp that climbs from the seam into the neighbouring piece, and the neighbour's socket floor is the matching ramp, so the tab sits on top of a wedge of the neighbour's front. The ramp hides the dovetail, gives a sloped glue face on top of the flank and end faces, and is also what makes it printable: face down, the tab's underside is a 45° overhang and the socket is open upward, so nothing needs support.

Seams under 100 mm carry one tab and longer seams two: 14 mm wide at the seam, 20 mm at the end, 6 mm deep, with 0.2 mm clearance per face for glue, including along the ramp. The 2.1 mm plate matches the bats and is too thin for this, so each seam has a rear land: the plate rises to 8.7 mm for 18 mm either side of the seam, stopping 2 mm inside the silhouette so the outline stays as thin as the bats'. The tab is 7.5 mm thick at the seam and 1.5 mm at its end. The land is on the wall side and hidden; the magnet housing stands 13.98 mm, so the land never touches the steel.

Every joint assembles by lowering the tab piece onto the face-down neighbour, so pieces can be glued in any order. Glue the cat face down on a flat surface so the front comes out flush. `show="joint-section"` shows the seated profile.

Print [the joint coupon](../_work/stl/halloween-cat-joint-coupon.stl) first: one tab and one socket at the production section and clearance. It shows whether 0.2 mm is right for this printer and the chosen glue before seven large pieces are committed to it. Elephant's foot on the face-down first layer is the likeliest thing to bind.

## Magnet

The belly holds one 51.7 × 10.75 mm cup magnet in exactly the bats' enclosed housing: 52.0 mm compensated pocket, 2.1 mm floor, 2.1 mm wall, 0.84 mm roof, 13.98 mm overall. It sits at the centre of mass of the whole cat, so the cat has no tendency to swing about it. The print procedure is the bats' procedure, unchanged: pause before the first roof layer at model Z=13.14 mm, seat the magnet working face up, cover it with one piece of blue painter's tape, and resume. See [the bat document](magnetic-bats-cup-magnet.md#print-and-insertion) for the reasons.

The cat weighs about twelve times a bat on the same single magnet. Whether one cup holds it in shear on the intended surface is unverified; test the assembled cat before trusting it.

## Verification

All eight STLs report `NoError`. Each piece's flat front face equals its exact share of the silhouette, so no tab reaches the front; the preview draws small notches at the chest seams that are not in the mesh. Six pieces report genus 0. The belly reports genus -1, one body and the sealed magnet cavity, as on the bats. The coupon reports genus -1 because it is two separate blocks. Every assembled neighbouring pair intersects to nothing, so tabs never collide with their sockets or each other. The seams, regions and tab roots were computed outside OpenSCAD: the seven pieces cover the outline exactly, every tab plus its clearance lies at least 2.5 mm inside the outline, and the magnet housing lies wholly inside the belly. Physical fit, glue strength and holding force are unverified.

## Rebuild

```bash
cd ~/www/feralcreative/scad
for p in tail hind-leg rump belly chest head forelegs; do utils/build.sh library/holiday/halloween/magnetic-bats-cup-magnet/bat-cat.scad -D 'show="piece"' -D "piece=\"$p\"" --name "halloween-cat-$p"; done
utils/build.sh library/holiday/halloween/magnetic-bats-cup-magnet/bat-cat.scad -D 'show="coupon"' --name halloween-cat-joint-coupon
utils/finalize.sh 'halloween-cat*'
```

Other views: `show="assembled"` (default), `show="exploded"`, `show="section"` for the covered magnet, and `show="before-cap"` for the belly at the pause. The seam data is fixed to the 800 mm outline; do not rescale the outline or the STLs.
