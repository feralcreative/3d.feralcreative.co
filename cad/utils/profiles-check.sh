#!/usr/bin/env bash
#
# profiles-check.sh — compare Flash Studio's presets against the repo's copies.
#
# Usage:
#   utils/profiles-check.sh            # report differences
#   utils/profiles-check.sh --install  # copy repo -> app  (then restart Flash Studio)
#   utils/profiles-check.sh --capture  # copy app -> repo  (then commit)
#
# Why this exists
# ---------------
# Presets live in two places and neither is authoritative on its own. The app's
# user/ tree is what Flash Studio actually reads, and it is outside version
# control and one reinstall away from gone. docs/profiles/ is the durable,
# diffable record shared between Feral MacBook and Feral Studio, and it is
# inert — copying a file there changes no print.
#
# They drift, silently, and the drift is expensive. A setting tuned on one
# machine and not committed is invisible on the other; a setting committed and
# not installed is invisible to the GUI. Both have already happened here, and
# the second cost a print: the machine ran 265 C while the repo said 240.
#
# A preset is TWO files. The .json holds the settings; the .info sidecar is how
# Flash Studio registers it. Copy only the .json to another machine and the
# preset does not appear in the dropdown, with no error and no clue. Both are
# checked and copied here for that reason.
#
# This script never touches the app bundle's system profiles, only user presets.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="${REPO_ROOT}/docs/profiles"
APP_DIR="${APP_DIR:-$HOME/Library/Application Support/Orca-Flashforge/user/default}"

MODE="check"
ONLY_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --install) MODE="install"; shift ;;
    --capture) MODE="capture"; shift ;;
    --only)
      [[ $# -ge 2 && -n "$2" ]] || { echo "error: --only requires a preset name" >&2; exit 64; }
      ONLY_NAME="$2"; shift 2 ;;
    *) echo "usage: $0 [--install|--capture] [--only <preset-name>]" >&2; exit 64 ;;
  esac
done

if [[ ! -d "$APP_DIR" ]]; then
  echo "error: no Flash Studio user preset tree at $APP_DIR" >&2
  echo "  Is Flash Studio installed? Set APP_DIR to override." >&2
  exit 69
fi

differ=0
missing_app=0
missing_repo=0

for kind in filament process printer machine; do
  [[ -d "$REPO_DIR/$kind" || -d "$APP_DIR/$kind" ]] || continue

  # Every preset name seen on either side, .json and .info considered together.
  # `|| true` matters: with set -e and pipefail, a grep that matches nothing
  # returns 1 and kills the script mid-report. A directory holding only
  # .orca_printer bundles is exactly that case, and the failure is silent.
  names="$( { ls -1 "$REPO_DIR/$kind" 2>/dev/null; ls -1 "$APP_DIR/$kind" 2>/dev/null; } \
            | grep -E '\.(json|info)$' | sed -E 's/\.(json|info)$//' | sort -u || true )"
  [[ -n "$names" ]] || continue

  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    if [[ -n "$ONLY_NAME" && "$name" != "$ONLY_NAME" ]]; then continue; fi
    for ext in json info; do
      r="$REPO_DIR/$kind/$name.$ext"
      a="$APP_DIR/$kind/$name.$ext"

      if [[ -f "$r" && ! -f "$a" ]]; then
        echo "app  MISSING  $kind/$name.$ext"
        missing_app=1
        [[ "$MODE" == "install" ]] && mkdir -p "$APP_DIR/$kind" && cp "$r" "$a" && echo "         installed"
      elif [[ -f "$a" && ! -f "$r" ]]; then
        echo "repo MISSING  $kind/$name.$ext"
        missing_repo=1
        [[ "$MODE" == "capture" ]] && mkdir -p "$REPO_DIR/$kind" && cp "$a" "$r" && echo "         captured"
      elif [[ -f "$a" && -f "$r" ]]; then
        # .info carries a timestamp that changes without meaning, so a
        # difference there is only worth reporting for the json.
        if ! cmp -s "$a" "$r"; then
          if [[ "$ext" == "json" ]]; then
            echo "DIFFERS       $kind/$name.$ext"
            differ=1
            [[ "$MODE" == "install" ]] && cp "$r" "$a" && echo "         app  <- repo"
            [[ "$MODE" == "capture" ]] && cp "$a" "$r" && echo "         repo <- app"
          fi
        fi
      fi
    done
  done <<< "$names"
done

echo
if [[ "$MODE" == "check" ]]; then
  if [[ "$differ" -eq 0 && "$missing_app" -eq 0 && "$missing_repo" -eq 0 ]]; then
    echo "in sync"
  else
    echo "Out of sync. --install to push repo -> app, --capture to pull app -> repo."
    echo "Whichever you run, the settings only reach a PRINT once you re-slice."
    exit 1
  fi
else
  echo "done. Restart Flash Studio before slicing in the GUI, and verify the"
  echo "result in the G-code with utils/gcode-probe.py rather than on screen."
fi
