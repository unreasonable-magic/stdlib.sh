#!/usr/bin/env sh

stdlib::import "string/inflector"

titleize() {
  inflector "titleize" "$@"
}
