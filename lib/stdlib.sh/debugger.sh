#!/usr/bin/env bash

stdlib::debugger() {
  printf "${COLOR_DIM}#${COLOR_RESET} ${COLOR_FG_BLUE}stdlib::debugger${COLOR_RESET}\n"
  printf "${COLOR_DIM}# Press CTRL-D to continue with $0${COLOR_RESET}\n"

  while true; do
    printf "▲ "
    if read -r input 2> /dev/null; then
      eval "$input"
    else
      printf "\n"
      break
    fi
  done
}
