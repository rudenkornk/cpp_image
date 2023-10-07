#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  automake \
  bison \
  device-tree-compiler \
  dos2unix \
  flex \
  gawk \
  gdb \
  linux-tools-generic \
  make \
  pkg-config \
