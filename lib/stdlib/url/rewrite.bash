stdlib_import "url/parse"
stdlib_import "argparser"

stdlib_url_rewrite() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local url="$1"
  shift

  readarray -t parts < <(stdlib_url_parse "$url" --scheme --host --port --path --query --fragment)

  for arg in "${@}"; do
    local value="${arg#*=}"
    case "$arg" in
    "--scheme="*)
      parts[0]="${value}"
      ;;
    "--host="*)
      parts[1]="${value/\//}"
      ;;
    "--port="*)
      parts[2]="${value}"
      ;;
    "--path="*)
      parts[3]="${value}"
      ;;
    "--query="*)
      parts[4]="${value}"
      ;;
    "--fragment="*)
      parts[5]="${value}"
      ;;
    *)
      stdlib_argparser error/invalid_arg "$arg"
      return 1
      ;;
    esac
  done

  # Some very boring but neccessary normalization of url parts.
  [[ -n ${parts[0]} && "${parts[0]}" != *"://" ]] && parts[0]="${parts[0]}://"
  [[ -n ${parts[2]} && "${parts[2]:0:1}" != ":" ]] && parts[2]=":${parts[2]}"
  [[ -n ${parts[3]} && "${parts[3]:0:1}" != "/" ]] && parts[3]="/${parts[3]}"
  [[ -n ${parts[4]} && "${parts[4]:0:1}" != "?" ]] && parts[4]="?${parts[4]}"
  [[ -n ${parts[5]} && "${parts[5]:0:1}" != "#" ]] && parts[5]="#${parts[5]}"

  local IFS=''
  local new_url="${parts[*]}"

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$new_url"
  else
    printf "%s\n" "${new_url}"
  fi

  return 0
}
