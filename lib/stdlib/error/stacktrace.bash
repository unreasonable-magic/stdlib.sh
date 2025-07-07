stdlib_error_stacktrace() {
  local -i idx=1
  local -i length="${#BASH_SOURCE[@]}"
  local -r wd="$(pwd)/"

  while [[ "$idx" -lt "$length" ]]; do
    local source_file="${BASH_SOURCE[$idx]/"$wd"/}"
    local func_name="${FUNCNAME[$idx]}"
    local line_no="${BASH_LINENO[$idx - 1]}"

    printf "\e[33m%s\e[0m \e[30m%s:%s\e[0m\n" "$func_name" "$source_file" "$line_no" >&2

    ((idx++))
  done
}
