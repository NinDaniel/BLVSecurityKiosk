#!/bin/bash
# Wrapper script to start Chromium kiosk with configuration

# Load configuration
source ~/kiosk-config.sh

# Start Chromium with configured flags and URL
chromium $CHROMIUM_FLAGS $UNIFI_PROTECT_URL
