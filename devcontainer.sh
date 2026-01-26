#!/bin/bash

WORKSPACE_FOLDER="$(cd ../zmk && pwd)"

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
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/build.sh
}

# Handle command line argument
case "${1:-build}" in
    stop)
        stop_container
        ;;
    connect)
        connect_container
        ;;
    build)
        build
        ;;
    *)
        echo "Usage: $0 {stop|connect|build}"
        echo "  stop    - Stop the devcontainer"
        echo "  connect - Connect interactively to the devcontainer"
        echo "  build   - Start the devcontainer and run build.sh (default)"
        exit 1
        ;;
esac
