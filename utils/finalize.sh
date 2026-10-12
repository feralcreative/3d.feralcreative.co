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
#   utils/finalize.sh 'delonghi-heater-stand*'    # every name that matches
#   utils/finalize.sh stl/delonghi-heater-stand*  # same, expanded by the shell
#   utils/finalize.sh --all          # every series in stl/
#
#   utils/finalize.sh --shitcan doorbell-wire-channel-upper   # say what would go
#   utils/finalize.sh --shitcan --apply doorbell-wire-channel-upper
#   utils/finalize.sh --shitcan 'doorbell-wire-channel-*'
#
# Names are OUTPUT names, the same ones build.sh --name takes and the same ones
# docs/stl-versions.txt is keyed on — not .scad paths.
#
# SUBFOLDERS. stl/ has per-part subdirectories in it — stl/gridfinity/ and the
# rest — and a name is found wherever under stl/ its meshes actually are. Names
# stay bare: you finalize `gridfinity-cup-1x1x6`, not a path to it. Setting
# OUTDIR still narrows the search to one directory. See the note above
# dirs_for() for what happens when one name is in two of them.
#
# WILDCARDS (Ziad, 2026-09-17). A name may be a glob. It is matched here, not
# by the shell, against the output names that actually exist: every stl/*.stl
# reduced to its name, and for --shitcan also the ledger, slice/ and 3mf/,
# because a name can leave those behind with no mesh left. QUOTE IT. zsh
# refuses an unmatched glob outright, and nothing in the repo root is called
# delonghi-heater-stand*, so unquoted the pattern never reaches this script.
# The one unquoted form that does work is a path the shell can expand,
# stl/delonghi-heater-stand*, and that is accepted too: a path is reduced to
# its name — directory, extension and -vNN stripped, duplicates dropped — so a
# directory's worth of drafts comes out as the handful of names they belong to.
#
# A WILDCARD NEVER YIELDS A COUPON ON A FINALIZE. A coupon is not a part and is
# never final; its parent's finalize sweeps it, and if the pattern walked into
# it afterwards it would find nothing there and fail the run for it. So the
# match drops any name with "coupon" in it and says so, and --all does the
# same — a run that ended in exit 1 on a coupon its own parent had just swept
# was the reason. A coupon typed out in full is still taken at its word.
# --shitcan keeps them: there the whole point is to take everything.
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
# AND SO DO THE RENDERS (Ziad, 2026-09-15). They are previews of a mesh that
# is no longer moving, gitignored and one `render.sh` away, and a finished
# part leaving 7 stale PNGs behind is the same clutter the versioned STLs
# were.
#
# THE RENDER MATCH IS NARROWER THAN --shitcan's, deliberately. render.sh
# names its output after the .scad's basename and a view — <base>-zplus.png —
# and output names extend each other: renders/ holds deck-door-stop-*.png
# beside deck-door-stop-truss-*.png, and desk-cup-holder-*.png beside
# desk-cup-holder-starbucks-*.png. A prefix glob on the shorter name would
# take the longer part's renders with it, and finalizing has no dry run to
# catch that. So this takes renders/<name>-<one segment>.png only: a view
# name carries no dash, so anything with a second dash after <name>- belongs
# to a longer output name and is left alone. --shitcan keeps the broad prefix
# glob, because there the whole point is to sweep, and it lists before it
# removes.
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
  echo "       $0 '<pattern>' [...]     quoted: zsh will not hand over an unmatched glob" >&2
  echo "       $0 stl/<name>*           or a path it can expand" >&2
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
  find "$OUTDIR" -name '*-v[0-9][0-9]*.stl' -print \
    | sed 's|.*/||; s|-v[0-9][0-9]*\.stl$||' \
    | sort -u
}

LEDGER="${REPO_ROOT}/docs/stl-versions.txt"

# SUBFOLDERS (Ziad, 2026-09-22). stl/ grew per-part subdirectories —
# stl/gridfinity/, stl/slim-can-holder/ — and everything here used to be a
# -maxdepth 1 find, so a name that had moved into one simply came back as
# "nothing found for this name". Names are still bare output names with no
# directory in them, because that is what build.sh --name and the ledger use;
# the directory is looked up from where the meshes actually are.
#
# One name in two directories is not resolved, it is reported and skipped: the
# two are different parts that collided on a name, and picking one silently is
# how the wrong file gets deleted.
dirs_for() {
  local name="$1"
  find "$OUTDIR" -type f \
    \( -name "${name}.stl" -o -name "${name}-v[0-9][0-9]*.stl" \) \
    2>/dev/null | sed 's|/[^/]*$||' | sort -u
}

# Every output name with a mesh in stl/, plain or versioned. What a pattern is
# matched against when finalizing: the ledger knows more names, but one with
# no mesh left has nothing to finalize and would only SKIP.
stl_names() {
  find "$OUTDIR" -name '*.stl' -print \
    | sed 's|.*/||; s|\.stl$||; s|-v[0-9][0-9][0-9]*$||' \
    | sort -u
}

# Wider, for --shitcan: anything a name can leave behind counts, down to a
# ledger line with nothing else left.
shitcan_names() {
  {
    stl_names
    if [[ -f "$LEDGER" ]]; then awk '{ print $1 }' "$LEDGER"; fi
    if [[ -d "${REPO_ROOT}/slice" ]]; then
      find "${REPO_ROOT}/slice" -mindepth 1 -maxdepth 1 -type d -print | sed 's|.*/||; s|\.keep$||'
    fi
    if [[ -d "${REPO_ROOT}/3mf" ]]; then
      find "${REPO_ROOT}/3mf" -maxdepth 1 -name '*.3mf' -print | sed 's|.*/||; s|\.keep\.3mf$||; s|\.3mf$||'
    fi
  } | sort -u
}

# Arguments to output names, one per line, in order, deduplicated, coupons
# and all. A bare name passes through as typed. A pattern (any of * ? [) is
# matched against the names this mode can act on; a path (a / in it, or .stl
# or .3mf on the end) is reduced to its name. See WILDCARDS in the header for
# why the pattern has to arrive quoted. Fails on a pattern that matches
# nothing, since that is almost always a typo.
expand_names() {
  local mode="$1"; shift
  local arg n m hit
  local universe=() out=()

  if [[ "$mode" == "shitcan" ]]; then
    while IFS= read -r n; do [[ -n "$n" ]] && universe+=("$n"); done < <(shitcan_names)
  else
    while IFS= read -r n; do [[ -n "$n" ]] && universe+=("$n"); done < <(stl_names)
  fi

  for arg in "$@"; do
    n="${arg##*/}"; n="${n%.stl}"; n="${n%.3mf}"
    case "$n" in
      *[*?[]*)
        hit=0
        for m in ${universe[@]+"${universe[@]}"}; do
          [[ "$m" == $n ]] || continue
          out+=("$m"); hit=1
        done
        [[ "$hit" -eq 1 ]] || { echo "error: nothing matches '$arg'" >&2; return 1; }
        ;;
      *)
        if [[ "$n" != "$arg" && "$n" =~ ^(.*)-v[0-9][0-9]+$ ]]; then n="${BASH_REMATCH[1]}"; fi
        out+=("$n")
        ;;
    esac
  done

  [[ "${#out[@]}" -gt 0 ]] || return 0
  printf '%s\n' "${out[@]}" | awk '!seen[$0]++'
}

# A filter for the finalize side only: a coupon name that arrived by any
# expansion — pattern, path or --all — is dropped and named once on stderr.
# See A WILDCARD NEVER YIELDS A COUPON in the header. A coupon typed out in
# full never passes through here, so it is still taken at its word.
drop_coupons() {
  local n
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    if [[ "$n" == *coupon* ]]; then
      printf '  %-40s skipped — a coupon is never final; name it in full to force it\n' "$n" >&2
      continue
    fi
    printf '%s\n' "$n"
  done
}

NAMES=()
if [[ "$1" == "--all" ]]; then
  [[ $# -eq 1 ]] || { echo "error: --all takes no other arguments" >&2; exit 64; }
  while IFS= read -r n; do [[ -n "$n" ]] && NAMES+=("$n"); done < <(all_names | drop_coupons)
  [[ "${#NAMES[@]}" -gt 0 ]] || { echo "nothing to finalize: no versioned STLs in $OUTDIR"; exit 0; }
elif [[ "$SHITCAN" -eq 1 ]]; then
  expanded="$(expand_names shitcan "$@")"
  while IFS= read -r n; do [[ -n "$n" ]] && NAMES+=("$n"); done <<< "$expanded"
else
  # Typed names are taken as they are, coupon or not; only what an expansion
  # produced goes through drop_coupons. So the two are sorted apart first,
  # and the expansions go through in one call so a draft series the shell
  # handed over file by file collapses to its name once, not once per file.
  TO_EXPAND=()
  for arg in "$@"; do
    case "$arg" in
      *[*?[]*|*/*|*.stl|*.3mf) TO_EXPAND+=("$arg") ;;
      *) NAMES+=("$arg") ;;
    esac
  done
  if [[ "${#TO_EXPAND[@]}" -gt 0 ]]; then
    expanded="$(expand_names finalize "${TO_EXPAND[@]}" | drop_coupons)"
    while IFS= read -r n; do [[ -n "$n" ]] && NAMES+=("$n"); done <<< "$expanded"
  fi
  [[ "${#NAMES[@]}" -gt 0 ]] || { echo "error: nothing left to finalize — every name given was a coupon" >&2; exit 1; }
fi

# renders/<name>-<one segment>.png, untracked only. Echoes the count so the
# caller can report it; see the header for why the match is not a prefix glob.
sweep_renders() {
  local name="$1"
  local n=0 f tail
  [[ -d "${REPO_ROOT}/renders" ]] || { echo 0; return 0; }
  for f in "${REPO_ROOT}/renders/${name}-"*.png; do
    [[ -e "$f" ]] || continue
    tail="${f##*/${name}-}"
    [[ "$tail" == *-* ]] && continue
    if git -C "$REPO_ROOT" ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      printf '  %-40s note: %s is tracked, left alone\n' "" "$(basename "$f")" >&2
      continue
    fi
    rm -f "$f"
    n=$((n + 1))
  done
  echo "$n"
}

# stl/<name>-*coupon*.stl, untracked only. Echoes the count, like sweep_renders.
sweep_coupons() {
  local name="$1" dir="$2"
  local n=0 f
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    if git -C "$REPO_ROOT" ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      printf '  %-40s note: %s is tracked, left alone\n' "" "$(basename "$f")" >&2
      continue
    fi
    rm -f "$f"
    n=$((n + 1))
  done < <(find "$dir" -maxdepth 1 -name "${name}-*coupon*.stl")
  echo "$n"
}

finalize_one() {
  local name="$1"
  local dirs=() d
  while IFS= read -r d; do [[ -n "$d" ]] && dirs+=("$d"); done < <(dirs_for "$name")
  if [[ "${#dirs[@]}" -eq 0 ]]; then
    printf '  %-40s SKIPPED — nothing found for this name\n' "$name" >&2
    return 1
  fi
  if [[ "${#dirs[@]}" -gt 1 ]]; then
    printf '  %-40s SKIPPED — this name is in %d directories:\n' "$name" "${#dirs[@]}" >&2
    printf '      %s\n' "${dirs[@]#$REPO_ROOT/}" >&2
    return 1
  fi
  local dir="${dirs[0]}"
  local plain="${dir}/${name}.stl"
  local keep=""

  # A symlink here is from a build older than 2026-09-12, when the plain name
  # was a link to the newest draft rather than a copy of it. It is still the
  # authority on which mesh was current. Resolve one level rather than following
  # it all the way, because that is exactly what build.sh wrote: a relative link
  # to a sibling.
  if [[ -L "$plain" ]]; then
    local target
    target="$(readlink "$plain")"
    keep="${dir}/$(basename "$target")"
    if [[ ! -f "$keep" ]]; then
      printf '  %-40s SKIPPED — %s points at a missing file\n' "$name" "$(basename "$plain")" >&2
      return 1
    fi
  elif [[ -f "$plain" ]]; then
    keep=""     # the newest build, as build.sh copies it; the drafts are the strays
  else
    # No plain name at all. Fall back to the highest version, and say so, since
    # this is the one case where the number is doing the choosing.
    keep="$(find "$dir" -maxdepth 1 -name "${name}-v[0-9][0-9]*.stl" | sort | tail -1)"
    [[ -n "$keep" ]] || {
      printf '  %-40s SKIPPED — nothing found for this name\n' "$name" >&2
      return 1
    }
    printf '  %-40s note: no %s.stl to follow, taking the highest version\n' "$name" "$name"
  fi

  local versions=()
  while IFS= read -r f; do [[ -n "$f" ]] && versions+=("$f"); done \
    < <(find "$dir" -maxdepth 1 -name "${name}-v[0-9][0-9]*.stl" | sort)

  if [[ "${#versions[@]}" -eq 0 && -z "$keep" ]]; then
    # Still sweep: a part can be final and have coupons and renders of it
    # lying around. Until 2026-09-17 this returned before the coupons, so a
    # part that had never carried a draft kept every coupon it ever had.
    local only_coupons only_renders
    only_coupons="$(sweep_coupons "$name" "$dir")"
    only_renders="$(sweep_renders "$name")"
    printf '  %-40s already final%s%s\n' "$name" \
      "$( [[ "$only_coupons" -gt 0 ]] && echo ", $only_coupons coupon file(s) removed" )" \
      "$( [[ "$only_renders" -gt 0 ]] && echo ", $only_renders render(s) removed" )"
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
  local coupons rendered
  coupons="$(sweep_coupons "$name" "$dir")"
  rendered="$(sweep_renders "$name")"

  local kept_tag="already a plain file"
  [[ -n "$keep" ]] && kept_tag="was $(basename "$keep")"
  printf '  %-40s final (%s)%s%s%s\n' "$name" "$kept_tag" \
    "$( [[ "$removed" -gt 0 ]] && echo ", $removed older version(s) removed" )" \
    "$( [[ "$coupons" -gt 0 ]] && echo ", $coupons coupon file(s) removed" )" \
    "$( [[ "$rendered" -gt 0 ]] && echo ", $rendered render(s) removed" )"
}

# Everything generated that carries one output name. Lists it, and removes it
# only when --apply says so. Returns 1 if the name turned up nothing at all,
# which usually means it was spelled wrong.
shitcan_one() {
  local name="$1"
  local found=0
  local paths=()
  local p

  # No single-directory rule here: --shitcan is taking every trace away, so it
  # takes the name's meshes wherever under stl/ they turn up.
  for p in "${REPO_ROOT}/3mf/${name}.3mf" "${REPO_ROOT}/3mf/${name}.keep.3mf"; do
    [[ -e "$p" ]] && paths[${#paths[@]}]="$p"
  done
  while IFS= read -r p; do
    [[ -n "$p" ]] && paths[${#paths[@]}]="$p"
  done < <(find "$OUTDIR" -type f \( -name "${name}.stl" -o -name "${name}-v[0-9][0-9]*.stl" -o -name "${name}-*coupon*.stl" \) 2>/dev/null | sort)
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
echo "Renders are gone with the drafts — utils/render.sh remakes them."
[[ "$failed" -eq 0 ]] || exit 1
