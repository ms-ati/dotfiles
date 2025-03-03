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
mkdir -p "${WINDSURF_DIR}/Machine" # Create the directory if it doesn't exist

# Symlink the Windsurf remote settings
for file in "${SCRIPT_DIR}/windsurf/Machine/"*; do
  if [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]]; then
    echo "Creating symlink: ${WINDSURF_DIR}/Machine/$(basename "$file") -> $file"
    ln -sf "$file" "${WINDSURF_DIR}/Machine/$(basename "$file")"
  fi
done

echo "Symlinking complete."
