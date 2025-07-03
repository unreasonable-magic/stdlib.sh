#!/usr/bin/env bash

stdlib::import "error/stacktrace"
stdlib::import "error/log"

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
