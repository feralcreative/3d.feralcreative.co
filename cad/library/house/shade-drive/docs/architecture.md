# Shade drive—architecture and open decisions

Started October 15, 2026, from the design brief at `_PLANS/shade-drive-design-brief-2026-10-15.md` (local only). Updated October 16, 2026, after the chain was measured and the bought parts were chosen in `~/www/ezzat/home.ezzat.com/docs/shade-drive-plan.md`, which is the source of truth for parts and decisions and supersedes the brief's "motor not selected" items. This file holds only what the geometry needs.

## What exists

`shade-drive.scad` holds the sprocket, a pocket-clearance coupon, reference geometry for every bought part, and a first-pass housing whose only job is to show how big the unit is.

| `show` | What it is | Status |
| --- | --- | --- |
| `print-set` (default) | Both sprocket halves, mid-plane faces up | Printable; dimensions measured or from drawings |
| `half-a`, `half-b` | One half each | Printable |
| `pocket-coupon` | Four sprocket pairs that differ only in pocket clearance | Printable; the first real test |
| `section` | Horizontal cut through the axis with the hub and wrapped chain | View |
| `assembly` | Whole unit, cover on | Sizing only |
| `assembly-open` | Cover off | Sizing only |
| `release` | Cover off, cartridge swung to the release position | Sizing only |

Set `asm_show_wall=true` to draw a translucent wall slab; it is off by default because it hides the iso view.

## Measured and drawn inputs

The chain is #10 plastic bead chain: 4.5 mm bead, 6.0 mm pitch, 1.5 mm cord, measured October 16, 2026. One joiner per loop, a rigid 13.25 × 7.6 mm cylinder that does not break away. Single-bead clips are on the chain too, probably limit stops, not yet sized.

The motor (Pololu 37D 131:1 with 64 CPR encoder) and the hub (Pololu #1999) are modelled from Pololu's dimension drawings 0J1735 and 0J667. The motor body is 72.6 mm long (gearbox 26.5, can 30.7, encoder 15.4), so the title's 73 mm includes the encoder. Its output shaft sits 7 mm off the body axis, on a 12 × 6 mm boss, and is 16 mm long beyond it.

## Sprocket

The wheel splits at the chain's mid-plane into two halves, each printed outer face on the bed with the mid-plane face up, so every half-pocket and the half cord groove print as open bowls with no overhang.

It now bolts to the #1999 hub instead of carrying its own D-bore. The hub flange sits 1 mm into a centring recess on the motor-side half, and three M3 × 12 button-head screws pass through both halves into the hub's threaded holes. The hub's holes sit on a 9.5 mm radius, which collides with the bead pockets on a 14-pocket wheel, so the wheel went to 15 pockets. With 15, three screws 120° apart land exactly midway between pockets at any hub rotation, leaving 1.15 mm of wall to the nearest pocket.

At 15 pockets the bead centres sit on a 14.43 mm radius: 90 mm of chain per revolution and 0.42 N·m of wheel torque at the measured 3 kg worst-case pull. The plan's sizing table used 14 pockets (84 mm and 0.40 N·m); those figures move by about 7%. The cord groove is widened for the 1.5 mm cord. The outboard half carries a 5.6 mm hole for an M4 heat-set insert that takes the 625ZZ's shoulder bolt; the insert hole size is a placeholder.

## Route assumption

The route is unmeasured, so this pass assumes the RYSE arrangement: the loop wraps 180° under the sprocket, both strands rise straight to the clutch, and the chain plane is 30 mm off the wall (`asm_chain_y`). The unit then sits at the bottom of the loop and keeps it taut by being slid down its slotted base. That is exactly where the shade's safety tensioner may already be. **Replacing or relocating that tensioner is an unresolved installation and safety issue**, not a decision this model has made. If the tensioner has to stay where it is, the alternative is a strand drive with idlers, which changes the layout entirely.

The joiner spans 55° of wheel, about 2.3 pockets, and cannot seat in a 5 mm pocket. Under this route it must never reach the sprocket over a full stroke; that depends on the chain travel per stroke and on where the stop clips sit, neither of which has been measured. The cover's strand notches are 10 mm wide so the joiner can at least pass the cover.

## Housing layout

The gearmotor's length decides the depth. To keep the chain plane near the wall, the sprocket sits nearest the wall and the motor points into the room, so depth is roughly the chain plane plus 104 mm.

| Part | What this pass does |
| --- | --- |
| P3 wall base | Plate with four vertical slots for tension adjustment, and two pillars carrying the pivot and latch pins out to the cartridge |
| P2 cartridge | Face plate on the gearbox's six M3 holes (M3 × 6 gives 2 mm of the allowed 3 mm), swinging on the pivot pin and held by the latch pin; both pins carry reaction torque |
| P4 keeper | Band under the wrapped chain, 1.5 mm off the bead edges, on arms from the cartridge so it swings with the sprocket |
| P5 outboard yoke | Optional (`brg_show`): from the cartridge over the top of the sprocket, between the strands, down the wall side to the 625ZZ; it must come off to load an intact loop over the sprocket's free end |
| P6 release latch | Placeholder pin only |
| P7 carrier | L-bracket off the base carrying the protoboard on standoffs under the motor, XIAO USB-C toward a slot in the -X side |
| P8 cover | Open-backed shell pushed on toward the wall, strand notches open to its back edge, three 12 mm buttons in a row on the front face, the DC jack on the bottom, vents on the +X side |

The cartridge pivots on a pin along Y at X −22, Z 7. Swinging it 20° lifts the sprocket 7.9 mm to slacken the loop. The latch sits at X 22, Z 22, above the arc the keeper arm sweeps on release. The motor is clocked so the encoder leads leave toward +X, clear of the button bodies. A CGAL check finds no overlap between the fixed parts, the swinging cartridge (engaged and released), the cover, the controls, and the chain, apart from the placeholder pins sitting in their own holes.

## Envelope

Echoed by the model as `ENVELOPE`:

| Measure | Value |
| --- | --- |
| Width along the wall | 59 mm |
| Height | 85 mm (about 40 below the sprocket axis and 45 above it) |
| Depth off the wall, housing | 134 mm |
| Depth off the wall, to the button bezels | 136 mm |
| Strand spacing at the top | 28.9 mm |

Depth is the motor: 30 mm of assumed chain standoff, 25 mm of sprocket, hub, and shaft, 73 mm of motor, and the cover. Height is the electronics stack under the motor (header sockets dominate) plus release headroom over it. Width is the button row and the pivot and latch pillars.

## Still open

1. Chain route against the tensioner, the chain plane's real distance from the wall, and the stop clips' positions and size.
2. Whether the outboard bearing is needed, which the bench decides by measuring shaft play under load.
3. The release mechanism beyond a placeholder pin, and what the clutch does with the chain released.
4. Exact outlines for the protoboard, buttons, DC jack, and antenna, which are generic placeholders here.
5. Mounting substrate and fasteners.

## Validation record

| Level | Status |
| --- | --- |
| Modelled fit | Sprocket against measured chain and drawn hub; housing as sizing only |
| Rendered inspection | All variants, seven views each, October 16, 2026 |
| Interference | CGAL intersections clear, engaged and released |
| Printed coupon fit | None |
| Bench operation | None |
| Installed performance | None |
