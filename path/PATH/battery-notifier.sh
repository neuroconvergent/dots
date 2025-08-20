#!/usr/bin/env bash
#--------------------------------
notif_check=0
full_notif_check=0
while true; do
	export DISPLAY=:0.0

	while read line; do
		value=$(echo $line | sed 's/%//g' | cut -d " " -f 2)
		key=$(echo $line | sed 's/%//g' | cut -d ":" -f 1)

		if [ $key = 'state' ]; then
			bat_state=$value
		else
			bat_percent=$value
		fi
	done < <(upower -i $(upower -e | grep BAT) | grep -E "percentage|state")

	if [ $bat_state == 'discharging' ]; then
		if [ $bat_percent -lt 30 ] && [ $notif_check -eq 0 ]; then
			notify-send --urgency=CRITICAL -a "Battery Notification" "Battery Low" "Level: ${bat_percent}%" -i "$HOME/.config/swaync/icons/warning.png"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
			notif_check=1
		elif [ $bat_percent -lt 10 ]; then
			notify-send --urgency=CRITICAL -a "Battery Notification" "Battery Low" "Level: ${bat_percent}%" -i "$HOME/.config/swaync/icons/warning.png"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
			sleep 30
		fi
	else
		if [ $bat_percent -ge 100 ]&& [ $full_notif_check -eq 0 ]; then
			notify-send --urgency=NORMAL -a "Battery Notification" "Battery Full" "Level: ${bat_percent}%" -i "$HOME/.config/swaync/icons/full-battery.png"
			full_notif_check=1
		elif [ $bat_percent -le 80 ]; then
			full_notif_check=0
		elif [ $bat_percent -ge 30 ]; then
			notif_check=0
		fi
	fi
	sleep 10
done
