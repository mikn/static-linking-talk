# 03 · a -sys crate that compiles C

`zstd = "0.13"` pulls `zstd-sys`, whose build script compiles zstd's C with the
`cc` crate. `cc` (1.4.4) decides host != target means cross-compiling and looks
for `x86_64-linux-musl-gcc`, then `musl-gcc`.

**A. Clean environment, no musl C compiler** (`00-tools/without-musl-gcc.sh`):

```
warning: zstd-sys@2.0.16+zstd.1.5.7: Compiler family detection failed due to error:
  ToolNotFound: failed to find tool "x86_64-linux-musl-gcc": No such file or directory (os error 2)
error: failed to run custom build command for `zstd-sys v2.0.16+zstd.1.5.7`
```

**B. `CC` exported.** Every Nix `mkShell` (so `nix develop` and devenv) exports
`CC=gcc`, `CXX=g++`, `AR=ar` via stdenv setup; a plain shell or `nix shell` does
not. `cc`
honours `CC` for every target, so the host gcc compiles zstd against glibc
headers and the result is linked into the musl binary:

```
$ CC=cc cargo build --release
    Finished `release` profile [optimized] target(s) in 16.82s
$ readelf -p .comment target/x86_64-unknown-linux-musl/release/init
  GCC: (GNU) 9.4.0        <- Rust's bundled musl crt/libc.a
  rustc version 1.95.0
  GCC: (GNU) 15.2.0       <- the host gcc. Not a musl compiler.

[init] hello from pid 1
[init] zstd 1.5.7
```

It boots because x86_64 glibc and musl agree on most of the C ABI. That is
luck, not a decision. With `musl-tools` installed and `CC` unset, `cc` picks
`musl-gcc` and `.comment` shows `GCC: (Debian 15.3.0-2) 15.3.0` instead.
