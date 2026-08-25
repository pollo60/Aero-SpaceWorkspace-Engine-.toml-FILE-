#!/bin/bash
# =============================================================================
# get_appid.sh — Print the bundle identifier of the frontmost macOS app.
# =============================================================================
# Usage:
#   ./scripts/get_appid.sh           # interactive: 3-second countdown then capture
#   ./scripts/get_appid.sh --now     # capture immediately (no countdown)
#   ./scripts/get_appid.sh --copy    # copy result to clipboard via pbcopy
# =============================================================================

set -euo pipefail

COPY=false
COUNTDOWN=true

for arg in "$@"; do
  case "$arg" in
    --copy)  COPY=true ;;
    --now)   COUNTDOWN=false ;;
    -h|--help)
      echo "Usage: $0 [--now] [--copy]"
      echo "  --now   Skip the 3-second countdown."
      echo "  --copy  Copy the bundle ID to the clipboard."
      exit 0 ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1 ;;
  esac
done

if $COUNTDOWN; then
  echo "Switch to the target window. Capturing in:"
  for i in 3 2 1; do
    echo "  ${i}..."
    sleep 1
  done
fi

APP_ID="$(osascript -e \
  'tell application "System Events" to get bundle identifier of process (name of first process whose frontmost is true)' \
  2>/dev/null || true)"

if [[ -z "$APP_ID" ]]; then
  echo "Error: Could not retrieve bundle identifier." >&2
  echo "Make sure Accessibility permissions are granted for Terminal/iTerm2." >&2
  exit 1
fi

echo ""
echo "Bundle ID: ${APP_ID}"
echo ""
echo "AeroSpace snippet:"
echo "  [[on-window-detected]]"
echo "  if.app-id = '${APP_ID}'"
echo "  run = ['move-node-to-workspace <WORKSPACE>', 'layout tiling']"

if $COPY; then
  echo "$APP_ID" | pbcopy
  echo ""
  echo "✅ Bundle ID copied to clipboard."
fi
