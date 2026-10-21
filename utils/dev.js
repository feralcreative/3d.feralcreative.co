import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

// Keep generated styles ready before Vite starts, and stop every watcher/server
// together when Ctrl+C is pressed or one of the processes fails.
const children = new Set();
const root = fileURLToPath(new URL("../", import.meta.url));
const npm = process.env.npm_execpath;
let stopping = false;

function stop(code = 0) {
  if (stopping) return;
  stopping = true;
  process.exitCode = code;
  for (const child of children) {
    try {
      if (process.platform === "win32") child.kill("SIGTERM");
      else process.kill(-child.pid, "SIGTERM");
    } catch (error) {
      if (error.code !== "ESRCH") console.error("Could not stop development process:", error.message);
    }
  }
}

function run(script) {
  return new Promise((resolve) => {
    const child = spawn(process.execPath, [npm, "run", script], {
      cwd: root,
      stdio: "inherit",
      detached: process.platform !== "win32",
    });
    children.add(child);
    child.on("error", (error) => {
      children.delete(child);
      console.error(`Could not start ${script}: ${error.message}`);
      stop(1);
      resolve(1);
    });
    child.on("exit", (code) => {
      children.delete(child);
      resolve(code ?? 1);
    });
  });
}

process.on("SIGINT", () => stop());
process.on("SIGTERM", () => stop());

if (!npm) {
  console.error("Run this development launcher with npm start.");
  process.exitCode = 1;
} else {
  const code = await run("build:css");
  if (code !== 0) stop(code);
  if (!stopping) {
    for (const script of ["sass:watch", "sass:watch:min", "proxy", "dev"]) {
      run(script).then((exitCode) => stop(exitCode));
    }
  }
}
