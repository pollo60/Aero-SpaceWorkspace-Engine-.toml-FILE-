#!/usr/bin/env bash
# =============================================================================
# AeroSpace Workspace Engine — One-Command Installer
# =============================================================================
# Usage: ./install.sh [--no-brew] [--no-reload] [--xdg]
#
#   --no-brew    Skip AeroSpace Homebrew installation check.
#   --no-reload  Skip `aerospace reload-config` at the end.
#   --xdg        Deploy config to ~/.config/aerospace/aerospace.toml
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ── Parse flags ──────────────────────────────────────────────────────────────
SKIP_BREW=false
SKIP_RELOAD=false
USE_XDG=false

for arg in "$@"; do
  case "$arg" in
    --no-brew)   SKIP_BREW=true ;;
    --no-reload) SKIP_RELOAD=true ;;
    --xdg)       USE_XDG=true ;;
    -h|--help)
      echo "Usage: $0 [--no-brew] [--no-reload] [--xdg]"
      exit 0 ;;
    *)
      error "Unknown argument: $arg"
      echo "Usage: $0 [--no-brew] [--no-reload] [--xdg]"
      exit 1 ;;
  esac
done

# ── Resolve repo root ─────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   🚀  AeroSpace Workspace Engine — Installer          ║${RESET}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Check macOS ───────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  error "This installer is for macOS only."
  exit 1
fi
success "macOS detected."

# ── 2. AeroSpace installation ────────────────────────────────────────────────
if $SKIP_BREW; then
  info "Skipping AeroSpace installation check (--no-brew)."
else
  if command -v aerospace &>/dev/null; then
    AERO_VER="$(aerospace --version 2>/dev/null || echo 'unknown')"
    success "AeroSpace is already installed ($AERO_VER)."
  else
    warn "AeroSpace not found."
    if command -v brew &>/dev/null; then
      info "Installing AeroSpace via Homebrew…"
      brew install --cask nikitabobko/tap/aerospace
      success "AeroSpace installed."
    else
      error "Homebrew is not installed. Install it first: https://brew.sh"
      error "Or re-run with --no-brew to skip this check."
      exit 1
    fi
  fi
fi

# ── 3. Deploy aerospace.toml ──────────────────────────────────────────────────
TOML_SRC="${REPO_ROOT}/aerospace.toml"
[[ ! -f "$TOML_SRC" ]] && TOML_SRC="${REPO_ROOT}/.aerospace.toml"

if [[ ! -f "$TOML_SRC" ]]; then
  error "AeroSpace TOML not found in repo root: ${TOML_SRC}"
  exit 1
fi

if $USE_XDG; then
  AEROSPACE_CFG="${HOME}/.config/aerospace"
  mkdir -p "$AEROSPACE_CFG"
  TOML_DST="${AEROSPACE_CFG}/aerospace.toml"
else
  TOML_DST="${HOME}/.aerospace.toml"
fi

if [[ -f "$TOML_DST" ]]; then
  BACKUP="${TOML_DST}.bak.$(date +%Y%m%d_%H%M%S)"
  warn "Existing config found — backing up to ${BACKUP}"
  cp "$TOML_DST" "$BACKUP"
fi

cp "$TOML_SRC" "$TOML_DST"
success "Deployed config → ${TOML_DST}"

# ── 4. Deploy scripts ─────────────────────────────────────────────────────────
SCRIPTS_SRC="${REPO_ROOT}/scripts"
AEROSPACE_CFG="${HOME}/.config/aerospace"

mkdir -p "$AEROSPACE_CFG"
success "Config directory ready: ${AEROSPACE_CFG}"

# dock-layout-sync.sh
SYNC_SRC="${SCRIPTS_SRC}/dock-layout-sync.sh"
SYNC_DST="${AEROSPACE_CFG}/dock-layout-sync.sh"
if [[ -f "$SYNC_SRC" ]]; then
  cp "$SYNC_SRC" "$SYNC_DST"
  chmod +x "$SYNC_DST"
  success "Deployed dock-layout-sync.sh → ${SYNC_DST}"
else
  info "dock-layout-sync.sh not found in scripts/ — skipping."
fi

# get_appid.sh — install to ~/bin for convenience
BIN_DIR="${HOME}/bin"
mkdir -p "$BIN_DIR"
APPID_SRC="${SCRIPTS_SRC}/get_appid.sh"
APPID_DST="${BIN_DIR}/get_appid"
if [[ -f "$APPID_SRC" ]]; then
  cp "$APPID_SRC" "$APPID_DST"
  chmod +x "$APPID_DST"
  success "Deployed get_appid → ${APPID_DST}"
fi

# list_apps.sh — install to ~/bin for convenience
LIST_SRC="${SCRIPTS_SRC}/list_apps.sh"
LIST_DST="${BIN_DIR}/list_apps"
if [[ -f "$LIST_SRC" ]]; then
  cp "$LIST_SRC" "$LIST_DST"
  chmod +x "$LIST_DST"
  success "Deployed list_apps → ${LIST_DST}"
fi

# Remind user to add ~/bin to PATH if it isn't already there
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  warn "~/bin is not in your PATH."
  warn "Add the following to your shell profile (~/.zshrc or ~/.bashrc):"
  echo ""
  echo -e "    ${BOLD}export PATH="\$HOME/bin:\$PATH"${RESET}"
  echo ""
  info "Then reload your shell:"
  echo -e "    ${BOLD}source ~/.zshrc${RESET}   (or ${BOLD}source ~/.bashrc${RESET} if using bash)"
  echo ""
fi

# ── 5. Reload AeroSpace config ───────────────────────────────────────────────
if $SKIP_RELOAD; then
  info "Skipping config reload (--no-reload)."
elif command -v aerospace &>/dev/null; then
  info "Reloading AeroSpace config…"
  aerospace reload-config && success "AeroSpace config reloaded." \
    || warn "Could not reload config automatically. Run: aerospace reload-config"
else
  info "AeroSpace CLI not found in PATH — start AeroSpace to apply the config."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}✅  Installation complete!${RESET}"
echo ""
echo -e "  ${BOLD}Tip:${RESET} To identify bundle IDs for new apps, run:"
echo -e "       ${CYAN}./scripts/get_appid.sh${RESET}   (or ${CYAN}get_appid${RESET} if ~/bin is in your PATH)"
echo ""
echo -e "  ${BOLD}Tip:${RESET} To list all running app bundle IDs, run:"
echo -e "       ${CYAN}./scripts/list_apps.sh${RESET}   (or ${CYAN}list_apps${RESET} if ~/bin is in your PATH)"
echo ""
