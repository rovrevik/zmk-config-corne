#!/bin/bash

# start the devcontainer
devcontainer up --workspace-folder "$(cd ../zmk && pwd)"
# connect to the devcontainer
docker exec -w /workspaces/zmk -it \
  $(docker ps --format "{{.ID}}\t{{.Image}}" | grep zmk | awk '{print $1}') \
  /bin/bash
