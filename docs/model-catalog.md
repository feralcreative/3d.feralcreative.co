# Model catalog and coloured views

The canonical repository is `3d.feralcreative.co`. Website source stays at its root; CAD sources, retained model assets, shared libraries and the existing CAD tools live under `cad/`. Both Git histories are preserved. The old sibling `scad` path is a compatibility link; a recovery copy is kept separately during the consolidation.

## Commands

Run these from the unified root:

```bash
utils/models.sh                       # stage the complete catalog and selected assets
utils/models.sh --render-colours      # also evaluate configured SCAD presentations
utils/models.sh --render-colours --model fence-pumpkins
utils/models.sh --push --dry-run      # stage locally and describe publication; no NAS connection
utils/models.sh --push                # publish assets first, then the catalog
```

Generation writes only regenerable staging and presentation outputs. It preserves original meshes, SCAD files, slicer projects, archives and source-only designs. It does not run a slicer, contact the printer, deploy the website or reset existing model versions. `cad/_work/site-models/report.json` records conversion failures; it is a local report and is not published. Normal website builds exclude CAD assets; Vite serves selected files from the staging directory without copying the library into `public/` or `dist/`.

## Model selection and availability

Every `model.json` produces a catalog entry, including models without a browser-readable mesh. Registered retained exports are preferred. For imported models without registered exports, the generator selects their owned retained browser formats, excluding nested models, regenerable work, coupons, enforcers and support volumes. Identical payloads within a model are deduplicated by SHA-256. Existing publication exclusions remain in force. Standalone OBJ and textual glTF packages are not advertised without dependency staging.

An entry with a geometry file is `viewable`; one without one is `no-mesh`. The website distinguishes browser-supported views from CAD formats available as downloads only (currently STEP, 3DM and FCStd). Source-only SKP/SCAD/STEP files remain downloadable where present. This is an availability classification, not a statement that an original is physically tested or printable. G-code-only 3MF archives may contain no mesh and cannot supply a 3D view.

The gallery lists only projects with an existing declared SCAD source and a browser-supported default view. Loose STL files never appear. It hides source-only entries, unsupported-only formats, withheld entries and the internal `no-model-loaded` placeholder. The management inventory retains the complete catalog. Website hiding preserves source files and saved downloads but removes them from the visitor catalog and blocks their direct URLs for non-admins. Files shared by a published project remain accessible.

## Project descriptions, instructions and supplies

Author project content in its `model.json`; the fence pumpkin is the populated reference. Set a top-level `title` for its display name. Optional `website` fields are copied into the schema-1 catalog:

```json
{
  "title": "Fence-post pumpkin",
  "website": {
    "description": "A fence-post jack-o’-lantern with a sliding rear door and magnetic mounting.",
    "default_view": "assembled",
    "view_labels": { "assembled": "Assembled pumpkin", "exploded": "Exploded assembly" },
    "instructions": [{ "title": "Steel disc", "text": "Use one 25 mm diameter × 2 mm thick steel disc." }],
    "parts": [{ "name": "Steel disc", "quantity": "1", "specification": "25 mm diameter × 2 mm thick", "url": "" }],
    "links": []
  }
}
```

Descriptions and instructions are plain text; paragraphs may contain newline characters. Product links and project links must be HTTPS without embedded credentials. Project links use `label` and `url`. Empty sections are hidden, and a part without a URL remains a supply item without a purchase link. Do not invent product listings, dimensions, print settings or validation claims. A preferred default view that has not been staged falls back to an available view and is recorded in the generation report.

Set `amazon_affiliate_tag` in `cad/catalog-settings.json` when the Amazon Associates tracking ID is available, then regenerate with `utils/models.sh`. The tag is a public identifier. It is applied only to canonical Amazon.com URLs; it does not rewrite other retailers or Amazon short links. Product links use the plain “View on Amazon” label; tagged links retain the separate Amazon Associate disclosure beneath the supplies list. The configured tracking ID is `feral-creative-20`. The pumpkin's steel disc, solar cork light and fence-side magnet use the exact Amazon product URLs supplied by Ziad.

## Gallery and part previews

The gallery displays a main project preview, title, category and optional description. The project modal keeps the interactive 3D model beside authored details and exposes a horizontally scrolling strip of assembly and part thumbnails. Selecting a thumbnail updates the existing `model`/`view` query contract; file downloads remain separate.

`model-previews.js` renders real geometry with one shared offscreen Online 3D Viewer instance as thumbnails enter the viewport. It caches PNGs by file hash and up axis in a bounded browser cache; unmanaged files use a session key. Failed thumbnails show an unavailable state without removing the project. Files over 25 MB show “Open for 3D preview” and are loaded when opened, rather than downloaded automatically while browsing. Background gallery work pauses while the modal is open; part thumbnails take priority, and sign-out cancels queued work. These thumbnails are generated in the browser and are not CAD source assets or application build inputs.

## Configured SCAD views

All 49 SCAD-backed projects have explicit `assembled` (Together) and `exploded` presentations. Renderable working sources accept `view="together"` or `view="exploded"`; the default preserves their previous print/coupon selectors. Single-piece sources use the same intact geometry for both modes. `assembly_view_sources` records the per-source classification; protected upstream sources retain their originals and use working adaptations. See [CAD assembly views](../cad/docs/assembly-views.md).

Add `presentations` to a model's metadata to select a specific assembly or variant:

```json
{
  "presentations": [
    {
      "id": "assembled",
      "label": "Door seated",
      "scad": "fence-pumpkin.scad",
      "defines": {
        "show": "assembled",
        "preview_light": false,
        "fused_roof": true,
        "disc_cover": true
      }
    }
  ]
}
```

Published filenames reserve a case-insensitive namespace so the same staging works on macOS and a case-sensitive NAS. When distinct assets would collide, the later filename receives a content-hash suffix. Catalog records use the resulting filenames; original source files and legacy aliases are preserved.

Models with a configured SCAD entrypoint and no explicit presentations get its default view. `--model` limits colour rendering, not catalog coverage. Cached presentations are rebuilt when their definition or model/shared SCAD dependencies change. Native OpenSCAD exports 3MF colours; the converter retains base-material assignments, component transforms and object/mesh names. Colours are converted from sRGB to linear glTF factors, distances from millimetres to metres, and axes from Z-up to Y-up. Native OpenSCAD may merge printed pieces into a single mesh with several materials; a colour group is not a promise of independent part visibility. Interpolated per-vertex 3MF colour resources are rejected explicitly until supported.

## Website contract

`GET /models/catalog.json` returns `schema: 1`, a generation timestamp, optional `settings` and `models`. Each entry carries its stable ID, title, category array, origin, design status, availability, default view, views, downloads, filename aliases and optional `website` content. File references are flat basenames. Views declare `format`, `units`, `up_axis`, byte size, SHA-256, colour source, and original `source_bounds_mm` where available. Downloads have their export name, format, size and hash. The viewer uses source bounds for engineering dimensions and the presentation's up axis for its camera. Existing filename links remain usable for eligible projects; unregistered published meshes are denied to visitors.

The base catalog is generated from local model metadata and files. Website organization is applied at request time; loose STL files not already claimed by a filename, alias or export stem also get manageable entries. The sign-in requirement remains; hidden projects and files are available only to admins.

## Verification

```bash
python3 cad/utils/library.py check
python3 cad/utils/test-library.py
python3 cad/utils/test-web-library.py
python3 cad/utils/test-catalog-publish.py
npm run test:models
npm run build
```

The exporter tests cover colour factors, standard GLB coordinates, component transforms, cycle rejection, original-file preservation and complete catalog entry coverage. Publication tests use fake SSH/rsync destinations to prove asset-first/catalog-last ordering and failure propagation. Those tests do not verify a live NAS transfer, production deployment or physical prints.

## Admin project management

On `/models`, an existing admin sees **Manage projects**. Filter by project title, category, filename, `hidden` or `published`, then use **Select filtered** for bulk changes. Selection remains active across filters; the selected count includes those rows. **Clear selection** resets both project and file selections.

- **Hide / Publish projects** changes gallery visibility. Projects without a browser-supported 3D view remain absent from the gallery even when published.
- **Hide / Publish selected files** removes or restores individual previews and downloads. Expand **Choose files to move or split** inside selected projects to select files.
- **Change category** updates website categories; `/` separates category levels.
- **Move selected files** transfers selected asset references to an existing destination outside the selected projects.
- **Merge projects into…** transfers all assets, instructions, supplies, links and descriptions to the destination. Source project IDs become aliases so old project links resolve to the destination. Conflicting view IDs are disambiguated.
- **Split selected files** creates a new project with the selected assets. It starts hidden. Use **Preview** to review it, then publish it.
- **Undo last change** restores the previous organization; up to 20 changes are retained globally. Revision conflicts require reloading the management inventory before another save.

Organization is a runtime overlay in `data/model-organization.json` locally and `/app/data/model-organization.json` in the container. Atomic writes use a private temporary file and rename. Back up the container data volume along with other persistent state. The overlay and undo history are private runtime data, excluded from Git and Vite serving/watching. Operations never move, delete or rewrite CAD files or generated mesh bytes. Edited projects are stored as catalog snapshots; regeneration preserves these overrides, so later changes to those projects' authored metadata need deliberate reconciliation with the saved organization. Local and production overlays are separate; a frontend build or catalog publish does not transfer local management choices.

`utils/model-management.js` provides a shared Connect/Express middleware. Vite mounts it directly and permits management only over a loopback socket with a localhost/loopback Host. Production mounts it in the private proxy before the catch-all and checks the existing signed session's admin flag. It does not grant an account a hub admin role. Viewer sessions and signed-out requests receive 403 and 401 respectively for management. Writes require same-origin JSON, and a stale revision returns 409. Run one proxy writer process per state file; revision serialization is process-local.

Production Nginx proxies the catalog and filtered listing through the middleware. A model-file authorization subrequest blocks hidden assets for non-admins while retaining existing access to visible files. Admins receive the complete catalog for management previews, but hidden cards remain excluded from their ordinary gallery. Both the updated private proxy and Nginx configuration must ship together; a frontend-only release cannot enforce hiding. Container startup, real hub roles and Nginx integration require separate runtime verification; do not start the production proxy for a routine local test because it also starts the printer monitor.

## Curated source downloads and retired exports

A model may declare top-level `source_downloads` containing explicit, existing `.scad` paths owned by that model. These are download-only files, staged using the same project-prefixed basename convention as meshes; source helpers are never added automatically. A source download must work with the advertised companion files. The fence-pumpkin project is the reference: one assembly SCAD imports the three final STL filenames from the same download folder, while its full authoring source and original dependencies remain in the local library.

An explicitly supplied `publish_exports` list is authoritative, even when empty or when a selected export is unavailable. It must not fall back to unrelated retained originals or trials. `publication_excluded_exports` also emits claimed legacy and prefixed filenames in `excluded_files`, so old staged or published assets cannot reappear in the unmanaged list and the model-file visibility check denies them to visitors. This preserves local source history without advertising retired downloads.

## SCAD requirement

A project must have an existing declared `.scad` source to appear on the site. The generator records `has_scad` from `scad`, `scad_files` or `source_downloads`, checking that the selected source exists inside the model directory. An unrelated helper discovered while scanning files does not qualify a model. Missing or absent eligibility fails closed; regenerate the catalog after adding or recreating a source. A SCAD source alone does not replace the existing requirement for a supported 3D preview.

The visitor catalog, file listing and model-file visibility checks exclude projects without SCAD. Unregistered loose files also fail the visibility check. Admins retain access to the complete management inventory, where these projects are marked **Needs SCAD**; publishing projects or files is rejected until their source exists. Local originals are retained for review and future recreation. No automatic STL-import wrapper is generated to make a legacy mesh qualify.

Saved admin snapshots cannot override current source eligibility. Moved, merged and split projects retain their contributor IDs in `scad_source_ids`; every contributor must have a current SCAD source. This prevents moving a source-less mesh into an authored project from making it public. Existing derived projects without source provenance remain ineligible until deliberately regrouped from eligible sources. The updated catalog, frontend and server visibility middleware must ship together for the deployed site to enforce the rule.
