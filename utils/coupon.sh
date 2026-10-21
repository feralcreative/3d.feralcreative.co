#!/usr/bin/env bash
# Keep the CAD entrypoint available from the unified project root.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARGS=()
for arg in "$@"; do ARGS+=("${arg#cad/}"); done
cd "$ROOT/cad"
exec bash "utils/coupon.sh" "${ARGS[@]+"${ARGS[@]}"}"
