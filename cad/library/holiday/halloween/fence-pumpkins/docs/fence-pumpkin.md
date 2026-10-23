# Fence-post pumpkins

Source: [fence-pumpkin.scad](../fence-pumpkin.scad). Adapted from "LED tea light jack-o-lantern pumpkins" by artwells (Printables model 1835966), licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); original files remain unchanged in `led-tea-light-jack-o-lantern-pumpkins-model_files/`.

## Print status—2026-10-22

Ziad reported that the pumpkin has been printed and everything fits.

## Closed, upright one-piece doors—2026-10-21

The current `fence-pumpkin-door-fix.stl` and `fence-pumpkin-door.stl` close the hollow rear lobes into a solid CAD volume for normal slicer infill. Each door is one piece. Ziad chose a flat underside for upright printing: the rear is trimmed at the existing guide stop, source Z=−17, and the supplied STL rests on that plane at print Z=0. The cork opening faces upward. The lower rear outline is deliberately flat; the rest follows the original pumpkin surface. The body and stem STLs remain byte-identical, and the original overnight 3MF is untouched.

For the already printed pumpkins, open **`saved-jobs/fence-pumpkin-door-fix-closed-upright.3mf`**. The matching complete-set project is `saved-jobs/fence-pumpkin-door-closed-upright.3mf`. Each contains one upright object, the saved PETG Pro machine/filament settings, 0.20 mm layers, two walls, five top/three bottom layers, 15% grid infill and supports disabled. Matching `-sliced.3mf` files retain the checked toolpaths. Do not use the complete-set door in the older body. Print one retrofit before repeating the five-door batch.

Both CLI slices exited 0. The retrofit estimates 44 min 20 s and 19.94 g; the complete door estimates 47 min 56 s and 24.91 g. Actual G-code contains sparse infill and zero support roles; the archive records one unskipped object and `support_used=false`. Neither slice logs the earlier tree-generation errors. Temperatures remain 255→265 °C and retraction remains 0.8 mm. Effective settings differ from the original project only in support enablement and process-name/override bookkeeping. The slicer still emits its existing `bed_temperature_too_high_than_filament` warning; this task does not tune filament or bed temperatures. Small bridges remain, including the wire passage; support-free toolpaths do not establish printed bridge quality.

Both final binary meshes have one connected closed surface, Euler 0/genus 1, zero collapsed triangles, zero bad edges and zero winding errors. The retrofit has 54,976 triangles and volume 44,851.711 mm³; the complete door has 37,088 triangles and volume 61,544.902 mm³. Binary-export cleanup changes each volume by less than 0.000001 mm³; the retrofit's submicron edge collapses move vertices by at most 0.000000239 mm. Seated and conservative continuous vertical insertion intersections with each matching body and the current stem are empty. Guide and cork-interface differences are below 0.0002 mm³; old-minus-new above the intentional underside trim is below 0.0011 mm³ from float32 reorientation. The tested 18.5 mm bore, 22 mm engagement, 6 mm wire passage and guide dimensions are unchanged. All seven final views of each door and the complete-set together/exploded assemblies were rendered and inspected. Reports, fixtures and previews are under `_work/closed-upright-20261021/`. Physical fit, bed adhesion, bridge quality and the finished print remain unverified.

`rear_interior="closed"` and `flat_underside=true` are the authoring defaults. `rear_interior="hollow"` with `flat_underside=false` retains the earlier support-dependent geometry/orientation. `pumpkin-outer-solid.scad` preserves only the outer connected surface of the original blank shell and its lid, so the fill follows the lobes rather than a convex hull. Regenerate that helper with NumPy available:

```bash
python3 cad/utils/pumpkin-solid.py --output cad/library/holiday/halloween/fence-pumpkins/includes/pumpkin-outer-solid.scad
utils/build.sh cad/library/holiday/halloween/fence-pumpkins/fence-pumpkin-door-fix.scad --name fence-pumpkin-door-fix --no-version
utils/build.sh fence-pumpkins --name fence-pumpkin-door --no-version -D 'show="print-door"' -D 'fused_roof=true' -D 'disc_cover=true'
```

Independently check and clean binary-export slivers before promoting a rebuild. `cad/utils/pumpkin-door-project.py --mesh <checked-upright.stl> --settings <flattened-project-settings.json> --process 'cad/docs/profiles/process/0.20mm Standard @AD5M Pro 0.4 - Pumpkin Closed Door.json' --output <editable.3mf>` reproduces an editable upright project without changing the installed presets. Slice it with `PROCESS="0.20mm Standard @AD5M Pro 0.4 - Pumpkin Closed Door" FILAMENT="Flashforge PETG Pro" utils/slice.sh <editable.3mf>`. The downloadable assembly SCAD now restores the upright door with a Z=−17 translation. The following sections retain the history of the earlier hollow geometry and failed supports; the closed upright projects supersede the support-gap trial.

## Earlier retrofit support removal failed—2026-10-21

Ziad printed `fence-pumpkin-door-fix.3mf` overnight and reported that all supports were too stuck to remove. He confirmed that they are fused to the surface. This is a failed physical support-release result; the immediate failure is bonding at support contacts. Existing mesh, fit and clearance checks do not override this result. The accepted appearance and tested light interface remain unchanged.

The provided file is an editable project without G-code. Its saved settings are Flashforge PETG Pro, 0.20 mm layers, automatic trees with the default style, plate-only supports, two top interface layers, 0.50 mm interface spacing, 0.24 mm top Z distance and 0.30 mm support/object XY distance. The saved temperatures are 255→265 °C, with inherited 0.8 mm retraction. These are the project settings, not independently recovered evidence of the actual overnight printer job.

A frozen snapshot and diagnostic re-slice are under `_work/support-removal-20261021/`. Flash Studio's current CLI reports Orca-Flashforge 2.4.2. The baseline re-slice completed with G-code, a sliced archive and an exported resolved configuration; only version metadata differs from the saved configuration. It estimates 1 h 37 min 13 s and 31.54 g. Both baseline and trial produce `Potentially lost branch!, critical: 1` and `Not precalculated Placeable areas requested` diagnostics; an exit status of zero does not resolve those support-generation concerns. The exported archive also retains the stock bed-temperature warning.

The separate diagnostic project `_work/3mf/fence-pumpkin-door-fix-support-gap-trial.3mf` increases only the top support Z distance from 0.24 to 0.40 mm and gives the process a distinct trial name. The matching source preset is `cad/docs/profiles/process/0.20mm Standard @AD5M Pro 0.4 - Pumpkin Door Release Trial.json`. It carries forward the provided project's existing process overrides. No installed preset, original project, SCAD or retained STL was overwritten. The gap trial targets the confirmed bonding failure. Test one door before a batch; acceptable release and the supported surface finish still need physical confirmation. Keep temperature, retraction, XY clearance and geometry unchanged for this first comparison.

All original mesh, placement, paint and other archive entries remain byte-identical in the trial. Re-slicing confirms that only the top gap and process name differ in the effective configuration. Model extrusion geometry is identical when path order and direction are ignored; support toolpaths change. The trial estimates 1 h 33 min 50 s and 30.99 g. At one sampled low overhang, the model extrudes at Z=5.4 with a 0.2 mm layer height; corresponding support interface paths move from Z=4.8 to 4.6. The resulting nominal layer-bottom gaps are 0.4 and 0.6 mm respectively. This local observation is not a universal measured air gap or a physical release test.

The trial remains local and unpromoted. It has not been printed or shown to release cleanly, and the tree diagnostics still require review before treating it as a replacement production job. Do not repeat the failed setup for the five-door batch. See [OrcaSlicer's support Z-distance documentation](https://github.com/OrcaSlicer/OrcaSlicer/wiki/support_settings_advanced#z-distance) for the setting's meaning; the 0.40 mm trial value is a scoped experimental choice, not a manufacturer guarantee.

## LED cork placeholder in the assembly SCAD—2026-10-20

`fence-pumpkin-assembly.scad` now displays an illustrative LED cork/solar head in the holder during F5 preview. Toggle `preview_light` to hide it. The cork shank uses the existing 18.5 mm socket diameter and 22 mm insertion depth; the head and flange reuse the earlier approximate stand-in dimensions. The placeholder follows the door in both together and exploded views. Head, flange and panel dimensions are adjustable in the LED cork placeholder section; they are visual estimates, not verified product measurements.

The accessory is guarded by `$preview`, so F6 renders and mesh exports contain only the printed pumpkin parts. Exports with `preview_light=true` and `false` were byte-identical. The four retained print STLs are unchanged. Catalog Together and Exploded presentations explicitly enable the accessory and set `$preview=true` for their coloured 3MF/GLB exports. The downloadable SCAD defaults to showing it in F5; normal F6/STL exports still exclude it. All seven together and exploded preview views were rendered and read under `_work/led-cork-preview/`.

## Door-fix top seam closed—2026-10-20

Closed the 0.3 mm crosswise slot between the retrofit door plate and its rear shell at the crown. `door-fix-crown-bridge.scad` samples the same original upper surface across Y=24.99..25.31 and forms a solid bridge above Z=20 within X=−20..20. The new material follows each existing lobe and overlaps the plate and shell. The rear clearance outside the doorway remains intact for the already printed body. This change applies only to `fence-pumpkin-door-fix.stl`; the complete body, complete door and stem are byte-identical to the previous revision.

The bridge helper comes from `cad/utils/pumpkin-crown.py --back-y 25.31 --wall-t 0.32`; rename its generated `back_crown()` module to `door_fix_crown_bridge()` when regenerating. Source assertions reject a changed seam or back plane without regeneration.

The revised fix has one connected closed surface, Euler −8/genus 5, 67,506 triangles, volume 34,194.540 mm³ and zero collapsed triangles, bad edges or winding errors. Bridging the crown connects additional routes around the remaining open rear clearance; there are no separate enclosed cavity surfaces. The seated and full conservative vertical insertion intersections against the protected legacy body and current stem are empty. The cork-holder interface difference is empty; differences below Z=20 and old-minus-new geometry have only numerical residuals below 0.000026 mm³. The final seven door/assembly views and matching top close-up were rendered and read. Reports and previews are under `_work/door-fix-top-seam/`; its `mesh-inputs.zip` holds verification mesh inputs so the loose STL cleanup stays intact. Physical fit and print quality remain unverified.

## Current STL files after cleanup—2026-10-20

The model folder contains exactly four retained STL files: `fence-pumpkin-body.stl`, `fence-pumpkin-door.stl`, `fence-pumpkin-door-fix.stl` and `fence-pumpkin-stem.stl`. The door fix additionally includes the top crown bridge described above; the other three meshes are unchanged from the verified rounded-holder revision below. Five copies of the door fix are needed for the existing pumpkins, but support removal must be resolved before repeating that print. Two copies each of the matching body, final door and stem are intended for the remaining pumpkins.

Seven superseded top-level exports and 58 older or duplicate work meshes were moved into `originals/retired-stls-2026-10-20.zip`. Every archived STL was checked against its SHA-256 hash before its loose copy was removed. The archive includes `STL-ARCHIVE-MANIFEST.json` and preserves paths relative to this model folder. Historical verification fixtures that import those work meshes require restoring the corresponding archived files first. Current reports and renders remain available; old 3MF/slicer jobs were outside this STL-only cleanup. The original source meshes and legacy mating-body reference remain in their protected subfolders because they support rebuilding and fit verification.

## Complete set and separate door fix—2026-10-20

There are now two distinct door/body combinations. Print **five `fence-pumpkin-door-fix.stl`** parts for the five already printed pumpkins. For the two remaining pumpkins, print **two each of `fence-pumpkin-body.stl`, `fence-pumpkin-door.stl` and `fence-pumpkin-stem.stl`**. The stem is unchanged and can be reused. Do not swap the two door variants: the fix uses the existing Y=25 rear wall; the complete set moves that wall to Y=20.

The new complete body and door use the original pumpkin exterior on both sides of the joint. The door's native rear lobes start at Y=20.3, leaving a 0.3 mm fitting gap at the body's Y=20 cut. The wall is still 4.8 mm thick; the plate's inner face moves from Y=20.2 to Y=15.2. The 40 mm door width, 1.8 mm V tongues, 0.3 mm sliding clearance and Z=−17 stop are preserved. `complete-back-outline.scad` supplies the filled Y=20 outline and `complete-back-crown.scad` follows the source roof across the new wall. This restores a connected complete rear shell without the retrofit's added side backing. The roof stays integral and the steel-disc pocket and stem mount retain their earlier dimensions.

`fence-pumpkin-door-fix.scad` independently retains the old body interface and the approved side-lobe backing with its inward 2.1 mm round-over. The legacy mating body is preserved under `originals/door-fix/`. The pre-taper approved door is retained in the local verification archive; the current fix adds the subsequently requested rounded holder underside.

Both doors share `cork-collar-blend.scad`. A 12 mm deep lower half-ellipsoid is tangent to the holder's vertical outside at its former Z=0 floor and shrinks into the pumpkin below it. A rounded forward root fills the underside back to the rear shell clearance plane. This adds material beneath the sharp ledge rather than shortening the holder. The tested 18.5 mm bore, 22 mm engagement, 3.5 mm radial wall, 2 mm socket floor and 6 mm wire passage at Z=5.5 remain unchanged. The holder axis stays at Y=37.5 and its top at Z=24. The taper is behind each variant's rear clearance plane and does not extend into the sliding guides.

The assembly SCAD imports only the complete body, door and stem final STLs. Local rendering uses `file_prefix=""`; website downloads use the `fence-pumpkins--` prefix. The separate door fix is a fourth STL download, not an assembly companion. The catalog has five downloads including the assembly SCAD, and six views including together, exploded and four individual parts.

Build from the unified root:

```bash
OUTDIR=/tmp/pumpkin-build utils/build.sh fence-pumpkins --name fence-pumpkin-body --no-version -D 'show="print-body"' -D 'fused_roof=true' -D 'disc_cover=true'
OUTDIR=/tmp/pumpkin-build utils/build.sh fence-pumpkins --name fence-pumpkin-door --no-version -D 'show="print-door"' -D 'fused_roof=true' -D 'disc_cover=true'
OUTDIR=/tmp/pumpkin-build utils/build.sh cad/library/holiday/halloween/fence-pumpkins/fence-pumpkin-door-fix.scad --name fence-pumpkin-door-fix --no-version
```

Re-import binary exports and intersect an enclosing cube before promotion if float32 conversion produces collapsed triangles. Independently verify topology and a volume change below 0.001 mm³. Reports, conservative continuous insertion sweeps and seven-view renders are retained under `_work/complete-set/`. The complete body has two closed surfaces and Euler 4 because the steel-disc cavity is sealed; each door has one closed surface and Euler −2/genus 2. All final meshes have zero collapsed triangles, bad edges or winding errors. Both seated and full continuous insertion intersections are empty for each matching body/door pair. These checks establish geometry, not physical fit or print quality. Both doors need supports under the raised rear shell and curved overhangs; support placement/removal, new-body printing and magnetic holding strength remain unverified. No slicing, publication or printer action is included in this revision.

## Earlier sculpted replacement rear door—superseded filename and holder underside

The following notes describe the pre-split replacement. Its geometry became the separate door fix; `fence-pumpkin-door.stl` now names the matching complete-set door described above.


The current `fence-pumpkin-door.stl` restores the original blank pumpkin's rear lobes on the existing sliding door. Only the door needs reprinting for an existing pumpkin. The body and stem files are byte-for-byte unchanged. The 40 mm door, 1.8 mm V tongues, 0.3 mm sliding clearance, Z=−17 stop and crown contour are preserved. The restored shell starts at Y=25.3, leaving a 0.3 mm seam behind the existing body's Y=25 rear wall.

The left side lobe has a solid backing with a 2.1 mm inward round-over. Its front-facing edge curls into the rear shape instead of growing into a visible flange beside the body. `backing-inset.scad` contains the original convex backing inset along its supporting planes; the authoring SCAD adds the radius back, keeping the rounded shape inside the original envelope. A small internal fill behind the original cut-edge material preserves support without enlarging its front footprint. The door returns to the original sculpted part's overall bounds. Independent checks sampled 408 lines along Y; all 266 lines hitting material had one continuous solid interval, with no sampled internal gaps. The rounded edge deliberately moves some interval starts behind Y=25.3; every sample remains behind the clearance plane. Printed strength and support removal remain unverified.

The cork opening moves into the restored rear shoulder at X=0, Y=37.5, Z=24. The holder retains the tested 18.5 mm teardrop bore, 22 mm engagement depth, 3.5 mm radial wall and 2 mm floor. Its upper neck projects slightly beyond the original sculpted surface. The 6 mm wire passage now sits at Z=5.5 and connects the holder to the pumpkin through the sliding plate. Feed the strand through both passages, slide the door down from above, then insert the solar light with its supplied silicone sheath. The original solar-head stand-in clears the stem at this position, but its unmeasured dimensions do not verify the actual head's clearance.

Print the replacement with its flat inner door face on the bed, as supplied. Its bounds in print orientation are approximately 79.14 × 58.61 × 30.05 mm. The restored shell starts 5.1 mm above the bed and has curved overhangs, so this door requires supports. No new slicer project or G-code has been produced; support placement, removal, print quality and physical fit of this revised assembly remain unverified. The previous door's support-free setting must not be reused for this sculpted door.

OpenSCAD reports `NoError`, genus 2. Independent binary-mesh checks find one connected closed surface, Euler −2, 57,982 triangles, zero collapsed triangles, zero bad edges and zero winding errors; volume is 29,770.615 mm³. Boolean intersections with the body and stem are empty for the seated door and a continuous upward sweep to Z=200. The conservative sweep starts at Z=−17 for the plate and guides and at Z=−30 for the rear shell behind Y=25.299, allowing 0.001 mm for binary-STL rounding at the seam. This includes the low rear lobes without falsely extending the guides below their stop, and proves a connected straight insertion path from entirely above the body to its seat. Guide strips, bottom stop and light interface have empty symmetric differences against the preceding sculpted door. All seven views of the final assembly, exploded assembly and separate door were rendered and inspected under `_work/inward-rounded-backing/`. These are geometry checks, not a physical fit or strength claim.

`door_style="sculpted"` is the authoring default. `door_style="original"` retains the previous exposed-collar door for existing jobs. Together/exploded previews and the download assembly use the current final replacement mesh. Regenerate the replacement from the unified repository root:

```bash
utils/build.sh fence-pumpkins -D 'show="print-door"' --name fence-pumpkin-door --no-version
```

Build output remains under `_work/stl/` until deliberately promoted to the retained final file. No body reprint, printer transfer or publication is part of this revision.

The inward-rounding helper is generated from the protected blank shell. Regenerate it before building if `rear_gusset_round`, `rear_seam` or `rear_gusset_inner_x` changes; the authoring source asserts that these dimensions match. Run from the unified root, with NumPy available in the selected Python:

```bash
/usr/bin/python3 cad/utils/pumpkin-backing.py --output cad/library/holiday/halloween/fence-pumpkins/includes/backing-inset.scad
```

The binary door export can contain collapsed float32 triangles at imported-shell intersections despite an OpenSCAD `NoError` result. Re-import the candidate and intersect an enclosing cube, then independently verify the cleaned mesh before promotion. The checked final door has one surface, Euler −2, zero collapsed triangles, bad edges and winding errors; the cleanup changed volume by less than 0.000001 mm³. The final cleanup source and reports are retained under `_work/inward-rounded-backing/`. The assembly/download SCAD still needs only the three final STL companions.


## Earlier website deliverables—2026-10-20

### Printed light fit confirmed—2026-10-20

Ziad printed and tested the pumpkin lights and confirmed the sizing is perfect. The solar cork lights' supplied silicone sheaths make them fit snugly in the collar and stay in place. Keep the sheath fitted during assembly. Preserve the current light interface dimensions, including the 18.5 mm cork bore and 22 mm collar depth; this is a confirmed physical fit with the sheathed light, not a new measurement of the product. This feedback validates light fit and retention; it does not establish support removal, steel-disc pause/resume behavior or magnetic mounting strength.

The website exposes one matching set for the current closed-roof, covered-disc configuration: `fence-pumpkin-body.stl`, `fence-pumpkin-door.stl`, `fence-pumpkin-stem.stl`, and `fence-pumpkin-assembly.scad`. There is no separate cap in this configuration. The website prefixes each filename with `fence-pumpkins--`; download all four files into one folder without renaming them. The assembly SCAD imports only those three final STLs, restores their assembled poses from their print orientations, and offers `show="assembled"` or `show="exploded"`. Exploded mode moves the door 60 mm along +Y and lifts the stem 45 mm along +Z. Piece colors remain distinct.

`fence-pumpkin.scad` remains the editable authoring source with its original dependencies and optional open-roof configuration. Its exploded mode now also separates the stem and, when applicable, the removable cap. Website assembly previews are generated from `fence-pumpkin-assembly.scad` with `file_prefix=""`, so they use exactly the retained final part meshes. No geometry, fit clearances, or slicer settings changed in this curation.

Build the selected parts from the authoring source with `show="print-body"`, `show="print-door"`, or `show="print-stem"`, always setting `fused_roof=true` and `disc_cover=true`. Use export names `fence-pumpkin-body`, `fence-pumpkin-door`, and `fence-pumpkin-stem`. Body imports require the established containing-cube cleanup before promotion. The checked body has two closed surfaces because the steel-disc pocket is a sealed internal cavity; this accounts for OpenSCAD genus −1. All three delivered binary meshes have zero collapsed triangles, bad edges, or winding errors and sit at Z=0. Body cleanup changed signed volume by less than 0.000001 mm³.

All seven orthographic/isometric views were rendered and inspected in both assembled and exploded modes from an isolated copy of the four downloaded files. The catalog contains only the two assembly previews and three individual part previews, with exactly four downloads. Older originals, open-roof/cap exports, trials and sliced projects remain retained locally and are excluded from the project. Retired publication names remain claimed and excluded in the catalog so stale files cannot resurface as unmanaged cards or visitor downloads. No publication or printer action was performed during curation. Light sizing and retention are now physically confirmed as recorded above; support removal, other mating interfaces, disc-pause/resume behavior and overall printed quality remain unverified for this selected set.

## Earlier revision notes—2026-10-19



### Superseded assembly STL exports—2026-10-20

`_work/stl/fence-pumpkin-door-seated.stl` contains the latest face-on-ridge pumpkin with the door and stem seated. `_work/stl/fence-pumpkin-door-exploded.stl` keeps the pumpkin and stem seated and moves the complete door/collar 60 mm rearward along +Y. This is an exploded display offset, not the door's sliding installation path. Both use the current closed-roof, covered-disc configuration and omit the simulated solar light. They are assembly/display exports; the separate part exports and sliced projects remain the printing workflow.

```bash
utils/build.sh fence-pumpkins -D 'show="assembled"' -D 'preview_light=false' -D 'fused_roof=true' -D 'disc_cover=true' --name fence-pumpkin-door-seated
utils/build.sh fence-pumpkins -D 'show="exploded"' -D 'preview_light=false' -D 'fused_roof=true' -D 'disc_cover=true' --name fence-pumpkin-door-exploded
```

`door_explode` controls the exploded offset in millimetres. Both v01 exports were cleaned using the enclosing-cube method, then independently checked: 280,580 triangles, no collapsed triangles, no bad edges or winding errors, Euler 6 across four closed surfaces (the main pumpkin/stem exterior, door, enclosed disc cavity, and enclosed peg clearance). Cleanup changed each volume by less than 0.001 mm³. All seven views of each configuration were rendered and read in `_work/renders/door-seated/` and `_work/renders/door-exploded/`. These exports do not add physical-print validation.

### Face centred on a ridge

`face_angle=7.83` rotates the eyes, reduced nose, and mouth together about the vertical axis through X=0, Y=2. A horizontal section of the original blank shell at Z=4 mm places the nearest ridge crest at +7.83° from −Y (0.01° angular sampling). The shell's radius there is 46.742 mm, compared with 45.274 mm along the previous nose direction. The local nose remains 9.8 × 7.7 mm with its apex at Z=9 mm. The pumpkin's lobes, rear door, mounting pocket, lid and stem are not rotated.

The source now starts from the blank shell and cuts a rotated face profile, closing the original feature positions. The original eyes and mouth are recovered from the difference between the front-half projections of the blank and traditional shells; subtracting the two solids before projecting produces unwanted surface slivers. A 1 mm inset of the blank's outer silhouette excludes edge tessellation differences without reaching the facial features. The continuous inner membrane remains unchanged.

The updated editable project is `_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial-face-on-ridge.3mf`, derived from the smaller-nose project below. All three pumpkins use the new shared mesh. Settings, object placements, doors, blocker, and native pause XML are retained byte-for-byte. All 1,656 painted support triangles are reproduced with the same total painted area (1,431.298436 mm²); two triangles were retessellated, while 1,654 match directly. The project has not been re-sliced, and the saved 0.20 mm settings still require pause/cover verification. Embedded thumbnails remain from the input project until refreshed by the slicer.

The body is `_work/stl/fence-pumpkin-traditional-disc-pause-trial-v03.stl`. OpenSCAD reports `NoError`; its negative genus reflects the intentional enclosed disc cavity. Independent checks find two closed surfaces, Euler 4, zero collapsed triangles, zero bad edges, and volume 47,296.903 mm³. Enclosing-cube cleanup changed volume by less than 0.000001 mm³. All seven evaluated assembly views were rendered and read under `_work/renders/face-on-ridge/`; `face-highlight.png` colours the facial membranes gold only for review so their placement is visible.

The seated door/body intersection is empty. The intersection with the door's full XY silhouette extruded upward from its seated bottom at Z=−17 through Z=103 is also empty; this conservative continuous envelope contains the entire straight insertion path from outside. The steel disc's vertical sweep is empty against the body truncated at the documented completed pause height (source Z=−22.67, print Z=4.26), starting 0.001 mm above the seat to exclude contact. These are geometry checks and do not verify a new slice or a physical fit.

### Nose reduced around its top point

The nose is now 9.8 × 7.7 mm, reduced to 70% of its previous 14 × 11 mm dimensions around the fixed apex at X=0, Z=9 mm. Its base rises from Z=−2 to Z=1.3 mm. The smaller triangle still contains the original mesh's nose opening (X=±2 mm, Z=2..6 mm), so no old opening protrudes beyond it. The eyes, mouth, face membrane, mounting pocket, and mating interfaces are unchanged.

The updated open-body export is `_work/stl/fence-pumpkin-traditional-body-v19.stl`. OpenSCAD reports `NoError`, genus 0. After the established enclosing-cube cleanup, the binary mesh has one closed surface, Euler 2, zero collapsed triangles, and zero bad edges; volume is 43,140.766 mm³, with cleanup changing volume by less than 0.000001 mm³. All seven evaluated assembly views were rendered and read under `_work/renders/nose-70/`. Appearance remains Ziad's call.

On request, the selected `fence-pumpkin-PETG-Pro-disc-pause-trial-sliced.3mf` was copied to `_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial-nose-70.3mf` with the smaller nose. Despite its name, the selected file had been re-saved as an editable project without G-code. It contains three pumpkin instances and three doors on its first plate, plus an empty second plate; its settings differ from the original verified slice, including 0.20 mm layers and independent support layer heights enabled. This nose edit preserves those settings, placements, doors, support blocker, and native pause XML exactly. The shared body mesh alone is replaced, updating all three pumpkins, and all 1,656 painted support faces are retained. Every other archive entry is byte-for-byte unchanged; retained thumbnails refresh when the slicer regenerates them. This editable copy has not been re-sliced, and the earlier pause/cover verification below applies to the original 0.12 mm slice, not to these modified project settings.

The covered-disc body export is `_work/stl/fence-pumpkin-traditional-disc-pause-trial-v02.stl`: two closed surfaces (the body and enclosed disc cavity), Euler 4, zero collapsed triangles or bad edges, volume 47,236.284 mm³. Cleanup changed volume by less than 0.000001 mm³. All seven evaluated assembly views for this variant were rendered and read under `_work/renders/disc-pause-nose-70/`.

### Upright trial with pause-inserted steel disc

Ziad requested that the upright, fused-roof trial capture the steel disc under a couple of printed layers. The new optional `disc_cover=true` adds a 0.24 mm cover above the existing 25.4 mm × 2.2 mm pocket; the 25 × 2 mm disc, its 2.1 mm PETG floor, and the surrounding pad diameter remain unchanged. This configuration uses no glue beneath the disc. At the early insertion pause the pumpkin is still open above, so the disc drops vertically into its seat; it does not pass through the rear door. The complete vertical swept volume against the body truncated at the completed pause height has an empty intersection, with 0.001 mm clearance above the seat to exclude the seated contact plane.

The new editable file is `_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial.3mf`; the sliced job is `_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial-sliced.3mf`. At the native pause, place one **25 mm diameter × 2 mm thick steel disc** flat in the open pocket and resume. The last completed model layer is **34 at Z=4.26 mm**. The seated disc's top is Z=4.10 mm, below the completed surface. The pause occurs before **layer 35 at Z=4.38 mm**, and the two cover layers print at **Z=4.38 and 4.50 mm**. The existing 0.2 mm headspace is retained. Physical fit, pause/resume behavior on the printer, and cover print quality have not been tested.

`utils/pumpkin-disc-pause.py` measures the enclosed cavity from the actual mesh and checks the actual sliced archive against the editable companion. The slice contains exactly one native `PAUSE`, at the correct boundary; no extrusion enters the pocket before it. Both subsequent cover layers have covering toolpaths across the disc footprint. The cover check buffers paths by 0.25 mm over a radius-12.2 mm test disc; uncovered areas are 0.190 and 0.211 mm² respectively (both below 1 mm²). This is toolpath coverage, not proof of a physically sealed printed cover. Flash Studio preserves native pause XML but drops the custom measurement JSON during sliced export, so verification requires the editable companion via `--project`.

The scoped process `0.12mm Fine @AD5M Pro 0.4 - Pumpkin Disc Pause Trial` disables independent support layer heights so support layers cannot move the pause boundary. It retains plate-only manual slim trees and the nominal 0.3 mm support top gap. Only this new preset and its `.info` were installed; the preset drift check reads `in sync`. Machine/process/filament presets are also embedded in the project. Actual G-code confirms Flashforge PETG Pro, 255→265 °C, textured PEI at 85 °C, 0.8 mm retraction, plate-only supports, and independent support layer heights disabled. The estimate is **4 h 54 min 36 s / 73.00 g**, excluding the operator's insertion time. Flash Studio UI control was unavailable, so an app restart and GUI inspection were not performed; verification is from the CLI's exported G-code and archives. Nothing was sent to the printer.

The v01 covered-disc STL has one solid with one enclosed cavity (two closed surfaces, Euler 4), volume 47,154.862 mm³, zero collapsed triangles, and zero bad edges. Enclosing-cube cleanup changed volume by −0.000000024 mm³. All seven assembly views were rendered and read under `_work/renders/disc-pause-trial/`. The previous upright support-removal concern remains unresolved; adding the steel-disc pause does not establish an intact extraction route for the roof supports. This is the paused-disc version of that trial, not a support-removal validation.

Reproduce the source variant and verify the resulting job:

```bash
utils/build.sh fence-pumpkins -D 'show="body"' -D 'fused_roof=true' -D 'disc_cover=true' --name fence-pumpkin-traditional-disc-pause-trial
# Independently validate/clean this enclosed-cavity STL before packaging.
# Resolve the Disc Pause Trial process and PETG Pro profiles, then export
# fully resolved settings using the existing Flash Studio CLI workflow.
python3 utils/pumpkin-project.py \
  library/holiday/halloween/fence-pumpkins/_work/stl/fence-pumpkin-traditional-disc-pause-trial.stl \
  /tmp/pumpkin-disc-pause-settings.json \
  library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial.3mf \
  --door library/holiday/halloween/fence-pumpkins/_work/stl/fence-pumpkin-traditional-door.stl \
  --profiles /tmp/pumpkin-disc-pause-profiles --plate-only --disc-pause
PROCESS="0.12mm Fine @AD5M Pro 0.4 - Pumpkin Disc Pause Trial" FILAMENT="Flashforge PETG Pro" utils/slice.sh \
  library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial.3mf \
  --name fence-pumpkin-PETG-Pro-disc-pause-trial-sliced
python3 utils/pumpkin-disc-pause.py \
  library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial-sliced.3mf \
  --project library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-disc-pause-trial.3mf
```

### Fused-roof plate-only trial—removal check failed

On request, `fused_roof=true` restores the integral roof while retaining the thicker walls, centered 14 × 11 mm nose, curved door crown, internal disc pocket, and separate green stem. It is an optional trial; the default remains unchanged. Build with `utils/build.sh fence-pumpkins -D 'show="body"' -D 'fused_roof=true' --name fence-pumpkin-traditional-fused-trial`. The v01 binary export was cleaned with the enclosing-cube method: one closed shell, Euler 2, zero collapsed triangles or bad edges, volume 46,989.827 mm³, cleanup volume change −0.000000024 mm³. All seven fused assembly views were rendered and inspected under `_work/renders/fused-trial/`.

The editable project is `_work/3mf/fence-pumpkin-PETG-Pro-plate-only-trial.3mf`; the sliced copy appends `-sliced`. `utils/pumpkin-project.py --plate-only` paints the flat roof and three rim regions (1,656 triangles total) and embeds the resolved machine/process/filament presets. The new scoped `Pumpkin Plate Only Trial` process differs from `Pumpkin Rim Supports` by `support_on_build_plate_only=1` and its name. It is retained as trial data and has not been installed as an active app preset. G-code confirms plate-only supports, manual slim trees, nominal 0.3 mm top gap, Flashforge PETG Pro, 255→265 °C, an 85 °C textured-PEI bed, and 0.8 mm retraction. The slice estimates 4 h 31 min 15 s and 72.27 g. No job was sent to the printer. GUI control was unavailable for this trial; observations below come from the actual emitted G-code and mesh, not a GUI preview.

The trees start on the plate behind the pumpkin and enter the rear opening. There are 95,454 support extrusion moves, no support in the steel-disc pocket, and support extends to source Z=31.39. However, interior support centerlines span X=−24.231..24.326 mm (48.56 mm) against the approximately 40.6 mm doorway between the tongue roots. The diagram `_work/renders/fused-trial/plate-only-support-route.png` plots actual support toolpaths against body sections.

A rearward straight-pull test fails: at support source Z=27.911, using a 0.21 mm toolpath buffer and the body section 0.04 mm below it, the initial overlap is zero; translating the supports 10 mm rearward intersects 2.049 mm² of body, rising to 14.266 mm² at 20 mm. This rejects a straight, intact extraction path. It does not prove that no angled or flexible extraction exists, but no such path has been established. Therefore the trial demonstrates plate-only routing, not easy support removal, and is not promoted as the replacement print job. The sliced archive records only the stock PETG bed-temperature warning; absence of another warning is not an extraction check.

Ziad printed the previous fused-roof design and reported that it printed well overall, but all supports were hard to remove, especially those inside the roof. The door left daylight above its top, the shell needed more contrast against the glowing face, and the nose was too small and appeared off-center. The new revision has a separate orange cap, a curved door crown, thicker surrounding walls, and a larger nose centered on X=0. This revision has not been printed.

| Piece | Current export | Orientation |
| --- | --- | --- |
| Open body | `fence-pumpkin-traditional-body-v19.stl` | Upright, steel-disc pad on the bed; `show="print-body"` |
| Door with cork collar | `fence-pumpkin-traditional-door-v05.stl` | Inner face on the bed, collar upward; `show="print-door"` |
| Orange cap | `fence-pumpkin-traditional-cap-v01.stl` | Flat underside on the bed; `show="print-cap"` |
| Green stem | `fence-pumpkin-traditional-stem-v04.stl` | Flat cut face on the bed; `show="print-stem"` |

Exports are under the model's `_work/stl/`. The green stem retains the preceding printed stem's geometry, including its 5.3 mm socket, and can be reused. Its original XY scale is independent of the new cap's seating clearance. The cap has a 5 mm × 3 mm peg and a 0.15 mm clearance around the old stem's lobed base. Glue the stem onto the cap, leaving the cap removable.

## Walls and face

`wall_add` increases from 1.0 to 1.5 mm, for roughly 3.2 mm total at the widest part of the original 1.7 mm shell. Thickening scales inward toward the existing shell center; it is not a constant normal offset and stops below Z=28.5. Copies at 0.5 mm increments overlap continuously. Using just the final 1.5 mm copy left a sealed void inside the wall and was rejected.

The eyes and mouth retain their original contours. The nose is a 9.8 × 7.7 mm upward-pointing triangle at X=0, spanning Z=1.3..9 after the 30% reduction above. The eyes measure approximately 16–17 × 12 mm. The new triangle completely contains the old nose opening. A continuous inner membrane from the matching blank shell remains behind every facial feature; `face_skin=0.9` is unchanged from the printed revision. The membrane is formed from curved, scaled source surfaces, so that number is nominal rather than a constant normal thickness. Increased light contrast remains a physical print test.

A 0.5 mm front-projection grid covers 3,036 samples across the eyes, mouth, and enlarged nose; all intersect a front membrane. Samples exactly on feature edges can intersect multiple material intervals, so a first-hit interval alone is not a reliable minimum membrane thickness.

## Cap and door

The cap is the source lid with its stem separated, retaining the original stepped seating plate. Its footprint is reduced by 0.15 mm at the nominal 23 mm edge radius to avoid the source lid's nominal touching fit. The body is open at the top, eliminating the inaccessible internal roof and its supports. The cap prints with its flat underside at Z=29.04747 on the bed.

The door retains its 40 mm width, 1.8 mm V tongues with 45° flanks, 0.3 mm sliding clearance, and stop at Z=−17. Its collar and wire hole are unchanged. Previously the top was one section at Y=25 extruded through the entire 4.8 mm wall, leaving a mismatch where the pumpkin rises toward Y=20.2. `back-crown.scad` now follows the original blank shell and lid across that depth, sampled at 0.25 mm X × 0.20 mm Y. The crown laps 0.1 mm into the lower flat slab. The door receives the curved crown and the cap clears the door's sliding envelope.

Regenerate the crown from the repository root if the original contours change:

```bash
python3 utils/pumpkin-crown.py --output library/holiday/halloween/fence-pumpkins/includes/back-crown.scad
```

The data is fixed to Y=20.2..25, X=−24..24, and a Z=19.9 floor. Source assertions require regeneration if the back-wall dimensions change. `back-outline.scad` still supplies the lower wall outline at Y=25; regenerate it with `utils/section-outline.py` if that cut plane changes.

## Cork light and fence attachment

The face is −Y and the back +Y. A solar cork light plugs into the door's collar like a bottle neck; its strand passes through the 6 mm hole into the pumpkin. The preview represents a 45 mm square solar head, 20 mm high, on a 30 mm × 6 mm round flange. Its top is Z=33.09, hidden behind the pumpkin when viewed from the front. The 18.5 mm bore, 22 mm depth, head height, and flange dimensions remain unmeasured assumptions. They were not retuned in this revision.

The nickel-plated steel disc is 25 mm diameter × 2 mm thick. Its pocket opens upward inside the body: 25.4 mm diameter × 2.2 mm deep, including 0.2 mm glue allowance. The exterior bottom remains closed, with 2.1 mm PETG between the steel and fence magnet and a 2.1 mm radial pad wall. The exterior bottom is Z=−26.93, pocket seat Z=−24.83, and rim Z=−22.63. With 0.2 mm glue beneath the disc its bottom is Z=−24.63 and top level with the rim. The earlier outside-facing pocket in body v12 was incorrect; v13 and later use this internal seat. Adhesive bonding and magnetic holding force remain physically unverified.

Install the disc through the open top before fitting the cap. Fit the solar light and wire strand to the door, then slide the door down from above. The cap, door, and stem all have checked vertical installation paths; the disc can descend through the open top directly onto its seat.

## PETG Pro plate with local rim supports

The current editable project is `_work/3mf/fence-pumpkin-PETG-Pro-rim-supports-v18.3mf`; the sliced job is `_work/3mf/fence-pumpkin-PETG-Pro-rim-supports-v18-sliced.3mf`. The plate contains the upright body on the left, face-down door at the lower right, and flat-bottomed cap at the upper right. Print the green stem separately or reuse the existing one.

The body needs local supports under its sculpted upper rim. The separate cap removes the large internal roof and gives access through the top for removal; it does not make the original rim support-free. Only downward-facing triangles in the three floating-tip regions between Z=29 and 32.2 are painted as enforcers (612 triangles). Slim manual trees are enabled for the body; the steel-disc pocket has a blocker, and the door and cap explicitly disable supports. The nominal top separation increases to 0.3 mm in the scoped Pumpkin Rim Supports process preset. Removal remains a physical print test. The previous v14 fused-roof job and v15–v17 unsupported trial jobs are superseded; do not print those as the current revision.

The plate uses AD5M Pro / 0.12 mm Fine Pumpkin Rim Supports / Flashforge PETG Pro. PETG Pro supplies 255 °C for the first layer, 265 °C afterward, an 85 °C textured-PEI bed, and 0.8 mm retraction. All are read back from G-code. G-code inspection finds 34,201 support extrusion moves, including interfaces, with support beneath all three tip regions and none inside the disc pocket. Support XY bounds are X=−44.906..−11.318 and Y=−13.263..53.898 on the centered ±110 mm bed; they remain clear of the door and cap. The new process preset is stored in `docs/profiles/process/` and installed with its `.info` sidecar; the installer’s `--only` option limits installation to this preset. Other installed presets are untouched. The 3MF also embeds the resolved machine, process, and filament presets, so GUI import retains the intended selection. The final estimate is 4 h 15 min 55 s and 66.32 g PETG, including approximately 3.92 g of local supports. Nothing is sent to the printer by these commands.

Rebuild all exports, then clean and independently check the binary meshes. The body can export collapsed float32 triangles despite OpenSCAD's `NoError`; the cleanup re-imports it, intersects an enclosing cube, validates topology and a volume change below 0.001 mm³, and updates both its numbered and plain copies. The last cleanup changed volume by less than 0.000001 mm³.

```bash
utils/build.sh fence-pumpkins -D 'show="body"' --name fence-pumpkin-traditional-body
utils/build.sh fence-pumpkins -D 'show="door"' --name fence-pumpkin-traditional-door
utils/build.sh fence-pumpkins -D 'show="cap"' --name fence-pumpkin-traditional-cap
utils/build.sh fence-pumpkins -D 'show="stem"' --name fence-pumpkin-traditional-stem
python3 utils/pumpkin-meshes.py --clean-body
utils/profiles-check.sh --install --only "0.12mm Fine @AD5M Pro 0.4 - Pumpkin Rim Supports"
```

Use Python with NumPy, SciPy, Shapely for the contour/check workflow and Pillow for the project thumbnails. Resolve the named process and filament with `utils/ffprofile.py`, and obtain fresh fully resolved settings from `utils/slice.sh` or a settings-only Flash Studio export. The commands below use the resulting resolved settings and profile directory from the current sliced job:

```bash
python3 utils/pumpkin-project.py \
  library/holiday/halloween/fence-pumpkins/_work/stl/fence-pumpkin-traditional-body.stl \
  library/holiday/halloween/fence-pumpkins/_work/slice/fence-pumpkin-PETG-Pro-rim-supports-v18-sliced/resolved.json \
  library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-rim-supports-v18.3mf \
  --door library/holiday/halloween/fence-pumpkins/_work/stl/fence-pumpkin-traditional-door.stl \
  --cap library/holiday/halloween/fence-pumpkins/_work/stl/fence-pumpkin-traditional-cap.stl \
  --profiles library/holiday/halloween/fence-pumpkins/_work/slice/fence-pumpkin-PETG-Pro-rim-supports-v18-sliced/profiles \
  --rim-supports
PROCESS="0.12mm Fine @AD5M Pro 0.4 - Pumpkin Rim Supports" FILAMENT="Flashforge PETG Pro" utils/slice.sh library/holiday/halloween/fence-pumpkins/_work/3mf/fence-pumpkin-PETG-Pro-rim-supports-v18.3mf \
  --name fence-pumpkin-PETG-Pro-rim-supports-v18-sliced \
  --set process:enable_support=1
```

## Correction after slicer feedback

The first handoff was incorrect: zero emitted supports did not prove that the rim could print unsupported. Flash Studio reported floating regions in the body. Targeted rim-relief trials still left unsupported areas and were rejected; v18 restores the original sculpted rim and supports it locally. Mesh checks establish topology, not buildability.

The earlier job also used Rapid PETG instead of the requested Flashforge PETG Pro. Its global settings said PETG, but the GUI displayed Generic ASA after import; the archive lacked embedded preset files. The corrected project embeds all three presets and is checked in Flash Studio as well as in the emitted G-code. After restarting Flash Studio, the final v18 sliced project opens with Flashforge PETG Pro selected; a GUI re-slice shows the three local support branches, 66.32 g total and approximately 4 h 16 min, with no floating-region warning. Preset archive naming follows the [OrcaSlicer 3MF reader and writer](https://github.com/SoftFever/OrcaSlicer/blob/main/src/libslic3r/Format/bbs_3mf.cpp).

## Geometry verification

The body, cap, and stem each have one closed surface, Euler characteristic 2 (genus 0); the door has one closed surface, Euler characteristic 0 (genus 1, the wire hole). All delivered binary meshes have zero collapsed triangles and zero edges whose incidence differs from two. The body volume is 43,059.343 mm³; door 24,173.746 mm³. The cap is 3,847.046 mm³ and the unchanged stem is 3,956.107 mm³.

The seated cap/body and door/body boolean intersections are empty. Sampled vertical paths connect fully outside poses to the seats: cap 84 poses with 0.05 mm motion and section spacing; stem 161 poses with 0.025 mm spacing; door 601 poses at 0.1 mm motion, using 48 Y sections 0.1 mm apart against the body and cap. The body in v18 retains the v15 geometry after the unsuccessful relief trials, so these installation checks still apply; all sampled overlaps were zero. The horizontal disc's straight descent through the open top checks 578 body sections at 0.1 mm Z spacing, with no overlap. These sampled checks do not establish physical fit, printed sliding friction, cap retention, bond strength, or light contrast.

All seven assembly views are under `_work/renders/fence-pumpkin-{iso,zplus,zminus,yminus,yplus,xplus,xminus}.png`. The face-on view hides recesses through equal shading; `fence-pumpkin-face-layout.png` shows the front projection and centerline separately. Ziad makes the visual call. `preview_light=false` hides the solar-light stand-in for inspection; `show="section"` cuts the assembly in half. `show="pumpkin"` retains the uncut, fused reference output.
