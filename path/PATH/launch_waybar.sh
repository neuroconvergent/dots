#!/bin/sh
#
if pgrep waybar
then
	killall waybar
fi
setsid -f waybar -c /home/sundar/.config/waybar/waybar.conf -s /home/sundar/.config/waybar/style.css
