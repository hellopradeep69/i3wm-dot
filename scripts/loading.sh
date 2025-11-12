#!/usr/bin/env bash

EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
    ~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf
    ~/.java ~/.cursor ~/fastfetch ~/Telegram ~/.fzf ~/.dbus ~/Dot-conf/*)

exclude_args=""
for d in "${EXCLUDE_DIRS[@]}"; do
    exclude_args+=" -not -path '$d*'"
done

echo "$exclude_args"
