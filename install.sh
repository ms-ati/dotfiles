#!/bin/bash
##
# Install script for dotfiles into codespace
# see: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles
##

set -euo pipefail # Enable strict error checking

# Directory script is running from (where this repo was cloned)
SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")

# Symlink the dotfiles to home directory
for file in "${SCRIPT_DIR}/."*; do
  if [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]]; then
    echo "Creating symlink: $HOME/$(basename "$file") -> $file"
    ln -sf "$file" "$HOME/$(basename "$file")"
  fi
done

WINDSURF_DIR="/home/codespace/.windsurf-server/data"
mkdir -p "${WINDSURF_DIR}/Machine"

CURSOR_DIR="/home/codespace/.cursor-server/data"
mkdir -p "${CURSOR_DIR}/Machine"

# Symlink the Windsurf remote settings
for file in "${SCRIPT_DIR}/windsurf/Machine/"*; do
  if [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]]; then
    echo "Creating symlink: ${WINDSURF_DIR}/Machine/$(basename "$file") -> $file"
    ln -sf "$file" "${WINDSURF_DIR}/Machine/$(basename "$file")"

    echo "Creating symlink: ${CURSOR_DIR}/Machine/$(basename "$file") -> $file"
    ln -sf "$file" "${CURSOR_DIR}/Machine/$(basename "$file")"
  fi
done

echo "Symlinking complete."

# Append the Windsurf IDE configuration to .bashrc if it doesn't already exist
if ! grep -q "VSCODE_GIT_ASKPASS_NODE.*\.windsurf-server" ~/.bashrc; then
  cat >> ~/.bashrc << 'EOF'

# Set GIT_EDITOR to use Windsurf IDE when running inside Windsurf
if [[ -n "$VSCODE_GIT_ASKPASS_NODE" && "$VSCODE_GIT_ASKPASS_NODE" == *".windsurf-server"* ]]; then
    # Using the integrated terminal in Windsurf
    export GIT_EDITOR="windsurf --wait"  # Assumes the 'windsurf' command exists
fi
EOF
  echo "Added Windsurf IDE configuration to .bashrc"
fi
