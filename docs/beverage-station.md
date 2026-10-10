# Beverage station

Rev-02 reconstruction of the six exported pieces in `sketchup/kitchen`, authored in `parts/beverage-station.scad`, with a subsequent flat-floor drink-body revision. The source builds without the SketchUp files or imported STLs. Coffee sits on the left and drinks on the right; the front faces -Y. Every separately printed piece has its own preview color.

## Reference handling

- The archived drink-body STL is 10× oversized. Its companion 3MF explicitly applies a 0.1 scale; measurements here use that scale.
- The archived baseplate names are swapped. `beverage-station-drinks-base-02.stl` is the small coffee plate; `beverage-station-coffee-base-02.stl` is the large drink plate. Ziad confirmed assigning them by matching geometry.
- Coffee includes the sloping dispenser floor, scooped pickup tray, rounded dispensing opening, viewing/label pocket, and the lid's slanted stirrer cup and curved filter holder.
- Drinks retains six chambers, elliptical pickup openings, and open-top backed label channels. The measured chamber widths and slightly uneven partition spacing are retained. The cover has six underside plugs and four quarter-circle retainers on top.
- The archived drink-lid plugs start 5 mm too far forward and intersect the reservoir front wall. The reconstruction moves their start from Y=30.5 to Y=35.5, retaining their 117 mm length. They now have 0.5 mm clearance at both ends of the 118 mm chambers.
- Tiny mesh irregularities are reconstructed as named dimensions and analytic profiles. The original pickup-lip contours and curved stirrer rim are stored as editable 2D points. This is a dimensional reconstruction, not an identical triangulation.

## Outputs

All six outputs start at Z=0 in their upright orientations. Sizes are X × Y × Z in mm. The working plain drink-body file is a copy of its v02 draft; the other five plain files retain their v01 drafts.

| Piece | STL | Size | Triangles | Genus |
| --- | --- | --- | --- | --- |
| Coffee body | `stl/beverage-station-coffee-body.stl` | 136 × 155 × 110 | 778 | 2 |
| Coffee lid | `stl/beverage-station-coffee-lid.stl` | 136 × 139 × 145.661 | 1824 | 0 |
| Coffee base | `stl/beverage-station-coffee-base.stl` | 146.2 × 165 × 4 | 958 | 0 |
| Drink body | `stl/beverage-station-drinks-body.stl` | 157.784 × 155 × 150 | 1848 | 6 |
| Drink lid | `stl/beverage-station-drinks-lid.stl` | 158 × 127 × 13 | 908 | 0 |
| Drink base | `stl/beverage-station-drinks-base.stl` | 167.8 × 165 × 4 | 976 | 0 |

The assembled envelope is 309.2 × 165 × 253.661 mm. It is an assembly view, not a single print job.

## Flat-floor drink body

Ziad reported that the inclined lanes let packets stack upright and become difficult to pull out. The v02 drink-body build replaces the approximately 20° ramps and their approximately 7 mm front drop with a horizontal floor at Z=7.8 mm, continuous through each chamber, its outlet, and the pickup tray. The six partitions, outlet shapes, label channels, exterior dimensions, and lid/baseplate interfaces are retained. The coffee body is unchanged.

The change removes gravity feeding; packets may need to be moved forward manually. Whether it prevents tipping and jamming needs a packet trial with the printed body.

```bash
utils/build.sh parts/beverage-station.scad -D 'show="drinks-body"' --name beverage-station-drinks-body --backend=CGAL
OUTDIR=renders/beverage-station-drinks-body utils/render.sh parts/beverage-station.scad -D 'show="drinks-body"' --render=cgal
```

The revised binary mesh has one shell, genus 6, positive volume of 547313.663 mm³, and zero collapsed triangles, bad edge incidences, or winding errors. Mesh sampling confirms the Z=7.8 mm floor across every chamber, outlet, and tray. The drink-base seated intersection and both continuous drink insertion sweeps are empty; the seated lid intersection is zero-volume planar contact at the rim.

## Build and review

Choose a piece explicitly when building. Use `show="exploded"` or `show="assembled"` for review, regardless of the current Customizer selection.

```bash
for piece in coffee-body coffee-lid coffee-base drinks-body drinks-lid drinks-base; do
    beverage_backend=Manifold
    if [[ "$piece" == drinks-body ]]; then beverage_backend=CGAL; fi
    utils/build.sh parts/beverage-station.scad \
        -D "show=\"$piece\"" --name "beverage-station-$piece" \
        --backend="$beverage_backend"
done
```

The exact-spacing drink body needs CGAL for its binary export. The Manifold export develops float32 slivers at the pickup tray's right corner even though OpenSCAD reports `NoError`. The delivered CGAL STL passes the independent triangle, edge, and winding checks. The other five delivered meshes use Manifold.

```bash
utils/render.sh parts/beverage-station.scad -D 'show="exploded"'
OUTDIR=renders/beverage-station-assembled utils/render.sh parts/beverage-station.scad -D 'show="assembled"'
OUTDIR=renders/beverage-station-coffee-lid utils/render.sh parts/beverage-station.scad -D 'show="coffee-lid"'
```

The exploded review is `renders/beverage-station-iso.png`. Individual seven-view sets are in `renders/beverage-station-<piece>/`, each named `beverage-station-<camera>.png`. Review the iso and all six elevations; the backed label channels can appear blank face-on.

## Assembly and verification

The three dovetails connect the baseplates in XY. Put the drink plate down first, then lower the coffee plate vertically with its three tails aligned to the sockets. Keep the plate seam 0.2 mm apart. Each body drops into its baseplate well; each lid then drops into its body. These are vertical assembly paths.

The source provides `base-fit`, `coffee-base-fit`, `drinks-base-fit`, `coffee-lid-fit`, and `drinks-lid-fit`, plus the corresponding `*-insertion` views. Fit views intersect the seated mates. Insertion views intersect the fixed mate with the entire continuous vertical swept volume, starting fully outside. Only the teeth or plugs enter their respective mate; their non-entering bodies remain clear by their bounding boxes. Body insertion uses the full convex body envelope. These constructive paths prove connected access to the seated poses without relying on isolated collision-free samples.

Verification on 2026-10-08: all six delivered binary STLs have one connected shell, positive volume, zero collapsed triangles, zero bad edge incidences, and zero winding errors. All five continuous insertion sweeps are empty. Seated base/body checks are empty; seated lid checks produce only zero-volume contact at the cover-to-rim plane.

Renders were inspected for shape and orientation. Ziad makes the visual call. Physical fit, packet feeding, print quality, and support requirements remain untested; no slicing or printer transmission was performed.
