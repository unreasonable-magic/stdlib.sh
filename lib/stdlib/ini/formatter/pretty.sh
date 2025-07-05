stdlib_ini_formatter_pretty() {
  local config
  config="$1"

  local show_comments
  show_comments="true"
  if [[ "${2:-}" == "--no-comments" ]]; then
    show_comments="false"
  fi

  local in_section
  in_section=""

  local -a comments
  comments=()

  local -i line_number
  line_number=0

  while IFS=$'\n' read -r line; do
    # Don't bother rendering empty lines
    if [[ "$line" == "" || "$line" =~ ^([ \t])$ ]]; then
      continue
    fi

    line_number+=1

    local first_char
    first_char="${line:0:1}"

    if [[ "$first_char" == "#" ]]; then
      comments+=("$line")
      continue
    fi

    local indent=""
    # Has there been a section defined in a previous line?
    if [[ "$in_section" != "" ]]; then
      # If we're rendering a new section, add a newline between
      # this one and the last one
      if [[ "$first_char" == "[" ]]; then
        echo
      else
        # Indent the key/values within the section
        indent="  "
      fi
    fi

    # Before we render a section and it's comments, should we insert a new
    # line? This one is annoying because we can't just willy nilly insert a new
    # line at the top because if this is the first section then there'll be a
    # rando new line at the top. So we'll use the 3 different checks to see if
    # we're in the right time and place for a new line
    if [[ "$in_section" == "" && "$line_number" -gt 1 && "$first_char" == "[" ]]; then
      echo
    fi

    # Before we render the line, render any comments we've seen already. The
    # reason we do this is valid, but the code looks weird. Basically we want
    # to render comments at the right indent level. So if you've written a
    # comment in a section, it shold be commented. But if a comment is the last
    # thing in a section, with a new section right after it, then that comment
    # should be fixed to the new section with no indentation, i.e:
    #
    # This:
    #
    # foo=bar
    # # comment 1
    # [section]
    # # comment 2
    # key=value
    # # comment 3
    # [section2]
    # key=value
    # # comment 4
    #
    # Becomes...
    #
    # foo = bar
    #
    # # comment 1
    # [section]
    #   # comment 2
    #   key = value
    #
    # # comment 3
    # [section2]
    #   key = value
    #
    # # comment 4
    if [[ "${#comments[@]}" -gt 0 ]]; then
      if [[ "$show_comments" == "true" ]]; then
        for c in "${comments[@]}"; do
          printf "%s\e[2m%s\e[0m\n" "$indent" "$c"
        done
      fi
      comments=()
    fi

    # Let future line renders know we're in a section
    if [[ "$first_char" == "[" ]]; then
      in_section="$line"
      IFS=' :' read id value <<< "$line"

      printf "\e[34m%s: %s\e[0m\n" "$id" "$value"
    else
      IFS=' =' read key value <<< "$line"

      printf "%s\e[39m%s\e[0m = \e[32m%s\e[0m\n" "$indent" "$key" "$value"
    fi
  done <<< "$config"
}
