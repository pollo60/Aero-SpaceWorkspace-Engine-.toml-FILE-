# AeroSpace Workspace Engine — Master Prompt

> **How to use this file:**
> Open GitHub Copilot Chat in VSCode (⌃⌘I or the sidebar icon), switch to **Agent mode**,
> then paste the entire prompt block below.  Copilot will autonomously create or update
> every file in the repository until the full feature set is complete.

---

## Master Prompt (paste into Copilot Agent)

```
You are implementing the AeroSpace Workspace Engine — a production-ready macOS window
management configuration.  Work autonomously through every task below, in order, without
stopping for confirmation.  After completing ALL tasks, print a final checklist showing
each item as ✅ complete.

═══════════════════════════════════════════════════════════
PROJECT CONTEXT
═══════════════════════════════════════════════════════════

This is a macOS window manager config repository built around AeroSpace (a tiling window
manager).  The full stack is:

  • AeroSpace (.aerospace.toml)  — tiling engine, workspace switching, keybindings
  • yabai                        — title-bar + shadow removal (MacGOD mode only)
  • Phoenix (phoenix.js)         — per-window JavaScript sizing/snap bindings (MacGOD mode)

The workspace taxonomy is FIXED and must be maintained exactly:
  AI | Code | CLI | Browser | Media | Social | 7 | 8 | 9

═══════════════════════════════════════════════════════════
TASK 1 — .aerospace.toml  (root config file)
═══════════════════════════════════════════════════════════

Create or update .aerospace.toml in the repo root with these exact requirements:

  config-version = 2
  start-at-login = true
  after-startup-command = ['exec-and-forget /bin/zsh ~/.config/aerospace/dock-layout-sync.sh']

  MacGOD toggle comment block near the top explaining the three lines to swap.

  enable-normalization-flatten-containers = true
  enable-normalization-opposite-orientation-for-nested-containers = true
  accordion-padding = 0
  default-root-container-layout = 'tiles'
  default-root-container-orientation = 'horizontal'

  persistent-workspaces = ['AI', 'Code', 'CLI', 'Browser', 'Media', 'Social', '7', '8', '9']

  [gaps] — all values = 0 (inner.horizontal, inner.vertical, outer.left/right/top/bottom)

  [[on-window-detected]] blocks (in this order):
    1. Catch-all: app-name-regex '.*' → 'layout tiling', check-further-callbacks = true
    2. AI:      regex '(?i)(gemini|chatgpt|claude|copilot)' → move to AI + layout tiling
    3. Code:    VSCode (com.microsoft.VSCode), Cursor (com.todesktop.230313mzl4w4u92),
                Xcode (com.apple.dt.Xcode), Zed (dev.zed.Zed),
                JetBrains regex '(?i)(intellij|webstorm|pycharm|goland|clion|datagrip|rubymine|rider)'
    4. CLI:     iTerm2, Terminal, Warp (dev.warp.Warp), Ghostty (com.mitchellh.ghostty),
                Kitty (net.kovidgoyal.kitty), Hyper (co.zeit.hyper)
    5. Browser: Safari, Chrome, Firefox, Arc (company.thebrowser.Browser),
                Brave (com.brave.Browser), Edge (com.microsoft.edgemac),
                Vivaldi (com.vivaldi.Vivaldi)
    6. Media:   Spotify, Apple Music, Plex (com.plexapp.plex), VLC (org.videolan.vlc),
                IINA (com.colliderli.iina)
    7. Social:  Slack (com.tinyspeck.slackmacgap), Mail (com.apple.mail),
                Messages (com.apple.MobileSMS), Discord (com.hnc.Discord),
                Teams (com.microsoft.teams2), Zoom (us.zoom.xos),
                Telegram (ru.keepcoder.Telegram), WhatsApp (net.whatsapp.WhatsApp),
                Linear (com.linear)
    8. 7:       Notion (notion.id), Obsidian (md.obsidian), Figma (com.figma.Desktop)
    9. Float:   systempreferences (com.apple.systempreferences),
                ActivityMonitor (com.apple.ActivityMonitor)

  [mode.main.binding]:
    Multi-monitor:
      alt-shift-m = 'move-workspace-to-monitor --wrap-around next'
      alt-m       = 'focus-monitor --wrap-around next'
      alt-shift-n = 'move-node-to-monitor --wrap-around next'
    Resize (±80px):
      alt-up/down/right/left
    Focus:
      alt-ctrl-up/down/right/left
    Move window in grid:
      alt-shift-up/down/right/left
    Toggle float:
      alt-f = 'layout floating tiling'
    Workspace switch (alt+1…9 → named workspaces AI…9):
      alt-1 → AI, alt-2 → Code, alt-3 → CLI, alt-4 → Browser,
      alt-5 → Media, alt-6 → Social, alt-7 → 7, alt-8 → 8, alt-9 → 9
    Move + follow (alt-shift+1…9):
      alt-shift-1 = ['move-node-to-workspace AI', 'workspace AI']   etc.
    Repair / debug:
      alt-ctrl-r  = 'layout tiling'
      alt-ctrl-d  = ['flatten-workspace-tree', 'balance-sizes']
      alt-shift-r = 'reload-config'

═══════════════════════════════════════════════════════════
TASK 2 — install.sh  (one-command installer)
═══════════════════════════════════════════════════════════

Create or update install.sh in the repo root:

  #!/usr/bin/env bash
  set -euo pipefail

  Flags: --no-brew (skip AeroSpace install check), --no-reload (skip reload)

  Steps:
    1. Assert macOS (uname == Darwin)
    2. Unless --no-brew: check for 'aerospace'; if missing, install via
       'brew install --cask nikitabobko/tap/aerospace'
    3. Backup existing ~/.aerospace.toml with timestamp, then copy .aerospace.toml → ~/.aerospace.toml
    4. mkdir -p ~/.config/aerospace
       Copy scripts/dock-layout-sync.sh → ~/.config/aerospace/dock-layout-sync.sh; chmod +x
    5. mkdir -p ~/bin
       Copy scripts/get_appid.sh → ~/bin/get_appid; chmod +x
       Copy scripts/list_apps.sh → ~/bin/list_apps;  chmod +x
    6. Unless --no-reload: run 'aerospace reload-config'
    7. Print tips about get_appid and list_apps commands

  Use coloured output helpers: info/success/warn/error with CYAN/GREEN/YELLOW/RED ANSI codes.
  Mark the file executable with: chmod +x install.sh

═══════════════════════════════════════════════════════════
TASK 3 — scripts/dock-layout-sync.sh
═══════════════════════════════════════════════════════════

Create or update scripts/dock-layout-sync.sh:

  #!/usr/bin/env zsh
  set -u

  Infinite loop (sleep 1 between iterations) that:
    - Reads 'defaults read com.apple.dock autohide' and 'orientation'
    - When either value changes from the last iteration:
        aerospace flatten-workspace-tree >/dev/null 2>&1
        aerospace balance-sizes >/dev/null 2>&1
    - This keeps tiling geometry correct when the Dock autohide/orientation changes.

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 4 — scripts/get_appid.sh
═══════════════════════════════════════════════════════════

Create or update scripts/get_appid.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Flags: --now (skip countdown), --copy (copy result to pbcopy), --help

  Behaviour:
    - Default: print "Switch to the target window. Capturing in: 3… 2… 1…" (1 s each)
    - --now: skip countdown
    - Use osascript to get bundle identifier of the frontmost process via System Events
    - Print:   Bundle ID: <id>
               AeroSpace snippet (ready-to-paste [[on-window-detected]] block)
    - --copy: pipe bundle ID to pbcopy and confirm

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 5 — scripts/list_apps.sh
═══════════════════════════════════════════════════════════

Create or update scripts/list_apps.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Flags: --grep <pattern> (filter by name or bundle ID, case-insensitive),
         --sort name|id  (default: sort by app name),
         --help

  Behaviour:
    - Use osascript/system_profiler or 'lsappinfo list' to enumerate running GUI apps
    - Print a two-column table: APP NAME | BUNDLE ID
    - Left-align columns with printf for readability
    - Apply --grep filter if provided (grep -i on both columns)

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 6 — scripts/toggle_macgod.sh
═══════════════════════════════════════════════════════════

Create or update scripts/toggle_macgod.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Flags: --on, --off, --status, (no arg = auto-flip based on current state)

  Paths:
    TOML = ~/.aerospace.toml (or $AEROSPACE_TOML env override)
    YABAIRC = ~/.yabairc    (or $YABAIRC env override)
    PHOENIXJS = ~/.phoenix.js (or $PHOENIXJS env override)
    Reads repo configs from configs/yabairc and configs/phoenix.js (relative to script)

  --on (activate_macgod):
    1. sed -i.bak patch TOML:
       - enable-normalization-flatten-containers = true  → false
       - enable-normalization-opposite-orientation-for-nested-containers = true → false
       - default-root-container-layout = 'tiles' → 'float'
    2. If configs/yabairc exists: backup existing ~/.yabairc if different, then cp + chmod +x
    3. If configs/phoenix.js exists: backup existing ~/.phoenix.js if different, then cp
    4. If yabai installed: 'brew services restart yabai' (or 'yabai --restart-service')
    5. If phoenix installed: 'open -a Phoenix'
    6. aerospace reload-config if available
    7. Print summary of active mode

  --off (deactivate_macgod):
    1. sed -i.bak patch TOML back to tiling values
    2. 'brew services stop yabai' if installed
    3. Kill Phoenix if running (osascript tell quit, or killall Phoenix)
    4. aerospace reload-config if available

  --status:
    Print current mode detected from TOML, plus yabai/Phoenix install status

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 7 — scripts/check_deps.sh
═══════════════════════════════════════════════════════════

Create or update scripts/check_deps.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Flag: --quiet (suppress output; exit 0 = healthy, exit 1 = issues)

  Sections:
    1. Core — AeroSpace:
       - aerospace command present
       - ~/.aerospace.toml present
       - ~/.config/aerospace/dock-layout-sync.sh present and executable

    2. MacGOD Ghost Mode:
       - Detect mode from TOML (float vs tiles)
       - If MacGOD active: check yabai installed, Phoenix installed,
         ~/.yabairc present, ~/.phoenix.js present
       - If MacGOD off: note if yabai/Phoenix installed but inactive

    3. DX Scripts:
       - scripts/get_appid.sh, list_apps.sh, toggle_macgod.sh, check_deps.sh
         all present and executable

    4. macOS advisory:
       - Print macOS version; warn on macOS 15+ about yabai --install-sa after updates

    5. Summary line: "N passed / N warnings / N failed"
       Exit 1 if any FAIL items.

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 8 — scripts/switch_profile.sh
═══════════════════════════════════════════════════════════

Create or update scripts/switch_profile.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Args: [PROFILE | path/to/file.toml]  (no arg = interactive menu)

  Locate profiles/ relative to the script file (../profiles/).
  Backup current ~/.aerospace.toml to ~/.aerospace_profiles_backup/ with a timestamp.
  Copy the selected profile to ~/.aerospace.toml.
  Run 'aerospace reload-config' if available.

  Interactive menu: list .toml files in profiles/, prompt for a number selection.
  Accept: bare name (e.g. "macgod"), full path, or --help.

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 9 — scripts/workspace_status.sh
═══════════════════════════════════════════════════════════

Create or update scripts/workspace_status.sh:

  #!/usr/bin/env bash
  set -euo pipefail

  Flags: -w/--workspace WS, -s/--short, -j/--json, -h/--help

  Requires 'aerospace' CLI.

  --json: pass through 'aerospace list-windows --all --json' (or --workspace WS)
  --short: compact table — one line per workspace: "WorkspaceName   N window(s)"
  default: full card view with box-drawing characters, one card per workspace,
           listing window titles from 'aerospace list-windows --workspace WS',
           marking the focused workspace

  Mark executable.

═══════════════════════════════════════════════════════════
TASK 10 — configs/yabairc
═══════════════════════════════════════════════════════════

Create or update configs/yabairc:

  A minimal yabai configuration for MacGOD Ghost Mode:

  yabai -m config layout float          # AeroSpace owns layout; yabai handles chrome only
  yabai -m config window_border off
  yabai -m config window_shadow float   # shadows only on floating windows
  yabai -m config window_opacity off

  # Remove title bars from all windows (requires SIP partially disabled + scripting addition)
  yabai -m config window_titlebar_background_color 0x00000000
  yabai -m signal --add event=window_created action="yabai -m window \$YABAI_WINDOW_ID --set-attr subrole AXStandardWindow; yabai -m window \$YABAI_WINDOW_ID --toggle zoom-fullscreen; yabai -m window \$YABAI_WINDOW_ID --toggle zoom-fullscreen" label=hide_titlebar

  # Mouse settings
  yabai -m config focus_follows_mouse autoraise
  yabai -m config mouse_follows_focus off

  # Floating rules for system windows
  yabai -m rule --add app="^System Preferences$" manage=off
  yabai -m rule --add app="^Activity Monitor$" manage=off
  yabai -m rule --add app="^Calculator$" manage=off
  yabai -m rule --add app="^Archive Utility$" manage=off

═══════════════════════════════════════════════════════════
TASK 11 — configs/phoenix.js
═══════════════════════════════════════════════════════════

Create or update configs/phoenix.js (the primary Phoenix config for MacGOD):

  Phoenix.set({ daemon: true, openAtLogin: true });

  const MARGIN = 0;
  const MASH     = ['cmd', 'ctrl'];
  const MASH_ALT = ['cmd', 'ctrl', 'alt'];

  Helper screenFrame(win) → returns flippedVisibleFrame shrunk by MARGIN on all sides.
  Helper snap(rect) → gets focused window and calls setTopLeft + setSize.

  Bindings using MASH (⌘⌃):
    return  → maximise (full screenFrame)
    left    → left half
    right   → right half
    up      → top half
    down    → bottom half
    7       → top-left quarter
    8       → top-right quarter
    1       → bottom-left quarter
    2       → bottom-right quarter
    c       → centre (keeps current size)
    m       → throw to next screen (preserves relative position)
    r       → Phoenix.reload()

  Bindings using MASH_ALT (⌘⌃⌥):
    left    → left third
    right   → right third
    up      → centre third (wide column)
    down    → two-thirds left

  End with: Phoenix.log('MacGOD Ghost Mode — phoenix.js loaded.');

═══════════════════════════════════════════════════════════
TASK 12 — profiles/macgod.toml
═══════════════════════════════════════════════════════════

Create or update profiles/macgod.toml — AeroSpace config for MacGOD Ghost Mode:

  Same structure as .aerospace.toml BUT:
    enable-normalization-flatten-containers = false
    enable-normalization-opposite-orientation-for-nested-containers = false
    default-root-container-layout = 'float'   # yabai + Phoenix own window geometry

  All 9 workspaces: AI, Code, CLI, Browser, Media, Social, 7, 8, 9
  Full [[on-window-detected]] routing (same app list as .aerospace.toml).
  Same [mode.main.binding] keybindings.

═══════════════════════════════════════════════════════════
TASK 13 — profiles/laptop.toml
═══════════════════════════════════════════════════════════

Create or update profiles/laptop.toml — AeroSpace config for single-display laptop:

  Same structure as .aerospace.toml BUT:
    default-root-container-layout = 'accordion'
    persistent-workspaces = ['AI', 'Code', 'CLI', 'Browser', 'Media', 'Social', 'Scratch']
    (7 workspaces — drop 8 and 9; rename 7 to Scratch)
  Reduced app routing (keep the most common apps per workspace, trim rarely-used ones).
  Bindings: alt-7 = 'workspace Scratch', alt-shift-7 = ['move-node-to-workspace Scratch', 'workspace Scratch']

═══════════════════════════════════════════════════════════
TASK 14 — README.md
═══════════════════════════════════════════════════════════

Create or update README.md to document the COMPLETE feature set:

  Sections (in order):
    1. Header — project title, tagline, "MacGOD Ready" callout
    2. Architectural Core Principles (5 numbered points)
    3. Workspace Taxonomy — table with Key | Workspace | Domain | Auto-Routed Apps
    4. Ergonomic Matrix — two tables: Window & Focus Control, Workspace Navigation
    5. MacGOD Deployment (Ghost Mode):
       - One-Command Toggle section with toggle_macgod.sh usage examples
       - What the Toggle Does table
       - Phoenix Keyboard Bindings table (⌘⌃ bindings)
       - Prerequisites (SIP, brew install yabai + phoenix, scripting addition note)
    6. Multi-Monitor Workflow ("The Teleport") — alt+M and alt+shift+N, Mac Mouse Fix tip
    7. Config Profiles — profiles/ table, switch_profile.sh usage examples
    8. MacGOD Ghost Mode — Full Config Files — configs/ table and deploy snippet
    9. Setup & Installation:
       - Quick Install (./install.sh with flags table)
       - Manual Install (prerequisites, clone, deploy TOML, deploy dock-sync, initialize)
    10. Customization Protocol — how to add apps, find bundle IDs, remap keys
        DX Toolkit Reference table (get_appid.sh, switch_profile.sh, workspace_status.sh)
    11. Health Check — check_deps.sh usage
    12. Further Suggestions — Raycast recommendation

═══════════════════════════════════════════════════════════
VERIFICATION STEPS
═══════════════════════════════════════════════════════════

After completing all tasks above, verify:

  1. All shell scripts have '#!/usr/bin/env bash' or '#!/usr/bin/env zsh' shebang
  2. All bash scripts include 'set -euo pipefail'
  3. All scripts have executable permissions (chmod +x)
  4. .aerospace.toml has all 9 named workspaces
  5. .aerospace.toml routes all apps listed in TASK 1
  6. profiles/macgod.toml uses float layout
  7. profiles/laptop.toml uses accordion layout with 7 workspaces
  8. configs/phoenix.js uses MASH=['cmd','ctrl'] and MASH_ALT=['cmd','ctrl','alt']
  9. toggle_macgod.sh --status would correctly detect mode from TOML layout value
  10. README.md covers all features

Print a final ✅ checklist for all 14 tasks once complete.
```

---

## What this master prompt builds

| File | Description |
|------|-------------|
| `.aerospace.toml` | Core AeroSpace config — 9 named workspaces, full app routing, all keybindings |
| `install.sh` | One-command installer with colour output and flags |
| `scripts/dock-layout-sync.sh` | Zsh daemon for Dock-change-aware tiling rebalance |
| `scripts/get_appid.sh` | Bundle ID capture with countdown + clipboard |
| `scripts/list_apps.sh` | Running GUI apps table with bundle IDs |
| `scripts/toggle_macgod.sh` | MacGOD Ghost Mode toggle (patches TOML, deploys yabai/Phoenix) |
| `scripts/check_deps.sh` | Full dependency health check |
| `scripts/switch_profile.sh` | Config profile switcher with interactive menu |
| `scripts/workspace_status.sh` | Workspace window snapshot (full / short / JSON) |
| `configs/yabairc` | Minimal yabai config — title-bar removal, shadows off |
| `configs/phoenix.js` | Phoenix JS grid-snap config using ⌘⌃ modifier |
| `profiles/macgod.toml` | AeroSpace profile for MacGOD Ghost Mode |
| `profiles/laptop.toml` | AeroSpace profile for single-display laptop |
| `README.md` | Complete documentation for the full stack |

---

## Tips for using this with VSCode Copilot

- **Agent mode required**: Click the ✨ icon in Copilot Chat and switch to **Agent** (not Ask or Edit).
- **Scope**: The agent has full read/write access to the workspace files.
- **If rate-limited**: The agent will automatically retry.  If it stops early, re-paste the prompt
  and add: *"Continue from where you left off.  Tasks already completed: [list them]."*
- **Incremental approach**: You can also paste individual TASK blocks one at a time to step
  through the implementation task by task.
- **Verification**: After the agent finishes, run `./scripts/check_deps.sh --quiet` (on macOS)
  or manually review the generated files against the README.
