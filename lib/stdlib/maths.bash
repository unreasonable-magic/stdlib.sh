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
#   isinf(x)        - test for infinity (only works with inf/-inf)
#   isnan(x)        - test for NaN (only works with nan)
#   isnormal(x)     - test for normal value
#   issubnormal(x)  - test for subnormal value (only works with subnormals)
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
#   isunordered(x, y)    - test if either is NaN (only works with nan)
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

enable fltexpr
stdlib_import "duration"

stdlib_maths() {
  local __stdlib_maths_result exit_code
  local format_string="$1"
  shift

  # Check if format string is provided
  if [[ -z "$format_string" ]]; then
    echo "stdlib_maths: error: no format string provided" >&2
    return 1
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

  # Check if the expression is a variable assignment (starts with identifier =)
  local is_assignment=false
  if [[ "$expression" =~ ^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*= ]]; then
    is_assignment=true
  fi

  if [[ "$is_assignment" == true ]]; then
    # For assignments, execute directly with fltexpr
    fltexpr "$expression"
    exit_code="$?"
    if [[ ! "$exit_code" -eq 0 ]]; then
      echo "stdlib_maths: error: invalid mathematical expression: $expression" >&2
      return "$exit_code"
    fi
  else
    # For expressions, evaluate and print result
    fltexpr "__stdlib_maths_result = ($expression)"
    exit_code="$?"
    if [[ ! "$exit_code" -eq 0 ]]; then
      echo "stdlib_maths: error: invalid mathematical expression: $expression" >&2
      return "$exit_code"
    fi

    printf "%s\n" "$__stdlib_maths_result"
  fi
}
