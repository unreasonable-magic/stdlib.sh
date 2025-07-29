stdlib_import "string/count"
stdlib_import "argparser"
stdlib_import "color/parse"

enable kv

stdlib_color_kv() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  if ! stdlib_color_parse "$input"; then
    stdlib_argparser error/invalid_arg "can't parse ${input@Q}"
    return 1
  fi

  printf "red=%s green=%s blue=%s\n" "${COLOR_RGB[1]}" "${COLOR_RGB[2]}" "${COLOR_RGB[3]}"
}

STDLIB_COLOR_KV_REGEX="^(red|green|blue)=(.*)$"

stdlib_color_kv_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_KV_REGEX ]]; then
    if kv -s '=' <<<"$1"; then
      declare -g -a COLOR_RGB=(
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
