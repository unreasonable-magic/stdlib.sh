stdlib_maths_round() {
  # Grab the precision config if present
  local precision=0
  local mode="round"
  while [[ "$1" == --* ]]; do
    case "$1" in
    --precision)
      precision="$2"
      shift 2
      ;;
    --ceil)
      mode="ceil"
      shift
      ;;
    --floor)
      mode="floor"
      shift
      ;;
    *)
      stdlib_error_fatal "unknown option: $1"
      ;;
    esac
  done

  local num="$1"

  # Handle negative numbers
  local is_negative=false
  if [[ "$num" == -* ]]; then
    is_negative=true
    num="${num#-}"
  fi

  # Remove decimal points and count decimal places
  local num_int="${num//./}"
  local num_decimal_places=0
  # Count decimal places
  if [[ "$num" == *.* ]]; then
    num_decimal_places=${num#*.}
    num_decimal_places=${#num_decimal_places}
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
  0)
    local scale="1"
    ;;
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

  # Scale the input number to work with integers
  local scaled_input=$num_int

  # Adjust for the difference between current decimal places and target precision
  local decimal_diff=$((num_decimal_places - precision))

  if ((decimal_diff > 0)); then
    # Need to truncate/round: determine what to add based on mode
    local adjustment=0

    if [[ "$mode" == "ceil" ]]; then
      # For ceiling, add 9 to force rounding up if any digits are truncated
      # But only if there are non-zero digits being truncated
      local truncated_part=""
      local temp_int=$num_int
      local temp_diff=$decimal_diff
      while ((temp_diff > 0)); do
        truncated_part="$((temp_int % 10))${truncated_part}"
        temp_int=$((temp_int / 10))
        ((temp_diff--))
      done
      if ((truncated_part > 0)); then
        adjustment=9
        local temp_diff=$((decimal_diff - 1))
        while ((temp_diff > 0)); do
          adjustment=$((adjustment * 10))
          ((temp_diff--))
        done
      fi
    elif [[ "$mode" == "round" ]]; then
      # Standard rounding: add 5
      adjustment=5
      local temp_diff=$((decimal_diff - 1))
      while ((temp_diff > 0)); do
        adjustment=$((adjustment * 10))
        ((temp_diff--))
      done
    fi
    # floor mode: no adjustment (truncate)

    # Apply adjustment for negative numbers (reverse ceil/floor)
    if [[ "$is_negative" == true ]] && [[ "$mode" != "round" ]]; then
      if [[ "$mode" == "ceil" ]]; then
        adjustment=0 # ceiling of negative is truncation
      else           # floor
        # For floor of negative, we need to round down (away from zero)
        local truncated_part=""
        local temp_int=$num_int
        local temp_diff=$decimal_diff
        while ((temp_diff > 0)); do
          truncated_part="$((temp_int % 10))${truncated_part}"
          temp_int=$((temp_int / 10))
          ((temp_diff--))
        done
        if ((truncated_part > 0)); then
          adjustment=9
          local temp_diff=$((decimal_diff - 1))
          while ((temp_diff > 0)); do
            adjustment=$((adjustment * 10))
            ((temp_diff--))
          done
        fi
      fi
    fi

    scaled_input=$((scaled_input + adjustment))

    # Remove excess decimal places
    while ((decimal_diff > 0)); do
      scaled_input=$((scaled_input / 10))
      ((decimal_diff--))
    done
  elif ((decimal_diff < 0)); then
    # Need to add decimal places
    while ((decimal_diff < 0)); do
      scaled_input=$((scaled_input * 10))
      ((decimal_diff++))
    done
  fi

  # Now we have the correctly rounded number with the right number of decimal places
  local result=$scaled_input

  # Format the result
  if ((precision == 0)); then
    # Integer result
    local int_part=$result
    local sign=""
    if [[ "$is_negative" == true ]]; then
      sign="-"
    fi
    echo "${sign}${int_part}"
  else
    # Decimal result
    local int_part=$((result / scale))
    local dec_part=$((result % scale))

    local sign=""
    if [[ "$is_negative" == true ]]; then
      sign="-"
    fi

    if ((dec_part == 0)); then
      echo "${sign}${int_part}"
    else
      # Remove trailing zeros
      printf -v dec_str "%0${precision}d" $dec_part
      while [[ "$dec_str" == *0 ]] && ((${#dec_str} > 1)); do
        dec_str="${dec_str%0}"
      done
      echo "${sign}${int_part}.${dec_str}"
    fi
  fi
}
