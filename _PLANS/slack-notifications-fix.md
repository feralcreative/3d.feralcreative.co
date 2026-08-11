# Fix Slack notification reliability (server-side monitor) + add filament runout alert

## Context

Slack notifications from the 3D printer stream are unreliable. Investigation against the live container and the printer itself shows why:

1. **The server-side monitor has never worked.** `PrinterMonitor.getPrinterStatus()` in [printer-proxy-server.js:498-502](printer-proxy-server.js#L498-L502) unwraps `data.data`, but the printer returns `{"code":0,"detail":{…}}`. `data.data` is `undefined`, so the guard `if (data.code !== 0 || !data.data) return null` bails on **every** poll, silently, every 5 seconds. Verified by querying `http://192.168.1.66:8898/detail` directly and by the container log, which has emitted zero `[MONITOR]` lines since the printer IP was corrected earlier today.
2. **Every notification you actually received came from the browser.** The container's only Slack activity today is `[SLACK] Sending notification: 🟢 Print Started` / `📊 Print 50% Complete` on the `/api/notify` relay. Those emoji are the *client* format in [notifications.js](notifications.js); the monitor's format uses 🖨️. The source has the client hooks commented out ([printer.js:441-482](printer.js#L441-L482)) but `dist/` is stale (built Feb 10, sources May 23) and `dist/printer.js:443-475` still has them live. Net effect: notifications only fire when a browser tab happens to be open — hence "unreliable".
3. **A second latent bug behind the first:** [printer-proxy-server.js:504](printer-proxy-server.js#L504) reads `detail.Status`; the field is lowercase `status`. Even after fixing the unwrap, every state would parse to `"Unknown"`.

Outcome wanted: one reliable, always-on, server-side notifier that works with no browser open, plus a filament-runout alert.

## Decisions taken

- Client-side notification path is **removed entirely**, including the `/api/notify` and `/notify` relay routes (they are unauthenticated open relays that POST caller-supplied JSON to any caller-supplied URL — see [printer-proxy-server.js:362-388](printer-proxy-server.js#L362-L388) and [server.js:646-673](server.js#L646-L673)).
- Monitor state **persists to the existing `/app/data` volume** so restarts mid-print don't fire spurious events.
- Filament runout is detected **heuristically**, because the printer's `/detail` on firmware 5.1.8 does not expose the documented `hasLeftFilament`/`hasRightFilament` booleans. A full `/detail` snapshot is logged on every unexpected pause so the real signal can be identified from a genuine runout and the rule tightened later.

## Part 1 — Repair the monitor

All in `printer-proxy-server.js`, class `PrinterMonitor` ([lines 476-768](printer-proxy-server.js#L476-L768)).

**Response parsing** (`getPrinterStatus`, lines 486-513):

- Unwrap `data.detail` (fall back to `data.product || data.data || data`, matching the tolerant pattern already used at [printer.js:193](printer.js#L193)).
- Read `detail.status`, not `detail.Status`.
- Add `errorCode: detail.errorCode || ""` and carry the raw `detail` object through on the returned status so the runout logger can dump it.
- Add an `AbortSignal.timeout(4000)` to the `fetch`. There is currently no timeout, so a hung request can stack overlapping polls.

**Poll loop** (`monitor`/`start`, lines 731-754): add an in-flight guard so a slow poll can't overlap the next tick — mirror the `isUpdating` pattern already in [printer.js:334-341](printer.js#L334-L341) rather than inventing a new one.

**State machine** (`detectStateChanges`, lines 668-729) — three gaps that cause missed events:

| Event | Current rule | Problem | New rule |
| --- | --- | --- | --- |
| Started | `Ready → Printing` | Real transition is `Ready → Heating → Printing`, so start is missed | Fire on entering `Printing` from any non-printing state (`Ready`, `Heating`, `Busy`, `Calibrating`, `null`), guarded by the cold-start rule below |
| Completed | `Printing → Ready` with `previousProgress >= 99` | Printer reports `completed`/`finish` in between, so `Ready` never follows `Printing` directly | Fire on entering `Completed`, **or** on `Printing → Ready` with `previousProgress >= 99` |
| Failed | `Printing → Ready` with `0 < previousProgress < 99` | Misses the `cancel` status, and misses a cancel at ≥99% | Fire on entering `Cancelled`/`Error`, or `Printing → Ready` with `previousProgress < 99` |

Keep `parseState` ([lines 515-543](printer-proxy-server.js#L515-L543)) as-is but verify it covers the documented enum from the reference library (`docs/ff-5mp-api-ts-main/src/models/MachineInfo.ts:176-195`): `ready | busy | calibrate_doing | error | heating | printing | pausing | paused | cancel | completed`.

**Dedupe:** port the cooldown logic from [notifications.js:31-42](notifications.js#L31-L42) (`shouldNotify`/`markNotified`, 60 s per event key) into the monitor before deleting that file, so a flapping state can't spam the channel.

## Part 2 — Persist monitor state

New small module (suggested `utils/monitor-state.js`) that reads/writes a single JSON file at `process.env.MONITOR_STATE_PATH || "/app/data/monitor-state.json"`. The `data` directory is already mounted in [docker-compose.yml](docker-compose.yml) (`/volume1/web/3d-printer-stream/data:/app/data`), so no deployment change is needed.

- Persist: `previousState`, `previousProgress`, `previousFileName`, `milestonesSent` (array), `lastNotificationTime` map.
- Load in the `PrinterMonitor` constructor; write after each `detectStateChanges` that changes anything. Writes are small and infrequent — plain `writeFileSync` to a temp path then `rename` is sufficient.
- Missing or unreadable file falls back to a clean in-memory state; do not crash the proxy over it.
- Cold-start guard: if there was no persisted state and the first poll shows `Printing`, adopt it as the baseline silently (no "Print Started", no back-filled 50% milestone).

## Part 3 — Filament runout notification

There is no direct signal on this firmware. Confirmed by a live `/detail` capture — the response contains `errorCode`, `rightFilamentType`, `estimatedRightWeight`, `status`, but **no** `hasRightFilament`. TCP `~M405`/`~M406` only toggle the sensor; there is no read command (`docs/ff-5mp-api-ts-main/src/tcpapi/FlashForgeClient.ts:144,157`).

Implementation:

- New method `notifyPossibleRunout(status)` on `PrinterMonitor`, fired when the printer enters `Pausing`/`Paused`/`Error` while `0 < progress < 99` **and** the pause was not user-initiated via the app's own filament-change flow.
- Suppress for 5 minutes after a `/gcode` `FILAMENT_CHANGE` request ([printer-proxy-server.js:286](printer-proxy-server.js#L286)) so the deliberate filament-change prep doesn't trigger a false runout alert. A module-level timestamp set by that route is enough.
- Message: `⚠️ Print Paused — possible filament runout`, with file name, progress, `errorCode` (if any), and current material type. Gated by a new `SLACK_NOTIFICATIONS.FILAMENT_RUNOUT` flag alongside the existing flags at [printer-proxy-server.js:35-41](printer-proxy-server.js#L35-L41).
- This **replaces** the plain `notifyPrintPaused` for mid-print pauses (one message, not two); `notifyPrintPaused` stays for pauses that don't meet the runout heuristic.
- **Capture for later tightening:** on every unexpected pause, `console.log` the complete raw `/detail` JSON under a `[RUNOUT-CAPTURE]` tag. After the next real runout, grep the container log for that tag and identify the field that actually changed, then narrow the heuristic.

## Part 4 — Remove the client-side path

- Delete `notifications.js` and its `<script>` tag at [index.html:45](index.html#L45).
- Delete the `NotificationService` instantiation at [auth.js:283-288](auth.js#L283-L288).
- Delete the dead commented-out notify hooks at [printer.js:438-482](printer.js#L438-L482), keeping the `console.log` lines. `detectStateChanges` in `printer.js` still drives UI state, so leave the detection itself intact.
- Delete the `/api/notify` route ([printer-proxy-server.js:362-388](printer-proxy-server.js#L362-L388)) and the `/notify` route ([server.js:646-673](server.js#L646-L673)) plus its startup-banner line at [server.js:690](server.js#L690).
- Remove the `SLACK` block from `config.js` ([lines 107-122](config.js#L107)) — it puts the webhook URL in publicly served client JS. Also remove it from `config.example.js` if present. The webhook stays only in `printer-proxy-server.js`.
- Copy the file out of the Vite copy-plugin list at [vite.config.js:24-38](vite.config.js#L24-L38).

## Part 5 — Deploy hygiene

`dist/` was built Feb 10 while sources changed May 23 — that staleness is what kept the old browser-side notifier alive in production. Confirm `utils/deploy/prod.sh` runs `npm run build` as part of the Docker build (the Dockerfile build stage does `npm ci && npm run build`), and delete the local stale `dist/` before deploying so nothing old is picked up.

Optional, low cost, worth doing while in here: `PRINTER_IP`, serial, check code, and the Slack webhook are hardcoded in both `printer-proxy-server.js` and `server.js`. Read them from `process.env` with the current values as defaults, so the next IP change is a compose edit rather than a code edit. Flag only — say the word and I'll include it.

## Files touched

| File | Change |
| --- | --- |
| `printer-proxy-server.js` | Monitor parsing, timeout, in-flight guard, state machine, cooldown, persistence wiring, runout notification; delete `/api/notify` |
| `utils/monitor-state.js` | New — load/save monitor state JSON |
| `printer.js` | Remove dead notify hooks |
| `auth.js` | Remove `NotificationService` instantiation |
| `notifications.js` | Delete |
| `index.html` | Remove script tag |
| `config.js` / `config.example.js` | Remove `SLACK` block |
| `vite.config.js` | Remove `notifications.js` from copy list |
| `server.js` | Delete `/notify` route + banner line |

<!--| PAGE-BREAK -->

## Verification

**Local, before deploying:**

1. `node printer-proxy-server.js` on a machine that can reach `192.168.1.66`. Within 5 s the log must show `[MONITOR] State changed: null → Ready` — that single line proves the unwrap fix, since the monitor is currently silent.
2. Point `MONITOR_STATE_PATH` at a temp file, kill and restart the process, and confirm no notification fires on restart and the state file reloads.
3. Drive the state machine without a real print by pointing the monitor at a stub `/detail` responder (a few lines of Express in the scratchpad) and replaying the sequences `ready → heating → printing → completed → ready` and `ready → printing → cancel → ready`. Expect exactly one Started, one 50%, one Completed on the first; one Started, one Failed on the second. This is the only practical way to test completion and failure paths without burning filament.
4. Temporarily point `SLACK_WEBHOOK_URL` at a local listener for these runs so the real channel stays quiet.

**On the printer, after deploying:**

1. Start a small real print. Expect exactly one `🖨️ Print Started` in Slack and one `[MONITOR] State changed` line per real transition in `docker logs 3d-printer-stream`.
2. Close every browser tab and confirm notifications keep arriving — that is the actual fix for the reported problem.
3. Pause the print from the printer's touchscreen mid-job and confirm the `⚠️ possible filament runout` message plus a `[RUNOUT-CAPTURE]` log dump; resume and let it finish.
4. Confirm no duplicate messages, which would mean a stale `dist/` is still being served.
5. `curl -X POST https://3dprinter.feralcreative.co/api/notify -d '{}'` must now 404 — confirms the open relay is gone.
