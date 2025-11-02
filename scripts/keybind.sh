#!/usr/bin/bash

key_set() {
    setxkbmap -option ctrl:nocaps
    xmodmap -e "keycode 108 = Escape"
}

Trackpad_set() {
    xinput set-prop "SYNA7DB5:00 06CB:CD41 Touchpad" "libinput Natural Scrolling Enabled" 1
}

key_set && Trackpad_set
