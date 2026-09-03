# 06 · vendored + zigbuild

`features = ["vendored"]` switches `openssl-sys` to `openssl-src`, which runs
OpenSSL's own `perl Configure` + `make` with `CC` set to the zig wrapper. The
library gap becomes a compiler gap, which zig closes.

```
$ cargo zigbuild --release
    Finished `release` profile [optimized] target(s) in 28.06s   # ~4 min CPU
$ file target/x86_64-unknown-linux-musl/release/init
init: ELF 64-bit LSB executable, x86-64, statically linked, stripped
$ ldd target/x86_64-unknown-linux-musl/release/init
        not a dynamic executable
$ ls -lh target/x86_64-unknown-linux-musl/release/init
-rwxrwxr-x 4.1M init

[init] hello from pid 1
[init] zstd 1.5.7
[init] OpenSSL 3.6.3 9 Jun 2026
```

Needs `perl` and `make` on PATH (the first attempt failed on a stripped PATH
with `Command 'perl' not found`). If a crate has no `vendored`/`bundled`
feature, build where host == target instead (`rust:alpine`, `apk add
openssl-libs-static`); that is the only case that needs a sysroot.
