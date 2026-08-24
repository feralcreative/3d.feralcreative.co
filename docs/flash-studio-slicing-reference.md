# Flash Studio: slicing reference for the AD5M Pro

**Machine:** FlashForge Adventurer 5M Pro, 0.4 nozzle
**Slicer:** Flash Studio 1.7.13, reporting internally as Orca-Flashforge 2.3.2
**Verified:** 2026-08-09 by reading the installed profiles; corrected 2026-08-10 by driving the CLI and reading the G-code back

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

**Use `utils/slice.sh`.** It exists because every naive way of doing this is silently wrong, and the rest of this section is why. Driving the binary by hand is for debugging the script, not for producing a job you intend to print.

```bash
utils/slice.sh stl/hobbs-chalk-holder.stl          # low-string settings, applied and verified
utils/slice.sh parts/hobbs-chalk-holder.scad       # meshes it first via build.sh
utils/slice.sh stl/x.stl --stock                   # stock profiles, no overrides
utils/slice.sh stl/x.stl --set filament:nozzle_temperature=235
```

Machine profile first in `--load-settings`, process profile second, semicolon-separated. Filaments are a separate flag.

### The CLI does not resolve `inherits`

**Verified 2026-08-10, and it is the trap that matters most.** Point `--load-settings` or `--load-filaments` at a profile from the bundle and only the keys *physically present in that one file* take effect. Everything else falls back to the slicer's **built-in defaults, not the parent profile**. Since almost every profile here is a thin overlay, the result is a slice that has almost nothing to do with the settings you named.

Slicing with the bundle's own `Flashforge PETG Pro.json` and `0.12mm Fine`, exactly as this document previously recommended, produced:

```text
filament_type                  PLA     should be PETG
pressure_advance               0.02    should be 0.046
filament_max_volumetric_speed  2       should be 12
fan_min_speed                  20      should be 80
inner_wall_line_width          0       should be 0.45
outer_wall_line_width          0       should be 0.42
elefant_foot_compensation      0       should be 0.15
inherits_group                 ['', '', '']
```

`nozzle_temperature` came out right at 265 only because PETG Pro's own file happens to set it, and `layer_height` at 0.12 for the same reason. That is what makes this so dangerous: the one or two values you would think to spot-check are exactly the ones that survive.

Two ways to get a correct slice:

- **Resolve the chains yourself and pass flat profiles.** This is what `utils/ffprofile.py` does, walking `inherits` and merging child over parent before handing the result to the CLI. `utils/slice.sh` calls it on every run.
- **Slice a project 3mf saved by the GUI.** Its `project_settings.config` is already fully flattened, so `--slice 0 file.3mf` with no profile flags resolves correctly. Confirmed against a GUI-saved project: PETG, 0.046, flow 12, walls 0.45/0.42.

When merging profiles yourself, remove `inherits` and **leave every other metadata key alone**. Stripping `instantiation`, `setting_id` or `is_custom_defined` makes the slicer stop treating the machine profile as a real printer, and it then rejects the job with `process not compatible with printer` even though the process profile's `compatible_printers` names that machine exactly. Renaming the merged machine profile breaks the same match.

### Two path quirks in the output flags

Both cost a full slice before being understood, and neither is documented upstream:

- **`--export-3mf` is resolved relative to `--outputdir`.** Give it an absolute path and you get `/out/dir//abs/path`, which fails with `Unable to open the file` *after* the slice has completed and the G-code has been thrown away. Pass a bare filename.
- **`--export-settings` ignores `--outputdir`** and writes relative to the current directory. Give it an absolute path or it lands wherever you happened to be standing.

`--export-settings` dumps the merged configuration and is how you check that a setting really took. Do not skip it—see the presets section below for what happens when you trust the GUI instead.

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

**That first line is unreachable in this build, and reading it as an escape hatch is a mistake.** Orca-Flashforge 2.3.2 exposes no per-setting command-line flags at all—`--help` lists only structural options such as `--scale`, `--rotate` and `--load-settings`. There is no `--nozzle-temperature`. Upstream PrusaSlicer accepted generic per-setting options and the precedence text is inherited from it, but nothing here honours it.

So there is no way to override one value at the command line. The only reliable route is to change it in the profile you load, which is why `utils/slice.sh` writes overrides into a resolved profile rather than passing flags—the closest equivalent to the `-D` pattern `render.sh` and `build.sh` use with OpenSCAD, but it works by rewriting the profile, not by beating it on priority.

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
| `slow_down_layer_time` | 8 | 8 | Target minimum seconds per layer. Bounded by the next row—see below |
| `slow_down_min_speed` | **30** | 30 | How far the slicer may slow down to hit that target. Raising the target does nothing until this comes down |
| every `filament_retraction_*` | `nil` | `nil` | **Nothing overrides the machine's 0.8 mm** |

### Retraction has an upper limit set by extrusion per layer

**Long retraction starves small layers.** This is the counterweight to the stringing advice below, and it outranks it: raising `filament_retraction_length` to 1.6 mm to cure stringing caused a print to stop extruding entirely part way up a collet. The nozzle kept moving and delivered nothing.

The test is the ratio of filament retracted to filament deposited, per layer. Measured on the chalk holder's collet, where four thin fingers are four separate islands:

```text
layer   z        extruded   retracted   cycles   ratio
201     24.30     0.565      3.20         2      6:1
281     33.90     0.255      6.40         4     25:1
341     41.10     0.486      6.40         4     13:1
```

At 0.06 mm of deposit per island, four 1.6 mm retract/deretract cycles per layer with a z-hop and a wipe between them let PETG ooze down the nozzle faster than those extrusions can re-pressurize it. A print starved at 25:1 and an earlier one at 12:1; 0.4 mm brings the worst layer to 6:1.

Two things follow:

- **Retraction length is a whole-print setting with a per-region cost.** Before raising it, ask what the smallest layer in the part extrudes. Anything under a millimetre per layer is in the danger zone.
- **The real lever is usually extrusion per layer, not retraction.** Several small islands each getting one perimeter plus gap fill is the worst case; joining them into one body cuts travel count and raises deposit at the same time.

### Cooling time is capped by minimum speed, not by the target

Both cooling settings are **filament** settings even though they read like process ones—they resolve as lists, and `--set process:slow_down_layer_time=...` is rejected.

The pair works as a target and a limit. `slow_down_layer_time` asks for a minimum seconds per layer; `slow_down_min_speed` is how slowly the slicer is permitted to go to get there. **Raising the target alone achieves nothing when the limit is the binding constraint**, which it is on any small layer. Measured on the chalk holder's collet, where each layer above the collar consumes about a quarter of a millimetre of filament:

```text
layer_time 8,  min_speed 30    43m 54s     the stock pairing
layer_time 12, min_speed 5     1h 13m
layer_time 20, min_speed 5     1h 58m
```

At `min_speed` 30 those layers finish in roughly two seconds no matter what the target says. Dropping it to 5 is what lets the dwell actually happen, and the print time is the evidence that it did.

This matters for any tall thin feature that finishes after its neighbours. See `docs/_PLANS/chalk-holder-04-260810T1514Z.md` for the case that produced these numbers—a collet whose fingers failed 1.2 mm after the part beside them stopped printing.

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
2. ~~**Retraction 0.8 → 1.6–2.0 mm**~~ **Withdrawn. Do not do this.** It was the reasoning below, and it was wrong in practice: 1.6 mm ground the extruder on 2026-08-10, and the 0.4 mm correction that followed jammed it twice more. On this geometry every value of retraction length other than the stock 0.8 has produced a failed print. Leave it alone. See [STATUS.md](STATUS.md).
3. **`retract_before_wipe` 100% → 0–30%.** At 100% the retraction finishes before the wipe move starts, so the wipe cannot clear ooze. Lower it and the retraction happens *during* the wipe, depositing residue on the wall instead of trailing it through air.
4. **`reduce_crossing_wall` 0 → 1.** Currently off. It matters more for these parts than for most: the chalk holder's collet has four slots, so every layer up it crosses open space eight times. The SCAD reference makes the same point from the other direction—*"Because retractions are risky, minimize travel-heavy geometry."*
5. **Switch to `Flashforge HS PETG`** as the base profile, since that is the family the filament belongs to. Worth doing for correctness, but it only buys 10 °C of the 30 needed.

`travel_speed` is already 500 and is not worth touching.

For whatever still gets through: a brief pass with a heat gun. That is already the documented answer for wisps in the painter's pyramid artwork and it works better on PETG than picking.

<!--| PAGE-BREAK -->

## The low-string presets

Applied 2026-08-09. Two user presets, written to `~/Library/Application Support/Orca-Flashforge/user/default/`. **They are user presets deliberately**—nothing inside the app bundle was touched, so a Flash Studio update cannot clobber them and the stock profiles remain intact underneath.

**Every preset also gets a copy committed to `docs/profiles/`** in this repo—`docs/profiles/filament/` for filament, matching subfolder for process and printer. The app's `user/` tree is outside version control and one reinstall away from gone; the repo copy is the durable, diffable record. Copying there is *in addition to* writing the app's preset, never instead of it.

### Moving a preset between computers

Verified 2026-08-10 by installing the filament preset on a second machine, where it had not existed.

**A preset is two files, not one, and copying only the JSON does nothing visible.** Flash Studio enumerates user presets through a `.info` sidecar sitting beside the JSON; without it the preset simply does not appear in the dropdown, with no error and no clue as to why. Both files belong in `docs/profiles/`.

```text
~/Library/Application Support/Orca-Flashforge/user/default/filament/
├── Rapid PETG Burnt Titanium.json
└── Rapid PETG Burnt Titanium.info
```

The sidecar is four fields and a timestamp:

```text
sync_info = create
user_id =
setting_id =
base_id = GFSA04
updated_time = 1786382901
```

**`base_id` is the `setting_id` of the profile named in the JSON's `inherits`, copied verbatim.** `Flashforge HS PETG` carries `setting_id` `GFSA04`, so that is what goes here. Nothing is prefixed or derived—the resemblance to the pre-existing `Shitty PLA.info`, whose `base_id` is `OGFSA04`, is because *its* parent `Generic PLA @System` genuinely has that id. To find any parent's id, read `setting_id` out of its file in the bundle.

Two smaller things that make a user preset match the ones the GUI writes itself: `"is_custom_defined": "0"`, and no `setting_id` or `filament_id` key at all. A preset with an invented `filament_id` is not worth the risk—the known-good example has none.

`@System` is not a suffix convention to imitate. Those are the names of profiles in the separate `OrcaFilamentLibrary` set that ships alongside the Flashforge one; a Flashforge parent is named plainly, as `Flashforge HS PETG`.

Installing on a new machine, start to finish:

1. Copy both files from `docs/profiles/filament/` into the path above.
2. **Restart Flash Studio.** It reads the `user/` tree at startup.
3. Select the preset, then **verify in the G-code and not in the GUI**—`utils/gcode-probe.py` prints the commanded temperature. The whole reason this document is so emphatic on that point is recorded above.

None of this is needed to *print* correctly. `utils/slice.sh` resolves and writes settings itself and never consults a user preset, so a machine with no presets installed still produces a correct job. Installing them matters only for working in the GUI.

### `filament/Rapid PETG Burnt Titanium.json`

Inherits `Flashforge HS PETG`, which is the correct family for this filament.

| Setting | Stock | Set to | Why |
| --- | --- | --- | --- |
| `nozzle_temperature` | 265 (Pro) / 255 (HS) | **240** | The stringing cause. Inside FlashForge's own declared range for the material, which is 220–260 |
| `nozzle_temperature_initial_layer` | 255 | **245** | Slightly hotter than the body for bed adhesion |
| `filament_retraction_length` | `nil`, so the machine's 0.8 | ~~1.6~~ **reverted to stock** | Ground the extruder. So did the 0.4 that replaced it. Do not set this |
| `filament_retract_before_wipe` | `nil`, so the machine's 100% | ~~20%~~ **reverted to stock** | Rolled back with the rest of the retraction tuning |
| `filament_max_volumetric_speed` | 12 | ~~8~~ **reverted to stock** | Only ever justified as a companion to a lower temperature |

**As of 2026-08-10 this preset carries temperature and bed temperature only.** Everything else in the table above was rolled back at Ziad's instruction after three consecutive jams, none of which happened under the stock retraction values. The rollback is untested against a finished print—that test is the first item in [STATUS.md](STATUS.md).

The flow-cap argument is kept because the reasoning may hold at a lower temperature: cooler PETG cannot melt as fast, and at 0.12 mm layers and 0.42 mm width the 200 mm/s outer wall demands about 10 mm³/s, close to the stock cap of 12. Capping at 8 makes the slicer slow down rather than under-extrude. It was never shown to help here, and it was in force during two failures, so treat it as an untested idea rather than a recommendation.

Retraction belongs on the **filament** rather than the machine, if it is ever set again: setting it machine-side would apply it to PLA as well.

### `process/0.12mm Fine @AD5M Pro 0.4 - Low String.json`

Inherits `0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle`, and changes exactly one thing:

| Setting | Stock | Set to | Why |
| --- | --- | --- | --- |
| `reduce_crossing_wall` | 0 | **1** | "Avoid crossing walls." Matters more for these parts than most—the chalk holder's collet has four slots, so every layer up it crosses open space eight times |

### These presets did not work, and the reason is the point

An earlier version of this section claimed both chains were resolved and every value confirmed to land. **That was wrong, and the print that followed paid for it.** Recorded here in full because the failure mode is invisible and will happen again to anyone who trusts the GUI.

The job sliced on 2026-08-09 ran at 265 °C. Its resolved configuration, read back out of the saved project:

```text
filament_settings_id            "Rapid PETG Burnt Titanium"   the preset, selected
inherits_group                  ["", "Flashforge HS PETG", ""]  chain declared
nozzle_temperature              265        the preset's 240 absent
filament_retraction_length      nil        the preset's 1.6 absent
filament_retract_before_wipe    nil        the preset's 20% absent
filament_max_volumetric_speed   12         the preset's 8 absent
print_settings_id               "0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle"
reduce_crossing_wall            0          the process preset never selected
```

The preset file itself is correct—`docs/profiles/filament/Rapid PETG Burnt Titanium.json` has all five values properly shaped as single-element string lists. It was selected. It contributed nothing.

**The tell is that 265 cannot come from that chain at all.** `Flashforge HS PETG` sets no temperature and inherits 255 from `Flashforge Generic PETG`; only `Flashforge PETG Pro` sets 265. So the project was carrying a stale flattened configuration from when PETG Pro was selected, with the new preset's *name* attached to it. Selecting a preset in the GUI updated the label and not the values.

Three lessons, in order of usefulness:

1. **Never verify a setting by looking at the GUI.** Verify it in the G-code, which is the only artefact the printer sees. `utils/gcode-probe.py` prints the commanded temperatures and the real retraction distances for exactly this reason.
2. **A stale project is more dangerous than a wrong profile**, because every name on screen looks right. If a project has been open across a preset change, re-slice from the STL rather than the project.
3. **Prefer `utils/slice.sh` over the GUI for anything you care about.** It resolves the chain, writes the overrides into the profile, and reads the result back, so there is no step where a value can be quietly dropped.

Rollback, if the app presets need undoing: the previous `user/` tree was copied to `user_backup-manual-<timestamp>/` alongside it, so restoring that folder or deleting the two files is enough. The repo copies under `docs/profiles/` are the durable record and are not affected.

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

**⚠️ That figure does not scale up. It is a small-bore number and applying it to a large bore is wrong.** Two independent measurements on Ø54 bores: `slim-can-screwdriver-stubby.scad` records a bore drawn at 54.116 miking 53.85, a loss of **0.27**, and the `slim-can-holder-3in` fit coupon printed 2026-08-22 records one drawn at 54.00 miking 53.77, a loss of **0.23**. Neither model of the loss survives both cases—a fixed 0.60 would have taken 0.60 off the Ø54 bores and took a third of that; a proportional loss would have taken 0.04 off the Ø10 bore and took fifteen times that. The small-bore loss is first-layer squish and extrusion pull-in, which are local and roughly constant in absolute terms, so they dominate a 10 mm bore and disappear into a 54 mm one. Design a small bore against 0.60 and a large one against roughly 0.25, and measure anything in between rather than interpolating.

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

**Built, 2026-08-10.** `utils/slice.sh` drives the slice, `utils/ffprofile.py` resolves the profile chains, and `utils/gcode-probe.py` reads the job back. They export nothing to the printer. What the probe reports, and what each is for:

| Reported | Why |
| --- | --- |
| Layer count and max Z | Whether the slicer emitted the whole part. The cheap standing check, in the spirit of reading genus out of `build.sh` |
| Temperature setpoints, in order | First layer and body separately. The only place a temperature cannot hide |
| Retraction distances, totalled per event | Proves a filament-side override reached the machine |
| Extrusion roles at a given Z | Whether a thin wall became perimeters or gap fill |
| Work cliff | The layer where extrusion per layer collapses, meaning some geometry finished and whatever is left is now printing alone with no cooling interval |

Two notes for anyone extending it. Retraction is **not** one G-code move: with `retract_before_wipe` below 100% the slicer emits a pure `G1 E-n` for the portion taken before the wipe and spreads the rest across the wipe's own `G1 X.. Y.. E-..` moves, so counting only the pure move reports a 1.6 mm retraction as 1.15. And extrusion-role *segments* count `;TYPE:` blocks, not loops, so they show which roles are present rather than how many perimeters were laid.

Still not built: support verification for `parts/hobbs-painters-pyramid.scad`.

## Open items

1. ~~Does the CLI resolve `inherits` from a bare child profile?~~ **Answered 2026-08-10: no.** See "The CLI does not resolve `inherits`". A slice driven from bundle profiles silently comes out with the slicer's built-in defaults for everything the named file does not set.
2. **Is the bore tight only at its mouth?** Mike a printed bore 10 mm up from the bed and compare with the reading at the opening. If it opens up, the 0.30 mm first layer is the culprit and `hole_pull_in` is set too high.
3. **What is the real pull-in at mid-height?** Follows from item 2. Orca's tolerance test, run once for this filament, would settle it properly.
4. **Does 240 °C fix the stringing?** **240 now reaches the machine**—confirmed on the printer's own readout during the 2026-08-10 print, not just in the G-code. The stringing question itself is still open, and that print does not settle it: it is a single object, so there are few long travels, and stringing shows up most between objects. Judge it on a multi-object plate. The one region worth inspecting on a single part is the collet, whose four slots mean eight open-air crossings per layer above z 7.5.
5. **The three-perimeter question.** Partly answered, and not favourably. Above the ring's top face the collet fingers print as **one outer wall plus gap infill, with no inner wall at all**. Segment counts cannot say how many loops the outer-wall block contains, so the exact perimeter count is still open, but gap fill on a load-bearing flexing feature is already the answer to whether the 1.26 mm tip wall resolves cleanly: it does not.
6. **Does the collet survive at 240 °C?** The open question after the 6.41 mm loss. The failure begins about ten layers above the work cliff at z 34.38, where the ring finishes and the four fingers lose their cooling interval. If it fails again at 240, the next lever is cooling time rather than temperature—`slow_down_layer_time` is 8 s and this is the geometry that wants more.
