stdlib_ini_formatter_colored() {
  while IFS= read -r -d '' string; do
    # printf 'raw "%s"\n' "${string@Q}"
    IFS=$'\n' readarray -t token <<<"$string"
    #echo "token $token"
    #echo "data $data"
    case "${token[0]}" in
    "$STDLIB_INI_TOKEN_KV_KEY")
      printf "\e[34m%s\e[0m" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_KV_OP")
      printf "%s" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_KV_VAL")
      printf "\e[32m%s\e[0m" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_SECTION")
      printf "[%s]" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_COMMENT")
      printf "\e[2m%s\e[0m" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_WS")
      printf "%s" "${token[1]}"
      ;;
    "$STDLIB_INI_TOKEN_NEWLINE")
      printf "\n"
      ;;
    esac
  done
  #local lines
  #lines=$(</dev/stdin)

  # while IFS= read -r token; do
  #   echo "token: $token"
  # done

  # echo "$lines"
}
