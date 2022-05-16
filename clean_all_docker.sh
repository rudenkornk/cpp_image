#!/usr/bin/env bash

# Helper script to remove all docker containers, volumes and dangling images
# Use it with caution since it removes ALL containers

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

docker container ls --quiet | ifne xargs docker stop
docker container ls --quiet -all | ifne xargs docker rm
docker system prune --volumes --force

