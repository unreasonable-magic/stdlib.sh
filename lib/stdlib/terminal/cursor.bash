#export CURSOR_DEFAULT="CURSOR_DEFAULT"
#export CURSOR_UNDERLINE="CURSOR_UNDERLINE"
#export CURSOR_BAR="CURSOR_BAR"

declare -g __stdlib_terminal_cursor_state_init
declare -g __stdlib_terminal_cursor_state_visible
declare -g __stdlib_terminal_cursor_state_style
declare -g __stdlib_terminal_cursor_state_blink
declare -g __stdlib_terminal_cursor_state_color

stdlib_terminal_cursor_init() {
  if [[ -z $__stdlib_terminal_cursor_state_init ]]; then
    __stdlib_terminal_cursor_state_style="default"
    __stdlib_terminal_cursor_state_visible="true"
    __stdlib_terminal_cursor_state_blink="false"
    __stdlib_terminal_cursor_state_color="?"

    __stdlib_terminal_cursor_state_init="true"
  fi
}

stdlib_terminal_cursor() {
  stdlib_terminal_cursor_init

  local visible
  local style
  local blink
  local color

  for arg; do
    if [[ "$arg" =~ ^([a-z]+)=([a-z0-9-]+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"

      case "$key" in
      visible)
        visible="$value"
        ;;
      style)
        style="$value"
        ;;
      blink)
        blink="$value"
        ;;
      color)
        color="$value"
        ;;
      esac
    else
      stdlib_error_log "not sure how to parse $arg"
      return 1
    fi
  done

  if [[ -n $visible ]]; then
    case "$visible" in
    "true")
      printf '\e[?25h' >/dev/tty
      ;;
    "false")
      printf '\e[?25l' >/dev/tty
      ;;
    *)
      stdlib_error_log "unknown arg to visible: $visible"
      return 1
      ;;
    esac
    __stdlib_terminal_cursor_state_visible="$visible"
  fi

  if [[ -z $style && -n $blink ]]; then
    case "$blink" in
    true)
      printf '\e[?12h' >/dev/tty
      ;;
    false)
      printf '\e[?12l' >/dev/tty
      ;;
    esac
    __stdlib_terminal_cursor_state_blink="$blink"
  elif [[ -n $style ]]; then
    blink="${blink:-"$__stdlib_terminal_cursor_state_blink"}"

    case "$style" in
    block)
      if [[ "$blink" == "true" ]]; then
        printf '\e[1 q' >/dev/tty
      else
        printf '\e[2 q' >/dev/tty
      fi
      ;;
    underline)
      if [[ "$blink" == "true" ]]; then
        printf '\e[3 q' >/dev/tty
      else
        printf '\e[4 q' >/dev/tty
      fi
      ;;
    bar)
      if [[ "$blink" == "true" ]]; then
        printf '\e[5 q' >/dev/tty
      else
        printf '\e[6 q' >/dev/tty
      fi
      ;;
    *)
      stdlib_error_log "unknown cursor style: ${style@Q}"
      return 1
      ;;
    esac

    __stdlib_terminal_cursor_state_style="$style"
  fi

  if [[ -n $color ]]; then
    printf '\x1b]12;%s\x1b\\' "$color" >/dev/tty
    __stdlib_terminal_cursor_state_color="$color"
  fi

  printf "visible=%s\nstyle=%s\nblink=%s\ncolor=%s\n" \
    "$__stdlib_terminal_cursor_state_visible" \
    "$__stdlib_terminal_cursor_state_style" \
    "$__stdlib_terminal_cursor_state_blink" \
    "$__stdlib_terminal_cursor_state_color"
}
