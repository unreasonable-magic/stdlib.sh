stdlib_import "test"

stdlib_percentageage() {
  local returnvar
  local force_decimal=false
  
  # Handle options
  while [[ "$1" =~ ^- ]]; do
    case "$1" in
      -v)
        returnvar="$2"
        shift 2
        ;;
      --decimal|-d)
        force_decimal=true
        shift
        ;;
      *)
        echo "stdlib_percentage: error: unknown option: $1" >&2
        return 1
        ;;
    esac
  done
  
  local input="$1"
  
  # Check if input should come from stdin (no args)
  if [[ -z "$input" ]]; then
    # Try to read from stdin
    if [[ ! -t 0 ]]; then
      read -r input
    fi
  fi
  
  # Check if we got input from either source
  if [[ -z "$input" ]]; then
    echo "stdlib_percentage: error: no input provided" >&2
    return 1
  fi
  
  # If input doesn't end with %, validate it's a number
  if [[ ! "$input" =~ %$ ]] && ! stdlib_test type/is_number "$input"; then
    echo "stdlib_percentage: error: input must be a number or percentage, got: $input" >&2
    return 1
  fi
  
  local result
  
  # Check if input already has % sign
  if [[ "$input" =~ %$ ]]; then
    # Already a percentage, just return it
    result="$input"
  else
    # Always treat numbers as decimals - multiply by 100
    local percentage=$(echo "$input * 100" | bc -l)
    # Clean up trailing zeros
    percentage=$(echo "$percentage" | sed 's/\.0*$//' | sed 's/\(\..*[^0]\)0*$/\1/')
    # Add leading zero if missing
    if [[ "$percentage" =~ ^\. ]]; then
      percentage="0$percentage"
    fi
    result="${percentage}%"
  fi
  
  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$result"
  else
    printf "%s\n" "$result"
  fi
  
  return 0
}