#!/usr/bin/env bash

##
# Symlink Cursor Machine (remote) settings into ~/.cursor-server/data/Machine/.
# Each file is linked individually; existing correct symlinks are skipped.
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="cursor-settings"
REPO_ROOT=$(dirname "$SCRIPT_DIR")

CURSOR_MACHINE="${HOME}/.cursor-server/data/Machine"
ensure_dir "$CURSOR_MACHINE" "$SCRIPT_NAME"

for file in "${REPO_ROOT}/cursor/Machine/"*; do
  [[ -f "$file" ]] || continue
  dest="${CURSOR_MACHINE}/$(basename "$file")"
  symlink_if_needed "$file" "$dest" "$SCRIPT_NAME"
done
