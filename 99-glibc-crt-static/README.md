# 99 · footnote: glibc +crt-static

`RUSTFLAGS="-C target-feature=+crt-static"` on the glibc target links, and
produces a static-pie. On this machine (Debian gcc 15.3 as linker, Debian glibc
static libs) that binary segfaults before `main`, both on the host and as pid 1:

```
$ timeout 1 ./target/release/init
Segmentation fault

[    0.632048] Run /init as init process
[    0.632611] init[1]: segfault at 28 ip 00007fb087675a85 ... error 4 in init[...]
[    0.634339] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
```

`segfault at 28` is a read of `%fs:0x28`, the stack-protector canary, before TLS
is set up. Adding `-C relocation-model=static` (non-PIE) boots fine. Not
investigated further; musl is the supported road.
