stdlib_string_singular() {
  local word="$1"
  local singular=""

  case "$word" in
    "men")
      singular="man"
      ;;
    "women")
      singular="woman"
      ;;
    "children")
      singular="child"
      ;;
    "feet")
      singular="foot"
      ;;
    "teeth")
      singular="tooth"
      ;;
    "geese")
      singular="goose"
      ;;
    "mice")
      singular="mouse"
      ;;
    "people")
      singular="person"
      ;;
    "oxen")
      singular="ox"
      ;;
    *sses|*shes|*ches|*xes|*zes)  # Words ending in sses, shes, ches, xes, zes -> remove es
      singular="${word%es}"
      ;;
    *uses|*ises|*oses|*ases)  # Words ending in uses, ises, oses, ases (like houses, horses, etc)
      singular="${word%s}"
      ;;
    *ses)  # Words ending in ses - for words like "glasses", "passes"
      singular="${word%es}"
      ;;
    *ies) # Words ending in ies -> change to y
      if [[ "${word%ies}" =~ [bcdfghjklmnpqrstvwxz]$ ]]; then
        singular="${word%ies}y"
      else
        # If it doesn't end in consonant+ies, just remove s
        singular="${word%s}"
      fi
      ;;
    *ves) # Words ending in ves -> change to f or fe
      # Try to determine if it was f or fe
      local stem="${word%ves}"
      # Common words ending in fe: wife, knife, life
      if [[ "$stem" =~ (wi|kni|li)$ ]]; then
        singular="${stem}fe"
      else
        singular="${stem}f"
      fi
      ;;
    *oes) # Words ending in consonant + oes -> remove es
      if [[ "${word%oes}" =~ [bcdfghjklmnpqrstvwxz]$ ]]; then
        singular="${word%es}"
      else
        singular="${word%s}"
      fi
      ;;
    *es) # Handle -es endings that don't match other patterns
      # For words like "houses", "horses", etc.
      singular="${word%s}"
      ;;
    *s) # Default: remove s
      singular="${word%s}"
      ;;
    *) # Already singular
      singular="$word"
      ;;
  esac

  printf "%s\n" "$singular"
}