# 04 · cargo zigbuild

Same crate as 03. `cargo zigbuild` points `CC_x86_64_unknown_linux_musl`,
`AR_…` and the linker at wrappers around `zig cc -target x86_64-linux-musl`.
The target-specific variable beats a stray `CC`, and zig carries musl's headers
and libc source, so nothing from the host toolchain is used.

```
$ cargo zigbuild --release
   Compiling zstd-sys v2.0.16+zstd.1.5.7
    Finished `release` profile [optimized] target(s) in 3.20s
$ file target/x86_64-unknown-linux-musl/release/init
init: ELF 64-bit LSB executable, x86-64, statically linked, stripped
$ readelf -p .comment target/x86_64-unknown-linux-musl/release/init
  rustc version 1.95.0
  Linker: LLD 21.1.8
  clang version 21.1.8

[init] hello from pid 1
[init] zstd 1.5.7
```

Note the `GCC: (GNU) 9.4.0` line is gone too: zig linked its own musl instead
of Rust's bundled one.
