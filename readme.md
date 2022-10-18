# Docker image for C++ CI

Docker image for C++ CI.

[![GitHub Actions Status](https://github.com/rudenkornk/docker_cpp/actions/workflows/workflow.yml/badge.svg)](https://github.com/rudenkornk/docker_cpp/actions)


## Build
```bash
make image
```
Also, you can use Docker Hub image as cache source:
```bash
docker pull rudenkornk/docker_cpp:latest
DOCKER_CACHE_FROM=rudenkornk/docker_cpp:latest make image
```


## Test
```bash
make check
```

## Run
```bash
make container

docker attach docker_cpp_container
# OR
docker exec -it docker_cpp_container bash -c "source ~/.profile && bash"
```

## Clean
```bash
make clean
# Optionally clean entire docker system and remove ALL containers
./clean_all_docker.sh
```

## Different use cases for this repository
This repository supports two different scenarios

### 1. Use image directly for local testing or CI

```bash
docker run --interactive --tty \
  --env USER_ID="$(id --user)" --env USER_NAME="$(id --user --name)" \
  --mount type=bind,source="$(pwd)",target="$(pwd)" \
  --workdir "$(pwd)" \
  rudenkornk/docker_cpp:latest
```
Instead of `$(pwd)` use path to your C++ repo.

### 2. Use scripts from this repository to setup your own system

```bash
# Ask system administrator to install necessary packages
./install_gcc.sh
./install_llvm.sh
./install_cmake.sh
./install_python.sh
./install_conan.sh
./config_system.sh

# Config normal user
cp --recursive conan ~/.conan
~/.conan/config_conan.sh
```

