stdlib_url_join() {
  shopt -s extglob

  local joined_url="${1%%/}"
  shift

  for str in "$@"; do
    # Remove all leading slashes
    str="${str##*(/)}"

    # Remove all trailing slashes
    str="${str%%*(/)}"

    joined_url+="/${str}"
  done

  printf "%s\n" "$joined_url"
}
