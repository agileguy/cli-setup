#!/bin/bash
set -euo pipefail

# Install i3lock-color from source

echo "=== Installing i3lock-color ==="

# Check if already installed (Cassandra Fox is in i3lock-color version output)
if i3lock --version 2>&1 | grep -q "Cassandra Fox"; then
    echo "✓ i3lock-color already installed"
    exit 0
fi

echo "→ Installing dependencies..."
sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev \
    libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev \
    libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev \
    libxkbcommon-x11-dev libjpeg-dev libgif-dev

echo "→ Cloning i3lock-color..."
rm -rf /tmp/i3lock-color
git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color

echo "→ Building i3lock-color..."
cd /tmp/i3lock-color
./build.sh

echo "→ Installing i3lock-color..."
sudo ./install-i3lock-color.sh

echo "→ Cleaning up..."
rm -rf /tmp/i3lock-color

echo "✓ i3lock-color installed successfully"
i3lock --version

