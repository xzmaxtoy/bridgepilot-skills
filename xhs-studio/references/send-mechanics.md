# Sending DMs and comment replies (bsk)

Proven a few times on XHS web (2026-10-09) on another account, through a different agent harness: DM replies, welcome DMs and one public comment reply, after the owner approved the exact texts. **Auto-send is NOT proven.** NOT yet run from Codex on the client's Chrome.

## Who sends
- `auto_reply_dms` / `auto_reply_comments` OFF (default): the skill drafts, the client sends. The skill never presses send.
- ON: first run `bash "$SKILL_DIR/scripts/guard.sh" dms` (or `comments`); exit 0 required. Send only a reply that matches a **pattern the client approved** (store approved patterns in `$XHS_HOME/reply-patterns.md`: thread type, exact wording, what is never promised). Anything else is a draft for the client. Log each send with `action-log.sh dm-reply|comment-reply auto "<thread pseudonym, text id>"`.

## Before a send
1. The client has approved this exact text or the pattern it matches. Never edit an approved text.
2. Open the thread from the inbox (sidebar 消息). Read the last bubble: theirs or ours (`inbox-triage.md`). The text must fit the thread.
3. Skip anyone on the client's skip list (peers, helpers).
4. Class B, J, F, H and anything about price, booking, complaints or safety: never sent by the skill. Escalate.

## DM route
1. Click the conversation (a JS click on `div.xhs-im-conv-item` by name is faster).
2. `bsk fill --session <id> --value "<approved text>" ".xhs-im-input-bar-editor"  # DM box`. Screenshot: the full text is in the box.
3. `bsk press --session <id> Enter  # send`.
4. Verify: a new blue bubble with the exact text and "刚刚" (just now), the input box empty, the thread moved to the top. Log it.
Sends are sequential, at least 60 s apart, with the window visible (`--show`). Daily cap: 10 sends unless the client sets another number.

## Public comment reply
Open the reply box from the notifications page ("回复" on the comment row, never the search box). Check the placeholder says `回复 <name>` (the only proof of the right target). Type the text. Enter only adds a newline: click `button.submit  # send`. Verify the reply shows under the comment. One reply per turn unless a batch is approved; 8 to 15 s between replies.

## What can block a send
- Some agent shells refuse the Enter keypress as a "real-world transaction" even after the client's approval. Do not work around it: ask the client to press Enter, or to allow it in their agent settings.
- Privacy block: a red "!" and "due to the other person's privacy settings you cannot send" (由于对方隐私设置). Do not retry. Until the other side follows back, only 1 text message is allowed.
- Any warning ("too frequent", "try later", send failed): stop, run `bsk-check-page.sh` (exit 4 stops all automation), report, no retry.
- The DM box needs the thread open in the visible window; background windows have failed.

## Limits
Replies at most 280 characters (platform cap about 300). Never put a contact ID, phone number, link, QR or other-platform name in a DM (`conversion-routes.md`). Never promise what the profile marks as not allowed.

## Log every send
Thread (pseudonym or nickname), text id, time, proof (bubble seen), lead flag (`log-standard.md`).
