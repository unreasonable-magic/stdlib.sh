stdlib_import "array/join"

stdlib_string_dedent() {
  local lines=()
  local line
  local indent_to_remove=999999

  # Read all lines into array
  while IFS= read -r line; do
    lines+=("$line")
  done

  # Remove empty lines from the beginning
  while [[ ${#lines[@]} -gt 0 && (-z "${lines[0]}" || "${lines[0]}" =~ ^[[:space:]]*$) ]]; do
    lines=("${lines[@]:1}") # Remove first element
  done

  # Remove empty lines from the end
  while [[ ${#lines[@]} -gt 0 && (-z "${lines[-1]}" || "${lines[-1]}" =~ ^[[:space:]]*$) ]]; do
    unset 'lines[-1]' # Remove last element
  done

  # Find the smallest indent amount from all non-empty lines
  if [[ ${#lines[@]} -gt 0 ]]; then
    for line in "${lines[@]}"; do
      # Skip empty lines or lines with only whitespace
      if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
        continue
      fi

      # Count leading spaces for this line
      local line_indent=0
      while [[ $line_indent -lt ${#line} && "${line:$line_indent:1}" == " " ]]; do
        ((line_indent++))
      done

      # Update minimum indent if this line has less indentation
      if [[ $line_indent -lt $indent_to_remove ]]; then
        indent_to_remove=$line_indent
      fi
    done
  fi

  # If no non-empty lines found, set indent to 0
  if [[ $indent_to_remove -eq 999999 ]]; then
    indent_to_remove=0
  fi

  declare -a buffer=()

  # Remove the indent from each line
  for line in "${lines[@]}"; do
    # Just add empty lines in as-is
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
      buffer+=("$line")
    else
      # Remove indent_to_remove spaces from the beginning
      if [[ $indent_to_remove -gt 0 && ${#line} -ge $indent_to_remove ]]; then
        buffer+=("${line:$indent_to_remove}")
      else
        buffer+=("$line")
      fi
    fi
  done

  if [[ ${#buffer[@]} -eq 0 ]]; then
    printf "\n"
  else
    printf "%s\n" "${ stdlib_array_join -d $'\n' -a buffer; }"
  fi
}
