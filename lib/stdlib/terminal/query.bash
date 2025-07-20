stdlib_import "string/escape"
stdlib_import "terminal/reader"
stdlib_import "terminal/reader/readkey"

stdlib_terminal_query() {
  local input="$1"

  local query=""
  case "$input" in
  cursor)
    query="\e[6n"
    ;;
  #device_status_report)
  #  query="\e[5n"
  #  ;;
  # primary_device_attributes)
  #   query="\e[c"
  #   ;;
  # secondary_device_attributes)
  #   query="\e[>c"
  #   ;;
  # tertiary_device_attributes)
  #   query="\e[=c"
  #   ;;
  window_size_pixels)
    query="\e[14t"
    ;;
  window_size_characters)
    query="\e[18t"
    ;;
  terminal_size_characters)
    query="\e[18t"
    ;;
  terminal_size_pixels)
    query="\e[19t"
    ;;
  terminal_version)
    query="\e[>q"
    ;;
  window_title)
    query="\e[>q"
    ;;

  esac

  stdlib_terminal_reader_start

  # Send query
  printf "%b" "$query" >&2

  stdlib_terminal_reader_readkey
}
