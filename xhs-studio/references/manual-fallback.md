# Manual fallback (only if bsk fails its check)

The browser route (bsk on the client's Chrome) is required. Use this route only when `bsk doctor` cannot be made to pass after one honest attempt, or the creator-center page cannot be driven. Tell the client plainly that this is the slower route, and report the exact failure (command, message) to BridgePilot so it can be fixed.

What still works without bsk:
- Cutdown, Chinese text, cover, caption draft, review gate: all local scripts. Nothing changes.
- Publish: put `final.mp4` (or the images), `cover.png` and `caption.md` in one folder; tell the client the path; give them the title, the body and the topics as separate blocks to copy. The client uploads, pastes and presses 发布 themselves. The skill cannot check the live post.
- Inbox: the client pastes new comments and DMs into the chat (nicknames only); the skill classifies them and drafts replies; the client sends.
- Insights: the client reads the numbers from the creator center and types them in; the skill records them.
Automation switches have no effect on this route: everything is client-sent. Record in the log that the fallback was used and why.
