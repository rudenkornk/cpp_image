BASE_NAME ?=
IMAGE_TAG ?=
CONTAINERFILE ?=

CACHE_FROM ?=

PROJECT := rudenkornk/cpp_image
BUILD_DIR := __build__/$(BASE_NAME)/$(IMAGE_TAG)
BUILD_TESTS := $(BUILD_DIR)/tests
CONTAINER_NAME := $(BASE_NAME)_cont
IMAGE_NAME := rudenkornk/$(BASE_NAME)
IMAGE_NAMETAG := $(IMAGE_NAME):$(IMAGE_TAG)
TESTS_DIR := tests
VCS_REF != git rev-parse HEAD

DEPS != grep --perl-regexp --only-matching "COPY \K.*?(?= \S+$$)" $(CONTAINERFILE)
DEPS += $(CONTAINERFILE)

HELLO_WORLD_DEPS != find $(TESTS_DIR) -type f,l

.PHONY: image
image: $(BUILD_DIR)/image

.PHONY: container
container: $(BUILD_DIR)/container

.PHONY: image_name
image_name:
	$(info $(IMAGE_NAME))

.PHONY: image_nametag
image_nametag:
	$(info $(IMAGE_NAMETAG))

.PHONY: image_tag
image_tag:
	$(info $(IMAGE_TAG))

.PHONY: format
format: $(BUILD_DIR)/node_modules
	npx prettier --ignore-path <(cat .gitignore .prettierignore) --write .

$(BUILD_DIR)/node_modules: package.json package-lock.json
	npm install --save-exact;
	mkdir --parents $(BUILD_DIR) && touch $@

.PHONY: $(BUILD_DIR)/not_ready

IMAGE_CREATE_STATUS != podman image exists $(IMAGE_NAMETAG) || echo "$(BUILD_DIR)/not_ready"
$(BUILD_DIR)/image: $(DEPS) $(IMAGE_CREATE_STATUS)
	podman build \
		--cache-from '$(CACHE_FROM)' \
		--label "org.opencontainers.image.ref.name=$(IMAGE_NAME)" \
		--label "org.opencontainers.image.revision=$(VCS_REF)" \
		--label "org.opencontainers.image.source=https://github.com/$(PROJECT)" \
		--label "org.opencontainers.image.version=$(IMAGE_TAG)" \
		--tag $(IMAGE_NAMETAG) \
		--file $(CONTAINERFILE) .
	mkdir --parents $(BUILD_DIR) && touch $@

CONTAINER_ID != podman container ls --quiet --all --filter name=^$(CONTAINER_NAME)$
CONTAINER_STATE != podman container ls --format {{.State}} --all --filter name=^$(CONTAINER_NAME)$
CONTAINER_RUN_STATUS != [[ ! "$(CONTAINER_STATE)" =~ ^Up ]] && echo "$(BUILD_DIR)/not_ready"
$(BUILD_DIR)/container: $(BUILD_DIR)/image $(CONTAINER_RUN_STATUS)
ifneq ($(CONTAINER_ID),)
	podman container rename $(CONTAINER_NAME) $(CONTAINER_NAME)_$(CONTAINER_ID)
endif
	podman run --interactive --tty --detach \
		--env "TERM=xterm-256color" \
		--mount type=bind,source="$$(pwd)",target="$$(pwd)" \
		--name $(CONTAINER_NAME) \
		--userns keep-id \
		--workdir "$$HOME" \
		$(IMAGE_NAMETAG)
	podman exec --user root $(CONTAINER_NAME) \
		bash -c "chown $$(id -u):$$(id -g) $$HOME"
	mkdir --parents $(BUILD_TESTS)
	mkdir --parents $(BUILD_DIR) && touch $@


$(BUILD_TESTS)/gcc/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		CC=gcc \
		CXX=g++ \
		cmake \
		-S $(TESTS_DIR) \
		-B $(BUILD_TESTS)/gcc \
		-G Ninja \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		cmake \
		--build $(BUILD_TESTS)/gcc \
		--verbose \
	"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "./$(BUILD_TESTS)/gcc/hello_world" | grep --quiet "Hello world!"
	grep --quiet "bin/g++" $(BUILD_TESTS)/gcc/compile_commands.json
	[[ $$(stat --format "%U" $@) == $$(id --user --name) ]]
	[[ $$(stat --format "%G" $@) == $$(id --group --name) ]]
	touch $@

$(BUILD_TESTS)/llvm/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		CC=clang \
		CXX=clang++ \
		cmake \
		-S $(TESTS_DIR) \
		-B $(BUILD_TESTS)/llvm \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		cmake \
		--build $(BUILD_TESTS)/llvm \
		--verbose \
	"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "./$(BUILD_TESTS)/llvm/hello_world" | grep --quiet "Hello world!"
	grep --quiet "bin/clang++" $(BUILD_TESTS)/llvm/compile_commands.json
	[[ $$(stat --format "%U" $@) == $$(id --user --name) ]]
	[[ $$(stat --format "%G" $@) == $$(id --group --name) ]]
	touch $@

$(BUILD_TESTS)/valgrind: $(BUILD_TESTS)/gcc/hello_world $(BUILD_TESTS)/llvm/hello_world
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "valgrind $(BUILD_TESTS)/gcc/hello_world"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "valgrind $(BUILD_TESTS)/llvm/hello_world"
	touch $@

$(BUILD_TESTS)/gdb: $(BUILD_TESTS)/gcc/hello_world $(BUILD_TESTS)/llvm/hello_world
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		gdb -ex run -ex quit ./$(BUILD_TESTS)/gcc/hello_world && \
		gdb -ex run -ex quit ./$(BUILD_TESTS)/llvm/hello_world && \
		: "
	touch $@

$(BUILD_TESTS)/clang_tidy: $(BUILD_TESTS)/gcc/hello_world $(BUILD_TESTS)/llvm/hello_world
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c " \
		clang-tidy -p $(BUILD_TESTS)/gcc $(TESTS_DIR)/hello_world.cpp && \
		clang-tidy -p $(BUILD_TESTS)/llvm $(TESTS_DIR)/hello_world.cpp && \
		: "
	touch $@

$(BUILD_TESTS)/env: $(BUILD_DIR)/container
	# glibc compilation requires env variables to be correctly formed
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$PATH' | \
		grep --perl-regexp --quiet --invert-match --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$MANPATH' | \
		grep --perl-regexp --quiet --invert-match --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$INFOPATH' | \
		grep --perl-regexp --quiet --invert-match --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$PCP_DIR' | \
		grep --perl-regexp --quiet --invert-match --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$LD_LIBRARY_PATH' | \
		grep --perl-regexp --invert-match --quiet --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$PKG_CONFIG_PATH' | \
		grep --perl-regexp --invert-match --quiet --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$PYTHONPATH' | \
		grep --perl-regexp --invert-match --quiet --only-matching "(^:|:$$|::)"
	podman exec $(CONTAINER_NAME) \
		bash -c 'echo $$XDG_DATA_DIRS' | \
		grep --perl-regexp --invert-match --quiet --only-matching "(^:|:$$|::)"
	touch $@

$(BUILD_TESTS)/versions: $(BUILD_DIR)/container
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "cmake --version" | grep --perl-regexp --quiet "3\.26\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "gcc --version" | grep --perl-regexp --quiet "13\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "g++ --version" | grep --perl-regexp --quiet "13\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "clang --version" | grep --perl-regexp --quiet "17\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "clang++ --version" | grep --perl-regexp --quiet "17\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "clang-format --version" | grep --perl-regexp --quiet "17\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "clang-tidy --version" | grep --perl-regexp --quiet "17\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "FileCheck --version" | grep --perl-regexp --quiet "17\.\d+\.\d+"
	podman exec --workdir $$(pwd) $(CONTAINER_NAME) \
		bash -c "python3 --version" | grep --perl-regexp --quiet "3\.10\.\d+"
	bash_version=$$(podman exec --workdir "$$(pwd)" $(CONTAINER_NAME) \
		bash -c "bash --version" | grep --perl-regexp --only-matching "\d+\.\d+\.\d+"); \
		{ echo 4.4.0; echo $$bash_version; } | sort --version-sort --check &> /dev/null
	git_version=$$(podman exec --workdir "$$(pwd)" $(CONTAINER_NAME) \
		bash -c "git --version" | grep --perl-regexp --only-matching "\d+\.\d+\.\d+"); \
		{ echo 2.0.0; echo $$git_version; } | sort --version-sort --check &> /dev/null
	touch $@

$(BUILD_DIR)/tests/username: $(BUILD_DIR)/container
	container_username=$$(podman exec --workdir "$$(pwd)" $(CONTAINER_NAME) \
		bash -c "id --user --name") && \
	[[ "$$container_username" == "$$(id --user --name)" ]]
	container_home=$$(podman exec --workdir "$$(pwd)" $(CONTAINER_NAME) \
		bash -c "echo $$HOME") && \
	[[ "$$container_home" == "/home/$$(id --user --name)" ]]
	touch $@

.PHONY: check
check: \
	$(BUILD_DIR)/tests/gcc/hello_world \
	$(BUILD_DIR)/tests/llvm/hello_world \
	$(BUILD_DIR)/tests/clang_tidy \
	$(BUILD_DIR)/tests/gdb \
	$(BUILD_DIR)/tests/valgrind \
	$(BUILD_DIR)/tests/env \
	$(BUILD_DIR)/tests/username \
	$(BUILD_DIR)/tests/versions \

.PHONY: clean
clean:
	podman container ls --quiet --filter name=^$(CONTAINER_NAME) | xargs podman stop || true
	podman container ls --quiet --filter name=^$(CONTAINER_NAME) --all | xargs podman rm || true

