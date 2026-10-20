#!/usr/bin/env bash
# Keep every utility's model lookup and default workspace in agreement.

model_resolve() {
  local model_assignments
  model_assignments="$(python3 "${REPO_ROOT}/utils/library.py" resolve "$1" --shell)" || return
  eval "$model_assignments"
}
