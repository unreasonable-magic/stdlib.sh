#!/usr/bin/env bash

urlparse() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local url="$1"
  shift

  local scheme host port path query fragment
  local temp

  # Check if URL is provided
  if [[ -z "$url" ]]; then
    stdlib::error::warning "not url passed"
    return 1
  fi

  # Extract scheme (protocol)
  if [[ "$url" =~ ^([^:]+):// ]]; then
    scheme="${url%%://*}"
    temp="${url#*://}"
  else
    temp="$url"
  fi

  # Extract fragment (everything after #)
  if [[ "$temp" == *"#"* ]]; then
    fragment="${temp##*#}"
    temp="${temp%#*}"
  fi

  # Extract query string (everything after ?)
  if [[ "$temp" == *"?"* ]]; then
    query="${temp##*\?}"
    temp="${temp%\?*}"
  fi

  # Extract path (everything after first /)
  if [[ "$temp" == *"/"* ]]; then
    path="/${temp#*/}"
    temp="${temp%%/*}"
  else
    path="/"
  fi

  # What's left is host[:port]
  if [[ "$temp" == *":"* ]]; then
    host="${temp%:*}"
    port="${temp##*:}"
  else
    host="$temp"
  fi

  local -a parts=()

  for arg in "${@}"; do
    log_debug "$arg"
    case "$arg" in
    --scheme)
      parts+=("$scheme")
      ;;
    --host)
      parts+=("$host")
      ;;
    --port)
      parts+=("$port")
      ;;
    --path)
      parts+=("$path")
      ;;
    --query)
      parts+=("$query")
      ;;
    --fragment)
      parts+=("$fragment")
      ;;
    esac
  done

  local IFS=$'\n'

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="${parts[*]}"
  else
    echo -e "${parts[*]}"
  fi

  return 0
}
