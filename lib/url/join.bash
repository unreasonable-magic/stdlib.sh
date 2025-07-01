#!/usr/bin/env bash

urljoin() {
  local joined
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
