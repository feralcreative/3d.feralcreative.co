#!/usr/bin/env bash
#
# clean.sh — delete generated output that is no longer needed.
#
# Usage:
#   utils/clean.sh                 # say what would go, delete nothing
#   utils/clean.sh --apply         # actually delete it
#   utils/clean.sh --keep 4        # keep more versions than the default 2
#   utils/clean.sh --scratch       # only the exp- throwaways, nothing else
#   utils/clean.sh --stale 7       # ALSO renders, 3mf and slice jobs untouched
#                                  # for 7 days
#   utils/clean.sh --all           # --keep 0 --stale 0: every regenerable byte
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
# there. Mark old versions rather than the newest one — it is already protected
# by retention anyway.
#
# SUBFOLDERS. stl/ has per-part subdirectories in it and every rule here reaches
# into them. The version rules run once per directory, so a name that exists in
# two of them is two independent series and neither can push the other out.
#
# WHAT IS PROTECTED WITHOUT ANY MARKING
#   - the newest N versions of each name (N = 2 unless --keep says otherwise)
#   - whatever a stl/<name>.stl symlink points at, where a build older than
#     2026-09-12 left one (build.sh now writes a real copy there instead)
#   - the coupon version docs/print-log.txt records as printed, because the
#     thing you printed is the reference for everything measured off it
#   - any slice/ directory whose STL survives the pass
#
# renders/ and 3mf/ are not versioned, so the version rules cannot speak about
# them at all. They are judged on age alone, which means a plain run LEAVES
# THEM ALONE and only --stale or --all touches them.
#
# They used to be cleared wholesale on every run, on the reasoning that they
# cost seconds to rebuild. True of the four standard views, false of everything
# else in there: a zoomed detail render made with -D flags to answer one
# question has no record of the flags that produced it, so "regenerable" was
# only ever true of the renders nobody minded losing. A default run wiping the
# tree you are in the middle of reading is also just a bad default.
#
# PAST MODELS, AND WHY --stale EXISTS
# -----------------------------------
# Every rule above is about a file's rank within its own name. None of them is
# about time, so nothing ever ages out: a part you finished months ago keeps
# its newest two versions and its slice job for ever, because the rules can
# only ever ask "is this the newest?" and the answer stays yes.
#
# slice/ is where that bites. A slice job is protected as long as the STL it
# came from is still on disk, and a finished part's STL is COMMITTED — so its
# job is protected permanently. One of them is a 73 MB plate_1.gcode. That is
# the single biggest tree in the repo and every byte of it rebuilds in about a
# minute with utils/slice.sh.
#
# --stale N adds the missing axis: anything regenerable that has not been
# touched in N days goes, whatever its rank. It still honours .keep, still
# refuses tracked files, and still spares a coupon the print log says was
# printed. --stale 0 means everything. If a name loses every version that way
# and its stl/<name>.stl is one of the old symlinks, that goes too rather than
# being left dangling; a real copy there is untouched.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

LOG="${PRINT_LOG:-docs/print-log.txt}"
LIBRARY_CLEAN_ARGS=("$@")
KEEP_N=2
APPLY=0
SCRATCH_ONLY=0
STALE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply|-y)  APPLY=1; shift ;;
    --keep)      KEEP_N="$2"; shift 2 ;;
    --stale)     STALE="$2"; shift 2 ;;
    --all)       KEEP_N=0; STALE=0; shift ;;
    --scratch)   SCRATCH_ONLY=1; shift ;;
    *) echo "usage: $0 [--apply] [--keep N] [--stale DAYS] [--all] [--scratch]" >&2; exit 64 ;;
  esac
done

[[ "$KEEP_N" =~ ^[0-9]+$ ]] || { echo "error: --keep wants a number" >&2; exit 64; }
[[ -z "$STALE" || "$STALE" =~ ^[0-9]+$ ]] || { echo "error: --stale wants a number of days" >&2; exit 64; }
python3 "${REPO_ROOT}/utils/library.py" clean "${LIBRARY_CLEAN_ARGS[@]+"${LIBRARY_CLEAN_ARGS[@]}"}"

DOOMED=()
BYTES=0

size_of() { du -sk "$1" 2>/dev/null | cut -f1; }

doom() {  # path reason
  DOOMED+=("$1|$2")
  BYTES=$(( BYTES + $(size_of "$1") ))
}

# git's own opinion, not a guess from the path. A tracked file is never output.
tracked() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

# Untouched for --stale days? False when --stale was not given, so every caller
# can ask unconditionally. Recurses, so a slice/ directory is judged by the
# newest file inside it and not by the directory's own mtime.
#
# -mtime and not -newermt: `find` on this machine is bfs, which rejects
# GNU's relative "-N days" argument. -mtime is understood by every find there
# is. Test the OUTPUT, not the exit status — a find that matches nothing still
# exits 0.
stale() {
  [[ -n "$STALE" ]] || return 1
  [[ -z "$(find "$1" -mtime -"$STALE" -print -quit 2>/dev/null)" ]]
}

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

# --- symlink targets (builds older than 2026-09-12) --------------------------

LINKED=""
while IFS= read -r l; do
  [[ -L "$l" ]] || continue
  LINKED="${LINKED}$(basename "$(readlink "$l")")"$'\n'
done < <(find stl -name '*.stl' 2>/dev/null)

is_linked() { printf '%s\n' "$LINKED" | grep -qx -- "$1"; }

# --- the pass ----------------------------------------------------------------

echo "== scratch (exp-*)"
for tree in renders stl slice 3mf; do
  [[ -d "$tree" ]] || continue
  while IFS= read -r p; do
    [[ -e "$p" ]] || continue
    tracked "$p" && continue
    doom "$p" "scratch"
  done < <(find "$tree" -name 'exp-*' -prune 2>/dev/null | sort)
done
[[ "${#DOOMED[@]}" -gt 0 ]] || echo "  none"

if [[ "$SCRATCH_ONLY" -eq 0 ]]; then
  echo
  echo "== versioned output, keeping the newest $KEEP_N of each name"
  # Group <name>-vNN.stl by name, newest first, and doom past the Nth.
  #
  # SUBFOLDERS (2026-09-22). Once per directory under stl/, rather than once
  # over a recursive listing, because the rules rank a name's versions against
  # each other: two parts that collided on a name in different subdirectories
  # would otherwise be ranked as one series and the loser's newest build would
  # be deleted as "older than the newest N".
  for d in $(find stl -type d 2>/dev/null | sort); do
  for name in $(ls "$d" 2>/dev/null | sed -n 's/^\(.*\)-v[0-9][0-9]*\.stl$/\1/p' \
                 | grep -v '^exp-' | sort -u); do
    n=0
    survived=0
    for f in $(ls "$d"/"$name"-v*.stl 2>/dev/null | sort -r); do
      base="$(basename "$f" .stl)"
      [[ "$f" == *.keep.* ]] && { echo "  $f — kept by name"; survived=1; continue; }
      tracked "$f" && { survived=1; continue; }
      n=$((n + 1))
      old=0
      stale "$f" && old=1
      if [[ "$n" -le "$KEEP_N" && "$old" -eq 0 ]]; then survived=1; continue; fi
      if is_printed "$base"; then
        echo "  $f — printed, per $LOG"
        survived=1
        continue
      fi
      if is_linked "$(basename "$f")" && [[ "$old" -eq 0 ]]; then
        echo "  $f — the latest symlink points here"
        survived=1
        continue
      fi
      if [[ "$old" -eq 1 ]]; then
        doom "$f" "not touched in $STALE days"
      else
        doom "$f" "older than the newest $KEEP_N"
      fi
    done

    # Nothing of this name left to point at. A dangling stl/<name>.stl is worse
    # than no link at all: every doc path and every downstream script resolves
    # through it.
    if [[ "$survived" -eq 0 && -L "$d/$name.stl" ]] && ! tracked "$d/$name.stl"; then
      doom "$d/$name.stl" "symlink with nothing left to point at"
    fi
  done
  done

  echo
  if [[ -n "$STALE" ]]; then
    echo "== renders and 3mf, untouched in $STALE days"
    for tree in renders 3mf; do
      [[ -d "$tree" ]] || continue
      for p in "$tree"/*; do
        [[ -e "$p" ]] || continue
        [[ "$p" == *.keep.* ]] && { echo "  $p — kept by name"; continue; }
        tracked "$p" && continue
        [[ "$p" == */exp-* ]] && continue     # already doomed as scratch
        stale "$p" || continue
        doom "$p" "not touched in $STALE days"
      done
    done
  else
    echo "== renders and 3mf — left alone; --stale N or --all to clear them"
  fi

  echo
  if [[ -n "$STALE" ]]; then
    echo "== slice jobs, orphaned or untouched in $STALE days"
  else
    echo "== slice jobs whose STL is gone"
  fi
  if [[ -d slice ]]; then
    for d in slice/*/; do
      [[ -d "$d" ]] || continue
      base="$(basename "${d%/}")"
      [[ "$base" == *.keep ]] && { echo "  $d — kept by name"; continue; }
      [[ "$base" == exp-* ]] && continue    # already doomed as scratch
      # Age first: a finished part's STL is committed, so the rule below would
      # protect its job for ever. This is the one that lets a past model go.
      if stale "$d"; then
        doom "$d" "not touched in $STALE days"
        continue
      fi
      # Survives if the STL it was sliced from is still there, under either the
      # plain name or any surviving version of it.
      if [[ -n "$(find stl \( -name "${base}.stl" -o -name "${base}-v*.stl" \) -print -quit 2>/dev/null)" ]]; then
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
  path="${entry%%|*}"
  printf '  %-52s %6s MB  %s\n' "$path" \
    "$(awk -v k="$(size_of "$path")" 'BEGIN{printf "%.1f", k/1024}')" "${entry##*|}"
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
