stdlib_ini_formatter_tokens() {
  while IFS= read -r -d '' string; do
    IFS=$'\n' readarray -t token <<< "$string"

    local -a data=()
    for d in "${token[@]:1}"; do
      printf -v d "%s" "${d@Q}"
      data+=("$d")
    done

    IFS="," printf "%s{%s} " "${token[0]}" "${data[*]}"
  done

  printf "\n"
}
