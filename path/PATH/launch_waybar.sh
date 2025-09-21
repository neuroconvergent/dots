#!/bin/sh
#
if pgrep waybar
then
	killall waybar
fi
setsid -f waybar -c $HOME/.config/waybar/waybar.conf -s $HOME/.config/waybar/style.css
