# Flash Studio: slicing reference for the AD5M Pro

**Machine:** FlashForge Adventurer 5M Pro, 0.4 nozzle
**Slicer:** Flash Studio 1.7.13, reporting internally as Orca-Flashforge 2.3.2
**Verified:** 2026-08-09, by reading the installed profiles and running the CLI

## Why this exists

`flashforge-ad5m-pro-scad-reference.md` is the constraint set for *designing* geometry. This is the constraint set for *slicing* it, and the two disagree in places—because that document was assembled from FlashForge's published profiles and community reports, while everything here was read out of the slicer actually installed on this machine.

Read this before advising on a print setting, before quoting a line width, and before assuming any figure in the SCAD reference is what the slicer will really do. The corrections section at the end lists every place the two documents diverge.

It also exists so nobody has to hunt through the app bundle again. Every path, chain and resolved value below is recorded so it can be looked up instead of rediscovered.

<!--| PAGE-BREAK -->

## The slicer

### What it is

Flash Studio is Orca-Flashforge rebranded. Orca-Flashforge is a fork of OrcaSlicer, which forked from Bambu Studio, which forked from PrusaSlicer, which forked from Slic3r. The practical consequence is that the OrcaSlicer CLI documentation applies almost verbatim—the fork inherits the command-line interface intact.

The app bundle reports `CFBundleShortVersionString` 1.7.13, but `--help` prints `Orca-Flashforge-2.3.2`. **The 2.3.2 is the number that matters** when checking whether an upstream flag exists; upstream's `--logfile`, for instance, arrived in 2.4.0 and is therefore absent here.

### Driving it from the command line

The executable lives inside the bundle, and its name contains a space:

```bash
"/Applications/Flash Studio.app/Contents/MacOS/Flash Studio" --help
```

**It runs headless.** Confirmed: invoked with no display attached it printed help and exited 0. No X server, no window, no GUI session required.

A complete slice, using the profiles already installed:

```bash
P="/Applications/Flash Studio.app/Contents/Resources/profiles/Flashforge"
"/Applications/Flash Studio.app/Contents/MacOS/Flash Studio" \
  --slice 0 \
  --load-settings "$P/machine/Flashforge Adventurer 5M Pro 0.4 Nozzle.json;$P/process/0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle.json" \
  --load-filaments "$P/filament/Flashforge PETG Pro.json" \
  --outputdir /tmp/slice-out \
  --export-3mf /tmp/slice-out/out.gcode.3mf \
  stl/hobbs-chalk-holder.stl
```

Machine profile first in `--load-settings`, process profile second, semicolon-separated. Filaments are a separate flag. **Because the profiles ship inside the bundle, nothing needs exporting**—point at them in place and the slice uses exactly the settings the GUI would.

Caveat not yet resolved: those files carry `inherits` keys, and it is untested whether the CLI resolves an inheritance chain from a bare child file or needs a fully-resolved profile. If a slice comes out with obviously wrong settings, that is the first thing to suspect. `--export-settings resolved.json` dumps the merged configuration and is the way to check.

### Flags that matter

| Flag | What it does |
| --- | --- |
| `--slice N` | 0 = all plates, i = plate i. This is what triggers slicing at all |
| `--load-settings "a.json;b.json"` | Machine then process |
| `--load-filaments "f.json;..."` | One per slot |
| `--export-3mf name.gcode.3mf` | Primary output; the G-code lives inside the archive |
| `--export-settings out.json` | Dumps the resolved configuration—use this to verify inheritance |
| `--export-slicedata dir` | Slice cache, reloadable with `--load-slicedata` |
| `--outputdir dir` | Where `plate_1.gcode` and friends land |
| `--info` | Model information without slicing |
| `--pipe name` | Streams progress as newline-delimited JSON |
| `--debug 0..5` | fatal, error, warning, info, debug, trace |
| `--no-check` | Skips validity checks including G-code path conflicts |
| `--arrange 1` / `--orient` / `--rotate` / `--scale` | Plate manipulation |
| `--datadir dir` | Alternate settings root—useful for testing a profile change without touching the GUI's config |

**There is no REST or HTTP API.** File-based invocation and `--pipe` are the only integration points.

### Setting priority

The slicer prints its own precedence rules, and they are worth internalising because they make command-line overrides safe:

```text
1) setting values from the command line (highest priority)
2) setting values loaded with --load_settings and --load_filaments
3) setting values loaded from 3mf (lowest priority)
```

So a single setting can be overridden on the command line without editing or copying a profile—the same pattern `render.sh` and `build.sh` already use with OpenSCAD's `-D`.

<!--| PAGE-BREAK -->

## Where the profiles live

System profiles ship inside the app bundle:

```text
/Applications/Flash Studio.app/Contents/Resources/profiles/Flashforge/
├── machine/
├── process/
└── filament/
```

User presets and overrides live at `~/Library/Application Support/Orca-Flashforge/`. **Note the directory kept the pre-rebrand name**—there is no `Flash Studio` directory.

### Resolving an inheritance chain

Almost every profile is a thin overlay. A file typically sets two or three keys and names a parent in `inherits`, and the parent is matched by its **`name` field, not its filename**. Reading a profile file directly will therefore tell you almost nothing.

The `0.12mm Fine` process profile is the cautionary example. Its entire content is `layer_height: 0.12` and `support_line_width: 0.4`. Everything else—every line width, every compensation, every speed—comes from the 0.20 mm profile it inherits from.

To resolve a chain, walk `inherits`, matching each name against the `name` key of every JSON in the same directory, and merge child over parent:

```python
import json, glob, os

def find(name, kind, P):
    for f in glob.glob(f"{P}/{kind}/*.json"):
        try:
            if json.load(open(f)).get("name") == name:
                return f
        except Exception:
            pass

def resolve(path, kind, P):
    d = json.load(open(path))
    chain = [os.path.basename(path)]
    while d.get("inherits"):
        p = find(d["inherits"], kind, P)
        if not p:
            chain.append(d["inherits"] + " (missing)")
            break
        parent = json.load(open(p))
        chain.append(os.path.basename(p))
        merged = dict(parent)
        merged.update({k: v for k, v in d.items() if k != "inherits"})
        merged["inherits"] = parent.get("inherits")
        d = merged
    return d, chain
```

Most values arrive as single-element lists (`['265']`), not scalars. Unset overrides appear as the string `'nil'`, which means *inherit*, not *zero*.

<!--| PAGE-BREAK -->

## The stack in use

### Machine

`Flashforge Adventurer 5M Pro 0.4 Nozzle` ← `fdm_adventurer5m_common` ← `fdm_flashforge_common` ← `fdm_machine_common`

| Setting | Value | Note |
| --- | --- | --- |
| `extruder_type` | Direct Drive | |
| `retraction_length` | **0.8** | FlashForge's PLA-oriented default. Nothing overrides it |
| `retraction_speed` / `deretraction_speed` | 35 / 35 | |
| `retraction_minimum_travel` | 1 | |
| `z_hop` / `z_hop_types` | 0.4 / Auto Lift | |
| `wipe` / `wipe_distance` | 1 / 2 | |
| `retract_before_wipe` | **100%** | All retraction happens *before* the wipe, so the wipe does nothing about ooze |
| `machine_max_speed_x` | 600 | |
| `printable_height` | 220 | The SCAD reference's 215 safe figure already accounts for the margin |

### Process

`0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle` ← `0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle` ← `fdm_process_flashforge_0.20` ← `fdm_process_flashforge_common` ← `fdm_process_common`

| Setting | Value | Note |
| --- | --- | --- |
| `layer_height` | 0.12 | The only meaningful thing the "Fine" profile sets |
| `initial_layer_print_height` | **0.30** | Does *not* scale with layer height—first-layer effects span 0.3 mm either way |
| `line_width` | 0.42 | |
| `outer_wall_line_width` | **0.42** | |
| `inner_wall_line_width` | **0.45** | Not 0.42. This breaks the SCAD reference's wall ladder—see corrections |
| `initial_layer_line_width` | 0.50 | |
| `wall_loops` | **2** | |
| `elefant_foot_compensation` | 0.15 | |
| `xy_hole_compensation` | **0** | |
| `xy_contour_compensation` | **0** | |
| `resolution` | 0.012 | Geometry finer than this is discarded |
| `seam_position` | aligned | |
| `travel_speed` | 500 | Already fast; not a stringing lever |
| `outer_wall_speed` / `inner_wall_speed` | 200 / 300 | |
| `initial_layer_speed` | 50 | |
| `bridge_speed` | 25 | |
| overhang speeds 1/4 → 4/4 | 0, 40, 20, 10 | Matches the SCAD reference |
| `reduce_crossing_wall` | **0** | "Avoid crossing walls" is OFF |
| `max_travel_detour_distance` | 0 | |

### Filament

`Flashforge PETG Pro` ← `Flashforge Generic PETG` ← `fdm_filament_pet` ← `fdm_filament_common`

| Setting | PETG Pro | HS PETG | Note |
| --- | --- | --- | --- |
| `nozzle_temperature` | **265** | 255 | Both far above where PETG should run |
| `nozzle_temperature_initial_layer` | 255 | 255 | |
| `hot_plate_temp` | 70 | 70 | |
| `textured_plate_temp` | 85 | 85 | |
| `filament_max_volumetric_speed` | 12 | 12 | Matches the SCAD reference |
| `filament_flow_ratio` | 1 | 1 | |
| `pressure_advance` | 0.046 | 0.046 | Matches the SCAD reference |
| `fan_min_speed` / `fan_max_speed` | 80 / 100 | 80 / 100 | |
| `overhang_fan_speed` | 100 | 80 | |
| `slow_down_layer_time` | 8 | 8 | |
| every `filament_retraction_*` | `nil` | `nil` | **Nothing overrides the machine's 0.8 mm** |

<!--| PAGE-BREAK -->

## The filament actually loaded

**FlashForge Rapid PETG, 1.75 mm, Burnt Titanium.** Vendor claims: 600 mm/s capable, ±0.02 mm dimensional accuracy, 1 kg spool, colour-shifting under light, and a finish marketed as hiding layer lines.

Two things follow from that description that bear on how it prints:

- **Colour-shifting and layer-line-hiding both imply loaded pigment**—mica, metal flake or a photochromic additive plus a matte agent. Loaded PETG behaves differently from clear: it is more abrasive on the nozzle, and matte additives generally want *less* heat, not more.
- **"Rapid" is marketing for the high-speed formulation.** The matching profile family is `Flashforge HS PETG`, not `Flashforge PETG Pro`.

**The profile in use is a mismatch.** `Flashforge HS PETG` exists, lists `Flashforge Adventurer 5M Pro 0.4 Nozzle` among its compatible printers, and differs from PETG Pro in exactly two respects: `nozzle_temperature` 255 rather than 265, and `overhang_fan_speed` 80 rather than 100.

That said, **switching profiles is not the fix on its own**—255 is still 15–25 °C above where this material should run. Treat HS PETG as the correct starting point and then come down from it.

## Stringing: diagnosis and fix

A print in this filament strung badly with the filament already dried. The cause is in the profile, not the spool.

**`nozzle_temperature` is 265.** The SCAD reference already flags FlashPrint's stock 250 °C PETG profile as ⚠️ "widely considered mis-tuned," with the community answer at 230–240 [FIELD]. Flash Studio's PETG Pro profile is 15 °C above the figure that document criticises, and 25–35 °C above the recommended band. PETG that hot is very fluid and will string regardless of how dry it is.

In order of effect:

1. **Nozzle temperature 265 → 235.** By far the largest lever. Run a temperature tower if the first guess is not right; the band worth exploring is 230–245.
2. **Retraction 0.8 → 1.6–2.0 mm**, keeping 35 mm/s. 0.8 is FlashForge's PLA default and the filament profile does not override it. Direct drive tolerates more than this for PETG. Orca's built-in retraction test settles it in one print.
3. **`retract_before_wipe` 100% → 0–30%.** At 100% the retraction finishes before the wipe move starts, so the wipe cannot clear ooze. Lower it and the retraction happens *during* the wipe, depositing residue on the wall instead of trailing it through air.
4. **`reduce_crossing_wall` 0 → 1.** Currently off. It matters more for these parts than for most: the chalk holder's collet has four slots, so every layer up it crosses open space eight times. The SCAD reference makes the same point from the other direction—*"Because retractions are risky, minimize travel-heavy geometry."*
5. **Switch to `Flashforge HS PETG`** as the base profile, since that is the family the filament belongs to. Worth doing for correctness, but it only buys 10 °C of the 30 needed.

`travel_speed` is already 500 and is not worth touching.

For whatever still gets through: a brief pass with a heat gun. That is already the documented answer for wisps in the painter's pyramid artwork and it works better on PETG than picking.

<!--| PAGE-BREAK -->

## The low-string presets

Applied 2026-08-09. Two user presets, written to `~/Library/Application Support/Orca-Flashforge/user/default/`. **They are user presets deliberately**—nothing inside the app bundle was touched, so a Flash Studio update cannot clobber them and the stock profiles remain intact underneath.

### `filament/Rapid PETG Burnt Titanium.json`

Inherits `Flashforge HS PETG`, which is the correct family for this filament.

| Setting | Stock | Set to | Why |
| --- | --- | --- | --- |
| `nozzle_temperature` | 265 (Pro) / 255 (HS) | **240** | The stringing cause. Inside FlashForge's own declared range for the material, which is 220–260 |
| `nozzle_temperature_initial_layer` | 255 | **245** | Slightly hotter than the body for bed adhesion |
| `filament_retraction_length` | `nil`, so the machine's 0.8 | **1.6** | 0.8 is FlashForge's PLA default; direct drive takes more for PETG |
| `filament_retract_before_wipe` | `nil`, so the machine's 100% | **20%** | At 100% the retraction finishes before the wipe starts, so the wipe does nothing about ooze |
| `filament_max_volumetric_speed` | 12 | **8** | See below—this one is a deliberate trade |

**Why the flow cap.** Cooler PETG cannot melt as fast. At 0.12 mm layers and 0.42 mm width the 200 mm/s outer wall demands about 10 mm³/s, which is close to the stock cap of 12 and unrealistic at 240 °C. Capping at 8 makes the slicer *slow down* to stay inside the melt rate rather than under-extrude. **Prints get slower.** That is the intended behaviour; raise it back toward 12 only if the temperature goes back up.

Retraction on the **filament** rather than the machine is deliberate too: retraction belongs to the material. Setting it machine-side would have applied 1.6 mm to PLA as well.

### `process/0.12mm Fine @AD5M Pro 0.4 - Low String.json`

Inherits `0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle`, and changes exactly one thing:

| Setting | Stock | Set to | Why |
| --- | --- | --- | --- |
| `reduce_crossing_wall` | 0 | **1** | "Avoid crossing walls." Matters more for these parts than most—the chalk holder's collet has four slots, so every layer up it crosses open space eight times |

### Verification, rollback, and what to do next

Both chains were resolved after writing and every value confirmed to land:

```text
filament: Rapid PETG Burnt Titanium <- Flashforge HS PETG <- Flashforge Generic PETG
          <- fdm_filament_pet <- fdm_filament_common
process:  0.12mm Fine @AD5M Pro 0.4 - Low String <- 0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle
          <- 0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle <- fdm_process_flashforge_0.20
          <- fdm_process_flashforge_common <- fdm_process_common
```

The previous `user/` tree was copied to `user_backup-manual-<timestamp>/` in the same directory before anything was written. Rolling back is deleting the two new files, or restoring that folder.

**Writing the files does not select them.** Both must be picked in the Flash Studio GUI before they take effect.

If it still strings at 240, go down before touching anything else—235, then 230, which is the floor of the useful band. Only after temperature is exhausted is retraction worth another look, and 2.0 mm is the next rung.

## Corrections to the SCAD reference

Each of these is a place where `flashforge-ad5m-pro-scad-reference.md` says something the installed profiles contradict or refine. **Where they disagree, this document wins**—these values were read from the slicer that will actually run the job.

### Wall thickness ladder—the important one

The reference's §4.3 ladder is built on a single 0.42 mm line width, giving 0.84 / 1.26 / 1.68 / 2.10 / 2.52 / 3.36. **Only the outer wall is 0.42. Inner walls are 0.45.**

That matters most for a thin feature with two exposed faces, such as a tube wall or a collet finger, where both surfaces get an outer-wall pass:

```text
2 loops:            0.42 + 0.42                = 0.84   still valid
3 loops:            0.42 + 0.45 + 0.42         = 1.29   NOT 1.26
4 loops:            0.42 + 0.45 + 0.45 + 0.42  = 1.74   NOT 1.68
```

A wall drawn at the reference's 1.26 leaves only 0.42 between the two outer passes, which is narrower than a 0.45 inner wall—so the slicer resolves it with gap fill or by stretching the outer passes rather than laying a clean third perimeter. `handle_collet_tip_wall` in `parts/hobbs-chalk-holder.scad` is currently 1.260 for exactly this reason and is affected. **This has not yet been confirmed against a real slice**; it is inference from the widths, and the check is described below.

`wall_loops` is also **2**, not the reference's implied "as many as fit."

### Hole compensation—confirmed, and the starting value refuted

The reference says FlashForge sets no XY compensation, marked ⚠️ and unverified. **Confirmed:** `xy_hole_compensation` and `xy_contour_compensation` are both `0` in the fully resolved profile.

Its recommended starting point of "+0.15 mm on diameter for the 0.4 nozzle" does **not** hold here. Measured on this machine and filament at 0.12 mm layers: a bore drawn at 10.150 mm across the flats miked 9.5–9.6 mm, a loss of **0.55–0.65 mm on diameter**. `hole_pull_in` in the chalk holder is set to 0.600 from that measurement rather than from the reference.

### First layer height does not scale

Not covered by the reference at all, and it changes how elephant's foot is reasoned about: **`initial_layer_print_height` is 0.30 mm even when `layer_height` is 0.12.** First-layer squish effects therefore span 0.3 mm of height regardless of how fine the rest of the print is, and a bore's mouth is affected over that whole range.

This is the leading explanation for a bore that mikes tight near the bed and may open up further in. It also means the reference's §5.3 rule—*"Never let a critical mating surface be the first layer"*—applies over a thicker band than the layer height suggests.

### Confirmed unchanged

`elefant_foot_compensation` 0.15, `resolution` 0.012, `pressure_advance` 0.046, PETG `filament_max_volumetric_speed` 12, the overhang speed ladder, and `seam_position` aligned all match the reference exactly.

## What the CLI is worth building on

The repo already has a design loop—`utils/render.sh` to see geometry, `utils/build.sh` to mesh it and report manifoldness and genus. The slicer closes the last gap, because several design claims currently rest on arithmetic that only the slicer can confirm:

- **Wall counts.** Slice, then parse the G-code at a known Z and count extrusion widths across a feature. This is the only way to prove a 1.26 or 1.29 mm collet finger really gets three perimeters instead of two-plus-gap-fill.
- **Retraction and travel counts.** Count `G1 E-` moves and open-air travels per layer band. Turns the stringing conversation from opinion into measurement, and tests whether `reduce_crossing_wall` actually helps this geometry.
- **Support decisions.** Slice with supports off and inspect, to confirm the "no supports needed" claims in `parts/hobbs-painters-pyramid.scad`.
- **Time and filament.** `slice_info.config` inside the exported `.gcode.3mf` carries filament in mm and grams, estimated print time and layer count—machine-readable, so a coupon-versus-full-plate decision stops being a guess.

None of this is built yet. If it gets built, it belongs in `utils/`, alongside the other two scripts, and it should export nothing to the printer.

## Open items

1. **Does the CLI resolve `inherits` from a bare child profile?** Untested. Verify with `--export-settings` before trusting any slice driven from the bundle's files directly.
2. **Is the bore tight only at its mouth?** Mike a printed bore 10 mm up from the bed and compare with the reading at the opening. If it opens up, the 0.30 mm first layer is the culprit and `hole_pull_in` is set too high.
3. **What is the real pull-in at mid-height?** Follows from item 2. Orca's tolerance test, run once for this filament, would settle it properly.
4. **Does 240 °C fix the stringing?** The presets are applied but unproven on a print. If it still strings, drop to 235 then 230 before changing anything else.
5. **The three-perimeter question**, per the wall ladder correction. Needs a slice and a G-code parse.
