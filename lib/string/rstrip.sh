#!/usr/bin/env sh

stdlib::import "string/inflector"

rstrip() {
  inflector "rstrip" "$@"
}
