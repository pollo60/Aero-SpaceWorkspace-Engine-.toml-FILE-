#!/usr/bin/env bash
# =============================================================================
# scripts/check_deps.sh — AeroSpace Workspace Engine dependency health check
# =============================================================================
# Verifies that all required and optional dependencies are installed and that
# the configuration files are correctly deployed.
#
# Usage:
#   ./scripts/check_deps.sh              # full check, coloured output
#   ./scripts/check_deps.sh --quiet      # exit 0 = all good, exit 1 = issues
# =============================================================================
set -euo pipefail

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

PASS=0
WARN=0
FAIL=0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
ok()   { PASS=$((PASS + 1)); $QUIET || echo "  ✅  $*"; }
warn() { WARN=$((WARN + 1)); $QUIET || echo "  ⚠️   $*"; }
fail() { FAIL=$((FAIL + 1)); $QUIET || echo "  ❌  $*"; }
h1()   { $QUIET || echo ""; $QUIET || echo "── $* ────────────────────────────────"; }

# ---------------------------------------------------------------------------
# 1. Required — AeroSpace
# ---------------------------------------------------------------------------
h1 "Core: AeroSpace"

if command -v aerospace &>/dev/null; then
    ver="$(aerospace --version 2>/dev/null || echo 'unknown')"
    ok "aerospace installed  ($ver)"
else
    fail "aerospace not found.  Install: brew install --cask nikitabobko/tap/aerospace"
fi

# Config file location
TOML="$HOME/.aerospace.toml"
if [[ ! -f "$TOML" && -f "$HOME/.config/aerospace/aerospace.toml" ]]; then
    TOML="$HOME/.config/aerospace/aerospace.toml"
fi

if [[ -f "$TOML" ]]; then
    ok "Config file present ($TOML)"
else
    fail "AeroSpace TOML missing.  Deploy with: ./install.sh  or  cp aerospace.toml ~/.aerospace.toml"
fi

# Dock-sync script (optional daemon)
DOCK_SYNC="$HOME/.config/aerospace/dock-layout-sync.sh"
if [[ -f "$DOCK_SYNC" ]]; then
    if [[ -x "$DOCK_SYNC" ]]; then
        ok "dock-layout-sync.sh present and executable"
    else
        warn "dock-layout-sync.sh present but NOT executable.  Fix: chmod +x \"$DOCK_SYNC\""
    fi
else
    ok "Running in standalone TOML mode (dock-layout-sync.sh optional)"
fi

# ---------------------------------------------------------------------------
# 2. Detect MacGOD mode state
# ---------------------------------------------------------------------------
h1 "MacGOD Ghost Mode"

macgod_active=false
if [[ -f "$TOML" ]]; then
    if grep -q "^default-root-container-layout = 'float'" "$TOML" 2>/dev/null; then
        macgod_active=true
        ok "AeroSpace TOML is in MacGOD (float) mode"
    else
        ok "AeroSpace TOML is in standard tiling mode"
    fi
fi

# ---------------------------------------------------------------------------
# 3. Optional MacGOD dependencies
# ---------------------------------------------------------------------------
if $macgod_active; then
    # yabai
    if command -v yabai &>/dev/null; then
        ver="$(yabai --version 2>/dev/null || echo 'unknown')"
        ok "yabai installed  ($ver)"
    else
        fail "MacGOD mode is ACTIVE but yabai is NOT installed."
        fail "  Install: brew install koekeishiya/formulae/yabai"
        fail "           sudo yabai --install-sa"
        fail "           brew services start yabai"
    fi

    # Phoenix
    if command -v phoenix &>/dev/null || [[ -d "/Applications/Phoenix.app" ]]; then
        ok "Phoenix installed"
    else
        fail "MacGOD mode is ACTIVE but Phoenix is NOT installed."
        fail "  Install: brew install --cask phoenix"
    fi

    # ~/.yabairc
    if [[ -f "$HOME/.yabairc" ]]; then
        ok "~/.yabairc present"
    else
        warn "~/.yabairc missing.  Deploy: ./scripts/toggle_macgod.sh --on"
    fi

    # ~/.phoenix.js
    if [[ -f "$HOME/.phoenix.js" ]]; then
        ok "~/.phoenix.js present"
    else
        warn "~/.phoenix.js missing.  Deploy: ./scripts/toggle_macgod.sh --on"
    fi
else
    # MacGOD off — just check if optional tools are available
    if command -v yabai &>/dev/null; then
        warn "yabai is installed but MacGOD mode is OFF.  Title bars will remain."
        warn "  Activate MacGOD: ./scripts/toggle_macgod.sh --on"
    else
        ok "yabai not needed  (MacGOD mode is OFF)"
    fi

    if command -v phoenix &>/dev/null || [[ -d "/Applications/Phoenix.app" ]]; then
        warn "Phoenix is installed but MacGOD mode is OFF."
    else
        ok "Phoenix not needed  (MacGOD mode is OFF)"
    fi
fi

# ---------------------------------------------------------------------------
# 4. DX utilities
# ---------------------------------------------------------------------------
h1 "DX Scripts"

for script in scripts/get_appid.sh scripts/list_apps.sh scripts/toggle_macgod.sh scripts/check_deps.sh scripts/switch_profile.sh scripts/workspace_status.sh; do
    path="$(cd "$(dirname "$0")/.." && pwd)/$script"
    if [[ -f "$path" ]]; then
        if [[ -x "$path" ]]; then
            ok "$script  (executable)"
        else
            warn "$script exists but is NOT executable.  Fix: chmod +x \"$path\""
        fi
    else
        fail "$script missing from repository"
    fi
done

# ---------------------------------------------------------------------------
# 5. macOS version advisory
# ---------------------------------------------------------------------------
h1 "macOS"

macos_ver="$(sw_vers -productVersion 2>/dev/null || echo 'unknown')"
ok "macOS $macos_ver"

macos_major="$(echo "$macos_ver" | cut -d. -f1)"
if (( macos_major >= 15 )); then
    warn "macOS 15+ — after every OS update, re-run: sudo yabai --install-sa  (if using MacGOD)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
$QUIET || echo ""
$QUIET || echo "═══════════════════════════════════════"
$QUIET || printf "  ✅  %d passed   ⚠️   %d warnings   ❌  %d failed\n" "$PASS" "$WARN" "$FAIL"
$QUIET || echo "═══════════════════════════════════════"

if (( FAIL > 0 )); then
    $QUIET || echo ""
    $QUIET || echo "Run ./install.sh to fix missing files, or see above for manual steps."
    exit 1
fi
