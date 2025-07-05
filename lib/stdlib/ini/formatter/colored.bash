
stdlib_ini_formatter_colored() {
  while IFS= read -r -d '' string; do
    # printf 'raw "%s"\n' "${string@Q}"
    IFS=$'\n' readarray -t token <<< "$string"
    #echo "token $token"
    #echo "data $data"
    case "${token[0]}" in
      "$STDLIB_INI_TOKEN_KV")
        printf "kv"
        ;;
      "$STDLIB_INI_TOKEN_SECTION")
        printf "section"
        ;;
      "$STDLIB_INI_TOKEN_COMMENT")
        printf "#%s" "${token[1]}"
        ;;
      "$STDLIB_INI_TOKEN_WS")
        printf "%s" "${token[1]}"
        ;;
      "$STDLIB_INI_TOKEN_NL")
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
