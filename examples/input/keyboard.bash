#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "input/keyboard"

buffer=""

my_func() {
  # local event="$1"
  local key="$2"
  local mod1="$3"

  case "$key" in
  Enter)
    printf "\n"
    ;;
  ArrowUp)
    printf $'\e[A'
    ;;
  ArrowRight)
    printf $'\e[C'
    ;;
  ArrowDown)
    printf $'\e[B'
    ;;
  ArrowLeft)
    printf $'\e[D'
    ;;
  Backspace)
    if [[ "$buffer" != "" ]]; then
      buffer="${buffer:0:-1}"
      printf '\b \b'
    fi
    ;;
  *)
    if [[ "$key" == "d" && "$mod1" == "Control" ]]; then
      return 1
    fi
    buffer+="$key"
    printf "%s" "$key"
    ;;
  esac
  return 0
}

printf "ctrl-d to exit\n\n"

buffer=""

stdlib_input_keyboard_capture my_func

echo -e "\n\nentered: $buffer"
