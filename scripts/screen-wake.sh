#!/bin/bash
# Wake from power saving - turn on screen and restart video streaming

# Set Wayland display for wlopm to work
export WAYLAND_DISPLAY=wayland-0

# Turn on the display
wlopm --on \*

# Wait for display to initialize
sleep 1

# Restart Chromium with the configured flags
DISPLAY=:0 chromium --kiosk --start-fullscreen --password-store=basic --noerrdialogs --disable-infobar --disable-features=TranslateUI --disable-sync --disable-default-apps --no-first-run --disable-session-crashed-bubble --hide-crash-restore-bubble --disk-cache-size=104857600 --media-cache-size=104857600 --disable-background-timer-throttling --js-flags=--max-old-space-size=2048 https://192.168.3.1/protect/dashboard/all &

logger "Screen wake - Display on, Chromium restarted"
