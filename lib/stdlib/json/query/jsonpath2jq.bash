stdlib_json_query_jsonpath2jq() {
  local jsonpath="$1"
  local jq_expr=""
  local i=0
  local len=${#jsonpath}

  # Remove leading $ if present
  if [[ "${jsonpath:0:1}" == "$" ]]; then
    jsonpath="${jsonpath:1}"
    jq_expr=""
  fi

  # Parse character by character
  while [[ $i -lt $len ]]; do
    local char="${jsonpath:$i:1}"

    case "$char" in
      ".")
        # Handle dot notation
        if [[ $i -eq 0 ]] || [[ "${jsonpath:$((i-1)):1}" == "]" ]]; then
          # Start of path or after array access
          jq_expr+="."
        else
          # Property access
          jq_expr+="."
        fi
        ;;
      "[")
        # Handle array/filter notation
        local bracket_content=""
        local bracket_end
        local bracket_depth=1
        ((i++))

        # Find matching closing bracket
        while [[ $i -lt $len ]] && [[ $bracket_depth -gt 0 ]]; do
          local bracket_char="${jsonpath:$i:1}"
          if [[ "$bracket_char" == "[" ]]; then
            ((bracket_depth++))
          elif [[ "$bracket_char" == "]" ]]; then
            ((bracket_depth--))
          fi

          if [[ $bracket_depth -gt 0 ]]; then
            bracket_content+="$bracket_char"
          fi
          ((i++))
        done
        ((i--)) # Back up one since we'll increment at end of loop

        # Parse bracket content
        if [[ "$bracket_content" == "*" ]]; then
          # Wildcard - convert to []
          jq_expr+="[]"
        elif [[ "$bracket_content" =~ ^[0-9]+$ ]]; then
          # Numeric index
          jq_expr+="[$bracket_content]"
        elif [[ "$bracket_content" =~ ^[0-9]+:[0-9]+$ ]]; then
          # Slice notation (basic)
          jq_expr+="[$bracket_content]"
        elif [[ "$bracket_content" =~ ^\?.*$ ]]; then
          # Filter expression
          local filter_expr="${bracket_content:1}" # Remove ?
          local converted_filter
          converted_filter=$(__stdlib_json_query_jsonpath2jq_convert_filter_expression "$filter_expr")
          jq_expr+="[] | select($converted_filter)"
        elif [[ "$bracket_content" =~ ^[0-9,]+$ ]]; then
          # Multiple indices
          jq_expr+="[$bracket_content]"
        else
          # Property name in brackets (quoted)
          bracket_content="${bracket_content//\'/}" # Remove quotes
          bracket_content="${bracket_content//\"/}" # Remove quotes
          jq_expr+="[\"$bracket_content\"]"
        fi
        ;;
      *)
        # Regular property name
        local prop_name=""
        while [[ $i -lt $len ]] && [[ "${jsonpath:$i:1}" != "." ]] && [[ "${jsonpath:$i:1}" != "[" ]]; do
          prop_name+="${jsonpath:$i:1}"
          ((i++))
        done
        ((i--)) # Back up one

        if [[ -n "$prop_name" ]]; then
          jq_expr+="$prop_name"
        fi
        ;;
    esac
    ((i++))
  done

  # Handle recursive descent (..)
  if [[ "$jsonpath" == *".."* ]]; then
    jq_expr=$(__stdlib_json_query_jsonpath2jq_handle_recursive_descent "$1")
  fi

  echo "$jq_expr"
}

# Convert filter expressions like (@.age > 25)
__stdlib_json_query_jsonpath2jq_convert_filter_expression() {
  local filter="$1"

  # Remove outer parentheses if present
  if [[ "${filter:0:1}" == "(" ]] && [[ "${filter: -1}" == ")" ]]; then
    filter="${filter:1:-1}"
  fi

  # Replace @ with current context
  filter="${filter//@/}"

  # Handle common operators
  filter="${filter// == / == }"
  filter="${filter// != / != }"
  filter="${filter// > / > }"
  filter="${filter// < / < }"
  filter="${filter// >= / >= }"
  filter="${filter// <= / <= }"

  # Handle string comparisons (add quotes if not present)
  if [[ "$filter" =~ ==.*[^0-9\"\']$ ]]; then
    filter=$(echo "$filter" | sed 's/== \([^"]*\)$/== "\1"/')
  fi

  echo "$filter"
}

# Handle recursive descent (..)
__stdlib_json_query_jsonpath2jq_handle_recursive_descent() {
  local jsonpath="$1"
  local result=""

  if [[ "$jsonpath" =~ ^\$\.\.(.+)$ ]]; then
    local target="${BASH_REMATCH[1]}"
    result=".. | .$target? // empty"
  elif [[ "$jsonpath" == "\$.." ]]; then
    result=".. | values"
  else
    # Convert normally and handle .. separately
    result=$(jsonpath_to_jq "$jsonpath")
  fi

  echo "$result"
}
