#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

BOOST_VERSION=1.79.0
BOOST_NAME=boost_${BOOST_VERSION//"."/"_"}
BOOST_ARCHIVE=$BOOST_NAME.tar.gz
BOOST_URL=https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VERSION/source/$BOOST_ARCHIVE

apt-get update
DEBAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  ca-certificates \
  wget \

wget $BOOST_URL
tar -xvf $BOOST_ARCHIVE
cd $BOOST_NAME
./bootstrap.sh --prefix=/usr/
./b2 install
cd -
rm $BOOST_ARCHIVE
rm --recursive --force $BOOST_NAME

