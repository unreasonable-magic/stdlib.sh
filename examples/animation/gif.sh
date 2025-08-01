#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "animation/timer"
stdlib_import "image"
stdlib_import "file/basename"

if [[ "$1" == "" ]]; then
  stdlib_error_log "missing gif, pass one of these filenames"
  for path in examples/animation/*.gif; do
    echo "$(stdlib_file_basename "$path")"
  done
  exit 1
fi

gif_name="$1"
if [[ ! "$gif_name" =~ \.gif$ ]]; then
  gif_name+=".gif"
fi

gif_path="./examples/animation/$gif_name"

if [[ ! -e "$gif_path" ]]; then
  stdlib_error_log "$gif_name doesn't exist"
  exit 1
fi

# todo: replace with ffprobe -v quiet -show_entries format:stream "examples/animation/baby64.gif"

gif_duration="$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$gif_path")"
gif_frame_count="$(ffprobe -v quiet -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of csv=p=0 "$gif_path")"
gif_frame_rate="$(ffprobe -v quiet -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$gif_path")"

gif_frames_dir="./tmp/gifs/$gif_name"
if [[ ! -d "$gif_frames_dir" ]]; then
  if ! mkdir -p "$gif_frames_dir"; then
    stdlib_error_fatal "cant make $gif_frames_dir"
  fi
fi

printf -v last_frame_filename "%s/frame_%0.3d.png" "$gif_frames_dir" "$gif_frame_count"

# gif_frame_count="$(ls -1 "$gif_frames_dir" | wc -l | stdlib string/trim)"
if [[ ! -e "$last_frame_filename" ]]; then
  if ! ffmpeg -i "$gif_path" "$gif_frames_dir/frame_%03d.png" 2>/dev/null; then
    stdlib_error_fatal "cant make frames"
  fi
fi

gif_dimensions="$(stdlib_image_dimensions "$last_frame_filename")"
IFS=' ' read -r width height <<<"$gif_dimensions"

stdlib ui/alert info --icon "󰵸" <<EOF
# $gif_name

Path: $gif_path
Duration: $gif_duration
Dimensions: $width x $height
Frame Dir: $gif_frames_dir
Frame Count: $gif_frame_count
Frame Rate: $gif_frame_rate
EOF

printf "\n"

stdlib terminal/cursor visible=false >/dev/null

stdlib_animation_timer --duration "${gif_duration}s" --fps "${gif_frame_rate}" --loop |
  while read -r frame; do
    printf "\e[?2026h"
    printf "\e_Ga=d\e\\"

    printf -v frame_png "%s/frame_%0.3d.png" "$gif_frames_dir" "$frame"

    full_frame_path=$(realpath "$frame_png")
    stdlib_image_print "$full_frame_path" "${width}px" "${height}px"
    printf "\e[?2026l"
  done

stdlib terminal/cursor visible=true >/dev/null
