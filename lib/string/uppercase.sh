#!/usr/bin/env sh

uppercase() {
  printf '%s\n' "$1" | tr '[:lower:]' '[:upper:]'
}
