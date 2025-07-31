stdlib_argparser() {
  case "$1" in
  error/invalid_arg)
    stdlib_error_log "${FUNCNAME[1]} invalid arg: $2"
    ;;
  error/missing_arg)
    stdlib_error_log "${FUNCNAME[1]} missing arg: $2"
    ;;
  error/length_mismatch)
    stdlib_error_log "${FUNCNAME[1]} wrong number of arguments (expected $2)"
    ;;
  *)
    stdlib_error_fatal "not a valid option for stdlib_argparser '$1'"
    ;;
  esac
}

stdlib_argparser_parse() {
  while [[ $# -gt 0 ]]; do
    local arg="$1"
    shift 1

    if [[ "$arg" == "--" ]]; then
      break
    fi
  done

  # If we've not been given any params, and there's something on stdin we should
  # read, let's set the params so we'll read them all in
  if [[ $# -eq 0 && ! -t 0 ]]; then
    set -- ""
  fi

  # Normalize the params into a newline seperated string, replacing "-" with
  # reading a single line from stdin, and replacing "" with reading everything
  # in from stdin. The reason that we use new lines is that it makes for easier
  # parsing with kv and mapfile later on.
  local input

  while [[ $# -gt 0 ]]; do
    local arg="$1"
    shift 1

    if [[ "$arg" == "-" ]]; then
      read -r arg
    elif [[ "$arg" == "" ]]; then
      IFS= read -r -d $'\0' arg
    fi

    input+="$arg"

    if [[ $# -gt 0 ]]; then
      input+=$'\n'
    fi
  done

  REPLY="$input"
}
