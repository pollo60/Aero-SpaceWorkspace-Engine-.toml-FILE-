# **🚀 AeroSpace Workspace Engine (.toml FILE)**

*A high-performance, hybrid window management configuration for macOS.*

This repository contains the production-ready [AeroSpace](https://github.com/nikitabobko/AeroSpace) configuration used for my personal and work related development.

Designed with Strategic Software Engineering / Architecture in mind, this configuration bridges the gap between strict Tiling Window Management (TWM) and macOS's native floating behavior, resulting in a zero-latency, context-switching powerhouse.

> **MacGOD Ready** — This config ships pre-wired for MacGOD (yabai + Phoenix integration). A single toggle inside the file switches it into full Ghost Mode where yabai removes title bars and Phoenix owns window logic. See the *MacGOD Deployment* section below.

## **🧠 Architectural Core Principles**

1. **Named Workspaces:** Workspaces carry semantic identities (`AI`, `Code`, `CLI`, `Browser`, `Media`, `Social`) instead of opaque numbers, so `alt+1` always means *AI context* regardless of how many spaces macOS has shuffled around.
2. **Zero Gaps, Maximum Data:** All inner and outer gaps are set to 0\. In data-heavy financial engineering, every pixel matters.
3. **Strict App-to-Workspace Routing:** Applications are automatically sorted into dedicated, persistent workspaces upon launch to eliminate cognitive overload.
4. **Window Follows You:** `Opt + Shift + Number` moves the focused window *and* teleports you to the destination workspace — because you use this combo a lot.
5. **Hardware Synergy:** Deeply integrated with [Mac Mouse Fix](https://macmousefix.com/) for fluid multi-monitor interactions.

## **🏗 Workspace Taxonomy**

The workspace routing is hardcoded via regex and Bundle IDs to maintain absolute order. Additionally, the user can easily edit the favorite apps for each workspace:

| Key | Workspace | Domain | Auto-Routed Applications |
| :---- | :---- | :---- | :---- |
| **alt+1** | **AI** | 🤖 AI / Agentic Logic | Gemini, ChatGPT, Claude, Copilot (PWAs or native) |
| **alt+2** | **Code** | 💻 IDE / Engineering | Visual Studio Code |
| **alt+3** | **CLI** | 📟 CLI / Server | iTerm2, Terminal |
| **alt+4** | **Browser** | 🌍 Research / Web | Safari, Chrome, Firefox, Arc |
| **alt+5** | **Media** | 🎵 Music / Media | Spotify, Apple Music |
| **alt+6** | **Social** | 💬 Communication | Slack, Apple Mail, Messages, Discord |
| **alt+7–9** | **7 / 8 / 9** | 🗒 Scratch / Free | Unassigned — use for ad-hoc contexts |

## **⌨️ The Ergonomic Matrix**

This configuration uses a carefully mapped modifier logic. The primary modifier is the Option (⌥) key, designed for minimal finger travel.

### **Window & Focus Control**

| Shortcut | Action | Logic |
| :---- | :---- | :---- |
| Opt \+ Arrows | **Resize Window** (+/- 80px) | Rapid floating adjustments. |
| Opt \+ Ctrl \+ Arrows | **Change Focus** | Directional focus switching. |
| Opt \+ Shift \+ Arrows | **Move Window** | Push window in a direction (tiling grid). |
| Opt \+ F | **Toggle Tiling/Floating** | Switch between strict grid and free-form. |
| ⚠️ **Architect's Note** | **Strictly Arrow Keys** | I exclusively use Opt \+ Arrow Keys. No Vim-bindings (H/J/K/L) are used to minimize cognitive load. |

### **Workspace Navigation**

| Shortcut | Action |
| :---- | :---- |
| Opt \+ 1–9 | Switch to named workspace (AI, Code, CLI …) |
| Opt \+ Shift \+ 1–9 | Move focused window **and follow it** to the named workspace |

## **🚀 MacGOD Deployment (Ghost Mode)**

This config is pre-wired for [MacGOD](https://github.com/pollo60/Aero-SpaceWorkspace-Engine-.toml-FILE-) — a full God-Mode layer that adds:

* **yabai** (SIP off) to eliminate window title bars
* **Phoenix** (JavaScript) for per-window logic, naming, and scripted positioning

### Activating Ghost Mode (MacGOD users only)

Open `~/.aerospace.toml` and swap the normalization + layout block to:

```toml
enable-normalization-flatten-containers = false
enable-normalization-opposite-orientation-for-nested-containers = false
default-root-container-layout = 'float'   # yabai + Phoenix own the layout
```

Then install and start yabai with your `~/.yabairc`:

```bash
brew install koekeishiya/formulae/yabai
brew services start yabai
```

Minimal `~/.yabairc` for title-bar removal:

```bash
sudo yabai --load-sa
yabai -m config layout float
yabai -m config window_titlebar off
yabai -m config window_shadow off
```

> **⚠️ Note:** After every macOS update, run `sudo yabai --install-sa` if title bars reappear.

Without MacGOD, leave the tiling defaults in place — AeroSpace handles everything independently.

## **🖥️ Multi-Monitor Workflow: "The Teleport"**

Working across multiple displays (e.g., MacBook \+ Monitor) requires speed. This config uses two dedicated monitor actions:

* **Command:** Opt \+ M  
* **Action:** Focuses the next monitor (wrap-around).
* **Command:** Opt \+ Shift \+ N  
* **Action:** Moves the focused window to the next monitor (wrap-around).

### **💡 Pro-Tip: Hardware Integration (Mac Mouse Fix)**

To achieve zero-friction UI control, map this shortcut to your mouse:

1. Download and install [Mac Mouse Fix](https://macmousefix.com/).  
2. Navigate to the **Click** tab.  
3. Assign a side-button on your mouse to the keyboard shortcut ⌥⇧N (window move) or ⌥M (monitor focus).  
4. *Result:* You can now switch monitor context or throw windows between screens with a single thumb click.

**☕ Architect's Call to Action:** *Mac Mouse Fix is an incredible piece of independent engineering. If you find the "Buy a Coffee" button within their app, use it. Great tools build great software.*

## **🛠 Setup & Installation**

### **1\. Prerequisites**

Ensure you have AeroSpace installed via Homebrew:

brew install \--cask nikitabobko/tap/aerospace

### **2\. Clone the Repository**

Pull this architectural blueprint to your local machine:

git clone \[https://github.com/pollo60/Aero-SpaceWorkspace-Engine.git\](https://github.com/pollo60/Aero-SpaceWorkspace-Engine.git)  
cd Aero-SpaceWorkspace-Engine

If your working copy is already at `/Users/UserName/Desktop/seasn-aerospace-workspace`, continue from there.

### **3\. Deploy Engine Configuration**

Copy the core .aerospace.toml into your home directory.

**Architect's Note:** The system strictly requires this file to be located at /Users/username/.aerospace.toml (or \~/.aerospace.toml) to detect and load it correctly.

cp .aerospace.toml \~/.aerospace.toml

### **4\. Deploy Dependencies (Dock-Sync Script)**

This configuration triggers a custom script on startup to handle the macOS Dock layout cleanly. You must deploy this script to the correct hidden configuration folder:

mkdir \-p \~/.config/aerospace  
cp scripts/dock-layout-sync.sh \~/.config/aerospace/  
chmod \+x \~/.config/aerospace/dock-layout-sync.sh

### **5\. Initialize**

Reload the engine to apply the architecture:

aerospace reload-config

## **⚙️ Customization Protocol**

Despite its high-performance architecture, this setup is strictly **beginner-friendly** and highly adaptable. Configuring it for your personal workflow requires only a few simple text edits.

If you need to adapt the App-to-Workspace routing for your own tech stack, follow these rules to maintain structural integrity:

1. Open \~/.aerospace.toml.  
2. Locate the \[\[on-window-detected\]\] blocks.  
3. You can target apps either via **App ID** (Bundle Identifier) or **Regex** (Window/App Name).

**Finding App IDs (The Clean Way)** Do not guess Bundle IDs. Use the provided Developer Experience (DX) tool included in this repository:

./scripts/get\_appid.sh

Click the target window, and the script will output the exact ID to paste into your config.

**Example: Swapping VS Code for JetBrains IntelliJ**

\[\[on-window-detected\]\]  
\# Change the App ID here:  
if.app-id \= 'com.jetbrains.intellij'   
run \= \['move-node-to-workspace Code', 'layout tiling'\]

**Customizing the Teleport Move Key (Opt \+ Shift \+ N)**

If you rely on Opt \+ Shift \+ N for another application, you can remap the multi-monitor move command easily. Search for `alt-shift-n` in the config and replace the key:

\# Example: Remap multi-monitor move to Opt \+ S  
alt-s \= 'move-node-to-monitor \--wrap-around next'

## **🔭 Further Suggestions: The Raycast Extension**

To complete this high-performance ecosystem, I strongly recommend replacing macOS Spotlight with [Raycast](https://www.raycast.com/). I utilize Raycast as my primary, zero-latency command center to instantly launch applications, manage my clipboard history, and execute system commands without ever breaking keyboard focus.

*Maintained by pollo60 | Strategic Architect*
