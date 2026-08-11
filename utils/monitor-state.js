/**
 * Printer Monitor State Persistence
 *
 * The printer monitor keeps a small amount of state (last known machine state,
 * progress, filename, milestones already sent, notification cooldowns). Holding
 * that only in memory means a container restart mid-print looks like a brand new
 * print, which fires a spurious "Print Started" and re-sends the 50% milestone.
 *
 * This module persists that state to a JSON file on the mounted data volume.
 * Every failure path here is non-fatal — the monitor must keep running even if
 * the state file is missing, unreadable, or unwritable.
 */

import { readFileSync, writeFileSync, renameSync, mkdirSync, existsSync } from "fs";
import { dirname } from "path";

const STATE_PATH = process.env.MONITOR_STATE_PATH || "/app/data/monitor-state.json";

const EMPTY_STATE = {
  previousState: null,
  previousProgress: 0,
  previousFileName: null,
  milestonesSent: [],
  lastNotificationTime: {},
};

/**
 * Load persisted monitor state.
 * Returns { state, existed } — `existed` is false when there was nothing usable
 * on disk, which the monitor uses to decide whether it is cold-starting.
 */
export function loadMonitorState() {
  try {
    if (!existsSync(STATE_PATH)) {
      console.log(`[MONITOR-STATE] No state file at ${STATE_PATH} - cold start`);
      return { state: { ...EMPTY_STATE }, existed: false };
    }

    const parsed = JSON.parse(readFileSync(STATE_PATH, "utf-8"));

    const state = {
      previousState: parsed.previousState ?? null,
      previousProgress: typeof parsed.previousProgress === "number" ? parsed.previousProgress : 0,
      previousFileName: parsed.previousFileName ?? null,
      milestonesSent: Array.isArray(parsed.milestonesSent) ? parsed.milestonesSent : [],
      lastNotificationTime:
        parsed.lastNotificationTime && typeof parsed.lastNotificationTime === "object" ? parsed.lastNotificationTime : {},
    };

    console.log(
      `[MONITOR-STATE] Restored: state=${state.previousState} progress=${state.previousProgress}% file=${state.previousFileName}`
    );
    return { state, existed: true };
  } catch (error) {
    console.error("[MONITOR-STATE] Could not read state file, starting clean:", error.message);
    return { state: { ...EMPTY_STATE }, existed: false };
  }
}

/**
 * Persist monitor state. Writes to a temp file then renames so a crash
 * mid-write can never leave a truncated JSON file behind.
 */
export function saveMonitorState(state) {
  try {
    const dir = dirname(STATE_PATH);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }

    const tmpPath = `${STATE_PATH}.tmp`;
    writeFileSync(tmpPath, JSON.stringify(state, null, 2), "utf-8");
    renameSync(tmpPath, STATE_PATH);
    return true;
  } catch (error) {
    console.error("[MONITOR-STATE] Failed to save state:", error.message);
    return false;
  }
}

export { STATE_PATH };
