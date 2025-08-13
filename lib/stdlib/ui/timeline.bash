stdlib_import "terminal/palette"

stdlib_ui_timeline() {
  local -A item_status
  local -A item_texts
  local -A item_details
  local -a item_order
  local header=""
  local header_total=0
  local header_current=0
  local total_lines_printed=0
  local accumulating_details=false
  local accumulating_for=""

  local background="${ stdlib_terminal_palette_query "background"; }"
  
  # Hide cursor on start
  tput civis
  
  # Ensure cursor is shown on exit
  trap 'tput cnorm' EXIT
  
  # Function to render the entire timeline
  render_timeline() {
    local output=""
    local has_failure=false
    local all_complete=true
    local all_success=true
    
    # Check overall status
    for key in "${item_order[@]}"; do
      if [[ "${item_status[$key]}" == "fail" ]]; then
        has_failure=true
        all_success=false
      fi
      if [[ "${item_status[$key]}" == "pending" ]]; then
        all_complete=false
      fi
    done

    
    # Determine colors
    local dot_color line_color
    if [[ "$all_complete" == true ]]; then
      if [[ "$all_success" == true ]]; then
        dot_color="\033[32m"  # Green
        line_color="\033[32m"
      else
        dot_color="\033[31m"  # Red
        line_color="\033[31m"
      fi
    elif [[ "$has_failure" == true ]]; then
      dot_color="\033[31m"  # Red if any failure
      line_color="\033[31m"
    else
      dot_color="\033[33m"  # Yellow while running
      line_color="\033[33m"
    fi
    
    # Render header
    output+="${dot_color}⏺\033[0m \033[1m${header}\033[0m \033[90m${header_current}/${header_total}\033[0m\n"
    
    # Render each item
    for i in "${item_order[@]}"; do
      local status="${item_status[$i]}"
      local text="${item_texts[$i]}"
      local details="${item_details[$i]}"
      
      # Render main line
      if [[ "$status" == "success" ]]; then
        output+="${line_color}┃\033[0m \033[32m☑\033[0m ${text}\n"
      elif [[ "$status" == "fail" ]]; then
        output+="${line_color}┃\033[0m \033[31m☐\033[0m ${text}\n"
      else
        output+="${line_color}┃\033[0m ☐ ${text}\n"
      fi
      
      # Render detail lines if present
      if [[ -n "$details" ]]; then
        while IFS= read -r detail_line; do
          output+="${line_color}┃\033[0m   ${detail_line}\n"
        done <<< "$details"
      fi
    done
    
    printf "%s" "$output"
  }
  
  # Clear and rerender
  clear_and_render() {
    # Begin synchronized output
    printf "\033[?2026h"
    
    # Move cursor up to beginning of timeline
    if [[ $total_lines_printed -gt 0 ]]; then
      for ((i=0; i<$total_lines_printed; i++)); do
        tput cuu1
        tput el
      done
    fi
    
    # Render the timeline
    local output
    output=$(render_timeline)
    printf "%b" "$output"
    
    # End synchronized output
    printf "\033[?2026l"
    
    # Count lines printed (account for ANSI codes)
    total_lines_printed=$(printf "%b" "$output" | sed $'s/\x1b\\[[0-9;]*m//g' | wc -l)
  }
  
  while IFS= read -r line; do
    # If we're accumulating details, check if this line is a continuation
    if [[ "$accumulating_details" == true ]]; then
      # Check if this line starts a new command or is a continuation
      if [[ "$line" =~ ^(#|##)\ .+\ \[[0-9]+.*\]$ ]]; then
        # This is a new command, stop accumulating
        accumulating_details=false
        accumulating_for=""
      else
        # This is a continuation line - add to details
        if [[ -n "${item_details[$accumulating_for]}" ]]; then
          item_details["$accumulating_for"]+=$'\n'
        fi
        item_details["$accumulating_for"]+="$line"
        clear_and_render
        continue
      fi
    fi
    
    if [[ "$line" =~ ^#\ (.+)\ \[([0-9]+)/([0-9]+)\]$ ]]; then
      header="${BASH_REMATCH[1]}"
      header_current="${BASH_REMATCH[2]}"
      header_total="${BASH_REMATCH[3]}"
      
      # Initial render
      clear_and_render
      
    elif [[ "$line" =~ ^##\ (.+)\ \[([0-9]+)\]$ ]]; then
      local item_text="${BASH_REMATCH[1]}"
      local item_num="${BASH_REMATCH[2]}"
      
      item_status["$item_num"]="pending"
      item_texts["$item_num"]="$item_text"
      item_details["$item_num"]=""
      item_order+=("$item_num")
      
      clear_and_render
      
    elif [[ "$line" =~ ^##\ (.+)\ \[([0-9]+)=(success|fail)\]$ ]]; then
      local item_text="${BASH_REMATCH[1]}"
      local item_num="${BASH_REMATCH[2]}"
      local status="${BASH_REMATCH[3]}"
      
      item_status["$item_num"]="$status"
      item_texts["$item_num"]="$item_text"
      
      # Start accumulating details for this item
      accumulating_details=true
      accumulating_for="$item_num"
      
      # Update header counter
      local completed=0
      for key in "${item_order[@]}"; do
        if [[ "${item_status[$key]}" == "success" ]] || [[ "${item_status[$key]}" == "fail" ]]; then
          ((completed++))
        fi
      done
      header_current=$completed
      
      clear_and_render
    fi
  done
  
  # Ensure cursor is shown
  tput cnorm
}
