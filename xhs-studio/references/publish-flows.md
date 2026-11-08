# Publish flows: post types and common faults

The step-by-step for an image note is `publish-route.md`. This file lists the other types and the usual faults.

## Required before publishing (any type)
Cover, title, body. Publishing stops at the 发布 button until the client approves the exact post (or, with `auto_publish` ON and `guard.sh publish` exit 0, the skill presses it once after the client's yes).

## Image note
Use `publish-route.md`. Title at most 20 characters (the counter shows `xx/20`; shorten at once if it is over). The body editor is a TipTap/ProseMirror `contenteditable`; setting `innerText` directly throws; use the synthetic paste in `publish-route.md`.

## Image note, text-to-image ("文字配图")
1. Open "上传图文", click 文字配图. 2. Type the cover text, click generate. 3. Pick a style on the template page, next. 4. In the editor fill title, body, topics. 5. Check the three required parts and stop at 发布. (Generated cards are text only; never use it to show a yard.)

## Half-way pre-publish (do not publish)
Done when the cover exists, the editor is open, title and body are filled, and the 发布 button is visible and untouched. This is the dry-run end state.

## Video (cutdown output)
`publish-route.md` "Video". Not tested on any route yet; report what differs.

## Long post
"写长文": not used by xhs-studio. If the goal is an image or video note, do not enter this path by mistake.

## Common faults
- Wrong tab (long post): go back to 发布笔记 and switch to 上传图文 or 上传视频.
- Drafts box opens on video: switch to the image-note tab before editing.
- Title over limit (`xx/20`): shorten at once.
- Only the cover was done: title and body must be filled too.
- Two upload entry points (double tab): if the first fails, try the second and snapshot to check.
- `bsk upload` fails: use the local-server upload in `publish-route.md`.
- Last click: "element stale" on 发布 means the button is inside a closed shadow root; use `bsk observe` and click the ref, or hand the click to the client.
- Web note detail asks for a QR scan: handle comments from the notifications page, or ask the client to use the app.
- Drafts live in the browser's local storage, not on the server. Do not edit or discard an existing draft that belongs to the client.
