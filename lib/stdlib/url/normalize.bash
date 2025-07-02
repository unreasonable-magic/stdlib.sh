stdlib::import "url/parse"
stdlib::import "error"

urlnormalize() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local -r url="$1"
  shift 1

  local basevar
  for arg in "${@}"; do
    local value="${arg#*=}"
    case "$arg" in
      "--base="*)
        basevar="${value}"
        ;;
      "--base")
        basevar="$2"
        break
        ;;
      *)
        stdlib::error::fatal "invalid arg $arg"
        ;;
    esac
    shift
  done

  local base_scheme base_host base_port
  if [[ -n "${basevar}" ]]; then
    read -r base_scheme base_host base_port < <(urlparse "$basevar" --scheme --host --port)
    readarray -t parts < <(urlparse "$basevar" --scheme --host --port)
    local base_scheme="${parts[0]}"
    local base_host="${parts[1]}"
    local base_port="${parts[2]}"
  fi

  readarray -t parts < <(urlparse "$url" --scheme --host --port --path --query --fragment)
  local scheme="${parts[0]}"
  local host="${parts[1]}"
  local port="${parts[2]}"
  local path="${parts[3]}"
  local query="${parts[4]}"
  local fragment="${parts[5]}"

  # Figure out which scheme to use
  if [[ -z "${scheme}" ]]; then
    if [[ "${port}" == 433 ]]; then
      scheme="https"
      port=""
    else
      if [[ -n "$base_scheme" ]]; then
        scheme="${base_scheme}"
      else
        stdlib::error::warning "no scheme provided in --base, defaulting to http"
        scheme="http"
        port=""
      fi
    fi
  fi

  # Remove standard ports
  if [[ "$port" == "80" || "$port" == "443" ]]; then
    port=""
  fi

  # Fill in host
  if [[ -z "${host}" ]]; then
    if [[ -n "$base_host" ]]; then
      host="${base_host}"
    else
      host=""
      stdlib::error::warning "no host provided in --base, defaulting to blank"
    fi
  fi

  # Remove / from end of path
  path="${path%/}"

  local normalized="${scheme,,}://${host,,}${path}${query}${fragment}"

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$normalized"
  else
    printf "%s\n" "${normalized}"
  fi

  return 0
}
