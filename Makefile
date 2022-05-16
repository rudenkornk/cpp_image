SHELL = /usr/bin/env bash

PROJECT_NAME := docker_cpp
VCS_REF ?= $(shell git rev-parse HEAD)
VCS_REF := $(VCS_REF)
BUILD_DATE ?= $(shell date --rfc-3339=date)
BUILD_DATE := $(BUILD_DATE)
BUILD_DIR ?= build
BUILD_DIR := $(BUILD_DIR)
TESTS_DIR ?= tests
TESTS_DIR := $(TESTS_DIR)
CI_BIND_MOUNT ?= $(shell pwd)
CI_BIND_MOUNT := $(CI_BIND_MOUNT)
KEEP_CI_USER_SUDO ?= false
KEEP_CI_USER_SUDO := $(KEEP_CI_USER_SUDO)
DOCKER_IMAGE_VERSION ?= 0.1.1
DOCKER_IMAGE_VERSION := $(DOCKER_IMAGE_VERSION)
DOCKER_IMAGE_NAME := rudenkornk/$(PROJECT_NAME)
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_IMAGE := $(BUILD_DIR)/$(PROJECT_NAME)_image_$(DOCKER_IMAGE_VERSION)
DOCKER_CACHE_FROM ?=
DOCKER_CACHE_FROM := $(DOCKER_CACHE_FROM)
DOCKER_CONTAINER_NAME ?= $(PROJECT_NAME)_container
DOCKER_CONTAINER_NAME := $(DOCKER_CONTAINER_NAME)
DOCKER_CONTAINER := $(BUILD_DIR)/$(DOCKER_CONTAINER_NAME)_$(DOCKER_IMAGE_VERSION)
DOCKER_TEST_CONTAINER_NAME := $(PROJECT_NAME)_test_container
DOCKER_TEST_CONTAINER := $(BUILD_DIR)/$(DOCKER_TEST_CONTAINER_NAME)_$(DOCKER_IMAGE_VERSION)

DOCKER_DEPS :=
DOCKER_DEPS += Dockerfile
DOCKER_DEPS += install_gcc.sh
DOCKER_DEPS += install_llvm.sh
DOCKER_DEPS += install_boost.sh
DOCKER_DEPS += install_cmake.sh
DOCKER_DEPS += config_system.sh

HELLO_WORLD_DEPS :=
HELLO_WORLD_DEPS += $(TESTS_DIR)/hello_world.cpp
HELLO_WORLD_DEPS += $(TESTS_DIR)/CMakeLists.txt

.PHONY: $(DOCKER_IMAGE_NAME)
$(DOCKER_IMAGE_NAME): $(DOCKER_IMAGE)

.PHONY: docker_image_name
docker_image_name:
	$(info $(DOCKER_IMAGE_NAME))

.PHONY: docker_image_tag
docker_image_tag:
	$(info $(DOCKER_IMAGE_TAG))

.PHONY: docker_image_version
docker_image_version:
	$(info $(DOCKER_IMAGE_VERSION))

DOCKER_IMAGE_ID = $(shell docker images --quiet $(DOCKER_IMAGE_TAG))
DOCKER_IMAGE_CREATE_STATUS = $(shell [[ -z "$(DOCKER_IMAGE_ID)" ]] && echo "$(DOCKER_IMAGE)_not_created")
DOCKER_CACHE_FROM_COMMAND = $(shell [[ ! -z "$(DOCKER_CACHE_FROM)" ]] && echo "--cache-from $(DOCKER_CACHE_FROM)")
.PHONY: $(DOCKER_IMAGE)_not_created
$(DOCKER_IMAGE): $(DOCKER_DEPS) $(DOCKER_IMAGE_CREATE_STATUS)
	docker build \
		$(DOCKER_CACHE_FROM_COMMAND) \
		--build-arg IMAGE_NAME="$(DOCKER_IMAGE_NAME)" \
		--build-arg VERSION="$(DOCKER_IMAGE_VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--tag $(DOCKER_IMAGE_TAG) .
	mkdir --parents $(BUILD_DIR) && touch $@

.PHONY: $(DOCKER_CONTAINER_NAME)
$(DOCKER_CONTAINER_NAME): $(DOCKER_CONTAINER)

DOCKER_CONTAINER_ID = $(shell docker container ls --quiet --all --filter name=^/$(DOCKER_CONTAINER_NAME)$)
DOCKER_CONTAINER_STATE = $(shell docker container ls --format {{.State}} --all --filter name=^/$(DOCKER_CONTAINER_NAME)$)
DOCKER_CONTAINER_RUN_STATUS = $(shell [[ "$(DOCKER_CONTAINER_STATE)" != "running" ]] && echo "$(DOCKER_CONTAINER)_not_running")
.PHONY: $(DOCKER_CONTAINER)_not_running
$(DOCKER_CONTAINER): $(DOCKER_IMAGE) $(DOCKER_CONTAINER_RUN_STATUS)
ifneq ($(DOCKER_CONTAINER_ID),)
	docker container rename $(DOCKER_CONTAINER_NAME) $(DOCKER_CONTAINER_NAME)_$(DOCKER_CONTAINER_ID)
endif
	docker run --interactive --tty --detach \
		--user ci_user \
		--env KEEP_CI_USER_SUDO=$(KEEP_CI_USER_SUDO) \
		--env CI_UID="$$(id --user)" --env CI_GID="$$(id --group)" \
		--name $(DOCKER_CONTAINER_NAME) \
		--mount type=bind,source="$(CI_BIND_MOUNT)",target=/home/repo \
		$(DOCKER_IMAGE_TAG)
	sleep 1
	mkdir --parents $(BUILD_DIR) && touch $@

.PHONY: $(DOCKER_TEST_CONTAINER_NAME)
$(DOCKER_TEST_CONTAINER_NAME): $(DOCKER_TEST_CONTAINER)

DOCKER_TEST_CONTAINER_ID = $(shell docker container ls --quiet --all --filter name=^/$(DOCKER_TEST_CONTAINER_NAME)$)
DOCKER_TEST_CONTAINER_STATE = $(shell docker container ls --format {{.State}} --all --filter name=^/$(DOCKER_TEST_CONTAINER_NAME)$)
DOCKER_TEST_CONTAINER_RUN_STATUS = $(shell [[ "$(DOCKER_TEST_CONTAINER_STATE)" != "running" ]] && echo "$(DOCKER_TEST_CONTAINER)_not_running")
.PHONY: $(DOCKER_TEST_CONTAINER)_not_running
$(DOCKER_TEST_CONTAINER): $(DOCKER_IMAGE) $(DOCKER_TEST_CONTAINER_RUN_STATUS)
ifneq ($(DOCKER_TEST_CONTAINER_ID),)
	docker container rename $(DOCKER_TEST_CONTAINER_NAME) $(DOCKER_TEST_CONTAINER_NAME)_$(DOCKER_TEST_CONTAINER_ID)
endif
	docker run --interactive --tty --detach \
		--user ci_user \
		--env CI_UID="$$(id --user)" --env CI_GID="$$(id --group)" \
		--name $(DOCKER_TEST_CONTAINER_NAME) \
		--mount type=bind,source="$$(pwd)",target=/home/repo \
		$(DOCKER_IMAGE_TAG)
	sleep 1
	mkdir --parents $(BUILD_DIR) && touch $@


$(BUILD_DIR)/gcc/HelloWorld: $(DOCKER_TEST_CONTAINER) $(HELLO_WORLD_DEPS)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) \
		bash -c " \
		CC=gcc CXX=g++ \
		cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S $(TESTS_DIR) -B $(BUILD_DIR)/gcc && \
		cmake --build $(BUILD_DIR)/gcc && \
		./$(BUILD_DIR)/gcc/HelloWorld && \
		: " | grep --quiet "Hello world!"
	# Touch in case cmake decided not to recompile
	touch $@

$(BUILD_DIR)/llvm/HelloWorld: $(DOCKER_TEST_CONTAINER) $(HELLO_WORLD_DEPS)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) \
		bash -c " \
		CC=clang CXX=clang++ \
		cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S $(TESTS_DIR) -B $(BUILD_DIR)/llvm && \
		cmake --build $(BUILD_DIR)/llvm && \
		./$(BUILD_DIR)/llvm/HelloWorld && \
		: " | grep --quiet "Hello world!"
	# Touch in case cmake decided not to recompile
	touch $@

$(BUILD_DIR)/valgrind_test: $(BUILD_DIR)/gcc/HelloWorld $(BUILD_DIR)/llvm/HelloWorld
	docker exec $(DOCKER_TEST_CONTAINER_NAME) \
		bash -c " \
		valgrind $(BUILD_DIR)/gcc/HelloWorld && \
		valgrind $(BUILD_DIR)/llvm/HelloWorld && \
		: "
	touch $@

$(BUILD_DIR)/gdb_test: $(BUILD_DIR)/gcc/HelloWorld $(BUILD_DIR)/llvm/HelloWorld
	docker exec $(DOCKER_TEST_CONTAINER_NAME) \
		bash -c " \
		gdb -ex run -ex quit ./build/gcc/HelloWorld && \
		gdb -ex run -ex quit ./build/llvm/HelloWorld && \
		: "
	touch $@

$(BUILD_DIR)/clang_tidy_test: $(BUILD_DIR)/gcc/HelloWorld $(BUILD_DIR)/llvm/HelloWorld
	docker exec $(DOCKER_TEST_CONTAINER_NAME) \
		bash -c " \
		clang-tidy -p $(BUILD_DIR)/gcc $(TESTS_DIR)/hello_world.cpp && \
		clang-tidy -p $(BUILD_DIR)/llvm $(TESTS_DIR)/hello_world.cpp && \
		: "
	touch $@

.PHONY: check
check: \
	$(BUILD_DIR)/gcc/HelloWorld \
	$(BUILD_DIR)/llvm/HelloWorld \
	$(BUILD_DIR)/clang_tidy_test \
	$(BUILD_DIR)/gdb_test \
	$(BUILD_DIR)/valgrind_test \

.PHONY: clean
clean:
	docker container ls --quiet --filter name=$(DOCKER_TEST_CONTAINER_NAME)_ | \
		ifne xargs docker stop
	docker container ls --quiet --filter name=$(DOCKER_TEST_CONTAINER_NAME)_ --all | \
		ifne xargs docker rm

