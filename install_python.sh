#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  python3-distutils \
  wget \

# This way it does not mess up gcc alternatives
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

