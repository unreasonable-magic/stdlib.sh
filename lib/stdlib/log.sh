export LOG_LEVEL_DEBUG=10
export LOG_LEVEL_INFO=20
export LOG_LEVEL_WARN=30
export LOG_LEVEL_ERROR=40

log_init() {
  declare -g -i __log_current_level=$LOG_LEVEL_INFO
  declare -g __log_main_pid="$BASHPID"
}

START_TIME=${EPOCHREALTIME}
LAST_TIME=${START_TIME}

log() {
  local -i level=$1

  if [[ $__log_current_level -le $level ]]; then
    local message="$2"

    local current_time=${EPOCHREALTIME}

    # Calculate milliseconds using bash arithmetic (no subshells)
    local total_sec=${current_time%.*}
    local total_frac=${current_time#*.}
    # local start_sec=${START_TIME%.*}
    # local start_frac=${START_TIME#*.}
    local last_sec=${LAST_TIME%.*}
    local last_frac=${LAST_TIME#*.}

    # Convert to milliseconds and calculate differences
    local total_ms_now=$(((total_sec * 1000) + (10#$total_frac / 1000)))
    # local start_ms=$(((start_sec * 1000) + (10#$start_frac / 1000)))
    local last_ms=$(((last_sec * 1000) + (10#$last_frac / 1000)))

    # local total_elapsed=$((total_ms_now - start_ms))
    local delta_elapsed=$((total_ms_now - last_ms))

    # printf "Total: %dms | Delta: +%dms\n" "$total_elapsed" "$delta_elapsed"
    LAST_TIME=$current_time

    local level_str level_color
    case $level in
    "$LOG_LEVEL_DEBUG")
      level_str="DEBUG"
      level_color="38;5;250"
      ;;
    "$LOG_LEVEL_INFO")
      level_str="INFO "
      level_color="38;5;75"
      ;;
    "$LOG_LEVEL_WARN")
      level_str="WARN "
      level_color="38;5;208"
      ;;
    "$LOG_LEVEL_ERROR")
      level_str="ERROR"
      level_color="38;5;160"
      ;;
    esac

    local pidname="$BASHPID"
    if [[ "$pidname" == "$__log_main_pid" ]]; then
      pidname+="~main"
    fi

    printf "\e[38;5;240m+%03dms\e[0m \e[%sm[%s]\e[0m \e[38;5;183m[%s]\e[0m \e[38;5;251m%s\e[0m\n" \
      "$delta_elapsed" \
      "$level_color" \
      "$level_str" \
      "$pidname" \
      "$message" >&2
  fi
}

log_set_level() {
  case $1 in
  "$LOG_LEVEL_DEBUG")
    __log_current_level=$LOG_LEVEL_DEBUG
    ;;
  "$LOG_LEVEL_INFO")
    __log_current_level=$LOG_LEVEL_INFO
    ;;
  "$LOG_LEVEL_WARN")
    __log_current_level=$LOG_LEVEL_WARN
    ;;
  "$LOG_LEVEL_ERROR")
    __log_current_level=$LOG_LEVEL_ERROR
    ;;
  *)
    echo "unknown log level $1"
    exit 1
    ;;
  esac
}

log_debug() {
  log $LOG_LEVEL_DEBUG "$1"
}

log_info() {
  log $LOG_LEVEL_INFO "$1"
}

log_warn() {
  log $LOG_LEVEL_WARN "$1"
}

log_error() {
  log $LOG_LEVEL_ERROR "$1"
}
