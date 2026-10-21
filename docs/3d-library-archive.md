# Standalone SCAD archive handoff

The old standalone repository is retired from active development. Continue all CAD and website work in `/Users/ziad/www/feralcreative/3d.feralcreative.co`; models, shared libraries, artwork, presets and CAD utilities live under `cad/`.

## Completed locally on 2026-10-20

- Initial standalone snapshot: `93f2251`. Final merged, GitHub-compatible main: `a2df3e394676d876eb44b9ae1e66bdfb2f036efb`.
- Retired checkout: `/Users/ziad/www/feralcreative/scad.pre-consolidation-20261020`, on clean `main`.
- Retired local tag: `archive/scad-2026-10-20`.
- Final snapshot preserved in this repository at `cad-history/main` and tag `cad-history/archive/scad-2026-10-20`.
- Merged old local branches removed only after preservation here: `feat/bong-stabilizer-led-wings`, `feat/halloween-bat-cup-magnets`, `feat/halloween-cat`, and `feat/nacs-plug-holder`.
- The remaining `feat/shade-drive` history is now merged into retired `main`; its SCAD source was already identical, and the newer main metadata was retained. The retired checkout now has only `main`. Its original branch tip remains recoverable here under `cad-history/feat/shade-drive`.

The `cad-history/*` refs preserve historical standalone trees with their former root-relative paths. Do not check them out over the active unified worktree or cherry-pick their old root paths into it blindly. Inspect the history or use a separate worktree, then port selected work into `cad/` deliberately.

## Preservation and checks

The pre-retirement migration audit hashed 2,433 non-ignored regular files and found no missing original file/link paths. Retained geometry and deliverables match the migrated copies byte-for-byte. Differences were confined to catalog utilities and documentation. Evidence is in root `_work/archive/scad-migration-audit-2026-10-20.json`; closure metadata is in `_work/archive/scad-closeout-2026-10-20.json`. Those generated audit records stay local and ignored.

The retired checkout passes validation for 256 manifests and 2,636 aliases, 17 library/finalization tests, four colour/catalog tests, and one mocked publisher test. Native preset `.info` sidecars retain their existing blank values and trailing spaces rather than being reformatted. Committing trial geometry, profiles and saved jobs preserves the work; it does not claim physical fit, support extraction, lamp behavior or print acceptance.

The retired README and AGENTS now state the retirement boundary. Its final `docs/HANDOFF.md` and `docs/ARCHIVE.md` record the move and recovery procedure; its prior handoff is retained as `docs/handoff-2026-10-13.md`.

## Active project state

The active branch here remains `feat/unified-3d-library`. Its original pending implementation and model changes are preserved; this old-repo close-out does not merge, commit, reset or finalize the active project's unfinished work. Read [the current project handoff](3d-library-handoff.md) for the model viewer and catalog status.

At this close-out, BOSL2's working checkout is `v2.0.775` (`cee9a1725caab8586c76eb88d409d16c1e795833`), while the staged gitlink remains the earlier `v2.0.774` (`f1493a8425f51bd0585dd6d89aea962561100d32`). This pre-existing active-project change was preserved. Resolve the intended pin when committing the unified integration; archive preparation does not reset it.

The old sibling `scad` path is a compatibility symlink into this active `cad/` tree. The physical recovery checkout is the separately named `scad.pre-consolidation-20261020` directory. Keep that recovery copy until the unified project is committed and backed up. Syncthing continuation uses the local files; cross-machine delivery has not been verified.

Ziad subsequently explicitly authorized publishing and archiving `feralcreative/scad`. **Verified complete on 2026-10-20:** final `main` and `archive/scad-2026-10-20` are published, GitHub reports `isArchived: true`, and only `main` remains locally and remotely. Three large STL models remain in Git LFS. The three installer packages were subsequently removed from tracked files and archive history at Ziad's instruction. The original merged history is preserved at tag `cad-history/scad-before-lfs-2026-10-20`; the final rewritten history and LFS payload cache are also retained locally in this unified repository. The commit map is in `_work/archive/scad-lfs-object-map-20261020.csv`.

Published GitHub ancestry was left unchanged. The initial historical upload used fast-forward batches. A later pack exceeded GitHub's size limit, so three temporary batches bounded by raw payload size transferred the remaining objects. Their transfer history was merged with the final source tree unchanged, and the temporary remote branch was deleted. GitHub archival was performed only after final main and its archive tag were published. Verification evidence is retained at `_work/archive/scad-github-archive-verification.json`. The standalone archived repository needs Git LFS for a complete fresh checkout.

This LFS conversion applies to the retired standalone repository only. The active unified history retains its original imports and pending work; it still needs its own large-file publication audit before pushing. No application deployment, NAS upload, printer action or shutdown of the active development stack is included.

## Installer exclusion—2026-10-20

DMG and PKG installers are excluded from both projects. The archived SCAD main/tag history was purged of installer filenames and duplicate installer blobs, republished using exact ref safeguards, and re-archived. Its final current commit is `a2df3e394676d876eb44b9ae1e66bdfb2f036efb`. Only the three STL model files remain referenced by Git LFS.

The active unified repository was filtered through a separate bare history copy. Installer paths and blobs were removed from its local branch/tag histories, and a narrow ignore-policy commit was added. The active branch name, pending model/website edits and every unrelated staged entry were preserved. No active unified branch was published. Commit and ref mappings are retained locally in `_work/archive/3d-installer-exclusion.json`. Rewritten commit IDs supersede earlier archival identifiers where installer removal changed ancestry.

GitHub retains unreferenced LFS objects on its servers after history removal. Purging those already-uploaded installer payloads requires GitHub Support or repository deletion/recreation; neither was performed. See [GitHub's LFS removal documentation](https://docs.github.com/en/repositories/working-with-files/managing-large-files/removing-files-from-git-large-file-storage).
