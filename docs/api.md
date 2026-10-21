# Proxy API

## Select the implementation first

- Inspect the current private server for the route being changed; the public examples do not define the complete runtime contract.
- Use the configured browser base URL. The production Nginx `/api/` prefix is removed before the request reaches Node.
- Keep dedicated routes before the production `app.all("*")` catch-all.
- Do not run endpoint probes against the printer or production proxy without task-specific authorization.

| Route | Current local implementation | Contract and caution |
|---|---|---|
| `/session` | Private proxy; `/api/session` through Nginx | GET validates the existing session cookie, POST establishes a session through the access hub, DELETE signs out. The model catalog uses GET as its authorization subrequest. |
| `/product` | Development POST; production catch-all | Proxy supplies printer credentials and forwards product information. |
| `/detail` | Development POST; production catch-all | Proxy supplies printer credentials and forwards status information. |
| `/job` | Development GET; production catch-all | Uses printer authentication headers upstream; development normalizes empty or unparseable job responses to no active job. |
| `/control` | Development POST | Forwards control fields; can affect hardware. Production catch-all does not allow this route. |
| `/upload` | Both private servers | Multipart file, caller email, and string-valued options; production repair is disabled. |
| `/gcode` | Both private servers | Advanced email allowlist, command dispatch, and physical printer effects. |
| `/stream` | Private production server | Long-lived multipart camera response; upstream failure returns 502 before response streaming begins. |
| `/health` | Private development server | Local server response; not proof that the printer is reachable. No matching production health endpoint. |
| `/uploadGcode` | Production catch-all allowlist | Direct upstream forwarding path; do not assume it shares `/upload` permission or repair checks. |
| `/api/log.php` | PHP handler from `utils/log.php` | POST JSON; rejects unsupported methods and invalid JSON, then appends activity data. |
| `/model-catalog/` | Filtered Node listing; Vite middleware locally | GET/HEAD directory listing with `name`, `type`, and `size` fields; production requires the existing session cookie. Reads the runtime model mount on each request with `Cache-Control: no-store`. It excludes files without an eligible SCAD project; the gallery no longer uses a directory-listing fallback. |
| `/models/catalog.json` | Node organization overlay; Vite middleware locally | GET/HEAD; schema 1 in `docs/model-catalog.md`. `Cache-Control: no-store`. Visible inventory retains existing access; hidden inventory requires the signed admin session. 404 when no catalog is published. |
| `/models/<file>` | Nginx static file from the models mount; Vite middleware locally | GET/HEAD for a flat basename. Hidden files require an admin session. A missing file is a 404, not the HTML shell. `?v=<sha256 prefix>` is ignored by the server and only varies the browser cache key. |

## Upload contract

- Use multipart field `file` for the file payload.
- Preserve `userEmail` and the existing `x-user-email` fallback; these values are caller assertions, not verified identity.
- Preserve the string comparisons for `sendToPrinter`, `startPrint`, `levelBeforePrint`, and `skipRepair`.
- Keep download-only behavior when `sendToPrinter` is false.
- Preserve the current file filter and size limit in the selected server; keep UI validation aligned with them.
- Handle a file-download response separately from a JSON response; preserve Content-Disposition filename handling.
- Treat 403 as the upload or advanced allowlist denial, 400 as request validation failure where explicitly handled, and 500 as a server failure. Multer errors must be checked separately from handler responses.
- Preserve temporary-file cleanup in download callbacks and failure paths.
- Do not infer repaired geometry from the response filename or UI success text.

## Permissions and runtime limitations

- `GoogleAuth` sends the Google credential to the proxy and restores user data from the proxy session cookie. The model catalog authorizes against that same session endpoint.
- The private server upload and G-code checks use email lists; they do not verify that the caller owns the supplied email.
- Development `DEV_MODE` does not automatically satisfy server permission lists.
- Production monitor startup is independent of API requests and browser authentication.
- Full authenticated end-to-end validation: TBD.

## Model management

`GET /api/model-library/manage` requires an existing signed admin session and returns the complete catalog, revision and `canUndo`. `POST` takes `{revision, action, ids, files, target, title, category}`; only fields used by the action are needed. Actions are `hide`, `show`, `hide-files`, `show-files`, `category`, `move`, `merge`, `split`, and `undo`. No request can supply new filesystem paths, file payloads or arbitrary catalog records. Invalid operations fail before persistence. Unauthorized requests return 401/403; stale revisions return 409; unavailable/corrupt storage returns 503. POST requires an Origin matching Host and JSON content type. The production proxy strips `/api/` as with existing routes.

`/model-library/catalog`, `/model-library/listing` and `/model-library/file-access` back the Nginx model routes. Listing requires a viewer session; management always requires admin. The internal file-access subrequest uses `X-Model-URI` supplied by Nginx, checks the requested basename against project filenames, legacy aliases and export stems, and denies hidden assets to non-admins. The catalog returns hidden inventory only to admins. These handlers never contact the printer.

SCAD eligibility is checked in the effective visitor catalog, listing, direct-file visibility and publish actions. The generated `has_scad` flag must be true for current contributor models; missing flags fail closed. Management GET retains source-less projects for admins, but publishing them returns 400 with a SCAD-required message. Moving/merging/splitting preserves contributor source IDs rather than trusting a saved admin eligibility flag.
