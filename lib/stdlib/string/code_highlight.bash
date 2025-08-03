#!/usr/bin/env bash

stdlib_import "terminal/text"

stdlib_string_code_highlight() {
  local input="${| stdlib_argparser_parse -- "$@"; }"
  
  if [[ -z "$input" ]]; then
    return 0
  fi
  
  local result="$input"
  
  # Use placeholders first to avoid sed conflicts with ANSI codes
  local string_placeholder="__STRING_COLOR__"
  local number_placeholder="__NUMBER_COLOR__"
  local boolean_placeholder="__BOOLEAN_COLOR__"
  local comment_placeholder="__COMMENT_COLOR__"
  local keyword_placeholder="__KEYWORD_COLOR__"
  local operator_placeholder="__OPERATOR_COLOR__"
  local reset_placeholder="__RESET_COLOR__"
  
  # Check if this is a full comment line first - if so, just highlight the whole line
  if [[ "$result" =~ ^[[:space:]]*(\/\/|#) ]]; then
    result=$(echo "$result" | sed -E "s/^([[:space:]]*)(\/\/|#)(.*)$/\1${comment_placeholder}\2\3${reset_placeholder}/")
  else
    # Apply syntax highlighting for non-full-comment lines
    
    # Highlight strings (both single and double quoted)
    result=$(echo "$result" | sed "s/\"[^\"]*\"/${string_placeholder}&${reset_placeholder}/g")
    result=$(echo "$result" | sed "s/'[^']*'/${string_placeholder}&${reset_placeholder}/g")
    
    # Highlight boolean values (true/false)
    result=$(echo "$result" | sed -E "s/([^a-zA-Z0-9_])(true|false)([^a-zA-Z0-9_]|$)/\1${boolean_placeholder}\2${reset_placeholder}\3/g")
    result=$(echo "$result" | sed -E "s/^(true|false)([^a-zA-Z0-9_]|$)/${boolean_placeholder}\1${reset_placeholder}\2/")
    
    # Highlight common keywords (language-agnostic)
    result=$(echo "$result" | sed -E "s/([^a-zA-Z0-9_])(if|else|for|while|function|def|let|const|var|return|null|undefined|nil)([^a-zA-Z0-9_]|$)/\1${keyword_placeholder}\2${reset_placeholder}\3/g")
    result=$(echo "$result" | sed -E "s/^(if|else|for|while|function|def|let|const|var|return|null|undefined|nil)([^a-zA-Z0-9_]|$)/${keyword_placeholder}\1${reset_placeholder}\2/")
    
    # Highlight numbers first (integers and decimals, including negative numbers)
    # This ensures numbers get highlighted before operators interfere
    result=$(echo "$result" | sed -E "s/([^a-zA-Z0-9_\.])(-?[0-9]+\.?[0-9]*)([^a-zA-Z0-9_\.]|$)/\1${number_placeholder}\2${reset_placeholder}\3/g")
    result=$(echo "$result" | sed -E "s/^(-?[0-9]+\.?[0-9]*)([^a-zA-Z0-9_\.]|$)/${number_placeholder}\1${reset_placeholder}\2/")
    # Handle decimal numbers that are standalone (entire string is just a number)
    result=$(echo "$result" | sed -E "s/^([0-9]+\.[0-9]+)$/${number_placeholder}\1${reset_placeholder}/")
    # Handle numbers directly adjacent to operators like =3 or 3+ or +4
    result=$(echo "$result" | sed -E "s/(=)([0-9]+\.?[0-9]*)/\1${number_placeholder}\2${reset_placeholder}/g")
    result=$(echo "$result" | sed -E "s/([0-9]+\.?[0-9]*)([+\\*\\/\\-])/${number_placeholder}\1${reset_placeholder}\2/g")
    result=$(echo "$result" | sed -E "s/([+\\*\\/\\-])([0-9]+\.?[0-9]*)/\1${number_placeholder}\2${reset_placeholder}/g")
    
    # Now highlight operators (after numbers are highlighted)
    result=$(echo "$result" | sed -E "s/(==|!=|<=|>=|&&|\|\||\\+\\+|--|\\+=|-=|\\*=|\/=)/${operator_placeholder}\1${reset_placeholder}/g")
    result=$(echo "$result" | sed -E "s/([^=!<>+\\*\/&|])(=|\\+|-|\\*|\/|<|>)([^=+\\*\/&|])/\1${operator_placeholder}\2${reset_placeholder}\3/g")
    # Also handle operators at the beginning or end of expressions
    result=$(echo "$result" | sed -E "s/^(=|\\+|-|\\*|\/|<|>)([^=+\\*\/&|])/${operator_placeholder}\1${reset_placeholder}\2/")
    result=$(echo "$result" | sed -E "s/([^=!<>+\\*\/&|])(=|\\+|-|\\*|\/|<|>)$/\1${operator_placeholder}\2${reset_placeholder}/")
    
    # Finally, highlight inline comments (after all other highlighting)
    result=$(echo "$result" | sed -E "s/(\/\/.*$)/${comment_placeholder}\1${reset_placeholder}/")
    result=$(echo "$result" | sed -E "s/(#.*$)/${comment_placeholder}\1${reset_placeholder}/")
  fi
  
  # Get ANSI codes using stdlib_terminal_text with fallback to direct codes
  local string_color number_color boolean_color comment_color keyword_color operator_color reset_code
  
  # Try to use stdlib_terminal_text, fallback to direct ANSI if it fails
  if string_color=$(stdlib_terminal_text foreground=xterm:green 2>/dev/null); then
    number_color=$(stdlib_terminal_text foreground=xterm:pink1 2>/dev/null)
    boolean_color=$(stdlib_terminal_text foreground=xterm:orange1 2>/dev/null)
    comment_color=$(stdlib_terminal_text foreground=xterm:grey50 2>/dev/null)
    keyword_color=$(stdlib_terminal_text foreground=xterm:cyan 2>/dev/null)
    operator_color=$(stdlib_terminal_text foreground=xterm:yellow 2>/dev/null)
    reset_code=$(stdlib_terminal_text reset 2>/dev/null)
  else
    # Fallback to direct ANSI codes if stdlib_terminal_text fails
    string_color=$'\e[38;5;2m'     # xterm green
    number_color=$'\e[38;5;218m'   # xterm pink1
    boolean_color=$'\e[38;5;214m'  # xterm orange1
    comment_color=$'\e[38;5;244m'  # xterm grey50
    keyword_color=$'\e[38;5;6m'    # xterm cyan
    operator_color=$'\e[38;5;3m'   # xterm yellow
    reset_code=$'\e[0m'            # reset
  fi
  
  # Replace placeholders with actual ANSI codes
  result=${result//$string_placeholder/$string_color}
  result=${result//$number_placeholder/$number_color}
  result=${result//$boolean_placeholder/$boolean_color}
  result=${result//$comment_placeholder/$comment_color}
  result=${result//$keyword_placeholder/$keyword_color}
  result=${result//$operator_placeholder/$operator_color}
  result=${result//$reset_placeholder/$reset_code}
  
  printf "%s\n" "$result"
}