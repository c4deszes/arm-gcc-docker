FROM ubuntu

LABEL version="1.1.0"
LABEL description="Image for building ARM embedded projects"

# Install common tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
      build-essential \
      git \
      curl \
      wget

# Install CMake
ARG cmake_version="3.28.1"
ARG cmake_platform="linux-x86_64"

RUN mkdir /opt/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-${cmake_platform}.sh
RUN sh cmake-${cmake_version}-${cmake_platform}.sh --prefix=/opt/cmake --skip-license
ENV PATH "$PATH:/opt/cmake/bin"

# Install Python
RUN apt-get install -y python3.12

# ARM GCC configuration
ARG arm_archive="13.2.rel1"
ARG arm_version="13.2.rel1"
ARG arm_platform="x86_64-aarch64-none-linux-gnu"

# Install ARM GCC
RUN mkdir /opt/armgcc
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/${arm_archive}/binrel/arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz
RUN tar -xf gcc-arm-none-eabi-${arm_version}-${arm_platform}.tar.bz2 --directory /opt/armgcc
ENV PATH "$PATH:/opt/armgcc/gcc-arm-none-eabi-${arm_version}/bin"
