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
# Use Cursor as git editor when running inside Cursor. Require a live IPC socket:
# after reconnect or new window, VSCODE_IPC_HOOK_CLI can still point at an old
# path; cursor --wait then fails with ENOENT on the .sock file.
_cursor_git_editor_ipc_ok() {
  [[ -n "${VSCODE_IPC_HOOK_CLI:-}" && -S "${VSCODE_IPC_HOOK_CLI}" ]]
}
_in_cursor_integrated_terminal() {
  [[ -n "${VSCODE_GIT_ASKPASS_NODE:-}" && "$VSCODE_GIT_ASKPASS_NODE" == *".cursor-server"* ]] ||
    [[ -n "${VSCODE_AGENT_FOLDER:-}" && "$VSCODE_AGENT_FOLDER" == *".cursor-server"* ]]
}
if _in_cursor_integrated_terminal && _cursor_git_editor_ipc_ok; then
  export GIT_EDITOR="cursor --wait"
fi
unset -f _cursor_git_editor_ipc_ok _in_cursor_integrated_terminal
EOF

inject_marker_block "${HOME}/.bashrc" "cursor-git-editor" "$snippet" "$SCRIPT_NAME"
