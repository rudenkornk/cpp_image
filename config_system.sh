#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  bash-completion \
  ca-certificates \
  gdb \
  make \
  ninja-build \
  python3-distutils \
  valgrind \
  vim \
  wget \


# This way it does not mess up gcc alternatives
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

pip install lit==14.0.3
pip install gcovr
pip install pathlib
pip install pyyaml

