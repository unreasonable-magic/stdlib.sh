stdlib_ui_alert() {
  local color_arg=""
  local icon_arg=""
  local border_arg="┃"

  while [ $# -gt 0 ]; do
    local arg="$1"
    shift

    case "$arg" in
    --color)
      color_arg="${color_arg:-$1}"
      shift
      ;;
    --icon)
      icon_arg="${icon_arg:-$1}"
      shift
      ;;
    --border)
      border_arg="${border_arg:-$1}"
      shift
      ;;
    info | success | warning | error)
      case "$arg" in
      info)
        color_arg="34"
        icon_arg="󰋽"
        ;;
      success)
        color_arg="32"
        icon_arg=""
        ;;
      warning)
        color_arg="33"
        icon_arg=""
        ;;
      error)
        color_arg="31"
        icon_arg=""
        ;;
      esac
      ;;
    *)
      stdlib_error_log "unknown flag: $arg"
      return 1
      ;;
    esac
  done

  # TODO make this dynamic
  local text_color="0"
  if [[ -n "$color_arg" ]]; then
    case "$color_arg" in
    34)
      text_color="38;2;192;215;233"
      ;;
    32)
      text_color="38;2;191;213;174"
      ;;
    33)
      text_color="38;2;255;213;175"
      ;;
    31)
      text_color="38;2;237;171;171"
      ;;
    esac
  fi

  while IFS=$'\n' read -r text; do
    if [[ "$text" =~ ^#\ (.+)$ ]]; then
      printf "\e[%sm%s \e[1m%s%s\e[0m\n" \
        "$color_arg" \
        "$border_arg" \
        "${icon_arg:+"$icon_arg "}" \
        "${BASH_REMATCH[1]}"
    else
      printf "\e[%sm%s\e[0m \e[%sm%s\e[0m\n" \
        "$color_arg" \
        "$border_arg" \
        "$text_color" \
        "$text"
    fi
  done
}
