#!/bin/bash
# Install Google Cloud SDK and GKE plugin from official apt repository

set -euo pipefail

echo "=== Installing Google Cloud SDK from official apt repository ==="

# Check if already installed
if command -v gcloud &> /dev/null; then
    echo "✓ Google Cloud SDK already installed: $(gcloud version 2>/dev/null | head -1)"
    # Check for GKE plugin
    if dpkg -l google-cloud-cli-gke-gcloud-auth-plugin &> /dev/null; then
        echo "✓ GKE auth plugin already installed"
        exit 0
    fi
fi

# Install prerequisites
echo "→ Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add Google Cloud public key
echo "→ Adding Google Cloud GPG key..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add Google Cloud SDK repository
echo "→ Adding Google Cloud SDK repository..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Update and install
echo "→ Installing Google Cloud CLI..."
sudo apt-get update
sudo apt-get install -y google-cloud-cli

# Install GKE auth plugin
echo "→ Installing GKE auth plugin..."
sudo apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin

# Verify installation
echo ""
echo "=== Installation complete ==="
gcloud version
echo ""
echo "GKE auth plugin location: $(which gke-gcloud-auth-plugin 2>/dev/null || echo 'installed via apt')"
echo ""
echo "Run 'gcloud init' to configure your account."
