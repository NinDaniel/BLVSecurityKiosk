#!/bin/bash
# Auto-refresh Chromium every 10 minutes - ONLY if screen is on

while true; do
    sleep 600  # 10 minutes (600 seconds)
    
    # Only refresh if Chromium is actually running (screen is on)
    if pgrep -x chromium > /dev/null; then
        # Send F5 (refresh) to the active window
        export DISPLAY=:0
        xdotool search --class chromium windowactivate --sync key --clearmodifiers F5
        logger "Chromium auto-refresh executed at $(date)"
    else
        logger "Chromium not running (power-saving mode) - skipping refresh"
    fi
done
