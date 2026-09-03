#!/bin/sh
set -x
cargo zigbuild --release        # expected to fail: openssl-sys wants a musl libssl via pkg-config
