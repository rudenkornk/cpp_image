#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  wget \

wget https://github.com/mikefarah/yq/releases/download/v4.25.2/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq

pip install conan==1.49.0

rm -rf /var/lib/apt/lists/*
