stdlib_import "string/trim"

stdlib_file_sanitizename() {
  shopt -s extglob

  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local escaped=""
  if [ $# -gt 0 ]; then
    escaped="$1"
  else
    escaped="$(
      cat </dev/stdin
      echo x
    )"
    escaped="${escaped%x}"
  fi

  stdlib_string_trim -v escaped "${escaped}"

  # Replace all non supported chars
  escaped="${escaped//[^a-zA-Z0-9À-ÿĀ-žƀ-ɏ\. ]/}"

  # Collapse multiple spaces into a single one
  escaped="${escaped//+( )/ }"

  # We can't return nothing, so if all we've got is a blank string, return
  # "file" - better than nothing!
  [[ "$escaped" == "" || "$escaped" == " " ]] && escaped="file"

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$escaped"
  else
    printf "%s\n" "${escaped}"
  fi

  return 0
}
