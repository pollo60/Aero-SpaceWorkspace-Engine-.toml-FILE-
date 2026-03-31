# GitHub Copilot — Workspace Instructions

## Project Overview

This repository is the **AeroSpace Workspace Engine**: a production-ready macOS window
management configuration built on top of [AeroSpace](https://github.com/nikitabobko/AeroSpace),
with optional deep integration of yabai + Phoenix (the "MacGOD Ghost Mode" layer).

The project delivers a zero-latency, context-switching workflow via named workspaces,
automatic app routing, ergonomic keybindings, and a suite of DX shell scripts.

---

## Repository Structure

```
.aerospace.toml            # Core AeroSpace config — named workspaces, app routing, bindings
install.sh                 # One-command installer (deploys config + scripts to ~/...)

scripts/
  dock-layout-sync.sh      # Zsh daemon: rebalances tiling on Dock autohide/orientation change
  get_appid.sh             # Print bundle ID of the frontmost macOS app
  list_apps.sh             # List all running GUI apps with bundle IDs
  toggle_macgod.sh         # Toggle MacGOD Ghost Mode (patches TOML, deploys yabai/Phoenix)
  check_deps.sh            # Health check: verifies all required & optional dependencies
  switch_profile.sh        # Activate a config profile from profiles/ with backup + reload
  workspace_status.sh      # Display a formatted snapshot of all AeroSpace workspaces

configs/
  yabairc                  # Minimal yabai config — removes title bars + shadows
  phoenix.js               # Phoenix JS config — primary, uses ⌘⌃ modifier (MacGOD default)
  phoenixrc.js             # Legacy Phoenix config using ⌥⌃ bindings; kept for reference only

profiles/
  macgod.toml              # AeroSpace profile for MacGOD Ghost Mode (float layout)
  laptop.toml              # AeroSpace profile for single-display laptop (accordion layout)
```

---

## Architecture Principles

1. **Named semantic workspaces** — `AI`, `Code`, `CLI`, `Browser`, `Media`, `Social`, `7`, `8`, `9`
   (not anonymous numbers).  `alt+1` always means the AI context.

2. **Zero gaps** — All inner/outer gaps are 0 to maximise screen real estate.

3. **Strict app-to-workspace routing** — `[[on-window-detected]]` blocks in the TOML
   route every known app to its dedicated workspace on launch, using Bundle IDs where possible
   and regex on app names for PWAs/AI tools.

4. **Window follows you** — `alt-shift-N` runs a two-command chain:
   `['move-node-to-workspace X', 'workspace X']` so the user teleports with the window.

5. **Arrow-key only** — No vim bindings (h/j/k/l).  All navigation uses arrow keys.

6. **MacGOD Ready** — A single `toggle_macgod.sh --on/--off` call switches between standard
   AeroSpace tiling and Ghost Mode (yabai removes title bars; Phoenix handles per-window sizing).

7. **Modifier hierarchy** — `⌥` (Option/alt) is the primary AeroSpace modifier.  Phoenix uses
   `⌘⌃` to avoid all collisions.

---

## Shell Script Conventions

- All bash scripts: `#!/usr/bin/env bash` with `set -euo pipefail`
- All zsh scripts: `#!/usr/bin/env zsh` with `set -u`
- Helper functions `ok()`, `warn()`, `fail()` with emoji prefix for colour output
- Scripts accept `--help` / `-h` and document usage in a comment block at the top
- Exit code `0` = success / everything healthy; exit code `1` = error / check failed

---

## TOML Conventions

- `config-version = 2`
- `start-at-login = true`
- Gaps all set to `0`
- Every new app routing block includes `'layout tiling'` in the run command
- MacGOD toggle section documented with a comment block near the top of the file

---

## Workspace Taxonomy

| Key   | Workspace | Apps (auto-routed)                                                       |
|-------|-----------|--------------------------------------------------------------------------|
| alt+1 | AI        | Gemini, ChatGPT, Claude, Copilot (regex)                                 |
| alt+2 | Code      | VSCode, Cursor, Xcode, Zed, all JetBrains IDEs                           |
| alt+3 | CLI       | iTerm2, Terminal, Warp, Ghostty, Kitty, Hyper                            |
| alt+4 | Browser   | Safari, Chrome, Firefox, Arc, Brave, Edge, Vivaldi                       |
| alt+5 | Media     | Spotify, Apple Music, Plex, VLC, IINA                                    |
| alt+6 | Social    | Slack, Mail, Messages, Discord, Teams, Zoom, Telegram, WhatsApp, Linear  |
| alt+7 | 7         | Notion, Obsidian, Figma                                                  |
| alt+8 | 8         | Unassigned scratch                                                       |
| alt+9 | 9         | Unassigned scratch                                                       |

---

## Key Bindings Summary

| Shortcut              | Action                                      |
|-----------------------|---------------------------------------------|
| `alt + arrows`        | Resize window ±80 px                        |
| `alt + ctrl + arrows` | Change focus direction                      |
| `alt + shift + arrows`| Move window in tiling grid                  |
| `alt + f`             | Toggle tiling ↔ floating                   |
| `alt + 1–9`           | Switch to named workspace                   |
| `alt + shift + 1–9`   | Move window AND follow it to workspace      |
| `alt + m`             | Focus next monitor (wrap-around)            |
| `alt + shift + m`     | Move workspace to next monitor              |
| `alt + shift + n`     | Move focused window to next monitor         |
| `alt + ctrl + r`      | Force tiling layout on focused window       |
| `alt + ctrl + d`      | Flatten tree + balance sizes                |
| `alt + shift + r`     | Reload AeroSpace config                     |

---

## Phoenix Bindings (MacGOD mode — `⌘⌃`)

| Shortcut        | Action                          |
|-----------------|---------------------------------|
| `⌘⌃ + Return`  | Maximise to fill screen         |
| `⌘⌃ + ←/→`    | Snap to left / right half       |
| `⌘⌃ + ↑/↓`    | Snap to top / bottom half       |
| `⌘⌃⌥ + ←`     | Snap to left third              |
| `⌘⌃⌥ + →`     | Snap to right third             |
| `⌘⌃⌥ + ↑`     | Snap to centre third            |
| `⌘⌃⌥ + ↓`     | Snap to two-thirds (left)       |
| `⌘⌃ + 7/8/1/2`| Corner snaps (TL/TR/BL/BR)     |
| `⌘⌃ + C`       | Centre window (keep size)       |
| `⌘⌃ + M`       | Throw window to next monitor    |
| `⌘⌃ + R`       | Reload Phoenix config           |
