#!/usr/bin/env python3
# newc cpio with /dev/console (char 5,1) + /init, no root needed
import sys, os, struct
out = open(sys.argv[2], "wb")
ino = [1]
def entry(name, mode, data=b"", rdev=(0, 0)):
    ino[0] += 1
    hdr = "070701" + "".join("%08x" % v for v in [
        ino[0], mode, 0, 0, 1, 0, len(data), 3, 1, rdev[0], rdev[1], len(name) + 1, 0])
    buf = hdr.encode() + name.encode() + b"\0"
    buf += b"\0" * ((-len(buf)) % 4)
    buf += data
    buf += b"\0" * ((-len(buf)) % 4)
    out.write(buf)
entry("dev", 0o040755)
entry("dev/console", 0o020600, rdev=(5, 1))
entry("init", 0o100755, open(sys.argv[1], "rb").read())
entry("TRAILER!!!", 0)
out.close()
