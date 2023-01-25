SHELL = /usr/bin/env bash

IMAGE ?= ubuntu_22
include $(IMAGE)/settings.mk
include $(MAKEFILE)
