# 05 · a -sys crate that wants a prebuilt library

`openssl = "0.10"` pulls `openssl-sys`, whose build script does not compile
OpenSSL. It asks pkg-config where `libssl` is. zig is a compiler and cannot
answer that; nothing on the machine has `libssl.a` built for musl.

```
$ cargo zigbuild --release
error: failed to run custom build command for `openssl-sys v0.9.117`

  Could not find openssl via pkg-config:
  pkg-config has not been configured to support cross-compilation.

  Install a sysroot for the target platform and configure it via
  PKG_CONFIG_SYSROOT_DIR and PKG_CONFIG_PATH, or install a
  cross-compiling wrapper for pkg-config and set it via
  PKG_CONFIG environment variable.

  $HOST = x86_64-unknown-linux-gnu
  $TARGET = x86_64-unknown-linux-musl
  openssl-sys = 0.9.117
```

Same CPU, different libc: pkg-config correctly treats this as cross-compiling
and refuses to hand out the glibc `libssl.so` from `libssl-dev`.
