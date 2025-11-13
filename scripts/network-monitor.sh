#!/bin/bash
# Network recovery monitor - restarts Chromium when network recovers

UNIFI_HOST="192.168.3.1"
CHECK_INTERVAL=30
NETWORK_WAS_UP=true

logger "Network monitor started - monitoring $UNIFI_HOST"

while true; do
    # Check if we can reach the Unifi server
    if ping -c 1 -W 2 $UNIFI_HOST > /dev/null 2>&1; then
        # Network is up
        if [ "$NETWORK_WAS_UP" = false ]; then
            # Network just came back online
            logger "Network recovered - checking if Chromium needs restart"
            
            # Only restart Chromium if it's actually running (not in power-saving mode)
            if pgrep -x chromium > /dev/null; then
                logger "Network recovered - restarting Chromium"
                killall chromium
                sleep 2
                DISPLAY=:0 chromium --kiosk --start-fullscreen --password-store=basic --noerrdialogs --disable-infobar --disable-features=TranslateUI --disable-sync --disable-default-apps --no-first-run --disable-session-crashed-bubble --hide-crash-restore-bubble --disk-cache-size=104857600 --media-cache-size=104857600 --disable-background-timer-throttling --js-flags=--max-old-space-size=2048 https://192.168.3.1/protect/dashboard/all &
            else
                logger "Network recovered but Chromium not running (power-saving mode?)"
            fi
            NETWORK_WAS_UP=true
        fi
    else
        # Network is down
        if [ "$NETWORK_WAS_UP" = true ]; then
            logger "Network connection lost to $UNIFI_HOST"
            NETWORK_WAS_UP=false
        fi
    fi
    
    sleep $CHECK_INTERVAL
done
