#export CURSOR_DEFAULT="CURSOR_DEFAULT"
#export CURSOR_UNDERLINE="CURSOR_UNDERLINE"
#export CURSOR_BAR="CURSOR_BAR"

declare -g __stdlib_screen_cursor_state_init
declare -g __stdlib_screen_cursor_state_visible
declare -g __stdlib_screen_cursor_state_style
declare -g __stdlib_screen_cursor_state_blink
declare -g __stdlib_screen_cursor_state_color

stdlib_screen_cursor_init() {
  if [[ -z $__stdlib_screen_cursor_state_init ]]; then
    __stdlib_screen_cursor_state_style="default"
    __stdlib_screen_cursor_state_visible="true"
    __stdlib_screen_cursor_state_blink="false"
    __stdlib_screen_cursor_state_color="?"

    __stdlib_screen_cursor_state_init="true"
  fi
}

stdlib_screen_cursor() {
  stdlib_screen_cursor_init

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
      printf '\e[?25h'
      ;;
    "false")
      printf '\e[?25l'
      ;;
    *)
      stdlib_error_log "unknown arg to visible: $visible"
      return 1
      ;;
    esac
    __stdlib_screen_cursor_state_visible="$visible"
  fi

  if [[ -z $style && -n $blink ]]; then
    case "$blink" in
    true)
      printf '\e[?12h'
      ;;
    false)
      printf '\e[?12l'
      ;;
    esac
    __stdlib_screen_cursor_state_blink="$blink"
  elif [[ -n $style ]]; then
    blink="${blink:-"$__stdlib_screen_cursor_state_blink"}"

    case "$style" in
    block)
      if [[ "$blink" == "true" ]]; then
        printf '\e[1 q'
      else
        printf '\e[2 q'
      fi
      ;;
    underline)
      if [[ "$blink" == "true" ]]; then
        printf '\e[3 q'
      else
        printf '\e[4 q'
      fi
      ;;
    bar)
      if [[ "$blink" == "true" ]]; then
        printf '\e[5 q'
      else
        printf '\e[6 q'
      fi
      ;;
    *)
      stdlib_error_log "unknown cursor style: ${style@Q}"
      return 1
      ;;
    esac

    __stdlib_screen_cursor_state_style="$style"
  fi

  if [[ -n $color ]]; then
    printf '\x1b]12;%s\x1b\\' "$color"
    __stdlib_screen_cursor_state_color="$color"
  fi

  printf "visible=%s\nstyle=%s\nblink=%s\ncolor=%s\n" \
    "$__stdlib_screen_cursor_state_visible" \
    "$__stdlib_screen_cursor_state_style" \
    "$__stdlib_screen_cursor_state_blink" \
    "$__stdlib_screen_cursor_state_color"
}
