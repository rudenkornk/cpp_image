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
  device-tree-compiler \
  dos2unix \
  expect \
  gdb \
  git \
  gnupg \
  jq \
  less \
  lftp \
  libevent-dev \
  libncurses5 \
  libtool \
  libusb-dev \
  linux-tools-generic \
  make \
  netcat \
  ninja-build \
  openssh-client \
  pkg-config \
  rsync \
  snap \
  sshpass \
  tar gzip zip unzip bzip2 p7zip-full p7zip-rar xz-utils \
  texinfo \
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

git config --global --add safe.directory /home/repo
sudo --user ci_user git config --global --add safe.directory /home/repo
