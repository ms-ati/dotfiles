#!/usr/bin/env bash

##
# Shared library for dotfiles install scripts.
# Source this file at the top of each script:
#   source "$(dirname "$(readlink -f -- "$0")")/_lib.sh"
##

# log SCRIPT_NAME VERB TARGET
# Prints a consistently formatted status line.
log() {
  local script="${1:-dotfiles}"
  local verb="${2:-info}"
  local target="${3:-}"
  printf "[dotfiles] %-18s %-9s %s\n" "$script" "$verb" "$target"
}

# ensure_dir DIR SCRIPT_NAME
# Creates DIR if it does not exist. Logs created or skip.
ensure_dir() {
  local dir="$1"
  local script="${2:-dotfiles}"
  if [[ -d "$dir" ]]; then
    log "$script" "skip" "$dir (exists)"
  else
    mkdir -p "$dir"
    log "$script" "created" "$dir"
  fi
}

# inject_marker_block FILE MARKER_ID CONTENT SCRIPT_NAME
# Inserts or replaces a fenced block inside FILE, bounded by:
#   # BEGIN <MARKER_ID>
#   # END <MARKER_ID>
# Three outcomes:
#   - FILE does not exist          -> file created with the block
#   - FILE exists, no markers      -> block appended to end of file
#   - FILE exists, markers present -> block replaced in-place
# Content outside the markers is never modified.
inject_marker_block() {
  local file="$1"
  local marker_id="$2"
  local content="$3"
  local script="${4:-dotfiles}"

  local begin="# BEGIN ${marker_id}"
  local end="# END ${marker_id}"
  local block
  block="$(printf '%s\n%s\n%s\n' "$begin" "$content" "$end")"

  if [[ ! -f "$file" ]]; then
    printf '%s\n' "$block" > "$file"
    log "$script" "created" "$file (marker block: $marker_id)"
    return
  fi

  if grep -qF "$begin" "$file"; then
    # Replace the existing block in-place using awk
    awk -v begin="$begin" -v end="$end" -v block="$block" '
      $0 == begin { print block; skip=1; next }
      skip && $0 == end { skip=0; next }
      !skip { print }
    ' "$file" > "${file}.dotfiles_tmp" && mv "${file}.dotfiles_tmp" "$file"
    log "$script" "updated" "$file (marker block: $marker_id)"
  else
    printf '\n%s\n' "$block" >> "$file"
    log "$script" "appended" "$file (marker block: $marker_id)"
  fi
}

# symlink_if_needed SRC DEST SCRIPT_NAME
# Creates a symlink DEST -> SRC if DEST does not already point to SRC.
# Three outcomes:
#   - DEST is already a symlink to SRC  -> skip (no change)
#   - DEST exists but points elsewhere  -> WARN (no change, never overwrite)
#   - DEST does not exist               -> symlink created
symlink_if_needed() {
  local src="$1"
  local dest="$2"
  local script="${3:-dotfiles}"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink -f -- "$dest" 2>/dev/null || true)"
    local expected
    expected="$(readlink -f -- "$src" 2>/dev/null || echo "$src")"
    if [[ "$current" == "$expected" ]]; then
      log "$script" "skip" "$dest (already linked)"
      return
    fi
    log "$script" "WARN" "$dest is a symlink but points to $current, expected $expected — skipping (manual fix needed)"
    return
  fi

  if [[ -e "$dest" ]]; then
    log "$script" "WARN" "$dest exists but is not a symlink — skipping (manual fix needed)"
    return
  fi

  ln -s "$src" "$dest"
  log "$script" "linked" "$dest"
}
