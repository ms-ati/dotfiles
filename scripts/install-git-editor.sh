#!/usr/bin/env bash

##
# Configure GIT_EDITOR to use Cursor when running inside a Cursor terminal.
# Injects a marker block into ~/.bashrc so the snippet is idempotent across
# repeated runs — the block is replaced if already present, or appended if not.
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="git-editor"

read -r -d '' snippet << 'EOF' || true
# Use Cursor as git editor when running inside Cursor
if [[ -n "${VSCODE_GIT_ASKPASS_NODE:-}" && "$VSCODE_GIT_ASKPASS_NODE" == *".cursor-server"* ]]; then
  export GIT_EDITOR="cursor --wait"
fi
EOF

inject_marker_block "${HOME}/.bashrc" "cursor-git-editor" "$snippet" "$SCRIPT_NAME"
