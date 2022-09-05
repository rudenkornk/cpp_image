#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace


CMAKE_VERSION=3.24.1
CMAKE_SCRIPT=cmake-$CMAKE_VERSION-linux-x86_64.sh
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/$CMAKE_SCRIPT"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  wget \

wget $CMAKE_URL
chmod +x $CMAKE_SCRIPT
./$CMAKE_SCRIPT --skip-licence --exclude-subdir --prefix=/usr
rm $CMAKE_SCRIPT

rm -rf /var/lib/apt/lists/*
