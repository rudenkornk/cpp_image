#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace


CMAKE_VERSION=3.29.2
CMAKE_SCRIPT=cmake-$CMAKE_VERSION-linux-x86_64.sh
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/$CMAKE_SCRIPT"

wget $CMAKE_URL
chmod +x $CMAKE_SCRIPT
./$CMAKE_SCRIPT --skip-licence --exclude-subdir --prefix=/usr
rm $CMAKE_SCRIPT
