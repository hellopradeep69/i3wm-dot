#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo -e "Usage: $0 <filename>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo -e "${RED}Error:${RESET} File not found!"
    exit 1
fi
