#!/usr/bin/env bash

##
# Inject each repo dotfile into the corresponding ~/.<name> using marker blocks.
# The repo content is fenced between # BEGIN / # END markers; anything the user
# has written outside those markers is never touched.
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="shell-dotfiles"
REPO_ROOT=$(dirname "$SCRIPT_DIR")

for file in "${REPO_ROOT}"/.*; do
  [[ -f "$file" ]] || continue
  name=$(basename "$file")
  # Skip git/editor artifacts
  [[ "$name" == ".git" || "$name" == ".gitignore" ]] && continue

  dest="${HOME}/${name}"
  marker_id="dotfiles-${name#.}"   # e.g. dotfiles-bash_aliases

  # Migrate from old install style: if dest is a symlink pointing back to this repo file,
  # remove the symlink so inject_marker_block works on a standalone home file instead.
  if [[ -L "$dest" ]]; then
    dest_target="$(readlink -f -- "$dest" 2>/dev/null || true)"
    file_canonical="$(readlink -f -- "$file" 2>/dev/null || echo "$file")"
    if [[ "$dest_target" == "$file_canonical" ]]; then
      rm "$dest"
      log "$SCRIPT_NAME" "migrated" "$dest (removed old symlink, will inject marker block)"
    fi
  fi

  content=$(cat "$file")
  inject_marker_block "$dest" "$marker_id" "$content" "$SCRIPT_NAME"
done
