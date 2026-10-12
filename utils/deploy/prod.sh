#!/usr/bin/env bash
#
# prod.sh — put the finished parts on the printer site.
#
# build.sh --push sends one mesh, the draft you just built, and the viewer
# accumulates every version you ever pushed. This is the other half: the set of
# FINISHED parts — every stl/<name>.stl with no -vNN in its name, which is what
# finalize.sh produces and what git commits — mirrored to the NAS in one go, so
# the site carries the current deliverables and nothing else from this repo.
#
#   utils/deploy/prod.sh              # sync
#   utils/deploy/prod.sh --dry-run    # show what would move, send nothing
#   utils/deploy/prod.sh --all        # every plain-named mesh, moving or not
#
# WHERE IT GOES is read from .vscode/sftp.json rather than repeated here, so the
# SFTP extension and this script cannot disagree about the host. That file is
# the one place the destination lives; if it moves, change it there.
#
# EXCEPT FOR THE VOLUME. The extension's remotePath is /web/..., which is what
# the NAS's SFTP service shows — it presents shared folders at the root. A plain
# ssh login sees the real filesystem, where the same folder is /volume1/web/...,
# and /web/... does not exist at all: rsync over ssh fails with "No such file"
# and sends nothing. So the path from sftp.json is prefixed with REMOTE_VOLUME
# here, the same way build.sh --push spells it. 2026-09-12: the first run with
# the bare path put nothing on the site.
#
# Drafts never go. Anything matching -v[0-9][0-9] is skipped even though it is
# an .stl in the same directory: a numbered file is a part still moving, and the
# viewer is for things worth printing. Nor does a plain file that still has
# drafts beside it — since 2026-09-12 build.sh keeps stl/<name>.stl as a copy
# of the newest build, so that file exists for every part in progress and says
# nothing about whether the part is done. FINISHED means finalize.sh has run:
# the plain file stands alone. --all drops that test and sends every plain name.
#
# SUBFOLDERS. stl/ has per-part subdirectories and the finished set is gathered
# from all of them. The far side stays FLAT — the viewer reads one models
# directory — so two subfolders holding the same filename would overwrite each
# other there. That is refused rather than resolved, since which one wins would
# come down to rsync argument order.
#
# Nothing is deleted on the far side. A part removed here stays on the site until
# someone removes it there deliberately — the models directory also holds
# meshes that came from elsewhere, and --delete would take those with it.
#
# THIS TOUCHES A LIVE HOST. Run it when Ziad asks and not otherwise; the same
# rule as build.sh --push.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONF="${REPO_ROOT}/.vscode/sftp.json"
STL_DIR="${REPO_ROOT}/stl"

DRY=()
ALL=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY=(--dry-run) ;;
    --all) ALL=1 ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

[[ -f "$CONF" ]] || { echo "no $CONF" >&2; exit 1; }

HOST="$(jq -er '.host' "$CONF")"
PORT="$(jq -er '.port' "$CONF")"
USER_="$(jq -er '.username' "$CONF")"
REMOTE_VOLUME="/volume1"
REMOTE="${REMOTE_VOLUME}$(jq -er '.remotePath' "$CONF")"

# The finished set: plain-named meshes, drafts excluded by pattern, and then
# any plain name that still has a draft beside it unless --all. Sorted so the
# listing reads the same way every run.
FILES=()
SKIPPED=()
while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  name="$(basename "$f" .stl)"
  # Drafts count as beside it only within its own directory.
  if [[ "$ALL" -eq 0 ]] && compgen -G "$(dirname "$f")/${name}-v[0-9][0-9]*.stl" >/dev/null; then
    SKIPPED+=("$name")
    continue
  fi
  FILES+=("$f")
done < <(find "$STL_DIR" -type f -name '*.stl' ! -name '*-v[0-9][0-9]*.stl' | sort)

# One flat destination: a repeated basename would land on itself over there.
DUPES="$(for f in ${FILES[@]+"${FILES[@]}"}; do basename "$f"; done | sort | uniq -d)"
if [[ -n "$DUPES" ]]; then
  echo "error: these names appear in more than one stl/ subfolder and the site is flat:" >&2
  printf '   %s\n' $DUPES >&2
  echo "rename one of each, or sync them in separate runs." >&2
  exit 1
fi

if [[ "${#SKIPPED[@]}" -gt 0 ]]; then
  echo "== ${#SKIPPED[@]} still moving (drafts beside them), not sent — finalize.sh or --all:"
  for n in "${SKIPPED[@]}"; do echo "   $n"; done
  echo
fi

if [[ "${#FILES[@]}" -eq 0 ]]; then
  echo "nothing to sync: no unversioned .stl in stl/"
  exit 0
fi

echo "== ${#FILES[@]} finished part(s) -> ${USER_}@${HOST}:${REMOTE}/ ${DRY[*]:-}"
for f in "${FILES[@]}"; do echo "   ${f#$STL_DIR/}"; done
echo

# -c compares by checksum rather than mtime: build.sh's copy step gives the
# plain file a fresh timestamp on every build even when the mesh is unchanged,
# and finalize.sh's mv keeps the draft's, so time is not a reliable signal here.
rsync -avzc --itemize-changes "${DRY[@]+"${DRY[@]}"}" \
  -e "ssh -p ${PORT}" \
  "${FILES[@]}" "${USER_}@${HOST}:${REMOTE}/"

echo
echo "done. viewer: https://3d.feralcreative.co/"
