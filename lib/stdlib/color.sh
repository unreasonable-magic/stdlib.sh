stdlib_import "test"

export COLOR_DIM="\e[2m"
export COLOR_FG_RED="\e[31m"
export COLOR_FG_GREEN="\e[32m"
export COLOR_FG_YELLOW="\e[33m"
export COLOR_FG_BLUE="\e[34m"
export COLOR_FG_MAGENTA="\e[34m"
export COLOR_FG_CYAN="\e[34m"
export COLOR_RESET="\e[0m"

stdlib_color() {
  while IFS= read -r line; do
    printf "\e[33m%s\e[0m\n" "$line"
  done
}

stdlib_color_rainbow() {
  if stdlib_test command/exists "lolcat"; then
    lolcat -f
  else
    while IFS= read -r line; do
      printf "\e[33m%s\e[0m\n" "$line"
    done
  fi
}
