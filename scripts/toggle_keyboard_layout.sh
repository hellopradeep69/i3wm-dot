#!/bin/bash

# Get current layout and variant (if any)
current_layout=$(setxkbmap -query | awk '/layout:/ {print $2}')
current_variant=$(setxkbmap -query | awk '/variant:/ {print $2}')

# Define menu options (layout:variant format)
options="QWERTY\nDVORAK\nCOLEMAK"

# Use rofi to choose layout
chosen=$(echo -e "$options" | rofi -dmenu -p "Select Keyboard Layout:" -theme demnu)

case "$chosen" in
QWERTY)
    setxkbmap us
    notify-send "Keyboard layout: QWERTY"
    ;;
DVORAK)
    setxkbmap us -variant dvorak
    notify-send "Keyboard layout: DVORAK"
    ;;
COLEMAK)
    setxkbmap us -variant colemak
    notify-send "Keyboard layout: COLEMAK"
    ;;
*)
    notify-send "No layout selected"
    exit 1
    ;;
esac
