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

Nothing here proves a print. Only a printed part does that, and printing is Ziad's step.

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
