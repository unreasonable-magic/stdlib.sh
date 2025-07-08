#!/usr/bin/env bash

eval "$(stdlib shellenv)"

timeline() {
  while IFS= read -r -n1 char; do
    if [[ "$char" == $'\e' ]]; then
      local sequence=""

      if IFS= read -r -s -n11 -t 0.01 c2; then
        if [[ "$c2" == "[stdlib:tl;" ]]; then
          IFS= read -r -s cmd
          printf "• %s\n┃ " "$cmd"
        else
          printf "%s" "${c2@Q}"
        fi
      fi
    else
      printf "%s" "$char"
    fi
  done
}

timeline_start() {
  printf "\e[stdlib:tl;# %s\n" "$1"
}

{
  timeline_start "something"
  sleep 3
  echo "1"
  sleep 1
  echo "2"
  sleep 1
  echo "something 1234"
} | timeline
