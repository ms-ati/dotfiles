#!/usr/bin/env bash

##
# Symlink individual Cursor skills, commands, and agent subdirectories into
# ~/.cursor/{skills,commands,agents}/. Only subdirectories (one per tool) are
# linked — plain files like README.md are ignored. Items already present (from
# other sources) are never removed or overwritten.
##
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f -- "$0")")
source "${SCRIPT_DIR}/_lib.sh"

SCRIPT_NAME="cursor-tools"
REPO_ROOT=$(dirname "$SCRIPT_DIR")

for type in skills commands agents; do
  repo_dir="${REPO_ROOT}/cursor/${type}"
  dest_dir="${HOME}/.cursor/${type}"

  # Migrate from old install style: if dest_dir is a symlink pointing to the repo dir,
  # remove it and replace with a real directory so individual items can be linked inside.
  if [[ -L "$dest_dir" ]]; then
    current_target="$(readlink -f -- "$dest_dir" 2>/dev/null || true)"
    expected_target="$(readlink -f -- "$repo_dir" 2>/dev/null || echo "$repo_dir")"
    if [[ "$current_target" == "$expected_target" ]]; then
      rm "$dest_dir"
      log "$SCRIPT_NAME" "migrated" "$dest_dir (removed whole-dir symlink, will use individual symlinks)"
    fi
  fi

  ensure_dir "$dest_dir" "$SCRIPT_NAME"

  [[ -d "$repo_dir" ]] || continue

  for item in "${repo_dir}"/*/; do
    [[ -d "$item" ]] || continue
    name=$(basename "$item")
    symlink_if_needed "$item" "${dest_dir}/${name}" "$SCRIPT_NAME"
  done
done
