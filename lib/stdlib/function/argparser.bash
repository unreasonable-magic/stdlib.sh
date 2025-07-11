stdlib_function_argparser() {
  case "$1" in
    error/invalid_arg)
      stdlib_error_log "${FUNCNAME[1]} invalid arg: $2"
      ;;
    *)
      stdlib_error_fatal "stdlib_function_argparser: unknown option $1"
      ;;
  esac
}
