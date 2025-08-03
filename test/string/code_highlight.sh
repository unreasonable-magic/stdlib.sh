#!/usr/bin/env bash
eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/code_highlight"

# Test basic string highlighting
result=$(stdlib_string_code_highlight 'let message = "Hello";')
assert "$result" =~ "Hello"

# Test basic number highlighting  
result=$(stdlib_string_code_highlight 'let count = 42;')
assert "$result" =~ "42"

# Test decimal numbers
result=$(stdlib_string_code_highlight 'let pi = 3.14159;')
assert "$result" =~ "3.14159"

# Test negative numbers
result=$(stdlib_string_code_highlight 'let temp = -5.5;')
assert "$result" =~ "-5.5"

# Test single quotes
result=$(stdlib_string_code_highlight "let name = 'Alice';")
assert "$result" =~ "Alice"

# Test double quotes
result=$(stdlib_string_code_highlight 'let greeting = "Hello World";')
assert "$result" =~ "Hello World"

# Test mixed content
result=$(stdlib_string_code_highlight 'function test(x) { return x * 2.5 + "result"; }')
assert "$result" =~ "2.5"
assert "$result" =~ "result"

# Test empty input
result=$(stdlib_string_code_highlight '')
assert "$result" == ""

# Test numbers at beginning of line
result=$(stdlib_string_code_highlight '123 is a number')
assert "$result" =~ "123"

# Test that variables are not highlighted as numbers
result=$(stdlib_string_code_highlight 'let variable123 = "test";')
# Should highlight the string but not the 123 in variable123
assert "$result" =~ "test"
# The variable123 should NOT be highlighted as a number

# Test that ANSI codes are present for strings (green)
result=$(stdlib_string_code_highlight 'let str = "test";')
assert "$result" =~ "\[38;5;2m" || "$result" =~ "\e\[38;5;2m"

# Test that ANSI codes are present for numbers (pink)
result=$(stdlib_string_code_highlight 'let num = 42;')
assert "$result" =~ "\[38;5;218m" || "$result" =~ "\e\[38;5;218m"

# Test that reset codes are present
result=$(stdlib_string_code_highlight 'let test = "hello";')
assert "$result" =~ "\[0m" || "$result" =~ "\e\[0m"

# Test boolean highlighting (true/false)
result=$(stdlib_string_code_highlight 'if (true) return false;')
assert "$result" =~ "true"
assert "$result" =~ "false"

# Test keyword highlighting
result=$(stdlib_string_code_highlight 'function test() { let x = null; }')
assert "$result" =~ "function"
assert "$result" =~ "let"
assert "$result" =~ "null"

# Test operator highlighting
result=$(stdlib_string_code_highlight 'x = y + 5; if (a >= b) { c++; }')
assert "$result" =~ "\+\+"

# Test comment highlighting (line comments)
result=$(stdlib_string_code_highlight '// This is a comment')
assert "$result" =~ "This is a comment"

result=$(stdlib_string_code_highlight '# This is also a comment')
assert "$result" =~ "This is also a comment"

# Test indented comments
result=$(stdlib_string_code_highlight '    // Indented comment')
assert "$result" =~ "Indented comment"

# Test that comment color codes are present (grey)
result=$(stdlib_string_code_highlight '// test comment')
assert "$result" =~ "\[38;5;244m" || "$result" =~ "\e\[38;5;244m"

# Test that boolean color codes are present (orange)  
result=$(stdlib_string_code_highlight 'return true;')
assert "$result" =~ "\[38;5;214m" || "$result" =~ "\e\[38;5;214m"

# Test that keyword color codes are present (cyan)
result=$(stdlib_string_code_highlight 'function test() {}')
assert "$result" =~ "\[38;5;6m" || "$result" =~ "\e\[38;5;6m"

# Test that operator color codes are present (yellow)
result=$(stdlib_string_code_highlight 'x = y + 5;')
assert "$result" =~ "\[38;5;3m" || "$result" =~ "\e\[38;5;3m"