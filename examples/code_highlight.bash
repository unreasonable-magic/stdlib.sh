#!/usr/bin/env bash

eval "$(stdlib shellenv)"
stdlib_import "string/code_highlight"

echo "🎨 Enhanced stdlib_string_code_highlight Examples"
echo "================================================="
echo

echo "Color Legend:"
echo "• Strings: GREEN • Numbers: PINK • Booleans: ORANGE"
echo "• Keywords: CYAN • Operators: YELLOW • Comments: GRAY"
echo

echo "Comments:"
stdlib_string_code_highlight "// This is a JavaScript comment"
stdlib_string_code_highlight "# This is a Python/Bash comment"
echo

echo "JavaScript with all features:"
stdlib_string_code_highlight 'function calculate(x, y) {'
stdlib_string_code_highlight '    if (x > 0 && y !== null) {'
stdlib_string_code_highlight '        let result = x * 2.5 + y;'
stdlib_string_code_highlight '        return result >= 10 ? true : false;'
stdlib_string_code_highlight '    } else {'
stdlib_string_code_highlight '        console.log("Invalid input");'
stdlib_string_code_highlight '        return undefined;'
stdlib_string_code_highlight '    }'
stdlib_string_code_highlight '}'
echo

echo "Python example:"
stdlib_string_code_highlight 'def process_data(items):'
stdlib_string_code_highlight '    if items is not None:'
stdlib_string_code_highlight '        count = 0'
stdlib_string_code_highlight '        for item in items:'
stdlib_string_code_highlight '            if item.value > 3.14:'
stdlib_string_code_highlight '                count += 1'
stdlib_string_code_highlight '        return count > 0'
stdlib_string_code_highlight '    return false'
echo

echo "Mixed operators and expressions:"
stdlib_string_code_highlight 'x += 5; y *= -2.3; z /= count;'
stdlib_string_code_highlight 'result = (a == b) ? "equal" : "different";'
stdlib_string_code_highlight 'if (flag && (count <= max)) { process(); }'
echo