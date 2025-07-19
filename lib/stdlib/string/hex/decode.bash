stdlib_string_hex_decode() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local hex="$1"
  local decoded=""
  local i

  for ((i = 0; i < ${#hex}; i += 2)); do
    decoded+="\x${hex:i:2}"
  done

  printf -v decoded "%b" "$decoded"

  if [[ -n "$returnvar" ]]; then
    declare -g __stdlib_string_hex_decode_return="${decoded}"
    eval "$returnvar=\$__stdlib_string_hex_decode_return"
    unset __stdlib_string_hex_decode_return
  else
    printf "%s\n" "${decoded}"
  fi
}
