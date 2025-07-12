stdlib_string_count() {
  if [[ $# -lt 2 ]]; then
    stdlib_argparser error/length_mismatch 2
    return 1
  fi

  local string="$1"
  local substring="$2"
  local with_substring_removed="${string//"${substring}"/}"

  local -i new_length=$((${#string} - ${#with_substring_removed}))

  if [[ $new_length -eq 0 ]]; then
    printf "0\n"
  else
    printf "%s\n" $((new_length / ${#substring}))
  fi
}
