# Proxy API

## Select the implementation first

- Inspect the current private server for the route being changed; the public examples do not define the complete runtime contract.
- Use the configured browser base URL. The production Nginx `/api/` prefix is removed before the request reaches Node.
- Keep dedicated routes before the production `app.all("*")` catch-all.
- Do not run endpoint probes against the printer or production proxy without task-specific authorization.

| Route | Current local implementation | Contract and caution |
|---|---|---|
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

- `GoogleAuth` decodes the Google credential in the browser and restores user data from localStorage.
- The private server upload and G-code checks use email lists; they do not verify that the caller owns the supplied email.
- Development `DEV_MODE` does not automatically satisfy server permission lists.
- Production monitor startup is independent of API requests and browser authentication.
- Full authenticated end-to-end validation: TBD.
