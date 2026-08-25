#!/usr/bin/env bash
# =============================================================================
# scripts/toggle_macgod.sh — Toggle MacGOD Ghost Mode on/off
# =============================================================================
# Edits the AeroSpace config in-place to switch between:
#   • Standard mode  (AeroSpace tiling, no yabai/Phoenix)
#   • MacGOD mode    (AeroSpace float + yabai title-bar removal + Phoenix)
#
# Usage:
#   ./scripts/toggle_macgod.sh          # auto-detect current state and flip
#   ./scripts/toggle_macgod.sh --on     # force MacGOD mode on
#   ./scripts/toggle_macgod.sh --off    # force MacGOD mode off
#   ./scripts/toggle_macgod.sh --status # print current state and exit
#   ./scripts/toggle_macgod.sh --help   # display usage instructions
# =============================================================================
set -euo pipefail

# Auto-detect target TOML location if not explicitly provided
if [[ -n "${AEROSPACE_TOML:-}" ]]; then
    TOML="$AEROSPACE_TOML"
elif [[ -f "$HOME/.config/aerospace/aerospace.toml" ]]; then
    TOML="$HOME/.config/aerospace/aerospace.toml"
else
    TOML="$HOME/.aerospace.toml"
fi

YABAIRC="${YABAIRC:-$HOME/.yabairc}"
PHOENIXJS="${PHOENIXJS:-$HOME/.phoenix.js}"

# Relative path to config files from the repo root (one level up from scripts/).
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_YABAIRC="$REPO_ROOT/configs/yabairc"
REPO_PHOENIXJS="$REPO_ROOT/configs/phoenix.js"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
die()   { echo "❌  $*" >&2; exit 1; }
info()  { echo "ℹ️   $*"; }
ok()    { echo "✅  $*"; }
warn()  { echo "⚠️   $*"; }

require_toml() {
    if [[ ! -f "$TOML" ]]; then
        echo "❌  Could not find AeroSpace TOML at: $TOML" >&2
        echo "    Deploy it first with: ./install.sh" >&2
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Detect current mode by inspecting the TOML.
# MacGOD mode is active when default-root-container-layout = 'float'
# ---------------------------------------------------------------------------
current_mode() {
    if grep -q "^default-root-container-layout = 'float'" "$TOML" 2>/dev/null; then
        echo "macgod"
    else
        echo "standard"
    fi
}

# ---------------------------------------------------------------------------
# Apply TOML patches
# ---------------------------------------------------------------------------

activate_macgod() {
    require_toml
    info "Activating MacGOD Ghost Mode …"

    # 1. Patch AeroSpace TOML: normalization off + float layout
    sed -i.bak \
        -e "s/^enable-normalization-flatten-containers = true$/enable-normalization-flatten-containers = false/" \
        -e "s/^enable-normalization-opposite-orientation-for-nested-containers = true$/enable-normalization-opposite-orientation-for-nested-containers = false/" \
        -e "s/^default-root-container-layout = 'tiles'$/default-root-container-layout = 'float'/" \
        "$TOML"
    
    # Validate that patches succeeded
    if grep -q "default-root-container-layout = 'float'" "$TOML"; then
        ok "Patched $TOML for MacGOD mode."
    else
        die "Failed to patch TOML; check file format and try again."
    fi

    # 2. Deploy yabai config if not already present
    if [[ -f "$REPO_YABAIRC" ]]; then
        if [[ -f "$YABAIRC" ]] && ! diff -q "$REPO_YABAIRC" "$YABAIRC" >/dev/null 2>&1; then
            cp "$YABAIRC" "${YABAIRC}.bak"
            info "Backed up existing ~/.yabairc to ~/.yabairc.bak"
        fi
        cp "$REPO_YABAIRC" "$YABAIRC"
        chmod +x "$YABAIRC"
        ok "Deployed $YABAIRC"
    else
        warn "configs/yabairc not found in repo — skipping yabai config deployment."
    fi

    # 3. Deploy Phoenix config if not already present
    if [[ -f "$REPO_PHOENIXJS" ]]; then
        if [[ -f "$PHOENIXJS" ]] && ! diff -q "$REPO_PHOENIXJS" "$PHOENIXJS" >/dev/null 2>&1; then
            cp "$PHOENIXJS" "${PHOENIXJS}.bak"
            info "Backed up existing ~/.phoenix.js to ~/.phoenix.js.bak"
        fi
        cp "$REPO_PHOENIXJS" "$PHOENIXJS"
        ok "Deployed $PHOENIXJS"
    else
        warn "configs/phoenix.js not found in repo — skipping Phoenix config deployment."
    fi

    # 4. Check if yabai / Phoenix are installed; offer guidance if not
    if ! command -v yabai &>/dev/null; then
        warn "yabai is not installed. Install it with:"
        warn "  brew install koekeishiya/formulae/yabai"
        warn "  sudo yabai --install-sa"
        warn "  brew services start yabai"
    else
        info "Restarting yabai …"
        brew services restart yabai 2>/dev/null || yabai --restart-service 2>/dev/null || true
    fi

    if ! command -v phoenix &>/dev/null; then
        warn "Phoenix is not installed. Install it with:"
        warn "  brew install --cask phoenix"
    else
        info "Restarting Phoenix …"
        open -a Phoenix 2>/dev/null || true
    fi

    # 5. Reload AeroSpace config
    if command -v aerospace &>/dev/null; then
        aerospace reload-config
        ok "AeroSpace config reloaded."
    else
        warn "aerospace CLI not found — reload manually: aerospace reload-config"
    fi

    ok "MacGOD Ghost Mode is now ACTIVE."
    echo ""
    echo "  AeroSpace : float layout  (yabai + Phoenix own window geometry)"
    echo "  yabai     : title bars removed, shadows off"
    echo "  Phoenix   : ⌘⌃+arrows for position snapping, ⌘⌃+Return to maximise"
    echo ""
    echo "  ⚠️  If title bars reappear after a macOS update, run:"
    echo "     sudo yabai --install-sa && brew services restart yabai"
}

deactivate_macgod() {
    require_toml
    info "Deactivating MacGOD Ghost Mode (restoring standard tiling) …"

    # 1. Patch AeroSpace TOML back to tiling defaults
    sed -i.bak \
        -e "s/^enable-normalization-flatten-containers = false$/enable-normalization-flatten-containers = true/" \
        -e "s/^enable-normalization-opposite-orientation-for-nested-containers = false$/enable-normalization-opposite-orientation-for-nested-containers = true/" \
        -e "s/^default-root-container-layout = 'float'$/default-root-container-layout = 'tiles'/" \
        "$TOML"
    ok "Patched $TOML for standard tiling mode."

    # 2. Stop yabai if running
    if command -v yabai &>/dev/null; then
        info "Stopping yabai …"
        brew services stop yabai 2>/dev/null || yabai --stop-service 2>/dev/null || true
        ok "yabai stopped."
    fi

    # 3. Quit Phoenix if running
    if pgrep -x Phoenix &>/dev/null; then
        info "Quitting Phoenix …"
        osascript -e 'tell application "Phoenix" to quit' 2>/dev/null || killall Phoenix 2>/dev/null || true
        ok "Phoenix quit."
    fi

    # 4. Reload AeroSpace config
    if command -v aerospace &>/dev/null; then
        aerospace reload-config
        ok "AeroSpace config reloaded."
    else
        warn "aerospace CLI not found — reload manually: aerospace reload-config"
    fi

    ok "Standard tiling mode is now ACTIVE."
}

print_status() {
    require_toml
    local mode
    mode="$(current_mode)"
    if [[ "$mode" == "macgod" ]]; then
        echo "🔥  MacGOD Ghost Mode : ACTIVE"
        echo "    TOML layout : float  (yabai + Phoenix expected to be running)"
    else
        echo "🏗️   Standard Tiling Mode : ACTIVE"
        echo "    TOML layout : tiles  (AeroSpace owns all geometry)"
    fi

    echo ""
    echo "Config file : $TOML"

    if command -v yabai &>/dev/null; then
        echo "yabai       : $(yabai --version 2>/dev/null || echo 'installed (version unknown)')"
    else
        echo "yabai       : not installed"
    fi

    if command -v phoenix &>/dev/null; then
        echo "Phoenix     : installed"
    else
        echo "Phoenix     : not installed"
    fi
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
case "${1:-}" in
    -h|--help)
        echo "Usage: $(basename "$0") [--on | --off | --status | --help]"
        exit 0
        ;;
    --on)     activate_macgod   ;;
    --off)    deactivate_macgod ;;
    --status) print_status      ;;
    "")
        require_toml
        mode="$(current_mode)"
        if [[ "$mode" == "macgod" ]]; then
            deactivate_macgod
        else
            activate_macgod
        fi
        ;;
    *)
        echo "Usage: $(basename "$0") [--on | --off | --status | --help]"
        exit 1
        ;;
esac
