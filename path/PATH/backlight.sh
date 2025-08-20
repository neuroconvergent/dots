!/usr/bin/env bash

iDIR="$HOME/.config/swaync/icons"

# Get brightness
get_backlight() {
	LIGHT=$(printf "%.0f\n" $(brightnessctl g))
	echo "${LIGHT}"
}

# Get brightness as a percentage
get_backlight_percent() {
	LIGHT=$(printf "%.0f\n" $(brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}'))
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
	brightnessctl s +5% && get_icon && notify_user
}

# Decrease brightness
dec_backlight() {
	brightnessctl s 5%- && get_icon && notify_user
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_backlight
elif [[ "$1" == "--inc" ]]; then
	inc_backlight
elif [[ "$1" == "--dec" ]]; then
	dec_backlight
else
	get_backlight
fi
