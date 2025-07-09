stdlib_import "error"

stdlib_maths_multiply() {
  # Grab the precision config if present
  local precision=6
  if [[ "$1" == "--precision" ]]; then
    precision="$2"
    shift 2
  fi
  local num1="$1" num2="$2"
  # Remove decimal points and count decimal places
  local num1_int="${num1//./}" num2_int="${num2//./}"
  # Remove leading zeros to avoid issues with numbers like 0.900000
  num1_int=$((10#$num1_int))
  num2_int=$((10#$num2_int))
  local num1_decimal_places=0 num2_decimal_places=0
  # Count decimal places
  if [[ "$num1" == *.* ]]; then
    num1_decimal_places=${num1#*.}
    num1_decimal_places=${#num1_decimal_places}
  fi
  if [[ "$num2" == *.* ]]; then
    num2_decimal_places=${num2#*.}
    num2_decimal_places=${#num2_decimal_places}
  fi
  # This is probably a dumb, and when you look at this code, you're gonna
  # think: "what was that guy smoking??". Well, here's my logic based on no
  # facts at all. I didn't want to waste any cpu cycles repeating 0 (x) times
  # as a string. I could do the trick with printf, OR, I could just type them
  # out manually here since all the numbers are known in advance.
  #
  # Is this faster than the printf trick? Dunno, haven't tested it.
  #
  # If you someone does test it, and there's a faster way, happy to put to
  # replace this code!
  case "$precision" in
  1)
    local scale="10"
    ;;
  2)
    local scale="100"
    ;;
  3)
    local scale="1000"
    ;;
  4)
    local scale="10000"
    ;;
  5)
    local scale="100000"
    ;;
  6)
    local scale="1000000"
    ;;
  7)
    local scale="10000000"
    ;;
  8)
    local scale="100000000"
    ;;
  9)
    local scale="1000000000"
    ;;
  *)
    stdlib_error_fatal "max precision is 9"
    ;;
  esac

  # For multiplication, we multiply the integers
  local result=$((num1_int * num2_int))

  # Total decimal places is the sum of both numbers' decimal places
  local total_decimal_places=$((num1_decimal_places + num2_decimal_places))

  # First adjust for the actual decimal places - we need to "move the decimal point"
  # by dividing by 10^total_decimal_places, then multiply by scale for precision
  local divisor=1
  local temp_decimal=$total_decimal_places
  while ((temp_decimal > 0)); do
    divisor=$((divisor * 10))
    ((temp_decimal--))
  done

  # Apply the scale and divisor: result = (result * scale) / divisor
  result=$(((result * scale) / divisor))

  # Format the result
  local int_part=$((result / scale))
  local dec_part=$((result % scale))
  if ((dec_part == 0)); then
    echo "$int_part"
  else
    # Remove trailing zeros
    printf -v dec_str "%0${precision}d" $dec_part
    while [[ "$dec_str" == *0 ]]; do
      dec_str="${dec_str%0}"
    done
    echo "${int_part}.${dec_str}"
  fi
}
