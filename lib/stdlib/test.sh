stdlib_test() {
  case "$1" in
  # Files
  file/exists)
    [ -e "$2" ]
    ;;
  file/is_missing)
    [ ! -e "$2" ]
    ;;
  file/is_empty)
    [ ! -s "$2" ]
    ;;
  file/has_data)
    [ -s "$2" ]
    ;;
  file/has_new_data)
    [ -N "$2" ]
    ;;
  # file/is_block_device)
  #   [ -b "$2" ]
  #   ;;
  # file/is_character_special_file)
  #   [ -c "$2" ]
  #   ;;
  # file/has_set_group_id_bit)
  #   [ -g "$2" ]
  #   ;;
  # file/has_sticky_bit)
  #   [ -k "$2" ]
  #   ;;
  # file/has_set_user_id_bit)
  #   [ -k "$2" ]
  #   ;;
  file/is_dir)
    [ -d "$2" ]
    ;;
  file/is_regular)
    [ -f "$2" ]
    ;;
  file/is_symbolic_link)
    # [ -L "$2" ]
    [ -h "$2" ]
    ;;
  file/is_fifo)
    [ -p "$2" ]
    ;;
  file/is_socket)
    [ -S "$2" ]
    ;;
  file/is_readable)
    [ -r "$2" ]
    ;;
  file/is_writable)
    [ -w "$2" ]
    ;;
  file/is_executable)
    [ -x "$2" ]
    ;;
  file/is_tty)
    [ -t "$2" ]
    ;;
  # file/is_newer_than)
  #   [ "$2" -ef "$3" ]
  #   ;;
  # file/is_older_than)
  #   [ "$2" -ot "$3" ]
  #   ;;
  # file/owned_by_group)
  #   [ -G "$2" ]
  #   ;;
  # file/owned_by_user)
  #   [ -O "$2" ]
  #   ;;

  # Variables

  var/is_set)
    [ -v "$2" ]
    ;;
  var/is_nameref)
    [ -R "$2" ]
    ;;

  # Commands

  command/exists)
    command -v "$2" &>/dev/null
    ;;

  # Strings

  string/is_empty)
    [ -z "$2" ]
    ;;
  string/is_present)
    [ -n "$2" ]
    ;;

  # Shell

  shellopt/is_enabled)
    [ -o "$2" ]
    ;;

  # Error handling

  '')
    stdlib_argparser error/length_mismatch 1
    return 1
    ;;
  *)
    stdlib_argparser error/invalid_arg "$@"
    return 1
    ;;
  esac
}
