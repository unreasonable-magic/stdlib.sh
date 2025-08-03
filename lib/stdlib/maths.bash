# stdlib_maths - Mathematical expression evaluator using fltexpr
#
# Operators:
#   +, -, *, /      - basic arithmetic
#   %, mod          - modulo (converted to fmod function)
#   ==, !=, <, <=, >, >= - comparisons
#   &&              - logical AND (converted to ternary)
#   ? :             - ternary conditional
#
#
#   abs(x)          - absolute value
#   acos(x)         - arc cosine
#   acosh(x)        - hyperbolic arc cosine
#   asin(x)         - arc sine
#   asinh(x)        - hyperbolic arc sine
#   atan(x)         - arc tangent
#   atanh(x)        - hyperbolic arc tangent
#   cbrt(x)         - cube root
#   ceil(x)         - ceiling (round up)
#   cos(x)          - cosine
#   cosh(x)         - hyperbolic cosine
#   cot(x)          - cotangent
#   coth(x)         - hyperbolic cotangent
#   erf(x)          - error function
#   erfc(x)         - complementary error function
#   exp(x)          - exponential (e^x)
#   exp2(x)         - base-2 exponential (2^x)
#   expm1(x)        - exp(x) - 1
#   fabs(x)         - floating-point absolute value
#   floor(x)        - floor (round down)
#   j0(x)           - Bessel function of the first kind, order 0
#   j1(x)           - Bessel function of the first kind, order 1
#   lgamma(x)       - log gamma function
#   log(x)          - natural logarithm
#   log10(x)        - base-10 logarithm
#   log1p(x)        - log(1 + x)
#   log2(x)         - base-2 logarithm
#   logb(x)         - extract exponent
#   nearbyint(x)    - round to nearest integer
#   rint(x)         - round to nearest integer
#   round(x)        - round to nearest integer
#   sin(x)          - sine
#   sinh(x)         - hyperbolic sine
#   sqrt(x)         - square root
#   tan(x)          - tangent
#   tanh(x)         - hyperbolic tangent
#   tgamma(x)       - gamma function
#   trunc(x)        - truncate to integer
#   y0(x)           - Bessel function of the second kind, order 0
#   y1(x)           - Bessel function of the second kind, order 1
#   atan2(y, x)     - arc tangent of y/x
#   copysign(x, y)  - copy sign of y to x
#   fdim(x, y)      - positive difference
#   fmax(x, y)      - maximum
#   fmin(x, y)      - minimum
#   fmod(x, y)      - floating-point remainder
#   hypot(x, y)     - hypotenuse (sqrt(x² + y²))
#   jn(n, x)        - Bessel function of the first kind, order n
#   ldexp(x, exp)   - x * 2^exp
#   nextafter(x, y) - next representable value after x toward y
#   pow(x, y)       - x raised to power y
#   remainder(x, y) - IEEE remainder
#   roundp(x, p)    - round to p decimal places
#   scalbn(x, n)    - x * FLT_RADIX^n
#   yn(n, x)        - Bessel function of the second kind, order n
#   fma(x, y, z)    - fused multiply-add (x * y + z)
#
# Classification Functions:
#   fpclassify(x)   - classify floating-point value
#   isfinite(x)     - test for finite value
#   isinf(x)        - test for infinity
#   isnan(x)        - test for NaN
#   isnormal(x)     - test for normal value
#   issubnormal(x)  - test for subnormal value
#   iszero(x)       - test for zero
#   ilogb(x)        - extract exponent as integer
#   signbit(x)      - test sign bit
#   isinfinite(x)   - test for infinity (alias) - not available
#
# Comparison Functions:
#   isgreater(x, y)      - x > y (handles NaN)
#   isgreaterequal(x, y) - x >= y (handles NaN)
#   isless(x, y)         - x < y (handles NaN)
#   islessequal(x, y)    - x <= y (handles NaN)
#   islessgreater(x, y)  - (x < y) || (x > y) (handles NaN)
#   isunordered(x, y)    - test if either is NaN
#   isbetween(x, min, max) - x >= min && x <= max (virtual function)
#   clamp(x, min, max)   - constrain x to [min, max] range (virtual function)
#   maximum(x, y, z, ...) - maximum of multiple values (virtual function)
#   minimum(x, y, z, ...) - minimum of multiple values (virtual function)
#   average(x, y, z, ...) - average of multiple values (virtual function)
#   sum(x, y, z, ...)    - sum of multiple values (virtual function)
#
# Constants:
#   PI       - π (3.14159...)
#   E        - e (2.71828...)
#   GAMMA    - Euler-Mascheroni constant (0.57721...)
#   DBL_MIN  - smallest positive double
#   DBL_MAX  - largest finite double
#
# Usage Examples:
#   stdlib_maths "log(2)"                → 0.693...
#   stdlib_maths "sin(PI/2)"             → 1
#   stdlib_maths "pow(2, 8)"             → 256
#   stdlib_maths "sqrt(%n)" 16           → 4
#   stdlib_maths "%percentage of sqrt(%n)" "50%" 64 → 4
#   stdlib_maths "result = PI * 2"       → sets result=6.28... (no output)
#   stdlib_maths "5 > 3"                 → true (exit 0, usable in conditionals)
#   stdlib_maths "5 < 3"                 → false (exit 1, usable in conditionals)
#   stdlib_maths "(5 > 3) && (2 < 4)"   → true (logical AND converted to ternary)
#   stdlib_maths "isbetween(5, 1, 10)"   → true (virtual function)
#   stdlib_maths "clamp(-2, 0, 100)"     → 0 (clamps to minimum)
#   stdlib_maths "clamp(101, 0, 100)"    → 100 (clamps to maximum)
#   stdlib_maths "7 % 3"                 → 1 (modulo converted to fmod)
#   stdlib_maths "10.5 % 3"              → 1.5 (floating-point modulo)
#   stdlib_maths "maximum(1, 3, 2)"      → 3 (maximum of multiple values)
#   stdlib_maths "minimum(5, 2, 8, 1)"   → 1 (minimum of multiple values)
#   stdlib_maths "average(1, 2, 3, 4)"   → 2.5 (average of multiple values)
#   stdlib_maths "sum(1, 2, 3, 4)"       → 10 (sum of multiple values)
#   stdlib_maths "isnan(5)"              → false (exit 1)
#   stdlib_maths "isnan(nan)"            → true (exit 0)
#   stdlib_maths "5 > 3 ? 42 : 0"       → 42 (ternary operator, exit 0)
#   stdlib_maths "5 < 3 ? 42 : 0"       → 0 (exit 0)
#   stdlib_maths "1 < 2 ? true : false" → true (exit 0)
#   stdlib_maths --dry-run "maximum(1, 2, 3)" → fmax(1, fmax(2, 3)) (shows transformation)
#   stdlib_maths --quiet "5 > 3"        → no output, exit 0 if true, exit 1 if false
#   stdlib_maths -q "5 < 3"             → no output, exit 1 (false)
#   stdlib_maths --exit-code "5 > 3"    → "true", exit 0 if true, exit 1 if false
#   stdlib_maths --format percentage "0.25" → 25%
#   stdlib_maths --format duration "3661" → 1 hour 1 minute 1 second
#   if stdlib_maths "5 > 3"; then echo "works!"; fi → works! (always exit 0 by default)
#   if stdlib_maths --quiet "5 > 3"; then echo "works!"; fi → works! (exit 0 if true)
#   stdlib_maths                         → starts interactive REPL mode
#   echo "1 + 1" | stdlib_maths         → processes expressions from stdin
#
# Options:
#   --dry-run    Show the transformed expression without evaluating it
#   --quiet, -q  Suppress output to stdout and enable --exit-code behavior
#   --exit-code  Return exit status 1 for false boolean expressions (0 otherwise)
#   --format     Format the output as 'number' (default), 'percentage', or 'duration'
#
# REPL Mode Features:
#   - Compact output (no extra newlines)
#   - Assignments print their values: foo = 1 + 2 → 3
#   - Variables persist between expressions: foo=5; bar=3; foo+bar → 8
#   - All mathematical functions and operators work
#   - Type 'exit' or 'quit' to exit, or use Ctrl+C

enable fltexpr
stdlib_import "duration"
stdlib_import "percentage"
stdlib_import "string/code_highlight"
stdlib_import "maths/repl"

stdlib_maths() {
  local __stdlib_maths_result exit_code
  local dry_run=false
  local quiet=false
  local exit_code_mode=false
  local format="number"  # Default format

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        shift
        ;;
      --quiet|-q)
        quiet=true
        exit_code_mode=true  # --quiet implies --exit-code
        shift
        ;;
      --exit-code)
        exit_code_mode=true
        shift
        ;;
      --format)
        format="$2"
        if [[ "$format" != "number" && "$format" != "percentage" && "$format" != "duration" ]]; then
          echo "stdlib_maths: error: invalid format '$format'. Must be one of: number, percentage, duration" >&2
          return 1
        fi
        shift 2
        ;;
      -*)
        echo "stdlib_maths: unknown option: $1" >&2
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  local format_string="$1"
  shift

  # If no arguments, start REPL mode (interactive or from stdin)
  if [[ -z "$format_string" ]]; then
    # Call the REPL function with the format option
    stdlib_maths_repl "$format" "$@"
    return $?
  fi

  # Call the main evaluation function
  _stdlib_maths_eval "$format_string" false "$dry_run" "$quiet" "$exit_code_mode" "$format" "$@"
}

_stdlib_maths_eval() {
  local format_string="$1"
  local is_repl="$2"
  local dry_run="$3"
  local quiet="$4"
  local exit_code_mode="$5"
  local format="$6"
  shift 6

  local __stdlib_maths_result exit_code

  # In REPL mode, restore previous variables
  if [[ "$is_repl" == true ]]; then
    if [[ -n "$_stdlib_repl_vars" ]]; then
      eval "$_stdlib_repl_vars"
    fi
  fi

  # Create a working copy of the format string
  local expression="$format_string"
  local arg_index=0
  local -a args=("$@")

  # Process placeholders in order they appear
  while [[ "$expression" =~ (%[n]|%duration|%percentage) ]]; do
    if [[ $arg_index -ge ${#args[@]} ]]; then
      echo "stdlib_maths: error: not enough arguments for format string" >&2
      return 1
    fi

    local placeholder="${BASH_REMATCH[1]}"
    local arg="${args[$arg_index]}"

    if [[ "$placeholder" == "%percentage" ]]; then
      # Strip % sign if present and convert to decimal
      if [[ "$arg" =~ ^([0-9]+\.?[0-9]*)%?$ ]]; then
        local value="${BASH_REMATCH[1]}"
        expression="${expression/\%percentage/(${value}/100)}"
      else
        echo "stdlib_maths: error: invalid percentage value: $arg" >&2
        return 1
      fi
    elif [[ "$placeholder" == "%duration" ]]; then
      # Convert duration to seconds using stdlib_duration
      local duration_seconds
      duration_seconds=$(stdlib_duration "$arg" --total-seconds)
      if [[ $? -eq 0 ]]; then
        expression="${expression/\%duration/${duration_seconds}}"
      else
        echo "stdlib_maths: error: invalid duration format: $arg" >&2
        return 1
      fi
    else
      # %n - just replace with the argument value
      expression="${expression/\%n/${arg}}"
    fi

    ((arg_index++))
  done

  # Convert "of" to multiplication
  expression="${expression// of / * }"

  # Convert modulo operator % to fmod function (must be before percentage conversion)
  # Match patterns like "number % number" but not "number%" (percentages)
  while [[ "$expression" =~ ([0-9]+\.?[0-9]*|[a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*%[[:space:]]+([0-9]+\.?[0-9]*|[a-zA-Z_][a-zA-Z0-9_]*) ]]; do
    local left="${BASH_REMATCH[1]}"
    local right="${BASH_REMATCH[2]}"
    local fmod_call="fmod($left, $right)"
    expression="${expression//${BASH_REMATCH[0]}/$fmod_call}"
  done

  # Convert percentages (e.g., "50%" -> "(50/100)")
  # Match numbers followed by % sign, including decimals
  while [[ "$expression" =~ ([0-9]+\.?[0-9]*)% ]]; do
    local percentage="${BASH_REMATCH[1]}"
    expression="${expression//${BASH_REMATCH[0]}/(${percentage}/100)}"
  done

  # Convert && expressions to ternary form (since fltexpr doesn't support &&)
  local and_pattern='\(([^)]+)\)[[:space:]]*&&[[:space:]]*\(([^)]+)\)'
  while [[ "$expression" =~ $and_pattern ]]; do
    local left="${BASH_REMATCH[1]}"
    local right="${BASH_REMATCH[2]}"
    local ternary="(($left) ? (($right) ? 1 : 0) : 0)"
    expression="${expression//${BASH_REMATCH[0]}/$ternary}"
  done

  # Convert isbetween(value, min, max) to ternary form
  local isbetween_pattern='isbetween\(([^,]+),([^,]+),([^)]+)\)'
  while [[ "$expression" =~ $isbetween_pattern ]]; do
    local value="${BASH_REMATCH[1]// /}" # Remove spaces
    local min="${BASH_REMATCH[2]// /}"   # Remove spaces
    local max="${BASH_REMATCH[3]// /}"   # Remove spaces
    local ternary="(($value >= $min) ? (($value <= $max) ? 1 : 0) : 0)"
    expression="${expression//${BASH_REMATCH[0]}/$ternary}"
  done

  # Convert clamp(value, min, max) to ternary form
  local clamp_pattern='clamp\(([^,]+),([^,]+),([^)]+)\)'
  while [[ "$expression" =~ $clamp_pattern ]]; do
    local value="${BASH_REMATCH[1]// /}" # Remove spaces
    local min="${BASH_REMATCH[2]// /}"   # Remove spaces
    local max="${BASH_REMATCH[3]// /}"   # Remove spaces
    local ternary="(($value < $min) ? $min : (($value > $max) ? $max : $value))"
    expression="${expression//${BASH_REMATCH[0]}/$ternary}"
  done

  # Convert maximum(a, b, c, ...) to nested fmax calls
  local maximum_pattern='([^a-zA-Z_]|^)maximum\(([^)]+)\)'
  while [[ "$expression" =~ $maximum_pattern ]]; do
    local prefix="${BASH_REMATCH[1]}"
    local args="${BASH_REMATCH[2]}"
    # Split arguments by comma and build nested fmax calls
    IFS=',' read -ra arg_array <<<"$args"
    local result="${arg_array[0]// /}" # Remove spaces from first arg
    for ((i = 1; i < ${#arg_array[@]}; i++)); do
      local next_arg="${arg_array[i]// /}" # Remove spaces
      result="fmax($result, $next_arg)"
    done
    expression="${expression//${BASH_REMATCH[0]}/${prefix}${result}}"
  done

  # Convert minimum(a, b, c, ...) to nested fmin calls
  local minimum_pattern='([^a-zA-Z_]|^)minimum\(([^)]+)\)'
  while [[ "$expression" =~ $minimum_pattern ]]; do
    local prefix="${BASH_REMATCH[1]}"
    local args="${BASH_REMATCH[2]}"
    # Split arguments by comma and build nested fmin calls
    IFS=',' read -ra arg_array <<<"$args"
    local result="${arg_array[0]// /}" # Remove spaces from first arg
    for ((i = 1; i < ${#arg_array[@]}; i++)); do
      local next_arg="${arg_array[i]// /}" # Remove spaces
      result="fmin($result, $next_arg)"
    done
    expression="${expression//${BASH_REMATCH[0]}/${prefix}${result}}"
  done

  # Convert average(a, b, c, ...) to sum divided by count
  local average_pattern='([^a-zA-Z_]|^)average\(([^)]+)\)'
  while [[ "$expression" =~ $average_pattern ]]; do
    local prefix="${BASH_REMATCH[1]}"
    local args="${BASH_REMATCH[2]}"
    # Split arguments by comma and build sum expression
    IFS=',' read -ra arg_array <<<"$args"
    local sum=""
    for ((i = 0; i < ${#arg_array[@]}; i++)); do
      local arg="${arg_array[i]// /}" # Remove spaces
      if [[ $i -eq 0 ]]; then
        sum="$arg"
      else
        sum="$sum + $arg"
      fi
    done
    local result="(($sum) / ${#arg_array[@]})"
    expression="${expression//${BASH_REMATCH[0]}/${prefix}${result}}"
  done
  
  # Convert sum(a, b, c, ...) to addition chain
  local sum_pattern='([^a-zA-Z_]|^)sum\(([^)]+)\)'
  while [[ "$expression" =~ $sum_pattern ]]; do
    local prefix="${BASH_REMATCH[1]}"
    local args="${BASH_REMATCH[2]}"
    # Split arguments by comma and build sum expression
    IFS=',' read -ra arg_array <<<"$args"
    local sum=""
    for ((i = 0; i < ${#arg_array[@]}; i++)); do
      local arg="${arg_array[i]// /}" # Remove spaces
      if [[ $i -eq 0 ]]; then
        sum="$arg"
      else
        sum="$sum + $arg"
      fi
    done
    local result="($sum)"
    expression="${expression//${BASH_REMATCH[0]}/${prefix}${result}}"
  done

  # Convert true/false to 1/0 for fltexpr
  expression="${expression//true/1}"
  expression="${expression//false/0}"

  # If dry-run mode, print the transformed expression and return
  if [[ "$dry_run" == true ]]; then
    printf "%s\n" "$expression"
    return 0
  fi

  # Validate variables before evaluation
  _stdlib_maths_validate_variables "$expression" "$is_repl" || return 1

  # Check if the expression is a variable assignment (starts with identifier =)
  local is_assignment=false
  if [[ "$expression" =~ ^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*= ]]; then
    is_assignment=true
  fi

  if [[ "$is_assignment" == true ]]; then
    # For assignments, execute directly with fltexpr
    # Capture stderr to detect actual errors vs false expressions
    local error_output
    # In REPL mode, set _ variable first, then execute assignment
    if [[ "$is_repl" == true ]] && [[ -n "$_stdlib_previous_result" ]]; then
      fltexpr "_ = $_stdlib_previous_result" 2>/dev/null
      error_output=$(fltexpr "$expression" 2>&1 >/dev/null)
    else
      error_output=$(fltexpr "$expression" 2>&1 >/dev/null)
    fi
    exit_code="$?"

    # If there's error output, it's an actual error (not just false)
    if [[ -n "$error_output" ]]; then
      echo "stdlib_maths: error: $error_output" >&2
      return "$exit_code"
    fi

    # For assignments, extract the variable name and value
    # Extract variable name from assignment
    local var_name="${expression%%=*}"
    var_name="${var_name// /}" # Remove spaces

    # Re-evaluate just the expression part to get the value
    local expr_part="${expression#*=}"
    expr_part="${expr_part#* }" # Remove leading spaces (better)

    # Evaluate the expression to get the result
    # In REPL mode, set _ variable first, then evaluate expression
    if [[ "$is_repl" == true ]] && [[ -n "$_stdlib_previous_result" ]]; then
      fltexpr "_ = $_stdlib_previous_result" 2>/dev/null
      fltexpr "__temp_result = ($expr_part)" 2>/dev/null
    else
      fltexpr "__temp_result = ($expr_part)" 2>/dev/null
    fi

    # Store the variable for use (export to global state)
    declare -g "$var_name=$__temp_result"

    # In REPL mode, also print the assigned value and update repl state
    if [[ "$is_repl" == true ]]; then
      # Highlight the assignment result if running interactively (unless quiet)
      if [[ "$quiet" != true ]]; then
        if [[ -t 0 ]]; then
          printf "%s\n" "$(stdlib_string_code_highlight "$__temp_result")"
        else
          printf "%s\n" "$__temp_result"
        fi
      fi
      
      # Update the repl_vars state
      if [[ -n "$_stdlib_repl_vars" ]]; then
        _stdlib_repl_vars="$_stdlib_repl_vars; $var_name=$__temp_result"
      else
        _stdlib_repl_vars="$var_name=$__temp_result"
      fi
      
      # Store the assigned value as the previous result too
      _stdlib_previous_result="$__temp_result"
    fi
  else
    # For expressions, evaluate and print result
    # First try to evaluate the expression
    # In REPL mode, set _ variable first, then evaluate expression
    if [[ "$is_repl" == true ]] && [[ -n "$_stdlib_previous_result" ]]; then
      fltexpr "_ = $_stdlib_previous_result" 2>/dev/null
      fltexpr "__stdlib_maths_result = ($expression)" 2>/tmp/stdlib_maths_error.$$
    else
      fltexpr "__stdlib_maths_result = ($expression)" 2>/tmp/stdlib_maths_error.$$
    fi
    exit_code="$?"

    # Read any error output
    local error_output=""
    if [[ -f /tmp/stdlib_maths_error.$$ ]]; then
      error_output=$(cat /tmp/stdlib_maths_error.$$)
      rm -f /tmp/stdlib_maths_error.$$
    fi

    # If there's error output, it's an actual error
    if [[ -n "$error_output" ]]; then
      # Check for common error patterns to provide better messages
      if [[ "$error_output" =~ "not found" ]] || [[ "$error_output" =~ "undefined" ]]; then
        # Extract variable name from error if possible
        if [[ "$expression" =~ ([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
          echo "stdlib_maths: error: undefined variable '${BASH_REMATCH[1]}'" >&2
        else
          echo "stdlib_maths: error: undefined variable in expression: $expression" >&2
        fi
      else
        echo "stdlib_maths: error: invalid mathematical expression: $expression" >&2
      fi
      return 1
    fi

    # Check if this is a boolean expression
    local is_boolean=false
    if [[ "$expression" =~ is[a-z]+\( ]] ||
      ([[ ! "$expression" =~ \? ]] &&
        ([[ "$expression" =~ \< ]] || [[ "$expression" =~ \> ]] ||
          [[ "$expression" =~ == ]] || [[ "$expression" =~ != ]] ||
          [[ "$expression" =~ \<= ]] || [[ "$expression" =~ \>= ]])) ||
      ([[ "$expression" =~ \? ]] && [[ "$expression" =~ \?[[:space:]]*1[[:space:]]*:[[:space:]]*0 ]]); then
      # Boolean functions, simple comparisons, or ternary expressions that return 1/0
      is_boolean=true
    fi

    # Store result for REPL mode and print
    local output_result
    local exit_code_to_return

    # Special handling for signbit: 0 stays as 0, 1 becomes "true"
    if [[ "$expression" =~ signbit\( ]]; then
      if [[ "$__stdlib_maths_result" == "1" ]]; then
        output_result="true"
        exit_code_to_return=0
      else
        output_result="0"
        exit_code_to_return=0
      fi
    elif [[ "$is_boolean" == true ]] && [[ "$__stdlib_maths_result" == "1" ]]; then
      output_result="true"
      if [[ "$exit_code_mode" == true ]]; then
        exit_code_to_return=0
      else
        exit_code_to_return=0  # Always 0 when not in exit-code mode
      fi
    elif [[ "$is_boolean" == true ]] && [[ "$__stdlib_maths_result" == "0" ]]; then
      output_result="false"
      if [[ "$exit_code_mode" == true ]]; then
        exit_code_to_return=1
      else
        exit_code_to_return=0  # Always 0 when not in exit-code mode
      fi
    else
      output_result="$__stdlib_maths_result"
      exit_code_to_return=0
    fi

    # Apply formatting to the output_result
    local formatted_result="$output_result"
    if [[ "$format" != "number" ]] && [[ "$is_boolean" != true ]]; then
      # Only format non-boolean numeric results
      case "$format" in
        percentage)
          # Convert to percentage format
          # Multiply by 100 and add % sign
          local percentage_value=$(awk "BEGIN {printf \"%.10g\", $__stdlib_maths_result * 100}")
          formatted_result="${percentage_value}%"
          ;;
        duration)
          # Convert to duration using stdlib_duration
          # Round to nearest integer for seconds
          local seconds=$(printf "%.0f" "$__stdlib_maths_result")
          # Call stdlib_duration in a way that ensures it's available
          formatted_result=$(stdlib_duration "$seconds")
          ;;
      esac
    fi
    
    # Output result unless quiet mode is enabled
    if [[ "$quiet" != true ]]; then
      # In REPL mode, store the result for next iteration and highlight output
      if [[ "$is_repl" == true ]]; then
        _stdlib_previous_result="$__stdlib_maths_result"
        # Highlight the output result if running interactively
        if [[ -t 0 ]]; then
          printf "%s\n" "$(stdlib_string_code_highlight "$formatted_result")"
        else
          printf "%s\n" "$formatted_result"
        fi
      else
        printf "%s\n" "$formatted_result"
      fi
    elif [[ "$is_repl" == true ]]; then
      # In REPL mode, still need to store the result even if quiet
      _stdlib_previous_result="$__stdlib_maths_result"
    fi
    
    return $exit_code_to_return
  fi
}

_stdlib_maths_validate_variables() {
  local expression="$1"
  local is_repl="$2"

  # Don't validate assignments - they handle their own validation
  if [[ "$expression" =~ ^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*= ]]; then
    return 0
  fi

  # Extract variable names from the expression
  # Look for sequences of letters/digits/underscores that aren't followed by ( (function calls)
  # Also exclude known constants and scientific notation
  local variables
  variables=$(echo "$expression" | grep -oE '[a-zA-Z_][a-zA-Z0-9_]*' | while read -r word; do
    # Skip if it's followed by ( in the original expression (function call)
    if [[ "$expression" =~ $word\( ]]; then
      continue
    fi
    # Skip if it's preceded by a digit (scientific notation like 1e308)
    if [[ "$expression" =~ [0-9]$word ]]; then
      continue
    fi
    # Skip known constants and virtual functions
    if [[ "$word" =~ ^(PI|E|GAMMA|DBL_MIN|DBL_MAX|inf|nan|isbetween|clamp|maximum|minimum|average|sum)$ ]]; then
      continue
    fi
    echo "$word"
  done | sort -u)

  # Check each variable
  for var in $variables; do
    # Skip the magic _ variable and temporary variables we create
    if [[ "$var" == "_" ]] || [[ "$var" == "__stdlib_maths_result" ]] || [[ "$var" == "__temp_result" ]]; then
      continue
    fi

    local var_defined=false

    # In REPL mode, check if variable exists in our state first
    if [[ "$is_repl" == true ]] && [[ -n "$_stdlib_repl_vars" ]] && [[ "$_stdlib_repl_vars" =~ $var= ]]; then
      var_defined=true
    fi

    # If not found in REPL state and not a known constant/function, assume undefined
    # Since fltexpr treats undefined vars as 0, we need to be proactive
    if [[ "$var_defined" == false ]]; then
      echo "stdlib_maths: error: undefined variable '$var'" >&2
      return 1
    fi
  done

  return 0
}
