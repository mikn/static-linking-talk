#!/bin/sh
# firecracker-boot.sh <init-binary> <serial-log>
# Needs: firecracker on PATH (or FIRECRACKER=...), an ELF vmlinux (VMLINUX=..., default ./vmlinux
# next to this script; make one with scripts/extract-vmlinux from your kernel's source/headers).
set -e
here=$(cd "$(dirname "$0")" && pwd)
FC="${FIRECRACKER:-firecracker}"
VMLINUX="${VMLINUX:-$here/vmlinux}"
"$here/pack-initrd.sh" "$1" /tmp/init.cpio >/dev/null
cat > /tmp/vm.json <<JSON
{
  "boot-source": {
    "kernel_image_path": "$VMLINUX",
    "initrd_path": "/tmp/init.cpio",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
  },
  "drives": [],
  "machine-config": { "vcpu_count": 1, "mem_size_mib": 256 }
}
JSON
timeout 15 "$FC" --no-api --config-file /tmp/vm.json > "$2" 2>&1 || true
grep -E 'Run /init|Failed to execute|Kernel panic|segfault|^\[init\]' "$2"
