# xhs-studio first run (SETUP)

Use this flow when the client requests setup, or consult only the module needed by the current action. It is not a mandatory ordered wizard. Begin useful planning, drafting or saved-file analysis with available evidence; gather remaining profile/preferences and prepare relevant tools as the work reaches them. Tell the client briefly what is ready, what is provisional and which actual next step needs input.

The status flags record completed milestones only. Missing/false flags do not send every request back through setup. Do not mark them complete without evidence, and do not treat a fully completed setup as content approval or sending authority.

`SKILL_DIR` = the folder holding SKILL.md. `XHS_HOME` = the storage folder the client chooses in stage A0 (no fixed folder). `workspace.sh set` saves it; every script reads it from there.

Rules for the whole setup: sign-in, 2FA codes and captchas are always the client's. Never ask for or type a password. Use only task-relevant, authorized sites and official dependency documentation. Stop on any XHS warning.

---
## Module A0. Workspace (when a durable destination is needed)
Reuse an already chosen accessible workspace. If none is known and files/client state need saving, ask one compact question: **"Which folder should hold your Xiaohongshu profile, footage, jobs and logs? I recommend one dedicated local folder that your current agent app can access."** Any client-chosen folder is fine; do not require a ChatGPT Project, Work mode or a particular subscription.
1. Get the folder path, then run `bash "$SKILL_DIR/scripts/workspace.sh" set "<FOLDER>"`. This creates `<FOLDER>/xhs-studio/` and saves its path. Verify `workspace.sh status`.
2. Identify the current host and verify authorized local file/command access. If it offers projects or attached folders, optionally guide the client using that app's actual available controls. Otherwise use the chosen folder directly. Do not invent Source folders, Work mode or equivalent controls in another app.
3. Explain where files live and whether the chosen folder syncs elsewhere; do not promise local-only storage for a synced folder. Reuse this workspace when changing agent apps; installation must not overwrite the profile.
4. Done when the workspace exists, the current agent can access it, and the client knows where it is.

---
## Module A. Sourced profile and progressive questions
1. For persistent profile updates choose the workspace (module A0). Supplied-file analysis or provisional planning need not wait for a full profile. The profile goes to `$XHS_HOME/profile.json` (get the path: `bash "$SKILL_DIR/scripts/workspace.sh" get`).
2. Copy `brand/profile.template.json` (blank) only if `$XHS_HOME/profile.json` does not exist; preserve answers when resuming.
3. Read supplied business websites/documents first, prepare a sourced draft profile, and use the grouped flow in `references/interview.md`. Defer optional material and creative details to the first video instead of blocking the interview on them.
4. Run `profile-check.py` when checking full profile completion. Report missing fields, ask only those relevant now, and defer others explicitly; an incomplete result does not block supported work in another flow.
Mark `status.interview_complete` true only after confirmed business essentials and the required read-back pass validation. Keep creative preferences provisional until reviewed; never invent values to obtain `profile OK`.

---
## Module B. Tools for the current action
Goal: check only the dependencies for the work being performed. Plan and saved-report analysis do not require Chrome, HyperFrames or music sign-in; inbox reads do not require video tooling. The list below is a reference, not an install-all prerequisite. Explain needed installs and proceed within the client’s existing authorization; ask only when an install is not already authorized. Sign-in is always completed by the client.

1. **Check what is relevant:** inspect the selected route. Run targeted checks for browser, editing or music only when needed. `doctor.sh` is an optional full-environment audit for broad setup; record unrelated MISSING items as deferred rather than blocking the current flow. Fix actual blockers within authorized scope and continue independent work.
2. **Node.js 22 or newer, and npm.** HyperFrames needs it. Install from https://nodejs.org (macOS with Homebrew: `brew install node@22`). Check: `node -v` shows 22 or higher.
3. **ffmpeg + ffprobe** (cuts the raw phone video). macOS: `brew install ffmpeg`. Windows: `winget install Gyan.FFmpeg`. Linux: `sudo apt install ffmpeg`. Check: `ffmpeg -version`, `ffprobe -version`.
4. **A Chinese font.** macOS already has PingFang. On Windows/Linux install Noto Sans SC (https://fonts.google.com/noto/specimen/Noto+Sans+SC). Check: doctor shows a font line.
5. **bsk (BrowserSkill CLI)** and its **Chrome extension** (the browser route is required):
   - Install the CLI. macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.sh | sh` then `export PATH="$HOME/.local/bin:$PATH"`. Windows PowerShell: `irm https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.ps1 | iex`. Check: `bsk --version`.
   - Install the extension in the Chrome that holds the XHS login: https://chromewebstore.google.com/detail/hhcmgoofomhgciiibhipgmgkgnoenaoi (Edge: the Edge Add-ons store). The client clicks "Add to Chrome" themselves. Then open the extension's popup and turn on the local connection.
   - Install/read the official browser-skill in the current host. Inspect `bsk install-skill --help` for supported harnesses; use the actual host option rather than assuming Codex. `bsk install-skill --harness Codex -y` is a Codex example only. For another host, follow its verified skill/tool loading mechanism; report unsupported local execution. Test-only doctor checks may set `XHS_SKIP_BSK_SKILL=1` when installation must stay untouched.
   - Check: `bsk doctor`. Every line must be `ok` (a `FAIL extension connected` line means Chrome is closed or the extension is off).
   - Optional but helpful: in `chrome://extensions` > BrowserSkill > Details, turn on "Allow access to file URLs". It may let `bsk upload` work. If it does not, `references/publish-route.md` has the local-server upload route.
6. **HyperFrames (video editing).** This skill does not edit video itself: it asks the client for the video requirements and hands the edit to the separately installed **/hyperframes** skill (open source, Apache 2.0, no per-render fee; `LICENSES.md`).
   - Check: `bash "$SKILL_DIR/scripts/check-hyperframes.sh"`. It checks the hyperframes skill, Node 22+ and ffmpeg.
   - If the skill is MISSING, proceed within existing setup authorization (otherwise ask before installing), then run `npx hyperframes skills update` (installs the core skills: hyperframes, hyperframes-cli, hyperframes-registry, media-use). Alternative: `npx skills add heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill media-use`. The first run downloads from the internet. Then **reload or restart the current agent app if required for skill discovery** so it sees the new skill, and run the check again.
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
8. Record which capabilities were actually verified. Keep `status.system_prep_complete` false until the broad environment check has passed; a false flag does not invalidate separately verified offline planning, analytics or inbox readiness.

If `bsk doctor` cannot be made to pass after one honest attempt, do not loop: report the specific blocker, use the manual route (`references/manual-fallback.md`) for that browser-dependent action, and continue offline work that does not need the browser.

---
## Module C. Optional first-flow dry runs (nothing is published)
Goal: prove the flow the client has reached. A plan can stop at an unapproved brief, a create test at a preview, an inbox test at unsent drafts, and an insights test at a saved report. The full video-to-form sequence below is for a requested publishing dry run, not a prerequisite to these smaller flows.
1. Ask the client for ONE real job folder (clips + stills), the customer-permission yes, and **which clip shows the finished result**. A zip: unpack with `python3 "$SKILL_DIR/scripts/unpack-footage.py" FILE.zip FOLDER` and do not go on until it says "all files present and complete". If footage is missing, continue with a conditional plan/filming request. Only run synthetic or unrelated tool-test clips when that separate test is authorized; never substitute them as client-job evidence.
2. Inspect the available footage and privacy concerns; begin the applicable HyperFrames storyline process before editing. Present three distinct storylines with a recommendation, let the client choose, then prepare `STORYLINES.md`, `SPEC.md`, and the storyboard with source intervals, output timing, draft captions, framing, and sound. A test with preparation footage may use an explicitly selected preparation story; it cannot masquerade as a finished result.
3. Refine the small group of unresolved video choices against that plan (`references/footage-cutdown.md`), record job-specific requirements in `video-brief.json`, and hand the sources and planning files to HyperFrames. Use the client's requested length throughout. Include requested catalog music once access is verified, show the DRAFT preview, collect revisions, and update reusable profile defaults separately from one-job exceptions. After exact words and edit approval, set `approved: true`, render `final.mp4`, and run `final-check.sh`.

4. Draft `caption.md` (DRAFT), run `lint-copy.py`, take the client's rewrite.
5. Publish form: follow `references/publish-route.md` steps 1 to 8 with the final video (or the cover and stills for an image note) and the approved caption. Stop at "all filled, button untouched". Take a screenshot of the form. Do NOT click 发布 in the dry run, even if `auto_publish` is on.
6. Stop the session (`bsk-stop.sh`). Check `bsk session list` is empty.
7. Write the log entry (what worked, what failed, selectors that changed) and tell the client the result in 3 lines.
8. Set `status.dry_run_complete` true only after the client has seen the filled form and said it looks right.

Return to the requested flow in `SKILL.md`. Continue refining saved preferences and checking new prerequisites at each boundary; setup never needs to finish all modules before useful work can continue.

## Optional: scheduled inbox checks
Do not create schedules during ordinary setup. If the client requests them, follow `references/scheduling.md`: discover host capabilities, confirm browser/account binding and timezone, use preview-only draft mode by default, and verify one bounded test. No scheduler or plan is mandatory for manual use.
