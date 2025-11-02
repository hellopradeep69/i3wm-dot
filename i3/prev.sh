#!/usr/bin/env bash
# Cycles to the previous workspace (1–10) including empty ones

current=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
prev=$((current - 1))
if [ "$prev" -lt 1 ]; then
    prev=10
fi
i3-msg workspace number $prev
