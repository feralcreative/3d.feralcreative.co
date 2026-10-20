# Enclosed cup-magnet wings-out Halloween bats

Source: [magnetic-bats-cup-magnet.scad](../magnetic-bats-cup-magnet.scad). Adapted from the supplied `Magnetic+Halloween+Bat+Silhouettes_stls` archive. Original filenames and SHA-256 hashes are recorded in [source-measurements.json](source-measurements.json); the source meshes are protected under `originals/`. The archive contains only STL files, with no creator or license metadata. Original source assets remain unchanged.

## Selected bats

The original collection has 26 silhouettes; Body14–Body26 use one original magnet mount. The active selection is ten flying, wings-out variants: Body14, Body15, Body16, Body17, Body19, Body21, Body22, Body23, Body25 and Body26. The folded-wing Body18, Body20 and Body24 are excluded. Original mounting counts were identified from the raised mounting regions, not guessed from silhouette size. Earlier rejected Body20/Body24 source copies remain preserved under `originals/`; their printable deliverables are no longer in the active model folder.

| STL, v01 | Uniform wing scale | Exported print bounds | Rotation on plate |
| --- | --- | --- | --- |
| [Body14](../halloween-bat-body14-cup52.stl) | 179.8% | 200.0 × 200.0 × 13.98 mm | 45° |
| [Body15](../halloween-bat-body15-cup52.stl) | 182.7% | 199.2 × 200.0 × 13.98 mm | 82.5° |
| [Body16](../halloween-bat-body16-cup52.stl) | 198.9% | 199.6 × 200.0 × 13.98 mm | 9° |
| [Body17](../halloween-bat-body17-cup52.stl) | 152.7% | 200.0 × 198.4 × 13.98 mm | 53° |
| [Body19](../halloween-bat-body19-cup52.stl) | 227.6% | 199.5 × 199.9 × 13.98 mm | 38° |
| [Body21](../halloween-bat-body21-cup52.stl) | 237.2% | 199.1 × 199.9 × 13.98 mm | 70° |
| [Body22](../halloween-bat-body22-cup52.stl) | 169.8% | 180.0 × 180.2 × 13.98 mm | 45° |
| [Body23](../halloween-bat-body23-cup52.stl) | 167.8% | 199.0 × 199.9 × 13.98 mm | 45° |
| [Body25](../halloween-bat-body25-cup52.stl) | 188.6% | 199.0 × 199.9 × 13.98 mm | 84.5° |
| [Body26](../halloween-bat-body26-cup52.stl) | 201.8% | 198.8 × 200.0 × 13.98 mm | 86.5° |

Body22 keeps its earlier silhouette, scale, housing and STL unchanged. The other nine bats enlarge the original wings uniformly, then widen only the central body enough to enclose the 56.2 mm housing within the front silhouette. The widened outline is a union with a 56.7 mm body disk, leaving 0.25 mm around the housing. Body15, Body17 and Body25 move the cup centre slightly away from the head so the enlarged torso does not swallow the original ears. These offsets, rotations, scales and original-file hashes are recorded in `source-measurements.json`. Wing contours remain those of the supplied files; the body contour changes are intentional and need Ziad's visual call.

Nine new exports target a maximum 200 mm footprint, leaving 5 mm inside the documented 205 mm safe envelope; Body22 remains about 180 × 180 mm. Exports are rotated to fit the bed. Let the slicer centre the full silhouette on the plate; the magnet centre is the STL origin and is not necessarily the bounding-box centre. Do not undo the exported rotation for printing. The Z thickness is newly designed rather than uniformly scaling the original thickness.

## Enclosed magnet housing

Each bat holds one measured 51.7 mm-diameter, 10.75 mm-thick cup magnet. The compensated polygonal cavity has a 52.0 mm diameter across flats and is 11.04 mm deep: 0.15 mm nominal radial clearance and 0.29 mm extra depth. The rear circular housing is 56.2 mm across, with a 2.1 mm radial wall, a 2.1 mm floor continuous with the wing plate, and a 0.84 mm solid rear roof. Maximum thickness is 13.98 mm. The housing stays entirely within the bat silhouette, with at least approximately 0.25 mm outline margin at the fitted centre.

The original 1.5 mm plate is sectioned at Z=0.8 mm to recover its contour without its original raised magnet mounts. The measured outline is uniformly enlarged, repositioned around the cup centre, and extruded as a 2.1 mm wing plate. Nine bodies add the local 56.7 mm disk around the housing; Body22 retains its original outline. The circular housing is on the rear; the decorative front stays completely flat. Colours are preview only; STL files do not select a filament colour.

The working magnetic face points toward the thin rear roof and the steel mounting surface. The steel cup back points toward the decorative face. Each completed bat completely covers the magnet; neither face is exposed. Actual holding force through the 0.84 mm roof needs a physical check with the intended surface.

## Print and insertion

These are model STLs, not sliced jobs: **the STL does not contain a print pause**. Without an insertion pause the cavity will be sealed empty.

1. Print [the open fit coupon](../_work/stl/halloween-bat-cup52-fit-coupon.stl) first, flat floor on the bed. It has the production floor, cavity diameter, depth and wall but no roof. Confirm that the actual magnet drops in without force and sits below the housing top. This checks cup fit, not the roof-printing process or magnetic holding strength.
2. Put a bat's flat decorative face on the bed, with the circular housing up, in its exported rotation. Centre the complete mesh, not only the magnet housing.
3. Keep supports out of the magnet cavity. Place a pause **before the first layer that closes the cavity roof at model Z=13.14 mm**. Select this from the actual sliced layer preview and verify the pause in G-code before printing. For a 0.30 mm first layer and 0.12 mm subsequent layers, the expected first roof layer is layer 109 at Z=13.26 mm; this is a calculated guide, not verified G-code, and changes with layer settings. The repo's `--magnet-pause` option is specific to 10×2 mm Gridfinity magnets and must not be used for these bats.
4. At the pause, insert one cup magnet with its working face up toward the roof. Seat it completely; its top must stay below the open housing rim. Keep it in the pocket rather than allowing it to move toward the printer hardware.
5. Cover the magnet's top face with one smooth, non-overlapping piece of blue painter's tape. In Ziad's prints the magnet sits flush with the layer boundary, so the first roof layer lands on it like a first layer. On the bare steel and ceramic face, PETG lifted, hardened, and was struck by the nozzle, increasingly often, until a print failed outright on 2026-10-17. The next print, with painter's tape on the face, sealed perfectly. The tape is about 0.13–0.15 mm thick, which leaves little room under a 0.20 mm layer; do not substitute duct tape or anything thicker.
6. Resume to print the rear cover.
7. After cooling, check that the enclosure is intact and test its hold on the intended steel surface before installing the bat.

No printer settings have been changed, no job has been sent, and no claim of physical cup fit, pause/resume reliability, cap quality or holding strength is made. Ziad performs the print and final visual review.

## Verification

All seven evaluated-geometry views were inspected for every bat, the open coupon, and the Body22 and Body17 cutaways. The ten bats report `NoError`, genus -1: one connected plastic body and one enclosed internal cavity, represented by two closed mesh boundary shells. The coupon reports `NoError`, genus 0 with one closed shell. Independent binary-STL checks found zero collapsed triangles, bad edges or winding errors for the ten selected bat exports and the open coupon. Body17 originally had four collapsed float32 triangles; re-import and intersection with a containing cube removed them with a measured volume change of 0 mm³. Both its retained STL and v01 workspace copies are the cleaned mesh. Recheck and clean that variant after future rebuilds if the defect recurs. Other variants needed no cleanup. Exact mesh bounds, volumes and error counts are retained in [mesh-checks.json](mesh-checks.json).

For all ten bats, the exact cup-cylinder seated intersection is empty, its conservative continuous vertical insertion sweep through the housing before the roof is empty, and subtracting the bat outline from the housing footprint is empty. The insertion check models the paused, open housing, not insertion through the completed roof. It excludes the zero-thickness roof boundary by 0.01 mm; the cavity wall and radial clearance remain intact. Printed dimensional tolerances and the actual cup shape remain unverified.

## Rebuild

```bash
for body in 14 15 16 17 19 21 22 23 25 26; do
  utils/build.sh magnetic-bats-cup-magnet -D "bat=\"body${body}\"" --name "halloween-bat-body${body}-cup52"
done
utils/build.sh magnetic-bats-cup-magnet -D 'show="coupon"' --name halloween-bat-cup52-fit-coupon
```

Select `show="section"` to see the completely covered magnet, `show="before-cap"` for the paused housing, and `show="magnet-fit"`, `show="magnet-insertion"` or `show="wall-fit"` for the geometry probes. Do not scale these exported STLs in the slicer: that would also scale the measured magnet pocket.
