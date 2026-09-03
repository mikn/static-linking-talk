#!/bin/sh
set -x
zig version; cargo-zigbuild --version
cargo zigbuild --release
file target/x86_64-unknown-linux-musl/release/init
readelf -p .comment target/x86_64-unknown-linux-musl/release/init
../00-tools/boot.sh target/x86_64-unknown-linux-musl/release/init out/boot.txt
