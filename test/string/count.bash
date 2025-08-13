eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "capture"
stdlib_import "string/count"
stdlib_import "function/list"
stdlib_import "function/location"
stdlib_import "ui/timeline"

test_stdlib_string_count_basic() {
    stdlib_capture stdlib_string_count "foo" "bar"
    assert "$STDOUT" == "0"
    
    stdlib_capture stdlib_string_count "foo" "bar"
    assert "$STDOUT" == "0"
    
    stdlib_capture stdlib_string_count "foo" "foo"
    assert "$STDOUT" == "1"
    
    stdlib_capture stdlib_string_count "foo foo foo" "foo"
    assert "$STDOUT" == "3"
}

test_stdlib_string_count_special_characters() {
    stdlib_capture stdlib_string_count "*bold* is a style" "*"
    assert "$STDOUT" == "2"
}

test_stdlib_string_count_tabs() {
    stdlib_capture stdlib_string_count $'works \t with \t tabs' $'\t'
    assert "$STDOUT" == "2"
    
    stdlib_capture stdlib_string_count $'ignores \\t escaped \\t tabs' $'\t'
    assert "$STDOUT" == "0"
}

test_stdlib_string_count_newlines() {
    stdlib_capture stdlib_string_count $'works \n with \n new \n lines' $'\n'
    assert "$STDOUT" == "3"
    
    stdlib_capture stdlib_string_count $'ignores \\n escaped \\n new \\n lines' $'\n'
    assert "$STDOUT" == "0"
}

test_stdlib_string_count_spaces() {
    stdlib_capture stdlib_string_count "     " " "
    assert "$STDOUT" == "5"
}

# Get list of test functions
test_functions=($(stdlib_function_list "test_*"))
test_count=${#test_functions[@]}

# Run tests with timeline UI
{
  echo "# Tests [0/$test_count]"
  
  # Send all test subheaders first
  index=1
  for location in "${test_functions[@]}"; do
    func="${ stdlib_function_location --function-name "$location"; }"
    echo "## $func [$index]"
    ((index++))
  done
  
  # Run tests and update timeline
  index=1
  exit_code=0
  for location in "${test_functions[@]}"; do
    func="${ stdlib_function_location --function-name "$location"; }"
    if "$func" >/dev/null 2>&1; then
      echo "## $func [$index=success]"
    else
      echo "## $func [$index=fail]"
      exit_code=1
    fi
    ((index++))
  done
  
  # Give time for UI to update
  sleep 0.1
} | stdlib_ui_timeline

# Exit with appropriate code
exit ${exit_code}
