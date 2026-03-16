#!/usr/bin/env bash

##
# Symlink all .code-workspace files from cursor/workspaces/ into $HOME
# so they appear in Cursor's "Open Recent" and can be opened in new codespaces.
# Paths inside each file are relative to that file (in the dotfiles repo).
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="cursor-workspace"
REPO_ROOT=$(dirname "$SCRIPT_DIR")
WORKSPACES_DIR="${REPO_ROOT}/cursor/workspaces"

for file in "${WORKSPACES_DIR}"/*.code-workspace; do
  [[ -f "$file" ]] || continue
  dest="${HOME}/$(basename "$file")"
  symlink_if_needed "$file" "$dest" "$SCRIPT_NAME"
done
