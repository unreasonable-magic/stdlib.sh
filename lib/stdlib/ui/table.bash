stdlib_import "string/count"
stdlib_import "ui/table/renderer"

enable dsv

#           0=left 1=joiner 2=repeater 3=right
# top:      ┌┬─┐
# divider:  ├┼─┤
# row:      ││ │
# bottom:   └┴─┘
#
STDLIB_TABLE_TOP=0
STDLIB_TABLE_DIVIDER=4
STDLIB_TABLE_ROW=8
STDLIB_TABLE_BOTTOM=12

stdlib_ui_table() {
  local lines=() widths=() column_count=0

  local -a renderer_args=()
  local input_arg="auto"

  while [ $# -gt 0 ]; do
    case "$1" in
      --renderer-arg)
        renderer_args+=("$2")
        shift 2
        ;;
      --input)
        input_arg="$2"
        shift 2
        ;;
      *)
        stdlib_argparser error/invalid_arg "$@"
        return 1
        ;;
    esac
  done

  # Read input
  if [[ $# -eq 0 ]]; then
    mapfile -t lines
  else
    mapfile -t lines <"$1"
  fi

  # No lines? Nothing to do!
  local -i lines_count=${#lines[@]}
  [[ $lines_count -eq 0 ]] && return

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
  column_count=${#first_row[@]}

  # Initialize widths array
  for ((i = 0; i < column_count; i++)); do
    widths[i]=0
  done

  # Calculate column widths
  for line in "${lines[@]}"; do
    dsv -a row -d "$delim" "${line}"
    for ((i = 0; i < column_count && i < ${#row[@]}; i++)); do
      if [[ ${#row[i]} -gt ${widths[i]} ]]; then
        widths[i]=${#row[i]}
      fi
    done
  done

  local index=0

  for line in "${lines[@]}"; do
    # if [[ $index -eq 0 ]]; then
    #   stdlib_ui_table_renderer \
    #     ${renderer_args[*]} \
    #     --column-widths-array-ref widths \
    #     --line-type "$STDLIB_TABLE_TOP"
    # fi

    dsv -a col -d "$delim" "${line}"

    stdlib_ui_table_renderer \
      ${renderer_args[*]} \
      --column-widths-array-ref widths \
      --column-data-array-ref col \
      --row-index "$index" \
      --rows-index "$index" \
      --line-type "$STDLIB_TABLE_ROW"

    # if [[ "$first_row_is_header" == "true" && $index -eq 0 ]]; then
    #   stdlib_ui_table_renderer \
    #     ${renderer_args[*]} \
    #     --column-widths-array-ref widths \
    #     --line-type "$STDLIB_TABLE_DIVIDER"
    # fi

    index=$((index + 1))

    # if [[ $index -eq $lines_count ]]; then
    #   stdlib_ui_table_renderer \
    #     ${renderer_args[*]} \
    #     --column-widths-array-ref widths \
    #     --line-type "$STDLIB_TABLE_BOTTOM"
    # fi
  done
}
