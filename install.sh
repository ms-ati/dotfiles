#!/usr/bin/env bash

##
# Install dotfiles into GitHub Codespaces (Cursor IDE).
# See: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles
#
# Each step is a separate script in scripts/; run any one standalone for debugging.
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/scripts/_lib.sh"

log "dotfiles" "start" "running install..."
bash "${SCRIPT_DIR}/scripts/install-shell-dotfiles.sh"
bash "${SCRIPT_DIR}/scripts/install-cursor-settings.sh"
bash "${SCRIPT_DIR}/scripts/install-cursor-workspace.sh"
bash "${SCRIPT_DIR}/scripts/install-cursor-tools.sh"
bash "${SCRIPT_DIR}/scripts/install-mcp.sh"
bash "${SCRIPT_DIR}/scripts/install-extensions.sh"
bash "${SCRIPT_DIR}/scripts/install-git-editor.sh"
log "dotfiles" "done" ""
