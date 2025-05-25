#!/usr/bin/env bash

stdlib::require() {
  local path="$STDLIB_PATH/lib/$1"
  if [ -e "$path" ]; then
    source "$path"
  else
    echo "stdlib::require: no such file $1"
    exit 1
  fi
}
