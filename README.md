# **🚀 AeroSpace Workspace Engine (.toml FILE)**

*A high-performance, hybrid window management configuration for macOS.*

This repository contains the production-ready [AeroSpace](https://github.com/nikitabobko/AeroSpace) configuration designed for seamless, zero-latency window management.

Designed with Strategic Software Engineering and Architecture in mind, this configuration bridges the gap between strict Tiling Window Management (TWM) and macOS's native floating behavior, resulting in a context-switching powerhouse that works **100% out of the box with zero setup required**.

> **MacGOD Ready** — This config ships pre-wired for MacGOD (yabai + Phoenix integration). A single toggle inside the file switches it into full Ghost Mode where yabai removes title bars and Phoenix owns window logic. See the *MacGOD Deployment* section below.

---

## **⚡ 10-Second Quick Start (Direct Download)**

Want just the clean, battle-tested TOML configuration without cloning the repository? Download it directly to your machine with a single command:

```bash
# Option A: Standard root location (~/.aerospace.toml)
curl -fsSL https://raw.githubusercontent.com/pollo60/Aero-SpaceWorkspace-Engine-.toml-FILE-/main/aerospace.toml -o ~/.aerospace.toml

# Option B: XDG config location (~/.config/aerospace/aerospace.toml)
mkdir -p ~/.config/aerospace && curl -fsSL https://raw.githubusercontent.com/pollo60/Aero-SpaceWorkspace-Engine-.toml-FILE-/main/aerospace.toml -o ~/.config/aerospace/aerospace.toml
```

Then reload AeroSpace:
```bash
aerospace reload-config
```

*That's it! The TOML is 100% self-contained and immediately functional.*

---

## **🧠 Architectural Core Principles**

1. **Named Workspaces:** Workspaces carry semantic identities (`AI`, `Code`, `CLI`, `Browser`, `Media`, `Social`) instead of opaque numbers, so `alt+1` always means *AI context* regardless of how many spaces macOS has shuffled around.
2. **Zero Gaps, Maximum Data:** All inner and outer gaps are set to 0. Every pixel matters.
3. **Strict App-to-Workspace Routing:** Applications are automatically sorted into dedicated, persistent workspaces upon launch to eliminate cognitive overload.
4. **Window Follows You:** `Opt + Shift + Number` moves the focused window *and* teleports you to the destination workspace.
5. **Hardware Synergy:** Deeply integrated with [Mac Mouse Fix](https://macmousefix.com/) for fluid multi-monitor interactions.

---

## **🏗 Workspace Taxonomy**

The workspace routing is hardcoded via regex and Bundle IDs to maintain absolute order:

| Key | Workspace | Domain | Auto-Routed Applications |
| :---- | :---- | :---- | :---- |
| **alt+1** | **AI** | 🤖 AI / Agentic Logic | Gemini, ChatGPT, Claude, Copilot (PWAs or native) |
| **alt+2** | **Code** | 💻 IDE / Engineering | Visual Studio Code, Cursor, Xcode, Zed, JetBrains IDEs |
| **alt+3** | **CLI** | 📟 CLI / Server | iTerm2, Terminal, Warp, Ghostty, Kitty, Hyper |
| **alt+4** | **Browser** | 🌍 Research / Web | Safari, Chrome, Firefox, Arc, Brave, Edge, Vivaldi, Zen, Orion |
| **alt+5** | **Media** | 🎵 Music / Media | Spotify, Apple Music, Plex, VLC, IINA |
| **alt+6** | **Social** | 💬 Communication | Slack, Apple Mail, Messages, Discord, Teams, Zoom, Telegram, WhatsApp, Linear |
| **alt+7** | **7** | 🗒 Notes / Design | Notion, Obsidian, Figma |
| **alt+8–9** | **8 / 9** | 🗒 Scratch / Free | Unassigned — use for ad-hoc contexts |

---

## **⌨️ The Ergonomic Matrix**

This configuration uses a carefully mapped modifier logic. The primary modifier is the Option (⌥) key, designed for minimal finger travel.

### **Window & Focus Control**

| Shortcut | Action | Logic |
| :---- | :---- | :---- |
| Opt + Arrows | **Resize Window** (+/- 80px) | Rapid floating adjustments. |
| Opt + Ctrl + Arrows | **Change Focus** | Directional focus switching. |
| Opt + Shift + Arrows | **Move Window** | Push window in a direction (tiling grid). |
| Opt + F | **Toggle Tiling/Floating** | Switch between strict grid and free-form. |
| ⚠️ **Architect's Note** | **Strictly Arrow Keys** | Exclusively uses Opt + Arrow Keys. No Vim-bindings (H/J/K/L) to minimize cognitive load. |

### **Workspace Navigation**

| Shortcut | Action |
| :---- | :---- |
| Opt + 1–9 | Switch to named workspace (AI, Code, CLI …) |
| Opt + Shift + 1–9 | Move focused window **and follow it** to the named workspace |

---

## **🚀 MacGOD Deployment (Ghost Mode)**

This config is pre-wired for MacGOD — a full God-Mode layer that adds:

* **yabai** (SIP partially disabled) to eliminate window title bars and shadows
* **Phoenix** (JavaScript) for per-window snapping, thirds, and corner positioning

The repository includes complete, ready-to-deploy configuration files for both tools under `configs/`.

### One-Command Toggle

Use the included toggle script to switch between Ghost Mode and standard tiling without manually editing any files:

```bash
# Activate MacGOD Ghost Mode (deploys yabai + Phoenix configs, patches TOML)
./scripts/toggle_macgod.sh --on

# Return to standard AeroSpace tiling mode (stops yabai + Phoenix)
./scripts/toggle_macgod.sh --off

# Auto-detect current state and flip
./scripts/toggle_macgod.sh

# Show current mode without changing anything
./scripts/toggle_macgod.sh --status
```

### What the Toggle Does

| Step | Action |
| :--- | :----- |
| Patches TOML | Flips `default-root-container-layout` between `'tiles'` and `'float'` |
| Deploys `configs/yabairc` | Copies `configs/yabairc` → `~/.yabairc` (backs up existing) |
| Deploys `configs/phoenix.js` | Copies `configs/phoenix.js` → `~/.phoenix.js` (backs up existing) |
| Restarts yabai | Runs `brew services restart yabai` |
| Reloads AeroSpace | Runs `aerospace reload-config` |

### Phoenix Keyboard Bindings (MacGOD mode)

Phoenix adds fine-grained window positioning on top of AeroSpace's workspace switching. All Phoenix bindings use `⌘⌃` (Cmd + Ctrl) to avoid collisions with AeroSpace's `⌥` (Option) layer.

**Note:** `configs/phoenix.js` is the **primary** configuration (using ⌘⌃). A legacy config `configs/phoenixrc.js` using ⌥⌃ bindings is also included as a reference for alternative modifier schemes.

| Shortcut | Action |
| :--- | :----- |
| `⌘⌃ + Return` | Maximise window to fill screen |
| `⌘⌃ + ← / →` | Snap to left / right half |
| `⌘⌃ + ↑ / ↓` | Snap to top / bottom half |
| `⌘⌃⌥ + ← / →` | Snap to left / right third |
| `⌘⌃⌥ + ↑` | Snap to centre third |
| `⌘⌃⌥ + ↓` | Snap to two-thirds (left) |
| `⌘⌃ + 7 / 8 / 1 / 2` | Corner snaps (Top-Left, Top-Right, Bottom-Left, Bottom-Right) |
| `⌘⌃ + C` | Centre window (60% × 80%) |
| `⌘⌃ + M` | Throw focused window to next monitor |
| `⌘⌃ + R` | Reload Phoenix config |

---

## **📁 Config Profiles**

The `profiles/` directory ships ready-to-use config variants. Use `scripts/switch_profile.sh` to activate one instantly.

| Profile file | Use case |
| :---- | :---- |
| `profiles/default.toml` | **Standard Multi-Display Profile** — Full 9 workspaces, tiling layout, auto-reload. |
| `profiles/macgod.toml` | **MacGOD Ghost Mode** — `default-root-container-layout = 'float'`, yabai + Phoenix own chrome & positioning. |
| `profiles/laptop.toml` | **Single-display laptop** — accordion tiling, 7 workspaces, compact defaults for MacBook panel. |

### Activating a Profile

```bash
# Interactive menu
./scripts/switch_profile.sh

# Direct activation by name
./scripts/switch_profile.sh default
./scripts/switch_profile.sh macgod
./scripts/switch_profile.sh laptop

# Or point to any custom TOML
./scripts/switch_profile.sh ~/my-custom.toml
```

The script automatically **backs up** your current configuration to `~/.aerospace_profiles_backup/` before applying the new profile.

---

## **🔭 MacGOD Ghost Mode — Full Config Files**

The `configs/` directory contains the companion files required to run full MacGOD mode:

| File | Purpose |
| :---- | :---- |
| `configs/yabairc` | Minimal yabai config — removes title bars and shadows, keeps layout floating so AeroSpace/Phoenix own positioning. |
| `configs/phoenix.js` | **Primary** Phoenix JavaScript config (⌘⌃ modifier) — grid-snap to halves/thirds/corners, centre, throw to next monitor, and reload. |
| `configs/phoenixrc.js` | Legacy Phoenix JavaScript config (⌥⌃ modifier) — reference implementation for alternative modifier scheme. |

---

## **🛠 Setup & Installation**

### **Quick Install (Full Repository Setup)**

Run the one-command installer from the repository root:

```bash
./install.sh
```

This will:

1. Check for AeroSpace (and offer to install it via Homebrew if missing).
2. Deploy `aerospace.toml` / `.aerospace.toml`, backing up any existing config.
3. Deploy `dock-layout-sync.sh` to `~/.config/aerospace/`.
4. Install the `get_appid` and `list_apps` DX tools to `~/bin/`.
5. Reload AeroSpace configuration automatically.

**Flags:**

| Flag | Effect |
| :--- | :--- |
| `--no-brew` | Skip AeroSpace installation check |
| `--no-reload` | Skip automatic config reload |
| `--xdg` | Deploy config to `~/.config/aerospace/aerospace.toml` |

---

## **⚙️ Customization Protocol**

Despite its high performance, this setup is strictly **beginner-friendly** and highly adaptable.

### Finding App Bundle IDs
Do not guess Bundle IDs. Use the provided Developer Experience (DX) tools:

```bash
# Interactive: 3-second countdown, then captures the frontmost window
./scripts/get_appid.sh

# Capture immediately and copy the result to clipboard
./scripts/get_appid.sh --now --copy

# List all currently running apps with their bundle IDs
./scripts/list_apps.sh

# Filter by name or bundle ID
./scripts/list_apps.sh --grep slack
./scripts/list_apps.sh --grep com.microsoft
```

### DX Toolkit Reference

| Script | Purpose |
| :---- | :---- |
| `scripts/get_appid.sh` | Print the Bundle ID of the currently focused app window. |
| `scripts/list_apps.sh` | List all active GUI applications and their Bundle IDs. |
| `scripts/switch_profile.sh` | Activate a config profile from `profiles/` with automatic backup and reload. |
| `scripts/workspace_status.sh` | Display a formatted snapshot of all workspaces and their windows. |
| `scripts/check_deps.sh` | Verify dependency health and configuration integrity. |
| `scripts/toggle_macgod.sh` | Toggle between Standard Tiling and MacGOD Ghost Mode. |

---

## **🩺 Health Check**

Run the dependency health check at any time to verify the full stack is correctly deployed:

```bash
./scripts/check_deps.sh
```

Exit code `0` = everything healthy. Exit code `1` = one or more items need attention.

---

## **🔭 Further Suggestions: Mac Mouse Fix & Raycast**

1. **Mac Mouse Fix**: For thumb-button monitor switching and workspace throwing.
2. **Raycast**: As your zero-latency keyboard command center for application launching and window navigation.

*Maintained by pollo60 | Strategic Architect*
