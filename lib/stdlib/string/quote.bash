stdlib_import "test"
stdlib_import "argparser"

stdlib_string_quote() {
  local char='"' escape='\"'

  for arg in "$@"; do
    case "$arg" in
    --single)
      char="'"
      escape="'\''"
      ;;
    -*)
      stdlib_argparser error/invalid_arg "$arg"
      return
      ;;
    *)
      input="$arg"
      ;;
    esac
  done

  if stdlib_test file/is_fifo /dev/stdin; then
    input="$(cat)"
  fi

  if stdlib_test string/is_empty "$input"; then
    printf "\n"
    return
  fi

  printf '%s%s%s\n' "$char" "${input//"$char"/"$escape"}" "$char"
}
