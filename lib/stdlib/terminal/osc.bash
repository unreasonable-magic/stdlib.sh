stdlib_import "param/join"

declare -g -A __stdlib_terminal_osc=(
  # Window/Terminal Title Operations
  ["set_window_title"]="\e]0;"
  ["set_icon_name"]="\e]1;"
  ["set_window_title_only"]="\e]2;"

  # Color Operations - Query/Set Palette Colors (0-255)
  ["set_color"]="\e]4;" # format: 4;color
  ["reset_color"]="\e]104" # format: 104;color

  # Default Terminal Colors
  ["set_foreground"]="\e]10;"
  ["set_background"]="\e]11;"
  ["set_cursor"]="\e]12;"
  ["set_mouse_foreground"]="\e]13;"
  ["set_mouse_background"]="\e]14;"
  ["set_selection_foreground"]="\e]17;"
  ["set_selection_background"]="\e]19;"

  # Color Resets
  ["reset_foreground"]="\e]110"
  ["reset_background"]="\e]111"
  ["reset_cursor"]="\e]112"
  ["reset_mouse_foreground"]="\e]113"
  ["reset_mouse_background"]="\e]114"
  ["reset_selection_background"]="\e]117"
  ["reset_selection_foreground"]="\e]119"

  # Working Directory
  ["set_cwd"]="\e]7;"

  # Hyperlinks (modern terminals)
  ["hyperlink_start"]="\e]8;;" # format: id;url
  ["hyperlink_end"]="\e]8;;\e\\"

  # Clipboard Operations
  ["set_clipboard"]="\e]52;c;" # (base64 encoded)

  # Bell/Notification
  ["urgent_bell"]="\e]777;notify;" # format: title;body

  # Font Operations (limited support)
  ["set_font"]="\e]50;"

  # Profile/Session (iTerm2)
  ["set_profile"]="\e]1337;SetProfile="

  # Terminator
  ["st"]="\e\\"
  ["bel"]="\a"
)

stdlib_terminal_osc() {
  local key="$1"
  shift
  local IFS=";"
  printf "%b%s%b" "${__stdlib_terminal_osc["$key"]}" "$*" "${__stdlib_terminal_osc[bel]}"
}
