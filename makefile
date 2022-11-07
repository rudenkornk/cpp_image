SHELL = /usr/bin/env bash

PROJECT_NAME := docker_cpp
BUILD_DIR ?= build
TESTS_DIR := tests
VCS_REF != git rev-parse HEAD
BUILD_DATE != date --rfc-3339=date
KEEP_SUDO ?= false
DOCKER_IMAGE_VERSION := 1.1.7
DOCKER_IMAGE_NAME := rudenkornk/$(PROJECT_NAME)
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_CACHE_FROM ?=
DOCKER_CONTAINER_NAME := $(PROJECT_NAME)_container
USER_ID ?=
USER_ID != [[ -z "$(USER_ID)" ]] && echo $$(id --user) || echo "$(USER_ID)"
USER_NAME ?=
USER_NAME != [[ -z "$(USER_NAME)" ]] && echo $$(id --user --name) || echo "$(USER_NAME)"

DOCKER_DEPS :=
DOCKER_DEPS += Dockerfile
DOCKER_DEPS += entrypoint.sh
DOCKER_DEPS += install_gcc.sh
DOCKER_DEPS += install_llvm.sh
DOCKER_DEPS += install_cmake.sh
DOCKER_DEPS += install_python.sh
DOCKER_DEPS += install_conan.sh
DOCKER_DEPS += $(shell find conan -type f,l)
DOCKER_DEPS += config_system.sh

HELLO_WORLD_DEPS != find $(TESTS_DIR) -type f,l

.PHONY: image
image: $(BUILD_DIR)/image

.PHONY: container
container: $(BUILD_DIR)/container

.PHONY: docker_image_name
docker_image_name:
	$(info $(DOCKER_IMAGE_NAME))

.PHONY: docker_image_tag
docker_image_tag:
	$(info $(DOCKER_IMAGE_TAG))

.PHONY: docker_image_version
docker_image_version:
	$(info $(DOCKER_IMAGE_VERSION))

IF_DOCKERD_UP := command -v docker &> /dev/null && docker image ls &> /dev/null

DOCKER_IMAGE_ID != $(IF_DOCKERD_UP) && docker images --quiet $(DOCKER_IMAGE_TAG)
DOCKER_IMAGE_CREATE_STATUS != [[ -z "$(DOCKER_IMAGE_ID)" ]] && echo "image_not_created"
DOCKER_CACHE_FROM_OPTION != [[ ! -z "$(DOCKER_CACHE_FROM)" ]] && echo "--cache-from $(DOCKER_CACHE_FROM)"
.PHONY: image_not_created
$(BUILD_DIR)/image: $(DOCKER_DEPS) $(DOCKER_IMAGE_CREATE_STATUS)
	docker build \
		$(DOCKER_CACHE_FROM_OPTION) \
		--build-arg IMAGE_NAME="$(DOCKER_IMAGE_NAME)" \
		--build-arg VERSION="$(DOCKER_IMAGE_VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--tag $(DOCKER_IMAGE_TAG) .
	mkdir --parents $(BUILD_DIR) && touch $@

DOCKER_CONTAINER_ID != $(IF_DOCKERD_UP) && docker container ls --quiet --all --filter name=^/$(DOCKER_CONTAINER_NAME)$
DOCKER_CONTAINER_STATE != $(IF_DOCKERD_UP) && docker container ls --format {{.State}} --all --filter name=^/$(DOCKER_CONTAINER_NAME)$
DOCKER_CONTAINER_RUN_STATUS != [[ "$(DOCKER_CONTAINER_STATE)" != "running" ]] && echo "container_not_running"
.PHONY: container_not_running
$(BUILD_DIR)/container: $(BUILD_DIR)/image $(DOCKER_CONTAINER_RUN_STATUS)
ifneq ($(DOCKER_CONTAINER_ID),)
	docker container rename $(DOCKER_CONTAINER_NAME) $(DOCKER_CONTAINER_NAME)_$(DOCKER_CONTAINER_ID)
endif
	docker run --interactive --tty --detach \
		--env KEEP_SUDO=$(KEEP_SUDO) \
		--env USER_ID="$(USER_ID)" --env USER_NAME="$(USER_NAME)" \
		--env "TERM=xterm-256color" \
		--name $(DOCKER_CONTAINER_NAME) \
		--mount type=bind,source="$$(pwd)",target="$$(pwd)" \
		--workdir "$$(pwd)" \
		$(DOCKER_IMAGE_TAG)
	sleep 1
	mkdir --parents $(BUILD_DIR) && touch $@


$(BUILD_DIR)/gcc/Release/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "gcc --version" | grep --perl-regexp --quiet "12\.\d+\.\d+"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "g++ --version" | grep --perl-regexp --quiet "12\.\d+\.\d+"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		ASAN=ON \
		UBSAN=ON \
		conan install \
		--profile:host gcc.jinja \
		--profile:build gcc.jinja \
		--settings build_type=Release \
		--build missing \
		--install-folder $(BUILD_DIR)/gcc $(TESTS_DIR) \
		"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		cmake \
		-S $(TESTS_DIR) \
		-B $(BUILD_DIR)/gcc \
		-G \"Ninja Multi-Config\" \
		-DCMAKE_CONFIGURATION_TYPES=\"Release\" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_TOOLCHAIN_FILE=\"conan_toolchain.cmake\" \
	"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		cmake \
		--build $(BUILD_DIR)/gcc \
		--config Release \
		--verbose \
	"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "./$(BUILD_DIR)/gcc/Release/hello_world" | grep --quiet "Hello world!"
	grep --quiet "g++" $(BUILD_DIR)/gcc/compile_commands.json
	grep --quiet "\-fsanitize=address" $(BUILD_DIR)/gcc/compile_commands.json
	grep --quiet "\-fsanitize=undefined" $(BUILD_DIR)/gcc/compile_commands.json
	touch $@

$(BUILD_DIR)/llvm/Release/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "clang --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "clang++ --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		ASAN=ON \
		UBSAN=ON \
		conan install \
		--profile:host llvm.jinja \
		--profile:build llvm.jinja \
		--settings build_type=Release \
		--build missing \
		--install-folder $(BUILD_DIR)/llvm $(TESTS_DIR) \
		"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		cmake \
		-S $(TESTS_DIR) \
		-B $(BUILD_DIR)/llvm \
		-G \"Ninja Multi-Config\" \
		-DCMAKE_CONFIGURATION_TYPES=\"Release\" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_TOOLCHAIN_FILE=\"conan_toolchain.cmake\" \
	"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		cmake \
		--build $(BUILD_DIR)/llvm \
		--config Release \
		--verbose \
	"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "./$(BUILD_DIR)/llvm/Release/hello_world" | grep --quiet "Hello world!"
	grep --quiet "clang++" $(BUILD_DIR)/llvm/compile_commands.json
	grep --quiet "\-fsanitize=address" $(BUILD_DIR)/llvm/compile_commands.json
	grep --quiet "\-fsanitize=undefined" $(BUILD_DIR)/llvm/compile_commands.json
	touch $@

$(BUILD_DIR)/valgrind_test: $(BUILD_DIR)/gcc/Release/hello_world $(BUILD_DIR)/llvm/Release/hello_world
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "valgrind --version"
	touch $@

$(BUILD_DIR)/gdb_test: $(BUILD_DIR)/gcc/Release/hello_world $(BUILD_DIR)/llvm/Release/hello_world
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		gdb -ex run -ex quit ./build/gcc/Release/hello_world && \
		gdb -ex run -ex quit ./build/llvm/Release/hello_world && \
		: "
	touch $@

$(BUILD_DIR)/clang_tidy_test: $(BUILD_DIR)/gcc/Release/hello_world $(BUILD_DIR)/llvm/Release/hello_world
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "clang-tidy --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c " \
		clang-tidy -p $(BUILD_DIR)/gcc $(TESTS_DIR)/hello_world.cpp && \
		clang-tidy -p $(BUILD_DIR)/llvm $(TESTS_DIR)/hello_world.cpp && \
		: "
	touch $@

$(BUILD_DIR)/clang_format_test: $(BUILD_DIR)/container
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "clang-format --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	touch $@

$(BUILD_DIR)/lit_test: $(BUILD_DIR)/container
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "lit --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	touch $@

$(BUILD_DIR)/filecheck_test: $(BUILD_DIR)/container
	docker exec --user $(USER_NAME) $(DOCKER_CONTAINER_NAME) \
		bash -c "FileCheck --version" | grep --perl-regexp --quiet "14\.\d+\.\d+"
	touch $@

.PHONY: check
check: \
	$(BUILD_DIR)/gcc/Release/hello_world \
	$(BUILD_DIR)/llvm/Release/hello_world \
	$(BUILD_DIR)/clang_tidy_test \
	$(BUILD_DIR)/gdb_test \
	$(BUILD_DIR)/valgrind_test \
	$(BUILD_DIR)/lit_test \
	$(BUILD_DIR)/filecheck_test \

.PHONY: clean
clean:
	docker container ls --quiet --filter name=$(DOCKER_CONTAINER_NAME)_ | \
		ifne xargs docker stop
	docker container ls --quiet --filter name=$(DOCKER_CONTAINER_NAME)_ --all | \
		ifne xargs docker rm

