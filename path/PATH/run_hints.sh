#!/usr/bin/env bash

WAY_STATUS=0

# Check if Waybar is running
if pgrep -x waybar >/dev/null; then
	killall waybar
	WAY_STATUS=1
fi

# Run hints
"$HOME/.local/bin/hints"

# Restore Waybar if it was running
if [ $WAY_STATUS -eq 1 ]; then
	waybar -c ~/.config/waybar/waybar.conf &
fi
