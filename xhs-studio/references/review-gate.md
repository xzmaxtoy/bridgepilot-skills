# Review gate

Standard pre-publish check. Run the mechanical part with `scripts/lint-copy.py`, then the human checks below. Output a PASS/FAIL table. Any FAIL = not publishable.

## Inputs
`caption.md` (first line = title), the final video or `cover.png` plus 3 frames, and the profile (`red_lines`).

## 1. Red-line gate
- No contact ID, phone number, link, QR or other-platform name (lint R-contact, R-link, R-platform).
- No licence, insurance, bonded, years-in-business or price claim unless it is in `red_lines.claims_sourced_by_client` with a source (lint R-credential).
- No absolute claim or promise (best, first, only, 100%, guaranteed, free) (lint R-absolute).
- Nothing from the client's own banned or never-name lists (lint R-client, R-never-name).
- **No invented detail** (human check): every number, date, place, quote and result in the text is in the profile or was said by the client for this job.
- **Real footage only** (human check): nothing generated or stock; the job and the customer permission are recorded.
- No customer face, house number, street sign or licence plate in the footage or the cover.
- Only existing topics (checked in the topic picker at publish time).

## 2. Design gate (video and cover)
- D1 Text does not cover the main subject or a face.
- D2 Hook and caption lines do not overlap.
- D3 Line breaks keep meaning (no single "的" alone on a line).
- D4 Compact: text takes at most 40% of the frame height.
- D5 Everything inside the safe zone x 60-940, y 130-1440 (template does this; verify on 3 frames).
- D6 Chinese characters render (no empty boxes), font size 64 px or more.
- D7 One style across hook, captions and cover.
- D8 No DRAFT stamp in the final render (`approved: true`).

## 2b. Privacy gate (P1 to P5): people, houses, objects
The package has no automatic person or object detection. These are human checks on `plan-review.jpg` and on 3 frames of the final video (start, middle, end), also the edges:
- P1 No customer face, and no identifiable person (also workers and neighbours), in the video or the cover. A person at the edge counts. Drop the segment, or slide the crop (`pan`) / crop in (`zoom`) in `cut-plan.json`, then re-render.
- P2 No house number, street sign, licence plate, mailbox name or address text.
- P3 No utility meter, electrical panel or other fixture the client did not choose to show; no neighbour's yard.
- P4 The customer's permission for THIS job is recorded (`customer_permission`).
- P5 The client has seen the contact sheet or the final frames and said it is fine. The client may also ask to drop any shot.
Record "privacy check done: N dropped or cropped" in the log. If the reviewer cannot view images, P1-P3 are NOT done: say so.

## 3. Format gate (F1 to F7), on `caption.md`
- F1 A separator emoji every 2 to 3 paragraphs.
- F2 Body 300 to 500 characters.
- F3 Title at most 20 characters, core word in the first half.
- F4 5 to 8 topics.
- F5 The last line is a question.
- F6 A first comment is prepared.
- F7 Sentence rhythm varies; paragraphs are not uniform.

## 4. Approval gate
- A1 The client has seen the exact Chinese text and said it is approved (the `DRAFT` line is removed only after this).
- A2 The content-type declaration will be EMPTY unless the client said otherwise.
- A3 `guard.sh publish` result is known: who presses 发布 (client, or the skill after the client's yes).

## 5. Location gate (only when a place tag is set)
- L1 The tag is the exact place the client named; the search used the brand term, never a city or region word.
- L2 The note does not read like an ad (no business name stuffed in the title, no offer text).

## Process
1. Read `red_lines`. 2. Run `lint-copy.py`. 3. Human red-line, design and privacy checks on frames, cover and `plan-review.jpg`. 4. Approval gate. 5. Location gate if a tag is set. 6. Output the PASS/FAIL table.
