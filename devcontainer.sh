#!/bin/bash

WORKSPACE_FOLDER="$(cd ../zmk && pwd)"
ZMK_CONFIG_DIR="${ZMK_CONFIG_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# Ensure zmk-config volume exists as bind mount to ZMK_CONFIG_DIR
ensure_zmk_config_volume() {
    local volume_ok=false
    if docker volume inspect zmk-config >/dev/null 2>&1; then
        local device
        device=$(docker volume inspect zmk-config --format '{{ index .Options "device" }}' 2>/dev/null)
        if [ "$device" = "$ZMK_CONFIG_DIR" ]; then
            volume_ok=true
        fi
    fi

    if [ "$volume_ok" != true ]; then
        # Remove existing volume and any containers using it
        for cid in $(docker ps -a -q --filter volume=zmk-config 2>/dev/null); do
            docker stop "$cid" 2>/dev/null
            docker rm "$cid" 2>/dev/null
        done
        docker volume rm zmk-config 2>/dev/null
        echo "Creating zmk-config volume..."
        docker volume create --driver local -o o=bind -o type=none -o device="$ZMK_CONFIG_DIR" zmk-config
    fi
}

# Function to check if container is running
is_container_running() {
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" echo "Container is running" >/dev/null 2>&1
}

# Function to stop the devcontainer (devcontainer CLI has no stop command; use docker)
stop_container() {
    if is_container_running; then
        container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$WORKSPACE_FOLDER" | head -1)
        if [ -n "$container_id" ]; then
            docker stop "$container_id"
            echo "Devcontainer stopped"
        else
            echo "Could not find devcontainer to stop"
        fi
    else
        echo "Devcontainer is not running"
    fi
}

# Function to connect to the devcontainer
connect_container() {
    if is_container_running; then
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" -- /bin/bash
    else
        echo "Devcontainer is not running. Use 'build' to start it first."
        exit 1
    fi
}

# Function to build
build() {
    if is_container_running; then
        echo "Devcontainer is already running"
    else
        devcontainer up --workspace-folder "$WORKSPACE_FOLDER"
        echo "Devcontainer daemon started"
    fi
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/draw.sh
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/build.sh
}

ensure_zmk_config_volume

# Handle command line argument
case "${1:-build}" in
    stop)
        stop_container
        ;;
    connect)
        connect_container
        ;;
    draw)
        if ! is_container_running; then
            devcontainer up --workspace-folder "$WORKSPACE_FOLDER"
            echo "Devcontainer daemon started"
        fi
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/draw.sh
        ;;
    build)
        build
        ;;
    *)
        echo "Usage: $0 {stop|connect|build|draw}"
        echo "  stop    - Stop the devcontainer"
        echo "  connect - Connect interactively to the devcontainer"
        echo "  build   - Start the devcontainer and run build.sh (default)"
        echo "  draw    - Generate keymap SVG using keymap-drawer"
        exit 1
        ;;
esac
