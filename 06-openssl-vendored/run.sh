#!/bin/sh
set -x
command -v perl; command -v make   # openssl-src needs both
cargo zigbuild --release
file target/x86_64-unknown-linux-musl/release/init
ldd target/x86_64-unknown-linux-musl/release/init
ls -lh target/x86_64-unknown-linux-musl/release/init
readelf -p .comment target/x86_64-unknown-linux-musl/release/init
../00-tools/boot.sh target/x86_64-unknown-linux-musl/release/init out/boot.txt
