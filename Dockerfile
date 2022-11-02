FROM ubuntu:22.04

# First, ask system administrator to install necessary packages
USER root
WORKDIR /etc/configs

COPY install_gcc.sh ./
RUN ./install_gcc.sh

COPY install_mingw.sh ./
RUN ./install_mingw.sh

COPY install_llvm.sh ./
RUN ./install_llvm.sh

COPY install_cmake.sh ./
RUN ./install_cmake.sh

COPY install_python.sh ./
RUN ./install_python.sh

COPY install_conan.sh ./
RUN ./install_conan.sh

COPY conan/ /root/.conan
RUN /root/.conan/config_conan.sh

COPY config_system.sh ./
RUN ./config_system.sh

COPY \
  license.md \
  entrypoint.sh \
  ./

WORKDIR /root
ENTRYPOINT ["/etc/configs/entrypoint.sh"]

# See https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="Nikita Rudenko"
LABEL org.opencontainers.image.vendor="Nikita Rudenko"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Docker image for C++ CI"
LABEL org.opencontainers.image.base.name="ubuntu:22.04"

ARG IMAGE_NAME
LABEL org.opencontainers.image.ref.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.url="https://hub.docker.com/repository/docker/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/${IMAGE_NAME}"

ARG VERSION
LABEL org.opencontainers.image.version="${VERSION}"

ARG VCS_REF
LABEL org.opencontainers.image.revision="${VCS_REF}"

ARG BUILD_DATE
LABEL org.opencontainers.image.created="${BUILD_DATE}"

