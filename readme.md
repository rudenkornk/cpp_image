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
  --user ci_user \
  --env CI_UID="$(id --user)" --env CI_GID="$(id --group)" \
  --mount type=bind,source="$(pwd)",target=/home/repo \
  rudenkornk/docker_cpp:latest
```

Instead of `$(pwd)` use path to your C++ repo.
It is recommended to mount it into `/home/repo`.
Be careful if mounting inside `ci_user`'s home directory (`/home/ci_user`): entrypoint script will change rights to what is written in `CI_UID` and `CI_GID` vars of everything inside home directory.

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
./config_conan.sh
```

