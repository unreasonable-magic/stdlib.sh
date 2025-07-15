stdlib_import "error/stacktrace"
stdlib_import "error/log"

# Prints an error and returns 1
stdlib_error_warning() {
  stdlib_error_log "$@"
  return 1
}

# Prints an error to stderr then exits
stdlib_error_fatal() {
  stdlib_error_log "$@"
  stdlib_error_stacktrace
  exit 1
}
