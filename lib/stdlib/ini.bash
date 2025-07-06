stdlib_import "ini/formatter/pretty"
stdlib_import "ini/formatter/colored"
stdlib_import "ini/formatter/tokens"
stdlib_import "ini/formatter/default"
stdlib_import "debugger"

#
#
# config::_parse_section() {
#   local section
#   section="$1"
#
#   # Remove the surrounding []
#   local contents
#   contents="${section//[\[\]]/}"
#
#   # Parse the section into it's key/value pair
#   IFS=' : ' read -r id value <<<"$contents"
#
#   # Validate the id
#   if [[ ! "$id" =~ $config_section_id_regex ]]; then
#     echo "invalid section id '$id' ($config_section_id_regex)"
#     exit 1
#   fi
#
#   __config_parse_section_return_id="$id"
#   __config_parse_section_return_value="$value"
# }
#
# config::_normalize_section() {
#   local id
#   id="$1"
#
#   local value
#   value="$2"
#
#   __config_normalize_section_return="[$id:$value]"
# }
#
# config::_parse_kv() {
#   local line
#   line="$1"
#
#   IFS=$' =' read -r key value <<<"$line"
#
#   if [[ "$key" =~ $config_section_key_regex ]]; then
#     __config_parse_kv_return_key="$key"
#     __config_parse_kv_return_value="$value"
#   else
#     echo "invalid key name \"$key\" ($config_section_key_regex)"
#     exit 1
#   fi
# }
#

export STDLIB_INI_TOKEN_COMMENT="comment"

export STDLIB_INI_TOKEN_KEY="kv_key"
export STDLIB_INI_TOKEN_OP="kv_op"
export STDLIB_INI_TOKEN_VAL="kv_val"

export STDLIB_INI_TOKEN_SECTION_START="sc_open"
export STDLIB_INI_TOKEN_SECTION_KEY="sc_key"
export STDLIB_INI_TOKEN_SECTION_OP="sc_op"
export STDLIB_INI_TOKEN_SECTION_VAL="sc_val"
export STDLIB_INI_TOKEN_SECTION_END="sc_end"

export STDLIB_INI_TOKEN_WS="ws"
export STDLIB_INI_TOKEN_NEWLINE="nl"

stdlib_ini_tokenizer() {
  #local -r lines="$(</dev/stdin)"

  stdlib_ini_tokenizer__token() {
    printf '%s\n%s\0' "$@"
  }

  stdlib_ini_tokenizer__maybe_ws() {
    if [[ "$1" != "" ]]; then
      printf '%s\n%s\0' \
        "$STDLIB_INI_TOKEN_WS" \
        "$1"
    fi
  }

  while IFS= read -r line; do

    # local stdlib_init_comment_regex="^#"
    # local stdlib_init_section_regex=""
    # local stdlib_init_section_key_regex=

    # These tests are ordered by potential frequency in the config files so we
    # can avoid unncessary regex calls
    #
    # declare -g -a __stdlib_ini_parse_line_return

    if [[ "$line" =~ ^([[:blank:]]+)?([a-zA-Z0-9_\-]+)([[:blank:]]+)?=([[:blank:]]+)?([^#]*)([[:blank:]]+)?(#(.+))?$ ]]; then

      stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[1]}"

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_KV_KEY" \
        "${BASH_REMATCH[2]}"

      stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[3]}"

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_KV_OP" \
        "="

      stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[4]}"

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_KV_VAL" \
        "${BASH_REMATCH[5]}"

      # stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[6]}"

    elif [[ "$line" =~ ^([[:blank:]]+)?\[([[:blank:]]+)?(.+)(:(.+))?([[:blank:]]+)?\]([[:blank:]]+)?$ ]]; then

      stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[1]}"

      stdlib_debugger

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_SECTION_START" \
        "["

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_SECTION" \
        "${BASH_REMATCH[2]}"

      printf '%s\n%s\0' \
        "$STDLIB_INI_TOKEN_SECTION_END" \
        "]"

      stdlib_ini_tokenizer__maybe_ws "${BASH_REMATCH[3]}"

    elif [[ "$line" =~ ^( )*#(.*)$ ]]; then

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_COMMENT" \
        "#${BASH_REMATCH[2]}"

    elif [[ "$line" =~ ^[[:blank:]]*$ ]]; then

      stdlib_ini_tokenizer__token \
        "$STDLIB_INI_TOKEN_WS" \
        "$line"

    else

      stdlib_error_fatal "dunno: ${line@Q}"

    fi

    printf '%s\n\\n\0' "$STDLIB_INI_TOKEN_NEWLINE"

    # echo "don't know hard to parse config line:"
    # echo "$line"
    # exit 1

  done

}
#
# config::_test_section() {
#   local test_id_query test_id_actual
#   test_id_query="$1"
#   test_id_actual="$2"
#
#   local test_value_query test_value_actual
#   test_value_query="$3"
#   test_value_actual="$4"
#
#   __config_test_section_return="true"
#
#   if [[ "$test_id_query" == "$test_id_actual" ]]; then
#     if [[ "$test_value_query" == "*" ]]; then
#       return
#     fi
#
#     if [[ "$test_value_query" == "$test_value_actual" ]]; then
#       return
#     fi
#
#     if [[ "${test_value_query:0:1}" == "~" ]]; then
#       local fuzzy_value_query="${test_value_query:1}"
#
#       if [[ "$fuzzy_value_query" == "$test_value_actual"* ]]; then
#         return
#       fi
#     fi
#   fi
#
#   __config_test_section_return="false"
# }

stdlib_ini() {
  local return_var
  if [[ "$1" == "-v" ]]; then
    return_var="$2"
    shift 2
  fi

  # Either get the file contents from stdin, or tret first var as filename
  # local str=""
  # if [ $# -gt 0 ]; then
  #   if [[ ! -e "$1" ]]; then
  #     echo "can't find config file: $1"
  #     return 1
  #   fi
  #   str="$(<"$1")"
  # else
  #   stdlib_ini_tokenizer | stdlib_ini_formatter_tokens
  # fi

  local formatter="stdlib_ini_formatter_tokens"

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
    --formatter | -f)
      case "$1" in
      default)
        formatter="stdlib_ini_formatter_default"
        ;;
      tokens)
        formatter="stdlib_ini_formatter_tokens"
        ;;
      pretty)
        formatter="stdlib_ini_formatter_pretty"
        ;;
      colored)
        formatter="stdlib_ini_formatter_colored"
        ;;
      raw)
        formatter="stdlib_ini_formatter_raw"
        ;;
      *)
        echo "unknown formatter $1"
        ;;
      esac
      shift
      ;;
    *)
      echo "unknonw option $arg"
      shift
      ;;
    esac
  done

  # stdlib_ini_tokenizer | "$formatter"
  stdlib_ini_tokenizer

  # local config_path
  # config_path="$1"

  # local section_search_query
  # section_search_query="${2:-}"

  # local section_search_id
  # section_search_id=""

  # local section_search_value
  # section_search_value=""

  # # Make sure we've got a valid section query
  # if [[ "$section_search_query" != "" ]]; then
  #   if [[ "$section_search_query" =~ $config_section_regex ]]; then
  #     # Parse the query and normalise it
  #     config::_parse_section "$section_search_query"

  #     section_search_id="${__config_parse_section_return_id}"
  #     section_search_value="${__config_parse_section_return_value}"
  #   else
  #     echo "'${section_search_query}' isnt' a valid section ($config_section_regex)"
  #     exit 1
  #   fi
  # fi

  # local -a config
  # config=()

  # By default we'll collect and return the whole config, but if you're
  # searching for a paticular value (or section) then it's off by default
  # local collecting_config
  # if [[ "$section_search_query" == "" ]]; then
  #   collecting_config="true"
  # else
  #   collecting_config="false"
  # fi

  # while IFS=$'\n' read -r line; do
  #   stdlib_ini_parse_line "$line"

  #   case "${__stdlib_ini_parse_line_return[0]}" in

  #   "$STDLIB_INI_TOKEN_WS")
  #     # Nothing to do here
  #     ;;

  #   "$STDLIB_INI_TOKEN_COMMENT") ;;

  #   "$STDLIB_INI_LINE_TYPE_SECTION")
  #     # Parse the line and normalize it
  #     ;;

  #   "$STDLIB_INI_LINE_TYPE_KV") ;;
  #   esac

  # done <<<"$str"

  # echo "$str" | stdlib_ini_formatter_colored

  # local config_with_newlines

  # if [[ "${#config[@]}" -gt 0 ]]; then
  #   # Join the config back together with newlines
  #   IFS=$'\n'
  #   config_with_newlines="${config[*]}"
  # else
  #   config_with_newlines=""
  # fi

  # if [[ -n "$return_var" ]]; then
  #   declare -g __stdlib_ini_parser_return="${config_with_newlines}"
  #   eval "$returnvar=\$__stdlib_ini_parser_return"
  #   unset __stdlib_ini_parser_return
  # else
  #   echo "$config_with_newlines"
  # fi
}
