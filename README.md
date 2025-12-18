# Bazzite Primary Display Setup Script

A simple interactive script to easily set the primary display for Gaming Mode in Bazzite.

The script automatically detects connected displays, lets you choose the desired one, writes the correct configuration, and offers to reboot.

## Technical details

The script creates (or overwrites) the following:

- **Directory**: `~/.config/environment.d/` (created if it doesn't exist)
- **File**: `~/.config/environment.d/10-gamescope-session.conf`

## Usage (one command)

```bash
bash <(curl -s https://raw.githubusercontent.com/Jlexand/bazzite-primary-display/master/set-primary-display.sh)
