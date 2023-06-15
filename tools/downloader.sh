#!/bin/bash

# Check if jq is installed
echo "Checking if jq is installed..."
if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed. Please install jq (e.g., 'sudo apt-get install jq') and try again."
    exit 1
fi
echo "jq is installed."

# Check if wget is installed
echo "Checking if wget is installed..."
if ! command -v wget &>/dev/null; then
    echo "wget is required but not installed. Please install wget (e.g., 'sudo apt-get install wget') and try again."
    exit 1
fi
echo "wget is installed."

owner="psyb0t"
repo="ssh-tunnel-swarm"
asset_name="ssh-tunnel-swarm"

echo "Looking up the latest release of $asset_name for github.com/$owner/$repo..."
releases=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
latest_release=$(echo "$releases" | jq -r '.[0]')
asset_url=$(echo "$latest_release" | jq -r ".assets[] | select(.name == \"$asset_name\") | .browser_download_url")

echo "Downloading $asset_url..."
wget -q "$asset_url" -O "$asset_name"

chmod +x "$asset_name"
