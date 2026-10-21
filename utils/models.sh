#!/usr/bin/env bash
# Stage the complete CAD catalog for the viewer; publish only with an explicit --push.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUSH=0
DRY=0
ARGS=()
OUTDIR="$ROOT/cad/_work/site-models"
while [[ "$#" -gt 0 ]]; do
  arg="$1"
  shift
  case "$arg" in
    --help|-h)
      echo "usage: utils/models.sh [--render-colours] [--model ID] [--outdir DIR] [--push] [--dry-run]"
      echo "Stages all catalog entries; --push publishes selected assets before the catalog."
      echo "--push --dry-run is an offline publication preview."
      exit 0 ;;
    --push) PUSH=1 ;;
    --dry-run) DRY=1 ;;
    --outdir)
      [[ "$#" -gt 0 ]] || { echo "error: --outdir requires a directory" >&2; exit 64; }
      OUTDIR="$1"; shift; ARGS+=(--outdir "$OUTDIR") ;;
    --outdir=*) OUTDIR="${arg#--outdir=}"; ARGS+=("$arg") ;;
    *) ARGS+=("$arg") ;;
  esac
done
python3 "$ROOT/cad/utils/web-library.py" "${ARGS[@]+"${ARGS[@]}"}"
if [[ "$PUSH" -eq 1 ]]; then
  if [[ "$DRY" -eq 1 ]]; then
    echo "Catalog staged locally. Would publish selected assets, then catalog.json; no NAS connection made."
  else
    CATALOG="$OUTDIR/catalog.json" bash "$ROOT/cad/utils/deploy/catalog.sh"
  fi
fi
