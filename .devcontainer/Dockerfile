# syntax=docker/dockerfile:1
ARG NODE_VERSION=24
FROM mcr.microsoft.com/devcontainers/javascript-node:${NODE_VERSION}

ARG USER=node
ARG DEBIAN_FRONTEND=noninteractive

# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo
# VERSION can be either 'latest' or a specific version number
ARG VERSION=0.54.0

# Download Hugo
RUN case ${VERSION} in \
    latest) \
    export VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}') ;;\
    esac && \
    echo ${VERSION} && \
    case $(uname -m) in \
    aarch64) \
    export ARCH=ARM64 ;; \
    *) \
    export ARCH=64bit ;; \
    esac && \
    echo ${ARCH} && \
    wget -O ${VERSION}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-${ARCH}.tar.gz && \
    tar xf ${VERSION}.tar.gz && \
    mv hugo /usr/bin/hugo

# Hugo dev server port
EXPOSE 1313


USER ${USER}
ARG HOME=/home/${USER}
WORKDIR ${HOME}

ARG PNPM_HOME=${HOME}/.local/share/pnpm
ENV PATH="${PNPM_HOME}:$PATH"
ENV SHELL="bash"
RUN wget -qO- https://get.pnpm.io/install.sh
RUN pnpm env use -g 20
RUN pnpm setup