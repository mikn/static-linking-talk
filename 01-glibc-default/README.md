# 01 · glibc default

`cargo build --release` produces a dynamically linked PIE. The initrd contains
one file, so the kernel cannot find the interpreter.

```
$ file target/release/init
init: ELF 64-bit LSB pie executable, x86-64, dynamically linked,
      interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0

[    0.671291] Run /init as init process
[    0.671634] Failed to execute /init (error -2)
[    0.671851] Run /sbin/init as init process
[    0.672073] Run /etc/init as init process
[    0.672255] Run /bin/init as init process
[    0.672445] Run /bin/sh as init process
[    0.672660] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel.
```

-2 is ENOENT. Full capture in `out/run.txt` and `out/boot.txt`.
