#!/usr/bin/env bash
set -euo pipefail

# Terminate already running bar instances
killall -q polybar || true

    # Wait until the processes have been shut down
    while pgrep -x polybar >/dev/null; do sleep 1; done

    # Launch bar(s)
    polybar --reload toph &