#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

VALGRIND_VERSION=3.21.0
VALGRIND_DIR=valgrind-$VALGRIND_VERSION
VALGRIND_ARCHIVE=$VALGRIND_DIR.tar.bz2
VALGRIND_URL="https://sourceware.org/pub/valgrind/$VALGRIND_ARCHIVE"

wget $VALGRIND_URL
tar -xvf $VALGRIND_ARCHIVE
cd $VALGRIND_DIR
./configure
make -j"$(nproc --all)"
make install
cd ..
rm $VALGRIND_ARCHIVE

# Valgrind reports this error in case libc6-dbg is not installed:
#
# Fatal error at startup: a function redirection
# which is mandatory for this platform-tool combination
# cannot be set up.  Details of the redirection are:
#
# A must-be-redirected function
# whose name matches the pattern:      strlen
# in an object with soname matching:   ld-linux-x86-64.so.2
# was not found whilst processing
# symbols from the object with soname: ld-linux-x86-64.so.2
#
# Possible fixes: (1, short term): install glibc's debuginfo
# package on this machine.  (2, longer term): ask the packagers
# for your Linux distribution to please in future ship a non-
# stripped ld.so (or whatever the dynamic linker .so is called)
# that exports the above-named function using the standard
# calling conventions for this platform.  The package you need
# to install for fix (1) is called
#
#   On Debian, Ubuntu:                 libc6-dbg
#   On SuSE, openSuSE, Fedora, RHEL:   glibc-debuginfo
#
# Note that if you are debugging a 32 bit process on a
# 64 bit system, you will need a corresponding 32 bit debuginfo
# package (e.g. libc6-dbg:i386).
#
# Cannot continue -- exiting now.  Sorry.

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  libc6-dbg
