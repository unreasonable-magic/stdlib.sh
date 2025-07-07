#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "input/keyboard"
stdlib_import "screen/cursor"

stdlib_screen_cursor style=bar blink=true >/dev/null

buffer="default value"
declare -i cursor=${#buffer}

my_func() {
  # local event="$1"
  local key="$2"
  local mod1="$3"

  case "$key" in
  Enter)
    return 1
    ;;
  ArrowUp)
    return
    ;;
  ArrowRight)
    if [[ $cursor -lt ${#buffer} ]]; then
      printf $'\e[C'
      cursor=$((cursor + 1))
    fi
    ;;
  ArrowDown)
    return
    ;;
  ArrowLeft)
    if [[ $cursor -gt 0 ]]; then
      printf $'\e[D'
      cursor=$((cursor - 1))
    fi
    ;;
  Tab)
    return
    ;;
  Backspace)
    if [[ "$buffer" != "" ]]; then
      buffer="${buffer:0:$((cursor - 1))}${buffer:$((cursor))}"
      cursor=$((cursor - 1))

      printf "\e[2K\r> %s\e[%dG" "$buffer" "$((cursor + 3))"
    fi
    ;;
  *)
    if [[ "$key" == "d" && "$mod1" == "Control" ]]; then
      return 1
    fi
    if [[ "$key" != "" ]]; then
      buffer="${buffer:0:$((cursor))}${key}${buffer:$((cursor))}"
      cursor+=1
    fi
    printf "\e[2K\r> %s\e[%dG" "$buffer" "$((cursor + 3))"
    ;;
  esac
  echo "$cursor" >>"log.txt"
  return 0
}

my_func

stdlib_input_keyboard_capture my_func

echo -e "\n\nentered: $buffer"
