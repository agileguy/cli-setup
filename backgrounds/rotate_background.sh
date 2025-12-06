#!/bin/bash

# Background rotation script
# Selects a random image from the backgrounds directory and sets it as wallpaper
# Also creates background.jpg and background.png copies for use by lock screen

BACKGROUNDS_DIR="$HOME/.config/backgrounds"

# Get list of jpg images (excluding the background.jpg copy)
images=($(find "$BACKGROUNDS_DIR" -maxdepth 1 -name "*.jpg" ! -name "background.jpg" -type f))

# Exit if no images found
if [ ${#images[@]} -eq 0 ]; then
    echo "No background images found in $BACKGROUNDS_DIR"
    exit 1
fi

# Select a random image
random_image="${images[$RANDOM % ${#images[@]}]}"

# Copy to background.jpg and convert to background.png for lock screen
cp "$random_image" "$BACKGROUNDS_DIR/background.jpg"
convert "$BACKGROUNDS_DIR/background.jpg" "$BACKGROUNDS_DIR/background.png"

# Set the wallpaper using feh
feh --bg-fill "$BACKGROUNDS_DIR/background.jpg"

echo "Background set to: $(basename "$random_image")"
