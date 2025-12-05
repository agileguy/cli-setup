#!/bin/bash

# Get list of connected outputs
outputs=($(xrandr --query | grep " connected" | cut -d" " -f1))

# Launch cmatrix on each output
for output in "${outputs[@]}"; do
    i3-msg "workspace lock_$output, move workspace to output $output"
    kitty --class cmatrix_lock -e cmatrix &
    sleep 0.3
    i3-msg "[class=\"cmatrix_lock\"] fullscreen enable"
done

# Small delay to ensure windows are ready
sleep 0.5

# Lock with xtrlock (transparent locker - cmatrix shows through)
xtrlock

# After unlock, kill all cmatrix windows
i3-msg "[class=\"cmatrix_lock\"] kill"

# Return to original workspace
i3-msg "workspace 1"

