#!/usr/bin/env bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# echo -e "${RED} Hello"

File="$1"

Base=$(basename "$File")
Dir=$(dirname "$File")
ext="${File##*.}"

echo "$Base $Dir $ext"
