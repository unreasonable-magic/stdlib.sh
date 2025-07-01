#!/usr/bin/env bash

# Parse a URL into its component parts
#
# Usage: urlparse <url> [OPTIONS...]
#
# Arguments:
#   <url>               The URL to parse (required)
#
# Options:
#   --scheme            Output the scheme/protocol (e.g., http, https, ftp)
#   --host              Output the hostname
#   --port              Output the port number
#   --path              Output the path component
#   --query             Output the query string
#   --fragment          Output the fragment/anchor
#
# Examples:
#   $ urlparse "https://example.com:8080/path?query=value#section" --host
#   example.com
#
#   $ urlparse "https://api.github.com/repos/user/repo" --scheme --host --path
#   https
#   api.github.com
#   /repos/user/repo
#
urlparse() {
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
