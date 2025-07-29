stdlib_import "color/type/xterm"

STDLIB_COLOR_ANSI_REGEX="^[[:space:]]*(([0-9]);)?([0-9]+)(;([0-9]+);([0-9]+))?[[:space:]]*$"

stdlib_color_type_ansi_format() {
  # Special handling of xterm colors. Usually we'd just return codes formatted
  # in rgb styled (prefixed with a 2):
  #
  #     2;229;0;0 # red
  #
  # But if we've been given an xterm color, let's use the number value from
  # that, i.e:
  #
  #     5:1 # red
  #
  if [[ "${COLOR[0]}" == "xterm" ]]; then
    stdlib_color_type_xterm_format --ansi
  elif [[ "${COLOR[0]}" == "ansi" && "${COLOR[4]}" != "" ]]; then
    # If we're just re-printing an ansi code that we've parsed ourselves, and
    # we've saved a version during parsing that's safe to print, let's just do
    # that
    printf "${COLOR[4]}\n"
  else
    printf "2;%s;%s;%s\n" "${COLOR[1]}" "${COLOR[2]}" "${COLOR[3]}"
  fi
}

stdlib_color_type_ansi_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_ANSI_REGEX ]]; then
    # Either look for a 2 at the start (to denote an rgb ansi value), or see if
    # we have a value blue
    if [[ "${BASH_REMATCH[2]}" == "2" || "${BASH_REMATCH[6]}" != "" ]]; then
      declare -g -a COLOR=(
        "ansi"
        "${BASH_REMATCH[3]}"
        "${BASH_REMATCH[5]}"
        "${BASH_REMATCH[6]}"
      )
      return 0
    elif [[ "${BASH_REMATCH[2]}" == "5" ]]; then
      # "5" means we've been given an xterm color, let's go find the name of it
      local xterm_name
      xterm_name="${ stdlib_color_type_xterm_data find-key-by-value "${BASH_REMATCH[3]}"; }"
      if [[ ! $? -eq 0 ]]; then
        return 1
      fi

      # Now that we've got the name, let's parse it as an xterm color
      if ! stdlib_color_type_xterm_parse "xterm:${xterm_name}"; then
        return 1
      fi

      # Huzzah! If we've gotten this far, then we've gotten our color, let's
      # claim the type and finish up
      declare -g -a COLOR=(
        "ansi"
        "${COLOR[1]}"
        "${COLOR[2]}"
        "${COLOR[3]}"
        "$1" # Save the input for easier formatting later
      )

      return 0
    fi
  fi

  return 1
}
