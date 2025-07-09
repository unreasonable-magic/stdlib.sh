#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "animation/timer"
stdlib_import "image"
stdlib_import "file/basename"

gif_path="./examples/animation/baby64.gif"

gif_name=""
stdlib_file_basename -v gif_name "$gif_path"

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

shopt -s nullglob

# stdlib_animation_timer --duration 5s --fps 1 | while read -r frame; do
#   echo "frame $frame / $total"
# done
#
# exit

stdlib screen/cursor visible=false >/dev/null

for file in "$gif_frames_dir"/*; do

  printf "\e[?2026h"
  printf "\e_Ga=d\e\\"
  full_frame_path=$(realpath "$file")
  stdlib_image_print "$full_frame_path" "${width}px" "${height}px"
  printf "\e[?2026l"

  sleep 0.1

done

stdlib screen/cursor visible=true >/dev/null
