# build image
FROM docker.io/debian:12.8-slim AS build

# rust version
ARG VERSION=1.63.0

# install build dependencies
RUN apt-get update && apt-get install -y \
  curl git python3 build-essential ninja-build cmake pkg-config libssl-dev \
  && rm -rf /var/lib/apt/lists/*

# clone the rust source code
WORKDIR /src/rust
RUN git clone -c http.version=HTTP/1.1 -c advice.detachedHead=false \
  --depth 1 --recurse-submodules=':!src/doc' --shallow-submodules \
  https://github.com/rust-lang/rust --branch ${VERSION} .

# install bootstrap compiler
RUN python3 x.py --help > /dev/null || true

# add cross compilation toolchain
COPY toolchain /usr/local

# add config and target file
COPY config.toml ./
COPY armv4t-unknown-linux-uclibceabi.json /usr/local/share/rust-targets/

# build and install compiler
ENV RUST_TARGET_PATH=/usr/local/share/rust-targets
RUN python3 x.py build
RUN python3 x.py install

# fresh distribution image
FROM docker.io/debian:12.8-slim

# install runtime dependencies
RUN apt-get update && apt-get install -y \
  build-essential ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# add built toolchain
COPY --from=build /usr/local /usr/local
RUN ldconfig

# add executable shortcuts for convenience
RUN cd /usr/local/bin && \
  for f in *-uclibcgnueabi-*; do ln -s "$f" "arm-${f#*-uclibcgnueabi-}"; done

# add cargo configuration
COPY cargo-config.toml /.cargo/config.toml

# set up environment
ENV RUST_TARGET_PATH=/usr/local/share/rust-targets
WORKDIR /src
USER 1000:1000
CMD echo >&2 "specify an executable like cargo or arm-gcc"; exit 1
