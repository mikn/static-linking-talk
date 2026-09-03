#!/bin/sh
# Run a command with every PATH entry that contains musl-gcc removed, and CC/CXX/AR unset.
# Simulates a machine without musl-tools so step 03 fails the way it does for most people.
P=$(printf '%s' "$PATH" | tr ':' '\n' | while read -r d; do [ -x "$d/musl-gcc" ] || [ -x "$d/x86_64-linux-musl-gcc" ] || printf '%s:' "$d"; done)
exec env -u CC -u CXX -u AR PATH="$P" "$@"
