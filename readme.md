# Container image for C++ builds

Container image for reproducible C++ builds targeting local and CI usage.  

[![GitHub Actions Status](https://github.com/rudenkornk/docker_cpp/actions/workflows/workflow.yml/badge.svg)](https://github.com/rudenkornk/cpp_image/actions)


## Using the image
```bash
# Bootstrap
podman run --interactive --tty --detach \
  --env "TERM=xterm-256color" `# colored terminal` \
  --mount type=bind,source="$(pwd)",target="$(pwd)" `# mount your repo` \
  --name cpp \
  --userns keep-id `# keeps your non-root username` \
  --workdir "$HOME" `# podman sets homedir to the workdir for some reason` \
  ghcr.io/rudenkornk/cpp_ubuntu:22.0.1
podman exec --user root cpp bash -c "chown $(id --user):$(id --group) $HOME"

# Execute single command
podman exec --workdir "$(pwd)" cpp bash -c 'your_command'

# Attach to container
podman exec --workdir "$(pwd)" --interactive --tty cpp bash
```

## Build
**Requirements:** `podman >= 3.4.4`, `GNU Make >= 4.3`  
```bash
make
```

## Test
```bash
make check
```

## Clean
```bash
make clean
```
