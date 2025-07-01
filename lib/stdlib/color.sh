#!/usr/bin/env bash

COLOR_DIM="\e[2m"
COLOR_FG_RED="\e[31m"
COLOR_FG_GREEN="\e[32m"
COLOR_FG_YELLOW="\e[33m"
COLOR_FG_BLUE="\e[34m"
COLOR_FG_MAGENTA="\e[34m"
COLOR_FG_CYAN="\e[34m"

COLOR_RESET="\e[0m"

stdlib::color() {
  while IFS= read -r line; do
    printf "\e[33m%s\e[0m\n" "$line"
  done
}

stdlib::color::rainbow() {
  if stdlib::test::is_command "lolcat"; then
    lolcat -f
  else
    while IFS= read -r line; do
      printf "\e[33m%s\e[0m\n" "$line"
    done
  fi
}
