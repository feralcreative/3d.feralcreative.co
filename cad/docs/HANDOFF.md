# End-of-day handoff

- **Date:** 13 October 2026
- **Branch:** `main`
- **Transfer:** Local checkout and retained files continue through Syncthing. No Git fetch or push is needed for this handoff; transfer completion has not been checked.

## Completed

`feat/haunted-tree-light-channel` is merged into `main`, including the tapered LED light channels, retained meshes, and existing library cleanup. `feat(part)/cat-gap-wedge` was already an ancestor of `main` and needed no additional changes.

The publisher fix is committed as `7a4bf2f` (`fix(publishing): allow library-only repositories`). The removed legacy `stl/` directory previously caused the publisher to skip the library list and report “nothing to sync.” The legacy scan is now optional. A mocked deployment selected `haunted-tree-grin-led.stl` without contacting the NAS; all 12 library workflow tests passed.

The library manifest check passed for 251 models and 2636 legacy aliases. The haunted-tree manifest currently selects all six retained outputs for publication, including the older hollow-mode diffuser. These publication selections do not establish physical print success.

## Resume

Read the [haunted-tree source and print notes](../library/holiday/haunted-tree-family/docs/source-and-print-notes.md). The five tree meshes use the tapered interior by default and are retained in [the model folder](../library/holiday/haunted-tree-family/). The old diffuser belongs to `interior="hollow"` and does not fit the tapered version.

Next physical step: slice the retained tree you want to print, then assess print finish, puck retention, and brightness. The existing model notes record mesh and insertion checks; a complete print with every support disabled is still unverified. The diagnostic slice did not produce a printable 3MF. No print settings were changed in this closing session.

## Publication

The local publisher is ready. This session did not deploy, and no later successful deployment was reported. When deliberately publishing, run from the repository root:

```bash
utils/deploy/prod.sh --dry-run
utils/deploy/prod.sh
```

This publishes all selected finished exports. `--all` also includes current drafts across the library. No remote branches were changed during the end-of-day merge.
