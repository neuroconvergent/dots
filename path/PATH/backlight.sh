#!/usr/bin/env bash

iDIR="$HOME/.config/swaync/icons"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
state_file="$state_dir/backlight"

# Mirror the laptop backlight percentage to DDC/CI external monitors.
set_external_backlight() {
	command -v ddcutil >/dev/null 2>&1 || return 0

	local percent display
	percent="$(get_backlight_percent)"

	while read -r display; do
		ddcutil --display "$display" setvcp 10 "$percent" >/dev/null 2>&1 || true
	done < <(ddcutil detect --brief 2>/dev/null | awk '/^Display [0-9]+/ {print $2}')
}

# Get brightness
get_backlight() {
	LIGHT=$(printf "%.0f\n" "$(brightnessctl g)")
	echo "${LIGHT}"
}

# Get brightness as a percentage
get_backlight_percent() {
	LIGHT=$(printf "%.0f\n" "$(brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}')")
	echo "${LIGHT}"
}

# Get icons
get_icon() {
	current="$(get_backlight_percent)"
	if [[ ("$current" -ge "0") && ("$current" -le "33") ]]; then
		icon="$iDIR/brightness-0.png"
	elif [[ ("$current" -ge "33") && ("$current" -le "66") ]]; then
		icon="$iDIR/brightness-50.png"
	elif [[ ("$current" -ge "66") && ("$current" -le "100") ]]; then
		icon="$iDIR/brightness-100.png"
	fi
}

# Notify
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$icon" "Brightness : $(get_backlight_percent)%"
}

# Increase brightness
inc_backlight() {
	brightnessctl s +5% && set_external_backlight && get_icon && notify_user
}

# Decrease brightness
dec_backlight() {
	brightnessctl s 5%- && set_external_backlight && get_icon && notify_user
}

# Remember the current brightness percentage for --reset.
save_backlight() {
	local percent
	percent="$(get_backlight_percent)"

	if [[ ! "$percent" =~ ^[0-9]+$ ]]; then
		echo "Unable to save current brightness" >&2
		return 1
	fi

	mkdir -p "$state_dir" && printf '%s\n' "$percent" > "$state_file"
}

# Set brightness to a specific percentage
set_backlight() {
	local percent="$1"

	if [[ ! "$percent" =~ ^[0-9]+$ ]]; then
		echo "Usage: $0 --set <0-100>" >&2
		return 1
	fi

	if [[ "$percent" -lt 0 ]]; then
		percent=0
	elif [[ "$percent" -gt 100 ]]; then
		percent=100
	fi

	save_backlight && brightnessctl s "$percent%" && set_external_backlight && get_icon && notify_user
}

# Restore the previously saved brightness percentage.
reset_backlight() {
	local percent

	if [[ ! -r "$state_file" ]]; then
		echo "No saved brightness value" >&2
		return 1
	fi

	read -r percent < "$state_file"

	if [[ ! "$percent" =~ ^[0-9]+$ ]]; then
		echo "Saved brightness value is invalid" >&2
		return 1
	fi

	brightnessctl s "$percent%" && set_external_backlight && get_icon && notify_user
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_backlight
elif [[ "$1" == "--inc" ]]; then
	inc_backlight
elif [[ "$1" == "--dec" ]]; then
	dec_backlight
elif [[ "$1" == "--set" ]]; then
	set_backlight "$2"
elif [[ "$1" == "--reset" ]]; then
	reset_backlight
else
	get_backlight
fi
