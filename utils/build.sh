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
#   utils/build.sh parts/hobbs-chalk-holder.scad -D 'show="coupon"' \
#       --name hobbs-chalk-holder-coupon                # name a variant separately
#   utils/build.sh parts/example-spacer.scad --version 3 # restamp, do not increment
#   utils/build.sh parts/example-spacer.scad --no-version # plain name, no stamp
#
# STLs come out binary. OpenSCAD's own default is ASCII, which is the same
# geometry at roughly seven times the size — a part carrying artwork runs to
# tens of megabytes, which is slow to rsync and worse to open in the web viewer.
# Pass --ascii if you need to read or diff the mesh by eye.
#
# VERSIONS. Every build stamps a version into the filename —
# stl/<name>-v<N>.stl — and leaves stl/<name>.stl as a symlink to the newest, so
# anything pointing at the plain name (slice.sh, the docs, a slicer window you
# left open) still finds the current mesh. The counter is per name and lives in
# docs/stl-versions.txt, which is COMMITTED on purpose: stl/ is gitignored and
# regenerable, so a counter kept there would reset to v1 the first time the tree
# was cleaned, and "v7" would stop meaning anything.
#
# It counts BUILDS, not design changes. Rebuilding an unchanged part still
# increments, because the script cannot tell the difference and guessing wrongly
# is worse than an extra number. Pass --version N to restamp deliberately.
#
# --name matters more than it looks. The stamp is keyed on the output name, and
# the default name is the .scad's basename — so without it every variant of a
# multi-variant part (show = "coupon", "ring", "collet-test") shares one counter
# and overwrites one file. Name the variant and it gets its own series.
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

# The version ledger. One `<name> <n>` line per output name, sorted, so a diff
# reads as "this part went to v8" rather than as a rewritten file.
VERSIONS_FILE="${VERSIONS_FILE:-${REPO_ROOT}/docs/stl-versions.txt}"

# Last version recorded for a name, or 0 if it has never been built. awk rather
# than grep so a name with a dot in it is not read as a pattern, and the last
# matching line wins if the file was ever hand-edited into duplicates.
version_current() {
  [[ -f "$VERSIONS_FILE" ]] || { echo 0; return; }
  awk -v n="$1" '$1 == n { v = $2 } END { print (v == "" ? 0 : v) }' "$VERSIONS_FILE"
}

version_record() {
  local name="$1" value="$2" tmp="${VERSIONS_FILE}.tmp"
  mkdir -p "$(dirname "$VERSIONS_FILE")"
  {
    [[ -f "$VERSIONS_FILE" ]] && awk -v n="$name" '$1 != n' "$VERSIONS_FILE"
    echo "$name $value"
  } | sort > "$tmp"
  mv "$tmp" "$VERSIONS_FILE"
}

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
  echo "usage: $0 <part.scad> [--name <base>] [--version <n>] [--no-version]" >&2
  echo "          [--ascii] [--push] [extra openscad args...]" >&2
  exit 64
fi

SCAD="$1"
shift

PUSH=0
FORMAT="binstl"
NAME=""
VERSION=""
VERSIONED=1
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --push)       PUSH=1; shift ;;
    --ascii)      FORMAT="asciistl"; shift ;;
    --name)       NAME="$2"; shift 2 ;;
    --version)    VERSION="$2"; shift 2 ;;
    --no-version) VERSIONED=0; shift ;;
    *)            ARGS+=("$1"); shift ;;
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

BASE="${NAME:-$(basename "$SCAD" .scad)}"
mkdir -p "$OUTDIR"

if [[ "$VERSIONED" -eq 1 ]]; then
  if [[ -n "$VERSION" ]]; then
    [[ "$VERSION" =~ ^[0-9]+$ ]] || {
      echo "error: --version wants a whole number, got: $VERSION" >&2
      exit 64
    }
    VER="$VERSION"
  else
    VER=$(( $(version_current "$BASE") + 1 ))
  fi
  OUT="$OUTDIR/${BASE}-v${VER}.stl"
else
  VER=""
  OUT="$OUTDIR/${BASE}.stl"

  # That plain name is where the latest-version symlink lives, and OpenSCAD
  # writes THROUGH a symlink — so an unversioned build would silently overwrite
  # the newest stamped mesh with whatever it just rendered, leaving the ledger
  # claiming a v9 that is really this build. Drop the link first so a real file
  # takes its place; the next versioned build replaces it again.
  if [[ -L "$OUT" ]]; then
    echo "note: replacing the latest-version symlink at $OUT with a plain file"
    rm "$OUT"
  fi
fi

# --export-format goes before the caller's own args, so passing one explicitly
# still wins.
echo "rendering $SCAD -> $OUT (this may take a while)"
"$OPENSCAD" -o "$OUT" --export-format="$FORMAT" "${ARGS[@]+"${ARGS[@]}"}" "$SCAD"
echo "built $OUT ($(du -h "$OUT" | cut -f1), $FORMAT)"

# The counter moves only once a mesh actually exists, so a failed render does
# not burn a number. The symlink is relative, so stl/ can be moved or the whole
# tree copied without it dangling.
if [[ "$VERSIONED" -eq 1 ]]; then
  version_record "$BASE" "$VER"
  ln -sfn "${BASE}-v${VER}.stl" "$OUTDIR/${BASE}.stl"
  echo "stamped v${VER} (docs/stl-versions.txt); $OUTDIR/${BASE}.stl -> ${BASE}-v${VER}.stl"
fi

if [[ "$PUSH" -eq 1 ]]; then
  echo "pushing to ${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  # The versioned file is what goes up, so the viewer accumulates versions side
  # by side rather than replacing the model in place. The name in the URL is the
  # filename, which is now stamped.
  rsync -avz -e "ssh -p ${NAS_PORT}" "$OUT" "${NAS_USER}@${NAS_HOST}:${NAS_PATH}/"
  echo "pushed. visible at https://3d.feralcreative.co/?model=$(basename "$OUT" .stl)"
fi
