#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

USER_ID=${USER_ID:-0}
USER_NAME=${USER_NAME:-root}
GROUP_ID=${GROUP_ID:-$USER_ID}
GROUP_NAME=${GROUP_NAME:-$USER_NAME}
KEEP_SUDO=${KEEP_SUDO:-false}

if [[ "$USER_ID" != "0" ]]; then
  if [[ "$USER_NAME" == "root" ]]; then
    echo "Looks like you set USER_ID, but forgot to set USER_NAME, please fix."
    exit 1
  fi

  adduser --uid "$USER_ID" --disabled-password --gecos "" "$USER_NAME"
  usermod --append --groups sudo "$USER_NAME"
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

  echo "Configuring user..."
  USER_HOME=$(eval echo ~"$USER_NAME")
  chown "$USER_NAME" "$USER_HOME"
  chgrp "$USER_NAME" "$USER_HOME"

  cp --recursive /root/.conan "$USER_HOME"
  chown --recursive "$USER_NAME" "$USER_HOME/.conan"
  chgrp --recursive "$USER_NAME" "$USER_HOME/.conan"
  sudo --user "$USER_NAME" "$USER_HOME/.conan/config_conan.sh" &> /dev/null
  echo "Done"
fi

if [[ "$KEEP_SUDO" != "true" ]]; then
  deluser --quiet "$USER_NAME" sudo
fi

USER_HOME=$(eval echo ~"$USER_NAME")
cd "$USER_HOME"
if [[ $# -gt 0 ]]; then
  exec sudo --user="$USER_NAME" -- bash -c "$@"
else
  exec sudo --user="$USER_NAME" -- bash
fi
