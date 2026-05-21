#!/bin/bash

# Install keymap-drawer if not already installed
# Using --break-system-packages since this is a disposable devcontainer
if ! command -v keymap &> /dev/null; then
    pip install --quiet --break-system-packages keymap-drawer
fi

# Parse the keymap and draw SVGs
CONFIG=/workspaces/zmk-config/keymap_drawer.config.yaml
mkdir -p /workspaces/zmk/build/keymap
keymap -c "$CONFIG" parse -z /workspaces/zmk-config/config/corne.keymap > /workspaces/zmk/build/keymap/keymap.yaml
keymap -c "$CONFIG" draw /workspaces/zmk/build/keymap/keymap.yaml > /workspaces/zmk/build/keymap/keymap.svg
echo "Generated build/keymap/keymap.svg"
