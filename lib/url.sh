#!/usr/bin/env bash

stdlib::url::parse() {
  local url="$1"
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

  for arg in "${@:2}"; do
    case "$arg" in
      --scheme)
        echo "$scheme"
        ;;
      --host)
        echo "$host"
        ;;
      --port)
        echo "$port"
        ;;
      --path)
        echo "$path"
        ;;
      --query)
        echo "$query"
        ;;
      --fragment)
        echo "$fragment"
        ;;
    esac
  done
}

stdlib::url::join() {
  local joined last_part

  for str in "$@"; do
    joined+="$str/"
  done

  # Globally replace any tripple /// (which may have gotten added during the
  # join) with a single /
  joined="${joined//\/\/\///}"

  # Remove trailing / if we have one
  joined="${joined%%/}"

  echo "$joined"
}
