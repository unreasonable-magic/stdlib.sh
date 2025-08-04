eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/comment"

declare out=""
declare stdout=""
declare fixture_file="$STDLIB_PATH/test/fixtures/commented_functions.bash"

# Test simple multi-line comment
stdout=$(stdlib_function_comment "$fixture_file" "hello_world")
assert "$stdout" == $'This is a simple greeting function\nIt says hello to the world'

# Test formatted multi-line comment with indentation
stdout=$(stdlib_function_comment "$fixture_file" "formatted_function")
assert "$stdout" == $'Multi-line comment\n\nwith indentation\n  - First point\n  - Second point\n\nEnd of comment'

# Test single line comment
stdout=$(stdlib_function_comment "$fixture_file" "single_line")
assert "$stdout" == "Single line comment"

# Test function with no comment
stdlib_function_comment "$fixture_file" "no_comment_function"
assert "$?" == "1"

# Test detached comment (should fail)
stdlib_function_comment "$fixture_file" "detached_comment"
assert "$?" == "1"

# Test comment with blank lines
stdout=$(stdlib_function_comment "$fixture_file" "blank_lines_in_comment")
assert "$stdout" == $'Comment with blank lines in between\n\nStill part of the same comment block'

# Test first of two consecutive functions
stdout=$(stdlib_function_comment "$fixture_file" "first_func")
assert "$stdout" == "First function comment"

# Test second of two consecutive functions
stdout=$(stdlib_function_comment "$fixture_file" "second_func")
assert "$stdout" == "Second function comment"

# Test non-existent function
stdlib_function_comment "$fixture_file" "non_existent"
assert "$?" == "1"

# Test invalid function name
stdlib_function_comment "$fixture_file" "invalid-name"
assert "$?" == "1"

# Test non-existent file
stdlib_function_comment "/non/existent/file.bash" "some_func"
assert "$?" == "1"
