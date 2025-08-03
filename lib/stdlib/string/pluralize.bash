stdlib_import "string/singular"
stdlib_import "test"

stdlib_string_pluralize() {
  local word="$1"
  local count="$2"
  local pluralized=""

  # If count is provided, then only pluralize the word if required (so passing
  # `book 1` won't pluralize, but `book 2` will.
  if [[ -n "$count" ]]; then
    # Validate that count is a number
    if ! stdlib_test type/is_number "$count"; then
      echo "stdlib_string_pluralize: error: count must be a number, got: $count" >&2
      return 1
    fi
    
    # Check if count is exactly 1 (integer or float)
    if [[ "$count" == "1" ]] || [[ "$count" == "1.0" ]] || [[ "$count" =~ ^1\.0*$ ]]; then
      printf "%s\n" "$(stdlib_string_singular "$word")"
      return
    fi
    # For any other number (including 0, negative, or fractional), use plural
  fi

  case "$word" in
    "man")
      pluralized="men"
      ;;
    "woman")
      pluralized="women"
      ;;
    "child")
      pluralized="children"
      ;;
    "foot")
      pluralized="feet"
      ;;
    "tooth")
      pluralized="teeth"
      ;;
    "goose")
      pluralized="geese"
      ;;
    "mouse")
      pluralized="mice"
      ;;
    "person")
      pluralized="people"
      ;;
    "ox")
      pluralized="oxen"
      ;;
    *ss|*sh|*s|*ch|*x|*z)  # Words ending in s, ss, sh, ch, x, z -> add es
      pluralized="${word}es"
      ;;
    *[bcdfghjklmnpqrstvwxz]y) # Words ending in consonant + y -> change y to ies
      pluralized="${word%y}ies"
      ;;
    *f|*fe) # Words ending in f or fe -> change to ves
      pluralized="${word%f}ves"
      ;;
    *[bcdfghjklmnpqrstvwxz]o) # Words ending in consonant + o -> add es (simplified rule)
      pluralized="${word}es"
      ;;
    *) # Default: just add s
      pluralized="${word}s"
      ;;
  esac

  printf "%s\n" "$pluralized"
}
