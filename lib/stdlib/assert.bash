_assert_show_context() {
  # $(caller) returns the line number and the file path
  local -a caller_info
  IFS=' ' read  -r -a caller_info <<< "${ caller 1; }"
  local -r -i line_number="${caller_info[0]}"
  local -r file_path="${caller_info[2]}"

  # Show a peak of the file that ran the assertion
  bat --theme="jellybeans" -n -r "$((line_number - 1)):$line_number" "$file_path"
}

assert() {
  _assert_show_context

  # Run the test
  local left="$1"
  local operation="$2"
  local right="$3"

  local passed="true"
  case "$operation" in
  ==)
    [ "$left" == "$right" ] || passed="false"
    ;;
  =~)
    [[ "$left" =~ $right ]] || passed="false"
    ;;
  *)
    echo "unknown test operator: $operation"
    ;;
  esac

  if [ "$passed" == "true" ]; then
    echo "     ✅ ${left@Q} ${operation} ${right@Q}"
  else
    echo "     ❌ ${left@Q} ${operation} ${right@Q}"
    exit 1
  fi
}

assert_success() {
  _assert_show_context

  # Run the command and check exit status
  "$@"
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "     ✅ $* succeeded"
  else
    echo "     ❌ $* failed with exit code $exit_code"
    exit 1
  fi
}

assert_failure() {
  _assert_show_context

  # Run the command and check exit status
  "$@"
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "     ✅ $* failed as expected"
  else
    echo "     ❌ $* succeeded but was expected to fail"
    exit 1
  fi
}
