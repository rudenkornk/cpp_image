#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  git

REVISION=afbb37cfd648335fd980f6fb7dbc2d0c84c009cf

cd /usr/local
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
git checkout $REVISION
cd ..
chmod -R "a=u" vcpkg
