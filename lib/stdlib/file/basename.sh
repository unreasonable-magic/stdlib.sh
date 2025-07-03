stdlib_file_basename() {
  local filename="${1##*/}"

  if [ $# -eq 2 ]; then
    printf '%s\n' "${filename%${2#\*}}"
  else
    printf '%s\n' "$filename"
  fi
}
