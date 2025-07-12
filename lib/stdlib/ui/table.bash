stdlib_import "string/count"
stdlib_import "string/repeat"
stdlib_import "string/pad"
stdlib_import "array/join"

enable dsv

stdlib_ui_table() {
  local lines=() widths=() cols=0

  local input_arg="auto"
  if [[ "$1" == "--input" ]]; then
    input_arg="$2"
    shift 2
  fi

  local -r unicode_thick_border_template="
  ┏━┳━┓
  ┃ ┃ ┃
  ┣━╋━┫
  ┃ ┃ ┃
  ┣━╋━┫
  ┃ ┃ ┃
  ┣━╋━┫
  ┃ ┃ ┃
  ┗━┻━┛
  "

  local -r ascii_border_template="
  +-+-+
  | | |
  +-+-+
  | | |
  +-+-+
  | | |
  +-+-+
  | | |
  +-+-+
  "

  # Read input
  if [[ $# -eq 0 ]]; then
    mapfile -t lines
  else
    mapfile -t lines <"$1"
  fi

  # No lines? Nothing to do!
  [[ ${#lines[@]} -eq 0 ]] && return

  # Peek at the input arg to see if we've got a header in the data
  local first_row_is_header=false
  if [[ "$input_arg" == *"+header" ]]; then
    first_row_is_header=true
    input_arg="${input_arg/+header/}"
    input_arg="${input_arg:-auto}"
  fi

  local delim
  case "$input_arg" in
  csv)
    delim=","
    ;;
  tsv)
    delim=$'\t'
    ;;
  auto)
    # Dunno if this is a good idea, but seems to work. If there's more tabs than
    # commas in the first row, then it's probably a tsv.
    local -i tab_count=${ stdlib_string_count "${lines[0]}" '$\t'; }
    local -i comma_count=${ stdlib_string_count "${lines[0]}" ','; }
    if [[ $tab_count -gt $comma_count ]]; then
      delim=$'\t'
    else
      delim=","
    fi
    ;;
  '')
    stdlib_argparser error/missing_arg "--input"
    return 1
    ;;
  *)
    stdlib_argparser error/invalid_arg "$input_arg is not a valid input arg"
    return 1
    ;;
  esac

  # Split first line to get column count
  local -a first_row
  dsv -a first_row -d "$delim" "${lines[0]}"
  cols=${#first_row[@]}

  # Initialize widths array
  for ((i = 0; i < cols; i++)); do
    widths[i]=0
  done

  # Calculate column widths
  for line in "${lines[@]}"; do
    dsv -a row -d "$delim" "${line}"
    for ((i = 0; i < cols && i < ${#row[@]}; i++)); do
      if [[ ${#row[i]} -gt ${widths[i]} ]]; then
        widths[i]=${#row[i]}
      fi
    done
  done

  # Build border
  local h_divider="+"
  for ((i = 0; i < cols; i++)); do
    h_divider+="${ stdlib_string_repeat "-" $((widths[i] + 2)); }"
    h_divider+="+"
  done

  # Print table
  printf "%s\n" "$h_divider"

  local start_line=0

  if [[ "$first_row_is_header" == "true" ]]; then
    # Print header
    dsv -a header -d "$delim" "${lines[0]}"

    local buffer=()
    for ((i = 0; i < cols; i++)); do
      # printf "%s | " "${ stdlib_string_pad --width "${widths[i]}" "${header[i]}"; }"
      buffer+=("${ stdlib_string_pad --width "${widths[i]}" "${header[i]}"; }")
    done

    printf "| %s |\n" "${ stdlib_array_join -d " | " -a buffer; }"
    printf "%s\n" "$h_divider"

    start_line=$(($start_line + 1))
  fi

  # Print data rows
  for ((r = $start_line; r < ${#lines[@]}; r++)); do
    dsv -a row -d "$delim" "${lines[r]}"

    local buffer=()
    for ((i = 0; i < cols; i++)); do
      buffer+=("${ stdlib_string_pad --width "${widths[i]}" "${row[i]:-}"; }")
    done

    printf "| %s |\n" "${ stdlib_array_join -d " | " -a buffer; }"
  done

  printf "%s\n" "$h_divider"
}
