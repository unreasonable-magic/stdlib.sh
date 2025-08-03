# stdlib_maths - Mathematical expression evaluator using fltexpr
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
#   stdlib_maths "%p of sqrt(%n)" "50%" 64 → 4
#   stdlib_maths "result = PI * 2"       → sets result=6.28... (no output)
#   stdlib_maths "5 > 3"                 → true (exit 0, usable in conditionals)
#   stdlib_maths "5 < 3"                 → false (exit 1, usable in conditionals)
#   stdlib_maths "isnan(5)"              → false (exit 1)
#   stdlib_maths "isnan(nan)"            → true (exit 0)
#   stdlib_maths "5 > 3 ? 42 : 0"       → 42 (ternary operator, exit 0)
#   stdlib_maths "5 < 3 ? 42 : 0"       → 0 (exit 0)
#   stdlib_maths "1 < 2 ? true : false" → true (exit 0)
#   if stdlib_maths "5 > 3"; then echo "works!"; fi
#   stdlib_maths                         → starts interactive REPL mode
#   echo "1 + 1" | stdlib_maths         → processes expressions from stdin
# 
# REPL Mode Features:
#   - Compact output (no extra newlines)
#   - Assignments print their values: foo = 1 + 2 → 3
#   - Variables persist between expressions: foo=5; bar=3; foo+bar → 8
#   - All mathematical functions and operators work
#   - Type 'exit' or 'quit' to exit, or use Ctrl+C

enable fltexpr
stdlib_import "duration"
stdlib_import "string/code_highlight"

stdlib_maths() {
  local __stdlib_maths_result exit_code
  local format_string="$1"
  shift

  # If no arguments, start REPL mode (interactive or from stdin)
  if [[ -z "$format_string" ]]; then
    echo "stdlib_maths interactive mode (Ctrl+C or 'exit' to quit)"
    echo "Examples: 1 + 1, sin(PI/2), 5 > 3, isnan(5), foo = 1 + 2"
    echo ""
    
    # Initialize global session variables to track assignments and previous result
    declare -g _stdlib_repl_vars=""
    declare -g _stdlib_previous_result=""
    
    while true; do
      # Only show prompt if stdin is a terminal
      if [[ -t 0 ]]; then
        printf "maths> "
      fi
      
      if ! read -r format_string; then
        # EOF reached
        if [[ -t 0 ]]; then
          echo ""
        fi
        break
      fi
      
      # Skip empty lines
      [[ -z "$format_string" ]] && continue
      
      # Exit commands
      if [[ "$format_string" == "exit" ]] || [[ "$format_string" == "quit" ]]; then
        break
      fi
      
      
      # Process the expression with REPL flag (using global variables)
      _stdlib_maths_eval "$format_string" true
    done
    return 0
  fi

  # Call the main evaluation function
  _stdlib_maths_eval "$format_string" false "$@"
}

_stdlib_maths_eval() {
  local format_string="$1"
  local is_repl="$2"
  shift 2
  
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
  while [[ "$expression" =~ (%[npd]) ]]; do
    if [[ $arg_index -ge ${#args[@]} ]]; then
      echo "stdlib_maths: error: not enough arguments for format string" >&2
      return 1
    fi

    local placeholder="${BASH_REMATCH[1]}"
    local arg="${args[$arg_index]}"

    if [[ "$placeholder" == "%p" ]]; then
      # Strip % sign if present and convert to decimal
      if [[ "$arg" =~ ^([0-9]+\.?[0-9]*)%?$ ]]; then
        local value="${BASH_REMATCH[1]}"
        expression="${expression/\%p/(${value}/100)}"
      else
        echo "stdlib_maths: error: invalid percentage value: $arg" >&2
        return 1
      fi
    elif [[ "$placeholder" == "%d" ]]; then
      # Convert duration to seconds using stdlib_duration
      local duration_seconds
      duration_seconds=$(stdlib_duration "$arg" --total-seconds)
      if [[ $? -eq 0 ]]; then
        expression="${expression/\%d/${duration_seconds}}"
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

  # Convert percentages (e.g., "50%" -> "(50/100)")
  # Match numbers followed by % sign, including decimals
  while [[ "$expression" =~ ([0-9]+\.?[0-9]*)% ]]; do
    local percentage="${BASH_REMATCH[1]}"
    expression="${expression//${BASH_REMATCH[0]}/(${percentage}/100)}"
  done

  # Convert "of" to multiplication
  expression="${expression// of / * }"
  
  # Convert true/false to 1/0 for fltexpr
  expression="${expression//true/1}"
  expression="${expression//false/0}"
  
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
    var_name="${var_name// /}"  # Remove spaces
    
    # Re-evaluate just the expression part to get the value
    local expr_part="${expression#*=}"
    expr_part="${expr_part#* }"  # Remove leading spaces (better)
    
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
      # Highlight the assignment result if running interactively
      if [[ -t 0 ]]; then
        printf "%s\n" "$(stdlib_string_code_highlight "$__temp_result")"
      else
        printf "%s\n" "$__temp_result"
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
    if [[ "$expression" =~ is[a-z]+\( ]] || \
       ([[ ! "$expression" =~ \? ]] && \
        ([[ "$expression" =~ \< ]] || [[ "$expression" =~ \> ]] || \
         [[ "$expression" =~ == ]] || [[ "$expression" =~ != ]] || \
         [[ "$expression" =~ \<= ]] || [[ "$expression" =~ \>= ]])) || \
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
      exit_code_to_return=0
    elif [[ "$is_boolean" == true ]] && [[ "$__stdlib_maths_result" == "0" ]]; then
      output_result="false"
      exit_code_to_return=1
    else
      output_result="$__stdlib_maths_result"
      exit_code_to_return=0
    fi
    
    # In REPL mode, store the result for next iteration and highlight output
    if [[ "$is_repl" == true ]]; then
      _stdlib_previous_result="$__stdlib_maths_result"
      # Highlight the output result if running interactively
      if [[ -t 0 ]]; then
        printf "%s\n" "$(stdlib_string_code_highlight "$output_result")"
      else
        printf "%s\n" "$output_result"
      fi
    else
      printf "%s\n" "$output_result"
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
    # Skip known constants
    if [[ "$word" =~ ^(PI|E|GAMMA|DBL_MIN|DBL_MAX|inf|nan)$ ]]; then
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
