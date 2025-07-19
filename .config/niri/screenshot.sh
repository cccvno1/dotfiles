#!/usr/bin/env bash

# Screenshot script with edit and save/copy options
# Usage: screenshot.sh [area|window|screen]

MODE="${1:-area}"
TEMP_DIR="/tmp/niri-screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TEMP_FILE="$TEMP_DIR/screenshot_$TIMESTAMP.png"
FINAL_DIR="$HOME/Pictures/Screenshots"

# Create directories if they don't exist
mkdir -p "$TEMP_DIR"
mkdir -p "$FINAL_DIR"

# Take screenshot based on mode
case "$MODE" in
    "area")
        grim -g "$(slurp)" "$TEMP_FILE"
        ;;
    "window")
        grim -g "$(niri msg focused-window | head -1)" "$TEMP_FILE"
        ;;
    "screen")
        grim -o "$(niri msg outputs | head -1 | cut -d' ' -f1)" "$TEMP_FILE"
        ;;
    *)
        echo "Usage: $0 [area|window|screen]"
        exit 1
        ;;
esac

# Check if screenshot was taken successfully
if [ ! -f "$TEMP_FILE" ]; then
    notify-send "Screenshot" "Failed to take screenshot" --urgency=critical
    exit 1
fi

# Open in swappy for editing
swappy -f "$TEMP_FILE" -o "$TEMP_FILE"

# Check if user saved the edited image (swappy modifies the file)
if [ -f "$TEMP_FILE" ]; then
    # Show options using fuzzel
    CHOICE=$(echo -e "Copy to clipboard\nSave to Pictures\nBoth copy and save\nDiscard" | fuzzel --dmenu --prompt "Screenshot action: ")

    case "$CHOICE" in
        "Copy to clipboard")
            wl-copy < "$TEMP_FILE"
            notify-send "Screenshot" "Copied to clipboard" --urgency=low
            ;;
        "Save to Pictures")
            FINAL_FILE="$FINAL_DIR/Screenshot_$TIMESTAMP.png"
            cp "$TEMP_FILE" "$FINAL_FILE"
            notify-send "Screenshot" "Saved to $FINAL_FILE" --urgency=low
            ;;
        "Both copy and save")
            wl-copy < "$TEMP_FILE"
            FINAL_FILE="$FINAL_DIR/Screenshot_$TIMESTAMP.png"
            cp "$TEMP_FILE" "$FINAL_FILE"
            notify-send "Screenshot" "Copied to clipboard and saved to $FINAL_FILE" --urgency=low
            ;;
        "Discard"|"")
            notify-send "Screenshot" "Discarded" --urgency=low
            ;;
    esac
fi

# Clean up temp file
rm -f "$TEMP_FILE"