# Use Debian 12 (bookworm) with specific digest for reproducibility
# To update: docker pull debian:12.8 && docker inspect debian:12.8 | grep sha256
FROM debian:12.8@sha256:17122fe3d66916e55c0cbd5bbf54bb3f87b3582f4d86a755a0fd3498d360f91b

LABEL version="2.0.0"
LABEL description="Image for building ARM embedded projects with pinned versions"

# Define versions as build arguments
ARG PYTHON_VERSION="3.14.1"
ARG GCC_VERSION="12.2.0"

# Install system dependencies with specific versions where critical
# Using debian packages which are more stable than Ubuntu PPAs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      gcc-12 \
      g++-12 \
      git \
      curl \
      wget \
      ca-certificates \
      libtool \
      autoconf \
      automake \
      pkg-config \
      # Python build dependencies
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      libncursesw5-dev \
      xz-utils \
      tk-dev \
      libxml2-dev \
      libxmlsec1-dev \
      libffi-dev \
      liblzma-dev \
      # Boost libraries
      libboost1.74-all-dev && \
    rm -rf /var/lib/apt/lists/*

# Set GCC 12 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100

# Build Python from source for exact version control
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --prefix=/usr/local && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-${PYTHON_VERSION}*

# Create symlinks for python3 and python
RUN ln -sf /usr/local/bin/python3.14 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3.14 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3.14 /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/pip3.14 /usr/local/bin/pip

# Install SRecord with specific version
ARG srecord_version="1.65"

WORKDIR /tmp
RUN wget https://downloads.sourceforge.net/project/srecord/srecord/${srecord_version}/srecord-${srecord_version}.0-Linux.deb && \
    apt-get install -y ./srecord-${srecord_version}.0-Linux.deb && \
    rm -f srecord-${srecord_version}.0-Linux.deb

# Install CMake with specific version
ARG cmake_version="3.31.10"
ARG cmake_platform="linux-x86_64"

WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-${cmake_platform}.sh && \
    mkdir -p /opt/cmake && \
    sh cmake-${cmake_version}-${cmake_platform}.sh --prefix=/opt/cmake --skip-license && \
    rm -f cmake-${cmake_version}-${cmake_platform}.sh
ENV PATH="/opt/cmake/bin:${PATH}"

# Install ARM GCC toolchain with specific version
ARG arm_version="14.2.rel1"
ARG arm_platform="x86_64-arm-none-eabi"

WORKDIR /tmp
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/${arm_version}/binrel/arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz && \
    mkdir -p /opt/armgcc && \
    tar -xf arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz --directory /opt/armgcc && \
    rm -f arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz
ENV PATH="/opt/armgcc/arm-gnu-toolchain-${arm_version}-${arm_platform}/bin:${PATH}"

# Install documentation tools
RUN apt-get update && apt-get install -y \
    doxygen \
    graphviz \
    plantuml

# Install draw.io desktop with specific version
RUN wget -O drawio.deb https://github.com/jgraph/drawio-desktop/releases/download/v30.0.0/drawio-amd64-30.0.0.deb
RUN apt-get install -y xvfb libnotify4 xdg-utils libsecret-1-0 libappindicator3-1
RUN apt-get install -y ./drawio.deb

# Set working directory to root and verify installations
WORKDIR /
RUN python --version && \
    cmake --version && \
    arm-none-eabi-gcc --version
