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
# Part colour and background together; OpenSCAD's default is Cornfield, the
# yellow-on-cream look. Ziad chose Metallic on 2026-09-12, then a magenta
# part on a deep purple (#404) ground, which no built-in scheme has. Custom
# schemes live in the repo under docs/color-schemes/ and are read only from
# OpenSCAD's user config directory, so each one is copied there before the
# render whenever it is missing or stale. Override per run with COLORSCHEME=...
COLORSCHEME="${COLORSCHEME:-Feral Magenta}"

# Libraries live in lib/, which is not one of OpenSCAD's default search paths.
# Exporting OPENSCADPATH is what lets a part say `include <BOSL2/std.scad>` and
# have it resolve — and it works no matter which directory you invoke from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export OPENSCADPATH="${REPO_ROOT}/lib${OPENSCADPATH:+:$OPENSCADPATH}"

SCHEME_SRC="$REPO_ROOT/docs/color-schemes"
SCHEME_DST="${OPENSCAD_USER_CONFIG:-$HOME/Library/Application Support/OpenSCAD}/color-schemes/render"
if [[ -d "$SCHEME_SRC" ]]; then
  mkdir -p "$SCHEME_DST"
  for f in "$SCHEME_SRC"/*.json; do
    [[ -e "$f" ]] || continue
    cmp -s "$f" "$SCHEME_DST/$(basename "$f")" || cp "$f" "$SCHEME_DST/"
  done
fi

# view name : rot_x,rot_y,rot_z : projection
#
# Orthographic on the three elevations so they read as true drawings — no
# perspective taper, so edges that should line up visibly line up. Iso stays
# perspective purely because it looks better as an overview.
VIEWS=(
  "iso:55,0,25:p"
  "front:90,0,0:o"
  "right:90,0,90:o"
  "top:0,0,0:o"
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
  IFS=':' read -r name rot proj <<< "$view"
  out="$OUTDIR/${BASE}-${name}.png"

  # gimbal camera: translate_x,y,z , rot_x,y,z , dist
  # dist is 0 because --viewall computes it to frame the whole model.
  "$OPENSCAD" \
    -o "$out" \
    --imgsize="$IMGSIZE" \
    --colorscheme="$COLORSCHEME" \
    --camera="0,0,0,${rot},0" \
    --projection="$proj" \
    --viewall \
    --autocenter \
    "$@" \
    "$SCAD"

  echo "rendered $out"
done
