# Publish route: creator-center form (bsk on the client's Chrome)

Proven 2026-10-10 on one live image post, on another account, through a different agent harness. NOT yet proven from Codex on the client's own Chrome: the first dry run in `SETUP.md` is where it gets proven. Selectors can change: if one fails, `bsk snapshot` / `bsk observe` again and retry once, then report.

## Hard stop rules
1. Fill the whole form, then STOP. Show the owner the form (the window is open in front with `--show`). The owner approves the exact post.
2. Click 发布 ONCE, only after that approval. Never click twice. Never use 定时发布 (schedule) unless the owner asks.
3. The content-type declaration (添加内容类型声明, "AI content" etc.) must be EMPTY unless the owner says otherwise.
4. On any warning, login wall or captcha: stop and report. Do not get past it.
5. The session dies if idle (about 15 min between turns). If the form is gone, rebuild the identical form and re-check it before publishing. Publish in the same turn as the final check when you can.

Switch note: `auto_publish` (profile) decides only WHO presses 发布. OFF (default): stop at "all filled, button untouched" and tell the client to press it. ON: allowed only if `bash "$SKILL_DIR/scripts/guard.sh" publish` exits 0 AND the client has said yes to this exact post in chat. Log the attempt and the result with `action-log.sh` (types `publish-attempt`, `publish-done`). In the dry run never click 发布.

## Steps
1. Start: `bash "$SKILL_DIR/scripts/bsk-start.sh" "<task>" --show` (the client is at the computer and sees the window). Use the printed 4-letter id in every command.
2. `bsk navigate --session <id> "https://creator.xiaohongshu.com/publish/publish?source=official&from=menu&target=image"`, then `bsk-check-page.sh <id>` (exit 0). Wait until `input.upload-input` exists (the page loads for a few seconds; `snapshot` is empty here, use `evaluate`). For a video post use the 上传视频 tab on this page (see "Video" below).
3. **Upload the files.** First try `bsk upload` on the page's file input. It may fail with "no visible geometry" (the input is hidden) or "Not allowed" (the extension lacks Chrome's "Allow access to file URLs"; turning that on in `chrome://extensions` > BrowserSkill may fix it). Fallback that worked:
   - Copy the files into a plain local folder (not a synced one). Serve it: `python3 "$SKILL_DIR/scripts/serve-folder.py" <folder> 8765` in the background (127.0.0.1 only, CORS on).
   - `bsk evaluate`: for each file in order, `fetch("http://127.0.0.1:8765/<name>")` -> `new File([blob], name, {type})` -> `DataTransfer.items.add`; then `input.files = dt.files` and dispatch a bubbling `change` event. An image note jumps to the editor ("图片编辑 N/18").
   - Check the thumbnail order in a screenshot. Stop the server afterwards. Delete the temporary copies only with the client's OK.
   - A tip popup ("我知道了") may cover the form: dismiss it with an `evaluate` click.
4. Title: `bsk fill --session <id> --value "<title>" "input.d-text"  # title field` (the first `input.d-text`, placeholder 填写标题会有更多赞哦). `--value` is required, the target goes last. Max 20 characters.
5. Body: the editor is `.tiptap.ProseMirror`. Focus it, then dispatch a synthetic paste: `ed.dispatchEvent(new ClipboardEvent("paste",{clipboardData:dt,bubbles:true,cancelable:true}))` with `dt.setData("text/plain", body)` (body fetched from the same local server). `bsk fill` does not work on this editor. Blank lines become empty paragraphs (fine). The counter shows N/1000.
6. Topics (话题): put the cursor at the end (`getSelection().selectAllChildren(ed); collapseToEnd()`), `bsk press Enter` twice. For each tag: `document.execCommand("insertText",false,"#tag")`, wait until the suggestion list (`.d-options`) shows plus about 1.5 s, then `bsk press --session <id> Enter` -> the first suggestion becomes an `a.tiptap-topic` chip. If the list was not loaded yet the tag stays plain text: delete that line and redo it. Verify with `JSON.parse(a.dataset.topic).name` for every chip. Only existing topics, never invent tags.
7. Location (地点): optional, see below.
8. Check the defaults (below), then screenshot the top and bottom of the form and the phone preview.
9. STOP. Wait for the owner's approval of this exact post.
10. Publish (after approval, once): the bottom bar is one custom element (`xhs-publish-btn`) with a CLOSED shadow root, so a text search for 发布 finds nothing and a selector click hits the gap between the two buttons. Run `bsk observe --session <id>` and find `button "发布"` (next to `button "暂存离开"`), then `bsk click --session <id> @eNN  # "发布" button`.
11. Success signal: the URL becomes `https://creator.xiaohongshu.com/publish/success?...` and the page says 发布成功 / "5 秒后将返回发布页". Any warning text: stop and report.

## Video (NOT tested on any route yet)
Open the 上传视频 tab on the publish page (click the tab; do not guess a URL). Upload `final.mp4` as in step 3 (large files: the local-server fetch route may be slow; if it fails, report and fall back to `manual-fallback.md`). Set the cover: use the uploaded `cover.png` if the page offers a cover upload, otherwise pick the frame the page shows and tell the client. Then title, body, topics as above. Stop at "all filled, button untouched". Report every step that behaved differently from the image-note form: this is new ground.

## Location step (optional)
Only if `profile.json` names a place to tag (a business listing the client owns). Rules:
- Re-check the picker before each posting day: which places the account's region can find may change. A read-only check: open the 添加地点 control (it appears only after the form has media), search the brand's POI term, read the results, change nothing.
- Search by the brand's own POI term. NEVER search a city or region word: results fill up with unrelated places in other countries.
- Pick only the exact place the client named (name + street address). If it is not offered: stop and report; pick no other place.
- Mechanics: the 添加地点 select is `.d-select-placeholder` with that text (the first `.d-select-placeholder` is the content-type declaration; do not click it by mistake). Tag it with an id via `evaluate`, `bsk click "#id"`, tag `document.activeElement` (the search input) and `bsk fill --value "<term>"`. Results are `.option-item` entries; match on name AND street address, then `bsk click` it.
- An open dropdown overlaps the controls below it: screenshot after every dropdown click. To undo a declaration: open its dropdown, click `.d-select-suffix-clear`, click a neutral heading to close.

## Defaults to check and report
加入合集 (collection): none. 原创声明 (original declaration): per client (default off). 内容类型声明: EMPTY. 选择群聊 / 引用笔记 / 投票 / 路线 / 文件: none. 关联活动: none linked. 允许正文复制: on. 可见范围: 公开可见 (or what the client says). 定时发布: off.

## After publishing: is it live?
1. Creator center `https://creator.xiaohongshu.com/new/note-manager`: the new card is first in the list. Use the tabs: it must be under 已发布 and NOT under 审核中 or 未通过. (The card shows no status label; do not click the icon buttons on the card, one is delete.)
2. Note id: the card's `data-impression` attribute (`noteId`).
3. Public link: `https://www.xiaohongshu.com/explore/<id>` alone gives a 404 page. Go to `https://www.xiaohongshu.com/explore`, take the `我` link `/user/profile/<userid>`, open it, and take the note's link that carries `xsec_token`. Open that. Check: title, body, topic links, "<n>分钟前 <region>", image counter 1/N, all images in order.
4. Location tag: look in the app if the web page does not show it.
5. Write the log entry (`log-standard.md`).

## Close down
1. Close the tab first (`bsk tab borrow` + `window.close()`), 2. `bsk-stop.sh <id>`, 3. `bsk session list` must show no session. Leave the form open and in front only when the client is about to review it.
