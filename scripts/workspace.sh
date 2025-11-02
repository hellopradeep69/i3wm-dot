#!/bin/bash
# my first script btw

THEME="/usr/share/rofi/themes/gruvbox-dark-hard.rasi"

action=$(printf "one\ntwo\nthree\nfour\nfive" | rofi -dmenu -theme "$THEME" -p "Goto")

case "$action" in
one) bspc desktop -f 1 ;;
two) bspc desktop -f 2 ;;
three) bspc desktop -f 3 ;;
four) bspc desktop -f 4 ;;
five) bspc desktop -f 5 ;;
esac
