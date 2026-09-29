# Debugging and verification limits

## Authoring baseline: 2026-09-28

| Check | Result | Next step |
|---|---|---|
| Dependency install | Registry DNS failed; offline attempt lacked cached metadata. | Retry the Commands-table install in an environment with registry access. |
| Frontend startup | Sandbox denied binding loopback port 5501. | Run the documented frontend command where local listening is permitted. |
| Build | Vite failed while copying `public/models/screen-fence-insert-220.stl`. | Ask Ziad to resolve asset availability; do not search deleted paths or remove links automatically. |
| Build plugin | Manifest injection then failed because entry HTML was not emitted. | Resolve the first build failure before diagnosing the secondary plugin error. |
| Automated tests | npm reported no test script. | Report suite coverage as unavailable; do not claim zero discovered tests is success. |
| JavaScript syntax | Commands-table checks passed for browser modules, utilities, and both private proxies. | Run the applicable checks after edits; syntax does not establish runtime behavior. |
| Docker and production | Not executed. | Perform only within an explicitly authorized deployment task. |
| Browser, printer, stream, Slack, repair | Not exercised end to end. | Use safe fixtures or an explicitly authorized runtime. |

## Build diagnosis

- Read the first build error before the `closeBundle` messages; the plugin may run even after failure.
- Treat incomplete `dist/` contents as failed output, even when some classic files were copied.
- Preserve the Vite watch exclusion for the external `3d` symlink.
- Verify generated CSS exists and reflects the SCSS source through the established editor workflow.
- Do not assume the ignored lockfile, private runtime files, or external models exist in a fresh checkout.
- Treat classic-script bundling warnings separately from missing-file errors; those scripts use the manual-copy plugin.

## Runtime diagnosis

- Access denied: inspect the applicable viewer, upload, or advanced list without dumping credentials or user tokens.
- Session restoration: inspect `GoogleAuth.checkSession`; it reads localStorage and is not a server session validation step.
- Missing status: distinguish proxy failure, printer failure, idle-job fields, and cached placeholder data.
- Missing model: check the expected basename and final-extension substitution; do not assume the printer upload populated the model library.
- Offline stream: inspect stream response headers, multipart boundaries, frame progress, cancellation, and reconnect behavior without logging the upstream credential-bearing URL.
- Local stream 404: the private development server does not implement `/stream`; the example URL alone does not configure a working stream.
- Repeated notifications after restart: inspect the configured monitor-state path, writable volume, restored cooldowns, and milestones using sanitized output.
- Repair appears successful: confirm which server handled the request and whether Python actually ran. The production upload handler currently disables repair.
- Missing Python support: follow the wrapper's `isPyMeshLabInstalled` check; requirements and image build status are insufficient evidence.
- Missing activity logs: inspect the browser's `/api/log.php` request, PHP routing, and writable log directory in an authorized runtime.

## Older documentation

- Use the canonical deep-dive files linked by `AGENTS.md` as the operating reference.
- Treat `docs/STL_REPAIR_GUIDE.md` as historical ADMesh material; its function names do not match the current wrapper.
- Treat README claims about complete repair installation and example setup as unverified where contradicted by current source.
- Keep the inherited SCSS prohibition, firmware observation, and host-networking rationale until explicitly superseded; unresolved evidence is recorded in `docs/decisions.md`.
- Do not copy old credential examples, full config dumps, or blind remote probes into new debugging instructions.
