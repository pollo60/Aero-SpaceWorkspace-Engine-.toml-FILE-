#!/bin/bash
# =============================================================================
# list_apps.sh — List all running macOS applications with their bundle IDs.
# =============================================================================
# Usage:
#   ./scripts/list_apps.sh              # full table
#   ./scripts/list_apps.sh --sort name  # sort by app name (default)
#   ./scripts/list_apps.sh --sort id    # sort by bundle ID
#   ./scripts/list_apps.sh --grep <pat> # filter by name or ID (case-insensitive)
# =============================================================================

set -euo pipefail

SORT_BY="name"
GREP_PAT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sort)
      SORT_BY="${2:-name}"
      shift 2 ;;
    --grep)
      GREP_PAT="${2:-}"
      shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--sort name|id] [--grep <pattern>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1 ;;
  esac
done

# Gather data via AppleScript (returns "Name\tBundleID" pairs)
RAW="$(osascript <<'EOF'
set output to {}
tell application "System Events"
  set processList to every process whose background only is false
  repeat with p in processList
    set appName to name of p
    try
      set bundleId to bundle identifier of p
    on error
      set bundleId to "(no bundle ID)"
    end try
    set end of output to appName & tab & bundleId
  end repeat
end tell
return output as text
EOF
)"

if [[ -z "$RAW" ]]; then
  echo "No running GUI applications found." >&2
  exit 0
fi

# ── Sort ──────────────────────────────────────────────────────────────────────
if [[ "$SORT_BY" == "id" ]]; then
  SORTED="$(echo "$RAW" | sort -t$'\t' -k2)"
else
  SORTED="$(echo "$RAW" | sort -t$'\t' -k1)"
fi

# ── Filter ────────────────────────────────────────────────────────────────────
if [[ -n "$GREP_PAT" ]]; then
  SORTED="$(echo "$SORTED" | grep -i "$GREP_PAT" || true)"
  if [[ -z "$SORTED" ]]; then
    echo "No apps matched pattern: ${GREP_PAT}"
    exit 0
  fi
fi

# ── Display ───────────────────────────────────────────────────────────────────
printf "%-40s %s\n" "APP NAME" "BUNDLE ID"
printf "%-40s %s\n" "$(printf '%.0s-' {1..40})" "$(printf '%.0s-' {1..40})"

while IFS=$'\t' read -r app_name bundle_id; do
  printf "%-40s %s\n" "$app_name" "$bundle_id"
done <<< "$SORTED"

echo ""
echo "Tip: To filter by name or ID, run:  $0 --grep <pattern>"
echo "Tip: To get the ID of the frontmost window interactively, run: get_appid.sh"
