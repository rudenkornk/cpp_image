#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  python2 \
  python3-distutils \
  python3-venv \
  wget \

# This way it does not mess up gcc alternatives

wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2 get-pip.py
rm get-pip.py

wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

rm -rf /var/lib/apt/lists/*

ln --symbolic --force /usr/bin/python2 /usr/bin/python
