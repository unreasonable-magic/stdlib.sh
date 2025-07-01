#!/usr/bin/env sh

stdlib::import "string/inflector"

trim() {
  inflector "trim" "$@"
}
