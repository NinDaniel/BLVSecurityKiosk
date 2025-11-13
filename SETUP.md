# Complete Setup Documentation

**System:** Raspberry Pi 5 (16GB RAM)
**OS:** Debian GNU/Linux 13 (trixie)
**Purpose:** 24/7 Security Camera Monitoring (Unifi Protect)
**Setup Date:** November 12, 2025

> **Note:** This document uses placeholders for sensitive information:
> - `<PI_IP_ADDRESS>`, `<UNIFI_PROTECT_IP>`: Check your Ubiquiti UniFi console or router's DHCP table
> - `<SSH_USERNAME>`, `<SSH_PASSWORD>`: Stored in Bitwarden under "Church Security Kiosk"

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Problems Solved](#problems-solved)
3. [Features](#features)
4. [Installation](#installation)
5. [Configuration Details](#configuration-details)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)
8. [Technical Reference](#technical-reference)

---

## System Overview

### Hardware Specifications
- **Model:** Raspberry Pi 5
- **RAM:** 16GB
- **Storage:** SD Card
- **Display:** Samsung Monitor via HDMI-A-2

### Software Stack
- **OS:** Debian GNU/Linux 13 (trixie)
- **Kernel:** 6.12.47+rpt-rpi-2712
- **Display Manager:** lightdm
- **Window Manager:** labwc (Wayland compositor)
- **Browser:** Chromium 141.0.7390.65

### Network Configuration
- **Pi IP Address:** `<PI_IP_ADDRESS>` (check your router's DHCP table or Ubiquiti UniFi console)
- **Unifi Protect IP:** `<UNIFI_PROTECT_IP>` (check Ubiquiti UniFi console)
- **Monitored URL:** `https://<UNIFI_PROTECT_IP>/protect/dashboard/all`

### SSH Access
```
Host: <PI_IP_ADDRESS>
Username: <SSH_USERNAME>
Password: <SSH_PASSWORD>
```
**⚠️ Credentials stored in Bitwarden under "Church Security Kiosk"**

---

## Problems Solved

### 1. Browser Crashes (Primary Issue)

**Symptom:** Chromium would crash after approximately 30 minutes of operation, displaying "Please reload the page" message.

**Root Causes:**
- Memory leaks in long-running browser sessions
- Insufficient memory management with multiple video streams
- GPU resource exhaustion
- HEVC (H.265) video decode incompatibility on Pi 5

**Solutions Implemented:**
- Optimized Chromium launch flags for memory management
- Increased disk cache to 100MB and media cache to 100MB
- Limited JavaScript heap to 2GB (plenty of headroom with 16GB RAM)
- Disabled background processes and unnecessary features
- Added flags to prevent crash recovery prompts
- Recommended disabling HEVC enhanced encoding in Unifi

**Current Status:** Stable operation expected. Auto-refresh safety net available if needed.

### 2. Power Consumption

**Problem:** Pi was being physically unplugged/plugged to turn it off/on, risking SD card corruption and wasting power when not monitored.

**Solution:** Intelligent power-saving system
- Automatic screen timeout after 15 minutes of inactivity
- Complete shutdown of Chromium when screen is off (stops video streaming)
- Automatic resume when any activity detected
- Power consumption reduced from ~15-20W to ~3-5W (~75% savings)

### 3. Network Reliability

**Problem:** When network connection dropped and recovered, Chromium would remain in error state requiring manual intervention.

**Solution:** Network monitoring daemon
- Pings Unifi server every 30 seconds
- Detects when network connection is lost
- Automatically restarts Chromium when connection recovers
- Smart enough to not interfere with power-saving mode

### 4. Long-Term Stability

**Problem:** Browser sessions can accumulate issues over days/weeks of continuous operation.

**Solution:** Automatic daily maintenance
- Scheduled reboot every day at 3:00 AM
- Clears accumulated memory and cache issues
- Ensures fresh start each day

### 5. Manual Intervention

**Problem:** Crashes or issues required physical presence to resolve.

**Solution:** Multiple recovery mechanisms
- Self-healing network recovery
- Crash-proof configuration
- Desktop shortcuts for remote control via SSH
- Optional auto-refresh safety net

---

## Features

### Automatic Features (No User Interaction Required)

**✓ Crash Prevention**
- Memory-optimized Chromium configuration
- 100MB disk cache, 100MB media cache
- 2GB JavaScript heap limit
- Disabled: sync, translate, background networking
- Suppressed crash recovery dialogs

**✓ Power Management**
- 15-minute idle timeout
- Stops video streaming when screen off
- Auto-resume on mouse/keyboard activity
- Manual override available

**✓ Network Recovery**
- Monitors Unifi server connectivity
- Auto-restarts Chromium on recovery
- Logs all network events

**✓ Daily Maintenance**
- Automatic reboot at 3:00 AM
- Clears memory and ensures fresh start

**✓ Auto-Start**
- All services start on boot
- No manual intervention needed

### Manual Controls

**Desktop Shortcuts:**
- **Turn Screen Off** - Immediate power-saving mode
- **Turn Screen On** - Wake display and resume streaming
- **Enable Auto-Refresh** - Activate 10-minute refresh cycle (if needed)

---

## Installation

### Prerequisites
- Raspberry Pi 5 with Debian-based OS
- Wayland support (labwc, wlroots, or similar)
- Unifi Protect system accessible on local network
- SSH access to the Pi

### Installation Steps

1. **Clone Repository**
```bash
cd ~
git clone <repository-url> church-kiosk-config
cd church-kiosk-config
```

2. **Copy Scripts to Home Directory**
```bash
cp scripts/* ~/
chmod +x ~/*.sh
```

3. **Install Autostart Configurations**
```bash
mkdir -p ~/.config/autostart
cp autostart-configs/unifi-protect.desktop ~/.config/autostart/
cp autostart-configs/screen-timeout.desktop ~/.config/autostart/
cp autostart-configs/network-monitor.desktop ~/.config/autostart/
# Note: chromium-refresh.desktop.disabled is intentionally not copied (disabled by default)
```

4. **Copy Desktop Shortcuts**
```bash
cp desktop-shortcuts/* ~/Desktop/
chmod +x ~/Desktop/*.sh
```

5. **Set Up Daily Reboot**
```bash
echo "0 3 * * * root /usr/sbin/reboot" | sudo tee /etc/cron.d/daily-reboot
sudo chmod 644 /etc/cron.d/daily-reboot
```

6. **Install Required Tools** (if not already installed)
```bash
sudo apt-get update
sudo apt-get install -y xdotool chromium swayidle wlopm
```

7. **Reboot System**
```bash
sudo reboot
```

### Verification

After reboot, verify all services are running:
```bash
# Check Chromium
ps aux | grep chromium | wc -l
# Should show 10+ processes

# Check power-saving monitor
ps aux | grep swayidle

# Check network monitor
ps aux | grep network-monitor

# Check display status
WAYLAND_DISPLAY=wayland-0 wlopm
# Should show display as "on"
```

---

## Configuration Details

### Chromium Launch Configuration

**File:** `~/.config/autostart/unifi-protect.desktop`

**Key Flags:**
```
--kiosk                              # Full-screen kiosk mode
--start-fullscreen                   # Start maximized
--password-store=basic               # Don't use system keyring
--noerrdialogs                       # Suppress error dialogs
--disable-infobar                    # Hide info bars
--disable-features=TranslateUI       # No translation prompts
--disable-sync                       # No Chrome sync
--disable-default-apps               # Don't load default apps
--no-first-run                       # Skip first-run experience
--disable-session-crashed-bubble     # No "restore pages?" prompt
--hide-crash-restore-bubble          # Hide crash recovery UI
--disk-cache-size=104857600          # 100MB disk cache
--media-cache-size=104857600         # 100MB media cache
--disable-background-timer-throttling # Don't slow background tabs
--js-flags=--max-old-space-size=2048 # 2GB JavaScript heap limit
```

**URL:** `https://<UNIFI_PROTECT_IP>/protect/dashboard/all`

### Power-Saving Configuration

**File:** `~/.config/autostart/screen-timeout.desktop`

**Timeout:** 900 seconds (15 minutes)

**Sleep Action:** `~/screen-sleep.sh`
- Exports WAYLAND_DISPLAY environment variable
- Kills all Chromium processes
- Turns off display via `wlopm --off *`
- Logs event to system journal

**Wake Action:** `~/screen-wake.sh`
- Exports WAYLAND_DISPLAY environment variable
- Turns on display via `wlopm --on *`
- Restarts Chromium with full configuration
- Logs event to system journal

### Network Monitoring

**File:** `~/.config/autostart/network-monitor.desktop`

**Script:** `~/network-monitor.sh`

**Configuration:**
- **Target Host:** `<UNIFI_PROTECT_IP>` (Unifi Protect server)
- **Check Interval:** 30 seconds
- **Method:** Single ping with 2-second timeout

**Behavior:**
- Continuously monitors connectivity
- Logs when connection is lost
- When connection recovers AND Chromium is running: restarts Chromium
- Skips restart if Chromium not running (respects power-saving mode)

### Daily Reboot

**File:** `/etc/cron.d/daily-reboot`

**Schedule:** `0 3 * * *` (3:00 AM daily)

**Command:** `/usr/sbin/reboot`

---

## Usage Guide

### Normal Daily Operation

**Everything is automatic!**

1. **System Boot:** Chromium starts automatically showing Unifi Protect
2. **Idle Timeout:** After 15 minutes of no activity, screen turns off and streaming stops
3. **Activity Resume:** Any mouse movement or keyboard press wakes the screen
4. **Network Issues:** Automatically detected and recovered
5. **Daily Maintenance:** Automatic reboot at 3:00 AM

### Arriving at Church

**Option 1 (Recommended):** Just move the mouse - screen will wake automatically

**Option 2:** Double-click "Turn Screen On" desktop icon

### Leaving Church

**Option 1 (Recommended):** Just leave it - screen will auto-timeout in 15 minutes

**Option 2:** Double-click "Turn Screen Off" icon for immediate power-saving

### Remote Management (SSH)

**Connect:**
```bash
ssh <SSH_USERNAME>@<PI_IP_ADDRESS>
```
(Credentials available in Bitwarden under "Church Security Kiosk")

**Put to Sleep:**
```bash
~/screen-sleep.sh
```

**Wake Up:**
```bash
~/screen-wake.sh
```

**Check Status:**
```bash
# Chromium running?
ps aux | grep chromium | wc -l

# Display status
WAYLAND_DISPLAY=wayland-0 wlopm

# All monitors
ps aux | grep -E 'swayidle|network-monitor' | grep -v grep
```

### If Crashes Return

If after disabling HEVC in Unifi you still experience crashes:

1. Go to the Pi (physically or via VNC/remote desktop)
2. Double-click "Enable Auto-Refresh" icon on desktop
3. This adds a 10-minute refresh cycle as a safety net

The auto-refresh is power-saving aware and won't interfere with screen timeout.

---

## Troubleshooting

### Display Doesn't Turn Off After 15 Minutes

**Check swayidle is running:**
```bash
ps aux | grep swayidle | grep -v grep
```

**Expected output:**
```
security [PID] ... swayidle -w timeout 900 /home/security/screen-sleep.sh resume /home/security/screen-wake.sh
```

**If not running, start it:**
```bash
nohup swayidle -w timeout 900 '/home/security/screen-sleep.sh' resume '/home/security/screen-wake.sh' > /tmp/swayidle.log 2>&1 &
```

**Check script has correct environment variable:**
```bash
head -5 ~/screen-sleep.sh
# Should show: export WAYLAND_DISPLAY=wayland-0
```

### Chromium Still Crashing

**1. Verify HEVC is disabled in Unifi Protect**
- Log into Unifi console
- Go to Protect settings
- Disable "Enhanced Video Encoding" or similar HEVC option

**2. Enable auto-refresh safety net:**
- Double-click "Enable Auto-Refresh" on desktop
- Or run: `~/Desktop/Enable-Auto-Refresh.sh`

**3. Check memory usage:**
```bash
free -h
# Should show plenty of free RAM (14+ GB available)
```

**4. Check Chromium logs:**
```bash
# View errors
tail -100 /tmp/chromium-simple.log | grep ERROR

# Check for specific issues
journalctl | grep chromium | tail -50
```

**5. Last resort - increase refresh frequency:**
Edit `~/chromium-refresh.sh` and change `sleep 600` to `sleep 300` (5 minutes instead of 10)

### Screen Wakes But Chromium Doesn't Start

**Test wake script manually:**
```bash
~/screen-wake.sh
```

**Check for errors:**
```bash
# Should see Chromium starting
ps aux | grep chromium

# Check logs
tail -20 /tmp/chromium-simple.log
```

**Common causes:**
- Display environment variable not set (check script has WAYLAND_DISPLAY=wayland-0)
- Permissions issue (ensure script is executable: `chmod +x ~/screen-wake.sh`)

### Network Monitor Not Working

**Check if running:**
```bash
ps aux | grep network-monitor | grep -v grep
```

**Check logs:**
```bash
journalctl | grep "Network monitor" | tail -20
```

**Test connectivity manually:**
```bash
ping -c 1 <UNIFI_PROTECT_IP>
# Should respond if Unifi is reachable
```

**Restart monitor:**
```bash
killall network-monitor.sh
nohup ~/network-monitor.sh > /tmp/network-monitor.log 2>&1 &
```

### Daily Reboot Not Happening

**Verify cron job:**
```bash
cat /etc/cron.d/daily-reboot
# Should show: 0 3 * * * root /usr/sbin/reboot
```

**Check cron service:**
```bash
sudo systemctl status cron
# Should be "active (running)"
```

**Check system logs for reboot:**
```bash
last reboot | head -5
# Should show daily 3 AM reboots
```

### Auto-Refresh Interfering with Screen Timeout

This shouldn't happen - the script is power-saving aware. Verify:

```bash
cat ~/chromium-refresh.sh
```

Should include:
```bash
if pgrep -x chromium > /dev/null; then
    # Only refresh if Chromium is running
```

If missing, the script needs to be updated to check if Chromium is running before refreshing.

---

## Technical Reference

### System Specifications

**Hardware:**
- Raspberry Pi 5
- 16GB RAM
- Samsung Monitor (HDMI-A-2)

**Software:**
- Debian GNU/Linux 13 (trixie)
- Linux kernel 6.12.47+rpt-rpi-2712
- labwc (Wayland compositor)
- Chromium 141.0.7390.65

**Display:**
- Resolution: Auto-detected
- Power Management: wlopm (Wayland)
- Idle Detection: swayidle

### Files and Locations

**Scripts:**
```
~/screen-sleep.sh               # Power-saving activation
~/screen-wake.sh                # Wake from power-saving
~/network-monitor.sh            # Network recovery monitor
~/chromium-refresh.sh           # Optional auto-refresh (disabled)
```

**Autostart Configs:**
```
~/.config/autostart/unifi-protect.desktop       # Chromium launcher
~/.config/autostart/screen-timeout.desktop      # Power-saving
~/.config/autostart/network-monitor.desktop     # Network monitor
~/.config/autostart/chromium-refresh.desktop.disabled  # Auto-refresh (off)
```

**Desktop Shortcuts:**
```
~/Desktop/Enable-Auto-Refresh.sh
~/Desktop/Enable-Auto-Refresh.desktop
~/Desktop/Screen-Off.sh
~/Desktop/Screen-Off.desktop
~/Desktop/Screen-On.sh
~/Desktop/Screen-On.desktop
```

**System Configs:**
```
/etc/cron.d/daily-reboot        # Daily 3 AM reboot
```

**Logs:**
```
/tmp/chromium-simple.log        # Chromium errors
/tmp/swayidle.log               # Power-saving events
/tmp/network-monitor.log        # Network events
journalctl                      # System journal (all events)
```

### Environment Variables

**Critical for Wayland:**
```bash
WAYLAND_DISPLAY=wayland-0       # Required for wlopm
DISPLAY=:0                      # Required for Chromium
```

These are set in scripts automatically.

### Power Consumption

**Measured/Estimated:**
- Active (display on, streaming): ~15-20W
- Power-saving (display off, no streaming): ~3-5W
- Savings: ~75% reduction when idle

**Components:**
- Display: ~10-15W (largest consumer)
- Pi 5: ~3-5W (base)
- Streaming: ~2-3W (network + processing)

### Memory Usage

**Typical (with Chromium running):**
- Total: 16GB
- Used: 1-2GB
- Available: 14GB+
- Swap: 2GB (rarely used)

Plenty of headroom - memory is not a constraint.

### Network Requirements

**Bandwidth:**
- Multiple camera streams: Variable (depends on number/quality)
- Typical: 5-20 Mbps

**Connectivity:**
- Wired Ethernet recommended
- WiFi acceptable if stable
- Recovery monitoring in place for intermittent issues

### Security Considerations

**Current State:**
- SSH enabled with password authentication
- Default credentials documented (change in production!)
- System on local network only

**Recommendations for Production:**
1. Change default SSH password
2. Implement SSH key-based authentication
3. Disable password authentication in SSH
4. Configure firewall (ufw) to limit SSH access
5. Regular OS updates
6. Monitor access logs

**To implement key-based auth:**
```bash
# On your laptop
ssh-keygen -t ed25519
ssh-copy-id <SSH_USERNAME>@<PI_IP_ADDRESS>

# On Pi
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

### Backup and Recovery

**Important files to backup:**
```
~/.config/autostart/
~/screen-*.sh
~/network-monitor.sh
~/chromium-refresh.sh
/etc/cron.d/daily-reboot
```

**Quick backup:**
```bash
tar -czf ~/kiosk-backup-$(date +%Y%m%d).tar.gz \
  ~/.config/autostart/ \
  ~/screen-*.sh \
  ~/network-monitor.sh \
  ~/chromium-refresh.sh \
  /etc/cron.d/daily-reboot
```

**Restore from backup:**
```bash
tar -xzf kiosk-backup-YYYYMMDD.tar.gz -C /
chmod +x ~/*.sh
sudo chmod 644 /etc/cron.d/daily-reboot
```

---

## Maintenance Schedule

### Daily (Automatic)
- 3:00 AM reboot
- Network monitoring (continuous)
- Power-saving cycles (as needed)

### Weekly (Manual)
- Check system logs for errors: `journalctl -p err`
- Verify all services running: `systemctl --failed`
- Check disk space: `df -h`

### Monthly (Manual)
- Review Chromium crash logs if any
- Check SD card health: `sudo smartctl -a /dev/mmcblk0` (if supported)
- Verify backup integrity
- Update OS: `sudo apt update && sudo apt upgrade`

### Quarterly (Manual)
- Review and update configurations as needed
- Check for new Chromium optimizations
- Verify power-saving still functioning correctly
- Test manual controls and shortcuts

---

## Change Log

### Version 1.0 - November 12, 2025

**Initial Setup:**
- Implemented crash prevention with optimized Chromium flags
- Created 15-minute power-saving mode with full streaming stop
- Added network recovery monitoring (30-second intervals)
- Configured daily 3:00 AM automatic reboot
- Disabled crash recovery prompts
- Created manual control desktop shortcuts
- Implemented optional auto-refresh safety net (disabled by default)
- Fixed WAYLAND_DISPLAY environment variable for proper display control
- Documented HEVC incompatibility and recommended H.264
- Created comprehensive documentation and Git repository

**Known Issues:**
- HEVC video may cause GPU SharedImage errors (disable in Unifi)
- wlopm requires WAYLAND_DISPLAY to be explicitly set

**Testing Status:**
- Power-saving: ✓ Verified working
- Network recovery: ✓ Verified working
- Daily reboot: ⏳ Scheduled (will verify after 3 AM)
- Crash prevention: ⏳ Testing in progress (disable HEVC first)

---

## Future Improvements

Potential enhancements to consider:

- [ ] Email/SMS notifications for system down alerts
- [ ] Temperature monitoring and thermal throttling alerts
- [ ] Implement SSH key-based authentication
- [ ] Add log rotation for Chromium logs
- [ ] Create web dashboard for remote monitoring
- [ ] Add camera feed health monitoring
- [ ] Implement graceful shutdown on power loss (UPS integration)
- [ ] Add metrics collection (uptime, crashes, power cycles)
- [ ] Create automated backup to network storage

---

## Credits

**Configuration developed:** November 12, 2025
**System:** Church Security Monitoring Kiosk
**Assistance:** Claude (Anthropic AI)

---

## Contact & Support

**For issues with this setup:**
1. Check Troubleshooting section above
2. Review system logs: `journalctl -xe`
3. Verify all services running: `ps aux | grep -E 'chromium|swayidle|network'`

**SSH Access:**
- Credentials stored in Bitwarden under "Church Security Kiosk"
- IP address available in Ubiquiti UniFi console or router DHCP table

---

**Document Version:** 1.0
**Last Updated:** November 12, 2025
**Maintained By:** Church IT Team
