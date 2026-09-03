#!/bin/sh
set -x
: '=== A: no musl C compiler, CC unset -> honest failure'
../00-tools/without-musl-gcc.sh cargo build --release 2>&1 | grep -E '^(warning|error)' | sort -u
: '=== B: CC exported (Nix devshells do this) -> green, wrong compiler'
rm -rf target
CC=cc cargo build --release 2>&1 | tail -1
file target/x86_64-unknown-linux-musl/release/init
cc --version | head -1
readelf -p .comment target/x86_64-unknown-linux-musl/release/init   # who compiled the C in here?
../00-tools/boot.sh target/x86_64-unknown-linux-musl/release/init out/boot.txt
