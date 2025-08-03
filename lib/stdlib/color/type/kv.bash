stdlib_import "string/wordsplit"

enable kv

STDLIB_COLOR_KV_REGEX="^(red|green|blue)=(.*)$"

stdlib_color_type_kv_format() {
  printf "red=%s green=%s blue=%s\n" "${COLOR[1]}" "${COLOR[2]}" "${COLOR[3]}"
}

stdlib_color_type_kv_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_KV_REGEX ]]; then
    if kv -s '=' <<<"${ stdlib_string_wordsplit "$1"; }"; then
      declare -g -a COLOR=(
        "kv"
        "${KV["red"]}"
        "${KV["green"]}"
        "${KV["blue"]}"
      )
      return 0
    fi
  fi

  return 1
}
