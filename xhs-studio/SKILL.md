---
name: xhs-studio
version: "0.2.0"
description: "Run a small business's Xiaohongshu (RedNote) account from the client's own computer: turn raw phone footage into a 10-30 s vertical post (the edit is done by the separately installed /hyperframes skill) with Chinese on-screen text and a cover, draft the Chinese caption (always as a DRAFT the client approves), fill the creator-center publish form, read comments, DMs and insights, and draft replies. Uses the client's own Chrome through the bsk browser tool. Three automation switches (auto-publish, auto-reply to comments, auto-reply to DMs) are all OFF by default. Use for: Xiaohongshu, 小红书, RedNote, post footage, make a post, publish, check comments, check DMs, post numbers, first-time setup, xhs-studio."
---

# xhs-studio

One client, one Xiaohongshu (XHS) account, one loop: **footage in -> cut -> Chinese text and cover -> caption draft -> client approves -> publish form -> comments and DMs -> numbers -> next post.** It runs inside the client's own Codex on the client's own computer. Real footage only.

`SKILL_DIR` = the folder that holds this SKILL.md. `XHS_HOME` = the client workspace: **a folder the client chose on the first run** (there is no fixed folder). It holds the profile, logs, jobs and footage. The path is saved once by `scripts/workspace.sh set` in `~/.config/xhs-studio/workspace`, and every script reads it from there; you set nothing in later commands. A script that finds no saved path stops with exit 12 and "NO WORKSPACE": run `SETUP.md` stage A0. The profile lives in the workspace, so a skill update never overwrites it. All scripts are called as `bash "$SKILL_DIR/scripts/<name>"` or `python3 "$SKILL_DIR/scripts/<name>"`.

"The owner" in the rules below means the client: the person who owns the XHS account.

## Step 0, every run
1. Run `bash "$SKILL_DIR/scripts/workspace.sh" status`. "not set" = stop and run `SETUP.md` stage A0. Then read `$XHS_HOME/profile.json` (get the path with `workspace.sh get`). If the profile is missing, or `status.interview_complete`, `system_prep_complete` or `dry_run_complete` is false: stop and run `SETUP.md` (the guided first run). Do nothing else first.
2. Run `bash "$SKILL_DIR/scripts/kill-switch.sh" status`. Report it in one line.
3. Read the newest files in `$XHS_HOME/log/` (what was done last time, what is waiting).
4. Run `bash "$SKILL_DIR/scripts/doctor.sh"` once per day, or whenever something fails.

## The three switches (client's choice, all OFF by default)
Set in the first-run interview, one by one, each with the plain note that **XHS may limit accounts that use automation**. Stored in `profile.json` > `automation`.

| Switch | OFF (default) | ON |
|---|---|---|
| `auto_publish` | The skill fills the whole form, leaves 发布 untouched, and tells the client. The client presses it. | After the client has approved the exact text and the cut, the skill presses 发布 itself, once. |
| `auto_reply_comments` | Reply drafts go to the client as a batch. The client sends. | The skill sends only replies that match a pattern the client approved. |
| `auto_reply_dms` | Reply drafts go to the client as a batch. The client sends. | The skill sends only replies that match a pattern the client approved. |

- Before ANY automatic action run `bash "$SKILL_DIR/scripts/guard.sh" publish|comments|dms`. Exit 0 = allowed. Anything else = prepare the draft and stop. Never test the switch by reading the file yourself.
- Log every automatic action with `scripts/action-log.sh` (before and after). The log is `$XHS_HOME/log/actions.jsonl`.
- **Kill switch:** `bash "$SKILL_DIR/scripts/kill-switch.sh" on` pauses all automatic actions at once (drafts and reading still work). `off` resumes. Tell the client this command in plain words during setup.
- **Warning stop:** `bsk-check-page.sh` exits 4 on any XHS warning and writes a stop file. All automatic actions stay off until the client clears it (`kill-switch.sh clear-warning`).
- Status of the evidence (honest): auto-publish was proven on one other account through a different harness. Auto-send of DMs and replies is NOT proven. Say so when the client asks about the switches.
- A switch only decides **who presses the button**. The client still approves the Chinese text first (see "Chinese copy" below).

## Chinese copy: always a DRAFT
Codex drafts the Chinese itself. No outside writing service, no key. Model Chinese reads stiff (生硬). So:
- Every Chinese output (caption, on-screen text, cover text, reply) is labelled **DRAFT 草稿**.
- The client rewrites or approves it in their own words before anything is rendered as final, published or sent. `final-check.sh` refuses a final video while `video-brief.json` has `approved: false`.
- Use the client's sample post and register (`profile.json` > `voice`). Short sentences, spoken style if the profile says spoken. No invented detail: never a number, a date, a name or a quote the client did not give.
- More: `references/copy-drafting.md`.

## Daily loop
1. Doctor check if due; kill-switch status.
2. Read the inbox, read-only (`references/inbox-triage.md`): at most 3 page loads. Diff against yesterday.
3. Draft replies in the client's voice. Show one batch to the client. If the matching switch is ON and the reply matches an approved pattern, send it (`references/send-mechanics.md`). Otherwise the client sends.
4. About 2 h after each post: sweep its comments.
5. Numbers at +24 h, +72 h and weekly (`references/insights.md`).
6. Write the day's log (`references/log-standard.md`).

## Make a post (the 11 steps)
1. **Footage in.** The client drops phone video and stills for ONE job in a folder. If it came as a zip, unpack it with `python3 "$SKILL_DIR/scripts/unpack-footage.py" FILE.zip FOLDER` (the system `unzip` can silently skip big clips) and require "all files present and complete". List the files. Ask, one at a time: what was the job, which city (city only), did the customer agree to be shown (`customer_permission`), **which clip shows the FINISHED RESULT** (required), and which clip, if any, should open the post (hook) and which shows the before state. No yes on permission = do not use that footage. Phone photos: `bash "$SKILL_DIR/scripts/prep-stills.sh" IN OUT` converts HEIC to JPG and makes a contact sheet (`references/footage-cutdown.md`).
2. **Fact lock.** Table of claims the post may make (service, before/after, timeframe). A claim with no source in the profile is cut. No licence, insurance, years-in-business or price claim unless the client stated it and gave the source. The client confirms the table.
3. **Rough cut (privacy check).** `python3 "$SKILL_DIR/scripts/cutdown.py" <folder or clips> --result <result clip> [--hook <clip>] [--before <clip>] --out "$XHS_HOME/jobs/<date>-<slug>"` -> `cut-plan.json`, `plan-review.jpg` + `plan-review.md`, `rough.mp4` (9:16, hook in the first 2 s, the ending only from the result clip), `cover-raw.png`, `video-brief.json`. **Then YOU review the plan before the client sees anything:** open `plan-review.jpg` (one tile per segment) and walk the table in `plan-review.md`. The script cannot see people, faces, house numbers, plates or utility meters: you are the check. Fix with `--avoid "CLIP@from-to"`, or edit `cut-plan.json` (delete, reorder, `start`, `pan`, `zoom`) and run `cutdown.py --render-plan`. Then show the client the cut and the tiles; they approve or ask for changes (`references/footage-cutdown.md`).
4. **Video requirements, then the edit in /hyperframes.** Ask the client, one question at a time (recommended answer first; reuse `profile.json` > `final_cut` as the default): **length** (10-30 s), **style**, **music**, **on-screen Chinese text** (yes/no; DRAFT hook, 2-4 captions, cover title), **which clips** to use and avoid. Write the answers into `video-brief.json` (the `requirements`, `on_screen_text` and `cover` fields). Then hand the edit to the separately installed **/hyperframes** skill: tell it the brief file, the source `rough.mp4` (or the original clips), the 1080x1920 frame and the safe zone (x 60-940, y 130-1440), the brand style from the profile, and the output path `<job>/final.mp4` (plus a `cover.png`). Ask it for a preview first (burn "DRAFT" into previews). If /hyperframes is not installed, `doctor.sh` says MISSING with the install command: tell the client and stop this step (`references/footage-cutdown.md`). The client approves or rewrites the words and the edit; set `approved: true` in `video-brief.json`; render the final; run `bash "$SKILL_DIR/scripts/final-check.sh" JOB` (exit 2 = not approved, exit 0 = accepted, size brought under 95 MB). The client can also open the HyperFrames project and edit the video themselves.
5. **Music and voice.** Per the client's answer in step 4. Default: none (real jobsite sound or silence; the client adds trending music inside the XHS app). If the client wants music, it must be a file they own or licensed. No generated voice.
6. **Caption draft.** Title (20 characters at most, core word in the first half), body 300-500 characters, 5-8 existing topics, a closing question, a first comment. Save as `caption.md` in the job folder, labelled DRAFT. The client edits and approves. SEO: `references/seo-guide.md`.
7. **Review gate** (includes the privacy gate P1-P5: people, house numbers, meters). `python3 "$SKILL_DIR/scripts/lint-copy.py" caption.md --profile "$XHS_HOME/profile.json" --first-comment "<text>"`, then the human checks in `references/review-gate.md`. Any FAIL = fix before the client sees it again.
8. **Publish.** Fill the creator-center form to "all filled, button untouched" (`references/publish-route.md`). With `auto_publish` OFF the client presses 发布. With it ON and `guard.sh publish` exit 0, the skill presses it once, after the client's approval of this exact post.
9. **Comments and DMs.** `references/inbox-triage.md`, `references/send-mechanics.md`. Price, booking, complaint, abuse, a request for a contact: escalate to the client, never answer.
10. **Read-back.** `references/insights.md`. Missing data stays blank, never zero. The profile's `north_star` number is reported next to the reach.
11. **Next post.** Winners by saves and comments per view, not reach, feed the next brief (`references/topic-ideation.md`).

## Hard stop rules (publish)
1. Fill the whole form, then STOP. Show the owner the form (the window is open in front with `--show`). The owner approves the exact post.
2. Click 发布 ONCE, only after that approval. Never click twice. Never use 定时发布 (schedule) unless the owner asks.
3. The content-type declaration (添加内容类型声明, "AI content" etc.) must be EMPTY unless the owner says otherwise.
4. On any warning, login wall or captcha: stop and report. Do not get past it.
5. The session dies if idle (about 15 min between turns). If the form is gone, rebuild the identical form and re-check it before publishing. Publish in the same turn as the final check when you can.

(With `auto_publish` ON, "the owner approves the exact post" is satisfied by the client's yes on this exact text and cut, given in chat before the click. The skill never publishes without that yes. Rules 2 to 5 are unchanged.)

## Rules that hold for every account
- One session, one tab. Close the tab first, then stop the session, then check `bsk session list` shows none. Never open the owner's other tabs.
- Never name a supplier, a competitor or another platform in a public or DM text. Never put a contact ID in any text.
- Never send, publish or schedule without the owner's approval for that exact text or post (or, for replies with the switch ON, a pattern the owner approved).
- Stop on any platform warning ("too frequent", "try later", restriction notices) and report; do not retry.
- Replies are written by the agent in the account's voice and labelled DRAFT until approved. No outside service sees them.
- Never enter a password, a 2FA code or a captcha. Sign-in, 2FA and captchas are always the client's (`bsk request-help`).
- Real footage only. Never use an AI-generated yard, turf or result. If the footage is not enough, ask the client for more footage.
- Never write a licence, insurance, bonded, years-in-business or price claim unless the client stated it AND gave the source (`profile.json` > `red_lines`).
- XHS forbids contact IDs, links and QR codes in posts, comments and DMs. Use only the plain-text hand-off wording in the profile (`references/conversion-routes.md`).
- Interaction: one question at a time, recommended answer first; batch approvals as one card; save long material to files and name them instead of pasting in chat.

## What is proven, and what is not (status 2026-11-08, v0.2.0)
| Job | Status |
|---|---|
| Cutdown script, final-check gate, workspace folder, copy lint, switches, kill switch, action log | Tested offline on synthetic footage |
| Edit and Chinese text through /hyperframes | NOT tested end to end here (the hand-off brief and the final-check are tested; the HyperFrames render itself is not) |
| Fill the creator-center image-note form and publish | Proven once on another account, through a different harness. NOT yet proven on bsk driven from Codex on the client's Chrome |
| Video upload form on creator center | NOT tested anywhere |
| Read DM threads, send DM replies, reply to comments | Proven a few times on another account through a different harness. Auto-send is NOT proven |
| Read insights and comment lists in bulk | NOT tested |
| XHS rules for accounts outside mainland China | Unverified. Treat as unknown; stop on any warning |
The first dry run in `SETUP.md` is where these get proven for this client. Report what worked and what did not.

## Files
| File | Use |
|---|---|
| `SETUP.md` | Guided first run: workspace folder, interview, system preparation, dry run |
| `DEPENDENCIES.md` | Every dependency, check command, install step |
| `LICENSES.md` | Licence terms for bsk and HyperFrames; what a reseller must do |
| `CHANGELOG.md` | Versions |
| `brand/profile.template.json` | The ONE profile file (data, not code) |
| `references/interview.md` | The first-run questions, in order |
| `references/footage-cutdown.md` | Raw footage to 9:16 rough cut, privacy check, the /hyperframes hand-off, text zones, cover |
| `references/copy-drafting.md` | Chinese drafting rules, caption format |
| `references/browser-runtime.md` | bsk session, one tab, selectors, low-token rules |
| `references/publish-route.md` | Creator-center publish steps and live check |
| `references/publish-flows.md` | Post types and common faults |
| `references/inbox-triage.md` | Message classes, daily scan, batch card |
| `references/send-mechanics.md` | Sending replies, pacing, what blocks a send |
| `references/insights.md` | Numbers per post, weekly roll-up |
| `references/review-gate.md` | Pre-publish checks |
| `references/conversion-routes.md` | Off-platform hand-off, what may never appear |
| `references/seo-guide.md`, `topic-ideation.md` | Keywords and topics |
| `references/log-standard.md` | Log folders and formats |
| `references/manual-fallback.md` | If bsk fails its check |
| `scripts/` | doctor, workspace, check-hyperframes, unpack-footage, prep-stills, cutdown, final-check, shrink-to-limit, bsk wrappers, guard, kill switch, action log, lint, profile check, self-test |
