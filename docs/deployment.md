# Runtime setup and deployment

## Authorization and verification

- Require explicit task-specific permission before deploying, transferring files, touching a remote server, or changing cloud state.
- Read the installed `ziad-deploy-workflows` skill before modifying or running deployment scripts.
- Use the existing `utils/deploy/` entrypoints; do not create a separate release mechanism for a documentation change.
- Deployment and rollback execution: TBD.
- The 2026-09-28 documentation pass read local source only; it did not verify the running production system.

## Build-context prerequisites

- Obtain private `config.js`, `server.js`, and `printer-proxy-server.js` from Ziad through the established private configuration channel.
- Do not overwrite populated private files with examples. The examples omit configuration keys and endpoints required by the current app.
- Obtain generated CSS through the existing Live Sass Compile workflow.
- Resolve model availability with Ziad before building; do not silently remove missing model references.
- Docker invokes `npm ci` in its stages, while Git ignores the lockfile. Confirm the local build context includes a valid lockfile before an authorized container build.
- `requirements.txt` currently has no active PyMeshLab dependency. The Docker Python install tolerates failure; container build success does not prove repair support.
- Keep `.env.example` as the checked-in environment template. A complete template covering the current private runtime remains TBD.

## Credential sources

| Name | Private location or source | Acquisition |
|---|---|---|
| `GOOGLE_CLIENT_ID` | `config.js`; public identifier obtained from Google OAuth configuration | Request the approved web client configuration from Ziad. |
| `client_secret` | OAuth client JSON in `.secrets/` | Request access from Ziad; never place it in browser configuration. |
| `CONFIG.PRINTER.SERIAL`, `CONFIG.PRINTER.CHECK_CODE` | Private browser configuration and corresponding private proxy configuration | Obtain printer settings through Ziad. |
| `CAMERA_STREAM_URL` | Private production proxy setting or environment override | Request the Surveillance Station stream configuration from Ziad; the URL carries the stream credential. |
| `SLACK_WEBHOOK_URL` | Private production proxy configuration | Request the approved server-side webhook from Ziad. |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID` | Local `.env`, named in `.env.example` | Request the approved cache-purge configuration from Ziad. |
| `SESSION_SECRET` | Named in `.env.example` | Runtime use is unverified; do not assume it secures the current browser session. |
| SSH access settings | Private deployment scripts and `.vscode/sftp.json` | Obtain host, port, identity, and access instructions from Ziad. |

- Preserve the ignore rules for `.env`, `.env.*.local`, `.secrets/`, `.vscode/`, private runtime JavaScript, and private deploy scripts.
- Never put the contents of these files into a commit, diagnostic dump, or chat response.
- Keep all credentials out of the new canonical docs, including masked forms and URL query values.

## Existing release mechanism

- The private `utils/deploy/prod.sh` builds an image, saves and transfers it over SSH, loads it remotely, applies Compose, and purges Cloudflare cache.
- Its current source does not implement the standard dry-run, force, help, or Git-state gates. Do not invoke it with a supposed harmless flag to inspect behavior.
- `utils/deploy/deploy-utils.sh` includes operations that contact and mutate the remote system; even log or status access requires the user's remote-access authorization.
- The checked-in `.example.sh` files are templates, not configured deployment commands.
- Preserve the existing Debian-based Docker package installation and Nginx/PHP paths; a prior partial Alpine conversion broke those assumptions.
- Preserve host networking and the data, logs, and models mounts unless the deployment task explicitly changes them.
- Preserve unbuffered proxying and the extended read timeout for MJPEG streams.
- Verify the image running remotely and the requested application behavior after an authorized release; a local build or image transfer is not deployment confirmation.
