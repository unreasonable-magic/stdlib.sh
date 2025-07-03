if [[ "${BASH_VERSION:0:1}" == "3" ]]; then
  stdlib_string_downcase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
  }
else
  stdlib_string_downcase() {
    echo "${1,,}"
  }
fi

stdlib_string_underscore() {
  echo "${1// /_}"
}
