# Together and exploded views

Renderable working SCAD files in the model library expose an **Assembly display** customizer selector:

- `default` keeps the source's previous output, including existing `show`, part, print and coupon controls.
- `together` shows the complete assembly in its assembled position.
- `exploded` separates the assembly components for inspection.

Single-piece models remain intact in both display modes. Helpers and includes do not acquire artificial geometry. Archived and protected upstream sources remain unchanged; four active projects now use working adaptations beside their retained originals.

From `cad/`, render a working source with either mode:

```bash
utils/render.sh library/3d-printer-tools/overture-spool/overture-spool-main-body-ribbed.scad -D 'view="together"'
utils/render.sh library/3d-printer-tools/overture-spool/overture-spool-main-body-ribbed.scad -D 'view="exploded"'
```

The fence-pumpkin download source imports the three curated final STLs. For local authoring renders, also pass `-D 'file_prefix=""'`; its default prefix matches the website download filenames.

Each model manifest records its renderable sources in `assembly_view_sources` as `assembly`, `single-part` or `inherited`. All 49 SCAD-backed projects have explicit website `assembled` and `exploded` presentations. Preserve any required configuration defines when updating these records. Generate previews from the unified repository root with `utils/models.sh --render-colours`; this stages locally and does not publish.

## Verification on 2026-10-20

Audited 85 renderable entrypoints: 83 edited/created working sources and two wrappers inheriting their display modes. Ten helpers and seven protected/archive sources were left unchanged. All 255 default/together/exploded native CSG evaluations passed, and all 85 default outputs matched their pre-change geometry after normalizing transparent wrapper groups and temporary asset paths. The existing default print geometry and retained printable STLs were preserved.

Generated 98 coloured website previews and inspected both modes for every entrypoint from seven angles. Single-piece identical geometry reuses its seven images. The large standard can-holder scene emitted OpenSCAD cache-size warnings during PNG rendering but completed all images. Two archived Tesla sources retain their pre-existing unknown `round` module warnings; they are not active entrypoints. Catalog generation retains three existing G-code-only 3MF conversion warnings.

The local contact sheets and full-size renders are in `_work/assembly-view-audit/review/index.html`. CSG reports, the exact applied file list, hashes and rollback copies are beside that directory. These are regenerable local review artifacts. Render checks establish display geometry, not physical fit, assembly insertion paths, print quality or support removal. No printable STL rebuild, slicing or printer operation was performed for this display-only change.
