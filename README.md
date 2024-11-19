# Rust Cross Compiler for ARMv4T with uClibc
This repository provides the containerized build process for the *Rust*
compiler targeting cross compilation for embedded devices with *ARMv4T* based
MCUs running *Linux* with *uClibc* 0.9. This target is not officially supported
and therefore needs to be compiled from source.

This code should also be a good starting point for building custom cross
compilers for other targets as well. Care has been taken to keep everything
clear and minimal.

## Building the Compiler
To build the *Rust* cross compiler you'll first need to build a GNU cross
compilation toolchain using a tool like [crosstool-ng][crosstool].
A containerized version of that can be found in the
[crosstool][crosstool-container] repository. Place your toolchain in the
toolchain directory. It should contain the directories *bin*, *lib* etc. and
one for your target (like *arm-unknown-linux-uclibcgnueabi*).

Inside that target directory you may replace the sysroot with the file tree
from your actual device.

Now you can build the container image by executing `podman build -t
rust-cross-compiler .`. This will take about an hour or more. For convenience
you may use the *cross-compiler.sh* script for running the container. For
example run `cross-compiler.sh cargo init` for initializing a new *Rust*
project in the current directory.

[crosstool]: https://github.com/crosstool-ng/crosstool-ng
[crosstool-container]: https://github.com/salatfreak/crosstool-container

## Rust Version
*Rust* version 1.64 [increased the required *libc* version from 2.11 to
2.17][version-bump] which is incompatible with the *uClibc* 0.9. *Rust* 1.63 is
therefore the latest version compatible with *uClibc* 0.9.

[version-bump]: https://blog.rust-lang.org/2022/08/01/Increasing-glibc-kernel-requirements.html

## Creating a Target Specification
Your new target needs to be specified inside a JSON file. You can base it on
one of the existing targets. Make sure you have the nightly toolchain installed
using `rustup toolchain install nightly`. You can now list the available
targets using `rustc +nightly -Z unstable-options --print target-list` and get
a specific target's specification by executing `rustc +nightly -Z
unstable-options --target <TARGET> --print target-spec-json`. You'll need to
remove the "is-builtin" entry for your custom targets.
