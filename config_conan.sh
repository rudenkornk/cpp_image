#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

conan config init
for compiler in \
    apple-clang \
    clang \
    gcc \
    ; do
  yq "with(.compiler.${compiler}.address_sanitizer; . = [\"None\", True] | . style=\"flow\")"  -i ~/.conan/settings.yml
  yq "with(.compiler.${compiler}.thread_sanitizer; . = [\"None\", True] | . style=\"flow\")"  -i ~/.conan/settings.yml
  yq "with(.compiler.${compiler}.ub_sanitizer; . = [\"None\", True] | . style=\"flow\")"  -i ~/.conan/settings.yml
done

sed -i 's/print_run_commands = False/print_run_commands = True/g' ~/.conan/conan.conf

