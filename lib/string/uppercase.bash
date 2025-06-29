#!/usr/bin/env bash

uppercase() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local str="${1:-$(</dev/stdin)}"

  str="${str^^}"

  if [[ -n "$returnvar" ]]; then
    declare -n returnvar_ref="${returnvar}"
    # shellcheck disable=SC2034
    returnvar_ref="${str}"
  else
    printf "%s\n" "${str}"
  fi
}
