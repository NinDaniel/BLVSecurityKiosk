#!/bin/bash
# Wake from power saving - turn on screen and restart video streaming

# Load configuration
source ~/kiosk-config.sh

# Turn on the display
wlopm --on \*

# Wait for display to initialize
sleep 1

# Restart Chromium with the configured flags using eval for proper expansion
eval "chromium $CHROMIUM_FLAGS $UNIFI_PROTECT_URL &"

logger "Screen wake - Display on, Chromium restarted"
