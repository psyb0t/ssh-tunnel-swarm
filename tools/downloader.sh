#!/bin/bash
owner=psyb0t
repo=ssh-tunnel-swarm
asset_name=ssh-tunnel-swarm

echo "Looking up the latest release of $asset_name for github.com/$owner/$repo..."
releases=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
latest_release=$(echo "$releases" | jq -r '.[0]')
asset_url=$(echo "$latest_release" | jq -r ".assets[] | select(.name == \"$asset_name\") | .browser_download_url")

echo "Downloading $asset_url..."
wget -q "$asset_url" -O "$asset_name"

chmod +x "$asset_name"
