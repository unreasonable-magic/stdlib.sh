stdlib_test_exists() {
  [ -e "$1" ]
}

stdlib_test_is_dir() {
  [ -d "$1" ]
}

stdlib_test_is_file() {
  [ -f "$1" ]
}

stdlib_test_strempty() {
  [ -z "$1" ]
}

stdlib_test_is_command() {
  command -v "$1" 2>&1 >/dev/null
}
