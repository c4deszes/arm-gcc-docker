FROM ubuntu:22.04

LABEL version="1.3.0"
LABEL description="Image for building ARM embedded projects"

# Install common tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
      build-essential \
      git \
      curl \
      wget \
      libboost-all-dev \
      libtool \
      software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && \
    apt-get install -y python3.10 python3.10-distutils && \
    apt-get install -y python3.10-venv python3.10-dev && \
    apt-get install -y python3-pip

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --set python3 /usr/bin/python3.10 && \
    ln -s /usr/bin/python3.10 /usr/bin/python

# Install SRecord
ARG srecord_version="1.65"

WORKDIR /
RUN wget https://downloads.sourceforge.net/project/srecord/srecord/${srecord_version}/srecord-${srecord_version}.0-Linux.deb
RUN apt install -y ./srecord-${srecord_version}.0-Linux.deb

# Install CMake
ARG cmake_version="3.28.1"
ARG cmake_platform="linux-x86_64"

WORKDIR /
RUN mkdir /opt/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-${cmake_platform}.sh
RUN sh cmake-${cmake_version}-${cmake_platform}.sh --prefix=/opt/cmake --skip-license
ENV PATH "$PATH:/opt/cmake/bin"

# Install ARM GCC
ARG arm_archive="13.2.rel1"
ARG arm_version="13.2.rel1"
ARG arm_folder="13.2.Rel1"
ARG arm_platform="x86_64-arm-none-eabi"

WORKDIR /
RUN mkdir /opt/armgcc
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/${arm_archive}/binrel/arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz
RUN tar -xf arm-gnu-toolchain-${arm_version}-${arm_platform}.tar.xz --directory /opt/armgcc
ENV PATH "$PATH:/opt/armgcc/arm-gnu-toolchain-${arm_folder}-${arm_platform}/bin"
