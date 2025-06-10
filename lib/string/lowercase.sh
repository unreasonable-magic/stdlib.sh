#!/usr/bin/env sh

lowercase() {
  # shellcheck disable=SC3028
  if [ -n "$BASH_VERSION" ] && [ "${BASH_VERSINFO:-0}" -ge 4 ] 2>/dev/null; then
    lowercase() {
      eval "printf '%s\\n' \"\${1,,}\""
    }
  elif [ -n "$ZSH_VERSION" ]; then
    lowercase() {
      # shellcheck disable=SC2296
      printf '%s\n' "${1:l}"
    }
  else
    lowercase() {
      printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'
    }
  fi

  lowercase "$@"
}
