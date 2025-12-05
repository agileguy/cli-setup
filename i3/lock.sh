#!/bin/bash

# Check if i3lock is installed
if ! command -v i3lock &> /dev/null; then
    notify-send "i3lock not found" "Run: curl -sSL https://raw.githubusercontent.com/agileguy/cli-setup/main/i3/install-i3lock-color.sh | bash"
    exit 1
fi

# Orange theme colors for i3lock-color
BLANK='#00000000'
CLEAR='#ff8c0022'
DEFAULT='#ff8c00cc'
TEXT='#ffb347ee'
WRONG='#ff4500bb'
VERIFYING='#ffa500bb'

i3lock \
--insidever-color=$CLEAR     \
--ringver-color=$VERIFYING   \
\
--insidewrong-color=$CLEAR   \
--ringwrong-color=$WRONG     \
\
--inside-color=$BLANK        \
--ring-color=$DEFAULT        \
--line-color=$BLANK          \
--separator-color=$DEFAULT   \
\
--verif-color=$TEXT          \
--wrong-color=$WRONG         \
--time-color=$TEXT           \
--date-color=$TEXT           \
--layout-color=$TEXT         \
--keyhl-color=$VERIFYING     \
--bshl-color=$WRONG          \
\
--screen 1                   \
--image ~/.config/backgrounds/great_wave.png \
--centered                   \

