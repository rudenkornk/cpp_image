# Docker image for C++ CI

Docker image for C++ CI.

[![GitHub Actions Status](https://github.com/rudenkornk/docker_cpp/actions/workflows/workflow.yml/badge.svg)](https://github.com/rudenkornk/docker_cpp/actions)


## Build
```shell
make rudenkornk/docker_cpp
```
Also, you can use Docker Hub image as cache source:
```shell
docker pull rudenkornk/docker_cpp:latest
DOCKER_CACHE_FROM=rudenkornk/docker_cpp:latest make rudenkornk/docker_cpp
```


## Test
```shell
make check
```

## Run
```shell
CI_BIND_MOUNT=$(pwd) make docker_cpp_container

docker attach docker_cpp_container
# OR
docker exec -it docker_cpp_container bash -c "source ~/.profile && bash"
```

## Clean
```shell
make clean
# Optionally clean entire docker system and remove ALL containers
./clean_all_docker.sh
```

## Different use cases for this repository
This repository supports three different scenarios

### 1. Use image directly for local testing or CI

```shell
docker run --interactive --tty \
  --user ci_user \
  --env CI_UID="$(id --user)" --env CI_GID="$(id --group)" \
  --mount type=bind,source="$(pwd)",target=/home/repo \
  rudenkornk/docker_cpp:latest
```

Instead of `$(pwd)` use path to your LaTeX repo.
It is recommended to mount it into `/home/repo`.
Be careful if mounting inside `ci_user`'s home directory (`/home/ci_user`): entrypoint script will change rights to what is written in `CI_UID` and `CI_GID` vars of everything inside home directory.

### 2. Use it with native GitHub Actions support (not recommended)
```yaml
jobs:
  build:
    runs-on: "ubuntu-20.04"
    container:
      image: rudenkornk/docker_cpp:0.1.0
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
    - name: Build
      run: # some build steps
```

Using it this way is not recommended, because GitHub Actions run commands as root and do not load any custom environment from the image.
Instead, it is better to use image directly in GitHub Actions script.
See also https://github.com/rudenkornk/docker_ci#2-use-it-in-github-actions

### 3. Use scripts from this repository to setup your own system:

```shell
# Ask system administrator to install necessary packages
./install_gcc.sh
./install_llvm.sh
./install_boost.sh
./install_cmake.sh
./config_system.sh
```

