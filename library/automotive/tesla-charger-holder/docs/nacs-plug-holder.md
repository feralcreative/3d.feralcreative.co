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
| Tooth | 2.2 mm engagement, 60° holding face, 35° lead-in, 8 mm wide | Design |
| Arm | 9 × 2.2 mm, about 24 mm from root to tooth, 1.2% strain at full deflection | Design |

Estimated release force, from beam theory with E ≈ 2000 MPa and μ 0.3–0.4, is 30–45 N, about a firm one-handed tug. The insertion force is about 8 N. These are estimates; `hold_angle` is the knob if it holds too hard or too loosely. Steeper holds harder and becomes self-locking near 60° with high friction.

The top of the bore is relieved past 36 mm and the floor past 48 mm, where the NACS spec's section A-A shows the handle starting to flare. Those depths are read off a drawing, not measured.

## Printing

Print with the wall face on the bed. No supports: every downward-facing surface is at 45° or steeper. The arm prints as a 45° slab, so its bending runs diagonally across layers. PETG is the intended material.

Print the fit coupon first: `utils/build.sh library/automotive/tesla-charger-holder/nacs-plug-holder.scad -D 'show="coupon"' --name nacs-plug-holder-fit-coupon`. It is a 10 mm sleeve of the bore, with a tab on the latch side. The plug nose should slide through it with no force and almost no wobble. Adjust `plug_clearance` before printing the holder.

## Mounting

Two #8 / 4 mm countersunk wood screws, above and below the body, driven straight in from the front.

## Not verified

No part of this has been printed. Bore fit, latch engagement, release force, arm fatigue life, and the handle-flare clearance all need a physical check.
