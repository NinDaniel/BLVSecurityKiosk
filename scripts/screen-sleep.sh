#!/bin/bash
# Power saving mode - stop video streaming and turn off screen

# Set Wayland display for wlopm to work
export WAYLAND_DISPLAY=wayland-0

# Kill Chromium to stop video streaming
killall chromium

# Wait a moment for clean shutdown
sleep 1

# Turn off the display
wlopm --off \*

logger "Power saving mode activated - Chromium stopped, screen off"
