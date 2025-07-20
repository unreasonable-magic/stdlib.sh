stdlib_string_hex_encode() {
  local str="$1"
  local hex=""
  local i

  for ((i = 0; i < ${#str}; i++)); do
    printf -v hex "%s%02x" "$hex" "'${str:i:1}"
  done

  printf "%s\n" "${hex}"
}
