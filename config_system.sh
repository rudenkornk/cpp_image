#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  bash-completion \
  gdb \
  git \
  less \
  make \
  ninja-build \
  valgrind \
  vim \

rm -rf /var/lib/apt/lists/*

pip install lit==14.0.3
pip install gcovr
pip install pathlib
pip install pyyaml

