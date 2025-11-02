#!/bin/bash

# Get list of Wi-Fi networks (skip header)
networks=$(nmcli -f SSID,SECURITY device wifi list | awk 'NR>1 {print $1}' | uniq)

# Show in Rofi
chosen=$(echo "$networks" | rofi -dmenu -i -p "Select Wi-Fi")

# If nothing selected, exit
[ -z "$chosen" ] && exit

# Notify user about attempt
notify-send "Wi-Fi" "Connecting to $chosen..."

# Check if network requires password
secured=$(nmcli -f SSID,SECURITY device wifi list | grep -w "$chosen" | awk '{print $2}')

# Ask for password if secured
if [[ "$secured" != "--" && "$secured" != "" ]]; then
    password=$(rofi -dmenu -password -p "Enter password for $chosen")
    [ -z "$password" ] && exit
    if nmcli device wifi connect "$chosen" password "$password"; then
        notify-send "Wi-Fi" "Connected to $chosen ✅"
    else
        notify-send "Wi-Fi" "Failed to connect to $chosen ❌"
    fi
else
    if nmcli device wifi connect "$chosen"; then
        notify-send "Wi-Fi" "Connected to $chosen ✅"
    else
        notify-send "Wi-Fi" "Failed to connect to $chosen ❌"
    fi
fi
