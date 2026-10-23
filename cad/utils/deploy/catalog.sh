#!/usr/bin/env bash
# Publish selected catalog assets before exposing their new catalog; leave other NAS files intact.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CATALOG="${CATALOG:-$REPO_ROOT/_work/site-models/catalog.json}"
CONF="$REPO_ROOT/.vscode/sftp.json"
DRY=()
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY=(--dry-run) ;;
    --help|-h) echo "usage: $0 [--dry-run] (generate locally with utils/models.sh first)"; exit 0 ;;
    *) echo "error: unknown argument: $arg" >&2; exit 64 ;;
  esac
done
[[ -f "$CATALOG" ]] || { echo "error: generate the model catalog first" >&2; exit 66; }
[[ -f "$CONF" ]] || { echo "error: CAD publication configuration is missing" >&2; exit 66; }
HOST="$(jq -er '.host' "$CONF")"
PORT="$(jq -er '.port' "$CONF")"
REMOTE_USER="$(jq -er '.username' "$CONF")"
REMOTE="/volume1$(jq -er '.remotePath' "$CONF")"
SSH_ARGS=(ssh -o BatchMode=yes -o ConnectTimeout=10 -p "$PORT")
if [[ -n "${SSH_KEY_PATH:-}" ]]; then
  [[ -f "$SSH_KEY_PATH" ]] || { echo "error: configured SSH identity is missing" >&2; exit 66; }
  SSH_ARGS+=(-i "$SSH_KEY_PATH")
fi
printf -v SSH_COMMAND '%q ' "${SSH_ARGS[@]}"
# Capture failures before rsync; process substitution would hide a failed validator.
SELECTED="$(python3 - "$CATALOG" <<'PY'
import json
from pathlib import Path
import sys
catalog=Path(sys.argv[1]);data=json.loads(catalog.read_text());files=set()
if data.get('schema')!=1:raise SystemExit('Unsupported model catalog schema')
for model in data['models']:
    for item in model['views']+model['downloads']:
        name=item['file']
        if Path(name).name!=name or name in {'.','..','catalog.json'}:
            raise SystemExit('Unsafe catalog asset filename')
        path=catalog.parent/name
        if not path.is_file():raise SystemExit('Missing catalog asset: '+name)
        files.add(str(path))
print('\n'.join(sorted(files)))
PY
)"
FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || FILES+=("$file"); done <<< "$SELECTED"
if [[ "${#FILES[@]}" -gt 0 ]]; then
  echo "Publishing ${#FILES[@]} catalog assets. Existing unrelated remote files are preserved."
  rsync -avzLc --chmod=F644 --delay-updates "${DRY[@]+"${DRY[@]}"}" -e "$SSH_COMMAND" "${FILES[@]}" "$REMOTE_USER@$HOST:$REMOTE/"
fi
# Only advertise newly referenced files after their transfer succeeds.
rsync -avzc --chmod=F644 --delay-updates "${DRY[@]+"${DRY[@]}"}" -e "$SSH_COMMAND" "$CATALOG" "$REMOTE_USER@$HOST:$REMOTE/"
