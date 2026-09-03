#!/bin/sh
set -x
RUSTFLAGS="-C target-feature=+crt-static" cargo build --release
file target/release/init
timeout 1 ./target/release/init; echo "host exit: $? (124 = still running when timeout hit, i.e. fine)"
../00-tools/boot.sh target/release/init out/boot-static-pie.txt
RUSTFLAGS="-C target-feature=+crt-static -C relocation-model=static" cargo build --release --target-dir target-nopie
file target-nopie/release/init
../00-tools/boot.sh target-nopie/release/init out/boot-nopie.txt
