# First-run interview

Goal: prepare a usable profile quickly, then refine creative preferences during the first video. Start from the blank template only when no saved profile exists.

## How to run it
- Read client-supplied websites and business documents before asking for facts. Prefill business name, services, areas, audience and voice cues with their source; label inferences and missing facts. Present one short profile summary for confirmation. Do not re-ask confirmed facts.
- Treat the sections below as a coverage checklist, not a fixed question-by-question script. Ask roughly 3–5 related, unresolved questions per group, with recommended answers; the client may accept the group or change selected items. Use one question when it genuinely needs separate attention or the client prefers it.
- A useful first group is audience, language/tone, inquiry handoff, and success metric. Keep the three automation choices separately labelled with OFF recommendations and the risk note; accepting a creative group cannot enable them.
- Save answers after each group. Every business claim needs a source: client/date, a supplied document/URL, or UNVERIFIED. A recommendation becomes a confirmed fact only after the client accepts it. UNVERIFIED claims stay out of posts.
- A sample post and keywords are optional. Defer account details that are not needed yet; verify the actual account before opening its publish form. Do not invent placeholders to pass validation.
- Creative settings are provisional starting points. Inspect the first footage, then develop the opening, length, pace, captions, music and brand tag through the selected storyline, storyboard and preview. Save reusable choices under `final_cut`; record one-video exceptions under the job's `video-brief.json` > `requirements`.
- Use the client's language. Never ask for passwords, codes, payment details, or customer private details. A test profile is not authorization to send, publish, or schedule.

## Coverage checklist

### 1. The XHS account
Does the account exist today? Handle (the name, not a login). Personal or professional (专业号)? About how many followers? Who runs it now? Is the client signed in to the XHS creator center in the Chrome they use on this computer?
-> `client.xhs_handle`, `client.account_type`. If there is no account yet, the client creates it before any account-access step; local profile and video planning can continue. Sign-up, phone checks and captchas are theirs.

### 2. Brand material
Business name as customers know it. What services do you sell today (one line each)? Which cities or areas do you serve (city names only)? What makes you different, in your own words (1-3 things, each one true and provable)? Who is the customer?
-> `client.business_name`, `brand.services[]`, `brand.service_area`, `brand.differentiators[]`, `brand.audience`. Services are a list so a new service later = one more row in this file.

### 3. Voice
Mandarin or Cantonese-flavoured written Chinese for posts and replies? (XHS is read in Simplified Chinese.) Spoken, like talking to a neighbour, or written and tidy? Optionally share a finished post you like and why; allow “later.”
-> `voice.*`. The sample post is the style target. Say plainly: "My Chinese will be a draft. You rewrite it; I learn from your edits."

### 4. Final cut and style
Offer a small group of starting recommendations based on the footage: length (usually 15–20 seconds, with explicit requests supported from 3–60 seconds), opening, short Chinese captions, pace and brand tag. If music is requested, recommend the free catalog with sign-in, while offering a provided licensed track, in-app music, or none. Set `music_source`; complete catalog setup before delivering a preview with requested BGM.
-> `final_cut.*`. Keep `preferences_confirmed` false until the client accepts reusable settings. Do not require every creative answer before the first storyboard. A 60-second request is not a new default for other clients.

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

### 10. The three switches (separate choices, default OFF)
Give this risk note with the group, keeping each choice explicit: "XHS may limit accounts that use automation. If it does, the skill stops and tells you. You can turn this off any time with the kill switch." Then ask:
- (a) Auto-publish: after you approve the exact post, should I press 发布 myself? Default: no, I fill the form and you press it. (Auto-publish was proven on one other account.)
- (b) Auto-reply to comments: should I send replies that match wording you approved? Default: no, I draft, you send. (Not yet proven.)
- (c) Auto-reply to DMs: same. Default: no. (Not yet proven.)
A group acceptance applies to its clearly listed recommendations; if creative and automation intent is ambiguous, leave switches OFF and clarify. Record each answer separately in `automation.*`, set `asked_on` to today's date, and set `warning_acknowledged` true only after the client has heard the note. If any switch is on, repeat the kill-switch command to the client: `bash scripts/kill-switch.sh on`.

### 11. Computer, tools and footage path
Which computer (Mac or Windows) and which system version? Which agent app is being used, and does it expose local files, commands and BrowserSkill? Ask about a plan only if a verified required feature depends on it. Which browser holds the XHS login (Chrome recommended)? How does footage get from the phone to this computer (cable, AirDrop, a Drive or Dropbox folder)? Which folder should I read it from?
-> `system.*`. A phone or tablet alone cannot run the cutdown. If the client has no computer that can run local tools, stop and tell Jesse/BridgePilot.

### 12. Keywords (optional, can be filled later)
What would a homeowner type into XHS search to find your service? Fill `keyword_pool` from the answers and from `references/seo-guide.md`.

## Finish
1. Read back the confirmed business essentials, provisional creative defaults, deferred fields, and separate automation choices in one compact summary. Get the client's confirmation.
2. Set `status.interview_complete: true` and run `python3 scripts/profile-check.py <profile>`. Fix real validation problems; do not fabricate optional values. If validation fails, restore `interview_complete: false` until corrected.
3. Continue system preparation and the first video. Update the profile as the client reviews the storyboard and preview instead of restarting the interview.
