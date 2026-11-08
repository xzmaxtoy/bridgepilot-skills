#!/usr/bin/env bash
# Gate + QA for the finished video that /hyperframes produced.
# Usage: final-check.sh JOBDIR
#   JOBDIR holds video-brief.json (written by cutdown.py, filled with the client) and final.mp4 (the HyperFrames render).
#   Exit 2  = the brief is not approved by the client (approved is false): the video is only a DRAFT, do not call it final.
#   Exit 1  = final.mp4 missing or fails the checks (1080x1920, 3-60 s, size). Prints what to fix.
#   Exit 0  = final.mp4 accepted. The size is brought under XHS_MAX_MB (default 95) by shrink-to-limit.sh.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
job="${1:?usage: final-check.sh JOBDIR}"
job="$(cd "$job" && pwd)"
[ -f "$job/video-brief.json" ] || { echo "missing $job/video-brief.json (run cutdown.py first)"; exit 1; }
approved="$(python3 -c 'import json,sys;print(str(json.load(open(sys.argv[1])).get("approved",False)).lower())' "$job/video-brief.json")"
if [ "$approved" != "true" ]; then
  echo "BLOCKED: video-brief.json has approved=false. The words and the edit are still a DRAFT."
  echo "Show the preview and the Chinese text to the client, apply their rewrite, set approved to true, then check again."
  exit 2
fi
[ -s "$job/final.mp4" ] || { echo "missing $job/final.mp4. Ask /hyperframes to render the approved edit to $job/final.mp4"; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe not found (install ffmpeg)"; exit 1; }
w="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$job/final.mp4")"
h="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$job/final.mp4")"
d="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$job/final.mp4")"
echo "final.mp4: ${w}x${h}, ${d}s"
[ "$w" = 1080 ] && [ "$h" = 1920 ] || { echo "FAIL: must be 1080x1920 (9:16). Ask /hyperframes to render at 1080x1920."; exit 1; }
python3 - "$d" "$job/video-brief.json" <<'PY' || exit 1
import json, sys
duration = float(sys.argv[1])
if not 3 <= duration <= 60:
    sys.exit("FAIL: length must be 3-60 s")
requested = (json.load(open(sys.argv[2])).get("requirements") or {}).get("length_sec")
if requested is not None:
    if isinstance(requested, bool) or not isinstance(requested, (int, float)) or not 3 <= requested <= 60:
        sys.exit("FAIL: brief length_sec must be a number from 3 to 60")
    if abs(duration - requested) > 0.1:
        sys.exit("FAIL: rendered %.3f s does not match approved %.3f s" % (duration, requested))
PY
bash "$here/shrink-to-limit.sh" "$job/final.mp4"
echo "final OK: $job/final.mp4"
