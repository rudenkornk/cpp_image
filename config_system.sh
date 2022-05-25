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
  python3-distutils \
  valgrind \
  vim \
  wget \


wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

pip install gcovr
pip install lit
pip install pathlib
pip install pyyaml

