#!/usr/bin/env bash

MkFile() {
  File="$1"

  if [[ -z "$File" ]]; then
    exit 1
  elif [[ -f "$File" ]]; then
    echo "Already exist"
    exit 1
  fi

  mkdir -p "$(dirname "$File")"
  touch "$File"

  echo "created dir : $(dirname "$File")"
  echo "created file : $File"
}

MkFile_cur() {
  File="$1"
  mkdir -p "$(dirname "$File")"
  touch "$File"
}

case "$1" in
1) echo hello ;;
*)
  MkFile "$1"
  ;;
esac
