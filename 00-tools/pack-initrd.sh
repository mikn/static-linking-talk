#!/bin/sh
# pack-initrd.sh <init-binary> <out.cpio>
# One file plus /dev/console (so pid 1 has a stdout). fakeroot lets mknod run without root.
set -e
d=$(mktemp -d)
mkdir -p "$d/dev" && cp "$1" "$d/init"
fakeroot sh -c "mknod -m 600 '$d/dev/console' c 5 1 && cd '$d' && find . | cpio -o -H newc" > "$2" 2>/dev/null
rm -rf "$d"
cpio -tv < "$2"
