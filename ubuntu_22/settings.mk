BASE_NAME := cpp_ubuntu
ANCHOR := 338bd65ac045f79d64db624bd7cb4a1db4893027
OFFSET := 1
PATCH != echo $$(($$(git rev-list $(ANCHOR)..HEAD --count --first-parent) - $(OFFSET)))
IMAGE_TAG := 22.0.$(PATCH)
CONTAINERFILE := ubuntu_22/Containerfile
MAKEFILE := linux.mk
