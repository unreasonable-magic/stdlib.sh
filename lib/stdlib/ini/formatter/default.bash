stdlib_ini_formatter_default() {
  while IFS= read -r -d '' string; do
    # printf 'raw "%s"\n' "${string@Q}"
    IFS=$'\n' readarray -t token <<<"$string"
    #echo "token $token"
    #echo "data $data"

    echo -n -e "${token[1]}"
  done
  #local lines
  #lines=$(</dev/stdin)

  # while IFS= read -r token; do
  #   echo "token: $token"
  # done

  # echo "$lines"
}
