#!/usr/bin/env bash

##
# Install VS Code/Cursor extensions from cursor/extensions.txt.
# - Uses `code` to install (available at dotfiles time even before Cursor connects).
# - Checks whether the extension dir already exists in vscode-server before installing.
# - Copies newly installed extensions into the Cursor server extensions dir when both exist.
# - One log line per extension: "skip" if already installed and cursor copy is up to date,
#   otherwise "install" and/or "copied".
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="extensions"
REPO_ROOT=$(dirname "$SCRIPT_DIR")

EXT_FILE="${REPO_ROOT}/cursor/extensions.txt"
VSCODE_EXT="${HOME}/.vscode-server/extensions"
CURSOR_EXT="${HOME}/.cursor-server/extensions"

if [[ ! -f "$EXT_FILE" ]]; then
  log "$SCRIPT_NAME" "skip" "cursor/extensions.txt not found"
  exit 0
fi

if ! command -v code &>/dev/null; then
  log "$SCRIPT_NAME" "skip" "code CLI not available — extensions skipped"
  exit 0
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line#"${line%%[![:space:]]*}"}"   # trim leading whitespace
  line="${line%"${line##*[![:space:]]}"}"   # trim trailing whitespace
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  ext_id="$line"

  # Check if already installed in vscode-server or cursor-server.
  # code stores extension dirs with lowercase IDs (e.g. Shopify.ruby-lsp -> shopify.ruby-lsp-*),
  # so we match using a lowercase version of the ID.
  ext_id_lower="${ext_id,,}"
  already_installed=false
  for ext_dir in "$VSCODE_EXT" "$CURSOR_EXT"; do
    [[ -d "$ext_dir" ]] || continue
    for dir in "${ext_dir}/${ext_id_lower}"-*/; do
      [[ -d "$dir" ]] && { already_installed=true; break 2; }
    done
  done

  if ! "$already_installed"; then
    log "$SCRIPT_NAME" "install" "$ext_id"
    code --install-extension "$ext_id" --force 2>/dev/null || true
  fi

  # Copy from vscode-server to cursor-server when both dirs exist
  cursor_copy_ok=true
  if [[ -d "$VSCODE_EXT" && -d "$CURSOR_EXT" ]]; then
    for src in "${VSCODE_EXT}/${ext_id_lower}"-*/; do
      [[ -d "$src" ]] || continue
      dest="${CURSOR_EXT}/$(basename "$src")"
      if [[ ! -d "$dest" ]] || [[ "$src" -nt "$dest" ]]; then
        cp -a "$src" "$dest" 2>/dev/null || true
        log "$SCRIPT_NAME" "copied" "$(basename "$src") -> cursor-server"
        cursor_copy_ok=false
      fi
    done
  fi

  if "$already_installed" && "$cursor_copy_ok"; then
    log "$SCRIPT_NAME" "skip" "$ext_id (installed, cursor copy up to date)"
  fi

done < "$EXT_FILE"
