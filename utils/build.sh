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
#   utils/build.sh parts/example-spacer.scad --push     # copy to the NAS (see below)
#
# --push rsyncs the STL to the printer site's models directory on the NAS, which
# is bind-mounted into the 3d-printer-stream container, so the model shows up in
# the web viewer without a rebuild.
#
# NEVER pass --push without Ziad explicitly asking for it. It writes to a live
# production host.

set -euo pipefail

OUTDIR="${OUTDIR:-stl}"

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
  echo "usage: $0 <part.scad> [--push] [extra openscad args...]" >&2
  exit 64
fi

SCAD="$1"
shift

PUSH=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--push" ]]; then
    PUSH=1
  else
    ARGS+=("$arg")
  fi
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

echo "rendering $SCAD -> $OUT (this may take a while)"
"$OPENSCAD" -o "$OUT" "${ARGS[@]+"${ARGS[@]}"}" "$SCAD"
echo "built $OUT ($(du -h "$OUT" | cut -f1))"

if [[ "$PUSH" -eq 1 ]]; then
  echo "pushing to ${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  rsync -avz -e "ssh -p ${NAS_PORT}" "$OUT" "${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  echo "pushed. visible at https://3d.feralcreative.co/?model=${BASE}"
fi
