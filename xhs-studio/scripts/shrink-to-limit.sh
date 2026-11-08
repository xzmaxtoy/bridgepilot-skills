#!/usr/bin/env bash
# Make sure a video is under the XHS size limit. Re-encodes at a computed bitrate when it is too big.
# Usage: shrink-to-limit.sh FILE [MAX_MB]     (default 95; MB = 1,000,000 bytes; XHS limit is 100)
# Exit 0 = file is under the limit (possibly after re-encoding), 1 = could not get it under.
set -euo pipefail
f="${1:?usage: shrink-to-limit.sh FILE [MAX_MB]}"
mb="${2:-${XHS_MAX_MB:-95}}"
max=$((mb * 1000000))
size="$(wc -c < "$f" | tr -d ' ')"
if [ "$size" -le "$max" ]; then echo "size ok: $size bytes (limit $max)"; exit 0; fi
dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")"
# video kbit/s = (limit bits * 0.93 safety) / seconds, minus 128 kbit/s for audio
kbps="$(python3 -c "import sys;d=float(sys.argv[1]);m=int(sys.argv[2]);print(max(300,int(m*8*0.93/d/1000)-128))" "$dur" "$max")"
echo "size $size > $max: re-encoding at ${kbps} kbit/s ..."
tmp="$f.shrink.mp4"
ffmpeg -v error -nostdin -y -i "$f" -c:v libx264 -preset medium -b:v "${kbps}k" -maxrate "${kbps}k" -bufsize "$((kbps * 2))k" \
  -pix_fmt yuv420p -c:a copy -movflags +faststart "$tmp"
mv "$tmp" "$f"
size="$(wc -c < "$f" | tr -d ' ')"
if [ "$size" -le "$max" ]; then echo "size ok after re-encode: $size bytes"; exit 0; fi
echo "STILL TOO BIG: $size bytes. Shorten the cut or lower --target."; exit 1
