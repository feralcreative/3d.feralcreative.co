# Debugging

What each artifact proves, where the logs are, and the failure modes already seen. Read when something built clean but came out wrong.

## What each verification step can and cannot tell you

| Artifact | Proves | Blind to |
| --- | --- | --- |
| `renders/<part>-*.png` | Shape, orientation, whether a feature landed on the right face | Manifoldness, wall thickness, printability |
| `build.sh` summary (`Status`, `Genus`, vertex/facet counts) | Manifold output; through-holes actually go through | Whether the shape is the one you wanted |
| `slice/<part>/plate_1.gcode` via `gcode-probe.py` | Height, layer count, commanded temperatures, real retraction distances, per-layer extrusion mix | Anything about the physical machine |
| `slice/<part>/resolved.json` | The full settings the slicer used | Whether the printer received them |
| `slice/<part>/slice.log` | Slicer stdout/stderr; where a failed slice explains itself | — |
| `show="fitcheck"` — boolean intersection of part and mating part | That the **seated** pose does not overlap | **Whether the seated pose can be reached at all.** See below. |

Nothing here proves a print. Only a printed part does that, and printing is Ziad's step.

## A part that fits is not a part that goes in

The screen fence cost two printed parts to this, so it is worth stating flatly: **an empty `fitcheck` proves the part fits where it ends up, and says nothing about whether it can get there.** For anything that has to enter a channel, a slot, or past a lip, those are different questions and the second is the hard one.

Three ways of answering it, in increasing order of how much they actually prove:

1. **A swept arc about an assumed pivot.** Cheap, and worth doing first for intuition. But it answers "can it rotate once engaged", not "can it get in", because it presupposes the engagement. The fence's tongue analysis passed this and the part still would not go in.
2. **Free placements at each tilt.** Also not enough on its own. Reporting "collision-free placements exist at every tilt from 0° to 30°" reads like a pass and is not one — it establishes local freedom near the seated pose, not a connected path from outside. That is the specific mistake that shipped a part that could not be inserted.
3. **A configuration-space path search.** The real answer. Rasterise the mating part once; for each tilt, rasterise the part and get every collision-free translation in one shot by FFT cross-correlation; then flood-fill reachability from "part entirely clear of the mating part" to the seated pose. Rotation about any fixed point plus arbitrary translation covers every rigid motion, so the space is complete. If the seated pose is not in the reachable set, no amount of rocking, tilting or force will seat it.

Sanity rules learned the hard way:

- **Cover the whole tilt range.** An early run swept −16° to +70° and missed the near-vertical, face-first motion the part was actually designed for. Widening it to ±100° did not change that answer, but only because it was checked.
- **Search from outside, not from nearby.** Restricting the translation search to a few millimetres around the seated pose is what made a dead design look feasible.
- **One colliding sample is a finding, not noise.** A single overlapping cell on a 0.15 mm grid got written off as "the pinch camming home". It was the top lip fouling the rib, and it was the whole problem.
- **Report obstructions by region.** Splitting collisions into near-half and far-half made the real signal readable; lumped together, a known artifact at one end masked the genuine block at the other.
- **When a physical test disagrees with the model, the model is wrong.** Ziad reported twice that the part would not rotate past the back corner while the analysis said it cleared by 0.40 mm. It did clear — but the tongue at the *other* end forced a tilt the channel could not accommodate, so he felt it at the back. Symptom and cause were at opposite ends of the part.

## Silent failure modes

- **Missing include or import.** OpenSCAD prints an ERROR and exits 0. The build succeeds, the STL exports, and the artwork—or a whole sub-assembly—is absent. Look at the render; do not trust the exit status.
- **A hole that did not go through.** `Genus: 0` on a part with a bore. Usually a subtracted solid stopping flush with its parent instead of overshooting by `eps`.
- **Coplanar subtracted faces.** Zero-thickness walls that confuse the renderer and the slicer. Overshoot every cut.
- **A reassigned parameter.** The last top-level assignment wins file-wide, so a value can be quietly overridden from a line far below the geometry that uses it.
- **A preset that never reached the job.** Correct file, correctly selected, stale project configuration. The only detector is the probe output.
- **A `.json` copied without its `.info` sidecar.** The preset does not appear in Flash Studio's dropdown, with no error.
- **Stale STL.** `slice.sh` on a `.scad` rebuilds the mesh first for this reason; slicing a hand-picked STL does not. Check the timestamp and the part name before treating any `.stl` or `.3mf` as evidence—a wrong conclusion was published from a five-hour-old project file for a different part.

## The chalk holder jams

Three consecutive coupons jammed the feed drive at roughly 6.5 mm, 10 mm and 20 mm of height: the extruder grinds the filament flat, stops advancing, and the print continues in the air. Before any print-setting change, parts printed complete; the only complaint was stringing. The prior is that the tuning caused this, not the model and not the machine.

Mechanism, worked out and believed: on a four-finger collet the per-layer extrusion collapses to about 1 mm while retraction events continue at a dozen per layer, so the retract-to-extrude ratio inverts and the same short length of filament is cycled through the drive gear hundreds of times until it is powder. The extrusion cliff `gcode-probe.py` reports at z 7.86 is where the fingers begin and where every failure happened. That is a useful number and was not a useful theory—four separate diagnoses built on it (stale STL, malformed preset, fingers snapping off mechanically, faceting) all failed on measurement, and are recorded in `_PLANS/chalk-holder-04-260810T1514Z.md`.

If a coupon still jams on the rolled-back stack, the investigation belongs on the machine—drive gear tension, heat creep in the hotend, whether the PTFE or nozzle needs replacing after three grinding events—and not back on slicer settings. See [STATUS.md](STATUS.md) for the next single-variable test.

## Health checks

```bash
utils/profiles-check.sh                                  # app vs repo preset drift
utils/gcode-probe.py slice/<part>/plate_1.gcode           # what a job will actually do
utils/gcode-probe.py slice/<part>/out.gcode.3mf --at-z 38 # extrusion-role mix at a height
utils/build.sh parts/<part>.scad                          # manifold + genus
```

A slice failure prints the last lines of `slice.log` itself. If `plate_1.gcode` is missing, the slice failed even if a command appeared to succeed—read the log rather than re-running.
