# Printer Profile Research Prompt

A reusable prompt for generating a machine-specific design reference that an OpenSCAD (or any CAD) agent can consume as context.

Run it once per printer. You get back a document containing that machine's specs, hard design constants, tolerances, material envelope, known defects, and the community's accumulated knowledge — with a citation on every figure.

**Companion file:** `flashforge-ad5m-pro-scad-reference.md` is the output this prompt produced for a FlashForge Adventurer 5M Pro. Use it as the reference implementation.

---

## Contents

1. [Why this exists](#1-why-this-exists)
2. [How to use it](#2-how-to-use-it)
3. [The prompt](#3-the-prompt)
4. [Why the prompt is shaped this way](#4-why-the-prompt-is-shaped-this-way)
5. [Adapting it](#5-adapting-it)
6. [Appendix: the original prompt](#appendix-the-original-prompt)

---

## 1. Why this exists

A CAD agent with no machine context produces geometry that is *technically valid and practically unprintable*: 2 mm walls that don't divide into the extrusion width, `$fn=200` on every cylinder, press fits toleranced for a printer that doesn't exist, unsupported 70° overhangs, and features that assume dissolvable support on a single-extruder machine.

Almost none of that is fixable in the slicer. It has to be designed in.

The information that prevents it is real, public, and scattered across manufacturer PDFs, slicer profile JSONs, firmware config files, forum threads, and model-sharing comment sections. Nobody has assembled it per-machine. This prompt does that assembly, once, into a file your agent can read.

---

## 2. How to use it

1. Fill in the `MACHINE PROFILE` block at the top of the prompt with your hardware.
2. Paste the whole thing into an agent that has web search, web fetch, subagents, and file write. (Claude Code, Cowork, or any comparable harness.)
3. Expect it to run for a while. The reference implementation took three parallel research agents plus a verification agent, ~100 tool calls, and produced 677 lines with 202 citations.
4. Commit the output next to your `.scad` files and reference it from your agent's system prompt, `CLAUDE.md`, or skill definition.

**Cost note.** This is a heavy, one-time research job. It is not something to re-run casually — but it is worth re-running when you change nozzles, add a build plate, or flash different firmware, since those change the design constants.

---

## 3. The prompt

Copy everything inside the block.

````markdown
# TASK: Build a machine-specific design reference for a 3D printer

## MACHINE PROFILE — fill this in before running

- **Printer:** <make, model, exact variant — e.g. "FlashForge Adventurer 5M Pro">
- **Nozzles owned:** <sizes, and what you use each one for>
- **Build plates owned:** <type and quantity — e.g. "2 × textured PEI, 1 × smooth PEI">
- **Materials used or intended:** <list, or "everything the printer supports">
- **Slicer:** <e.g. OrcaSlicer / PrusaSlicer / Bambu Studio / vendor slicer>
- **Firmware state:** <stock, or which community mod and version>
- **Enclosure / filtration / chamber heating:** <as applicable>
- **Anything unusual:** <third-party hotend, modified fans, custom plate, etc.>

## ROLE

You are a research agent. Your output is a reference document consumed by **an AI agent that generates parametric CAD (OpenSCAD) models** for the machine above.

You are not writing a review, a buyer's guide, or a tutorial. You are writing the **constraint set** that geometry must satisfy to print successfully on this specific machine, with these specific nozzles, on these specific plates, in these specific materials.

The test of every sentence: *does this change what the model should look like, or how the user should be advised?* If not, cut it.

## NON-GOALS

- No generic 3D printing advice. The consuming agent already knows what an overhang is. Only machine-specific facts.
- No purchase recommendations, unless the purchase changes a design constraint (e.g. a hotend that raises the temperature ceiling and therefore unlocks a material).
- No marketing language. Where a manufacturer claim conflicts with an independent measurement, report both and say which to design around.
- No padding, no hedging prose, no summary-of-the-summary sections.

## METHOD — follow this order

### Step 1 — Run three research streams in parallel

Dispatch these as concurrent subagents. Do not run them sequentially; they are independent.

**Stream A — Official specifications.** Build volume and any usable-area caveats; nozzle and bed temperature ceilings; claimed flow rate; speeds and accelerations; motion system and kinematics; extruder type and drive; bed levelling mechanism and mesh density; firmware base, version history, and release notes; every nozzle and build plate the manufacturer sells, with materials and temperature ratings; enclosure, chamber temperature, and filtration; sensors, recovery features, connectivity; cooling fan inventory; power and noise ratings; differences between this model and its siblings; successor models.

**Stream B — Community reality.** What owners praise, in specifics. Then, exhaustively: first-layer and levelling problems; build plate failures; clogging and heat-creep patterns; nozzle-swap failures; part cooling adequacy; ringing, banding, layer shifts; dimensional accuracy reports including any measured expansion or shrinkage values; firmware bugs and error codes; reliability over time and what breaks first; support experiences; safety issues or recalls. Then, most importantly: **idiosyncrasies that change how someone should design parts** — bad regions of the bed, behaviour with tall thin parts, small-detail capability per nozzle, reported clearance values that actually work, model placement constraints.

**Stream C — Mods, slicer profiles, and materials.** Popular printable mods ranked by download count, with what each fixes; hardware upgrades people actually buy and their reported success rates; firmware mods and what each unlocks; **exact slicer profile values per nozzle size** (layer heights, line widths, max volumetric speed, speeds, accelerations, retraction, pressure advance, compensations); per-material temperatures, plates, and failure modes for every material the machine supports and the notable ones it doesn't.

Give every stream this instruction verbatim: **every claim must carry a source URL, attached to the claim it supports.**

### Step 2 — Search the source hierarchy, in this order

**Tier 1 — Manufacturer primary sources.** Product page spec table, downloadable datasheet PDF, the user manual PDF, the official wiki, troubleshooting and error-code pages, maintenance procedures, firmware release notes, and the manufacturer's own GitHub organisation.

**Tier 2 — The two overlooked goldmines. Search these explicitly; they are where the usable numbers live.**

- **Slicer vendor profile JSONs.** OrcaSlicer's repository carries manufacturer-authored profiles at `resources/profiles/<Vendor>/` split into `machine/`, `process/`, and `filament/`. These contain exact line widths, layer height ranges, retraction lengths, per-axis accelerations and jerk, max volumetric speed, pressure advance, flow ratio, elephant-foot compensation, support gaps, and arc-fitting flags — per nozzle size and per material. **This is the single richest source of design constants and it is almost never cited.** PrusaSlicer and Bambu Studio ship equivalent vendor bundles. Read the raw JSON, follow the `inherits` chain, and note where a profile lazily inherits values that don't suit its nozzle.
- **Community firmware mod repositories.** For any Klipper-based machine, the mod projects publish the real `printer.cfg` / `printer.base.cfg`. That file states kinematics, stepper currents, microsteps, mesh probe count and bounds, probe type, temperature ceilings, input shaper values, fan inventory and pin assignments, and firmware retraction — facts the manufacturer never publishes. Their `FAQ.md` and `CALIBRATION.md` are usually the most candid account of the machine's real limits in existence, including which behaviours are unfixable. Also read their macro files: purge, wipe, and levelling routines reveal exactly which regions of the bed are consumed before every print.

**Tier 3 — Independent reviews with instrumentation.** Prefer reviewers who metered something. Note every case where a measurement contradicts a manufacturer claim.

**Tier 4 — Community discussion.** Owner forums, subreddits, model-sharing site comments, GitHub issues and discussions. On model-sharing sites, **download and like counts are your signal strength metric** — a fix with 6,000 downloads describes a real defect; one with 12 describes a preference.

**Tier 5 — Aggregators and SEO content.** Cite only when nothing better exists, and label as second-hand. Discard any page whose stated specs contradict Tier 1.

### Step 3 — Tag every claim with its evidence class

Use these markers throughout the output. The consuming agent needs to know what it can rely on.

| Marker | Meaning |
|---|---|
| `[SPEC]` | Manufacturer or firmware-config fact. Hard constraint. |
| `[FIELD]` | Reported by owners or reviewers. Reliable but not guaranteed. |
| `[DERIVED]` | Arithmetic you performed from `[SPEC]` values. Correct math, not machine-confirmed. |
| `⚠️` | Contested, unverified, or a known gap. Flag rather than design around it. |

### Step 4 — Derive the design constants

**Do not stop at reporting specs.** The value of this document is in the arithmetic that turns specs into geometry rules. Compute all of the following, show the formula, and mark the results `[DERIVED]`:

1. **Wall thickness ladder per nozzle.** Integer multiples of that nozzle's line width, for 2/3/4/5/6/8 perimeters. Wall thicknesses that aren't multiples of line width produce gaps or over-extrusion. State the minimum structural wall (2 perimeters) and the absolute minimum printable feature.
2. **Flow-capped real speed per material and nozzle.** `v_max = MVS ÷ (layer_height × line_width)`. Compare against what the profile claims. On most fast printers the headline speed is fiction for everything except PLA — surface that.
3. **Safe build envelope.** Start from the nominal volume, then subtract: the purge/prime line region, the nozzle-wipe region, any pre-print probe location, and any area outside the measured bed mesh. Read these coordinates out of the firmware macro files, not the marketing copy.
4. **Clearance ladder per nozzle** — press / snug / free / print-in-place. Anchor to any real-world datapoint you found (a widely-downloaded "this hinge fuses shut" fix is a real measurement of the machine's floor).
5. **Faceting rules for OpenSCAD.** Facet count for a target chord error: `n = ceil(180 / acos(1 - e/r))`. Hole circumscription, because OpenSCAD polygons are inscribed and holes therefore come out undersized before any printing effect: `r_circumscribed = r / cos(180/n)`. Match chord error to nozzle size, and never finer than the slicer's own `resolution` value — geometry below that is discarded anyway.
6. **First-layer deltas.** If the machine has multiple plate types, quantify how much the effective squish differs between them and state which dimensions that puts at risk.
7. **Controller/firmware limits that constrain geometry.** If the machine has a documented move-queue, memory, or processing limit, treat it as a first-class design constraint and say exactly which geometry provokes it.

Verify every calculation programmatically. Do not do this arithmetic by hand.

### Step 5 — Verification pass (mandatory)

Dispatch a **separate** agent with no memory of the research. Give it the finished claims and have it independently re-check, against primary sources:

- every headline specification
- every slicer profile value quoted
- every derived calculation
- any claim that a material is or isn't supported

It must return CONFIRMED / CONTRADICTED / COULD NOT VERIFY per claim, with the URL it used, and explicitly flag anything it found to be **wrong**.

Fold the corrections in. Then state in the document that a verification pass was run, and list what remained open after it.

This step is not optional and it is not ceremonial. In the reference implementation it caught four real errors, including one manufacturer instruction that had been recorded backwards and one widely-repeated threshold with no primary source behind it.

## REQUIRED OUTPUT STRUCTURE

A single markdown file. Sections, in order:

0. **How to use this document** — the evidence taxonomy table, and the machine's design priority order (what to optimise first, and what to sacrifice).
1. **Machine identity card** — one table, every headline spec, one source per row.
2. **Build envelope** — the zones table (purge strip, wipe strip, unprobed border, probe point), plus the derived safe envelope and any placement rules.
3. **The nozzles** — what each is for, materials, temperature ratings, and the operational consequences of swapping.
4. **Per-nozzle design constants** — machine-level slicer settings, the per-nozzle geometry table, the derived wall-thickness ladder, and derived flow-capped speeds.
5. **Dimensional accuracy, tolerance and fit** — what's actually known, what isn't, the dominant fit-killer, and the clearance ladder.
6. **The binding constraint** — whatever this machine's real bottleneck is (controller, cooling, flow, rigidity), and the CAD rules that follow directly from it. Include copy-pasteable helper functions.
7. **Overhangs, bridges, supports** — with numbers, and with any enclosure/thermal interaction.
8. **Build plates** — one row per plate the user owns, with the design consequences of each.
9. **Materials matrix** — official slicer values table, then a per-material verdict table with design implications, including explicit ❌ verdicts for unsupported materials and why.
10. **Deep-dive on the user's stated primary use case** — the specific nozzle/material combination they named.
11. **Known weaknesses that should change designs** — ranked by design impact, not by severity.
12. **Mods and upgrades** — printable mods ranked by adoption; hardware upgrades with evidence quality noted.
13. **Firmware landscape** — brief, and only insofar as it changes design constraints.
14. **Copy-paste constants block** — working code the consuming agent can drop into a model. Parameterise on nozzle size so one variable change propagates.
15. **Pre-flight checklist** — checkboxes the agent verifies before returning any model.
16. **Open questions** — what stayed unverified, so the agent flags rather than guesses.
17. **Sources** — grouped by category.

## FAILURE MODES — avoid these specifically

- **Never invent a number.** "No published value exists for this" is a valid, valuable finding. If you catch yourself producing a plausible-sounding tolerance figure with no source, stop and mark it ⚠️ instead.
- **Never average conflicting sources.** Report the conflict, name the most authoritative source, and say which value to design against. A spec that appears as 100/105/110/130 across four sources is itself an important finding.
- **Check every performance claim against an independent measurement.** Noise ratings, flow rates, and maximum speeds are the usual offenders.
- **Distinguish manufacturer guidance from community convention.** "This material needs a 0.6 nozzle" is often a retailer's recommendation that the material's own datasheet contradicts. Say which is which.
- **If a source is blocked or unreachable, say so in the output.** Silently omitting a major community source is worse than noting the gap. If a subagent reports a domain is inaccessible, do not route around it with shell tools or alternative fetchers — record the limitation.
- **Subagent outputs may exceed return limits.** Instruct research subagents to write long findings to a file and return the path plus a summary, rather than returning the full text.
- **Do not read output-format skills or templates until research is complete.** Gather facts first; format last.
- **Resolve which value the *consuming agent* should use.** Every ⚠️ should end with an instruction — "flag to the user," "use X until tested," "refuse and explain."

## DONE CRITERIA

- [ ] Every figure has an inline source link.
- [ ] Every claim carries an evidence marker.
- [ ] All seven derivation categories in Step 4 are present, with formulas shown.
- [ ] All arithmetic was verified programmatically.
- [ ] An independent verification pass ran, and its corrections are folded in.
- [ ] The constants block is syntactically valid and parameterised on nozzle size.
- [ ] Unsupported materials carry explicit ❌ verdicts with reasons.
- [ ] Open questions are listed rather than papered over.
- [ ] No section restates another section.
````

---

## 4. Why the prompt is shaped this way

Notes for anyone modifying it.

**Parallel streams, not one big search.** Specs, sentiment, and slicer/material data live in disjoint corners of the web and reward different search strategies. Run serially, they take three times as long and the later streams get anchored on the earlier ones' framing.

**The slicer profile repos are the highest-leverage instruction in the prompt.** Manufacturers publish vague marketing specs and precise slicer profiles. The profiles are on GitHub, are machine-readable, and contain exactly the numbers a CAD agent needs — line widths, compensations, volumetric limits. Without an explicit instruction, agents don't think to look there.

**Firmware mod repos are the second.** A community `printer.cfg` is a hardware teardown in text form. Their FAQ files also tend to state, plainly, which of the machine's problems are unfixable — something no manufacturer document will ever say.

**The evidence taxonomy exists because the consuming agent needs to know when to hedge.** A CAD agent that treats a forum anecdote and a firmware constant as equally authoritative will confidently produce a part toleranced against folklore. Four markers is enough; more gets ignored.

**Derivation is the whole point.** "Line width is 0.42 mm" is a fact. "Therefore your wall thicknesses are 0.84 / 1.26 / 1.68 / 2.10 and 2 mm is a bad number" is a design rule. Reporting without deriving produces a document that reads well and changes nothing.

**Verification is mandatory because research agents produce confident, plausible, wrong numbers.** The reference run caught a manufacturer instruction recorded backwards and a widely-repeated file-size threshold with no primary source. Both would have survived any amount of re-reading by the agent that wrote them. It has to be a fresh agent.

**The "failure modes" section is load-bearing.** Most of it exists because something went wrong on the reference run. Keep it, and add to it when your own runs go sideways.

---

## 5. Adapting it

**Other FDM printers.** Works as-is. Fill in the machine profile block and run.

**Multi-material / AMS-style machines.** Add a stream question about purge waste, tool-change reliability, and per-filament purge volumes — these change whether a multi-colour design is economically sane, which is a design decision.

**Resin (MSLA).** Replace the nozzle/extrusion sections wholesale. The equivalent constants are pixel pitch and XY resolution, layer height range, anti-aliasing behaviour, lift speed and suction forces, cross-sectional area limits, drain hole and hollow-wall minimums, supports and orientation, and cure-shrinkage compensation. The method — source hierarchy, evidence taxonomy, derivation, verification — transfers unchanged.

**CNC / laser.** The structure transfers; the derivations don't. Replace Step 4 with tool-diameter-driven internal corner radii, feeds and speeds, workholding envelope, and kerf compensation.

**Non-CAD consuming agents.** If the consumer is a slicer-settings assistant rather than a CAD agent, keep sections 1–5 and 9–17 and drop the OpenSCAD-specific material in 6 and 14.

**Keeping it current.** Firmware updates change real constraints — one update on the reference machine added a mandatory pre-print probe at bed centre. Re-run the verification pass, not the whole research job, when firmware changes.

---

## Appendix: the original prompt

Preserved for provenance. The version above is this, made explicit — same intent, with the method, source hierarchy, evidence rules, derivation requirements, output structure, and verification step spelled out rather than left for the agent to infer.

> I need you to do some deep research for my SCAD agent. Specifically, I have a FlashForge Adventurer 5M Pro with two textured plates and one smooth one. I have a 0.25mm nozzle, 0.4 that's my workhorse, 0.6 for Wood + PLA, and a 0.8 I've used to print large things more quickly. What I need you to do is search the internet for manuals, specifications, forum chat about the printer. When designing objects for 3d printing, I want my SCAD agent to know everything possible about my printer and take it into account in my designs—the printer's general specs, strengths, weaknesses, idiosyncrasies, what people love and hate about it, and what are the most popular mods and upgrades people have done.

**What the original got right, and the template preserves:** naming the consuming agent up front; listing the exact hardware inventory including what each nozzle is *for*; asking for weaknesses and idiosyncrasies rather than just specs; asking what people *hate*, which is where the design-relevant defects hide.

**What it left implicit, and the template makes explicit:** the parallel research structure; the slicer-profile and firmware-config source tiers; per-claim citation; the evidence taxonomy; the requirement to derive design constants rather than report specs; the output structure; the verification pass; and the instruction to say "unknown" rather than produce a plausible number.
