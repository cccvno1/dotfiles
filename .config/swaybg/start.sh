#!/bin/bash
# Swaybg startup script

# Default wallpaper directory
WALLPAPER_DIR="$HOME/.config/swaybg"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/wallpaper.png"
FALLBACK_COLOR="#282828"

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Set wallpaper or fallback to solid color
if [[ -f "$DEFAULT_WALLPAPER" ]]; then
    exec swaybg -i "$DEFAULT_WALLPAPER" -m fill
else
    exec swaybg -c "$FALLBACK_COLOR"
fi
