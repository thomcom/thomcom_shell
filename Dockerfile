##############################################################################
# thomcom-shell Multi-Stage Dockerfile
#
# Build targets:
#   docker build --target base  -t thomcom-shell:base  .
#   docker build --target shell -t thomcom-shell:shell .
#   docker build --target full  -t thomcom-shell:full  .
##############################################################################

FROM ubuntu:24.04 AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl git git-lfs ca-certificates bzip2 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash devkit || true
USER devkit
WORKDIR /home/devkit

COPY --chown=devkit:devkit . /home/devkit/.thomcom_shell/

RUN /home/devkit/.thomcom_shell/install.sh --tier base --docker

LABEL org.thomcom.shell.tier="base"
ARG THOMCOM_VERSION=unknown
LABEL org.thomcom.shell.version="${THOMCOM_VERSION}"

SHELL ["/bin/bash", "-l", "-c"]
CMD ["bash", "-l"]

# ---

FROM base AS shell

RUN /home/devkit/.thomcom_shell/install.sh --tier shell --docker

LABEL org.thomcom.shell.tier="shell"

# ---

FROM shell AS full

RUN /home/devkit/.thomcom_shell/install.sh --tier full --docker

LABEL org.thomcom.shell.tier="full"
