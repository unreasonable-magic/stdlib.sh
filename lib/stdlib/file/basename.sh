stdlib_file_basename() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local filename="${1##*/}"

  if [ $# -eq 2 ]; then
    printf -v filename '%s' "${filename%${2#\*}}"
  fi

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$filename"
  else
    printf "%s\n" "${filename}"
  fi
}
