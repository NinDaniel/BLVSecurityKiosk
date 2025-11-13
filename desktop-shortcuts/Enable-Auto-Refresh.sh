#!/bin/bash

# Re-enable auto-refresh for Chromium
mv ~/.config/autostart/chromium-refresh.desktop.disabled ~/.config/autostart/chromium-refresh.desktop 2>/dev/null

# Start the refresh script now
nohup ~/chromium-refresh.sh > ~/chromium-refresh.log 2>&1 &

# Show notification
notify-send "Auto-Refresh Enabled" "Chromium will auto-refresh every 10 minutes" -i dialog-information

echo "Auto-refresh has been enabled and started"
echo "Chromium will refresh every 10 minutes"
