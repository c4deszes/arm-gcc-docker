FROM ubuntu:23.04

LABEL version="1.1.0"
LABEL description="Image for building ARM embedded projects"

# Install common tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
      build-essential \
      git \
      curl \
      wget \
      boost-dev \
      libtool

# Install SRecord
ARG srecord_version="1.65"

WORKDIR /
RUN wget https://sourceforge.net/projects/srecord/files/srecord/${srecord_version}/srecord-${srecord_version}.tar.gz
RUN tar -xf srecord-${srecord_version}.tar.gz --directory /opt/srecord
WORKDIR /opt/srecord/srecord-${srecord_version}
RUN ./configure --without-gcrypt && make all-bin && make install-bin install-libdir install-include

# Install CMake
ARG cmake_version="3.28.1"
ARG cmake_platform="linux-x86_64"

WORKDIR /
RUN mkdir /opt/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-${cmake_platform}.sh
RUN sh cmake-${cmake_version}-${cmake_platform}.sh --prefix=/opt/cmake --skip-license
ENV PATH "$PATH:/opt/cmake/bin"

# Install Python
WORKDIR /
RUN apt-get install -y python3.11
RUN echo 'alias python="python3.11"' >> ~/.bashrc
RUN echo 'alias python3="python3.11"' >> ~/.bashrc

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
