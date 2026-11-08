#!/usr/bin/env python3
"""xhs-studio cutdown: raw phone footage -> requested-length 9:16 rough cut (3-60 s).

Needs only python3 (stdlib) + ffmpeg + ffprobe. No network. No AI model.

BEFORE YOU RUN IT, know which clip shows the FINISHED RESULT (--result). Ask the client.
The cut is built around it: it opens with a moment from the result (or from --hook), and
the closing part comes ONLY from the result clip(s). Without --result the script guesses
"the last clip" and prints a loud warning.

What it does
  1. Scores every second of every clip (sharpness, motion, exposure) with ffmpeg.
     It CANNOT see people, faces, house numbers or utility meters (no detector is built in;
     a skin-tone test was tried and rejected: soil and wood trigger it). A human looks at
     the contact sheet; use --avoid to skip a stretch you already know about.
  2. Builds: HOOK (2 s) -> BEFORE -> DURING (sped up) -> AFTER (result clip only).
  3. Writes cut-plan.json (hand-editable), plan-review.md (table), plan-review.jpg
     (contact sheet, one tile per segment, exactly as cropped), rough.mp4, cover-raw.png,
     video-brief.json (the client requirements and Chinese text, handed to /hyperframes).
  Review the sheet BEFORE showing the client. Drop, crop (pan/zoom) or reorder in
  cut-plan.json, then:  cutdown.py --render-plan JOB/cut-plan.json

Usage
  cutdown.py CLIP_OR_FOLDER ... --out JOBDIR --result RESULT_CLIP [--hook CLIP]
             [--before CLIP] [--avoid "CLIP@10-16"] [--still before:IMG.jpg]
             [--cover-still IMG.jpg] [--target 20] [--fit crop|blur] [--audio mute|keep]
             [--speed 3] [--hook-sec 2] [--seg-sec 2] [--plan-only]
  cutdown.py --render-plan JOBDIR/cut-plan.json
  cutdown.py --list JOBDIR/cut-plan.json
Clip names can be a file name only (IMG_2597.MOV); a folder expands to its video files.
"""
import argparse, json, os, re, shutil, subprocess, sys

W, H, FPS = 1080, 1920, 30
SAMPLE_FPS = 2  # analysis samples per second
VIDEO_EXT = (".mov", ".mp4", ".m4v", ".avi", ".mkv", ".webm")


def run(cmd):
    r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if r.returncode != 0:
        raise RuntimeError("command failed: %s\n%s" % (" ".join(cmd), r.stderr[-1500:]))
    return r


def probe(path):
    r = run(["ffprobe", "-v", "error", "-show_entries", "format=duration:stream=codec_type",
             "-of", "json", path])
    d = json.loads(r.stdout)
    dur = float(d["format"].get("duration", 0))
    has_audio = any(s.get("codec_type") == "audio" for s in d.get("streams", []))
    return dur, has_audio


def stat_series(path, chain, key="lavfi.signalstats.YAVG"):
    vf = "fps=%d,scale=160:-2,%ssignalstats,metadata=print:key=%s:file=-" % (SAMPLE_FPS, chain, key)
    r = subprocess.run(["ffmpeg", "-v", "error", "-nostdin", "-i", path, "-an", "-vf", vf, "-f", "null", "-"],
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if r.returncode != 0:
        raise RuntimeError("analysis failed for %s: %s" % (path, r.stderr[-800:]))
    return [float(m.group(1)) for m in re.finditer(re.escape(key) + r"=([0-9.]+)", r.stdout)]


def analyse(path, dur):
    bright = stat_series(path, "format=gray,")
    motion = stat_series(path, "format=gray,tblend=all_mode=difference,")
    sharp = stat_series(path, "format=gray,edgedetect=low=0.1:high=0.3,")
    n = min(len(bright), len(motion), len(sharp))
    seconds = []
    for s in range(int(dur)):
        i0, i1 = s * SAMPLE_FPS, min((s + 1) * SAMPLE_FPS, n)
        if i0 >= n:
            break
        avg = lambda a: sum(a[i0:i1]) / max(1, len(a[i0:i1]))
        seconds.append({"t": s, "bright": avg(bright), "motion": avg(motion), "sharp": avg(sharp),
                        "excluded": False})
    return seconds


def normalise(vals):
    if not vals:
        return []
    lo, hi = min(vals), max(vals)
    return [0.5 if hi - lo < 1e-9 else (v - lo) / (hi - lo) for v in vals]


def score_seconds(all_secs):
    sharp_n = normalise([s["sharp"] for s in all_secs])
    mot = [s["motion"] for s in all_secs]
    mot_n = normalise(mot)
    srt = sorted(mot)
    p90 = srt[int(len(srt) * 0.9)] if srt else 0
    for s, a, m in zip(all_secs, sharp_n, mot_n):
        sc = 0.55 * a + 0.45 * m
        if s["bright"] < 35 or s["bright"] > 225:
            sc *= 0.3  # too dark / blown out
        if s["motion"] > p90 * 1.4 and p90 > 0:
            sc *= 0.7  # likely shaky / camera swing
        if s["excluded"]:
            sc = 0.0
        s["score"] = sc


def best_windows(secs, length):
    """Non-overlapping windows of `length` whole seconds of ONE clip, best first."""
    L = max(1, int(round(length)))
    cands = []
    for i in range(0, len(secs) - L + 1):
        win = secs[i:i + L]
        if any(x["excluded"] for x in win):
            continue
        sc = sum(x["score"] for x in win) / L
        cands.append((sc, i))
    cands.sort(reverse=True)
    chosen, used = [], set()
    for sc, i in cands:
        if any((i + k) in used for k in range(L)):
            continue
        chosen.append((sc, i))
        used.update(range(i, i + L))
    return chosen


def expand_inputs(items):
    out = []
    for it in items:
        if os.path.isdir(it):
            for f in sorted(os.listdir(it)):
                if f.lower().endswith(VIDEO_EXT) and not f.startswith("."):
                    out.append(os.path.abspath(os.path.join(it, f)))
        elif os.path.isfile(it):
            out.append(os.path.abspath(it))
        else:
            sys.exit("not a file or folder: %s" % it)
    seen, uniq = set(), []
    for p in out:
        if p not in seen:
            seen.add(p)
            uniq.append(p)
    return uniq


def resolve(name, paths, what):
    """Match a clip name (full path, or file name) against the input paths."""
    ab = os.path.abspath(name)
    if ab in paths:
        return ab
    hits = [p for p in paths if os.path.basename(p) == os.path.basename(name)]
    if len(hits) == 1:
        return hits[0]
    sys.exit("%s '%s' is not one of the input clips (or the name is ambiguous). Inputs: %s"
             % (what, name, ", ".join(os.path.basename(p) for p in paths)))


def build_plan(clips, args, result_paths, hook_paths, before_paths):
    L = args.seg_sec
    speed = args.speed
    warnings = []
    by_path = {c["path"]: c for c in clips}
    order = [c["path"] for c in clips]
    if not result_paths:
        last = order[-1]
        result_paths = [last]
        warnings.append("NO --result CLIP NAMED: assumed the LAST clip (%s) shows the finished result. "
                        "Ask the client which clip shows the finished result and re-run with --result."
                        % os.path.basename(last))
    rset, kset, bset = set(result_paths), set(hook_paths), set(before_paths)

    def windows_of(path, length=L):
        c = by_path[path]
        return [{"file": path, "start": float(i), "src_dur": float(length), "score": round(sc, 3),
                 "has_audio": c["audio"], "clipdur": c["dur"]}
                for sc, i in best_windows(c["secs"], length)]

    def pool_of(paths):
        out = []
        for p in paths:
            out += windows_of(p)
        return sorted(out, key=lambda w: -w["score"])

    def overlaps(w, ws):
        return any(x["file"] == w["file"] and x["start"] < w["start"] + w["src_dur"] and w["start"] < x["start"] + x["src_dur"] for x in ws)

    target = args.target
    hook = args.hook_sec
    body = target - hook
    n_before = max(1, round(body * 0.30 / L))
    n_during = max(1, round(body * 0.40 / L))
    n_after = max(1, round(body * 0.30 / L))

    used = []
    # HOOK
    hook_pool = pool_of(hook_paths) if hook_paths else pool_of(result_paths)
    if not hook_pool:
        hook_pool = pool_of(order)
    if not hook_pool:
        raise SystemExit("not enough usable footage (no clip has a free window)")
    hw = dict(hook_pool[0], role="hook", src_dur=float(hook), speed=1.0)
    used.append(hw)

    # AFTER: result clip(s) only. One CONTINUOUS stretch per result clip reads better than
    # several short cuts of the same static view. At least one segment is guaranteed.
    after = []
    want = n_after * L
    for rp in result_paths:
        stretch = want if len(result_paths) == 1 else max(L, want // len(result_paths))
        stretch = min(stretch, int(by_path[rp]["dur"]) - 1)
        got = None
        while stretch >= L and got is None:
            for w in windows_of(rp, stretch):
                if not overlaps(w, used):
                    got = w
                    break
            if got is None:
                stretch -= 1
        if got is None and windows_of(rp, L):
            got = windows_of(rp, L)[0]
            warnings.append("result clip is short: the AFTER part reuses the hook moment")
        if got is not None:
            after.append(dict(got, role="after", speed=1.0))
    used += after

    # BEFORE / DURING from the other clips
    others = [p for p in order if p not in rset and p not in kset]
    if bset:
        bpool = pool_of([p for p in order if p in bset])
        opool = pool_of([p for p in others if p not in bset])
    else:
        total = sum(by_path[p]["dur"] for p in others) or 1.0
        pos, bpool, opool = 0.0, [], []
        for p in others:
            for w in windows_of(p):
                frac = (pos + w["start"] + L / 2.0) / total
                (bpool if frac < 0.4 else opool).append(w)
            pos += by_path[p]["dur"]
        bpool.sort(key=lambda w: -w["score"])
        opool.sort(key=lambda w: -w["score"])
    if not others:
        warnings.append("no clips besides the result/hook clips: BEFORE and DURING come from the result clip")
        pool = [w for w in pool_of(result_paths) if not overlaps(w, used)]
        bpool, opool = pool[: len(pool) // 2], pool[len(pool) // 2:]

    def blocked(w):
        """True if any second of the full source range was excluded with --avoid."""
        secs = by_path[w["file"]]["secs"]
        a, b = w["start"], w["start"] + w["src_dur"]
        return any(x["excluded"] and x["t"] + 1 > a and x["t"] < b for x in secs)

    def take(pool_, n, role, spd):
        picked = []
        for w in pool_:
            if len(picked) >= n:
                break
            cand = dict(w, role=role, speed=spd, src_dur=w["src_dur"] * spd)
            if cand["start"] + cand["src_dur"] > w["clipdur"] + 0.01:
                cand["start"] = max(0.0, w["clipdur"] - cand["src_dur"])
            if overlaps(cand, used + picked) or blocked(cand):
                continue
            picked.append(cand)
        if len(picked) < n:
            warnings.append("only %d of %d wanted '%s' moments found" % (len(picked), n, role))
        return picked

    before = take(bpool, n_before, "before", 1.0)
    used += before
    during = take(opool, n_during, "during", speed)
    used += during
    key = lambda w: (order.index(w["file"]) if w["file"] in order else 0, w["start"])
    seq = [hw] + sorted(before, key=key) + sorted(during, key=key) + sorted(after, key=key)

    # stills (real photos only)
    stills = []
    for spec in args.still or []:
        role, _, f = spec.partition(":")
        if role not in ("before", "after") or not f or not os.path.isfile(f):
            sys.exit("--still needs ROLE:FILE with ROLE before|after and an existing image (convert HEIC first: scripts/prep-stills.sh)")
        stills.append((role, os.path.abspath(f)))
    segs, t = [], 0.0

    def add(w, still=False):
        nonlocal t
        out_dur = 2.0 if still else w["src_dur"] / w["speed"]
        segs.append({"role": w["role"], "file": w["file"], "still": still,
                     "start": 0.0 if still else round(w["start"], 2),
                     "src_dur": out_dur if still else round(w["src_dur"], 2),
                     "speed": 1.0 if still else w["speed"], "out_start": round(t, 2), "out_dur": round(out_dur, 2),
                     "score": w.get("score", 0), "has_audio": False if still else w.get("has_audio", False),
                     "pan": 0.5, "zoom": 1.0, "note": ""})
        t += out_dur

    for w in seq:
        if w["role"] == "before" and not any(s["role"] == "before" for s in segs):
            for role, f in stills:
                if role == "before":
                    add({"role": "before", "file": f}, still=True)
        add(w)
    for role, f in stills:
        if role == "after":
            add({"role": "after", "file": f}, still=True)
    while t > target and len(segs) > 3:
        drop = next((i for i in range(len(segs) - 1, -1, -1) if segs[i]["role"] == "during"), None)
        if drop is None:
            break
        t -= segs[drop]["out_dur"]
        segs.pop(drop)
    t = 0.0
    for s in segs:  # renumber the timeline
        s["out_start"] = round(t, 2)
        t += s["out_dur"]
    if t < target - 0.1:
        warnings.append("cut is %.1f s, below the requested %.1f s: review usable footage; do not pad it" % (t, target))
    if t > target + 0.1:
        warnings.append("cut is %.1f s, above the requested %.1f s: trim the plan or edit original clips" % (t, target))
    warnings.append("PRIVACY CHECK REQUIRED: the script cannot see people, faces, house numbers, plates or utility meters. "
                    "Open plan-review.jpg and look at every tile (also the edges); drop, pan or zoom as needed.")
    return {"version": 2, "target_sec": target, "total_sec": round(t, 2), "fit": args.fit, "audio": args.audio,
            "result_clips": [os.path.basename(p) for p in result_paths], "segments": segs, "warnings": warnings}


def vf_for(fit, pan=0.5, zoom=1.0):
    if fit == "blur":
        return ("split[a][b];[a]scale=%d:%d:force_original_aspect_ratio=increase,crop=%d:%d,boxblur=30:5[bg];"
                "[b]scale=%d:%d:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2"
                % (W, H, W, H, W, H))
    pan = min(1.0, max(0.0, float(pan)))
    zoom = max(1.0, float(zoom))
    return ("scale=%d:%d:force_original_aspect_ratio=increase,scale=trunc(iw*%.3f/2)*2:trunc(ih*%.3f/2)*2,"
            "crop=%d:%d:(iw-%d)*%.3f:(ih-%d)/2" % (W, H, zoom, zoom, W, H, W, pan, H))


def seg_input(s):
    if s.get("still"):
        return ["-loop", "1", "-framerate", str(FPS), "-t", str(s["out_dur"]), "-i", s["file"]]
    return ["-ss", str(s["start"]), "-t", str(s["src_dur"]), "-i", s["file"]]


def write_review(plan, outdir):
    """plan-review.md (table) and plan-review.jpg (contact sheet, one tile per segment, cropped as rendered)."""
    rows = ["| # | role | clip | from s | src s | speed | out s | pan | zoom | note |", "|---|---|---|---|---|---|---|---|---|---|"]
    for i, s in enumerate(plan["segments"]):
        rows.append("| %d | %s | %s%s | %.1f | %.1f | %sx | %.1f | %s | %s | %s |" % (
            i, s["role"], os.path.basename(s["file"]), " (still)" if s.get("still") else "", s["start"], s["src_dur"],
            s["speed"], s["out_dur"], s.get("pan", 0.5), s.get("zoom", 1.0), s.get("note", "")))
    md = ["# Plan review", "",
          "Total %.1f s. Result clip(s): %s." % (plan["total_sec"], ", ".join(plan.get("result_clips", [])) or "none named"), "",
          "Open `plan-review.jpg`: tile order is row by row, 4 per row, tile 0 = row 1 left = segment #0.",
          "There is NO automatic person, face or object detection. You are the check.",
          "Look at every tile. Check: any person (also at the edge), any face, house number, street sign, plate,",
          "utility meter or panel, a neighbour's yard. Then edit `cut-plan.json` (delete the segment, change `start`, set `pan` 0-1",
          "to slide the crop left/right on landscape clips, `zoom` 1.0-2.0 to crop in) and run `cutdown.py --render-plan`.", ""] + rows
    if plan.get("warnings"):
        md += ["", "## Warnings"] + ["- " + w for w in plan["warnings"]]
    open(os.path.join(outdir, "plan-review.md"), "w", encoding="utf-8").write("\n".join(md) + "\n")
    fdir = os.path.join(outdir, "_review")
    os.makedirs(fdir, exist_ok=True)
    n = 0
    for i, s in enumerate(plan["segments"]):
        f = os.path.join(fdir, "t%02d.jpg" % i)
        vf = vf_for(plan["fit"], s.get("pan", 0.5), s.get("zoom", 1.0)) + ",scale=270:480"
        t = 0 if s.get("still") else s["start"] + s["src_dur"] / 2.0
        cmd = ["ffmpeg", "-v", "error", "-nostdin", "-y"] + (["-i", s["file"]] if s.get("still") else ["-ss", str(t), "-i", s["file"]])
        cmd += ["-frames:v", "1", "-vf", vf, "-q:v", "3", f]
        try:
            run(cmd)
            n += 1
        except RuntimeError:
            return
    cols = 4
    rows_n = (n + cols - 1) // cols
    try:
        run(["ffmpeg", "-v", "error", "-nostdin", "-y", "-start_number", "0", "-i", os.path.join(fdir, "t%02d.jpg"),
             "-vf", "tile=%dx%d:padding=6:color=black" % (cols, rows_n), "-frames:v", "1", "-q:v", "3",
             os.path.join(outdir, "plan-review.jpg")])
    except RuntimeError:
        pass
    shutil.rmtree(fdir, ignore_errors=True)


def render_plan(plan, outdir, cover_still=None):
    segdir = os.path.join(outdir, "_segs")
    os.makedirs(segdir, exist_ok=True)
    listfile = os.path.join(segdir, "list.txt")
    keep = plan.get("audio") == "keep"
    lines = []
    for i, s in enumerate(plan["segments"]):
        seg = os.path.join(segdir, "seg%02d.mp4" % i)
        speed = s["speed"]
        crop = vf_for(plan["fit"], s.get("pan", 0.5), s.get("zoom", 1.0))
        vf = "%s,%s,fps=%d,format=yuv420p" % ("setpts=PTS/%s" % speed if not s.get("still") else "null", crop, FPS)
        cmd = ["ffmpeg", "-v", "error", "-nostdin", "-y"] + seg_input(s)
        use_src_audio = keep and s.get("has_audio") and speed == 1.0 and not s.get("still")
        if not use_src_audio:
            cmd += ["-f", "lavfi", "-t", str(s["out_dur"]), "-i", "anullsrc=r=48000:cl=stereo"]
        cmd += ["-filter_complex", "[0:v]%s[v]" % vf, "-map", "[v]"]
        if use_src_audio:
            cmd += ["-map", "0:a:0", "-af", "aresample=48000,volume=0.6"]
        else:
            cmd += ["-map", "1:a:0"]
        cmd += ["-t", str(s["out_dur"]), "-c:v", "libx264", "-preset", "veryfast", "-crf", "20",
                "-c:a", "aac", "-ar", "48000", "-ac", "2", "-movflags", "+faststart", seg]
        run(cmd)
        lines.append("file '%s'" % seg.replace("'", "'\\''"))
    with open(listfile, "w") as f:
        f.write("\n".join(lines) + "\n")
    rough = os.path.join(outdir, "rough.mp4")
    run(["ffmpeg", "-v", "error", "-nostdin", "-y", "-f", "concat", "-safe", "0", "-i", listfile,
         "-c", "copy", "-movflags", "+faststart", rough])
    if plan.get("audio") != "keep":
        tmp = rough + ".tmp.mp4"
        run(["ffmpeg", "-v", "error", "-nostdin", "-y", "-i", rough, "-an", "-c:v", "copy", tmp])
        os.replace(tmp, rough)
    cover = os.path.join(outdir, "cover-raw.png")
    h = plan["segments"][0]
    if cover_still:
        run(["ffmpeg", "-v", "error", "-nostdin", "-y", "-i", cover_still, "-frames:v", "1",
             "-vf", vf_for(plan["fit"]), cover])
    else:
        run(["ffmpeg", "-v", "error", "-nostdin", "-y"] + (["-i", h["file"]] if h.get("still") else ["-ss", str(h["start"] + h["src_dur"] / 2), "-i", h["file"]])
            + ["-frames:v", "1", "-vf", vf_for(plan["fit"], h.get("pan", 0.5), h.get("zoom", 1.0)), cover])
    shutil.rmtree(segdir, ignore_errors=True)
    brief = os.path.join(outdir, "video-brief.json")
    if not os.path.exists(brief):
        skeleton = {
            "approved": False,
            "_note": "The client's video requirements, handed to the separately installed /hyperframes skill. Fill every field WITH the client. All Chinese is DRAFT until the client approves; then set approved to true. final-check.sh refuses a final while approved is false.",
            "source_video": "rough.mp4",
            "source_duration_sec": plan["total_sec"],
            "cover_raw": "cover-raw.png",
            "frame": {"width": 1080, "height": 1920, "safe_zone": "x 60-940, y 130-1440 (top 130, bottom 480, right 140 are covered by the XHS interface)"},
            "requirements": {
                "length_sec": plan["target_sec"],
                "style": "",
                "music": "pending client choice",
                "music_source": "none",
                "clips_to_use": [],
                "clips_to_avoid": [],
            },
            "on_screen_text": {
                "hook": {"text": "", "fromSec": 0, "toSec": 2.4},
                "captions": [],
                "lowerLabel": "",
                "watermark": "",
            },
            "cover": {"title": "", "subtitle": ""},
            "brand_style": {"accent_colour": "", "text_colour": "", "font_family": ""},
            "output": "final.mp4",
        }
        with open(brief, "w", encoding="utf-8") as f:
            json.dump(skeleton, f, ensure_ascii=False, indent=2)
    return rough, cover


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("inputs", nargs="*")
    ap.add_argument("--out")
    ap.add_argument("--result", action="append", default=[], help="clip that shows the FINISHED result (repeatable). Ask the client.")
    ap.add_argument("--hook", action="append", default=[], help="clip to take the first 2 s from (optional)")
    ap.add_argument("--before", action="append", default=[], help="clip that shows the before state (optional)")
    ap.add_argument("--avoid", action="append", default=[], help='skip a stretch, e.g. "IMG_2597.MOV@10-16" (seconds)')
    ap.add_argument("--still", action="append", default=[], help="ROLE:IMAGE (before|after), a real photo already converted to jpg/png")
    ap.add_argument("--cover-still", help="use this photo (jpg/png) as the cover background")
    ap.add_argument("--target", type=float, default=20.0, help="target length in seconds (3-60; approximate rough plan)")
    ap.add_argument("--fit", choices=["crop", "blur"], default="crop",
                    help="crop = fill 9:16 (landscape clips lose their sides); blur = whole frame on blurred background")
    ap.add_argument("--audio", choices=["mute", "keep"], default="mute")
    ap.add_argument("--speed", type=float, default=3.0, help="speed-up of the 'during' part")
    ap.add_argument("--hook-sec", type=float, default=2.0)
    ap.add_argument("--seg-sec", type=int, default=2)
    ap.add_argument("--plan-only", action="store_true", help="analyse, write the plan and review sheet, do not render")
    ap.add_argument("--render-plan", help="re-render from an edited cut-plan.json")
    ap.add_argument("--list", help="print the review table of a cut-plan.json")
    args = ap.parse_args()
    if not 3 <= args.target <= 60:
        ap.error("--target must be 3 to 60 seconds; it is never silently clamped")

    if args.list:
        plan = json.load(open(args.list))
        write_review(plan, os.path.dirname(os.path.abspath(args.list)))
        print(open(os.path.join(os.path.dirname(os.path.abspath(args.list)), "plan-review.md"), encoding="utf-8").read())
        return
    for tool in ("ffmpeg", "ffprobe"):
        if not shutil.which(tool):
            sys.exit("%s not found. Run scripts/doctor.sh and follow the install hint." % tool)

    if args.render_plan:
        plan = json.load(open(args.render_plan))
        outdir = os.path.dirname(os.path.abspath(args.render_plan))
        rough, cover = render_plan(plan, outdir, os.path.abspath(args.cover_still) if args.cover_still else None)
        write_review(plan, outdir)
        print("rendered", rough, cover)
        print("review :", os.path.join(outdir, "plan-review.jpg"))
        return
    if not args.inputs or not args.out:
        ap.error("need input clips (or a folder) and --out JOBDIR")
    args.out = os.path.abspath(args.out)
    os.makedirs(args.out, exist_ok=True)
    paths = expand_inputs(args.inputs)
    result_paths = [resolve(n, paths, "--result") for n in args.result]
    hook_paths = [resolve(n, paths, "--hook") for n in args.hook]
    before_paths = [resolve(n, paths, "--before") for n in args.before]
    clips = []
    for p in paths:
        dur, aud = probe(p)
        if dur < args.seg_sec + 1:
            print("skip (too short): %s" % p)
            continue
        print("analysing %s (%.0f s) ..." % (os.path.basename(p), dur), flush=True)
        clips.append({"path": p, "dur": dur, "audio": aud, "secs": analyse(p, dur)})
    if not clips:
        sys.exit("no usable clips")
    keep = {c["path"] for c in clips}
    for lst, name in ((result_paths, "--result"), (hook_paths, "--hook"), (before_paths, "--before")):
        for p in lst:
            if p not in keep:
                sys.exit("%s clip %s is too short to use" % (name, os.path.basename(p)))
    for spec in args.avoid:
        m = re.match(r"^(.+)@(\d+(?:\.\d+)?)-(\d+(?:\.\d+)?)$", spec)
        if not m:
            sys.exit('--avoid needs "CLIP@START-END" in seconds, got: %s' % spec)
        p = resolve(m.group(1), paths, "--avoid")
        a, b = float(m.group(2)), float(m.group(3))
        for c in clips:
            if c["path"] == p:
                for s in c["secs"]:
                    if s["t"] + 1 > a and s["t"] < b:
                        s["excluded"] = True
    allsecs = [s for c in clips for s in c["secs"]]
    score_seconds(allsecs)
    plan = build_plan(clips, args, result_paths, hook_paths, before_paths)
    plan_path = os.path.join(args.out, "cut-plan.json")
    with open(plan_path, "w") as f:
        json.dump(plan, f, indent=2)
    write_review(plan, args.out)
    print("plan   :", plan_path)
    print("review :", os.path.join(args.out, "plan-review.jpg"), "+ plan-review.md  (LOOK AT IT before showing the client)")
    for w in plan["warnings"]:
        print("WARNING:", w)
    if args.plan_only:
        return
    rough, cover = render_plan(plan, args.out, os.path.abspath(args.cover_still) if args.cover_still else None)
    print("rough  :", rough, "(%.1f s)" % plan["total_sec"])
    print("cover  :", cover)


if __name__ == "__main__":
    main()
