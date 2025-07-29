stdlib_import "argparser"
stdlib_import "color"

enable kv

declare -A -g __stdlib_terminal_text_ansi_flags=(
  [bold]="1"
  [bold_reset]="221"
  [dim]="2"
  [dim_reset]="222"
  # https://sw.kovidgoyal.net/kitty/misc-protocol/#independent-control-of-bold-and-faint-sgr-properties
  #
  # > In common terminal usage, bold is set via SGR 1 and faint by SGR 2.
  # > However, there is only one number to reset these attributes, SGR 22, which
  # > resets both. There is no way to reset one and not the other. kitty uses 221
  # > and 222 to reset bold and faint independently.
  #
  # [dim_reset]="22"
  # [bold_reset]="22"
  [italic]="3"
  [italic_reset]="23"
  [underline]="4"
  [underline_reset]="24"
  [blinking]="5"
  [blinking_reset]="25"
  [inverse]="7"
  [inverse_reset]="27"
  [hidden]="8"
  [hidden_reset]="28"
  [strikethrough]="9"
  [strikethrough_reset]="29"
)

stdlib_terminal_text() {
  # Parse the params and convert them into an assoc array, so params like this:
  # 
  #     bold foreground=blue dim
  #
  # Transform into:
  #
  #     (
  #       ['bold']=''
  #       ['foreground']='blue'
  #       ['dim']=''
  #     )
  #
  local input="${| stdlib_argparser_parse "$@"; }"
  kv -s "=" <<< "$input"

  # Loop through each member of the assoc array and collect all the ansi codes
  # as instructed by the keys of the array
  local ansi key value
  for key in "${!KV[@]}"; do
    value="${KV[$key]}"

    case "$key" in
      # 0 resets all the things
      reset)
        ansi+="0;"
        ;;

      # Handle basic instructrions
      bold|italic|dim|blinking|inverse|hidden|strikethrough)
        if [[ "$value" == "" || "$value" == "true" ]]; then
          ansi+="${__stdlib_terminal_text_ansi_flags["$key"]};"
        elif [[ "$value" == "false" ]]; then
          ansi+="${__stdlib_terminal_text_ansi_flags["${key}_reset"]};"
        else
          stdlib_argparser error/invalid_arg "$value is invalid for $key"
        fi
        ;;

      # https://sw.kovidgoyal.net/kitty/underlines/
      underline)
        case "$value" in
          ""|true|straight)
            ansi+="${__stdlib_terminal_text_ansi_flags["$key"]};"
            ;;
          false)
            ansi+="${__stdlib_terminal_text_ansi_flags["${key}_reset"]};"
            ;;
          double)
            ansi+="4:2;"
            ;;
          curly)
            ansi+="4:3;"
            ;;
          dotted)
            ansi+="4:4;"
            ;;
          dashed)
            ansi+="4:5;"
            ;;
          *)
            stdlib_argparser error/invalid_arg "$value is invalid for $key"
            ;;
          esac
        ;;

      foreground|background|underline_color)
        if [[ "$value" == "false" ]]; then
          case "$key" in
            foreground)
              ansi+="39;"
              ;;
            background)
              ansi+="49;"
              ;;
            underline_color)
              ansi+="59;"
              ;;
          esac
        else
          value="${ stdlib_color --format ansi "$value"; }"
          if [[ ! $? -eq 0 ]]; then
            return 1
          fi

          case "$key" in
            foreground)
              ansi+="38;$value"
              ;;
            background)
              ansi+="48;$value"
              ;;
            underline_color)
              ansi+="58;$value"
              ;;
          esac
        fi
        ;;

      *)
        stdlib_argparser error/invalid_arg "$key"
        return 1
        ;;
    esac
  done

  printf "\e[%sm" "$ansi"
}
