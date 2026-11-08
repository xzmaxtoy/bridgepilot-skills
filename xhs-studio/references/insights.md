# Insights: numbers per post, weekly roll-up

Read through bsk, read-only. **Not yet tested as a routine on any route:** the first run discovers the pages. Use one session, at most a few pages per run, `bsk evaluate` templates scoped to `main`, and report what worked and what did not.

## Where the numbers are (to confirm on the first run)
- Creator center note manager `https://creator.xiaohongshu.com/new/note-manager`: per note views, likes, comments, saves.
- Creator center data pages (the 数据 area of creator.xiaohongshu.com): per note and account trend. Find the link by `bsk snapshot` / `observe`; do not guess URLs.
- Notifications `/notification`: comments, likes and saves, new followers.
- DM list: count of new threads per class (`inbox-triage.md`).
Write down the page and selector that worked in `$XHS_HOME/log/patterns/insights-pages.md` so the next run is faster.

## Per post
| When | Action |
|---|---|
| +10 min | Leave a first comment (prepared in `caption.md`): a real question. No self-praise, no marketing, no links. Posting it is an action: the client does it, or the skill does it only if `auto_reply_comments` is ON and `guard.sh comments` exits 0 |
| +30 min | Look at first numbers; draft answers to the first comments |
| +2 h | Draft answers to all comments (aim for an interaction rate above 5%); put G-intent comments in the batch card |
| +24 h | Did the note enter the recommendation feed? Record views, likes, saves, comments, shares, follows |
| +72 h | Check for a second push; record the numbers again |
Public lore, not official: comments and shares weigh about 4x a like, a follow about 8x. The first 2 hours decide the first traffic pool; an interaction rate below 3% stalls it. Say "public lore" if you quote it.

## Weekly roll-up
Per note: views, likes, saves, comments, shares, follows gained, intent DMs, and the profile's **north star** (`north_star.metric`, for example measurement visits booked, as counted per `north_star.how_counted`). Save rate and comment rate per view. Mark every figure that is inferred, not read from the creator backend, as "inferred". **Missing data stays blank (null), never zero.**
`results.json` shape: `{ "meta": {account, period, source}, "results": [ {note_id, title, published_at, views, likes, saves, comments, shares, follows, intent_dms, north_star, notes} ] }`, saved in `$XHS_HOME/log/`.

## Reporting rule
Never quote reach alone. Always side by side: views, follows, intent DMs, the north-star number, and say what could not be traced. Ask the client for the north-star count (they hold it): the skill cannot see it on XHS.

## Feeding the next post
Pick the winners by saves and comments per view, not reach. Record for each: hook, structure, topic, time of day. Turn the pattern, not the text, into the next brief (`topic-ideation.md`).
