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
  ccache \
  device-tree-compiler \
  dos2unix \
  flex \
  gawk \
  gdb \
  git \
  htop \
  jq \
  less \
  lftp \
  linux-tools-generic \
  make \
  ninja-build \
  openssh-client \
  openssh-server \
  pkg-config \
  sshpass \
  tar gzip zip unzip bzip2 p7zip-full p7zip-rar xz-utils \
  valgrind \
  vim \
