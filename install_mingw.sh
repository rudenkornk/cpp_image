#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

MINGW_VERSION=8.0.0-1

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  mingw-w64=${MINGW_VERSION} \
  mingw-w64-tools=${MINGW_VERSION} \
  mingw-w64-x86-64-dev=${MINGW_VERSION} \

rm -rf /var/lib/apt/lists/*
