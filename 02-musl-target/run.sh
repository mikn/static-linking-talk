#!/bin/sh
set -x
rustup target add x86_64-unknown-linux-musl
cargo build --release                       # .cargo/config.toml sets the target
file target/x86_64-unknown-linux-musl/release/init
ldd target/x86_64-unknown-linux-musl/release/init
../00-tools/boot.sh target/x86_64-unknown-linux-musl/release/init out/boot.txt
