#!/usr/bin/env sh

lowercase() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'
}
