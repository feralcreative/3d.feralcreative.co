#!/usr/bin/env bash
#
# slice.sh — slice a part with Flash Studio from the command line, verifiably.
#
# Usage:
#   utils/slice.sh stl/hobbs-chalk-holder.stl
#   utils/slice.sh parts/hobbs-chalk-holder.scad          # builds the STL first
#   utils/slice.sh stl/x.stl --stock                      # no low-string overrides
#   utils/slice.sh stl/x.stl --set filament:nozzle_temperature=235
#   utils/slice.sh stl/x.stl --at-z 38                    # role breakdown up the collet
#   utils/slice.sh stl/gridfinity/x.stl --magnet-pause    # enclosed 10x2 mm magnets
#
# Output lands in slice/<part>/ — plate_1.gcode, out.gcode.3mf, resolved.json —
# and the sliced job is also copied to 3mf/<part>.3mf, which is the file to
# hand to the printer: named after the part rather than the slicer's fixed
# "out.gcode.3mf", and in one flat tree rather than a directory per job.
#
# This EXPORTS NOTHING TO THE PRINTER. It slices and reports. Sending a job is a
# deliberate, separate act.
#
# Why it does not simply point the CLI at the installed profiles
# --------------------------------------------------------------
# Because that silently produces the wrong print. Flash Studio profiles are thin
# overlays chained by `inherits`, and the CLI does not walk the chain — only the
# keys physically present in the file you name take effect, and everything else
# falls back to the slicer's built-in defaults rather than the parent profile. A
# slice driven straight from the bundle's PETG profile came out as PLA at 2 mm3/s
# with zero-width walls. utils/ffprofile.py resolves the chains and writes flat
# profiles instead, which is what gets loaded here.
#
# Nor does it trust the GUI. On 2026-08-09 a correct user filament preset was
# written, correctly selected, and contributed nothing to the sliced job: the
# project kept a stale configuration and the print ran 25 C too hot, which cost
# the top 6.41 mm of a collet. The overrides below are therefore applied to the
# resolved profile every run, and the G-code is read back afterwards to confirm
# they arrived. Trust the probe output, not the fact that a command succeeded.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTROOT="${OUTROOT:-${REPO_ROOT}/slice}"
MF_ROOT="${MF_ROOT:-${REPO_ROOT}/3mf}"

FS_APP="${FS_APP:-/Applications/Flash Studio.app}"
FS_BIN="${FS_APP}/Contents/MacOS/Flash Studio"
FS_PROFILES="${FS_APP}/Contents/Resources/profiles/Flashforge"

MACHINE="${MACHINE:-Flashforge Adventurer 5M Pro 0.4 Nozzle}"

# Our own presets are the default, and they are the single source of truth for
# every value. This script used to default to the stock parents and then paste a
# hardcoded array of overrides on top; because command-line overrides outrank
# everything, that array silently beat the preset. It carried retraction 1.6 --
# the value that ground the extruder on 2026-08-10 -- long after the preset had
# been corrected to 0.4. Do not reintroduce it. If a value needs changing,
# change it in docs/profiles/ and reinstall, so the repo and the app agree.
PROCESS="${PROCESS:-0.12mm Fine @AD5M Pro 0.4 - Low String}"
FILAMENT="${FILAMENT:-Rapid PETG Burnt Titanium}"

# The plate on the machine. This is a project setting, not a preset one, so
# it cannot live in docs/profiles/ — it selects which of a filament preset's
# *_plate_temp values the slicer reads, and without it every job was sliced
# for a "Cool Plate" the printer does not have. The AD5M Pro ships with a
# double-sided textured PEI plate.
BED_TYPE="${BED_TYPE:-Textured PEI Plate}"

# --stock drops back to the untuned FlashForge stack, for comparison only.
STOCK_PROCESS="0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle"
STOCK_FILAMENT="Flashforge HS PETG"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <part.scad|file.stl|file.3mf> [--stock] [--set kind:key=value] [--at-z Z] [--magnet-pause]" >&2
  exit 64
fi

INPUT="$1"
shift

STOCK=0
AT_Z=""
MAGNET_PAUSE=0
EXTRA_SETS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stock) STOCK=1; shift ;;
    --set)   EXTRA_SETS+=("$2"); shift 2 ;;
    --at-z)  AT_Z="$2"; shift 2 ;;
    --magnet-pause) MAGNET_PAUSE=1; shift ;;
    *) echo "error: unknown argument: $1" >&2; exit 64 ;;
  esac
done

if [[ ! -f "$INPUT" ]]; then
  echo "error: no such file: $INPUT" >&2
  exit 66
fi

if [[ ! -x "$FS_BIN" ]]; then
  echo "error: Flash Studio not found at $FS_BIN" >&2
  echo "  Set FS_APP to its location." >&2
  exit 69
fi

# A .scad gets meshed first, so one command goes from source to sliced job.
# build.sh already reports manifoldness and genus, which is worth seeing.
#
# The unversioned name is deliberate. build.sh stamps its output as
# stl/<name>-v01.stl and points stl/<name>.stl at the newest, so this picks up
# the mesh just built while keeping the slice directory a stable
# slice/<part>/ — the path STATUS.md and the plan files quote. Slice a specific
# version by naming its file: utils/slice.sh stl/<name>-v03.stl.
if [[ "$INPUT" == *.scad ]]; then
  echo "== building mesh"
  "${REPO_ROOT}/utils/build.sh" "$INPUT"
  INPUT="stl/$(basename "$INPUT" .scad).stl"
fi

BASE="$(basename "${INPUT%.*}")"
OUTDIR="${OUTROOT}/${BASE}"
PROFDIR="${OUTDIR}/profiles"
rm -rf "$OUTDIR"
mkdir -p "$PROFDIR"

if [[ "$STOCK" -eq 1 ]]; then
  PROCESS="$STOCK_PROCESS"
  FILAMENT="$STOCK_FILAMENT"
fi

# Only what the caller asked for on this invocation. Everything else comes from
# the presets, so what gets sliced is what the repo says.
SETS=()
for s in "${EXTRA_SETS[@]+"${EXTRA_SETS[@]}"}"; do SETS+=(--set "$s"); done

echo "== resolving profiles"
"${REPO_ROOT}/utils/ffprofile.py" \
  --bundle "$FS_PROFILES" \
  --machine "$MACHINE" \
  --process "$PROCESS" \
  --filament "$FILAMENT" \
  --bed-type "$BED_TYPE" \
  "${SETS[@]+"${SETS[@]}"}" \
  --outdir "$PROFDIR" >/dev/null

# ffprofile reports the resolved chains and every override on stderr, which is
# left visible above; the JSON path map on stdout is what got swallowed.
MACHINE_JSON="${PROFDIR}/machine.json"
PROCESS_JSON="${PROFDIR}/process.json"
FILAMENT_JSON="${PROFDIR}/filament.json"

if [[ "$MAGNET_PAUSE" -eq 1 ]]; then
  [[ "$INPUT" == *.stl ]] || {
    echo "error: --magnet-pause requires the Gridfinity STL path" >&2
    exit 64
  }
  MAGNET_STL="$INPUT"
  # Export the fully resolved config without invoking the broken CLI thumbnail
  # renderer. The source project supplies CPU thumbnails and a native pause.
  "$FS_BIN" --load-settings "${MACHINE_JSON};${PROCESS_JSON}" \
    --load-filaments "$FILAMENT_JSON" \
    --export-settings "${OUTDIR}/pause-settings.json" "$INPUT" \
    >"${OUTDIR}/pause-settings.log" 2>&1
  python3 "${REPO_ROOT}/utils/magnet-project.py" "$INPUT" \
    "${OUTDIR}/magnet-project.3mf" --settings "${OUTDIR}/pause-settings.json"
  INPUT="${OUTDIR}/magnet-project.3mf"
fi

echo "== slicing"
# Two path quirks, both learned the hard way and neither documented upstream:
#   --export-3mf is resolved RELATIVE TO --outputdir, so an absolute path here
#     produces /out/dir//abs/path and the export fails after a full slice.
#   --export-settings ignores --outputdir entirely and writes relative to the
#     current directory, so it needs an absolute path to land anywhere useful.
"$FS_BIN" \
  --slice 0 \
  --load-settings "${MACHINE_JSON};${PROCESS_JSON}" \
  --load-filaments "${FILAMENT_JSON}" \
  --outputdir "$OUTDIR" \
  --export-settings "${OUTDIR}/resolved.json" \
  --export-3mf "out.gcode.3mf" \
  "$INPUT" \
  >"${OUTDIR}/slice.log" 2>&1 || {
    echo "error: slice failed. Last lines of ${OUTDIR}/slice.log:" >&2
    grep -viE 'FF_CRASH_TRACE' "${OUTDIR}/slice.log" | tail -15 >&2
    exit 70
  }

GCODE="${OUTDIR}/plate_1.gcode"
if [[ ! -f "$GCODE" ]]; then
  echo "error: no plate_1.gcode produced; see ${OUTDIR}/slice.log" >&2
  exit 70
fi

echo "== job"
PROBE_ARGS=("$GCODE")
[[ -n "$AT_Z" ]] && PROBE_ARGS+=(--at-z "$AT_Z")
"${REPO_ROOT}/utils/gcode-probe.py" "${PROBE_ARGS[@]}"

if [[ "$MAGNET_PAUSE" -eq 1 ]]; then
  python3 "${REPO_ROOT}/utils/magnet-project.py" "$MAGNET_STL" \
    "${OUTDIR}/out.gcode.3mf" --verify
fi

# The named copy. Flash Studio always writes out.gcode.3mf, so the part's name
# is put back on the file here, where the printer-bound copy lives.
mkdir -p "$MF_ROOT"
MF_OUT="${MF_ROOT}/${BASE}.3mf"
cp "${OUTDIR}/out.gcode.3mf" "$MF_OUT"

echo
echo "wrote $OUTDIR"
echo "wrote $MF_OUT"
echo "NOT sent to the printer."
