# stdlib_maths_repl - Interactive REPL mode for stdlib_maths
#
# This module provides an interactive Read-Eval-Print Loop (REPL) for mathematical expressions.
# It maintains state between expressions, allowing variables to persist across evaluations.
#
# Features:
#   - Interactive prompt when connected to a terminal
#   - Supports piped input for batch processing
#   - Variable persistence between expressions
#   - Access to previous result via _ variable
#   - Exit via 'exit', 'quit', or Ctrl+C
#
# Usage:
#   stdlib_maths_repl [format]
#   
# Arguments:
#   format - Output format: 'number' (default), 'percentage', or 'duration'
#
# Examples:
#   stdlib_maths_repl                    # Start interactive REPL
#   echo "1 + 1" | stdlib_maths_repl    # Process from stdin
#   stdlib_maths_repl percentage         # REPL with percentage output

stdlib_maths_repl() {
  local format="${1:-number}"  # Default to number format
  shift
  
  # Initialize global session variables to track assignments and previous result
  declare -g _stdlib_repl_vars=""
  declare -g _stdlib_previous_result=""
  
  echo "stdlib_maths interactive mode (Ctrl+C or 'exit' to quit)"
  echo "Examples: 1 + 1, sin(PI/2), 5 > 3, isnan(5), foo = 1 + 2"
  echo ""
  
  local expression
  local saved_terminal_state
  
  # Save initial terminal state if running interactively
  if [[ -t 0 ]]; then
    saved_terminal_state=$(stty -g 2>/dev/null)
  fi
  
  while true; do
    # Only show prompt if stdin is a terminal
    if [[ -t 0 ]]; then
      printf "maths> "
    fi
    
    if ! read -r expression; then
      # EOF reached
      if [[ -t 0 ]]; then
        echo ""
      fi
      break
    fi
    
    # Skip empty lines
    [[ -z "$expression" ]] && continue
    
    # Exit commands
    if [[ "$expression" == "exit" ]] || [[ "$expression" == "quit" ]]; then
      break
    fi
    
    # Process the expression with REPL flag (using global variables)
    # Arguments: expression, is_repl, dry_run, quiet, exit_code_mode, format, remaining args
    _stdlib_maths_eval "$expression" true false false false "$format" "$@"
    
    # Restore terminal state after evaluation if running interactively
    if [[ -t 0 ]] && [[ -n "$saved_terminal_state" ]]; then
      stty "$saved_terminal_state" 2>/dev/null
    fi
  done
  
  return 0
}