stdlib_import "screen/cursor"
stdlib_import "input/keyboard"

stdlib_ui_input() {
  local prompt=""
  local history_path=""

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
    --prompt)
      prompt="$1"
      shift
      ;;
    --history)
      history_path="$1"
      shift
      ;;
    esac
  done

  local value=""
  local draft=""
  declare -i cursor="${#value}"

  local -i history_index=0

  stdlib_screen_cursor style=bar blink=true >/dev/null

  __stdlib_ui_input_render() {
    printf "\e[2K\r%s%s\e[%dG" "$prompt" "$value" "$((cursor + ${#prompt} + 1))" >/dev/tty
  }

  __stdlib_ui_input_callback() {
    local key="$2"
    local mod1="$3"

    case "$key" in
    Enter)
      printf "\n" >/dev/tty
      return 1
      ;;

    ArrowUp)
      if [[ -e "$history_path" ]]; then
        if [[ $history_index -eq 0 ]]; then
          draft="${value}"
        fi
        history_index+=1
        text="$(tail -n "$history_index" "$history_path" | head -n 1)"
        value="$text"
        cursor="${#value}"

        __stdlib_ui_input_render
      fi
      return
      ;;

    ArrowRight)
      if [[ $cursor -lt ${#value} ]]; then
        printf $'\e[C' >/dev/tty
        cursor=$((cursor + 1))
      fi
      ;;

    ArrowDown)
      if [[ -e "$history_path" ]]; then
        history_index=$((history_index - 1))
        text="$(tail -n "$history_index" "$history_path" | head -n 1)"

        if [[ $history_index -eq 0 ]]; then
          value="$draft"
          cursor="${#value}"
        else
          value="$text"
          cursor="${#value}"
        fi

        __stdlib_ui_input_render
      fi
      return
      ;;

    ArrowLeft)
      if [[ $cursor -gt 0 ]]; then
        printf $'\e[D' >/dev/tty
        cursor=$((cursor - 1))
      fi
      ;;

    Tab)
      return
      ;;

    Backspace)
      if [[ "$value" == "" ]]; then
        return
      fi

      value="${value:0:$((cursor - 1))}${value:$((cursor))}"
      cursor=$((cursor - 1))

      __stdlib_ui_input_render
      ;;

    *)
      if [[ "$key" == "c" && "$mod1" == "Control" ]]; then
        value=""
        cursor=0
        return 1
      else
        value="${value:0:$((cursor))}${key}${value:$((cursor))}"
        cursor+=${#key}
      fi

      __stdlib_ui_input_render
      ;;
    esac

    return 0
  }

  __stdlib_ui_input_render

  stdlib_input_keyboard_capture __stdlib_ui_input_callback

  echo "$value"
}
