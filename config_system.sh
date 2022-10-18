#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  apt-transport-https \
  automake \
  bash-completion \
  bison \
  ca-certificates \
  ccache \
  curl \
  device-tree-compiler \
  dos2unix \
  expat \
  expect \
  flex \
  gdb \
  git \
  gnupg \
  jq \
  less \
  lftp \
  libevent-dev \
  libfl-dev \
  libftdi-dev \
  libgmp-dev \
  libhidapi-dev \
  libncurses5 \
  libtool \
  libusb-1.0-0-dev \
  linux-tools-generic \
  lsb-release \
  make \
  ncurses-dev \
  netcat \
  ninja-build \
  opensbi \
  openssh-client \
  openssh-server \
  pkg-config \
  qemu-system-riscv64 \
  qemu-utils \
  rsync \
  snap \
  sshpass \
  tar gzip zip unzip bzip2 p7zip-full p7zip-rar xz-utils \
  texinfo \
  u-boot-qemu \
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

git config --system --add safe.directory '*'
