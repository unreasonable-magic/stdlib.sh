#!/usr/bin/env sh

stdlib::import "string/inflector"

lowercase() {
  inflector "lowercase" "$@"
}
