stdlib_string_hex_decode() {
  local hex="$1"
  local decoded=""
  local i

  for ((i = 0; i < ${#hex}; i += 2)); do
    decoded+="\x${hex:i:2}"
  done

  printf -v decoded "%b" "$decoded"
  printf "%s\n" "${decoded}"
}
