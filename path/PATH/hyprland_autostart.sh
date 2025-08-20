#!/bin/sh
#

### Wallpaper with hyprpaper
hyprpaper &

### Waybar launch script
$HOME/PATH/launch_waybar.sh &

### System tray applets
nm-applet &
blueman-applet &

### Notifications with dunst
#if pgrep dunst
#then
#	killall dunst
#fi
#dunst -conf $HOME/.config/dunst/dunstrc &

### Notifications with mako
#if pgrep mako
#then
#	killall mako
#fi
#mako &

### Notifications with swaync 
if pgrep swaync
then
	killall swaync
fi
swaync &
$HOME/PATH/battery-notifier.sh &

###Automatic screen temperature with gammastep
gammastep-indicator &

###Activate bluetooth file transfer
/usr/lib/bluetooth/obexd -n &

###Lock screen Timeout with swayidle
#swayidle -w timeout 240 '$HOME/PATH/lock_screen_off.sh' before-sleep '$HOME/PATH/lock_screen_off.sh' &

###Lock screen Timeout with hypridle
hypridle &

###Clipboard with Cliphist
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

###Font Config for XWayland
xsettingd &

###kanata for keyboard mods
kanata -c ~/.config/kanata/config.kbd

###Music Player Daemon
#mpd $HOME/.config/mpd/mpd.conf &
#mpDris2 &
# Use mpd and mpdris2-rs user sevices instead

###Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

###Automounting drives with udiskie (password prompt with zenity)
udiskie -a --smart-tray -p "zenity --entry --hide-text --text 'Enter password for {device_presentation}:' --title 'Authentication for Disk Operation'" -f pcmanfm-qt&

###Optimus-manager for nvidia
#sleep 10;
#if pgrep optimus-manager-qt
#then
	#killall optimus-manager-qt
#fi
#optimus-manager-qt &

###Proton mail bridge
protonmail-bridge --noninteractive &

###Screensharing Nuclear Method
sleep 1
killall -e xdg-desktop-portal-hyprland 
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal 
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2 
/usr/lib/xdg-desktop-portal &
