#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

GCC_VERSION=13

add-apt-repository ppa:ubuntu-toolchain-r/test --yes
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  gcc-$GCC_VERSION \
  g++-$GCC_VERSION \

update-alternatives \
  --install /usr/bin/gcc gcc /usr/bin/gcc-$GCC_VERSION $GCC_VERSION"0" \
  --slave /usr/bin/cc cc /usr/bin/gcc-$GCC_VERSION \
  --slave /usr/bin/g++ g++ /usr/bin/g++-$GCC_VERSION \
  --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-$GCC_VERSION \
  --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-$GCC_VERSION \
  --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-$GCC_VERSION \
  --slave /usr/bin/gcov gcov /usr/bin/gcov-$GCC_VERSION \
  --slave /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-$GCC_VERSION \
  --slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-$GCC_VERSION \
  --slave /usr/bin/lto-dump lto-dump /usr/bin/lto-dump-$GCC_VERSION \

update-alternatives \
  --install /usr/bin/cpp cpp /usr/bin/cpp-$GCC_VERSION $GCC_VERSION"0" \
