extname() {
  case "$1" in
    *.*)
      # Remove everything up to the last dot
      printf '%s\n' "${1##*.}"
      ;;
    *)
      # No extension
      printf '\n'
      ;;
  esac
}
