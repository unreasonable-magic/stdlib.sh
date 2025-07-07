#!/bin/bash

draw_rounded_box() {
    local width=40
    local height=10
    local title=""
    local color=""
    local content=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -w|--width)
                width="$2"
                shift 2
                ;;
            -h|--height)
                height="$2"
                shift 2
                ;;
            -t|--title)
                title="$2"
                shift 2
                ;;
            -c|--color)
                color="$2"
                shift 2
                ;;
            *)
                content="$1"
                shift
                ;;
        esac
    done

    # Validate dimensions
    if [[ $width -lt 3 || $height -lt 3 ]]; then
        echo "Error: Width and height must be at least 3" >&2
        return 1
    fi

    # Color codes using printf \e syntax
    local color_code=""
    local reset=""

    if [[ -n "$color" ]]; then
        reset=$(printf '\e[0m')
        case $color in
            red)     color_code=$(printf '\e[31m') ;;
            green)   color_code=$(printf '\e[32m') ;;
            yellow)  color_code=$(printf '\e[33m') ;;
            blue)    color_code=$(printf '\e[34m') ;;
            magenta) color_code=$(printf '\e[35m') ;;
            cyan)    color_code=$(printf '\e[36m') ;;
            white)   color_code=$(printf '\e[37m') ;;
            *)       color_code="" ;;
        esac
    fi

    # Unicode box drawing characters
    local top_left="╭"
    local top_right="╮"
    local bottom_left="╰"
    local bottom_right="╯"
    local horizontal="─"
    local vertical="│"

    # Calculate inner width
    local inner_width=$((width - 2))

    # Create horizontal line
    local hline=""
    for ((i = 0; i < inner_width; i++)); do
        hline+="$horizontal"
    done

    # Top border with optional title
    if [[ -n "$title" ]]; then
        local title_len=${#title}

        if [[ $title_len -gt $((inner_width - 4)) ]]; then
            # Title too long, truncate
            title="${title:0:$((inner_width - 4))}"
            title_len=${#title}
        fi

        local padding_total=$((inner_width - title_len - 2))
        local padding_left=$((padding_total / 2))
        local padding_right=$((padding_total - padding_left))

        local left_line=""
        local right_line=""

        for ((i = 0; i < padding_left; i++)); do
            left_line+="$horizontal"
        done

        for ((i = 0; i < padding_right; i++)); do
            right_line+="$horizontal"
        done

        local small_text=$(printf '\e[11m')
        local normal_text=$(printf '\e[10m')
        printf "%s%s%s %s%s%s %s%s%s%s\n" "$color_code" "$top_left" "$left_line" "$small_text" "$title" "$normal_text" "$right_line" "$top_right" "$reset"
    else
        # No title, just horizontal line
        printf "%s%s%s%s%s\n" "$color_code" "$top_left" "$hline" "$top_right" "$reset"
    fi

    # Split content into lines
    local content_lines=()
    if [[ -n "$content" ]]; then
        while IFS= read -r line; do
            content_lines+=("$line")
        done <<< "$content"
    fi

    # Middle rows
    local content_height=$((height - 2))
    for ((i = 0; i < content_height; i++)); do
        printf "%s%s" "$color_code" "$vertical"

        if [[ $i -lt ${#content_lines[@]} ]]; then
            # Line with content
            local line="${content_lines[i]}"
            if [[ ${#line} -gt $inner_width ]]; then
                # Truncate if too long
                line="${line:0:$inner_width}"
            fi
            printf "%-*s" $inner_width "$line"
        else
            # Empty line
            printf "%*s" $inner_width ""
        fi

        printf "%s%s\n" "$vertical" "$reset"
    done

    # Bottom border
    printf "%s%s%s%s%s\n" "$color_code" "$bottom_left" "$hline" "$bottom_right" "$reset"
}

# Example usage:
echo "Basic box:"
draw_rounded_box

echo -e "\n Box with title:"
draw_rounded_box -t "My Title" -w 30 -h 6

echo -e "\nColored box with content:"
draw_rounded_box -t " Status" -c red -w 25 -h 8 "System is running
All services OK
Memory: 65%
CPU: 23%"

echo -e "\nBlue box with custom dimensions:"
draw_rounded_box -c blue -w 50 -h 5 "This is a wider box with blue borders"
