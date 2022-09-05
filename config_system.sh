#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  apt-transport-https \
  bash-completion \
  bison \
  ca-certificates \
  ccache \
  curl \
  dos2unix \
  gdb \
  git \
  gnupg \
  jq \
  less \
  lftp \
  libevent-dev \
  linux-tools-generic \
  make \
  ninja-build \
  openssh-client \
  pkg-config \
  snap \
  sshpass \
  tar gzip zip unzip bzip2 p7zip-full p7zip-rar \
  valgrind \
  vim \
  wget \
  zlib1g-dev \

rm -rf /var/lib/apt/lists/*

pip install lit==14.0.3
pip install gcovr
pip install pathlib
pip install psutil
pip install pyyaml

