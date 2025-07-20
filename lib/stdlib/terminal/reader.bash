stdlib_import "trapstack"

stdlib_terminal_reader_start() {
  # If we've already started, don't do anything
  if [[ "$__stdlib_terminal_reader_prev" ]]; then
    return
  fi

  # Get a copy of current stty before we override it
  declare -g __stdlib_terminal_reader_prev
  __stdlib_terminal_reader_prev="$(stty -g)"

  # Put terminal in raw mode: no echo, no line buffering, no Ctrl+C
  stty -echo -icanon intr ''

  # Make sure what we've done is restored at the end of the program
  stdlib_trapstack_add stdlib_terminal_reader_finish
}

stdlib_terminal_reader_finish() {
  # Restore tty to what it was before
  if [[ -z $__stdlib_terminal_reader_prev ]]; then
    stty "$__stdlib_terminal_reader_prev"
    unset __stdlib_terminal_reader_prev
  fi

  stdlib_trapstack_remove __stdlib_terminal_reader_init_cleanup
}
