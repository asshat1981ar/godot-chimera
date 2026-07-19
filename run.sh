#!/bin/bash
# Convenience runner for the Godot 4 editor / game in a Termux/PRoot environment
# where /mnt/sdcard is mounted noexec. The wrapper copies the Godot binary to
# /dev/shm (tmpfs, exec-capable) before launching.

set -e
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODOT_WRAPPER="$PROJECT_DIR/.tools/bin/run_godot4.sh"

exec bash "$GODOT_WRAPPER" "$@"
