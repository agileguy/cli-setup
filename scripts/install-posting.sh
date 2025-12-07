#!/bin/bash
# Install Posting TUI HTTP client using uv

set -euo pipefail

echo "=== Installing Posting TUI HTTP client ==="

# Check if already installed
if command -v posting &> /dev/null; then
    echo "✓ Posting already installed: $(posting --version 2>/dev/null || echo 'installed')"
    exit 0
fi

# Check if uv is installed, install if not
if ! command -v uv &> /dev/null; then
    echo "→ Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install posting with Python 3.13
echo "→ Installing posting..."
uv tool install --python 3.13 posting

echo ""
echo "=== Posting installation complete ==="
echo "Run 'posting' to start the TUI HTTP client."
