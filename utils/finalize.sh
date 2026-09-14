#!/usr/bin/env bash
#
# finalize.sh — collapse a finished part's version series down to one file.
#
# Versions exist to make iteration legible: while a part is moving, having v01
# through v06 side by side is how you compare, roll back, and tell which mesh a
# print came from. Once it stops moving that is just clutter, and worse, it is
# clutter that invites printing the wrong file — a stale vNN sitting next to the
# current one looks exactly as legitimate.
#
# So a finished piece gets one file, stl/<name>.stl, with no version in the name
# and no drafts beside it. That is what this does:
#
#   utils/finalize.sh slim-can-holder-3in-explicit
#   utils/finalize.sh slim-can-holder-3in-explicit slim-can-holder-3in-censored
#   utils/finalize.sh --all          # every series in stl/
#
#   utils/finalize.sh --shitcan doorbell-wire-channel-upper   # say what would go
#   utils/finalize.sh --shitcan --apply doorbell-wire-channel-upper
#
# Names are OUTPUT names, the same ones build.sh --name takes and the same ones
# docs/stl-versions.txt is keyed on — not .scad paths.
#
# WHICH MESH SURVIVES. stl/<name>.stl itself — build.sh keeps it as a real copy
# of the newest build — so this only deletes the numbered drafts beside it. Not
# the highest number: those are usually the same and are not always, and
# slim-can-adapter once carried a v02 while both the ledger and the plain name
# said v01 was current. Builds before 2026-09-12 left a symlink at the plain
# name instead of a copy; one of those is still followed and promoted.
#
# COUPONS GO TOO. A finished part has nothing left to test, so every
# stl/<name>-*coupon*.stl — plain or versioned, whatever the build named it —
# is deleted with the drafts (Ziad, 2026-09-13). Only untracked files: a
# coupon that has somehow been committed is left where it is and named.
#
# THE LEDGER IS LEFT ALONE. docs/stl-versions.txt keeps its count for the name.
# Finishing a part is not a promise never to touch it again, and if it is rebuilt
# the next build should be v07 rather than a v01 that collides with the history.
# The ledger is committed and the versioned STLs are not, so the ledger is the
# only record of where a series actually got to — clearing it would throw that
# away to save one line.
#
# Finalizing also changes what git sees. .gitignore commits stl/<name>.stl and
# ignores every stl/<name>-vNN.stl, so this is the step that puts a finished
# mesh under version control and takes its scratch history back out.
#
# Rebuilding a finalized part puts a numbered draft back beside it, which is
# correct: it has started moving again. Run this again when it stops. To skip
# that round trip entirely on a part you know is done, build it with
# `build.sh --no-version`, which writes the plain name in the first place.
#
# --shitcan: THE OTHER END OF A PART'S LIFE
# -----------------------------------------
# Finalizing says "this one is done, keep exactly one of it". --shitcan says
# the opposite: this output is not wanted at all any more, take every trace of
# it away. An abandoned variant — the wire channel's upper and cap once the
# design stopped needing them as separate outputs — otherwise leaves meshes,
# renders, a sliced job and a line in the ledger lying around looking current.
#
# For each name it removes:
#
#   stl/<name>.stl and every stl/<name>-vNN.stl and stl/<name>-*coupon*.stl
#   renders/<name>-*.png
#   slice/<name>/ and 3mf/<name>.3mf
#   the <name> line in docs/stl-versions.txt
#
# DRY RUN IS THE DEFAULT, like clean.sh: it lists and stops, and --apply is the
# only thing that removes anything. Unlike clean.sh it will delete files git
# tracks, because a finished stl/<name>.stl is committed and that is precisely
# the file being thrown out; it says which ones those are, and leaves the
# deletion staged for you to commit.
#
# THE LEDGER LINE GOES, where finalizing leaves it. There is no history left to
# collide with once the meshes are gone, and a name in docs/stl-versions.txt
# with nothing behind it is just a puzzle for later.
#
# WHAT IT WILL NOT TOUCH. parts/<name>.scad — the source is never generated
# output and one .scad usually feeds several output names, so deleting a
# variant must not take the part with it; it names the file if one exists and
# leaves it to you. MODELS/ likewise: that is a symlink into the printer site's
# NAS and removing something from it is a change to a live site, so it says
# what it found there and stops.
#
# ⚠️ THE RENDER GLOB IS A PREFIX, renders/<name>-*.png, because ad-hoc renders
# are named freely and there is no list of them to match against. So shitcanning
# a base name also sweeps up renders belonging to names that extend it —
# doorbell-wire-channel takes doorbell-wire-channel-upper-zplus.png with it.
# That is what the dry run is for: read the list before you pass --apply.
#
# --shitcan takes explicit names only. There is no --shitcan --all, on purpose.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="${OUTDIR:-${REPO_ROOT}/stl}"

usage() {
  echo "usage: $0 <name> [<name>...]" >&2
  echo "       $0 --all" >&2
  echo "       $0 --shitcan [--apply] <name> [<name>...]" >&2
  echo >&2
  echo "  <name> is an output name (build.sh --name), not a .scad path." >&2
  exit 64
}

SHITCAN=0
APPLY=0
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --shitcan)  SHITCAN=1; shift ;;
    --apply|-y) APPLY=1; shift ;;
    --all)      ARGS[${#ARGS[@]}]="--all"; shift ;;
    -h|--help)  usage ;;
    -*)         echo "error: unknown option: $1" >&2; usage ;;
    *)          ARGS[${#ARGS[@]}]="$1"; shift ;;
  esac
done
set -- ${ARGS[@]+"${ARGS[@]}"}

[[ $# -ge 1 ]] || usage
if [[ "$APPLY" -eq 1 && "$SHITCAN" -eq 0 ]]; then
  echo "error: --apply only means anything with --shitcan; finalizing has no dry run" >&2
  exit 64
fi
if [[ "$SHITCAN" -eq 1 && "$1" == "--all" ]]; then
  echo "error: --shitcan takes names, never --all" >&2
  exit 64
fi

[[ -d "$OUTDIR" ]] || { echo "error: no such directory: $OUTDIR" >&2; exit 66; }

# Every name in stl/ that has at least one -vNN.stl beside it. Uses the same
# two-digit-minimum shape build.sh stamps, so a v100 series is still found.
all_names() {
  find "$OUTDIR" -maxdepth 1 -name '*-v[0-9][0-9]*.stl' -print \
    | sed 's|.*/||; s|-v[0-9][0-9]*\.stl$||' \
    | sort -u
}

NAMES=()
if [[ "$1" == "--all" ]]; then
  [[ $# -eq 1 ]] || { echo "error: --all takes no other arguments" >&2; exit 64; }
  while IFS= read -r n; do [[ -n "$n" ]] && NAMES+=("$n"); done < <(all_names)
  [[ "${#NAMES[@]}" -gt 0 ]] || { echo "nothing to finalize: no versioned STLs in $OUTDIR"; exit 0; }
else
  NAMES=("$@")
fi

finalize_one() {
  local name="$1"
  local plain="${OUTDIR}/${name}.stl"
  local keep=""

  # A symlink here is from a build older than 2026-09-12, when the plain name
  # was a link to the newest draft rather than a copy of it. It is still the
  # authority on which mesh was current. Resolve one level rather than following
  # it all the way, because that is exactly what build.sh wrote: a relative link
  # to a sibling.
  if [[ -L "$plain" ]]; then
    local target
    target="$(readlink "$plain")"
    keep="${OUTDIR}/$(basename "$target")"
    if [[ ! -f "$keep" ]]; then
      printf '  %-40s SKIPPED — %s points at a missing file\n' "$name" "$(basename "$plain")" >&2
      return 1
    fi
  elif [[ -f "$plain" ]]; then
    keep=""     # the newest build, as build.sh copies it; the drafts are the strays
  else
    # No plain name at all. Fall back to the highest version, and say so, since
    # this is the one case where the number is doing the choosing.
    keep="$(find "$OUTDIR" -maxdepth 1 -name "${name}-v[0-9][0-9]*.stl" | sort | tail -1)"
    [[ -n "$keep" ]] || {
      printf '  %-40s SKIPPED — nothing found for this name\n' "$name" >&2
      return 1
    }
    printf '  %-40s note: no %s.stl to follow, taking the highest version\n' "$name" "$name"
  fi

  local versions=()
  while IFS= read -r f; do [[ -n "$f" ]] && versions+=("$f"); done \
    < <(find "$OUTDIR" -maxdepth 1 -name "${name}-v[0-9][0-9]*.stl" | sort)

  if [[ "${#versions[@]}" -eq 0 && -z "$keep" ]]; then
    printf '  %-40s already final\n' "$name"
    return 0
  fi

  # Drop the link before the move, or mv would write through it and land the
  # mesh back on top of itself. build.sh guards the same trap for --no-version.
  [[ -L "$plain" ]] && rm "$plain"

  if [[ -n "$keep" ]]; then
    mv "$keep" "$plain"
  fi

  local removed=0
  for f in "${versions[@]}"; do
    [[ "$f" == "$keep" ]] && continue
    rm -f "$f"
    removed=$((removed + 1))
  done

  # The coupons: every output name that starts with this one and says so.
  local coupons=0
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    if git -C "$REPO_ROOT" ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      printf '  %-40s note: %s is tracked, left alone\n' "" "$(basename "$f")"
      continue
    fi
    rm -f "$f"
    coupons=$((coupons + 1))
  done < <(find "$OUTDIR" -maxdepth 1 -name "${name}-*coupon*.stl")

  local kept_tag="already a plain file"
  [[ -n "$keep" ]] && kept_tag="was $(basename "$keep")"
  printf '  %-40s final (%s)%s%s\n' "$name" "$kept_tag" \
    "$( [[ "$removed" -gt 0 ]] && echo ", $removed older version(s) removed" )" \
    "$( [[ "$coupons" -gt 0 ]] && echo ", $coupons coupon file(s) removed" )"
}

LEDGER="${REPO_ROOT}/docs/stl-versions.txt"

# Everything generated that carries one output name. Lists it, and removes it
# only when --apply says so. Returns 1 if the name turned up nothing at all,
# which usually means it was spelled wrong.
shitcan_one() {
  local name="$1"
  local found=0
  local paths=()
  local p

  for p in "${OUTDIR}/${name}.stl" "${REPO_ROOT}/3mf/${name}.3mf" "${REPO_ROOT}/3mf/${name}.keep.3mf"; do
    [[ -e "$p" ]] && paths[${#paths[@]}]="$p"
  done
  while IFS= read -r p; do
    [[ -n "$p" ]] && paths[${#paths[@]}]="$p"
  done < <(find "$OUTDIR" -maxdepth 1 \( -name "${name}-v[0-9][0-9]*.stl" -o -name "${name}-*coupon*.stl" \) 2>/dev/null | sort)
  if [[ -d "${REPO_ROOT}/renders" ]]; then
    while IFS= read -r p; do
      [[ -n "$p" ]] && paths[${#paths[@]}]="$p"
    done < <(find "${REPO_ROOT}/renders" -maxdepth 1 -name "${name}-*.png" 2>/dev/null | sort)
  fi
  for p in "${REPO_ROOT}/slice/${name}" "${REPO_ROOT}/slice/${name}.keep"; do
    [[ -d "$p" ]] && paths[${#paths[@]}]="$p"
  done

  printf '  %s\n' "$name"
  if [[ "${#paths[@]}" -gt 0 ]]; then
    found=1
    for p in "${paths[@]}"; do
      local mark=""
      git -C "$REPO_ROOT" ls-files --error-unmatch "$p" >/dev/null 2>&1 && mark="   [git tracked]"
      printf '      %s%s\n' "${p#$REPO_ROOT/}" "$mark"
      [[ "$APPLY" -eq 1 ]] && rm -rf "$p"
    done
  fi

  if [[ -f "$LEDGER" ]] && grep -q -- "^${name} " "$LEDGER"; then
    found=1
    printf '      docs/stl-versions.txt — the %s line\n' "$name"
    if [[ "$APPLY" -eq 1 ]]; then
      local tmp
      tmp="$(mktemp)"
      grep -v -- "^${name} " "$LEDGER" > "$tmp" || true
      mv "$tmp" "$LEDGER"
    fi
  fi

  # Named, never touched: the source, and the live site's mirror.
  [[ -f "${REPO_ROOT}/parts/${name}.scad" ]] \
    && printf '      note: parts/%s.scad exists and is left alone — delete it yourself if the part is going too\n' "$name"
  [[ -e "${REPO_ROOT}/MODELS/${name}.stl" ]] \
    && printf '      note: MODELS/%s.stl is on the printer site NAS and is left alone — that is a live site\n' "$name"

  if [[ "$found" -eq 0 ]]; then
    printf '      nothing found under this name\n' >&2
    return 1
  fi
  return 0
}

if [[ "$SHITCAN" -eq 1 ]]; then
  echo "== shitcanning, in ${REPO_ROOT}"
  failed=0
  for n in "${NAMES[@]}"; do
    shitcan_one "$n" || failed=$((failed + 1))
  done
  echo
  if [[ "$APPLY" -eq 0 ]]; then
    echo "dry run. Re-run with --apply to remove it."
  else
    echo "gone. Whatever git tracked is now a staged deletion — commit it."
  fi
  [[ "$failed" -eq 0 ]] || exit 1
  exit 0
fi

echo "== finalizing in $OUTDIR"
failed=0
for n in "${NAMES[@]}"; do
  finalize_one "$n" || failed=$((failed + 1))
done

echo
echo "docs/stl-versions.txt is unchanged — a rebuild resumes at the next number."
[[ "$failed" -eq 0 ]] || exit 1
