# 02 · musl target

`.cargo/config.toml` sets `build.target = "x86_64-unknown-linux-musl"`. The
target ships std plus a self-contained musl `libc.a` and crt objects, so no
system packages are involved.

```
$ rustup target add x86_64-unknown-linux-musl
info: downloading component rust-std
$ cargo build --release
$ file target/x86_64-unknown-linux-musl/release/init
init: ELF 64-bit LSB pie executable, x86-64, static-pie linked, not stripped
$ ldd target/x86_64-unknown-linux-musl/release/init
        statically linked

[    0.629589] Run /init as init process
[init] hello from pid 1
```
