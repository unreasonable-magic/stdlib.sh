stdlib_import "string/strip_prefix"
stdlib_import "string/strip_suffix"
stdlib_import "string/dedent"

stdlib_function_code() {
  local no_declare=false
  local function_name

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-declare)
        no_declare=true
        shift
        ;;
      *)
        function_name="$1"
        shift
        break
        ;;
    esac
  done

  if [[ -z "$function_name" ]]; then
    echo "Error: Function name required" >&2
    return 1
  fi

  local code
  code="${ declare -f "$function_name"; }"

  if [[ -z "$code" ]]; then
    echo "Error: Function '$function_name' not found" >&2
    return 1
  fi

  if [[ "$no_declare" == true ]]; then
    # Remove function declaration line and opening brace
    code="${ stdlib_string_strip_prefix "$code" "$function_name () "$'\n'"{"; }"

    # Remove closing brace
    code="${ stdlib_string_strip_suffix "$code" "}"; }"

    # Dedent the code
    code="${ stdlib_string_dedent "$code"; }"
  fi

  printf "%s\n" "$code"
}
