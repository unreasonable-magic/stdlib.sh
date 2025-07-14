stdlib_string_pluralize() {
  local word="$1"
  local pluralized=""

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
