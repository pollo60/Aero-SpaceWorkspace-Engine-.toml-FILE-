// =============================================================================
// ~/.phoenix.js — MacGOD Ghost Mode (Phoenix layer)
// =============================================================================
// Phoenix is a lightweight macOS window manager scriptable in JavaScript.
// In the MacGOD stack it sits above yabai and AeroSpace to add:
//   • Per-window keyboard shortcuts for sizing and positioning
//   • Named window "slots" (thirds, halves, full-screen) on any monitor
//   • A workspace-aware window title overlay (optional)
//
// Install:  brew install --cask phoenix
// Docs:     https://github.com/kasper/phoenix
//
// AeroSpace owns workspace switching (alt+1…9).
// yabai removes title bars.
// Phoenix manages fine-grained sizing and positioning of individual windows.
// =============================================================================

Phoenix.set({
  daemon: true,     // run without an icon in the menu bar
  openAtLogin: true // start automatically at login
});

// =============================================================================
// CONSTANTS
// =============================================================================

const MARGIN = 0;         // pixel gap between window and screen edge (0 = zero-gap)

// Modifier combos — chosen to avoid collisions with AeroSpace (which uses alt / alt+ctrl / alt+shift).
const MASH     = ['cmd', 'ctrl'];          // ⌘⌃ for position snapping
const MASH_ALT = ['cmd', 'ctrl', 'alt'];   // ⌘⌃⌥ for thirds / custom sizes

// =============================================================================
// HELPERS
// =============================================================================

/**
 * Returns the usable frame of the screen the given window is on,
 * shrunk by MARGIN on all four sides.
 */
function screenFrame(win) {
  const f = win.screen().flippedVisibleFrame();
  return {
    x: f.x + MARGIN,
    y: f.y + MARGIN,
    width:  f.width  - MARGIN * 2,
    height: f.height - MARGIN * 2
  };
}

/**
 * Move + resize the focused window to fill the given rectangle.
 * @param {Object} rect  { x, y, width, height }
 */
function snap(rect) {
  const win = Window.focused();
  if (!win) return;
  win.setTopLeft({ x: rect.x, y: rect.y });
  win.setSize({ width: rect.width, height: rect.height });
}

// =============================================================================
// FULL-SCREEN
// =============================================================================

// ⌘⌃ + Return — maximise focused window to fill screen
Key.on('return', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  snap(screenFrame(win));
});

// =============================================================================
// HALVES  (⌘⌃ + Arrow)
// =============================================================================

Key.on('left', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  snap({ x: f.x, y: f.y, width: Math.floor(f.width / 2), height: f.height });
});

Key.on('right', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const half = Math.floor(f.width / 2);
  snap({ x: f.x + half, y: f.y, width: f.width - half, height: f.height });
});

Key.on('up', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  snap({ x: f.x, y: f.y, width: f.width, height: Math.floor(f.height / 2) });
});

Key.on('down', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const half = Math.floor(f.height / 2);
  snap({ x: f.x, y: f.y + half, width: f.width, height: f.height - half });
});

// =============================================================================
// THIRDS  (⌘⌃⌥ + Arrow)
// =============================================================================

Key.on('left', MASH_ALT, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  snap({ x: f.x, y: f.y, width: Math.floor(f.width / 3), height: f.height });
});

Key.on('right', MASH_ALT, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const third = Math.floor(f.width / 3);
  snap({ x: f.x + third * 2, y: f.y, width: f.width - third * 2, height: f.height });
});

// Centre-third (wide column) — useful for a focused coding window flanked by two context windows.
Key.on('up', MASH_ALT, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const third = Math.floor(f.width / 3);
  snap({ x: f.x + third, y: f.y, width: third, height: f.height });
});

// Two-thirds (left) — terminal on the right, code editor taking most of the screen.
Key.on('down', MASH_ALT, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const third = Math.floor(f.width / 3);
  snap({ x: f.x, y: f.y, width: third * 2, height: f.height });
});

// =============================================================================
// CORNER SNAPPING  (⌘⌃ + numpad / F-key equivalents via number row)
// =============================================================================
// 7 = top-left    8 = top-right
// 1 = bottom-left 2 = bottom-right

Key.on('7', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  snap({ x: f.x, y: f.y, width: Math.floor(f.width / 2), height: Math.floor(f.height / 2) });
});

Key.on('8', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const half = Math.floor(f.width / 2);
  snap({ x: f.x + half, y: f.y, width: f.width - half, height: Math.floor(f.height / 2) });
});

Key.on('1', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const halfH = Math.floor(f.height / 2);
  snap({ x: f.x, y: f.y + halfH, width: Math.floor(f.width / 2), height: f.height - halfH });
});

Key.on('2', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f = screenFrame(win);
  const halfW = Math.floor(f.width / 2);
  const halfH = Math.floor(f.height / 2);
  snap({ x: f.x + halfW, y: f.y + halfH, width: f.width - halfW, height: f.height - halfH });
});

// =============================================================================
// CENTRE  (⌘⌃ + C)
// =============================================================================

Key.on('c', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const f  = screenFrame(win);
  const wf = win.frame();
  // Keep the current window size but move it to the centre of the screen.
  snap({
    x: f.x + Math.floor((f.width  - wf.width)  / 2),
    y: f.y + Math.floor((f.height - wf.height) / 2),
    width:  wf.width,
    height: wf.height
  });
});

// =============================================================================
// THROW TO NEXT SCREEN  (⌘⌃ + M)
// This mirrors the AeroSpace alt-shift-n binding but at the Phoenix level,
// useful when AeroSpace is in MacGOD float mode and alt-shift-n may not apply.
// =============================================================================

Key.on('m', MASH, () => {
  const win = Window.focused();
  if (!win) return;
  const screens = Screen.all();
  if (screens.length < 2) return;
  const currentScreen = win.screen();
  const idx = screens.findIndex(s => s.identifier() === currentScreen.identifier());
  const nextScreen = screens[(idx + 1) % screens.length];
  const nf = nextScreen.flippedVisibleFrame();
  // Move window to the same relative position on the next screen.
  const cf = currentScreen.flippedVisibleFrame();
  const wf = win.frame();
  const relX = (wf.x - cf.x) / cf.width;
  const relY = (wf.y - cf.y) / cf.height;
  win.setTopLeft({
    x: nf.x + relX * nf.width,
    y: nf.y + relY * nf.height
  });
});

// =============================================================================
// RELOAD CONFIG  (⌘⌃ + R)
// =============================================================================

Key.on('r', MASH, () => {
  Phoenix.reload();
});

Phoenix.log('MacGOD Ghost Mode — phoenix.js loaded.');
