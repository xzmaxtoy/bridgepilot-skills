# Chinese copy: drafting rules

The current agent drafts the Chinese itself, for the client to rewrite. No outside writing service.

## Always
- Label every Chinese output **DRAFT 草稿**. Remove the label only after the client says the text is approved.
- Use the matching `profile.json` > `voice` when available, otherwise the client's current instructions/job brief; ask only essential wording questions and label provisional defaults. Do not require a full interview to draft copy. Voice fields: language (Mandarin / Cantonese-flavoured), register (spoken / written), the sample post, tone notes. Match the sample's sentence length and habits.
- Simplified Chinese. Short sentences. One idea per sentence. Real words a neighbour would say. Cut filler connectors (综上所述, 总而言之) and stiff phrases (为您提供优质服务).
- Facts only from the profile or from what the client said in this job. Never invent a number, date, name, price, duration, quote or customer story. If a fact is missing, leave a visible gap `[待补：...]` and ask.
- Allowed claims: only items in `brand.services`, `brand.differentiators` and `red_lines.claims_sourced_by_client` that carry a real source (not UNVERIFIED).
- Never: licensed, insured, bonded, years in business, price or discount, "best / first / only / 100% / guaranteed / free", contact IDs, phone numbers, links, QR codes, other platform names, competitor names. `scripts/lint-copy.py` catches most of these; it cannot catch invented facts.

## Caption format (`caption.md`)
```
DRAFT 草稿 (line 1: delete this line only after the client approves)
<line 2 = the title: 20 characters at most, core word in the first half>
<body: 300-500 characters, short paragraphs, a separator emoji every 2-3 paragraphs, core word once in the first 100 characters>
<closing question that invites a comment>
#topic1 #topic2 #topic3 #topic4 #topic5   (5-8 existing topics only)
FIRST COMMENT:
<a real question, no self-praise, no link>
```
`scripts/lint-copy.py` reads exactly this layout: a first line that starts with DRAFT or 草稿 is the marker and is ignored by the length checks; the next non-empty line is the title; everything after a line starting `FIRST COMMENT:` (or `首评:`) is the first comment and is not counted in the body. Format checks: `references/review-gate.md` F1-F7. The ranking word 第一 is only flagged as a claim (第一名, 行业第一); 第一步, 第一次 and similar are fine.

## After drafting
Show the draft with 2 lines on top: what is invented (nothing) and what is missing (the `[待补]` gaps). Ask the client to rewrite in their words. Keep their rewritten version as the truth; learn the habits (sentence length, particles, words they chose) and append one line to `$XHS_HOME/log/patterns/voice.md` so the next draft is closer.

## Replies (comments and DMs)
Same rules, plus: at most 280 characters; thank, answer the one thing asked, invite the next step in plain words from `contact_handoff.plain_text_wording`. Escalate anything about price, booking, complaints, safety, abuse or a request for a contact.
