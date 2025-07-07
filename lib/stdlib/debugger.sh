# shellcheck disable=SC2059

stdlib_import "color"
stdlib_import "ui/input"
stdlib_import "file/dirname"

STDLIB_DEBUGGER_HISTORY="$XDG_STATE_HOME/stdlib.sh/debugger/history"
STDLIB_DEBUGGER_ACTIVE="false"

stdlib_debugger() {
  if ! mkdir -p "$(stdlib_file_dirname "$STDLIB_DEBUGGER_HISTORY")"; then
    stdlib_error_warning "can't make history file for debugger"
  else
    touch "$STDLIB_DEBUGGER_HISTORY"
  fi

  printf "${COLOR_DIM}#${COLOR_RESET} ${COLOR_FG_BLUE}stdlib_debugger${COLOR_RESET}\n"
  printf "${COLOR_DIM}# Press CTRL-D to continue with $0${COLOR_RESET}\n"

  export STDLIB_DEBUGGER_ACTIVE="true"

  while true; do
    local input
    if input="$(stdlib_ui_input --history "$STDLIB_DEBUGGER_HISTORY" --prompt "▲ ")"; then
      if [[ "$input" != "" ]]; then
        # Save the input to the history file if it exists
        if [[ -e "$STDLIB_DEBUGGER_HISTORY" ]]; then
          echo "$input" >>"$STDLIB_DEBUGGER_HISTORY"
        fi
      fi

      # If a variable has been entered, let's be nice and just log it for them
      if [[ "${input:0:1}" == "$" ]]; then
        stdlib_debugger_vardump "$input"
      else
        eval "$input"
      fi
    else
      printf "\n"
      break
    fi
  done

  STDLIB_DEBUGGER_ACTIVE="false"
}

stdlib_debugger_vardump() {
  local str_f="\e[32m%s\e[0m"
  local bracket_f="\e[34m%s\e[0m"
  local comment_f="\e[30m%s\e[0m"

  local varname="$1"
  [[ "$varname" == "$"* ]] && varname="${varname:1}"

  declare -n varvalue="$varname"

  local declaration
  if declaration="$(declare -p "$varname" 2>/dev/null)"; then
    if [[ "$declaration" == "declare -a"* ]]; then
      declare -i index=0

      printf "(\n"
      for item in "${varvalue[@]}"; do
        printf "  ${str_f} ${comment_f}\n" \
          "${item@Q}" \
          "# $index"
        index+=1
      done
      printf ")\n"
    elif [[ "$declaration" == "declare -A"* ]]; then
      printf "(\n"
      for key in "${!varvalue[@]}"; do
        printf "  ${bracket_f}${str_f}${bracket_f}=${str_f}\n" \
          "[" \
          "${key@Q}" \
          "]" \
          "${varvalue[$key]@Q}"
      done
      printf ")\n"
    else
      printf "${str_f}\n" "${varvalue@Q}"
    fi
  else
    echo "$varname is not declared"
  fi
}
