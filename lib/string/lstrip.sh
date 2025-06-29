#!/usr/bin/env sh

stdlib::import "string/inflector"

lstrip() {
  inflector "lstrip" "$@"
}
