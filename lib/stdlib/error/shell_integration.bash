command_not_found_handle() {
  printf "command not found: %s\n\n" "$*" >&2

  stdlib_error_stacktrace

  # Don't do magical kill the process gear if we're in a debugger (we should be
  # allowed to make mistakes in that context without killing the program)
  if [[ "$STDLIB_DEBUGGER_ACTIVE" != "true" ]]; then
    # This is "plan b" for if the bottom approaches don't work to stopping the
    # current script.
    {
      sleep 3
      echo "took too long to exit, force killing..." >&2
      kill -9 "$$" &>/dev/null
    } &
    local plan_b_pid=$?

    # `exit` will only work if errexit is set. So in the event it's not enabled,
    # we'll go hardcore and just use a classic unix kill to stop the script,
    # instead of the more cleaner approach.
    if shopt -o -p errexit &>/dev/null; then
      exit 1
    else
      # kill -9 "$$"
      kill $plan_b_pid &>/dev/null
      kill $$ &>/dev/null
    fi
  fi
}
