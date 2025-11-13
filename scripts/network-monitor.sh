#!/bin/bash
# Network recovery monitor - restarts Chromium when network recovers

# Load configuration
source ~/kiosk-config.sh

CHECK_INTERVAL=30
NETWORK_WAS_UP=true

logger "Network monitor started - monitoring $UNIFI_PROTECT_IP"

while true; do
    # Check if we can reach the Unifi server
    if ping -c 1 -W 2 $UNIFI_PROTECT_IP > /dev/null 2>&1; then
        # Network is up
        if [ "$NETWORK_WAS_UP" = false ]; then
            # Network just came back online
            logger "Network recovered - checking if Chromium needs restart"

            # Only restart Chromium if it's actually running (not in power-saving mode)
            if pgrep -x chromium > /dev/null; then
                logger "Network recovered - restarting Chromium"
                killall chromium
                sleep 2
                chromium $CHROMIUM_FLAGS $UNIFI_PROTECT_URL &
            else
                logger "Network recovered but Chromium not running (power-saving mode?)"
            fi
            NETWORK_WAS_UP=true
        fi
    else
        # Network is down
        if [ "$NETWORK_WAS_UP" = true ]; then
            logger "Network connection lost to $UNIFI_PROTECT_IP"
            NETWORK_WAS_UP=false
        fi
    fi

    sleep $CHECK_INTERVAL
done
