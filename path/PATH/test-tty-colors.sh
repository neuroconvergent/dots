#!/bin/bash
# Preview ANSI colours and Ly-style 0xSSRRGGBB values

echo "=== ANSI 16 colours (0-15) ==="
for i in {0..15}; do
    printf "\e[38;5;%sm %3s \e[0m" "$i" "$i"
    if (( i % 8 == 7 )); then echo; fi
done
echo

# Function to show a Ly-style colour
# Arg1: Hex in 0xSSRRGGBB format
show_ly_color() {
    local val=$1
    # Extract RGB
    local hex=${val:4}   # last 6 chars are RRGGBB
    local rr=${hex:0:2}
    local gg=${hex:2:2}
    local bb=${hex:4:2}
    printf "%-12s (RGB #%s%s%s) -> " "$val" "$rr" "$gg" "$bb"
    # Print with truecolor escape (works on capable consoles, falls back otherwise)
    printf "\e[38;2;$((16#$rr));$((16#$gg));$((16#$bb))m██████████\e[0m\n"
}

echo "=== Test your Ly-style colours ==="
# Your intended colors
show_ly_color 0x00DFAFAF   # dusty pink
show_ly_color 0x00D7875F   # warm orange
show_ly_color 0x008CAAEE   # pastel blue

# Recommended ANSI-bright approximations
show_ly_color 0x40FF00FF   # bright magenta (pink)
show_ly_color 0x40FFFF00   # bright yellow (orange-ish)
show_ly_color 0x400000FF   # bright blue
