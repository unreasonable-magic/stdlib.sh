stdlib::assert () {
  # $(caller) returns the line number and the file path
  local -r caller_info="$(caller)"
  local -r -i line_number="${caller_info%% *}"
  local -r file_path="${caller_info#* }"

  # Show a peak of the file that ran the assertion
  # TODO: extract this into a stdlib function
  bat --theme="jellybeans" -n -r "$((line_number - 1)):$line_number" "$file_path"

  # Run the test
  if eval "$*"; then
    echo "     ✅ ${*}"
  else
    echo "     ❌ ${*}"
    exit 1
  fi
}
