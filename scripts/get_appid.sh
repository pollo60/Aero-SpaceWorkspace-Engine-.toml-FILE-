#!/bin/bash
# Print the bundle identifier of the currently focused macOS app.
echo "Click the window you want to identify..."
osascript -e 'tell application "System Events" to get bundle identifier of process (name of first process whose frontmost is true)'
