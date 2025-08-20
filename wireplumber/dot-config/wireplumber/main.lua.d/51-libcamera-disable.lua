# ~/.config/wireplumber/main.lua.d/51-libcamera-disable.lua
# Mitigate camera not turning off, see https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2669#note_2252423
# Restart wireplumber after change with `systemctl restart --user wireplumber`
libcamera_monitor.enabled = false
