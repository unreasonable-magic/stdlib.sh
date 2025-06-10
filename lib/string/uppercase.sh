#!/usr/bin/env sh

uppercase() {
  # shellcheck disable=SC3028
  if [ -n "$BASH_VERSION" ] && [ "${BASH_VERSINFO:-0}" -ge 4 ] 2>/dev/null; then
    uppercase() {
      eval "printf '%s\\n' \"\${1^^}\""
    }
  elif [ -n "$ZSH_VERSION" ]; then
    uppercase() {
      # shellcheck disable=SC2296
      printf '%s\n' "${1:u}"
    }
  else
    uppercase() {
      printf '%s\n' "$1" | tr '[:lower:]' '[:upper:]'
    }
  fi

  uppercase "$@"
}
