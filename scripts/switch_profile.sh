#!/usr/bin/env bash
# switch_profile.sh — activate an AeroSpace config profile
#
# Usage:
#   ./scripts/switch_profile.sh [PROFILE]
#
#   PROFILE   Name (without .toml) of a file inside ./profiles/ or a
#             full path to any .toml file.
#             Supported built-in names: default | macgod | laptop
#
# With no argument the script lists available profiles and lets you
# pick one interactively.
#
# Examples:
#   ./scripts/switch_profile.sh default
#   ./scripts/switch_profile.sh macgod
#   ./scripts/switch_profile.sh laptop
#   ./scripts/switch_profile.sh ~/my-custom.toml
#   ./scripts/switch_profile.sh          # interactive menu

set -euo pipefail

# ── Locate the profiles/ directory relative to this script ────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PROFILES_DIR="$REPO_ROOT/profiles"
BACKUP_DIR="$HOME/.aerospace_profiles_backup"

# Auto-detect target config path
if [[ -f "$HOME/.config/aerospace/aerospace.toml" ]]; then
  TARGET="$HOME/.config/aerospace/aerospace.toml"
else
  TARGET="$HOME/.aerospace.toml"
fi

# ── Helpers ───────────────────────────────────────────────────────────────
usage() {
  echo "Usage: $(basename "$0") [PROFILE|path/to/file.toml]"
  echo ""
  echo "Available built-in profiles:"
  for f in "$PROFILES_DIR"/*.toml; do
    [[ -f "$f" ]] && echo "  $(basename "${f%.toml}")"
  done
  exit 0
}

backup_current() {
  if [[ -f "$TARGET" ]]; then
    mkdir -p "$BACKUP_DIR"
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    cp "$TARGET" "$BACKUP_DIR/aerospace.$ts.toml"
    echo "  ↳ Backed up current config to $BACKUP_DIR/aerospace.$ts.toml"
  fi
}

activate() {
  local src="$1"
  if [[ ! -f "$src" ]]; then
    echo "Error: profile file not found: $src" >&2
    exit 1
  fi
  backup_current
  mkdir -p "$(dirname "$TARGET")"
  cp "$src" "$TARGET"
  echo "✓ Profile applied: $src → $TARGET"

  # Reload AeroSpace if it is running.
  if command -v aerospace &>/dev/null; then
    aerospace reload-config && echo "✓ AeroSpace reloaded." || true
  else
    echo "  ↳ AeroSpace not found in PATH — start AeroSpace to load the new profile."
  fi
}

# ── Interactive menu ──────────────────────────────────────────────────────
interactive_menu() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   AeroSpace Profile Switcher         ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  local -a profiles=()
  for f in "$PROFILES_DIR"/*.toml; do
    [[ -f "$f" ]] && profiles+=("$(basename "${f%.toml}")")
  done

  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "No profiles found in $PROFILES_DIR" >&2
    exit 1
  fi

  echo "Available profiles:"
  local i=1
  for p in "${profiles[@]}"; do
    echo "  $i) $p"
    ((i++))
  done
  echo ""
  read -r -p "Enter number [1-${#profiles[@]}]: " choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#profiles[@]} )); then
    echo "Invalid selection." >&2
    exit 1
  fi

  local selected="${profiles[$((choice - 1))]}"
  activate "$PROFILES_DIR/$selected.toml"
}

# ── Main ──────────────────────────────────────────────────────────────────
case "${1:-}" in
  -h|--help)
    usage
    ;;
  "")
    interactive_menu
    ;;
  default)
    if [[ -f "$PROFILES_DIR/default.toml" ]]; then
      activate "$PROFILES_DIR/default.toml"
    elif [[ -f "$REPO_ROOT/aerospace.toml" ]]; then
      activate "$REPO_ROOT/aerospace.toml"
    else
      activate "$REPO_ROOT/.aerospace.toml"
    fi
    ;;
  *)
    # Accept either a bare name or a full path.
    if [[ -f "$1" ]]; then
      activate "$1"
    elif [[ -f "$PROFILES_DIR/$1.toml" ]]; then
      activate "$PROFILES_DIR/$1.toml"
    else
      echo "Error: '$1' is not a recognised profile or an existing file." >&2
      echo "Run '$(basename "$0") --help' to see available profiles." >&2
      exit 1
    fi
    ;;
esac
