assert() {
  # $(caller) returns the line number and the file path
  local -r caller_info="$(caller)"
  local -r -i line_number="${caller_info%% *}"
  local -r file_path="${caller_info#* }"

  # Show a peak of the file that ran the assertion
  # TODO: extract this into a stdlib function
  bat --theme="jellybeans" -n -r "$((line_number - 1)):$line_number" "$file_path"

  # Run the test
  local left="$1"
  local operation="$2"
  local right="$3"

  local passed="true"
  case "$operation" in
  ==)
    [ "$left" == "$right" ] || passed="false"
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
