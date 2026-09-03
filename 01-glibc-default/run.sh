#!/bin/sh
set -x
cargo build --release
file target/release/init
ldd target/release/init
../00-tools/boot.sh target/release/init out/boot.txt
