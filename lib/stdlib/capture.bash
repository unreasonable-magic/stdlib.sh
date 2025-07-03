# https://stackoverflow.com/questions/11027679/capture-stdout-and-stderr-into-different-variables
capture() {
  local stdout_var="__stdout"
  local stderr_var="__stderr"

  for arg; do
    case "$arg" in
    --stdout-var)
      stdout_var="$2"
      shift 2
      ;;
    --stderr-var)
      stderr_var="$2"
      shift 2
      ;;
    esac
  done

  # IFS=$'\n' read -r -d '' "${stdout_var}"
  # IFS=$'\n' read -r -d '' "${stdout_var}"

  # Create temporary files for capture
  local -r temp_stdout="$(mktemp)"
  local -r temp_stderr="$(mktemp)"
  local -r temp_exit="$(mktemp)"

  # Execute command with output redirection
  {
    "$@"
    echo $? >"$temp_exit"
  } >"$temp_stdout" 2>"$temp_stderr"

  local exit_code
  exit_code="$(cat "$temp_exit")"

  local stdout_content
  stdout_content="$(cat "$temp_stdout")"

  local stderr_content
  stderr_content="$(cat "$temp_stderr")"

  # Clean up temporary files
  # rm -f "$temp_stdout" "$temp_stderr" "$temp_exit"

  # Set output variables
  printf -v "$stdout_var" '%s' "$stdout_content"
  printf -v "$stderr_var" '%s' "$stderr_content"

  # Return the original exit code
  return "$exit_code"
}
