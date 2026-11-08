# First-run interview

Goal: fill `$XHS_HOME/profile.json` (start from `brand/profile.template.json`; ask every answer in the interview, assume none). No separate question list is ever sent to the client: you ask them here.

## How to run it
- One question at a time. Say the recommended answer first when there is one. Wait for the answer.
- Chat language: the client's (English or Chinese). Keep questions short and plain.
- After each section, write the answers into `profile.json` right away (so a stop in the middle loses nothing). Show the client the section in plain words and ask "right?".
- Every fact gets a `source`: "client, interview YYYY-MM-DD" when the client states it now, a document name if they show one, or the word **UNVERIFIED** when they are unsure or it came from a seed. An UNVERIFIED fact may never be used as a claim in a post.
- Never ask for a password, a 2FA code, a card number or a customer's private details.
- Do not paste the whole list at the client. Do not skip a section because the answer seems obvious.

## Sections (in this order)

### 1. The XHS account
Does the account exist today? Handle (the name, not a login). Personal or professional (专业号)? About how many followers? Who runs it now? Is the client signed in to the XHS creator center in the Chrome they use on this computer?
-> `client.xhs_handle`, `client.account_type`. If there is no account yet: stop here; the client creates it first (sign-up, phone checks and captchas are always theirs).

### 2. Brand material
Business name as customers know it. What services do you sell today (one line each)? Which cities or areas do you serve (city names only)? What makes you different, in your own words (1-3 things, each one true and provable)? Who is the customer?
-> `client.business_name`, `brand.services[]`, `brand.service_area`, `brand.differentiators[]`, `brand.audience`. Services are a list so a new service later = one more row in this file.

### 3. Voice
Mandarin or Cantonese-flavoured written Chinese for posts and replies? (XHS is read in Simplified Chinese.) Spoken, like talking to a neighbour, or written and tidy? Please paste ONE finished post you like (yours or another account's) and say why you like it.
-> `voice.*`. The sample post is the style target. Say plainly: "My Chinese will be a draft. You rewrite it; I learn from your edits."

### 4. Final cut and style
How long should a video be (10 to 30 seconds; recommend 15)? What should the first 2 seconds show? On-screen Chinese text: yes or no? Music: none (recommended; you add trending music inside the XHS app)? Faces in the frame: yes, no, or hands only? Do you want a watermark or brand tag? Any style you like (calm, fast, before/after, close-up)?
-> `final_cut.*`.

### 5. Red lines and banned claims
Ask: "Is there anything we must never say?" Then state the standing rule: the skill never says or implies licensed, insured, bonded, or a number of years in business, unless you tell me it is true AND where I can see proof. Ask whether the client wants to state any such claim now (if yes: the claim and its source go to `red_lines.claims_sourced_by_client`, and only then `licence_claim_allowed` may be true). Also: words to avoid, names never to mention (competitors, suppliers, partners).
-> `red_lines.*`. Default for the licence line: not allowed.

### 6. Customer permission
Explain: before using footage of a customer's yard, I ask you "did the customer agree to be shown?" every time. Faces, house numbers and street signs are never shown. Confirm.
-> `customer_permission.ask_per_job` (default true).

### 7. How customers reach you off-platform
Explain: XHS does not allow contact IDs, phone numbers, links or QR codes in posts, comments or DMs. I will only write plain-text hand-off wording. Ask: what should a customer do when they want a visit or a quote? (for example: "send us a private message here and we will answer", or the neighbourhood you serve). Who gets the leads you escalate?
-> `contact_handoff.plain_text_wording[]` (a few lines), `contact_handoff.who_gets_escalations`. Check each line has no ID, number, link or other platform name.

### 8. Direct messages
Who answers DMs today? How fast do you want a first answer (hours)? Is there a backup person?
-> `dms.*`.

### 9. The one number that matters
Ask: "If this account works, which one number goes up?" Recommend a business action over reach, for example measurement visits booked. How would we count it (who tells me, how often)?
-> `north_star.metric`, `north_star.how_counted`.

### 10. The three switches (ask ONE BY ONE, default OFF)
For each, say this in plain words first: "XHS may limit accounts that use automation. If it does, the skill stops and tells you. You can turn this off any time with the kill switch." Then ask:
- (a) Auto-publish: after you approve the exact post, should I press 发布 myself? Default: no, I fill the form and you press it. (Auto-publish was proven on one other account.)
- (b) Auto-reply to comments: should I send replies that match wording you approved? Default: no, I draft, you send. (Not yet proven.)
- (c) Auto-reply to DMs: same. Default: no. (Not yet proven.)
Record each answer separately in `automation.*`, set `asked_on` to today's date, and set `warning_acknowledged` true only after the client has heard the note. If any switch is on, repeat the kill-switch command to the client: `bash scripts/kill-switch.sh on`.

### 11. Computer, tools and footage path
Which computer (Mac or Windows) and which system version? Which ChatGPT / Codex plan? Which browser holds the XHS login (Chrome recommended)? How does footage get from the phone to this computer (cable, AirDrop, a Drive or Dropbox folder)? Which folder should I read it from?
-> `system.*`. A phone or tablet alone cannot run the cutdown. If the client has no computer that can run local tools, stop and tell Jesse/BridgePilot.

### 12. Keywords (optional, can be filled later)
What would a homeowner type into XHS search to find your service? Fill `keyword_pool` from the answers and from `references/seo-guide.md`.

## Finish
1. Run `python3 scripts/profile-check.py $XHS_HOME/profile.json`. Fix every listed problem.
2. Set `status.interview_complete` true.
3. Read the whole profile back to the client in plain words (not JSON). Ask for one yes.
4. Go on to SYSTEM PREPARATION in `SETUP.md`.
