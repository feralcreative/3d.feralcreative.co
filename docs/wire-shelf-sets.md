# Wire shelf print sets

All three wire shelf designs have a two-piece print set: one deck/body and its matching rail. The box platform and cup holder now use the successful Gridfinity shelf's sliding dovetail section through `parts/wire-shelf-dovetail.scad`. The Gridfinity joint remains unchanged; its print-set variant now contains only the two printable pieces, with the optional support enforcer kept in its separate variant.

## Print jobs

Generated locally on 2026-10-05 using Flashforge Generic PLA, the 0.20 mm Standard process, a 220 °C nozzle, and a 60 °C Textured PEI bed. Supports are disabled and absent from the G-code. Times and filament weights are slicer estimates.

| Part | Local print job | Time | Filament |
| --- | --- | --- | --- |
| Box platform | `3mf/wire-shelf-box-platform-set.3mf` | 1h 54m | 77.66 g |
| Cup holder | `3mf/wire-shelf-cup-holder-set.3mf` | 1h 27m | 51.63 g |
| Gridfinity 4×2 shelf | `3mf/wire-shelf-gridfinity-4x2-dovetail-set.3mf` | 2h 50m | 96.66 g |

The Gridfinity job pauses before layer 30 at Z=6.00 mm to fill its 32 buried 10×2 mm magnet cavities, then prints the roofs. The box and cup jobs have no pause. The existing `wire-shelf-gridfinity-4x2-set.3mf` was left untouched; the newly verified job has the `dovetail-set` name above. Jobs and renders are generated local artifacts and are not included in the commit.

## Geometry and assembly

Print each body working face upward, underside on the bed. Print its rail as mounted, channel mouth on the bed and dovetail tail upward. The two pieces sit 8 mm apart on the plate. Slide the rail along X into either open end of the body's groove before attaching the set to the shelf. Rails have different lengths and brace positions; pair each with its own body.

The tested dovetail retains its 5 mm mouth, 7 mm roof, 2.94 mm depth, 0.2 mm clearance per face, and 0.5 mm mouth chamfer. The box platform retains its 130×101 mm interior and 6 mm lip. The cup retains the current 69 mm clear diameter and 25 mm cavity depth. Both retain a 4.5 mm floor, leaving 1.56 mm above the groove. The proven channel cutter and floor-wire reliefs remain unchanged.

## Sources and exports

Each source defaults to `show="print-set"`, suitable for rendering and exporting the whole layout. Single-piece variants use their own output names to avoid overwriting the complete set.

| Source | Body variant and STL | Rail variant and STL |
| --- | --- | --- |
| `parts/wire-shelf-box-platform.scad` | `deck` → `stl/wire-shelf-box-platform-deck.stl` | `rail` → `stl/wire-shelf-box-platform-rail.stl` |
| `parts/wire-shelf-cup-holder.scad` | `body` → `stl/wire-shelf-cup-holder-body.stl` | `rail` → `stl/wire-shelf-cup-holder-rail.stl` |
| `parts/gridfinity/wire-shelf-gridfinity-4x2.scad` | `deck` → `stl/gridfinity/wire-shelf-gridfinity-4x2-deck.stl` | `set-rail` → `stl/gridfinity/wire-shelf-gridfinity-4x2-set-rail.stl` |

For example:

```bash
utils/build.sh parts/wire-shelf-box-platform.scad
utils/build.sh parts/wire-shelf-box-platform.scad -D 'show="deck"' --name wire-shelf-box-platform-deck
utils/build.sh parts/wire-shelf-box-platform.scad -D 'show="rail"' --name wire-shelf-box-platform-rail
OUTDIR=stl/gridfinity utils/build.sh parts/gridfinity/wire-shelf-gridfinity-4x2.scad --name wire-shelf-gridfinity-4x2-set
```

The box and cup assembled views remain available as `platform` and `holder`; Gridfinity retains `plate`. Use `split` for an exploded view. Seven preview views for each default layout are under `renders/<source-name>-{iso,zplus,zminus,yminus,yplus,xplus,xminus}.png`.

## Verification boundary

All seven renders per set were inspected. All nine combined and individual STL exports passed independent checks for collapsed triangles, edge incidence, and winding, with the expected solid and cavity counts. The box and cup dovetails passed seated-intersection and continuous axial sweep checks, including the complete rail and its braces. Shelf-wire and payload clearance probes also passed. The original snap-on shelf interface retains its previously printed geometry.

Each archived 3MF passed ZIP integrity checks and contains the exact verified G-code, with two printable objects, zero support roles, and the expected pause count. The Gridfinity cavity/pause verifier confirmed its magnet openings and roof timing. These checks establish mesh, modeled assembly, and sliced-job integrity. Ziad has physically printed the original Gridfinity shelf and the shelf-interface coupon; the newly split box and cup sets still need their first physical print and assembly check.
