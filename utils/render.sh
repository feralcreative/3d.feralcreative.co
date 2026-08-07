#!/usr/bin/env bash
#
# render.sh — render a .scad part to multi-angle PNGs for visual review.
#
# This is the feedback loop that lets an agent SEE what it just wrote.
# Always run this after editing a part, and always look at the output.
#
# Usage:
#   utils/render.sh parts/example-spacer.scad
#   utils/render.sh parts/example-spacer.scad -D 'outer_d=30'
#
# Output lands in renders/<part>-<view>.png

set -euo pipefail

IMGSIZE="${IMGSIZE:-1200,900}"
OUTDIR="${OUTDIR:-renders}"

# view name : rot_x,rot_y,rot_z
VIEWS=(
  "iso:55,0,25"
  "front:90,0,0"
  "right:90,0,90"
  "top:0,0,0"
)

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
  echo "usage: $0 <part.scad> [extra openscad args...]" >&2
  exit 64
fi

SCAD="$1"
shift

if [[ ! -f "$SCAD" ]]; then
  echo "error: no such file: $SCAD" >&2
  exit 66
fi

OPENSCAD="$(find_openscad)" || {
  echo "error: openscad not found." >&2
  echo "  Install it, or symlink /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD onto PATH." >&2
  exit 69
}

BASE="$(basename "$SCAD" .scad)"
mkdir -p "$OUTDIR"

for view in "${VIEWS[@]}"; do
  name="${view%%:*}"
  rot="${view##*:}"
  out="$OUTDIR/${BASE}-${name}.png"

  # gimbal camera: translate_x,y,z , rot_x,y,z , dist
  # dist is 0 because --viewall computes it to frame the whole model.
  "$OPENSCAD" \
    -o "$out" \
    --imgsize="$IMGSIZE" \
    --camera="0,0,0,${rot},0" \
    --viewall \
    --autocenter \
    "$@" \
    "$SCAD"

  echo "rendered $out"
done
