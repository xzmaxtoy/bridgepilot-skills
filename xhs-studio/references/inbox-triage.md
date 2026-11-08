# Inbox triage: classes, daily scan, batch card

Comments and DMs. Reading is always allowed (read-only). Sending follows the client's switches (`SKILL.md`) and `send-mechanics.md`.

## Classes (written for a local service business)
| Class | What it is | Priority | Target response | Done means |
|---|---|---|---|---|
| A system mutual follow | Only the system line "we now follow each other" | P4 | No reply. A later user message re-activates the thread: re-classify on the daily diff | No action |
| B visit / quote intent | Asks about price, a visit, a measurement, availability, "can you come to <city>" | P1 | 24 h | The client is told at once. The reply is hand-off wording only (no price, no date, no promise) |
| C service question | What material, how long it takes, how it works, before/after detail | P2 | 3 days | General answer from the profile's sourced facts, plus the hand-off wording |
| D peer / business | Supply offers, collaboration, agencies, job seekers | P3 | 7 days, may stay unanswered | One polite line or "no reply" |
| E spam / ads | Lead drops, course selling, mass mail | P5 | No reply | Logged; the client reports or blocks |
| F abuse / harassment | Harassment, personal attacks, threats, requests for private data | Escalate | Show the client at once | No reply; the client decides |
| G public comment | Question, praise or pushback under a note. Sub-mark G-intent (how to book, how much, where) and treat it like B | P2 question / P3 praise / P4 pushback | 3 days, batched with post days | Replied per `send-mechanics.md` |
| H contact request | Asks for or leaves a contact ID or phone | Escalate, B sub-type | As B | Never exchange; use the profile's hand-off wording |
| I unclear | Image, emoji, "?" | P3 | Ask one clarifying question | Re-classified. I-needs-opening: preview cannot tell; the client decides whether to open it |
| J complaint | Unhappy customer, damage, dispute, safety | Escalate | Show the client at once | No reply from the skill, ever |
New-follower notifications count as A (P4). "Follow back" is the client's manual action; the skill never clicks it.

Order: F = J > B > C = G(question) > D > G(praise) > A/E.

**Never answered by the skill, in any mode:** price, discounts, booking dates, quotes, timelines, guarantees, anything about licence or insurance, complaints, safety. These go to the client with the thread and the draft hand-off line.

## Daily scan (read-only, at most 3 page loads)
1. Load 1: `/notification`; read the three sub pages with in-page clicks.
2. Load 2: sidebar 消息 into `/chat`; read the conversation list (lazy-loaded; threads can appear only after the click).
3. Load 3: reserved for one retry only.
4. Diff against yesterday's `inbox-state.json`: new threads, changed previews, unread badges, new notifications.
5. Draft only for new B/C/H threads or previews that turned into intent. Everything else is just logged.
6. Output one batch card per day (an empty day gets one line "no new messages").
7. Save the new snapshot as `inbox-state.json` and the old one as `inbox-state-YYYY-MM-DD.json` in `$XHS_HOME/log/`.
Do not: open threads (that marks them read), reply, like, follow or follow back, mark read. Opening a thread is allowed only when it is on the approved send list.
After a post: about 2 h later, one page load of `/notification` > 评论和@, read new comments only, put G-intent comments in the batch card.
Safety: at most 3 page loads per session, 3 to 6 s between navigations, single tab. Any login wall, captcha or "too frequent" notice: stop and report (`bsk-check-page.sh` exit 3 or 4). One retry for an HTTP 5xx or 524 page, at least 5 s later; then give up for the day. Drop to every other day after 3 empty days.

## Last bubble check (always)
A list preview shows the LAST message, which can be OURS. Open the thread (only on the approved send list) and check who sent the last bubble (right/blue = us) before drafting. Never send "sorry for the late reply" when our message is the last one.

## Batch card (one line per thread, phone-readable)
```
#3 <nick> | class | priority | date (days waiting)
Their words: <exact text>
Last bubble: theirs / ours
Draft (DRAFT 草稿): <text>
Reply: 1 send / 2 edit: __ / 3 no reply / 4 escalate
```
The client answers with codes ("3-1 4-2"). The log is updated only after the send is verified.

## Lead table (B and H only)
One row per thread: id, nickname only (no avatar, no full message text), first and last message date, source post if known, class, question summary (20 characters at most), our reply date, how the client took it over, outcome (visit booked yes/no/date), note.
"Traced customer" = a customer who came through XHS AND the client confirms (visit booked, job done). A reply alone does not count. Say what cannot be traced in every report. This feeds the profile's `north_star`.
