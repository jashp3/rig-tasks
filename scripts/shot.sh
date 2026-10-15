#!/usr/bin/env bash
# Render a local HTML file to a PNG.
#   scripts/shot.sh <file-or-url> <out.png> [width] [height]
#
# Environment notes for this box (all three are required, none are defaults):
#   /root/.npm is read-only  -> npm_config_cache must point somewhere writable
#   agent-browser socket dir -> XDG_RUNTIME_DIR must be writable
#   headless compositing     -> --disable-gpu, or screenshots come out blank
set -euo pipefail

target="${1:?usage: shot.sh <file-or-url> <out.png> [width] [height]}"
out="${2:?usage: shot.sh <file-or-url> <out.png> [width] [height]}"
width="${3:-1280}"
height="${4:-800}"

case "$target" in
  /*) url="file://$target" ;;
  *)  url="$target" ;;
esac

export XDG_RUNTIME_DIR=/tmp/ab-run
export TMPDIR=/tmp
export npm_config_cache=/root/.openrig/workspace/.npm-cache
export AGENT_BROWSER_HOME=/tmp/ab-home
export AGENT_BROWSER_ARGS="--disable-gpu --no-sandbox --disable-dev-shm-usage"

mkdir -p "$XDG_RUNTIME_DIR" /tmp/ab-home
chmod 700 "$XDG_RUNTIME_DIR"

ab() { npx --yes agent-browser "$@"; }

ab open "$url" >/dev/null
ab set viewport "$width" "$height" >/dev/null
ab reload >/dev/null
ab wait --load networkidle >/dev/null
ab screenshot --full "$out" >/dev/null

echo "$out ($width x $height)"
