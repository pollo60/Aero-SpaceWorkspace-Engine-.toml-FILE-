/**
 * phoenixrc.js — Starter Phoenix configuration for MacGOD Ghost Mode
 *
 * Phoenix is a lightweight macOS window manager scriptable in JavaScript.
 * In MacGOD mode Phoenix handles per-window positioning and naming while
 * AeroSpace owns workspace routing and keybindings.
 *
 * Install:
 *   brew install --cask phoenix
 *   cp configs/phoenixrc.js ~/.phoenix.js
 *   # Phoenix auto-loads ~/.phoenix.js on startup
 *
 * Docs: https://kasper.github.io/phoenix/
 */

// ── Preferences ────────────────────────────────────────────────────────────
Phoenix.set({
  daemon: false,   // Show Phoenix in the menu bar (not a background daemon).
  openAtLogin: true,
});

// ── Helpers ────────────────────────────────────────────────────────────────

/** Return the primary screen (built-in or first connected display). */
function primaryScreen() {
  return Screen.main();
}

/** Return the full usable frame of a screen (excludes Dock + menu bar). */
function usableFrame(screen) {
  return screen.flippedVisibleFrame();
}

/**
 * Move and resize a window to a grid cell.
 *
 * @param {Window} win   Target window.
 * @param {number} cols  Total grid columns.
 * @param {number} rows  Total grid rows.
 * @param {number} col   Zero-based column index.
 * @param {number} row   Zero-based row index.
 * @param {number} wCols Number of columns the window should span.
 * @param {number} wRows Number of rows the window should span.
 */
function snapToGrid(win, cols, rows, col, row, wCols = 1, wRows = 1) {
  const screen = win.screen() || primaryScreen();
  const frame  = usableFrame(screen);
  const cw     = frame.width  / cols;
  const ch     = frame.height / rows;
  win.setFrame({
    x: frame.x + col  * cw,
    y: frame.y + row  * ch,
    width:  cw * wCols,
    height: ch * wRows,
  });
}

/** Maximise a window to the usable area of its current screen. */
function maximise(win) {
  win.setFrame(usableFrame(win.screen() || primaryScreen()));
}

// ── Layout Shortcuts ────────────────────────────────────────────────────────

// Opt+Ctrl+M — maximise focused window.
Key.on('m', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) maximise(win);
});

// Opt+Ctrl+[ — snap focused window to left half.
Key.on('[', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 1, 0, 0);
});

// Opt+Ctrl+] — snap focused window to right half.
Key.on(']', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 1, 1, 0);
});

// Opt+Ctrl+, — snap focused window to top-left quadrant.
Key.on(',', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 2, 0, 0);
});

// Opt+Ctrl+. — snap focused window to top-right quadrant.
Key.on('.', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 2, 1, 0);
});

// Opt+Ctrl+/ — snap focused window to bottom-left quadrant.
Key.on('/', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 2, 0, 1);
});

// Opt+Ctrl+; — snap focused window to bottom-right quadrant.
Key.on(';', ['option', 'control'], () => {
  const win = Window.focused();
  if (win) snapToGrid(win, 2, 2, 1, 1);
});

// Opt+Ctrl+C — centre focused window (60 % wide, 80 % tall).
Key.on('c', ['option', 'control'], () => {
  const win = Window.focused();
  if (!win) return;
  const screen = win.screen() || primaryScreen();
  const f      = usableFrame(screen);
  const w      = f.width  * 0.6;
  const h      = f.height * 0.8;
  win.setFrame({
    x: f.x + (f.width  - w) / 2,
    y: f.y + (f.height - h) / 2,
    width:  w,
    height: h,
  });
});

// ── App-specific auto-sizing ────────────────────────────────────────────────
// When VS Code opens, maximise it immediately.
Event.on('appDidLaunch', (app) => {
  if (app.bundleIdentifier() === 'com.microsoft.VSCode') {
    const wins = app.windows();
    if (wins.length > 0) maximise(wins[0]);
  }
});

Phoenix.log('Phoenix MacGOD config loaded.');
