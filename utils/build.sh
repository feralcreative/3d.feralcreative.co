#!/usr/bin/env bash
#
# build.sh — full-render a .scad part to STL.
#
# This runs OpenSCAD's real (F6/CGAL-or-Manifold) render, not the fast preview,
# so it can be slow on complex parts. Output goes to stl/<part>.stl.
#
# Usage:
#   utils/build.sh parts/example-spacer.scad
#   utils/build.sh parts/example-spacer.scad -D 'outer_d=30'
#   utils/build.sh parts/example-spacer.scad --ascii    # ASCII STL instead of binary
#   utils/build.sh parts/example-spacer.scad --push     # copy to the NAS (see below)
#
# STLs come out binary. OpenSCAD's own default is ASCII, which is the same
# geometry at roughly seven times the size — a part carrying artwork runs to
# tens of megabytes, which is slow to rsync and worse to open in the web viewer.
# Pass --ascii if you need to read or diff the mesh by eye.
#
# --push rsyncs the STL to the printer site's models directory on the NAS, which
# is bind-mounted into the 3d-printer-stream container, so the model shows up in
# the web viewer without a rebuild.
#
# NEVER pass --push without Ziad explicitly asking for it. It writes to a live
# production host.

set -euo pipefail

OUTDIR="${OUTDIR:-stl}"

# Libraries live in lib/, which is not one of OpenSCAD's default search paths.
# Exporting OPENSCADPATH is what lets a part say `include <BOSL2/std.scad>` and
# have it resolve — and it works no matter which directory you invoke from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export OPENSCADPATH="${REPO_ROOT}/lib${OPENSCADPATH:+:$OPENSCADPATH}"

NAS_HOST="nas.feralcreative.co"
NAS_PORT="33725"
NAS_USER="ziad"
NAS_PATH="/volume1/web/3d-printer-stream/public/models"

find_openscad() {
  if command -v openscad >/dev/null 2>&1; then
    command -v openscad
  elif [[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]]; then
    echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
  else
    return 1
  fi
}

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <part.scad> [--ascii] [--push] [extra openscad args...]" >&2
  exit 64
fi

SCAD="$1"
shift

PUSH=0
FORMAT="binstl"
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --push)  PUSH=1 ;;
    --ascii) FORMAT="asciistl" ;;
    *)       ARGS+=("$arg") ;;
  esac
done

if [[ ! -f "$SCAD" ]]; then
  echo "error: no such file: $SCAD" >&2
  exit 66
fi

OPENSCAD="$(find_openscad)" || {
  echo "error: openscad not found." >&2
  exit 69
}

BASE="$(basename "$SCAD" .scad)"
OUT="$OUTDIR/${BASE}.stl"
mkdir -p "$OUTDIR"

# --export-format goes before the caller's own args, so passing one explicitly
# still wins.
echo "rendering $SCAD -> $OUT (this may take a while)"
"$OPENSCAD" -o "$OUT" --export-format="$FORMAT" "${ARGS[@]+"${ARGS[@]}"}" "$SCAD"
echo "built $OUT ($(du -h "$OUT" | cut -f1), $FORMAT)"

if [[ "$PUSH" -eq 1 ]]; then
  echo "pushing to ${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  rsync -avz -e "ssh -p ${NAS_PORT}" "$OUT" "${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  echo "pushed. visible at https://3d.feralcreative.co/?model=${BASE}"
fi
