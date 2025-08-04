eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/definition"

declare out=""
declare stdout=""

# Define a simple test function
simple_test() {
    echo "Hello"
    return 0
}

# Test getting full function source
stdout=$(stdlib_function_definition --declaration simple_test)
assert "$stdout" == $'simple_test() {\n    echo "Hello"\n    return 0\n}'

stdout=$(stdlib_function_definition --body simple_test)
assert "$stdout" == $'echo "Hello"\nreturn 0'

# Define a multi-line test function
multi_line_test() {
    local var="test"
    if [[ "$var" == "test" ]]; then
        echo "It works"
    fi
}

stdout=$(stdlib_function_definition --body multi_line_test)
assert "$stdout" == $'local var="test"\nif [[ "$var" == "test" ]]; then\n    echo "It works"\nfi'

declare stdout=""
declare fixture_file="$STDLIB_PATH/test/fixtures/commented_functions.bash"

# Test simple multi-line comment
stdout=$(stdlib_function_definition --comment "$fixture_file:hello_world")
assert "$stdout" == $'# This is a simple greeting function\n# It says hello to the world'

# Test formatted multi-line comment with indentation
stdout=$(stdlib_function_definition --comment "$fixture_file:formatted_function")
assert "$stdout" == $'# Multi-line comment\n#\n# with indentation\n#   - First point\n#   - Second point\n#\n# End of comment'

# Test single line comment
stdout=$(stdlib_function_definition --comment "$fixture_file:single_line")
assert "$stdout" == "# Single line comment"

# Test function with no comment
stdout=$(stdlib_function_definition --comment "$fixture_file:no_comment_function")
assert "$stdout" == ""

# Test detached comment (should fail)
stdout=$(stdlib_function_definition --comment "$fixture_file:detached_comment")
assert "$stdout" == ""

# Test comment with blank lines
stdout=$(stdlib_function_definition --comment "$fixture_file:blank_lines_in_comment")
assert "$stdout" == $'# Comment with blank lines in between\n#\n# Still part of the same comment block'

# Test first of two consecutive functions
stdout=$(stdlib_function_definition --comment "$fixture_file:first_func")
assert "$stdout" == "# First function comment"

# Test second of two consecutive functions
stdout=$(stdlib_function_definition --comment "$fixture_file:second_func")
assert "$stdout" == "# Second function comment"

# Test non-existent function
stdlib_function_definition --comment "$fixture_file:non_existent"
assert "$?" == "1"

# Test invalid function name
stdlib_function_definition --comment "$fixture_file:."
assert "$?" == "1"

# Test non-existent file
stdlib_function_definition --comment "/non/existent/file.bash:some_func"
assert "$?" == "1"
