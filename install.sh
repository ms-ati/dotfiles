#!/usr/bin/env bash

##
# Install script for dotfiles into GitHub Codespaces (Cursor IDE).
# See: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")

# ---- 1. Symlink dotfiles to home ----
for file in "${SCRIPT_DIR}/."*; do
  if [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]]; then
    echo "[dotfiles] Symlink: $HOME/$(basename "$file") -> $file"
    ln -sf "$file" "$HOME/$(basename "$file")"
  fi
done

# ---- 2. Cursor remote (Machine) settings ----
CURSOR_MACHINE="/home/codespace/.cursor-server/data/Machine"
mkdir -p "${CURSOR_MACHINE}"
for file in "${SCRIPT_DIR}/cursor/Machine/"*; do
  if [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]]; then
    echo "[dotfiles] Symlink: ${CURSOR_MACHINE}/$(basename "$file") -> $file"
    ln -sf "$file" "${CURSOR_MACHINE}/$(basename "$file")"
  fi
done

# ---- 3. MCP config: merge repo's mcp.json into ~/.cursor/mcp.json ----
# Repo is source of truth for servers we define; any extra servers in existing file are kept.
mkdir -p "$HOME/.cursor"
REPO_MCP="${SCRIPT_DIR}/cursor/mcp.json"
USER_MCP="$HOME/.cursor/mcp.json"
if [[ ! -f "$USER_MCP" ]]; then
  echo "[dotfiles] Copy MCP config: $USER_MCP"
  cp "$REPO_MCP" "$USER_MCP"
else
  echo "[dotfiles] Merge MCP config into $USER_MCP"
  # Merge: repo mcpServers override/add; local-only keys in mcpServers are preserved
  jq -s '{ mcpServers: (.[1].mcpServers * .[0].mcpServers) }' "$USER_MCP" "$REPO_MCP" > "${USER_MCP}.tmp" && mv "${USER_MCP}.tmp" "$USER_MCP"
fi

# ---- 4. Install extensions (at least these) ----
# Always use `code` (available at dotfiles time); then copy into Cursor so extensions work in both.
VSCODE_EXT="${HOME}/.vscode-server/extensions"
CURSOR_EXT="${HOME}/.cursor-server/extensions"
if [[ -f "${SCRIPT_DIR}/cursor/extensions.txt" ]] && command -v code &>/dev/null; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "[dotfiles] Installing extension: $line"
    code --install-extension "$line" --force 2>/dev/null || true
  done < "${SCRIPT_DIR}/cursor/extensions.txt"
  # Copy from VS Code server to Cursor server so Cursor has them (e.g. when opened in Cursor after dotfiles ran).
  if [[ -d "$VSCODE_EXT" ]] && [[ -d "$CURSOR_EXT" ]]; then
    while IFS= read -r ext_id || [[ -n "$ext_id" ]]; do
      ext_id=$(echo "$ext_id" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
      [[ -z "$ext_id" || "$ext_id" =~ ^# ]] && continue
      for src in "${VSCODE_EXT}/"${ext_id}-*; do
        [[ -d "$src" ]] || continue
        dest="${CURSOR_EXT}/$(basename "$src")"
        if [[ ! -d "$dest" ]] || [[ "$src" -nt "$dest" ]]; then
          echo "[dotfiles] Copy extension to Cursor: $(basename "$src")"
          cp -a "$src" "$dest" 2>/dev/null || true
        fi
      done
    done < "${SCRIPT_DIR}/cursor/extensions.txt"
  fi
fi

# ---- 5. GIT_EDITOR for Cursor ----
if ! grep -q "VSCODE_GIT_ASKPASS_NODE.*\.cursor-server" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc << 'EOF'

# Use Cursor as git editor when running inside Cursor
if [[ -n "${VSCODE_GIT_ASKPASS_NODE:-}" && "$VSCODE_GIT_ASKPASS_NODE" == *".cursor-server"* ]]; then
  export GIT_EDITOR="cursor --wait"
fi
EOF
  echo "[dotfiles] Added Cursor GIT_EDITOR to .bashrc"
fi

echo "[dotfiles] Done."
