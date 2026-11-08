# xhs-studio first run (SETUP)

Run this when `profile.json` is missing or any of `interview_complete`, `system_prep_complete`, `dry_run_complete` is false. Three stages, in order. Never skip a stage. Tell the client in one line which stage you are in.

`SKILL_DIR` = the folder holding SKILL.md. `XHS_HOME` = the storage folder the client chooses in stage A0 (no fixed folder). `workspace.sh set` saves it; every script reads it from there.

Rules for the whole setup: sign-in, 2FA codes and captchas are always the client's. Never ask for or type a password. Never open any other site than the ones named here. Stop on any XHS warning.

---
## Stage A0. Where everything is stored (ask this first)
Ask ONE question: **"Where should I keep everything for your Xiaohongshu work (your profile, logs, jobs and footage)? Best: the folder of a ChatGPT project, so the chat and the files live together. Or pick any folder."** Recommended answer first: a ChatGPT project folder (steps below). Any folder the client picks is fine.
1. Get the folder path from the client (they can drag the folder into the chat). Then: `bash "$SKILL_DIR/scripts/workspace.sh" set "<FOLDER>"`. This creates `<FOLDER>/xhs-studio/` (jobs, log, state, footage-in) and saves the path. Check: `bash "$SKILL_DIR/scripts/workspace.sh" status`.
2. Do NOT put the workspace on a folder that syncs half-finished files if the client does not want that; tell them everything stays on their computer.
3. **Guide the client to set up a ChatGPT project (Work mode)**, in their language. Say it in Chinese AND English, and say once that button names can differ by app version; if a step is not there, skip it and pick any folder.

   English:
   1. In the ChatGPT app, create a new **Project** and choose **Work** mode.
   2. Under **Source folders**, add the folder that holds your editing material (your raw phone videos and photos).
   3. Open this chat's menu and **move this conversation into the project**, so the chat and its files stay together.
   4. Tell me the project folder path (or drag the folder here). I will store everything in a subfolder called `xhs-studio`.

   中文：
   1. 在 ChatGPT 应用里新建一个**项目**（Project），选择**工作**（Work）模式。
   2. 在**来源文件夹**（Source folders）里，添加放剪辑素材的文件夹（手机拍的原始视频和照片）。
   3. 打开这个对话的菜单，把**这个对话移入该项目**，这样对话和文件就放在一起。
   4. 把项目文件夹的路径告诉我（或把文件夹拖到这里）。我会在里面建一个叫 `xhs-studio` 的子文件夹，存放所有内容。
4. Done when `workspace.sh status` prints the folder and "folder exists", and the client has seen where it is.

---
## Stage A. Interview
1. The workspace exists (stage A0). The profile goes to `$XHS_HOME/profile.json` (get the path: `bash "$SKILL_DIR/scripts/workspace.sh" get`).
2. Copy `brand/profile.template.json` (blank) only if `$XHS_HOME/profile.json` does not exist; preserve answers when resuming.
3. Read supplied business websites/documents first, prepare a sourced draft profile, and use the grouped flow in `references/interview.md`. Defer optional material and creative details to the first video instead of blocking the interview on them.
4. `python3 "$SKILL_DIR/scripts/profile-check.py" "$XHS_HOME/profile.json"` must print `profile OK`.
Done when: `status.interview_complete` is true and the client said yes to the read-back.

---
## Stage B. System preparation
Goal: required dependencies checked, including the selected music route. Explain needed installs and proceed within the client’s existing authorization; ask only when an install is not already authorized. Sign-in is always completed by the client.

1. **Check what exists:** `bash "$SKILL_DIR/scripts/doctor.sh"`. Fix every `MISSING` line below, in this order, then run doctor again until it ends with "all required parts present".
2. **Node.js 22 or newer, and npm.** HyperFrames needs it. Install from https://nodejs.org (macOS with Homebrew: `brew install node@22`). Check: `node -v` shows 22 or higher.
3. **ffmpeg + ffprobe** (cuts the raw phone video). macOS: `brew install ffmpeg`. Windows: `winget install Gyan.FFmpeg`. Linux: `sudo apt install ffmpeg`. Check: `ffmpeg -version`, `ffprobe -version`.
4. **A Chinese font.** macOS already has PingFang. On Windows/Linux install Noto Sans SC (https://fonts.google.com/noto/specimen/Noto+Sans+SC). Check: doctor shows a font line.
5. **bsk (BrowserSkill CLI)** and its **Chrome extension** (the browser route is required):
   - Install the CLI. macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.sh | sh` then `export PATH="$HOME/.local/bin:$PATH"`. Windows PowerShell: `irm https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.ps1 | iex`. Check: `bsk --version`.
   - Install the extension in the Chrome that holds the XHS login: https://chromewebstore.google.com/detail/hhcmgoofomhgciiibhipgmgkgnoenaoi (Edge: the Edge Add-ons store). The client clicks "Add to Chrome" themselves. Then open the extension's popup and turn on the local connection.
   - Install the bsk skill into Codex: `bsk install-skill --harness Codex -y` (the supported path; REQUIRED: `doctor.sh` reports it MISSING until done. Test runs on a machine whose real Codex folder must stay untouched may set `XHS_SKIP_BSK_SKILL=1` for the doctor).
   - Check: `bsk doctor`. Every line must be `ok` (a `FAIL extension connected` line means Chrome is closed or the extension is off).
   - Optional but helpful: in `chrome://extensions` > BrowserSkill > Details, turn on "Allow access to file URLs". It may let `bsk upload` work. If it does not, `references/publish-route.md` has the local-server upload route.
6. **HyperFrames (video editing).** This skill does not edit video itself: it asks the client for the video requirements and hands the edit to the separately installed **/hyperframes** skill (open source, Apache 2.0, no per-render fee; `LICENSES.md`).
   - Check: `bash "$SKILL_DIR/scripts/check-hyperframes.sh"`. It checks the hyperframes skill, Node 22+ and ffmpeg.
   - If the skill is MISSING, proceed within existing setup authorization (otherwise ask before installing), then run `npx hyperframes skills update` (installs the core skills: hyperframes, hyperframes-cli, hyperframes-registry, media-use). Alternative: `npx skills add heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill media-use`. The first run downloads from the internet. Then **restart Codex** so it sees the new skill, and run the check again.
   - HyperFrames sends anonymous usage telemetry by default. Tell the client; they can switch it off with the environment variable `HYPERFRAMES_NO_TELEMETRY=1` (or `DO_NOT_TRACK=1`). Record their choice in the log.
   - Read `LICENSES.md` with the client now (short: no fee, no headcount limit) and note it in the log.
6a. **Music route, before the first music preview.** Offer the free catalog when the client requests BGM, alongside their own licensed track, in-app music, or none. Store `final_cut.music_source` (`catalog`, `provided`, `in_app`, `generate`, or `none`). For `catalog`:
   - Run `bash "$SKILL_DIR/scripts/check-music.sh"`. It checks the HeyGen helper and the last verified catalog-readiness record; this is separate from the HyperFrames installation check.
   - If the helper is missing or incompatible, use the official instructions at https://developers.heygen.com/cli within authorized setup scope. Check `heygen --version` against the installed media-use skill's supported version (currently 0.3.0+).
   - Run `npx hyperframes auth status`. If signed out, explain that free catalog access needs sign-in and ask the client to complete `npx hyperframes auth login` (or `! npx hyperframes auth login` in a host that supports it). Wait for completion, then recheck. Do not request credentials or record tokens.
   - Read the installed media-use skill. List existing BGM candidates before retrieval; if none fits, retrieve a suitable free catalog track into the test job with `npx hyperframes media-use resolve --type bgm --intent "<mood and tempo>" --project "<job>"`. Record provenance and set `system.music_catalog_ready: true` only after successful retrieval. This records the last check, not permanent authentication; recheck auth before subsequent catalog use.
   - If access fails, report the exact blocker and let the client choose whether to continue without catalog music. Keep readiness false; do not silently use paid generation. Provided tracks, in-app music and silence need no HeyGen account; generated music follows media-use’s separate account and credit requirements. Honor the recorded telemetry choice on every HyperFrames command.
7. **Confirm the XHS sign-in.**
   - `sid=$(bash "$SKILL_DIR/scripts/bsk-start.sh" "setup signin check" --show)` (prints a session id; type that literal id in later commands).
   - Snapshot first: `bsk snapshot --session <id>`.
   - `bsk navigate --session <id> "https://creator.xiaohongshu.com/"` then `bash "$SKILL_DIR/scripts/bsk-check-page.sh" <id>` on its own line.
   - Exit 3 (sign-in wall): ask the client to sign in in the Agent Window (`bsk request-help --session <id> --prompt "Please sign in to Xiaohongshu creator center, then click Done"`), then check again. Never type their credentials.
   - Exit 4 (XHS warning): stop, tell the client, do not retry.
   - Exit 0: signed in.
   - ALWAYS end with `bash "$SKILL_DIR/scripts/bsk-stop.sh" <id>`.
8. Final check: `bash "$SKILL_DIR/scripts/doctor.sh"` ends with "all required parts present". Set `status.system_prep_complete` true.

If `bsk doctor` cannot be made to pass after one honest attempt, do not loop: tell the client, set the manual route (`references/manual-fallback.md`) for now, and report the exact failure to BridgePilot.

---
## Stage C. Dry run (nothing is published)
Goal: prove the whole chain once, ending at "all filled, button untouched".
1. Ask the client for ONE real job folder (clips + stills), the customer-permission yes, and **which clip shows the finished result**. A zip: unpack with `python3 "$SKILL_DIR/scripts/unpack-footage.py" FILE.zip FOLDER` and do not go on until it says "all files present and complete". If they have no footage yet, run the cutdown on any short clip only to test the tools, and say it is a test.
2. Inspect the available footage and privacy concerns; begin the applicable HyperFrames storyline process before editing. Present three distinct storylines with a recommendation, let the client choose, then prepare `STORYLINES.md`, `SPEC.md`, and the storyboard with source intervals, output timing, draft captions, framing, and sound. A test with preparation footage may use an explicitly selected preparation story; it cannot masquerade as a finished result.
3. Refine the small group of unresolved video choices against that plan (`references/footage-cutdown.md`), record job-specific requirements in `video-brief.json`, and hand the sources and planning files to HyperFrames. Use the client's requested length throughout. Include requested catalog music once access is verified, show the DRAFT preview, collect revisions, and update reusable profile defaults separately from one-job exceptions. After exact words and edit approval, set `approved: true`, render `final.mp4`, and run `final-check.sh`.

4. Draft `caption.md` (DRAFT), run `lint-copy.py`, take the client's rewrite.
5. Publish form: follow `references/publish-route.md` steps 1 to 8 with the final video (or the cover and stills for an image note) and the approved caption. Stop at "all filled, button untouched". Take a screenshot of the form. Do NOT click 发布 in the dry run, even if `auto_publish` is on.
6. Stop the session (`bsk-stop.sh`). Check `bsk session list` is empty.
7. Write the log entry (what worked, what failed, selectors that changed) and tell the client the result in 3 lines.
8. Set `status.dry_run_complete` true only after the client has seen the filled form and said it looks right.

Setup is done. From now on `SKILL.md` "Step 0" applies.
