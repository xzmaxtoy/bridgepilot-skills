#!/usr/bin/env bash
# Make two short synthetic clips for testing the cutdown. NOT real footage; never post these.
# Usage: make-test-footage.sh OUTDIR
set -euo pipefail
out="${1:?usage: make-test-footage.sh OUTDIR}"
mkdir -p "$out"
# clip 1: 24 s landscape 1280x720, moving pattern; clip 2: 16 s vertical 720x1280, with a tone
ffmpeg -v error -nostdin -y -f lavfi -i "testsrc2=size=1280x720:rate=30,format=yuv420p" -t 24 \
  -f lavfi -i "sine=frequency=220:sample_rate=48000" -shortest -c:v libx264 -c:a aac "$out/test-landscape.mp4"
ffmpeg -v error -nostdin -y -f lavfi -i "mandelbrot=size=720x1280:rate=30,format=yuv420p" -t 16 \
  -c:v libx264 "$out/test-vertical.mp4"
ls -la "$out"
