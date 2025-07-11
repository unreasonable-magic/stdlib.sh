enable kv

stdlib_ini_query() {
  if [[ $# -eq 0 ]]; then
    stdlib_error_warning "no query provided"
    return 1
  fi

  kv -s "="

  for query in "$@"; do
    printf "%s\n" "${KV[$query]}"
  done
}
