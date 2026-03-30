#!/usr/bin/env bash
# workspace_status.sh — display a formatted snapshot of AeroSpace workspaces
#
# Usage:
#   ./scripts/workspace_status.sh [OPTIONS]
#
# Options:
#   -w, --workspace WS   Show only the specified workspace (e.g. Code)
#   -s, --short          Compact single-line-per-window output
#   -j, --json           Raw JSON output (requires aerospace CLI)
#   -h, --help           Show this help message
#
# Requires: aerospace CLI in PATH.

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────
FILTER_WS=""
SHORT=false
JSON_MODE=false

# ── Argument parsing ──────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--workspace) FILTER_WS="$2"; shift 2 ;;
    -s|--short)     SHORT=true;     shift ;;
    -j|--json)      JSON_MODE=true; shift ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# *//'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Dependency check ──────────────────────────────────────────────────────
if ! command -v aerospace &>/dev/null; then
  echo "Error: 'aerospace' CLI not found in PATH." >&2
  echo "Install AeroSpace: brew install --cask nikitabobko/tap/aerospace" >&2
  exit 1
fi

# ── JSON passthrough ──────────────────────────────────────────────────────
if $JSON_MODE; then
  if [[ -n "$FILTER_WS" ]]; then
    aerospace list-windows --workspace "$FILTER_WS" --json
  else
    aerospace list-windows --all --json
  fi
  exit 0
fi

# ── Build workspace list ──────────────────────────────────────────────────
if [[ -n "$FILTER_WS" ]]; then
  workspaces=("$FILTER_WS")
else
  mapfile -t workspaces < <(aerospace list-workspaces --all)
fi

# ── Short mode: compact table ─────────────────────────────────────────────
if $SHORT; then
  for ws in "${workspaces[@]}"; do
    count=0
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      ((count++))
    done < <(aerospace list-windows --workspace "$ws" 2>/dev/null || true)
    printf "%-10s  %d window(s)\n" "$ws" "$count"
  done
  exit 0
fi

# ── Full mode: workspace cards ────────────────────────────────────────────
WORKSPACES_WITH_FOCUS=()
FOCUSED_WS="$(aerospace list-workspaces --focused 2>/dev/null || echo '')"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  AeroSpace Workspace Status              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

for ws in "${workspaces[@]}"; do
  focus_marker=""
  [[ "$ws" == "$FOCUSED_WS" ]] && focus_marker=" ◀ focused"

  echo "┌─────────────────────────────────────────────────────────"
  printf "│  Workspace: %-8s%s\n" "$ws" "$focus_marker"
  echo "├─────────────────────────────────────────────────────────"

  window_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    printf "│    %s\n" "$line"
    ((window_count++))
  done < <(aerospace list-windows --workspace "$ws" 2>/dev/null || true)

  if (( window_count == 0 )); then
    echo "│    (empty)"
  fi
  echo "└─────────────────────────────────────────────────────────"
  echo ""
done
