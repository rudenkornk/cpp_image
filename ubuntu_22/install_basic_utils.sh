#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  gpg-agent \
  lsb-release \
  software-properties-common \
  wget \

mkdir --parents /etc/apt/keyrings
