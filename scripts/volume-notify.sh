#!/bin/bash
amixer set Master "$1" unmute
level=$(amixer get Master | grep -o -m 1 '[0-9]\+%')
mute=$(amixer get Master | grep -o '\[off\]')

if [[ "$mute" == "[off]" ]]; then
    notify-send -u low "🔇 Muted"
else
    notify-send -u low "🔊 Volume" "$level"
fi
