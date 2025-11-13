# Church Security Kiosk Configuration

Complete setup and configuration for a Raspberry Pi 5 based security camera monitoring kiosk running Unifi Protect.

## Overview

This repository contains all configuration files, scripts, and documentation for a hardened Raspberry Pi kiosk system designed for 24/7 security camera monitoring at a church.

**Hardware:** Raspberry Pi 5 (16GB RAM)
**OS:** Debian GNU/Linux 13 (trixie)
**Display Software:** Chromium in kiosk mode
**Camera System:** Unifi Protect

## Key Features

- **Crash Prevention**: Optimized Chromium configuration prevents memory leaks and crashes
- **Power Saving**: Automatic screen timeout after 15 minutes with video streaming suspension (~75% power reduction)
- **Network Recovery**: Automatic Chromium restart when network connection recovers
- **Daily Maintenance**: Automatic reboot at 3:00 AM for long-term stability
- **Manual Controls**: Desktop shortcuts for immediate sleep/wake control
- **Optional Safety Net**: 10-minute auto-refresh script (disabled by default)

## How It Works

### 1. Browser Stability
Chromium runs with optimized memory management, larger caches, and unnecessary features disabled to maintain stable 24/7 operation without crashes or memory leaks.

### 2. Intelligent Power Saving
The system automatically turns off the display and stops video streaming after 15 minutes of inactivity, reducing power consumption by ~75% while maintaining instant wake capability.

### 3. Network Recovery
A monitoring script continuously checks network connectivity to the Unifi Protect server. When the connection is restored after an interruption, Chromium automatically restarts to resume video streaming.

### 4. Self-Healing Maintenance
The kiosk performs automatic daily reboots at 3:00 AM to clear any accumulated state issues, ensuring reliable long-term operation without manual intervention.

## Repository Structure

```
church-kiosk-config/
├── README.md                    # This file
├── SETUP.md                     # Detailed setup documentation
├── scripts/                     # All bash scripts
│   ├── screen-sleep.sh         # Power-saving mode
│   ├── screen-wake.sh          # Wake from power-saving
│   ├── network-monitor.sh      # Network recovery monitor
│   └── chromium-refresh.sh     # Optional auto-refresh
├── autostart-configs/           # Desktop autostart files
│   ├── unifi-protect.desktop
│   ├── screen-timeout.desktop
│   ├── network-monitor.desktop
│   └── chromium-refresh.desktop.disabled
└── desktop-shortcuts/           # Manual control scripts
    ├── Enable-Auto-Refresh.sh
    ├── Screen-Off.sh
    └── Screen-On.sh
```

## Quick Start

### Installation
1. Clone this repository to your Raspberry Pi
2. Copy scripts to home directory: `cp scripts/* ~/`
3. Make scripts executable: `chmod +x ~/*.sh`
4. Copy autostart configs: `cp autostart-configs/* ~/.config/autostart/`
5. Copy desktop shortcuts: `cp desktop-shortcuts/* ~/Desktop/`
6. Set up cron job: `echo "0 3 * * * root /usr/sbin/reboot" | sudo tee /etc/cron.d/daily-reboot`
7. Reboot system

### Basic Usage

**Normal Operation:**
- System auto-starts and manages everything
- Screen turns off after 15 min idle
- Mouse/keyboard wakes screen automatically

**Manual Control:**
- Double-click "Turn Screen Off" to sleep immediately
- Double-click "Turn Screen On" to wake
- Double-click "Enable Auto-Refresh" if crashes return

## Configuration

### Chromium Flags
See `autostart-configs/unifi-protect.desktop` for complete Chromium launch configuration including:
- Memory limits and cache sizes
- Disabled unnecessary features
- Crash recovery suppression

### Power Saving
- **Timeout:** 15 minutes (configurable in `screen-timeout.desktop`)
- **Sleep action:** Stops Chromium + turns off display
- **Wake trigger:** Any mouse/keyboard activity

### Network Monitoring
- **Check interval:** 30 seconds
- **Target:** 192.168.3.1 (Unifi Protect server)
- **Recovery action:** Restart Chromium when connection restored

## System Requirements

- Raspberry Pi 5 (recommended) or Pi 4 with 4GB+ RAM
- Debian-based OS with Wayland support
- Unifi Protect system on local network
- Internet connection for initial setup

## Troubleshooting

### Display doesn't turn off
```bash
# Check if swayidle is running
ps aux | grep swayidle

# Restart if needed
nohup swayidle -w timeout 900 '/home/security/screen-sleep.sh' resume '/home/security/screen-wake.sh' &
```

### Chromium not starting after wake
```bash
# Check process
ps aux | grep chromium

# Manually restart
~/screen-wake.sh
```

### Network monitor not working
```bash
# Check if running
ps aux | grep network-monitor

# View logs
journalctl | grep "Network monitor"
```

See `SETUP.md` for complete troubleshooting guide.

## Technical Details

- **Window Manager:** labwc (Wayland)
- **Display Control:** wlopm (Wayland power management)
- **Idle Detection:** swayidle
- **Browser:** Chromium 141.0.7390.65+

## Security Notes

- Default SSH credentials are included in SETUP.md - **change these in production**
- Consider implementing SSH key-based authentication
- Firewall rules recommended for production deployment

## Maintenance

- **Daily:** Automatic reboot at 3:00 AM
- **Weekly:** Check system logs for any recurring errors
- **Monthly:** Verify SD card health, check for OS updates
- **Quarterly:** Review and update this configuration as needed

## License

This configuration is provided as-is for use in church security systems. Feel free to adapt for your needs.

## Support

For issues or questions, refer to `SETUP.md` for detailed documentation including:
- Complete feature list
- Configuration details
- Troubleshooting steps
- SSH access information
- Change log

## Credits

Configuration developed and documented November 12, 2025 with assistance from Claude (Anthropic).

---

**Last Updated:** November 12, 2025
**Version:** 1.0
