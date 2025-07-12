stdlib_import "argparser"
stdlib_import "string/repeat"

stdlib_string_pad() {
  local string_arg=""
  local width_arg=10
  local align_arg="left"
  local padding_char=" "

  while [[ $# -gt 0 ]]; do
    case $1 in
    --width)
      width_arg="$2"
      if [[ ! "$width_arg" =~ ^[0-9]+$ ]]; then
        stdlib_argparser error/invalid_arg "--width must be a positive integer"
        return 1
      fi
      shift 2
      ;;
    --align)
      align_arg="$2"
      if [[ ! "$align_arg" =~ ^(left|right|center)$ ]]; then
        stdlib_argparser error/invalid_arg "--align must be 'left', 'right', or 'center'"
        return 1
      fi
      shift 2
      ;;
    --char)
      padding_char="$2"
      shift 2
      ;;
    -*)
      stdlib_argparser error/invalid_arg "$1"
      return 1
      ;;
    *)
      string_arg="$1"
      shift
      ;;
    esac
  done

  # Make sure we've got a string
  if [[ -z "$string_arg" ]]; then
    stdlib_argparser error/missing_arg "no string provided"
    return 1
  fi

  # Get string length in bytes (this is what ${#string} gives us)
  local string_length=${#string_arg}

  # If string is already longer than width, just return it
  if [[ $string_length -ge $width_arg ]]; then
    printf "%s" "$string_arg"
    return 0
  fi

  local total_padding=$((width_arg - string_length))
  local padding="${ stdlib_string_repeat "$padding_char" "$width_arg"; }"

  case "$align_arg" in
  left)
    printf "%s%s\n" "$string_arg" "${padding:0:$total_padding}"
    ;;
  right)
    printf "%s%s\n" "${padding:0:$total_padding}" "$string_arg"
    ;;
  center)
    local left_pad=$((total_padding / 2))
    local right_pad=$((total_padding - left_pad))
    printf "%s%s%s\n" "${padding:0:$left_pad}" "$string_arg" "${padding:0:$right_pad}"
    ;;
  esac
}
