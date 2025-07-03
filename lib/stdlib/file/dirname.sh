stdlib_file_dirname() {
  case "$1" in
  */*) printf '%s\n' "${1%/*}" ;;
  *) printf '.\n' ;;
  esac
}
