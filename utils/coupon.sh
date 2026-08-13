#!/usr/bin/env bash
#
# coupon.sh — build a test coupon carrying only the parts that have actually
# changed since the last one you printed.
#
# Usage:
#   utils/coupon.sh parts/hobbs-chalk-holder.scad            # build the coupon
#   utils/coupon.sh parts/hobbs-chalk-holder.scad --slice    # and slice it
#   utils/coupon.sh parts/hobbs-chalk-holder.scad --all      # ignore the log, build everything
#   utils/coupon.sh parts/hobbs-chalk-holder.scad --printed  # record that you printed the last one
#
# A coupon exists to answer a question about the thing that changed. Reprinting
# the half that did not change costs plate time and filament and answers
# nothing, so by default that half is left off.
#
# HOW IT DECIDES. It builds each component on its own into a scratch directory
# and hashes the mesh. A component whose hash matches the one recorded as last
# printed is unchanged in the only sense that matters — the geometry that would
# reach the bed is identical, whatever the parameters did on the way there — and
# it is omitted. Everything else is included. Parameter edits that cancel out do
# not fool it, and neither does a comment change that rewrites the file.
#
# It cannot know what you printed, because printing is your step and nothing in
# the repo sees it. --printed is how you tell it, and until you do, the last
# thing you marked stays the reference.
#
# WHAT IT COSTS, MEASURED. Dropping a part also drops whatever cooling time it
# was buying its neighbours, which on a thin tall feature is not free. On this
# part it turned out to be nearly free anyway: layer times up the chalk holder's
# collet go 5.7 s to 3.7 s over the 2.2 mm where the ring overlaps it, and do
# not move at all above that, because the ring tops out below most of the
# collet. Do not assume the same on another part — slice it both ways and look.
#
# WHAT THE PART HAS TO DECLARE. Two comment directives, so this script needs no
# knowledge of any particular part:
#
#   // COUPON-COMPONENTS: handle=coupon-handle ring=ring
#   // COUPON-PLATE: coupon
#
# The first maps a component name to the show = "..." value that isolates it;
# the second gives the variant that puts them all on one plate.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="${PRINT_LOG:-${REPO_ROOT}/docs/print-log.txt}"
VERSIONS_FILE="${VERSIONS_FILE:-${REPO_ROOT}/docs/stl-versions.txt}"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <part.scad> [--all] [--slice] [--printed]" >&2
  exit 64
fi

SCAD="$1"
shift

ALL=0
SLICE=0
MARK=0
for arg in "$@"; do
  case "$arg" in
    --all)     ALL=1 ;;
    --slice)   SLICE=1 ;;
    --printed) MARK=1 ;;
    *) echo "error: unknown argument: $arg" >&2; exit 64 ;;
  esac
done

[[ -f "$SCAD" ]] || { echo "error: no such file: $SCAD" >&2; exit 66; }

PART="$(basename "$SCAD" .scad)"
NAME="${PART}-coupon"

# The directives, read out of the part itself.
COMPONENTS="$(sed -n 's|^// *COUPON-COMPONENTS: *||p' "$SCAD" | head -1)"
PLATE="$(sed -n 's|^// *COUPON-PLATE: *||p' "$SCAD" | head -1)"

if [[ -z "$COMPONENTS" || -z "$PLATE" ]]; then
  echo "error: $SCAD declares no coupon components." >&2
  echo "  Add, near the top:" >&2
  echo "    // COUPON-COMPONENTS: handle=coupon-handle ring=ring" >&2
  echo "    // COUPON-PLATE: coupon" >&2
  exit 65
fi

# --- the log ----------------------------------------------------------------
#
# One line per part and component:
#   <part> <component> <built_version> <built_sha> <printed_version> <printed_sha>
# with - for "never". Committed, for the same reason the version ledger is:
# stl/ is gitignored and regenerable, and a record of what physically got
# printed cannot be rebuilt from anything.

# Versions are stored bare and shown padded, matching build.sh's filenames. A
# missing record stays "-" rather than becoming v00.
ver_tag() { [[ "$1" == "-" ]] && { echo "-"; return; }; printf 'v%02d' "$1"; }

log_field() {  # part component column-number
  [[ -f "$LOG" ]] || { echo "-"; return; }
  awk -v p="$1" -v c="$2" -v n="$3" \
      '$1 == p && $2 == c { v = $n } END { print (v == "" ? "-" : v) }' "$LOG"
}

log_put() {  # part component built_v built_sha printed_v printed_sha on_plate
  local tmp="${LOG}.tmp"
  mkdir -p "$(dirname "$LOG")"
  # Header comments are kept above the sort rather than swept into it, or the
  # explanation at the top of the file gets shuffled into alphabetical order on
  # the first write.
  {
    [[ -f "$LOG" ]] && { grep '^#' "$LOG" || true; }
    {
      [[ -f "$LOG" ]] && grep -v '^#' "$LOG" \
        | awk -v p="$1" -v c="$2" '!($1 == p && $2 == c)'
      printf '%s %s %s %s %s %s %s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7"
    } | sort
  } > "$tmp"
  mv "$tmp" "$LOG"
}

# --- marking a print --------------------------------------------------------
#
# Only the components that were actually on the plate get marked. One that was
# omitted was not printed this time, so its existing record — the last time it
# genuinely was — has to stand.

if [[ "$MARK" -eq 1 ]]; then
  marked=0
  for pair in $COMPONENTS; do
    comp="${pair%%=*}"
    bv="$(log_field "$PART" "$comp" 3)"
    bs="$(log_field "$PART" "$comp" 4)"
    on_plate="$(log_field "$PART" "$comp" 7)"
    if [[ "$bs" == "-" || "$on_plate" != "included" ]]; then
      echo "  $comp: not on the last plate, leaving its record alone"
      continue
    fi
    log_put "$PART" "$comp" "$bv" "$bs" "$bv" "$bs" "included"
    echo "  $comp: marked printed at $(ver_tag "$bv")"
    marked=$((marked + 1))
  done
  [[ "$marked" -gt 0 ]] || echo "nothing to mark — build a coupon first"
  exit 0
fi

# --- hashing each component -------------------------------------------------

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

OPENSCAD="$(command -v openscad || echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)"
[[ -x "$OPENSCAD" ]] || { echo "error: openscad not found" >&2; exit 69; }
export OPENSCADPATH="${REPO_ROOT}/lib${OPENSCADPATH:+:$OPENSCADPATH}"

INCLUDED=()
OMITTED=()

# macOS ships bash 3.2, which has no associative arrays, so the component ->
# hash map is a newline-separated "comp sha" string and this reads it back.
# Two components do not justify anything cleverer, and requiring a newer bash
# would make the script depend on a Homebrew install that need not be there.
HASHES=""
sha_for() { printf '%s\n' "$HASHES" | awk -v c="$1" '$1 == c { print $2 }'; }
show_for() {
  for p in $COMPONENTS; do
    [[ "${p%%=*}" == "$1" ]] && { echo "${p#*=}"; return; }
  done
}

echo "== hashing components"
for pair in $COMPONENTS; do
  comp="${pair%%=*}"
  show="${pair#*=}"

  out="${SCRATCH}/${comp}.stl"
  "$OPENSCAD" -o "$out" --export-format=binstl -D "show=\"${show}\"" "$SCAD" \
    >/dev/null 2>&1 || { echo "error: failed to build component $comp" >&2; exit 70; }

  sha="$(shasum -a 256 "$out" | cut -d' ' -f1)"
  HASHES="${HASHES}${comp} ${sha}"$'\n'
  printed_sha="$(log_field "$PART" "$comp" 6)"
  printed_v="$(log_field "$PART" "$comp" 5)"

  if [[ "$ALL" -eq 0 && "$sha" == "$printed_sha" ]]; then
    OMITTED+=("$comp")
    printf '  %-10s unchanged since printed %s — omitted\n' "$comp" "$(ver_tag "$printed_v")"
  else
    INCLUDED+=("$comp")
    if [[ "$printed_sha" == "-" ]]; then
      printf '  %-10s never marked printed — included\n' "$comp"
    else
      printf '  %-10s changed since printed %s — included\n' "$comp" "$(ver_tag "$printed_v")"
    fi
  fi
done

if [[ "${#INCLUDED[@]}" -eq 0 ]]; then
  echo
  echo "nothing has changed since the last print. No coupon built."
  echo "  Pass --all to build one anyway."
  exit 0
fi

# One component on its own is its own show variant; everything together is the
# plate. Anything in between is a plate this part has no variant for, so it
# falls back to the full plate rather than inventing one.
if [[ "${#INCLUDED[@]}" -eq 1 ]]; then
  USE_SHOW="$(show_for "${INCLUDED[0]}")"
else
  USE_SHOW="$PLATE"
  if [[ "${#OMITTED[@]}" -gt 0 ]]; then
    echo "  note: no variant emits exactly this subset; building the full plate"
    INCLUDED+=("${OMITTED[@]}")
    OMITTED=()
  fi
fi

echo
echo "== building show=\"$USE_SHOW\" as $NAME"
"${REPO_ROOT}/utils/build.sh" "$SCAD" -D "show=\"${USE_SHOW}\"" --name "$NAME"

VER="$(awk -v n="$NAME" '$1 == n { v = $2 } END { print (v == "" ? "?" : v) }' \
       "$VERSIONS_FILE")"

# Column 7 records whether the component was on THIS plate, which is what
# --printed needs later: marking a coupon as printed must not claim a component
# that was left off it. The printed columns are carried through untouched —
# building is not printing, and only --printed may move them.
for comp in "${INCLUDED[@]}"; do
  log_put "$PART" "$comp" "$VER" "$(sha_for "$comp")" \
          "$(log_field "$PART" "$comp" 5)" "$(log_field "$PART" "$comp" 6)" "included"
done
for comp in "${OMITTED[@]+"${OMITTED[@]}"}"; do
  log_put "$PART" "$comp" "$(log_field "$PART" "$comp" 3)" \
          "$(log_field "$PART" "$comp" 4)" \
          "$(log_field "$PART" "$comp" 5)" "$(log_field "$PART" "$comp" 6)" "omitted"
done

if [[ "$SLICE" -eq 1 ]]; then
  echo
  "${REPO_ROOT}/utils/slice.sh" "stl/${NAME}.stl"
fi

echo
echo "when you have printed it:  utils/coupon.sh $SCAD --printed"
