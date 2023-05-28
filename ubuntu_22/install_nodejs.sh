#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

DISTRO=$(lsb_release --codename --short)
ARCH=$(dpkg --print-architecture)
PUBKEY=/etc/apt/trusted.gpg.d/nodejs.asc
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key > $PUBKEY
echo "deb [arch=$ARCH signed-by=$PUBKEY] https://deb.nodesource.com/node_19.x $DISTRO main" > /etc/apt/sources.list.d/nodejs.list

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  nodejs \
