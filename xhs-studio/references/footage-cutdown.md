# Footage planning and cutdown for a vertical post

New build; nothing like it existed in the source skills. Real footage only. The point: the client films a whole job (maybe an hour), and gets back a short vertical cut with a hook, Chinese text and a cover, in minutes instead of hours.

## Tools
`ffmpeg` and `ffprobe` cut and crop the rough cut (`scripts/cutdown.py`). The edit, the Chinese on-screen text and the cover are made by the separately installed **/hyperframes** skill (HyperFrames, Apache 2.0). This skill gives it a brief; `scripts/final-check.sh` checks and gates the result. Check everything with `scripts/doctor.sh` and `scripts/check-hyperframes.sh`.

## Getting the footage in
- A folder on the computer: use it as is.
- A zip (Google Drive or a phone-folder download): `python3 "$SKILL_DIR/scripts/unpack-footage.py" FOOTAGE.zip FOLDER`. The system `unzip` can abort on a Chinese file name ("write error (disk full?)" while the disk is fine) and then silently skip every file after it, often the two biggest clips. The script extracts file by file, continues after an error, and compares every file with the zip listing. It must end with "all files present and complete". If it lists problems, do not use the folder: download the zip again.
- Phone photos: `bash "$SKILL_DIR/scripts/prep-stills.sh" INPUT_FOLDER OUTPUT_FOLDER` converts HEIC to JPG (macOS `sips`, else `heif-convert`, else ImageMagick) and writes `stills-sheet.jpg` (6 per row, sorted file names). Pick: a cover background (`--cover-still IMG.jpg`) or before/after frames shown for 2 s each (`--still before:IMG.jpg`, `--still after:IMG.jpg`). Real photos of the job only. Same privacy check as video.

## Storyline and storyboard before editing

Inspect the actual footage before suggesting a narrative. For a new narrative video over roughly 15 seconds, follow the installed HyperFrames vertical/social, story, and specification guidance: propose three distinct storylines in words, put the recommendation first, let the client choose, then save `STORYLINES.md`, `SPEC.md`, and a storyboard before cutting. Honor explicit user scripts/storyboards and HyperFrames' no-stops/file-delivery exceptions.

The storyboard maps output times or frame ranges to source clips and intervals, framing, draft copy, and sound cues. It must show what the footage can actually support. Missing after footage means requesting it or agreeing a different story, not creating or relabelling a finished yard. Planning choices do not approve final copy, a final render, or publication.

The automatic cutdown below is optional and specifically result-led. Use it only after choosing a compatible story; use original sources in HyperFrames for other structures. A `--plan-only` pass may help inspect candidate intervals, but is not a replacement for storyline selection or a storyboard.

## Confirm unresolved footage facts in a small group
1. Which clip shows the **finished result**? (`--result`, required. Without it the script assumes the last clip and warns loudly.)
2. Is there a clip to open the post with? (`--hook`, optional. Default: the best moment of the result clip.)
3. Which clip shows how it looked before? (`--before`, optional.)
4. Anything to leave out (a person, a neighbour, a meter, a street sign)? (`--avoid "IMG_2597.MOV@8-17"`.)

## Run it
```
python3 "$SKILL_DIR/scripts/cutdown.py" FOLDER_OR_CLIPS --result IMG_2600.MOV --out "$XHS_HOME/jobs/2026-10-20-turf-sanjose" \
   [--hook CLIP] [--before CLIP] [--avoid "CLIP@from-to"] [--still before:IMG.jpg] [--cover-still IMG.jpg] \
   [--target 20] [--fit crop|blur] [--audio mute|keep] [--speed 3] [--plan-only]
```
- Clips are read in name order (the phone's order = time order) when you pass a folder. Clip names can be file names only.
- Output in the job folder:
  - `cut-plan.json` - the plan: which second of which clip, the role of each piece, speed, `pan`, `zoom`, `note`. Editable.
  - `plan-review.jpg` + `plan-review.md` - the review sheet and table (see "Review the plan").
  - `rough.mp4` - 1080x1920, 30 fps, H.264, muted by default.
  - `cover-raw.png` - a frame from the hook (or your `--cover-still`).
  - `video-brief.json` - the client requirements and Chinese text, all empty, `approved: false` (handed to /hyperframes).
- `--plan-only` stops after the plan and the review sheet (no render), useful for a first look.
- Long footage takes time: every clip is decoded three times at low resolution to score it (a 60 s phone clip about 8 s). Say so; do not stop it.

## How the cut is built
1. **Score** every second: sharpness (edge energy), motion (frame difference), exposure. Too dark or blown-out seconds are pushed down; violent camera swings are pushed down. Seconds you `--avoid` are never used.
2. **Story:** HOOK (2 s, from `--hook`, else the best moment of the result clip) -> BEFORE (first part of the other clips, or `--before`) -> DURING (the rest, sped up, default 3x) -> AFTER. About 30% / 40% / 30% of the time after the hook. **AFTER comes only from the result clip(s)** as one continuous stretch (a result reads better as one shot than as several cuts of the same view). At least one AFTER segment is guaranteed.
3. **Crop** to 9:16. `--fit crop` fills the frame (landscape clips lose their sides). `--fit blur` keeps the whole landscape frame on a blurred copy of itself. Per segment `pan` (0 = left edge, 1 = right edge) slides the crop on landscape clips and `zoom` (1.0-2.0) crops in. Phone-vertical clips only change with `zoom`.
4. **Audio** muted by default: jobsite wind and engine noise ruin a post, and the client adds trending music in the XHS app. `--audio keep` keeps source sound at 60% on the normal-speed pieces only.

It is a first draft by rule, not taste. Show the cut to the client; they say "keep, shorter, other moment". Change the plan, not the pipeline.

## Review the plan (privacy and story) BEFORE the client sees it
There is **no automatic person, face or object detection** in this package. A skin-tone test was tried on real footage and rejected: soil, wood and wet sod trigger it, so it flags everything. You, and then the client, are the check:
1. Open `plan-review.jpg`. One tile per segment, row by row, 4 per row, tile 0 = segment #0, cropped exactly as rendered. Use the table in `plan-review.md` to map a tile to a clip and second.
2. Look at every tile, **including the edges**, for: any person (back, side, partly in frame), a face, a house number, a street sign, a licence plate, a utility meter or panel, a neighbour's yard, a customer's belongings.
3. Fix each one: delete the segment from `cut-plan.json`; or change `start` to another moment; or slide the crop with `pan` / crop in with `zoom` so the person is outside the frame; or add `--avoid` and re-run. Then `cutdown.py --render-plan JOB/cut-plan.json` (about 10 s) and look at the new `plan-review.jpg`.
4. Check the story: hook shows the result or a clear contrast; the ending shows the finished result; no repeated near-identical tiles in a row; nothing the footage does not show.
5. Record in the log: "privacy check done, N segments dropped or cropped".
If you cannot view images, the client reviews the sheet themselves before approving. Do not claim the check was done.

## Length and pace
Recommend 15–20 seconds when the client has no preference; support explicit requests from 3–60 seconds. Pass the requested length to the brief and `--target` without silently clamping it. The automatic rough plan is approximate: report insufficient usable footage rather than padding or claiming it met the requested duration. Let the selected story and camera motion determine cuts and holds.

## Hook (first 2 seconds)
- The first frame must already be interesting: the finished result, a before/after contrast, or a close-up of the work. Never a logo, a title card, or a wide empty yard.
- Put a short Chinese hook line on it (4-12 characters). Examples of shape, not copy: a question ("这块地值得翻新吗？"), a result ("三天，后院大变样"). Write it as DRAFT; the client rewrites it.
- No claim in the hook that the profile cannot source (no "最好", "第一", licence, price).

## Video requirements and the hand-off to /hyperframes
Use provisional defaults and ask a small group of unresolved choices with recommendations: length, opening, pace, captions, brand tag, and music route. Refine them through the first storyboard and preview rather than completing a long creative interview first. Store this job's explicit requirements in `video-brief.json`; update profile defaults only when the client confirms they should apply to future videos. If BGM is wanted, offer the free catalog and finish `SETUP.md` B6a before the requested music preview. A track the client provides, in-app music, and none remain valid choices. Generated music uses a separate chosen route, not an automatic fallback.

Then hand the edit to **/hyperframes** (it must be installed: `check-hyperframes.sh`; if not, show the client the install command and stop). Give it:
- the brief file path and the job folder; the original source clips and selected `STORYLINES.md`, `SPEC.md`, storyboard, and optional `rough.mp4`;
- frame 1080x1920, 9:16, h264, the client-requested duration (3–60 s); output `<job>/final.mp4` and a still `<job>/cover.png`;
- safe zones: x 60-940, y 130-1440 (top 130 px, bottom 480 px and right 140 px are covered by the XHS interface). Hook in the upper safe zone, captions just above the bottom 480 px band, optional place label top-left inside the zone. Never over a face. Max 2 lines, 14 characters per line, font size 64 px or more;
- a Chinese-capable font (the profile's `brand.style.font_family` if set; else Noto Sans SC or PingFang SC), brand colours from `brand.style`;
- "put a red DRAFT stamp on every preview; none on the final";
- the real footage only rule: no generated scenes, people, yards or results.
The client can open the HyperFrames project and change the video themselves. After the client's rewrite and yes: set `approved: true`, render the final, then `bash "$SKILL_DIR/scripts/final-check.sh" JOB`.

## Cover frame
`cover-raw.png` is the middle of the hook (or the photo you gave with `--cover-still`). The cover must reflect the selected story (a result/contrast only when supported), big text on the lower third, no face covered. XHS shows covers in a grid: one idea, 4-12 characters. If the frame is poor, pick another second: `ffmpeg -ss <t> -i clip -frames:v 1 -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" cover-raw.png`.

## QA before showing the client
1. `ffprobe final.mp4`: 1080x1920, h264, the approved duration (3–60 s).
2. Look at 3 frames (start, middle, end) and the cover. Chinese characters are real characters (no empty boxes), nothing outside the safe zones, no text over a face, no other platform's mark, nothing AI-generated.
3. Size under 100 MB (XHS limit as noted in the source skill). `final-check.sh` runs `shrink-to-limit.sh`, which re-encodes at a computed bitrate when the file is over `XHS_MAX_MB` (default 95).
4. Footage permission recorded for this job.

## Not in scope
Generated scenes, AI-made yards or turf, avatars, voice-overs, stock footage. If the footage is too thin, ask the client for more clips.
