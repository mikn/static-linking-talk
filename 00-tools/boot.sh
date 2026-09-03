#!/bin/sh
# boot.sh <init-binary> <serial-log>  — boots a one-file initrd under QEMU/KVM
set -e
KERNEL="${KERNEL:-/boot/vmlinuz-$(uname -r)}"
python3 "$(dirname "$0")/mkcpio.py" "$1" /tmp/init.cpio
timeout 20 qemu-system-x86_64 -enable-kvm -m 256 -display none -no-reboot \
  -kernel "$KERNEL" -initrd /tmp/init.cpio \
  -append "console=ttyS0 panic=1 loglevel=7" -serial "file:$2" >/dev/null 2>&1 || true
grep -E 'Run /init|Failed to execute|Kernel panic|segfault|^\[init\]' "$2"
