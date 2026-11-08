# Log standard

Everything is kept in the client workspace `$XHS_HOME/log/` (the storage folder the client chose on the first run). Never inside the skill folder.

## Files and folders
- `actions.jsonl` - one JSON line per automatic action and per kill-switch / warning event (written by `scripts/action-log.sh`). Never edit by hand.
- `actions/` - what was done: posts published, sends, scans. `reviews/` - reviews. `patterns/` - what works, one pattern per file (`voice.md`, `insights-pages.md`). `topics/` - topic research.
- File names start with the date: `YYYY-MM-DD-short-slug.md`. One conclusion per file. Every entry starts with: date, what, result, evidence (proof seen), next step.

## Post entry (published post)
Note title and id, publish time, route (`bsk form`), who pressed 发布 (client / skill), defaults seen (declaration, visibility, schedule), topics, place tag (chosen / not offered / not visible on web), what the client edited out of the draft and why, live-check result (tab 已发布, public link works), warnings seen (none or text), what to check next (+2 h comments, +24 h and +72 h numbers).

## Send log (DMs and comment replies)
One table per day: thread (nickname or pseudonym "thread N"), text id, time, proof (blue bubble with the exact text and "just now"), lead flag. Never store avatars, full inbound message text, contact details or order data of customers beyond the minimum fields; use pseudonyms in anything that leaves the workspace. Record failures too: blocked sends (privacy block), denied keypresses, warnings.

## Daily scan state
`inbox-state.json`: per conversation id, nickname, date of last message, unread count, preview (truncated), class; plus notification counts. Overwrite daily; keep the previous day as `inbox-state-YYYY-MM-DD.json`.

## Housekeeping
At the end of a browser run: pages read, clicks (labels), changes made (none or what), session stopped and `bsk session list` empty.
