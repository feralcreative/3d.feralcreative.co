# 3D library consolidation—Claude review

Independent review of [3d-library-consolidation.md](3d-library-consolidation.md), written 2026-10-20 for Codex and Ziad, revised the same day after Codex's corrections. It is review only. Nothing in either application was edited, no branch was switched, nothing was committed or pushed, the NAS was not contacted, and no server was started. All execution was local Node parse tests in my scratchpad against the website's installed `online-3d-viewer`.

## Summary of positions

1. **Repository merge: prove the contract first, merge later.** Codex and I agree. Merging is technically cheap (website history is 42 commits, `.git` is 34 MB) and can keep history, but none of the colour or coverage goals depend on it.
2. **Standard GLB works in the installed viewer, with no replacement.** Codex's real export round-trips exact colours. I accept Codex's position: shared GLBs use standard metres and Y-up, and the consumer chooses the camera's up axis per format and reports engineering dimensions from explicit metadata.
3. **Native 3MF loads but shows the wrong colours in the installed viewer.** Geometry and units are correct, but every colour comes out darker, consistent with sRGB→linear being applied twice. Until that is fixed or worked around, GLB is the better presentation format. The 3MF finding is from a Node test, not a browser.
4. **Gaps to report, not policies to impose:** model files are served without authentication, missing files return `200`, and the website's WIP Docker build cannot compile its styles. Whether and when to change access policy is a separate, deliberate decision.

## Installed-engine results

Installed: `online-3d-viewer` 0.18.0, three 0.176.0, Node 24. Scripts are in `/private/tmp/claude-501/-Users-ziad-www-feralcreative-scad/440acb95-60ba-4fa5-9554-85039801b707/scratchpad/ovproof/` (`real.mjs` for the GLB, `tmf.mjs` for the 3MF, and `proof.mjs` for my first hand-built fixture). The source is `/tmp/scad-colour-export-proof.scad`: a `#90A553` 20×20×2 slab with a `Gold` 10×10×2 block at Z 1.99.

| Input | Colours the viewer imports | Bounds | Up reported | Volume | Instances |
| --- | --- | --- | --- | --- | --- |
| Codex GLB, 1860 B | `144,165,83` and `255,215,0`—exact; an unused third material `249,215,44` | X 0–0.02, Y 0–0.00399, Z −0.02–0 (metres, Y-up, `[x,z,−y]`) | Y | 9.99e-7 m³ | 1 mesh, 28 triangles, 2 primitives |
| Native 3MF, 2016 B | `16,30,2` and `255,107,0`—too dark | X 0–20, Y 0–20, Z 0–3.99 (mm, Z-up) | Z | 999 mm³ | 2 instances, 18 and 10 triangles, both named "OpenSCAD Model" |
| My first fixture | `198,210,155` and `255,237,0`—washed out | as authored | Y | n/a | n/a |

What the table shows:

- **GLB colour handling is correct when the factors are linear.** My first fixture was wrong because I put sRGB fractions into `baseColorFactor`, as Codex pointed out. Codex's converter applies sRGB→linear, and the colours come back exactly.
- **The two formats agree on geometry.** 9.99e-7 m³ is 999 mm³, the same figure the 3MF gives, so the metre conversion and the axis swap are lossless.
- **The 3MF colour error is systematic.** `144/255` → linear `0.279` → linear again `0.063` → `16`. three's `3MFLoader` converts `displaycolor` into linear working space, and OV then treats that value as sRGB. It needs confirming in a browser, but nothing in this path depends on the environment.
- **Camera up has to follow the format.** `EmbeddedViewer` always calls `SetUpVector(Direction.Y)` and ignores the importer's reported direction. A standard GLB therefore looks right as is, while today's Z-up STLs, and native 3MFs, appear tipped onto their backs. The consumer should set the up vector from the import result or the catalog: Z for STL and 3MF, Y for GLB. That change is mine to make.
- **The viewer's STL formulas give nonsense for metre GLBs.** The current panel would read "0.02 × 0.00 × 0.02 mm" and "0.00 mm³". Dimensions should come from catalog metadata (below), not from raw bounds.
- **The OpenSCAD default colour leaks into the GLB.** `F9D72C` is OpenSCAD's colour for uncoloured geometry. Here it is unused, but on a part with uncoloured solids it would become a real yellow material. Uncoloured geometry should reach the viewer without a material so the viewer's default applies, and unreferenced materials should be dropped.
- **The parts are merged.** Both formats come out split by colour, not by printed piece. Two pieces in the same colour would become one group, and pieces have no names. Seated and exploded views still work, since position is preserved, but a parts legend or per-piece visibility would need per-piece export. That is worth checking on `wire-shelf-gridfinity-4x2` before the contract settles.
- **No Draco or meshopt.** Only Draco, specular-glossiness, and texture-transform are accepted in `extensionsRequired`, and Draco loads its decoder from `cdn.jsdelivr.net` at runtime. Codex's GLB declares no extensions, which is what we want.

## Schema and export contract

The contract is a generated `catalog.json` plus files in the existing flat models directory. Codex owns the generator, I own the consumer, and a schema change needs both of us. A v1 sketch, for Codex to correct:

```json
{
  "schema": 1,
  "generated_at": "2026-10-20T00:00:00Z",
  "source_commit": "ecb4c66",
  "models": [
    {
      "id": "screen-fence-rail",
      "title": "Screen fence rail",
      "category": ["cats"],
      "origin": "authored",
      "status": "unreviewed",
      "availability": "viewable",
      "attribution": null,
      "default_view": "assembled",
      "views": [
        {
          "id": "assembled",
          "label": "Assembled",
          "file": "screen-fence-rail--assembled.glb",
          "format": "glb",
          "units": "m",
          "up_axis": "y",
          "source_bounds_mm": { "min": [0, 0, 0], "max": [20, 20, 3.99] },
          "bytes": 1860,
          "sha256": "…",
          "colour_source": "scad"
        }
      ],
      "downloads": [
        { "export": "screen-fence-key", "file": "screen-fence-key.stl", "format": "stl", "units": "mm", "up_axis": "z", "bytes": 0, "sha256": "…" }
      ],
      "aliases": ["screen-fence-key-v04.stl"]
    }
  ]
}
```

Contract rules:

- **Format, units, and up axis are declared per file.** The viewer picks the importer from `format` rather than forcing `.stl`, and the camera from `up_axis`. Native 3MF keeps the unit and up axis it declares; STL is mm, Z-up by convention.
- **Engineering dimensions come from `source_bounds_mm`,** which is computed by the generator from the source geometry. Volume and area are shown only where the generator supplies them, or where the format is in mm and the mesh is closed. They are never inferred from a converted mesh.
- **Colour defaults to the part's existing `color()` definitions.** `colour_source` is `scad` when they exist and `default` when the viewer's grey applies. No new colour scheme is introduced.
- **Model availability is separate from downloadable files.** `availability` describes the model entry (`viewable`, `download-only`, `no-mesh`); `views` and `downloads` list what files exist. A model with no mesh is still a catalog entry and shown as such, not hidden.
- **Existing exclusions carry forward unchanged:** coupons, `publication_excluded_exports`, protected assets, and drafts.
- **The flat namespace stays.** File names derive from export names, which `build.sh` already keeps globally unique. View files are `<model-id>--<view-id>.<ext>`, and the generator rejects any export name containing `--`.
- **Deep links keep working.** `?model=` accepts a model ID, a published filename, or an alias. The printer page's job-name mapping (job basename → model) uses the same lookup.
- **The catalog goes up last.** Meshes are sent first and `catalog.json` last, so a live catalog never references a missing file. This keeps the bind mount's no-rebuild property.
- **Caching:** names are not versioned, so the website appends `?v=<sha256 prefix>`, and the catalog stays `no-store`.
- **Views are declared in `model.json`,** for example `{"id": "exploded", "openscad_args": ["-D", "show=\"exploded\""]}`, because `show=` vocabularies differ between parts. Codex owns this field.
- **Unmanaged files stay visible.** The NAS directory holds meshes this repo didn't publish, and `prod.sh` never deletes. The website lists catalog entries, plus any top-level STL from the autoindex that nothing in the catalog claims. Existing links to those keep working.

## Imported-model coverage

Codex's counts: 196 declared exports. Of the 210 models without exports, 166 hold a retained STL and 34 hold no STL, 3MF, OBJ, GLB, or glTF. From the manifests: 188 `legacy`, 36 `authored`, 24 `imported`, and 8 `adapted`; 254 of 256 are `unreviewed`; 19 have a `licenses` entry and 2 a `source_url`.

1. **Declared exports:** published as today, adding a coloured view where the part has `color()` definitions.
2. **Mesh-only models (166):** these need an explicit selection of which retained file is the presentation mesh. They are not inferred, because folders hold coupons, tests, enforcers, and superseded originals. A triage pass can propose candidates for review.
3. **No-mesh models (34):** catalog entries with `availability: "no-mesh"`. SketchUp-only models have no conversion path in this pipeline, and the Dropbox archive is off-limits.
4. **Attribution is a reported gap, not an embargo.** The catalog's `attribution` field will be empty for most of the 32 third-party models, because the manifests rarely carry the source. Codex's generator can surface it where it exists; existing publication rules are unchanged.

## Website migration risks

1. **Model files are served without authentication.** In the Dockerfile's Nginx config, only `= /model-catalog/` has `auth_request`. `/models/<file>` goes through `location /`, so a catalog placed in the models directory would be readable without signing in. That is a fact about the current access policy, reported here; changing it is a separate, deliberate decision. Serving the catalog from its own location under the same `auth_request` as today's listing keeps the current policy.
2. **Missing models return 200.** `try_files $uri $uri/ /index.html` answers `/models/missing.stl` with `index.html`, so the `HEAD` check passes, and the user then sees "check your connection" instead of "not found". A `location /models/ { try_files $uri =404; }` fixes it. The exact `= /models/` page route still wins, because exact matches take precedence.
3. **The WIP Docker build cannot compile its styles.** On `feat/hub-access`, `npm run build` now runs Sass on `styles/scss/`, which the local, gitignored `.dockerignore` excludes from the build context. The image also depends on other ignored local files: `printer-proxy-server.js` (copied by the Dockerfile), `config.js`, and the lockfile that `npm ci` needs. A merge does not change any of this.
4. **The WIP is uncommitted.** As Codex found, `models.js` and `utils/dev.js` are untracked and 13 tracked files are modified, so a history-only import would leave the model library behind. The website's AGENTS.md requires explicit permission before an agent commits there.
5. **The two repos have different commit policies.** The scad AGENTS.md lets the agent commit and open PRs; the website's requires per-task permission. A merged tree needs one policy.
6. **The `3d` symlink into Dropbox has self-referential loops.** Vite already excludes it. Inside the scad tree it becomes something `library.py`, `clean.sh`, or `rg` could walk into.
7. **Agreed:** keep `web/.gitignore` scoped to `web/`, and keep the Docker build context to `web/` only. The Dockerfile's `COPY utils ./utils` means the website's `utils/`, and a root context would pick up the wrong one.
8. **Tooling keyed on the repo root would shift:** tmux session names, `_PLANS/` journals and cursors, the private `utils/deploy/` scripts, the GitHub remote and its open branches, and the `.vscode/sftp.json` destinations.

If the merge goes ahead later, the method I'd recommend is `git filter-repo --to-subdirectory-filter web` on a fresh clone of the website, then `git merge --allow-unrelated-histories` into scad on a branch. Unlike `git subtree add`, that keeps `log` and `blame` readable without `--follow`.

## Recommended sequence

This is my recommendation, not a sign-off checklist. The local, read-only, and proof steps can go ahead now; deployment and access-policy changes stay separate, deliberate acts.

1. **Contract v1:** a schema document plus a fixture `catalog.json`, agreed between Codex and me.
2. **Codex:** a catalog generator, and a coloured GLB export for one multi-piece part, written to a local directory.
3. **Claude:** a catalog-driven library and viewer against the fixture: per-format up axis, metadata-driven dimensions, deep-link and alias resolution, views and downloads, and the autoindex fallback.
4. **Browser check** of the GLB, and of 3MF with and without a colour correction, in the installed viewer. Running the local dev server on its configured port 5501 is the only step here that binds a port.
5. **End to end locally:** Vite reads the generator's output.
6. **Website groundwork:** fix the Docker style build and the missing-file `200`; serve the catalog under the existing listing's authentication. These ship with the WIP once it lands, and the image rebuild is Ziad's deployment.
7. **Publish:** meshes first, catalog last, when Ziad chooses to.
8. **Expand coverage in batches:** coloured views for declared exports first, then mesh-only models as their presentation files are selected.
9. **Repository merge,** if still wanted.

## Resolved and open points

Resolved with Codex:

- Prove the contract before merging; `web/.gitignore` stays scoped and the Docker context stays `web/` only.
- GLB is standard metres and Y-up. The consumer chooses camera up per format and import result. Dimensions come from `source_bounds_mm` and unit metadata.
- Colours come from existing `color()` definitions.
- No new publication embargo, authentication policy, or automatic hiding of no-mesh entries. Gaps are reported instead.

Open:

- **GLB or 3MF as the presentation format.** I recommend GLB, because native 3MF imports too dark in the installed viewer. 3MF stays viable if the browser test confirms a simple correction.
- **Per-piece identity.** The current export groups by colour. Whether a parts legend matters enough to export each piece separately is a product call.
- **Licence files.** I dropped my earlier claim. For the record, Claude's memory holds a 2026-10-18 instruction from Ziad, made on the fence pumpkins: don't commit newly downloaded licence files, and put a credit line in the model's doc instead. The repo docs preserve licences that are already retained. The two may not conflict (keep what is retained, don't add new ones), but it bears on where `attribution` is read from, so it is worth Ziad confirming.
