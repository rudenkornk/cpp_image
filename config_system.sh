#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  gdb \
  make \
  valgrind \
  vim \

