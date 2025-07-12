stdlib_import "array/join"
stdlib_import "string/repeat"
stdlib_import "string/pad"

declare -g -A __stdlib_ui_table_styles=(
  # ++-+
  # ++-+
  # || |
  # ++-+
  ["ascii"]="++-+++-+|| |++-+"

  # ====
  # ====
  # || |
  # ====
  ["ascii_double"]="========|| |===="

  # ┏┳━┓
  # ┣╋━┫
  # ┃┃ ┃
  # ┗┻━┛
  ["heavy"]="┏┳━┓┣╋━┫┃┃ ┃┗┻━┛"

  # ┌┬─┐
  # ├┼─┤
  # ││ │
  # └┴─┘
  ["light"]="┌┬─┐├┼─┤││ │└┴─┘"

  # ╭┬─╮
  # ├┼─┤
  # ││ │
  # ╰┴─╯
  ["light_rounded"]="╭┬─╮├┼─┤││ │╰┴─╯"

  # ╔╦═╗
  # ╠╬═╣
  # ║║ ║
  # ╚╩═╝
  ["double"]="╔╦═╗╠╬═╣║║ ║╚╩═╝"

  # ╒╤═╕
  # ╞╪═╡
  # ││ │
  # ╘╧═╛
  ["double_horizontal"]="╒╤═╕╞╪═╡││ │╘╧═╛"

  # ╓╥─╖
  # ╟╫─╢
  # ║║ ║
  # ╙╨─╜
  ["double_vertical"]="╓╥─╖╟╫─╢║║ ║╙╨─╜"

  # ████
  # ████
  # ██ █
  # ████
  ["blocks"]="██████████ █████"

  # ****
  # ****
  # ** *
  # ****
  ["stars"]="********** *****"

  # ####
  # ####
  # ## #
  # ####
  ["hash"]="########## #####"

  # ▲▲▲▲
  # ▼▼▼▼
  # ▼▼ ▼
  # ▲▲▲▲
  ["triangles"]="▲▲▲▲▼▼▼▼▼▼ ▼▲▲▲▲"

  # ◆◆◆◆
  # ◇◇◇◇
  # ◇◇ ◇
  # ◆◆◆◆
  ["diamonds"]="◆◆◆◆◇◇◇◇◇◇ ◇◆◆◆◆"

  # ○○○○
  # ●●●●
  # ●● ●
  # ○○○○
  ["circles"]="○○○○●●●●●● ●○○○○"

  # ◦◦◦◦
  # ◦◦◦◦
  # ◦◦ ◦
  # ◦◦◦◦
  ["circles_outline_small"]="◦◦◦◦◦◦◦◦◦◦ ◦◦◦◦◦"

  # ▫▫▫▫
  # ▪▪▪▪
  # ▪▪ ▪
  # ▫▫▫▫
  ["squares"]="▫▫▫▫▪▪▪▪▪▪ ▪▫▫▫▫"

  #
  #
  #
  #
  ["blank"]="                "

)

stdlib_ui_table_renderer() {
  local line_type_arg=""
  local column_widths_array_ref_arg="" column_data_array_ref_arg=""

  local style_arg="ascii"
  local -i cell_padding_left_arg=1
  local -i cell_padding_right_arg=1

  while [ $# -gt 0 ]; do
    case "$1" in
      --column-widths-array-ref)
        column_widths_array_ref_arg="$2"
        shift 2
        ;;
      --column-data-array-ref)
        column_data_array_ref_arg="$2"
        shift 2
        ;;
      --style)
        style_arg="$2"
        shift 2
        ;;
      --cell-padding-left)
        cell_padding_left_arg="$2"
        shift 2
        ;;
      --cell-padding-right)
        cell_padding_right_arg="$2"
        shift 2
        ;;
      --line-type)
        line_type_arg="$2"
        shift 2
        ;;
      *)
        stdlib_argparser error/invalid_arg "$@"
        return 1
        ;;
    esac
  done

  local chars="${__stdlib_ui_table_styles[$style_arg]:$line_type_arg:4}"

  local left_char="${chars:0:1}"
  local joiner_char="${chars:1:1}"
  local repeater_char="${chars:2:1}"
  local right_char="${chars:3:1}"

  declare -n column_widths="${column_widths_array_ref_arg}"
  local buffer=()

  if [[ "$column_data_array_ref_arg" != "" ]]; then
    local left_padding="${ stdlib_string_repeat "$repeater_char" "$cell_padding_left_arg"; }"
    local right_padding="${ stdlib_string_repeat "$repeater_char" "$cell_padding_left_arg"; }"

    declare -n column_data="${column_data_array_ref_arg}"
    local column_index=0
    for col in "${column_data[@]}"; do
      buffer+=("$left_padding${ stdlib_string_pad --width "${column_widths[column_index]}" "${col:-}"; }$right_padding")
      column_index=$((column_index+1))
    done
  else
    for width in "${column_widths[@]}"; do
      buffer+=("${ stdlib_string_repeat "$repeater_char" $(($width + $cell_padding_left_arg + $cell_padding_right_arg)); }")
    done
  fi

  printf "%s%s%s\n" "$left_char" "${ stdlib_array_join -d "$joiner_char" -a buffer; }" "$right_char"
}

stdlib_ui_table_renderer_styles() {
  for key in "${!__stdlib_ui_table_styles[@]}"; do
    printf "%s\n" "$key"
  done
}
