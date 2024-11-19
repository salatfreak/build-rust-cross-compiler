#!/bin/sh

exec podman run --rm \
  --volume .:/src \
  --userns keep-id --user "$(id -u):$(id -g)" \
  rust-cross-compiler:1.63 "$@"
