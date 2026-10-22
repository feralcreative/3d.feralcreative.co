# NACS plug holder with spring latch

Source: [nacs-plug-holder.scad](../nacs-plug-holder.scad). Replaces the imported ImBain holder (`Tesla_Charger_Holder.stl`), which Ziad found insecure.

## Why the old holder lets go

The plug hangs nose-up at about 41°, so its weight pulls it outward and only a fixed 5 mm bump holds it. A fixed bump only works in a loose pocket, because the plug has to lift over it on the way in: that holder's bore is 46.5 × 40.7 mm against a 40.4 × 35.7 mm nose, about 5.5 mm of headroom, which is exactly what lets it lift back off. A taller bump needs more headroom, so it cannot help. The bump is also taller than the 4 mm-deep pocket it sits in.

## Design

The bore is snug, 0.4 mm per side, and the hold comes from a printed cantilever arm in the floor whose tooth snaps into the connector's own latch pocket, the same pocket the car's latch pin engages. The plug hangs nose-up at 45°, with the cable hanging naturally.

| Feature | Value | Source |
| --- | --- | --- |
| Bore outline | Inlet cavity 45 mm in, mirrored for symmetry, plus 0.4 mm | `TS-0011139_INLET` solid in `NACS to CCS Adapter v8.step` (MacheForum, unverified third-party model) |
| Latch pocket | 9.71 wide, 6.2 long, 4 deep, ±0.2 | Tesla NACS Technical Specification TS-0023666 (2022), pp. 24–25 |
| Pocket position | 20.2 mm behind the plug face (spec); 21.0 mm (STEP latch window) | Both; the tooth is self-locating, so either works |
| Tooth | 2.2 mm engagement, 65° holding face, 35° lead-in, 8 mm wide | Design |
| Arm | 9 mm wide, tapering from 5.0 mm at the root to 3.0 mm at the tooth, 1.5 mm fillets in both root corners, rooted 10 mm behind the stop, about 30 mm from root to tooth, about 34 N at the tooth and 1.3% nominal root strain at full deflection | Design |
| Shell | 5.5 mm around the bore and under the latch slot: 3 mm `wall` plus 2.5 mm `skin` (2026-10-21). `skin` thickens only the outside; the bore, latch, slot and screws do not move relative to the wall, and the extra behind the wall face is cut off | Design |

The arm is deflection-controlled: the tooth always moves 2.2 mm, so for a given force the root strain depends on how long the arm is and how the bend is spread along it. A longer arm, thicker in proportion, gives more force at the same strain; the taper thins the outer arm so it takes more of the bend, and the fillets remove the square inside corners that roughly doubled or tripled the peak. The arm cannot get wider: the screw channels clear the slot by 0.9 mm.

The first print (2026-10-18) fitted perfectly and seated with a click, but the arm, 2.6 to 1.4 mm on a 4 mm root, made 8.7 N at the tooth and gave no hold at all; the plug fell out as if there were no latch. Beam theory had promised a 30–45 N release, so treat release-force estimates here as optimistic by a wide margin, most likely because the pocket edge is rounded and the tooth bites less than its face angle suggests. The current arm makes about four times the force, and the holding face was steepened from 60° to 65° (2026-10-21), which roughly doubles the pull needed to cam the arm out at a PETG friction coefficient of about 0.35. It becomes self-locking near 70°, where the plug could only come out by lifting the arm by hand, so 65° leaves a margin for the friction being higher than assumed. If the plug is now hard to pull out, go back toward 62°.

The top of the bore is relieved past 36 mm and the floor past 48 mm, where the NACS spec's section A-A shows the handle starting to flare. Those depths are read off a drawing, not measured.

## Name

"Charlotte" in Gwendolyn Bold is debossed 0.8 mm into the sloping top face and reads from in front of the wall. It wraps around the curve of the face rather than being projected onto it, 46 mm along its baseline, and the baseline arcs parallel to the rim of the mouth below, dropping 6.4 mm at the ends with each letter turned square to it. It is tapered at 70° in five bands like the chalk holder's wordmark, so nothing in the cut needs support. Gwendolyn's hairlines would be about 0.4 mm at this size, too thin for a 0.4 nozzle to cut, so every stroke is swelled 0.15 mm (`name_swell`); the thinnest joins still go shallow as the taper narrows them. The cut is wrapped in `render()`: its hundreds of strip intersections otherwise overflow the OpenSCAD preview, which then draws nothing at all. Change `name_text` to rename it, or set it to `""` to leave the face plain.

The font is vendored at `logos/fonts/Gwendolyn-Bold.ttf` and loaded with `use <>`, so the build does not depend on installed fonts. Gwendolyn is by The Gwendolyn Project Authors, SIL Open Font License 1.1, from Google Fonts.

## Printing

Print with the wall face on the bed. No supports: every downward-facing surface is at 45° or steeper, and nothing starts in mid-air. The arm is rooted at its low end, behind the stop, so it grows up from the body; the first version was rooted toward the mouth, its free end began as an island, and the slicer asked for supports inside the latch slot. The arm prints as a 45° slab, so its bending runs diagonally across layers. PETG is the intended material.

Print the fit coupon first: `utils/build.sh library/automotive/tesla-charger-holder/nacs-plug-holder.scad -D 'show="coupon"' --name nacs-plug-holder-fit-coupon`. It is a 10 mm sleeve of the bore, with a tab on the latch side. The plug nose should slide through it with no force and almost no wobble. Adjust `plug_clearance` before printing the holder.

## Mounting

Two #8 / 4 mm countersunk wood screws, sunk inside the body and side by side, 22 mm apart, in the bottom of the plug stop. With the plug out, drive them straight in through the bore, down 10 mm channels; 6 mm of plastic is clamped under each head. They sit at the upper end of the body, where they best resist the hanging handle trying to peel the holder off the wall.

## Not verified

Printed once, 2026-10-18, with the 8.7 N arm: bore fit perfect, latch engages, hold nil. The stiffer arm, its release force, its fatigue life, and the handle-flare clearance are not yet verified.
