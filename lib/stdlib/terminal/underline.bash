stdlib_import "param/join"

enable kv

stdlib_terminal_underline() {
  # Turn the key=value params into an assoc array
  local -A args_kv
  kv -A args_kv -s "=" <<< "${ stdlib_param_join --delim $'\n' "$@"; }"

  # Loop through each key passed and add the relevant ansi sequences
  local ansi key value
  for key in "${!args_kv[@]}"; do
    value="${args_kv["$key"]}"

    case "$key" in
      # Handle style attributes
      # <ESC>[4:0m  # no underline
      # <ESC>[4:1m  # straight underline
      # <ESC>[4:2m  # double underline
      # <ESC>[4:3m  # curly underline
      # <ESC>[4:4m  # dotted underline
      # <ESC>[4:5m  # dashed underline
      style)
        case "$value" in
          straight)
            ansi+="\e[4:1m"
            ;;
          double)
            ansi+="\e[4:2m"
            ;;
          curly)
            ansi+="\e[4:3m"
            ;;
          dotted)
            ansi+="\e[4:4m"
            ;;
          dashed)
            ansi+="\e[4:5m"
            ;;
          *)
            stdlib_argparser error/invalid_arg "invalid style ${value}"
            return 1
        esac
        ;;
      # Handle color
      # <ESC>[58...m
      color)
        # Blank string will reset the color
        if [[ "${value}" == "" ]]; then
          ansi+="\e[59m"
        else
          ansi+="\e[4;91m"
        fi
        ;;
      *)
        stdlib_argparser error/invalid_arg "$key is not valid"
        ;;
    esac
  done

  printf "%b" "$ansi"
}
