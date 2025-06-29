#!/usr/bin/env sh

stdlib::import "string/inflector"

capitalize() {
  inflector "capitalize" "$@"
}
