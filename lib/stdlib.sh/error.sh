#!/usr/bin/env bash

stdlib::require "stdlib.sh/error/stacktrace"

stdlib::error::stacktrace() {
  if [[ "$BASH_SOURCE" != "" ]]; then
    stdlib::error::stacktrace::bash
  else
    echo "can't figure out backtrace"
  fi
}

stdlib::error::log() {
  local script_name="$(basename "$0")"
  printf "%s: $1\n" "$script_name" "${@:2}" >&2
}

# Prints an error and returns 1
stdlib::error::warning() {
  stdlib::error::log "$@"
  return 1
}

# Prints an error to stderr then exits
stdlib::error::fatal() {
  stdlib::error::log "$@"
  exit 1
}
