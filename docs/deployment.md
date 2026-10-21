# Runtime setup and deployment

## Authorization and verification

- Require explicit task-specific permission before deploying, transferring files, touching a remote server, or changing cloud state.
- Use the `personal-knowledge` skill’s migrated deployment procedures (`references/docs/DEPLOY_SCRIPT_INSTRUCTIONS.md`) when modifying deployment scripts. This repository uses the existing standalone Docker-on-NAS flow; the former `ziad-deploy-workflows` skill is not installed here.
- Use the existing `utils/deploy/` entrypoints; do not create a separate release mechanism for a documentation change.
- The revised deployment flow has passed isolated tests and an offline dry run. A real release with this revision and rollback execution remain unverified.
- The 2026-09-28 documentation pass read local source only; it did not verify the running production system.

## Build-context prerequisites

- Obtain private `config.js`, `server.js`, and `printer-proxy-server.js` from Ziad through the established private configuration channel.
- Do not overwrite populated private files with examples. The examples omit configuration keys and endpoints required by the current app.
- `npm run build` generates expanded and minified CSS before Vite. For local watch mode, use `npm start`.
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

## Production release command

Run from any working directory; the entrypoint resolves the unified repository root:

```bash
utils/deploy/prod.sh --help
utils/deploy/prod.sh --dry-run
utils/deploy/prod.sh
```

The script requires a clean working tree on `main`. `--force` permits a dirty tree or another branch; it never bypasses the production confirmation prompt. An offline preview in the current working checkout can use `utils/deploy/prod.sh --dry-run --force`. Help has no side effects; dry-run validates the publication destination and prints the plan without loading `.env`, generating models, building an image, contacting the NAS, uploading, restarting services or purging caches.

A real invocation performs these steps in order:

1. Confirm the CAD publisher uses the same SSH destination and models volume as the application. Check the private runtime files and lockfile required by the Docker build. Ask for `yes` before doing release work, then load `.env` without splitting quoted values.
2. Refresh the complete catalog and all configured coloured presentations through `utils/models.sh --render-colours`. Reject failed configured views, missing or incomplete selected files, unsafe paths and SHA-256 mismatches. Conversion warnings for retained unsupported originals do not by themselves block deployment.
3. Build the existing Linux/AMD64 Docker image. Run the image with a Node-only entrypoint to check entry HTML, its bundles/CSS, copied classic scripts, manifest and environment maps. This artifact check does not start the production proxy or printer monitor. Save the image to a temporary compressed archive.
4. Transfer/load the image, then invoke the existing CAD publisher with the selected SSH identity. It dereferences staging links, checksums file transfers, preserves unrelated remote files and publishes `catalog.json` only after the selected assets succeed. A publication failure stops before the application container is recreated.
5. Transfer Compose and run `up -d --force-recreate`. Host networking and existing data/log/model mounts are preserved. The script does not run `down` first.
6. Verify the running container uses the loaded image; check the deployed catalog hash and every selected asset's presence/size inside the model mount. Retry startup checks through Nginx, then verify the public HTTPS routes. Both `/models` spellings and the catalog must work, and representative STL and GLB downloads must return the right MIME type, byte count and SHA-256. A failure prevents the success summary.
7. Purge Cloudflare cache when configured; a purge failure is non-fatal. Print the verified release summary and remove the local image archive on exit.

The app and library remain separate storage concerns, but the production entrypoint now coordinates both. Generated catalog assets stay out of the Docker context. Local CAD-only updates can still use `utils/models.sh --push` when explicitly authorized. The CAD publisher respects `SSH_KEY_PATH`, including paths containing spaces; otherwise SSH uses its normal configured identity/agent.

## Verification and limits

```bash
bash -n utils/deploy/prod.sh cad/utils/deploy/catalog.sh
python3 utils/test-prod-deploy.py
node --check utils/verify-model-deployment.mjs
node --test utils/verify-model-deployment.test.mjs
python3 cad/utils/test-catalog-publish.py
python3 cad/utils/test-web-library.py
npm run build
node utils/verify-model-deployment.mjs --build dist
```

The production-entrypoint tests use isolated fake Git, Docker, SSH, publication and cache-purge commands. They cover offline/help behavior, Git gates, confirmation, mismatched destinations, asset validation, release ordering, identity paths containing spaces, publication/build/verification failures and non-fatal cache purge. The suite skips if the ignored private entrypoint is unavailable in a clean checkout. The Node tests use temporary files and a loopback HTTP fixture, including catalog outages, HTML returned for model routes, truncated/wrong downloads and redirects. Publisher tests prove asset-first/catalog-last ordering and transfer-failure propagation. Exporter regression coverage also checks case-only filename collisions, including stale staging symlinks, without modifying originals. These are not a live release or container-runtime verification.

Preserve the Debian-based package installation, Nginx/PHP paths, host networking, persistent mounts, unbuffered proxying and extended stream timeouts. Nginx serves the exact `/models` and `/models/` HTML routes; it proxies the effective catalog/listing to the model-management middleware and checks model-file visibility through an internal subrequest. `utils/verify-model-deployment.mjs` is copied into the runtime image with the existing `utils/` copy.

The private `utils/deploy/deploy-utils.sh` remains the management entrypoint; it includes remote mutations, and even its log/status reads require remote-access authorization. Checked-in `.example.sh` files remain templates. Production restarts, public sign-in, printer/stream behavior, real Cloudflare purge and rollback remain separate runtime checks. No actual deployment was performed while modifying the script.
