#!/usr/bin/env sh

stdlib::import "string/inflector"

strip() {
  inflector "strip" "$@"
}
