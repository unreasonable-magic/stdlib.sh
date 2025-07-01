#!/usr/bin/env sh

stdlib::import "string/inflector"

uppercase() {
  inflector "uppercase" "$@"
}
