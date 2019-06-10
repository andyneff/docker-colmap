FROM nvidia/cuda:9.0-devel-ubuntu16.04 as colmap
# FROM nvidia/cuda:10.1-devel-ubuntu18.04 as colmap

SHELL ["/usr/bin/env", "bash", "-euxvc"]

RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl unzip ca-certificates \
        libgtk2.0-dev freeglut3-dev libdevil-dev libglew-dev liblapack-dev \
        libboost-program-options-dev libboost-filesystem-dev libboost-graph-dev \
        libboost-regex-dev libboost-system-dev libboost-test-dev libeigen3-dev \
        libsuitesparse-dev libfreeimage-dev libgoogle-glog-dev libgflags-dev \
        qtbase5-dev libqt5opengl5-dev libcgal-dev libcgal-qt5-dev \
        libatlas-base-dev libsuitesparse-dev; \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin; \
    curl -fLO https://github.com/ninja-build/ninja/releases/download/v1.7.1/ninja-linux.zip; \
    unzip ninja-linux.zip; \
    chmod +x /usr/local/bin/ninja; \
    rm ninja-linux.zip

# cmake
ARG CMAKE_VERSION=3.11.0
RUN cd /tmp; \
    curl -fLO https://cmake.org/files/v${CMAKE_VERSION%.*}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz; \
    curl -fLo cmake.txt https://cmake.org/files/v${CMAKE_VERSION%.*}/cmake-${CMAKE_VERSION}-SHA-256.txt; \
    grep 'Linux-x86_64\.tar\.gz' cmake.txt | sha256sum -c - > /dev/null; \
    tar --strip-components=1 -xf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz -C /usr/local; \
    rm cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz cmake.txt; \
    rm -rf /tmp/*

# ceres solver
ARG CERES_VERSION=1.14.0
RUN curl -fLO "https://github.com/ceres-solver/ceres-solver/archive/${CERES_VERSION}.zip"; \
    unzip "${CERES_VERSION}.zip"; \
    mkdir "ceres-solver-${CERES_VERSION}/build"; \
    pushd "ceres-solver-${CERES_VERSION}/build"; \
      cmake -G Ninja ..; \
      ninja install; \
    popd; \
    rm -rf "ceres-solver-${CERES_VERSION}" "${CERES_VERSION}.zip"

# colmap
ARG COLMAP_VERSION=c4ecd3221850d4a894668a8976debdc0d45541fc
ARG DSM_CUDA_ARCHS=Auto
RUN curl -fLO "https://github.com/colmap/colmap/archive/${COLMAP_VERSION}.zip"; \
    unzip "${COLMAP_VERSION}.zip"; \

    mkdir "colmap-${COLMAP_VERSION}/build"; \
    pushd "colmap-${COLMAP_VERSION}/build"; \
      cmake -G Ninja \
            -DCUDA_ARCHS="${DSM_CUDA_ARCHS}" \
            ..; \
      ninja -j `nproc` install; \
    popd; \
    rm -rf "colmap-${COLMAP_VERSION}" "${COLMAP_VERSION}.zip"