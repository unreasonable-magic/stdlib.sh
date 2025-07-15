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
