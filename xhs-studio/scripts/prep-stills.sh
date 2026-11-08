#!/usr/bin/env bash
# Turn phone photos (HEIC, JPG, PNG) into JPG files the cutdown can use. Real photos only.
# Usage: prep-stills.sh INPUT_FOLDER OUTPUT_FOLDER
# Converts every .heic/.heif with the first tool found (macOS: sips; else heif-convert; else ImageMagick),
# copies jpg/png as they are, and makes a contact sheet (stills-sheet.jpg) so you can pick cover and
# before/after photos. Then use them:
#   cutdown.py ... --cover-still OUT/IMG_x.jpg          (cover background)
#   cutdown.py ... --still before:OUT/IMG_y.jpg --still after:OUT/IMG_z.jpg   (2 s photo frames in the cut)
# Photos are subject to the same privacy check as video: look at every one (people, house numbers, plates).
set -euo pipefail
in="${1:?usage: prep-stills.sh INPUT_FOLDER OUTPUT_FOLDER}"
out="${2:?usage: prep-stills.sh INPUT_FOLDER OUTPUT_FOLDER}"
mkdir -p "$out"
conv=""
if command -v sips >/dev/null 2>&1; then conv=sips
elif command -v heif-convert >/dev/null 2>&1; then conv=heif-convert
elif command -v magick >/dev/null 2>&1; then conv=magick
fi
n=0; bad=0
for f in "$in"/*; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"; name="${base%.*}"; ext="$(printf '%s' "${base##*.}" | tr '[:upper:]' '[:lower:]')"
  case "$ext" in
    heic|heif)
      if [ -z "$conv" ]; then echo "no HEIC converter found (macOS has sips; else install libheif: brew install libheif / apt install libheif-examples)"; exit 1; fi
      case $conv in
        sips) sips -s format jpeg -s formatOptions 90 "$f" --out "$out/$name.jpg" >/dev/null 2>&1 || { echo "FAILED $base"; bad=$((bad+1)); continue; } ;;
        heif-convert) heif-convert -q 90 "$f" "$out/$name.jpg" >/dev/null 2>&1 || { echo "FAILED $base"; bad=$((bad+1)); continue; } ;;
        magick) magick "$f" -quality 90 "$out/$name.jpg" >/dev/null 2>&1 || { echo "FAILED $base"; bad=$((bad+1)); continue; } ;;
      esac
      n=$((n+1)) ;;
    jpg|jpeg|png) cp "$f" "$out/$base"; n=$((n+1)) ;;
  esac
done
echo "stills ready: $n in $out ($bad failed)"
# contact sheet, 6 per row, 200 px wide tiles (file order = sorted names)
if command -v ffmpeg >/dev/null 2>&1 && [ "$n" -gt 0 ]; then
  tmp="$(mktemp -d)"; i=0
  for f in "$out"/*.jpg "$out"/*.png; do
    case "$f" in */stills-sheet.jpg) continue;; esac
    [ -f "$f" ] || continue
    ffmpeg -v error -nostdin -y -i "$f" -frames:v 1 -vf "scale=200:200:force_original_aspect_ratio=decrease,pad=200:200:(ow-iw)/2:(oh-ih)/2" "$tmp/$(printf '%03d' $i).png" && i=$((i+1))
  done
  rows=$(( (i + 5) / 6 ))
  ffmpeg -v error -nostdin -y -start_number 0 -i "$tmp/%03d.png" -vf "tile=6x$rows:padding=4:color=black" -frames:v 1 -q:v 3 "$out/stills-sheet.jpg" && echo "sheet: $out/stills-sheet.jpg (tile order = sorted file names, row by row)"
fi
[ "$bad" = 0 ]
