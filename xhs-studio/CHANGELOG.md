# Changelog

Semantic versions; the version is in `SKILL.md` frontmatter metadata. To pass an update to a client: give them the new folder, they run `bash scripts/install-to-codex.sh --force`. Their profile, logs and jobs live in the workspace folder (`XHS_HOME`, default `~/xhs-studio`) and are not touched. If `profile.template.json` gains a field, the changelog says so and the skill adds it to their profile at the next run.

## 0.4.2 - 2026-11-08
- Save complete report bundles in the client workspace (or explicit chosen destination), verify portable links, and maintain separate account-scoped live/test report pointers. Host output folders are staging copies.
- Make repeat video planning read the matching-account report and prior experiment first, then link evidence, targeting, hypothesis and outcome windows into the next job brief. Keep account/test boundaries and normal creative/publishing approvals.

## 0.4.1 - 2026-11-08
- Make setup and optional inbox scheduling host-neutral: discover actual local-tool, skill, scheduler and notification capabilities rather than requiring ChatGPT/Codex or a named plan. Keep legacy installer usable with a chosen destination.
- Add a portable scheduled-check brief, preview-only/draft-only defaults, independent action authorization, persistent baselines, bounded tests and verified cancellation. Scheduled browser execution remains unverified; manual inbox read/draft was tested once.
- Clarify last-sender checks and read-state side effects. Historical messages and our last replies do not become new leads.
- Include the visual-report assets in installation so an installed copy can render weekly reports. No profile migration or schedule is created by this update.

## 0.4.0 - 2026-11-08
- Weekly reviews download official analytics first, preserve raw exports, and use UI reads for missing context.
- Add an offline visual report template and validated renderer: daily charts, weekly outcome cards, cumulative post comparisons, local targeting evidence, draft experiment and source links. Test renderer with `python3 scripts/test-weekly-report.py`.
- Audit local geography, title/caption keywords, existing topics, location tags and business outcomes with explicit unknowns. Do not infer location from language or blame hashtags without evidence.
- Separate publication filters from metric periods; reconcile totals, conflicting dates and rate definitions. Remove unsupported algorithm-weight lore from analytics guidance.
- Evidence: one read-only account test downloaded two official Excel exports and verified desktop/mobile report interactions. Geography and posted caption/topic access remain unverified. No client data or profile migration.

## 0.3.0 - 2026-11-08
- Prefill sourced business facts from client websites/documents; ask small related groups with recommendations, allow optional sample posts to wait, and refine reusable creative preferences through the first video.
- Follow HyperFrames storyline selection and a concrete storyboard/SPEC before the applicable first-video edit. Keep source footage available; use automatic cutdown only for compatible result-led stories.
- Honor explicit durations through 60 seconds in profile validation, cutdown targets, briefs, and final QA; retain a shorter recommendation when unspecified.
- Offer free catalog BGM when music is requested. Check the optional HeyGen helper, guide sign-in, and prove retrieval before recording catalog readiness. Do not silently use paid generation.
- Template additions: `final_cut.music_source`, `final_cut.preferences_confirmed`, and `system.music_catalog_ready`. Missing fields in existing profiles mean none, provisional, and unverified; ask only when that route is used. No client profile is overwritten.

## 0.2.0 - 2026-11-08
- **Video editing moved to HyperFrames.** Remotion removed (no `remotion-template/`, no `render.sh`, no `setup-remotion.sh`). The skill now asks the client for the video requirements (length, style, music, on-screen text, which clips), writes them to `video-brief.json` (was `props.json`) and hands the edit to the separately installed `/hyperframes` skill. New `final-check.sh` gates the result (approved flag, 1080x1920, length, size). New `check-hyperframes.sh`; `doctor.sh` and setup stage B check the HyperFrames skill, Node 22+ and ffmpeg and print the install command. Licence: Apache 2.0, no per-render fee (see `LICENSES.md`).
- **No fixed workspace.** The first run (SETUP stage A0) asks where to store everything, saves the path with `scripts/workspace.sh set` (`~/.config/xhs-studio/workspace`) and every script reads it (`_env.sh`). Scripts stop with exit 12 if no folder is chosen. The client is guided, in Chinese and English, to create a ChatGPT project (Work mode), add the editing-material folder under Source folders and move the conversation in.
- Package carries only the blank `brand/profile.template.json`: no brand, client seed or footage.
- README tells the client's agent to download from github.com/xzmaxtoy/bridgepilot-skills and install.
- Node: any version 22 or newer is accepted (the Node 26 rule existed only for Remotion).
- Kept: three switches OFF by default, Codex-native Chinese copy, bsk browser route, stop before 发布.

## 0.1.2 - 2026-10-16
- Removed the client seed file and every reference to it. It held a client seed and must not ship to other clients. The first-run interview now asks every answer.

## 0.1.1 - 2026-10-14 (fixes from the first fresh-tester run on real footage)
- Cutdown: asks for the RESULT clip first (`--result`; optional `--hook`, `--before`, `--avoid`). The hook and the whole ending now come from the result clip, as one continuous stretch; at least one segment from it is guaranteed. Without `--result` it warns loudly. Folders are accepted as input.
- Cutdown: review step. Writes `plan-review.jpg` (one tile per segment, cropped as rendered) and `plan-review.md`; `--plan-only`; per-segment `pan` and `zoom` to crop a person out; `--avoid` to skip a stretch. No automatic person or object detection exists, and the docs say so (a skin-tone test was tried on real footage and removed: soil and wood trigger it).
- New privacy gate P1-P5 in the review gate; SKILL.md makes the plan review a mandatory step before the client sees the cut.
- Stills: `prep-stills.sh` (HEIC to JPG, contact sheet), `--cover-still`, `--still before|after:IMG`.
- Zips: `unpack-footage.py` extracts file by file and checks every file against the zip listing (the system `unzip` can silently skip big clips on Chinese file names).
- Render: crf 23 plus `shrink-to-limit.sh` (re-encodes when over `XHS_MAX_MB`, default 95; XHS limit 100). Final render still refuses while `approved` is false (tested).
- Template: place label and watermark moved inside the safe zone; brand colour and font read from `profile.json` > `brand.style`.
- Lint: reads the documented caption layout (DRAFT marker line ignored, `FIRST COMMENT:` section); 第一步 / 第一次 no longer flagged as a ranking claim.
- doctor: Node 26 or any non-LTS Node is MISSING (it breaks Remotion silently); the bsk agent skill is MISSING when absent (as SETUP says), with `XHS_SKIP_BSK_SKILL=1` for test runs.
- install-to-codex.sh message no longer assumes `~/xhs-studio`; docs say every script reads `XHS_HOME` from the environment.
- profile template: new optional `brand.style`.

## 0.1.0 - 2026-10-14 (first build)
- Combined the Xiaohongshu operating manual and the short-video builder into one client-side skill. Brand-specific material removed.
- New: footage cutdown (`scripts/cutdown.py`): raw phone video to a 10-30 s 9:16 cut with a hook, plus a cover frame.
- New: slim Remotion project (Post + Cover) with Chinese text inside XHS safe zones and a DRAFT stamp until the client approves.
- Browser route is bsk on the client's own Chrome, with client-side start/stop/check wrappers.
- Three automation switches (auto-publish, auto-reply comments, auto-reply DMs), all OFF by default; guard, kill switch, warning stop, action log.
- Guided first run (interview, system preparation, dry run) and one profile file.
- No outside writing service: Codex drafts Chinese; everything is DRAFT until the client approves.
- Tested offline: cutdown on synthetic clips, Remotion Chinese render, copy lint, switches. NOT yet tested: any XHS page, video upload form, auto-send, insights reading.
