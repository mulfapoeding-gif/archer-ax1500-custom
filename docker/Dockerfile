# Docker build environment for Archer AX1500 GPL sources
# Based on Ubuntu 12.04 (Precise Pangolin) - required for old OpenWRT SDK

FROM ubuntu:12.04

LABEL maintainer="Archer AX1500 Custom Firmware Project"
LABEL description="Build environment for TP-Link Archer AX1500 GPL sources"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses5-dev \
    libncursesw5-dev \
    gawk \
    git \
    subversion \
    mercurial \
    wget \
    curl \
    unzip \
    zlib1g-dev \
    libssl-dev \
    gettext \
    flex \
    bison \
    patch \
    binutils \
    cpio \
    rsync \
    jq \
    python \
    python3 \
    python3-pip \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install requests pycryptodome

# Set up working directory
WORKDIR /router

# Create necessary directories
RUN mkdir -p /router/Iplatform/openwrt/dl \
    && mkdir -p /router/Iplatform/build \
    && mkdir -p /router/patches \
    && mkdir -p /router/output

# Copy helper scripts
COPY scripts/ /router/scripts/
COPY patches/ /router/patches/

# Set environment variables
ENV SHELL=/bin/bash
ENV PATH="/router/scripts:$PATH"

# Download required sources to dl directory
# These are often missing from old mirrors
RUN cd /router/Iplatform/openwrt/dl \
    && wget -q https://github.com/openwrt/openwrt/archive/refs/tags/v14.07.tar.gz -O openwrt-14.07.tar.gz \
    || echo "Download failed, will retry during build"

# Create build instructions
RUN echo '#!/bin/bash\n\
set -e\n\
echo "========================================"\n\
echo "  Archer AX1500 Build Environment"\n\
echo "========================================"\n\
echo ""\n\
echo "To build GPL sources:"\n\
echo "  1. Copy GPL source tarball to /router"\n\
echo "  2. Extract: tar -xzf sources.tar.gz"\n\
echo "  3. Apply patch: patch -p1 < /router/patches/router.patch"\n\
echo "  4. cd Iplatform/build"\n\
echo "  5. make menuconfig"\n\
echo "  6. make SHELL=/bin/bash V=s"\n\
echo ""\n\
echo "To build packages:"\n\
echo "  make package/<package_name>/compile V=s"\n\
echo ""\n\
echo "Output will be in: /router/Iplatform/build/bin/"\n\
echo ""\n\
' > /BUILD_INSTRUCTIONS.txt && chmod +x /BUILD_INSTRUCTIONS.txt

# Default command
CMD ["/bin/bash"]
