# Decisions

Why things are the way they are, so a later agent does not "fix" a deliberate choice.

## OpenSCAD instead of SketchUp

Ziad designed printable parts in SketchUp for years; the archive (roughly 50 project folders, 6.5 GB of `.skp` and `.stl`) stays in Dropbox and is not migrated. OpenSCAD was adopted for three things SketchUp could not give: real version control with meaningful diffs, parametric rather than hand-drawn parts, and—the actual motivation—an agent that can help design them. The frustrations that motivated it are lookup-and-recall problems suited to an agent: fillets and chamfers are tedious, BOSL2's API surface is too large to memorize, and OpenSCAD's variable semantics surprise people with programming backgrounds.

## BOSL2 as a submodule, not vendored

Pinned at v2.0.747 and pulled with `--recurse-submodules`. Rejected: vendoring a plain clone (the `.gitignore` keeps a commented-out line for that if it is ever wanted), and fighting `minkowski()` for rounding instead of using a library.

## `logos/marks.scad` instead of `import()` in parts

Three failure modes, each of which had already happened:

- **Tessellation.** OpenSCAD's SVG importer honours `$fn` and ignores `$fa`/`$fs` outright, so artwork silently inherits the part's resolution. At `$fn = 64` the Hobbs mark cost 39,808 triangles against the importer's own floor of 12,532, for an outline landing around 0.03 mm at print size either way. Every module pins `$fn = 0` over its own import, so the mark gets no vote on the part's curves and the part none on the mark's.
- **Paths.** A relative path inside `import()` resolves against the file the statement is written in. Keeping imports next to the SVGs is what makes them resolve from anywhere—and it matters because a missing import prints an ERROR and then exits 0, so the build succeeds and hands you a part with no artwork.
- **Registration.** The Hobbs figure and wordmark are separate files because the pyramid cuts one through the wall and raises the other. They stay aligned only because both are scaled and centred against the bounding box of the *pair*, which the library does for you.

Native sizes are measured off OpenSCAD's own import rather than read off the SVG `viewBox`, because the two disagree—the importer works in millimetres at 96 dpi and the artwork carries its own whitespace. Remeasure if a file is replaced.

## Scanned meshes come in as shells, split first

A scanned STL is often several closed shells in one file—a head with the eyes dropped on as spheres—and `import()` keeps them that way. Every boolean on that import leaves the overlaps in: negative genus, the overlapped volume counted twice, internal faces for the slicer to guess about. Unioning the file with itself does not fix it; coincident faces are degenerate for an exact boolean and the result was worse than the input (genus 980 on the fish koozie). So `utils/stl-shells.py` writes one file per shell and the part imports them as separate `union()` operands, which Manifold resolves cleanly. The shell count lives in the part as a parameter because a missing shell file is a warning and exit 0. Decided 2026-09-16 on `fish-koozie-12oz.scad`.

## A derivative of an ND-licensed model stays private

The fish koozie is CC BY-NC-ND. Reboring it for a different can is a derivative, which the licence permits for private use and forbids sharing. The `.scad` is committed—it carries numbers and no mesh—and the source mesh stays in `_incoming/`, uncommitted. The built STL is not committed either, even though the repo is private and `stl/*.stl` normally is: it is an 8 MB derivative that rebuilds in a second, and a copy on GitHub is a copy on someone else's server. It does not go to Printables, the NAS viewer, or `--push`. Decided 2026-09-16.

## Big parts are sectioned with dovetails printed on the sections

The heater stand's edge is 500 mm on a bed that probes 210. Three equal sections, the joints locked by dovetail tabs printed on the centre piece and sockets in the end pieces—no loose keys, no rails—because that is the fewest parts and nothing can go missing. The tabs sit low on the end faces, where a trapezoid block's shoulders are widest, and the sockets open at the underside with a 45-degree pyramid roof, so a piece is lifted over the tab and lowered on, nothing shows once it is down, and nothing bridges in the print. Ziad's choices, 2026-09-16, from four alternatives put to him.

## Binary STL by default

OpenSCAD defaults to ASCII, which is the same geometry at roughly seven times the size: a part carrying artwork ran 63 MB ASCII and 11 MB binary, which is slow to rsync and worse to open in the web viewer. `build.sh` passes `--export-format=binstl`; `--ascii` is there for reading or diffing a mesh by eye.

## `ffprofile.py` resolves inheritance instead of pointing the CLI at profiles

Flash Studio profiles are thin overlays: a file sets two or three keys and names a parent in `inherits`, matched by the parent's `name` field rather than its filename. The GUI walks that chain; the CLI does not. Verified 2026-08-10: slicing from the bundle's own PETG Pro profile produced `filament_type` PLA, `filament_max_volumetric_speed` 2 and `outer_wall_line_width` 0. So the chain is walked here, child merged over parent, `inherits` stripped, and only `inherits` stripped—`instantiation`, `setting_id` and `is_custom_defined` look like bookkeeping but removing them changes behaviour. Overrides are type-preserving by matching the shape the resolved value already has: filament settings are single-element lists of strings (`["240"]`), process settings are bare scalars, and writing the wrong shape is a good way to have a value ignored silently.

## Presets are the single source of truth, not script defaults

`utils/slice.sh` used to default to the stock parent profiles and paste a hardcoded `LOW_STRING` array of `--set` overrides on top. Because command-line overrides outrank presets, that array silently beat everything in `docs/profiles/`, carrying retraction 1.6 mm—the value that ground the extruder—for hours after the preset had been corrected to 0.4. It now defaults to the repo's own presets and passes only what the caller asks for on that invocation. If a convenient set of defaults is wanted, it goes in a preset.

## Verify in G-code, never in the GUI

On 2026-08-09 a correct user filament preset was written, correctly selected, and contributed nothing to the sliced job: the project kept a stale configuration, the print ran 25 °C too hot, and it cost the top 6.41 mm of a collet. The G-code is the only artefact the printer sees, so it is the only place a setting is real. `gcode-probe.py` exists for exactly that, one figure per past failure.

## Rolled back the retraction tuning, kept one process change

The 2026-08-10 rollback returned `Rapid PETG Burnt Titanium.json` to temperature-only, dropping retraction length and speeds, retract-before-wipe, retract-when-changing-layer, minimum travel, the volumetric flow cap and the slow-down pair. The `0.12mm Fine @AD5M Pro 0.4 - Low String` process preset was kept because it only sets `reduce_crossing_wall` and was in effect during a print that completed—a judgement call, and the one surviving change. Full account in [STATUS.md](STATUS.md).

## Chalk holder sizing is mechanism, not styling

The clamping stroke can never exceed the collet's length, so wanting 1.8 turns of stroke forces a 16 mm collet, which forces a bigger thread under it to keep the finger roots thick, which forces a bigger barrel around that. Stroke is spent out of thread engagement and there are 2.9 turns to spend. The legacy pair squeezed 0.66 mm over half a turn with a bore that printed around 9.47 mm, so a 9.50 mm stick was shaved on the way in and there was nothing left to take up—one defect, two symptoms.

Parameter names in merged part files are prefixed per sub-assembly because OpenSCAD has no namespaces and no scoping for top-level assignments: the two source files each defined `collar_d`, `thread_depth` and a dozen other names with different values.

## Deferred: a web configurator

Discussed and deliberately deferred. It would live in the `3d.feralcreative.co` repo, which already has the auth tiers, the printer upload endpoint, the STL viewer and the container; here it would be a rewrite. Deferred because a configurator is a layer over a parts library and the library does not exist yet—build ten real parts first.

One constraint is non-negotiable if it is ever built: **accept parameters only, never user-supplied `.scad` source.** OpenSCAD can read files via `include<>`, `import()` and `surface()`, and the printer container runs with `network_mode: host` to reach the printer on the LAN, so executing submitted source there would expose the whole home network.

## Reserved: `scad.feralcreative.co`

Intentionally unused. If a public gallery of designs is ever built, that domain is for it—which is why this repo is plain `scad` and not domain-shaped.
