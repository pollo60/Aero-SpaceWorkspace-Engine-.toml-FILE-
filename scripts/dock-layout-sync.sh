#!/usr/bin/env zsh
set -u

last_autohide=""
last_orientation=""

while true; do
  autohide="$(defaults read com.apple.dock autohide 2>/dev/null || echo 0)"
  orientation="$(defaults read com.apple.dock orientation 2>/dev/null || echo bottom)"

  if [[ "$autohide" != "$last_autohide" || "$orientation" != "$last_orientation" ]]; then
    last_autohide="$autohide"
    last_orientation="$orientation"

    # Recompute layout after Dock changes visible screen geometry.
    aerospace flatten-workspace-tree >/dev/null 2>&1
    aerospace balance-sizes >/dev/null 2>&1
  fi

  sleep 1
done
