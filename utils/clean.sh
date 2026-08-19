#!/usr/bin/env bash
#
# clean.sh — delete generated output that is no longer needed.
#
# Usage:
#   utils/clean.sh                 # say what would go, delete nothing
#   utils/clean.sh --apply         # actually delete it
#   utils/clean.sh --keep 4        # keep more versions than the default 2
#   utils/clean.sh --scratch       # only the exp- throwaways, nothing else
#
# DRY RUN IS THE DEFAULT and --apply is the only way to remove anything. This
# deletes tens of megabytes at a time and some of it took an hour of slicing to
# produce, so the shape of the command is: look, then do.
#
# WHAT IT WILL NEVER TOUCH. Anything git tracks. The trees below are all
# gitignored and reproducible from parts/ — that is the whole basis on which
# this is safe — and the script refuses to consider a path git knows about, so
# pointing it at parts/ by accident does nothing.
#
# HOW A FILE SAYS KEEP OR KILL, in its own name
# ---------------------------------------------
# Two tokens, and everything without one falls in the middle:
#
#   exp-<anything>        SCRATCH. Always deleted, whatever its version, on
#                         every pass. Use it for one-off experiments —
#                         utils/build.sh parts/x.scad --name exp-thing
#                         --no-version — so a comparison you ran once does not
#                         become a file somebody has to think about later.
#
#   <name>.keep.<ext>     KEPT. Never deleted, by anything, ever. Rename a file
#                         to claim it: the coupon that finally gripped, the
#                         slice you are about to print. Directories take the
#                         same mark as a suffix: slice/<name>.keep/
#
#   everything else       Subject to the retention rules below.
#
# The name is the marker on purpose. A sidecar file or a central list is one
# more thing to drift out of step with the tree, and neither shows up in `ls`.
# This does: you can see what is protected while you are looking at what is
# there. Mark old versions rather than the newest one — renaming the newest
# breaks the stl/<name>.stl symlink that points at it, and the newest is
# already protected by retention anyway.
#
# WHAT IS PROTECTED WITHOUT ANY MARKING
#   - the newest N versions of each name (N = 2 unless --keep says otherwise)
#   - whatever each stl/<name>.stl symlink points at
#   - the coupon version docs/print-log.txt records as printed, because the
#     thing you printed is the reference for everything measured off it
#   - any slice/ directory whose STL survives the pass
#
# renders/ and 3mf/ are not versioned and cost seconds to rebuild, so they are
# cleared wholesale apart from .keep. If you are mid-review of a render, mark it
# or re-run utils/render.sh afterwards.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

LOG="${PRINT_LOG:-docs/print-log.txt}"
KEEP_N=2
APPLY=0
SCRATCH_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply|-y)  APPLY=1; shift ;;
    --keep)      KEEP_N="$2"; shift 2 ;;
    --scratch)   SCRATCH_ONLY=1; shift ;;
    *) echo "usage: $0 [--apply] [--keep N] [--scratch]" >&2; exit 64 ;;
  esac
done

[[ "$KEEP_N" =~ ^[0-9]+$ ]] || { echo "error: --keep wants a number" >&2; exit 64; }

DOOMED=()
BYTES=0

size_of() { du -sk "$1" 2>/dev/null | cut -f1; }

doom() {  # path reason
  DOOMED+=("$1|$2")
  BYTES=$(( BYTES + $(size_of "$1") ))
}

# git's own opinion, not a guess from the path. A tracked file is never output.
tracked() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

# --- what the print log says was printed ------------------------------------
#
# The log stores versions per component, and every component of a part shares
# one coupon series, so a printed v3 protects <part>-coupon-v03.stl.

PRINTED=""
if [[ -f "$LOG" ]]; then
  while read -r part ver; do
    [[ -n "${ver:-}" && "$ver" != "-" ]] || continue
    PRINTED="${PRINTED}$(printf '%s-coupon-v%02d' "$part" "$ver")"$'\n'
  done < <(grep -v '^#' "$LOG" | awk '{print $1, $5}' | sort -u)
fi

is_printed() {  # basename without extension
  printf '%s\n' "$PRINTED" | grep -qx -- "$1"
}

# --- symlink targets ---------------------------------------------------------

LINKED=""
for l in stl/*.stl; do
  [[ -L "$l" ]] || continue
  LINKED="${LINKED}$(basename "$(readlink "$l")")"$'\n'
done

is_linked() { printf '%s\n' "$LINKED" | grep -qx -- "$1"; }

# --- the pass ----------------------------------------------------------------

echo "== scratch (exp-*)"
for tree in renders stl slice 3mf; do
  [[ -d "$tree" ]] || continue
  for p in "$tree"/exp-*; do
    [[ -e "$p" ]] || continue
    tracked "$p" && continue
    doom "$p" "scratch"
  done
done
[[ "${#DOOMED[@]}" -gt 0 ]] || echo "  none"

if [[ "$SCRATCH_ONLY" -eq 0 ]]; then
  echo
  echo "== versioned output, keeping the newest $KEEP_N of each name"
  # Group stl/<name>-vNN.stl by name, newest first, and doom past the Nth.
  for name in $(ls stl 2>/dev/null | sed -n 's/^\(.*\)-v[0-9][0-9]*\.stl$/\1/p' \
                 | grep -v '^exp-' | sort -u); do
    n=0
    for f in $(ls stl/"$name"-v*.stl 2>/dev/null | sort -r); do
      base="$(basename "$f" .stl)"
      [[ "$f" == *.keep.* ]] && { echo "  $f — kept by name"; continue; }
      tracked "$f" && continue
      n=$((n + 1))
      if [[ "$n" -le "$KEEP_N" ]]; then continue; fi
      if is_linked "$(basename "$f")"; then
        echo "  $f — the latest symlink points here"
        continue
      fi
      if is_printed "$base"; then
        echo "  $f — printed, per $LOG"
        continue
      fi
      doom "$f" "older than the newest $KEEP_N"
    done
  done

  echo
  echo "== renders and 3mf (not versioned, seconds to rebuild)"
  for tree in renders 3mf; do
    [[ -d "$tree" ]] || continue
    for p in "$tree"/*; do
      [[ -e "$p" ]] || continue
      [[ "$p" == *.keep.* ]] && { echo "  $p — kept by name"; continue; }
      tracked "$p" && continue
      [[ "$p" == */exp-* ]] && continue     # already doomed as scratch
      doom "$p" "regenerable"
    done
  done

  echo
  echo "== slice jobs whose STL is gone"
  if [[ -d slice ]]; then
    for d in slice/*/; do
      [[ -d "$d" ]] || continue
      base="$(basename "${d%/}")"
      [[ "$base" == *.keep ]] && { echo "  $d — kept by name"; continue; }
      [[ "$base" == exp-* ]] && continue    # already doomed as scratch
      # Survives if the STL it was sliced from is still there, under either the
      # plain name or any surviving version of it.
      if [[ -e "stl/${base}.stl" ]] || compgen -G "stl/${base}-v*.stl" >/dev/null; then
        continue
      fi
      doom "$d" "no STL left to match"
    done
  fi
fi

# --- report ------------------------------------------------------------------

echo
if [[ "${#DOOMED[@]}" -eq 0 ]]; then
  echo "nothing to delete."
  exit 0
fi

echo "would delete ${#DOOMED[@]} items, $(( BYTES / 1024 )) MB:"
for entry in "${DOOMED[@]}"; do
  printf '  %-52s %s\n' "${entry%%|*}" "${entry##*|}"
done

if [[ "$APPLY" -eq 0 ]]; then
  echo
  echo "dry run. Re-run with --apply to delete."
  exit 0
fi

echo
for entry in "${DOOMED[@]}"; do
  rm -rf "${entry%%|*}"
done
echo "deleted ${#DOOMED[@]} items."

# Superseded sources are reported and never touched: removing one is a commit,
# not a cleanup, and git is already the thing that remembers it.
echo
echo "note: these tracked sources look superseded — deleting them is your call,"
echo "      and it belongs in its own commit:"
git ls-files 'parts/*.scad' | while read -r f; do
  b="$(basename "$f" .scad)"
  if git grep -qi "merged from.*$b" -- parts/ 2>/dev/null; then
    echo "      $f"
  fi
done
