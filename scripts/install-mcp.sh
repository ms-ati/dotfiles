#!/usr/bin/env bash

##
# Install or merge Cursor MCP config into ~/.cursor/mcp.json.
# Repo is source of truth: repo keys override matching local keys.
# Keys present only in the local file are preserved.
# Requires: jq
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="mcp"
REPO_ROOT=$(dirname "$SCRIPT_DIR")

REPO_MCP="${REPO_ROOT}/cursor/mcp.json"
USER_MCP="${HOME}/.cursor/mcp.json"

ensure_dir "${HOME}/.cursor" "$SCRIPT_NAME"

if [[ ! -f "$USER_MCP" ]]; then
  cp "$REPO_MCP" "$USER_MCP"
  log "$SCRIPT_NAME" "copied" "$USER_MCP"
else
  # Merge: start with local, then apply repo on top (repo keys win on conflicts).
  # Local-only mcpServers keys are preserved.
  jq -s '{ mcpServers: (.[0].mcpServers * .[1].mcpServers) }' \
    "$USER_MCP" "$REPO_MCP" > "${USER_MCP}.dotfiles_tmp" \
    && mv "${USER_MCP}.dotfiles_tmp" "$USER_MCP"
  log "$SCRIPT_NAME" "merged" "$USER_MCP (repo wins, local-only keys kept)"
fi
