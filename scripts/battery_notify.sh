#!/bin/bash

CRITICAL_LEVEL=30
CHECK_INTERVAL=60 # seconds
last_warned=100

while true; do
    battery_level=$(cat /sys/class/power_supply/BAT*/capacity | sort -n | head -1)
    charging_status=$(cat /sys/class/power_supply/BAT*/status | head -1)

    if [[ "$battery_level" -le "$CRITICAL_LEVEL" && "$charging_status" != "Charging" ]]; then
        if [[ "$battery_level" -lt "$last_warned" ]]; then
            if ((battery_level <= 10)); then
                notify-send -u critical "🔴 CRITICAL Battery" "${battery_level}% left!"
            elif ((battery_level <= 20)); then
                notify-send -u critical "🟠 Low Battery" "${battery_level}% left!"
            else
                notify-send -u normal "⚠️ Battery" "${battery_level}% left!"
            fi
            paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga &
            last_warned=$battery_level
        fi
    else
        last_warned=100
    fi

    sleep "$CHECK_INTERVAL"
done
