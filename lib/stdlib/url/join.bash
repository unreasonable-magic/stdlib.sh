urljoin() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local joined
  for str in "$@"; do
    joined+="$str/"
  done

  # Globally replace any tripple /// (which may have gotten added during the
  # join) with a single /
  joined="${joined//\/\/\///}"

  # Remove trailing / if we have one
  joined="${joined%%/}"

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$joined"
  else
    printf "%s\n" "${joined}"
  fi

  return 0
}
