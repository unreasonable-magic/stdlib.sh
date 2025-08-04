eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/code"

declare out=""
declare stdout=""

# Define a simple test function
simple_test() {
    echo "Hello"
    return 0
}

# Test getting full function source
stdout=$(stdlib_function_code simple_test)
assert "$stdout" == $'simple_test () \n{ \n    echo "Hello";\n    return 0\n}'

# Test --no-declare option
stdout=$(stdlib_function_code --no-declare simple_test)
assert "$stdout" == $'echo "Hello";\nreturn 0'

# Define a multi-line test function
multi_line_test() {
    local var="test"
    if [[ "$var" == "test" ]]; then
        echo "It works"
    fi
}

# Test multi-line function with --no-declare
stdout=$(stdlib_function_code --no-declare multi_line_test)
assert "$stdout" == $'local var="test";\nif [[ "$var" == "test" ]]; then\n    echo "It works";\nfi'
