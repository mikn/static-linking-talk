# static-linking-talk

Companion repo for the lightning talk **"PID 1 Has No Friends"**: static linking
in Rust, told through a stage-1 `init` for a Firecracker-style platform. One
folder per step. Every output quoted on the slides came from running these
folders on 2026-09-02.

| Step | What you do | What happens |
| --- | --- | --- |
| `01-glibc-default` | `cargo build --release`, boot it as `/init` | `Failed to execute /init (error -2)` → kernel panic. ENOENT on `/lib64/ld-linux-x86-64.so.2`. |
| `02-musl-target` | `rustup target add x86_64-unknown-linux-musl`, rebuild | `static-pie linked`, boots, prints from pid 1. Pure Rust is done here. |
| `03-zstd-needs-c-compiler` | add `zstd = "0.13"` (a `-sys` crate that compiles C) | A: `failed to find tool "x86_64-linux-musl-gcc"`. B: with `CC` exported (every Nix `mkShell`/devenv does this) it builds green using the **host** gcc against glibc headers. |
| `04-zstd-zigbuild` | `cargo zigbuild --release` | Builds. `.comment` shows only clang/LLD: zig brought its own C compiler and its own musl. |
| `05-openssl-pkg-config` | add `openssl` (a `-sys` crate that wants a prebuilt library) | `pkg-config has not been configured to support cross-compilation`. zig cannot help: nothing has `libssl.a` for musl. |
| `06-openssl-vendored` | `features = ["vendored"]`, `cargo zigbuild` | OpenSSL 3.6.3 compiled from source by zig cc, 25 s wall, 4.1 MB, boots. |
| `99-glibc-crt-static` | footnote: `-C target-feature=+crt-static` on glibc | static-pie output segfaults before `main` (host and VM); non-PIE boots. Not investigated. |

## Running it

Prerequisites: `rustup` (the toolchain file pins 1.95 and adds the musl target),
`qemu-system-x86_64` with `/dev/kvm` access, `python3`, and a readable kernel at
`/boot/vmlinuz-$(uname -r)` (override with `KERNEL=/path/to/vmlinuz`). Steps
04 to 06 need `zig` and `cargo-zigbuild` (`cargo install cargo-zigbuild`; zig via
your package manager or `pip install ziglang`). Step 06 needs `perl` and `make`.

```sh
cd 01-glibc-default && ./run.sh
```

Each `run.sh` builds, inspects the ELF (`file`, `ldd`, `readelf -p .comment`)
and boots the binary as the only file in an initrd under QEMU/KVM. Serial
output lands in `out/`. `00-tools/mkcpio.py` writes the newc cpio (with a
`/dev/console` node so pid 1 has a stdout) without needing root.

### Booting with Firecracker instead

`00-tools/firecracker-boot.sh <init> <log>` does the same with Firecracker
(v1.16.1 tested). It packs the initrd with plain `cpio` under `fakeroot`
(`00-tools/pack-initrd.sh`) and boots with `firecracker --no-api
--config-file vm.json`. Firecracker wants an ELF `vmlinux`, not a bzImage:

```sh
/usr/src/linux-headers-$(uname -r)/scripts/extract-vmlinux /boot/vmlinuz-$(uname -r) > 00-tools/vmlinux
cd 02-musl-target && ../00-tools/firecracker-boot.sh target/x86_64-unknown-linux-musl/release/init out/firecracker.txt
```

`out/firecracker.txt` in steps 01, 02 and 06 are captures from that path; the
slides use them.

### What the platform's real stage 1 depends on

`bazel/stateful/rootfs/sandbox-initrd` depends on `libc` and `nlrs` only: pure
Rust, no `-sys` crate. The talk's init adds one anyway, because that is the
lesson; `zstd` and `openssl` were picked because both are already in the
platform's workspace lock (`zstd = "0.13"` directly in drydock and
uffd-handler, `openssl-sys` transitively via `nydus-utils`), alongside
`lz4-sys`, `libz-sys`, `userfaultfd-sys`, `devicemapper-sys` and `aws-lc-sys`.

Step 03 uses `00-tools/without-musl-gcc.sh` to hide `musl-gcc` and unset `CC`
so the failure reproduces on a machine that has `musl-tools` installed.

## What the steps establish

- Rust code is already statically linked. libc and the C behind `-sys` crates are not.
- `rustup target add x86_64-unknown-linux-musl` ships std **and** a self-contained musl `libc.a`. Pure Rust needs no system packages.
- A `-sys` crate that compiles C needs a C compiler for the target. `cc` 1.4.4 looks for `x86_64-linux-musl-gcc`, then `musl-gcc`. `musl-tools` satisfies it (verified: `.comment` shows Debian's gcc via the musl wrapper), unless something exports `CC`, which `cc` honours for every target.
- A `-sys` crate that wants a prebuilt library needs that library built for musl. No compiler produces it. `vendored`/`bundled` features sidestep it by compiling from source; otherwise build where host == target (Alpine).
- `cargo zigbuild` is the one-tool answer for the compiler gap: it sets the target-specific `CC_x86_64_unknown_linux_musl`, which beats a stray `CC`, and links against zig's own musl.
- Verify with the ELF, not the build log: `file`, `ldd`, and `readelf -p .comment` (who compiled the C in this binary).

## Versions

rustc 1.95.0 · cc 1.4.4 · zstd-sys 2.0.16+zstd.1.5.7 · openssl-sys 0.9.117 ·
openssl-src 300.6.1+3.6.3 · zig 0.16.0 · cargo-zigbuild 0.23.0 · host: Debian
forky, gcc 15.3 (Debian) and 15.2 (Nix), musl-tools 1.2.x · guest kernel:
Debian 7.1.7 under QEMU 10 with KVM.
