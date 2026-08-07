# AI Agent Primer: Feral SCAD Parts

**Project:** Parametric 3D-printed parts, designed in OpenSCAD, with agent assistance
**Location:** `~/www/feral/scad`
**Owner:** Ziad (Feral Creative)
**Created:** 2026-08-07

## Why this repo exists

Ziad has been designing 3D-printable parts in SketchUp for years. The archive lives in Dropbox at `/Volumes/Feral SSD/Dropbox (Personal)/_FERAL/3d`—roughly 50 project folders, 6.5 GB, mostly binary `.skp` and `.stl` files. That archive stays where it is. This repo is not a migration of it.

This repo is a deliberate change of method. OpenSCAD describes geometry as **code**, which means three things SketchUp could not offer: real version control with meaningful diffs, parts that are parametric rather than hand-drawn, and—the actual motivation—**an agent that can help design them**.

That last point is the whole premise. Ziad's specific frustrations with OpenSCAD are the ones an agent is well suited to absorb: fillets and chamfers are tedious, the BOSL2 library that fixes them has a large API surface nobody memorizes, and OpenSCAD's variable semantics surprise people with programming backgrounds. Those are lookup-and-recall problems. Hand them to the agent.

## The one rule that matters

**Never write `.scad` and hand it over without looking at a render.**

An agent writing solid geometry blind produces plausible code with wrong results: holes in the wrong face, mirrored parts, solids that were supposed to intersect and don't. The code compiles, the STL exports, and the part is garbage.

OpenSCAD renders to PNG from the command line, and you can read PNG files. So the loop is:

```bash
utils/render.sh parts/whatever.scad
```

That writes four PNGs to `renders/`—iso, front, right, top. **Read all four.** One view hides things; a tab on the wrong side is invisible head-on. Then iterate until the geometry is actually right, and only then build an STL.

Treat a render you have not looked at as work not done.

## Layout

```text
scad/
├── _AI_AGENT_PRIMER.md      # this file
├── README.md                # short human-facing summary
├── .gitignore
├── parts/                   # one .scad per design — the actual source
│   └── example-spacer.scad  # template showing house style
├── lib/                     # BOSL2 lives here, as a git submodule
├── renders/                 # generated PNGs (gitignored)
├── stl/                     # generated STLs (gitignored)
└── utils/
    ├── render.sh            # part -> multi-angle PNGs, for review
    └── build.sh             # part -> STL, optional --push to NAS
```

Scripts live in `utils/`, never `scripts/`—that is Ziad's convention across all his repos. Documentation other than `README.md` and this file belongs in a `docs/` folder if one is ever needed.

<!--| PAGE-BREAK -->

## How this connects to the printer site

Ziad runs a separate project at `~/www/feral/3d.feralcreative.co`—a web app that streams live video from his FlashForge Adventurer 5M Pro with a real-time status overlay, plus an in-browser STL viewer. It is deployed as a Docker container on his Synology NAS.

**The two repos are deliberately decoupled.** They share no code and no history. They are joined by exactly one thing: a directory on the NAS.

```text
this repo                 build.sh renders + rsyncs
    │
    ▼
NAS: /volume1/web/3d-printer-stream/public/models/*.stl
    │                     bind-mounted into the container
    ▼
3d.feralcreative.co       viewer serves them at /models
```

Two consequences worth internalizing:

- STLs are **not** tracked by git in either repo. The printer site gitignores `**/public/models/*`; this repo gitignores `stl/`. Models are build artifacts and travel by rsync, not by commit.
- Because the models directory is a bind mount, a new STL appears in the web viewer immediately. No Docker rebuild, no deploy.

`utils/build.sh --push` performs that rsync. It is opt-in for a reason—see the rules below.

## Working rules

- **Never push to the NAS without Ziad explicitly asking.** `build.sh` only rsyncs when `--push` is passed. Do not pass it on your own initiative. That target is a live production host.
- **Never run `git commit` or `git push` without explicit permission.** Hand over a single chained one-liner (`git add -A && git commit -m "type(scope): subject"`) and let Ziad run it. Conventional Commits, imperative mood, and **no AI attribution of any kind** in the message.
- **Do not investigate Ziad's machine to answer questions about his setup.** If you need to know whether something is installed or how he has something configured, ask him. It is his computer and he already knows.
- Be skeptical of your own geometry. If you are not sure a boolean did what you intended, render it and check rather than asserting it works.

## OpenSCAD notes for agents

Things that reliably bite, worth knowing before writing anything:

- **Variables are not variables.** They behave more like compile-time constants: assignment is not sequential, and within a scope the last assignment wins regardless of where it appears in the file. Do not write code that depends on reassignment.
- **Never leave subtracted faces coplanar with their parent.** A cut that stops exactly flush produces a zero-thickness wall. Overshoot it—see the `eps` pattern in `parts/example-spacer.scad`. Do this every single time.
- **`difference()` subtracts every child after the first.** Order matters; a misplaced brace silently changes the result.
- **`$fn` controls curve resolution.** Set it once at the top of a part. High values make renders slow, so keep it moderate while iterating and raise it before the final STL.
- **Preview and render are different operations.** `render.sh` produces PNGs quickly. `build.sh` runs the real mesh computation and can be genuinely slow on complex parts—do not assume it hung.
- **Read the geometry summary `build.sh` prints.** `Status: NoError` means manifold, and `Genus` counts through-holes topologically—a part with one bore should report `Genus: 1`. If you punched a hole and genus came back `0`, the cut did not go through. That is a free correctness check on every build; do not ignore it.
- **Output is manifold by construction.** Unlike SketchUp exports, OpenSCAD CSG output should not need mesh repair. The printer site has a PyMeshLab repair step for uploads; parts from here should pass through it untouched. If one does not, that is a real signal something is wrong with the geometry.

## House style for parts

Follow `parts/example-spacer.scad`:

1. Parameters at the top, grouped under `/* [Section] */` comments. Those headers are what OpenSCAD's Customizer panel reads, so grouping is functional, not decorative.
2. Every dimension a named parameter with a unit comment. No bare numbers buried in geometry.
3. Geometry inside a named `module`, with a single call at the bottom.
4. One part per file, named after the part.

`build.sh` and `render.sh` both accept `-D 'name=value'` to override any top-level parameter without editing the file, which is the fast way to compare variants.

## Current state

The toolchain is set up and verified end to end. No real parts exist yet—`parts/example-spacer.scad` is a template, not a design.

- **OpenSCAD 2026.06.12** is installed at `/Applications/OpenSCAD.app`. It is *not* on `PATH`; both scripts fall back to `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`, which is the path that actually gets used. The CLI cannot be extracted from the bundle—it resolves 58 dylibs through `@rpath` internally—so a second machine needs its own install.
- **BOSL2 is installed** as a git submodule at `lib/BOSL2` (v2.0.747). Clone with `--recurse-submodules`. Use it for rounding, chamfering, and attachment rather than fighting `minkowski()`.
- **`include <BOSL2/std.scad>` works only through the scripts.** `lib/` is not a directory OpenSCAD searches, so `render.sh` and `build.sh` export `OPENSCADPATH` pointing at it. Invoking the `openscad` binary directly, outside those scripts, will fail to resolve the include.
- **The camera flags are verified.** `--camera`, `--projection`, `--viewall`, and `--autocenter` all behave as written on 2026.06.12. This was checked with a deliberately asymmetric test rig, because the example spacer is rotationally symmetric and its front and right views are pixel-identical whether the flags work or not. If you ever re-verify this, do not use a symmetric part.
- **The three elevations render orthographic**, so they read as true drawings; iso stays perspective as an overview.
- **STLs export as ASCII**, which is OpenSCAD's default. `--export-format=binstl` produces much smaller files if that ever matters for the web viewer.

## Possible future work

Discussed and deliberately deferred, recorded so it is not re-litigated from scratch:

A **web configurator**—browse a library of finished parts, adjust parameters with sliders, render a preview, and send straight to the printer. This would live in the `3d.feralcreative.co` repo, not here, because that project already has the auth tiers, the printer upload endpoint, the STL viewer, and the container. The marginal cost there is low; here it would be a rewrite.

It was deferred for a good reason: a configurator is a layer over a parts library, and the library does not exist yet. Build ten real parts first, then see whether the itch is real.

If it does get built, one constraint is non-negotiable: **accept parameters only, never user-supplied `.scad` source.** OpenSCAD can read files via `include<>`, `import()`, and `surface()`, and the printer container runs with `network_mode: host` so it can reach the printer on the LAN. Executing arbitrary submitted source in that container would expose the whole home network.

Separately, `scad.feralcreative.co` is intentionally unused as a name. If a public gallery of designs ever gets built, that domain is reserved for it—which is why this repo is plain `scad` and not domain-shaped.
