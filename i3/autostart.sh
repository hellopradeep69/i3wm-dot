#!/bin/bash

# Clipboard manager
wl-paste --watch cliphist store &

#copyq to have clipboard
copyq &

# Notification daemon
dunst &

# Start compositor
picom &

# feh --bg-fill ~/Pictures/Wallpapers/maybe.jpg &
# nitrogen --restore &

# Custom scripts
~/.local/bin/keybind.sh &
~/.local/bin/bat_notify.sh &

# Polybar
# $HOME/.config/polybar/launch.sh &
