stdlib_import "color"

stdlib_debugger() {
  printf "${COLOR_DIM}#${COLOR_RESET} ${COLOR_FG_BLUE}stdlib_debugger${COLOR_RESET}\n"
  printf "${COLOR_DIM}# Press CTRL-D to continue with $0${COLOR_RESET}\n"

  while true; do
    printf "▲ "
    if read -r input 2>/dev/null; then
      # If a variable has been entered, let's be nice and just log it for them
      if [[ "${input:0:1}" == "$" ]]; then
        eval "echo $input"
      else
        eval "$input"
      fi
    else
      printf "\n"
      break
    fi
  done
}
