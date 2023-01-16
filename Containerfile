FROM docker.io/library/ubuntu:22.04

WORKDIR /etc/configs

COPY install_basic_utils.sh ./
RUN ./install_basic_utils.sh

COPY install_gcc.sh ./
RUN ./install_gcc.sh

COPY install_llvm.sh ./
RUN ./install_llvm.sh

COPY install_cmake.sh ./
RUN ./install_cmake.sh

COPY install_python.sh ./
RUN ./install_python.sh

COPY config_system.sh ./
RUN ./config_system.sh

COPY license.md ./

WORKDIR /root

# See https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="Nikita Rudenko"
LABEL org.opencontainers.image.vendor="Nikita Rudenko"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Container image for C++ builds."
LABEL org.opencontainers.image.base.name="ubuntu:22.04"
